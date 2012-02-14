unit main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, DB, IBDatabase, DBGrids, ComCtrls, IBCustomDataSet,
	StrUtils, DateUtils, crew_utils, IBQuery;

type
	Tform_main = class(TForm)
		grid_crew : TStringGrid;
		Label1 : TLabel;
		Label2 : TLabel;
		edit_zakaz4ik : TEdit;
		edit_adres : TEdit;
		Label3 : TLabel;
		Label5 : TLabel;
		Label4 : TLabel;
		db_main : TIBDatabase;
		stbar_main : TStatusBar;
		ta_main : TIBTransaction;
		DBGrid1 : TDBGrid;
		datasource_main : TDataSource;
		ibquery_main : TIBQuery;
		grid_gps : TStringGrid;
		grid_order : TStringGrid;
		procedure FormCreate(Sender : TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	form_main : Tform_main;
	cur_time : TDateTime;

implementation

{$R *.dfm}

procedure show_status(status : string);
begin
	form_main.stbar_main.Panels[0].Text := status;
end;

function sql_select(sel : string) : integer;
begin
	with form_main do
	begin
		ibquery_main.SQL.Clear;
		ibquery_main.SQL.Add(sel);
		try
			ibquery_main.Prepare;
		except
			show_status('неверный запрос к БД');
			result := -1;
			exit;
		end;
		ibquery_main.Open;
		show_status('запрос произведён');
	end;
	result := 0;
end;

function coords_to_str(fields : TFields) : TStringList;
var
	field : TField; // main file
	j, l : integer;
	// s, s2, d : string;
	b : TBytes;
	pint : ^integer;
	plat, plong : ^single;
	s, sdate1, sdate2, sid, scoords : string;
	res : TStringList;
begin
	res := TStringList.Create;
	sdate1 := fields[1].AsString;
	sdate2 := fields[2].AsString;
	field := fields[3];
	l := field.DataSize;
	setlength(b, l);
	b := field.AsBytes;
	j := 0;
	while j < l do
	begin
		pint := @b[j];
		plat := @b[j + 8];
		plong := @b[j + 4];
		if pint^ > 0 then
		begin
			sid := inttostr(pint^);
			scoords := StringReplace(floattostr(plat^), ',', '.', [rfReplaceAll]) + ', ' + StringReplace(floattostr(plong^), ',', '.', [rfReplaceAll]);
		end;
		s := sid + '::      ' + sdate1 + ' -- ' + sdate2 + '        (' + scoords + ')';
		res.Append(s);
		j := j + 12;
	end;
	result := res;
end;

function get_coord_list() : TStringList;
var
	sel : string;
	j : integer;
	coords, list : TStringList;
begin
	cur_time := now();
	sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS from CREWS_COORDS where MEASURE_START_TIME>''2011-10-03 14:57:50'' order by MEASURE_START_TIME ASC, ID ASC';
	// sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS from CREWS_COORDS order by MEASURE_START_TIME ASC, ID ASC';
	sql_select(sel);
	with form_main do
	begin
		list := TStringList.Create;
		while (not ibquery_main.Eof) do
		begin
			coords := coords_to_str(ibquery_main.fields);
			j := 0;
			while (j < coords.Count) do
			begin
				list.Append(coords.Strings[j]);
				inc(j);
			end;
			ibquery_main.Next;
		end;
		list.Sorted := true;
	end;
	result := list;
end;

function get_sql_list(sel : string; sort_flag : boolean) : TStringList;
var
	res : string;
	list : TStringList;
	field : TField;
begin
	sql_select(sel);
	with form_main do
	begin
		list := TStringList.Create;
		while (not ibquery_main.Eof) do
		begin
			res := '';
			for field in ibquery_main.fields do
			begin
				res := res + field.AsString + '|';
			end;
			list.Append(res);
			ibquery_main.Next;
		end;
		if sort_flag then
			list.Sorted := true;
	end;
	result := list;
end;

function get_crew_list() : TStringList;
var
	sel : string;
begin
	// sel := 'select CREWS.ID, CREWS.STATE, CREWS.IDENTIFIER as GpsId, CREWS.CODE, CREWS.NAME from CREWS where (CREWS.STATE=2 or CREWS.STATE=0) order by GpsId';
	sel := 'select CREWS.IDENTIFIER as GpsId, CREWS.ID, CREWS.STATE, CREWS.CODE, CREWS.NAME from CREWS order by GpsId';
	result := get_sql_list(sel, false);
end;

function get_order_list() : TStringList;
var
	sel : string;
begin
	// sel := 'select CREWS.ID, CREWS.STATE, CREWS.IDENTIFIER as GpsId, CREWS.CODE, CREWS.NAME from CREWS where (CREWS.STATE=2 or CREWS.STATE=0) order by GpsId';
	sel := 'select STARTTIME, ID, STATE, SOURCE, DESTINATION  from ORDERS order by STARTTIME DESC';
	result := get_sql_list(sel, false);
end;

procedure show_grid(list : TStringList; var grid : TStringGrid);
begin
	grid.ColCount := 1;
	grid.RowCount := list.Count;
	grid.ColWidths[0] := grid.Width;
	grid.Cols[0].Assign(list);
end;

procedure show_tmp();
var
	list_coord, list_crew, list_order : TStringList;
begin
	with form_main do
	begin
		list_coord := get_coord_list();
		show_grid(list_coord, grid_gps);
		list_crew := get_crew_list();
		show_grid(list_crew, grid_crew);
		list_order := get_order_list();
		show_grid(list_order, grid_order);
		// grid_gps.ColCount := 1;
		// grid_gps.RowCount := list.Count;
		// grid_gps.Cols[0].Assign(list);

	end;
end;

function open_database() : boolean;
begin
	with form_main do
	begin
		with db_main do
		begin
			SQLDialect := 3;
			// DatabaseName := 'localhost:D:\fbdb\tme.fdb';
			DatabaseName := 'localhost:c:\Program Files\TMEnterpriseDemo\tme_demo_db.fdb';
			// LoginPrompt := False;		{off window-prompt user and passwd}
			// Params.Clear;				{see dfm.form_main.db_main.Params}
			// Params.Add('user_name=SYSDBA');
			// Params.Add('password=masterkey');
			// Params.Add('lc_ctype=WIN1251');
		end;
		try
			db_main.Connected := true;
			show_status('успешное подключение к БД');
			result := true;
		except
			show_status('ошибка при открытии БД');
			result := False;
		end;
	end;
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	with form_main do
	begin
		grid_crew.ColWidths[0] := 560; // 120;
		grid_crew.ColWidths[1] := 180;
		grid_crew.ColWidths[2] := 570 - (120 + 180) - 5;
	end;

	if open_database() then
	begin
		show_tmp();
	end;

end;

end.
