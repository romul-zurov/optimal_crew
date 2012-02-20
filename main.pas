unit main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, DB, IBDatabase, DBGrids, ComCtrls, IBCustomDataSet,
	StrUtils, DateUtils, crew_utils, IBQuery, OleCtrls, SHDocVw, EncdDecd;

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
		browser : TWebBrowser;
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
			scoords := StringReplace(floattostr(plat^), ',', '.', [rfReplaceAll]) + ', ' + StringReplace
				(floattostr(plong^), ',', '.', [rfReplaceAll]);
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

function get_crew_list(sdate : string) : TStringList;
// извлекаем рабочие экипажи
var
	sel : string;
begin
	// sel := 'select CREWS.ID, CREWS.STATE, CREWS.IDENTIFIER as GpsId, CREWS.CODE, CREWS.NAME from CREWS where (CREWS.STATE=2 or CREWS.STATE=0) order by GpsId';
	// sel := 'select CREWS.IDENTIFIER as GpsId, CREWS.ID, CREWS.STATE, CREWS.CODE, CREWS.NAME from CREWS order by GpsId';
	sel := 'select CREWS.IDENTIFIER, CREWS_H.STATETIME, CREWS_H.TOSTATE, CREWS.NAME, CREWS.FINISHTIME' +
		' from CREWS_H, CREWS where CREWS_H.STATETIME > ''' + sdate +
		''' and (CREWS_H.TOSTATE = 1 or CREWS_H.TOSTATE = 3) and CREWS.ID = CREWS_H.CREWID order by CREWS_H.STATETIME desc';
	result := get_sql_list(sel, false);
end;

function get_order_list(sdate : string) : TStringList;
// заказы занятых экипажей
var
	sel : string;
begin
	sdate := '''' + sdate + '''';
	// sel := 'select STARTTIME, STATE, SOURCE, STOPS_COUNT, STOPS, DESTINATION  from ORDERS where STOPS_COUNT > 0   order by STARTTIME DESC';
	sel :=
		'select CREWS.IDENTIFIER, CREWS.NAME, ORDERS.SOURCE, ORDERS.STOPS_COUNT, ORDERS.STOPS, ORDERS.DESTINATION'
		+ ' from CREWS_H, CREWS, ORDERS' + ' where CREWS_H.STATETIME > ' + sdate + ' and ORDERS.STARTTIME > ' + sdate +
		' and (CREWS_H.TOSTATE = 3) and (CREWS.ID = CREWS_H.CREWID) and (ORDERS.CREWID = CREWS_H.CREWID)';

	result := get_sql_list(sel, true);
end;

function param64(s : AnsiString) : AnsiString;
var ss : AnsiString;
	p : Pointer;
begin
	p := Pointer(s);
	ss := EncodeBase64(p, Length(s));
	ss := StringReplace(ss, chr(10), '', [rfReplaceAll]);
	ss := StringReplace(ss, chr(13), '', [rfReplaceAll]);
	ss := StringReplace(ss, '+', ';', [rfReplaceAll]);
	ss := StringReplace(ss, '=', '_', [rfReplaceAll]);
	result := ss;
end;

function get_track_time(surl : AnsiString) : integer;
type
	t1251 = type AnsiString(1251);
var cp1251 : t1251;
	ss : TStringStream;
	sw : widestring;
begin
	with form_main do
	begin
		cp1251 := surl;
		ss := TStringStream.Create(surl, 1251);
		// sw := ss.DataString;
		sw := widestring(ss.Bytes);
		browser.Navigate(sw);
	end;
end;

procedure show_grid(list : TStringList; var grid : TStringGrid);
begin
	grid.ColCount := 1; grid.RowCount := list.Count; grid.ColWidths[0] := grid.Width;
	grid.Cols[0].Assign(list);
end;

procedure show_tmp();
const SDAY = '2011-10-03 00:00:00';
var list_coord, list_crew, list_order : TStringList;
	surl : AnsiString;
begin
	with form_main do
	begin
		list_coord := get_coord_list(); show_grid(list_coord, grid_gps);
		list_crew := get_crew_list(SDAY);
		// RemoveDuplicates(list_crew);
		show_grid(list_crew, grid_crew); list_order := get_order_list(SDAY); show_grid(list_order, grid_order);

		surl := 'http://robocab.ru/ac-taxi.php?param=' +
			'Imh0dHA6Ly9hYy10YXhpLnJ1L29yZGVyL3BvaW50X2Zyb20lNUJvYmolNUQlNUIlNUQ9' +
			'JTI2cG9pbnRfZnJvbSU1QmhvdXNlJTVEJTVCJTVEPSUyNnBvaW50X2Zyb20lNUJjb3JwJTVEJTVCJTVEPSUyNnBvaW50X2Zyb20lNUJ' +
			'jb29yZHMlNUQlNUIlNUQ9MzAuMjYwMTMlMjUyQzU5LjkzNzk4NCUyNnBvaW50X2ludCU1Qm9iaiU1RCU1QiU1RD0lQzElRTAlRUIlRj' +
			'IlRTglRTklRjElRUElRTAlRkYlMjAlRjMlRUIuJTI2cG9pbnRfaW50JTVCaG91c2UlNUQlNUIlNUQ9MjElMjZwb2ludF9pbnQlNUJjb' +
			'3JwJTVEJTVCJTVEPTElMjZwb2ludF9pbnQlNUJjb29yZHMlNUQlNUIlNUQ9JTI2cG9pbnRfdG8lNUJvYmolNUQlNUIlNUQ9JUMwJUUy' +
			'JUYyJUVFJUUyJUYxJUVBJUUwJUZGJTIwJUYzJUVCLiUyNnBvaW50X3RvJTVCaG91c2UlNUQlNUIlNUQ9MjElMjZwb2ludF90byU1QmN' +
			'vcnAlNUQlNUIlNUQ9MSUyNnBvaW50X3RvJTVCY29vcmRzJTVEJTVCJTVEPSIgIjx0ZCBjb2xzcGFuPVwiMlwiIGlkPVwicmVjYWxjT3' +
			'V0cHV0XCIgYWxpZ249XCJsZWZ0XCI;IiAiPC90ZD4i';
		//
		surl := 'http://ac-taxi.ru/order/point_from[obj][]=&point_from[house][]=&point_from[corp][]=' +
			'&point_from[coords][]=30.26013%2C59.937984&point_int[obj][]=Балтийская ул.&point_int[house][]=21' +
			'&point_int[corp][]=1&point_int[coords][]=&point_to[obj][]=Автовская ул.&point_to[house][]=21' +
			'&point_to[corp][]=1&point_to[coords][]=';
		edit_adres.Text := param64('"' + surl + '"');
		get_track_time(surl);
	end;
end;

function open_database() : boolean;
begin
	with form_main do
	begin
		with db_main do
		begin
			SQLDialect := 3;
			DatabaseName := 'localhost:D:\fbdb\tme.fdb';
			// DatabaseName := 'localhost:c:\Program Files\TMEnterpriseDemo\tme_demo_db.fdb';
			// LoginPrompt := False;		{off window-prompt user and passwd}
			// Params.Clear;				{see dfm.form_main.db_main.Params}
			// Params.Add('user_name=SYSDBA');
			// Params.Add('password=masterkey');
			// Params.Add('lc_ctype=WIN1251');
		end;
		try
			db_main.Connected := true; show_status('успешное подключение к БД'); result := true;
		except
			show_status('ошибка при открытии БД');
			result := false;
		end;
	end;
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	// with form_main do
	// begin
	// grid_crew.ColWidths[0] := 560; // 120;
	// grid_crew.ColWidths[1] := 180;
	// grid_crew.ColWidths[2] := 570 - (120 + 180) - 5;
	// end;

	if open_database() then
	begin
		show_tmp();
	end;

end;

end.
