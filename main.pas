unit main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, DB, IBDatabase, DBGrids, ComCtrls, IBCustomDataSet,
	StrUtils, DateUtils, IBQuery, OleCtrls, SHDocVw, MSHTML, ActiveX,
	crew, crew_utils;

type
	Tform_main = class(TForm)
		grid_crews : TStringGrid;
		Label1 : TLabel;
		Label2 : TLabel;
		edit_zakaz4ik : TEdit;
		edit_ap_street : TEdit;
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
		Button1 : TButton;
		Label6 : TLabel;
		edit_ap_house : TEdit;
		Label7 : TLabel;
		edit_ap_korpus : TEdit;
		Label8 : TLabel;
		edit_ap_gps : TEdit;
		Label9 : TLabel;
		procedure FormCreate(Sender : TObject);
		procedure Button1Click(Sender : TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	form_main : Tform_main;
	cur_time : TDateTime;
	crew_list : TCrewList;
	ac_taxi_url : string;

implementation

{$R *.dfm}

procedure show_status(status : string);
begin
	form_main.stbar_main.Panels[0].Text := status;
end;

function sql_select(sel : string) : Integer;
begin
	with form_main do
	begin
		ibquery_main.SQL.Clear;
		ibquery_main.SQL.Add(sel);
		try
			ibquery_main.Prepare;
		except
			show_status('�������� ������ � ��');
			result := -1;
			exit;
		end;
		ibquery_main.Open;
		show_status('������ ���������');
	end;
	result := 0;
end;

function ret_crews_stringlist(var clist : TCrewList) : TSTringList;
	procedure add_s(var s : string; subs : string);
	begin
		s := s + '|' + subs;
	end;

var res : TSTringList;
	pp, ps : Pointer;
	s, sc : string;
begin
	res := TSTringList.Create();
	for pp in clist.Crews do
	begin
		with clist.crew(pp) do
		begin
			s := IntToStr(CrewId);
			add_s(s, IntToStr(GpsId));
			add_s(s, IntToStr(State));
			add_s(s, FloatToStr(dist / 1000.0));
			add_s(s, IntToStr(Time));
			add_s(s, Coord);
			add_s(s, Code); add_s(s, name);
			for sc in coords do
				add_s(s, sc);
			res.Append(s);
		end;
	end;
	result := res;
end;

function coords_to_str(fields : TFields; var clist : TCrewList) : TSTringList;
var
	field : TField; // main file
	j, l, id : Integer;
	// s, s2, d : string;
	b : TBytes;
	pint : ^Integer;
	plat, plong : ^single;
	s, sdate1, sdate2, sgpsid, scoords : string;
	res : TSTringList;
	crew : TCrew;
	pp : Pointer;

begin
	res := TSTringList.Create;
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
			sgpsid := IntToStr(pint^);
			scoords := StringReplace(FloatToStr(plat^), ',', '.', [rfReplaceAll]) + ',' + StringReplace
				(FloatToStr(plong^), ',', '.', [rfReplaceAll]);
		end;
		s := sgpsid + '|' + date_to_full(sdate2) + '|(' + scoords + ')';
		res.Append(s);
		j := j + 12;

		// !!! ---
		// if crew_list.isGpsgpsidInList(StrToInt(sgpsid)) then
		pp := clist.findByGpsId(StrToInt(sgpsid));
		if pp = nil then
			crew := clist.crew(crew_list.Append(StrToInt(sgpsid)))
		else
			crew := clist.crew(pp);
		crew.append_coords(scoords, date_to_full(sdate2));
		// !!!---
	end;
	result := res;
end;

function get_coord_list(var clist : TCrewList; Coord : string) : TSTringList;
var
	sel : string;
	j : Integer;
	coords, slist : TSTringList;
begin
	cur_time := now();
	sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS from CREWS_COORDS where MEASURE_START_TIME>''2011-10-03 14:57:50'' order by MEASURE_START_TIME ASC, ID ASC';
	// sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS from CREWS_COORDS order by MEASURE_START_TIME ASC, ID ASC';
	sql_select(sel);
	with form_main do
	begin
		slist := TSTringList.Create;
		while (not ibquery_main.Eof) do
		begin
			coords := coords_to_str(ibquery_main.fields, clist);
			j := 0;
			while (j < coords.Count) do
			begin
				slist.Append(coords.Strings[j]);
				inc(j);
			end;
			ibquery_main.Next;
		end;
		slist.Sorted := true;
	end;
	clist.set_current_crews_coord();
	clist.set_crews_dist(Coord);
	exit(slist);
end;

function get_sql_list(sel : string; sort_flag : boolean) : TSTringList;
var
	res : string;
	list : TSTringList;
	field : TField;
begin
	sql_select(sel);
	with form_main do
	begin
		list := TSTringList.Create;
		while (not ibquery_main.Eof) do
		begin
			res := '';
			for field in ibquery_main.fields do
			begin
				res := res + field.AsString + '|';
			end;
			if res[length(res)] = '|' then
				delete(res, length(res), 1);
			list.Append(res);
			ibquery_main.Next;
		end;
		if sort_flag then
			list.Sorted := true;
	end;
	result := list;
end;

function get_crew_list(sdate : string; var clist : TCrewList) : TSTringList;
// ��������� ������� �� gps_id
	function get_list(sz : string) : TSTringList;
	begin
		form_main.edit_zakaz4ik.Text := sz;
		exit(get_sql_list(sz, false));
	end;

var
	sel, s, sid : string;
	res, sl : TSTringList;
	id, GpsId : Integer;
begin
	sdate := '''' + sdate + '''';
	// sel := 'select CREWS.ID, CREWS.STATE, CREWS.IDENTIFIER as GpsId, CREWS.CODE, CREWS.NAME from CREWS where (CREWS.STATE=2 or CREWS.STATE=0) order by GpsId';
	// sel := 'select CREWS.IDENTIFIER as GpsId, CREWS.ID, CREWS.STATE, CREWS.CODE, CREWS.NAME from CREWS order by GpsId';

	sel := 'select CREWS.IDENTIFIER, CREWS.ID, CREWS_H.TOSTATE, CREWS.CODE, CREWS.NAME' +
		' from CREWS_H, CREWS where' + ' CREWS_H.STATETIME > ' + sdate +
		' and (CREWS_H.TOSTATE = 1 or CREWS_H.TOSTATE = 3) ';
	sel := sel + ' and CREWS.IDENTIFIER in (' + clist.get_gpsid_list_as_string() + ') ';
	sel := sel + ' and CREWS_H.CREWID = CREWS.ID ' + ' order by CREWS_H.STATETIME desc';

	// !!
	sel :=
		'select CREWS.IDENTIFIER, CREWS.ID, CREWS.CODE, CREWS.NAME from CREWS where '
		+ ' CREWS.IDENTIFIER in (' + clist.get_gpsid_list_as_string() + ') ';
	res := get_list(sel);
	clist.set_crewId_by_gpsId(res);
	sel := 'select CREWS.ID, CREWS_H.TOSTATE from CREWS, CREWS_H where ' + ' CREWS.ID in (' +
		clist.get_crewid_list_as_string() + ') ' + ' and CREWS_H.STATETIME > ' + sdate +
		' and CREWS_H.CREWID = CREWS.ID ';
	res := get_list(sel);
	clist.set_crews_state_by_crewId(res);
	clist.Crews.Sort(sort_crews_by_state_dist);
	result := res;
end;

function get_order_list(sdate : string) : TSTringList;
// ������ ������� ��������
var
	sel : string;
begin
	// ����������!
	sdate := '''' + sdate + '''';
	// sel := 'select STARTTIME, STATE, SOURCE, STOPS_COUNT, STOPS, DESTINATION  from ORDERS where STOPS_COUNT > 0   order by STARTTIME DESC';
	sel :=
		'select CREWS.IDENTIFIER, CREWS.NAME, ORDERS.SOURCE, ORDERS.STOPS_COUNT, ORDERS.STOPS, ORDERS.DESTINATION'
		+ ' from CREWS_H, CREWS, ORDERS' + ' where CREWS_H.STATETIME > ' + sdate +
		' and ORDERS.STARTTIME > ' + sdate +
		' and (CREWS_H.TOSTATE = 3) and (CREWS.ID = CREWS_H.CREWID) and (ORDERS.CREWID = CREWS_H.CREWID)';

	result := get_sql_list(sel, true);
end;

function html_to_string(WB : TWebBrowser) : string;
var
	StringStream : TStringStream;
	Stream : IStream;
	PersistStream : IPersistStreamInit;
	res : string;
begin
	res := 'error';
	PersistStream := WB.Document as IPersistStreamInit;
	StringStream := TStringStream.Create('');
	Stream := TStreamAdapter.Create(StringStream, soReference) as IStream;
	try
		PersistStream.Save(Stream, true);
		res := StringStream.DataString;
	finally
		StringStream.Free;
	end;
	res := get_substr(res, '&lt;&lt;&lt;', '&gt;&gt;&gt;');
	result := res;
end;

function get_zapros(surl : string) : string;
var
	Doc : IHTMLDocument2;
	s : string;
begin
	with form_main do
	begin
		browser.Navigate(surl);
		Doc := browser.Document as IHTMLDocument2;
		while browser.ReadyState < READYSTATE_COMPLETE do
			Application.ProcessMessages;
		s := html_to_string(browser);
		result := s; // 'Foo String';
	end;
end;

function get_crew_way_time(var points : TList) : Integer;
	procedure add_s(var s : string; s1, s2, s3, s4 : string; num : Integer);
	var ss : string;
	begin
		case num of
			0 :
				ss := 'from';
			1 :
				ss := 'int';
			-1 :
				ss := 'to';
		end;
		s := s + 'point_' + ss + '[obj][]=' + s1 + '&';
		s := s + 'point_' + ss + '[house][]=' + s2 + '&';
		s := s + 'point_' + ss + '[corp][]=' + s3 + '&';
		s := s + 'point_' + ss + '[coords][]=' + s4 + '&';
	end;

var i, c, n, t : Integer;
	a : TAdres;
	surl, res : string;
begin
	c := points.Count;
	if c < 2 then
		exit(-1);
	surl := ac_taxi_url + 'order?service=1&';
	for i := 0 to c - 1 do
	begin
		if i = 0 then
			n := 0
		else if i = (c - 1) then
			n := -1
		else
			n := 1;
		a := TAdres(points.Items[i]);
		add_s(surl, a.street, a.house, a.korpus, a.gps, n);
	end;
	surl := '"' + surl + '"' + ' "id=\"recalcOutput\" align=\"left\">" "</td>"';
	surl := param64(surl);
	surl := 'http://robocab.ru/ac-taxi.php?param=' + surl;
	res := get_zapros(surl);

	// ------
	form_main.edit_zakaz4ik.Text := res;
	res := get_substr(res, '����� (� ������ ������): ', ' ���.');
	try
		t := StrToInt(res);
		exit(t);
	except
		exit(-1);
	end;
end;

function get_gps_coords_for_adres(ulica, dom, korpus : string) : string;
	function get_coords() : string;
	var surl : string;
	begin
		surl := ac_taxi_url + 'order?service=1&';
		surl := surl + 'point_from[obj][]=' + ulica + '&';
		surl := surl + 'point_from[house][]=' + dom + '&';
		surl := surl + 'point_from[corp][]=' + korpus + '&';
		surl := surl + 'point_to[obj][]=' + ulica + '&';
		surl := surl + 'point_to[house][]=' + dom + '&';
		surl := surl + 'point_to[corp][]=' + korpus + '&';

		surl := '"' + surl + '"' + ' "DayGPSKoordinatPoAdresu" "foo"';
		surl := param64(surl);
		surl := 'http://robocab.ru/ac-taxi.php?param=' + surl;

		result := get_zapros(surl);
	end;

var surl, res : string;
begin
	res := get_coords();
	if pos('Error', res) > 0 then
		res := '';
	result := res;
end;

function get_track_time(surl : AnsiString) : Integer;
begin
	with form_main do
	begin
	end;
	result := 0;
end;

procedure show_result_crews_grid(var list : TCrewList);
var pp : Pointer;
	r : Integer;
	crew : TCrew;
begin
	with form_main do
	begin
		grid_crews.RowCount := 0;
		r := 0;
		for pp in list.Crews do
		begin
			crew := list.crew(pp);
			grid_crews.RowCount := r + 1;
			grid_crews.Cells[0, r] := crew.name;
			grid_crews.Cells[1, r] := IntToStr(crew.Time);
			grid_crews.Cells[2, r] := FloatToStrF(crew.dist / 1000.0, ffFixed, 3, 3);
			grid_crews.Cells[3, r] := crew.state_as_string;
			inc(r);
		end;
	end;
end;

procedure show_grid(var list : TSTringList; var grid : TStringGrid);
begin
	grid.ColCount := 1; grid.RowCount := list.Count; grid.ColWidths[0] := grid.Width;
	grid.Cols[0].Assign(list);
end;

procedure show_tmp();
const SDAY = '2011-10-03 00:00:00';
var list_coord, list_crew, list_order, list_tmp : TSTringList;
	surl, sc1, sc2, ap_coord : string;
	i : Integer;
	pp : Pointer;
	a1, a2 : TAdres;
	alist : TList;

begin
	with form_main do
	begin

		// ������� ���ר� ������� �������� �� �� !;
		// 30.628900,60.031448       - crew 55
		// 30.375401,59.90293 - ���������� 7

		ap_coord := edit_ap_gps.Text;
		list_coord := get_coord_list(crew_list, ap_coord);
		show_grid(list_coord, grid_gps);

		// edit_adres.Text := IntToStr(crew_list.Crews.Count);

		list_crew := get_crew_list(SDAY, crew_list);
		// show_grid(list_crew, grid_crews);

		list_tmp := ret_crews_stringlist(crew_list); show_grid(list_tmp, grid_order);
		show_result_crews_grid(crew_list);

		edit_zakaz4ik.Text := get_gps_coords_for_adres(edit_ap_street.Text, edit_ap_house.Text,
			edit_ap_korpus.Text);

		// !!
		a1 := TAdres.Create('��������� ��������', '53', '3', '30.362589,59.848299');
		a2 := TAdres.Create('����� ����������', '7', '', '30.375401,59.90293');
		alist := TList.Create();
		alist.Add(Pointer(a1));
		alist.Add(Pointer(a2));
		show_status(IntToStr(get_crew_way_time(alist)));


		// if crew_list.crewByGpsId(9).is_crew_was_in_coord('30.3088703155518,59.9947509765625') then
		// edit_zakaz4ik.Text := 'ASDFGHJKL!';

		// list_order := get_order_list(SDAY); show_grid(list_order, grid_order);

		// sc1 := get_gps_coords_for_adres('��������� �����.', '53', '3');
		// sc2 := get_gps_coords_for_adres('���������� �����.', '194', '');
		// sc1 := '30.362589,59.848299';
		// sc2 := '30.363829,59.848945';
		// edit_zakaz4ik.Text := sc1 + ' :: ' + sc2;
		// edit_adres.Text := floattostr(get_dist_from_coord(sc1, sc2));
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
			db_main.Connected := true; show_status('�������� ����������� � ��'); result := true;
		except
			show_status('������ ��� �������� ��');
			result := false;
		end;
	end;
end;

procedure Tform_main.Button1Click(Sender : TObject);
begin
	show_tmp();
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	ac_taxi_url := 'http://test.robocab.ru/';
	with form_main do
	begin
		grid_crews.ColWidths[0] := 360; // 120;
		grid_crews.ColWidths[1] := 180;
		grid_crews.ColWidths[2] := 180;
		grid_crews.ColWidths[3] := 280;
		edit_ap_street.Text := '���������� ��.';
		edit_ap_house.Text := '7';
		edit_ap_korpus.Text := '';
		edit_ap_gps.Text := '30.375004,59.902483';
	end;
	// form_main.DBGrid1.Hide();

	crew_list := TCrewList.Create();
	if open_database() then
	begin
		// show_tmp();
	end;

end;

end.
