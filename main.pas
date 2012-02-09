unit main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, DB, IBDatabase, DBGrids, ComCtrls, IBCustomDataSet,
	StrUtils, DateUtils, crew_utils;

type
	Tform_main = class(TForm)
		grid_crews : TStringGrid;
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
		dataset_main : TIBDataSet;
		DBGrid1 : TDBGrid;
		datasource_main : TDataSource;
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

function coords_to_str(field : TField) : TStringList;
var
	nfields, j, l, l2 : integer;
	s, s2, d : string;
	date0, date1, date2 : TDateTime;
	b : TBytes;
	pint : ^integer;
	plat, plong : ^single;
	sid, scoords : string;
	res : TStringList;

begin
	res := TStringList.Create;
	l := field.DataSize;
	l2 := l div 12;
	date0 := date0 / l2;
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
		res.Append(sid + ' :: ' + scoords);
		// res.Append(scoords);
		j := j + 12;
	end;

	result := res;
end;

procedure show_tmp();
var
	sel : string;
	i, j : integer;
	res, list : TStringList;
begin
	cur_time := now();
	with form_main do
	begin
		dataset_main.SelectSQL.Clear;
		// sel := 'select ID, STATE, CODE, NAME from CREWS order by ID';
		// sel := 'select ID, COORDS from CREWS_COORDS';
		sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS from CREWS_COORDS WHERE MEASURE_START_TIME>''2011-10-03 14:57:50'' ORDER BY MEASURE_START_TIME ASC, ID ASC';
		// sel := replace_day(sel, cur_time);
		// sel := 'select CREWS.ID, CREWS.STATE, CREWS.IDENTIFIER as GpsId, CREWS.CODE, CREWS.NAME from CREWS where (CREWS.STATE=2 or CREWS.STATE=0) order by GpsId';
		// sel := 'select CREWS.CODE, CREWS.NAME, CREWS_COORDS.COORDS from CREWS, CREW_STATE, CREWS_COORDS where CREW_STATE.SYSTEMSTATE=2 and CREWS.ID=CREW_STATE.ID and CREWS_COORDS.ID=CREW_STATE.ID';
		dataset_main.SelectSQL.Add(sel);
		dataset_main.Open;
		show_status('������ ���������');
		i := 0;
		grid_crews.RowCount := 0;
		grid_crews.ColCount := 1;
		list := TStringList.Create;
		while (not dataset_main.Eof) do
		begin
			res := coords_to_str(dataset_main.Fields[3]);
			j := 0;
			while (j < res.Count) do
			begin
				grid_crews.Cells[0, i] := res.Strings[j];
				inc(j);
				inc(i);
				grid_crews.RowCount := i + 1;
			end;
			dataset_main.Next;
		end;
		grid_crews.RowCount := grid_crews.RowCount - 1;
        list.Assign(grid_crews.Cols[0]);
        list.Sorted := true;
        grid_crews.Cols[0].Assign(list);
		// grid_crews.Cols[0].Sorted := True;
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
			db_main.Connected := True;
			show_status('�������� ����������� � ��');
			result := True;
		except
			show_status('������ ��� �������� ��');
			result := False;
		end;
	end;
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	with form_main do
	begin
		grid_crews.ColWidths[0] := 560; // 120;
		grid_crews.ColWidths[1] := 180;
		grid_crews.ColWidths[2] := 570 - (120 + 180) - 5;
	end;

	if open_database() then
	begin
		show_tmp();
	end;

end;

end.
