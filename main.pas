unit main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, DB, IBDatabase, DBGrids, ComCtrls, IBCustomDataSet,
	StrUtils, DateUtils, IBQuery, OleCtrls, SHDocVw, MSHTML, ActiveX, IniFiles, WinInet,
	crew, crew_utils, ExtCtrls;

type
	Tform_main = class(TForm)
		grid_crews : TStringGrid;
		Label1 : TLabel;
		Label2 : TLabel;
		edit_zakaz4ik : TEdit;
		edit_ap_street : TEdit;
		db_main : TIBDatabase;
		stbar_main : TStatusBar;
		ta_main : TIBTransaction;
		datasource_main : TDataSource;
		ibquery_main : TIBQuery;
		grid_order : TStringGrid;
		Label6 : TLabel;
		edit_ap_house : TEdit;
		Label7 : TLabel;
		edit_ap_korpus : TEdit;
		Label8 : TLabel;
		edit_ap_gps : TEdit;
		Label9 : TLabel;
		GridPanel_main : TGridPanel;
		panel_ap : TPanel;
		Button1 : TButton;
		cb_real_base : TCheckBox;
		GridPanel_grids : TGridPanel;
		GroupBox_order : TGroupBox;
		GroupBox_crew : TGroupBox;
		procedure FormCreate(Sender : TObject);
		procedure Button1Click(Sender : TObject);
		procedure browserDocumentComplete(ASender : TObject; const pDisp : IDispatch; var URL : OleVariant);
		procedure cb_real_baseClick(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	form_main : Tform_main;
	crew_list, res_crew_list : TCrewList;
	order_list : TOrderList;
	ac_taxi_url : string;
	Complete_Flag : boolean;

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
			show_status('неверный запрос к БД');
			result := -1;
			exit;
		end;
		ibquery_main.Open;
		show_status('запрос произведён');
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

function get_coord_list(const SCTIME : string; var clist : TCrewList) : TSTringList;
var
	sel : string;
	// Coord : string;
	j : Integer;
	coords, slist : TSTringList;
begin
	cur_time := now();
	sel :=
		'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS from CREWS_COORDS where MEASURE_START_TIME>''' +
		SCTIME + ''' order by MEASURE_START_TIME ASC, ID ASC';
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
	clist.set_crews_dist(clist.ap_gps);
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
// извлекаем экипажи по gps_id
	function get_list(sz : string) : TSTringList;
	begin
		form_main.edit_zakaz4ik.Text := sz;
		exit(get_sql_list(sz, false));
	end;

var
	sel, s, sid, screws_gpsid : string;
	res, sl : TSTringList;
	id, GpsId : Integer;
begin

	sdate := '''' + sdate + '''';
	res := TSTringList.Create();
	{
	  sel := 'select CREWS.IDENTIFIER, CREWS.ID, CREWS_H.TOSTATE, CREWS.CODE, CREWS.NAME' +
	  ' from CREWS_H, CREWS where' + ' CREWS_H.STATETIME > ' + sdate +
	  ' and (CREWS_H.TOSTATE = 1 or CREWS_H.TOSTATE = 3) ';
	  sel := sel + ' and CREWS.IDENTIFIER in (' + clist.get_gpsid_list_as_string() + ') ';
	  sel := sel + ' and CREWS_H.CREWID = CREWS.ID ' + ' order by CREWS_H.STATETIME desc';
	  }

	// !!
	screws_gpsid := clist.get_gpsid_list_as_string();
	if length(screws_gpsid) = 0 then
		exit(res);
	sel := //
		'select CREWS.IDENTIFIER, CREWS.ID, CREWS.CODE, CREWS.NAME, CREWS.STATE from CREWS where ' //
		+ ' CREWS.IDENTIFIER in (' + screws_gpsid + ') ' //
	// только экипажи из crews по gpsId
		+ ' and CREWS.STATE in (1,3) '; // в состоянии "свободен" и "на заказе", согласно таблице CREW_STATE
	// + ' and LEFT(CREWS.CODE, 1) !=''Э'' '; // отбрасываем эвакуаторы - пока не нужно;
	res := get_list(sel);
	clist.set_crewId_by_gpsId(res);

	// sel := 'select CREWS.ID, CREWS_H.TOSTATE from CREWS, CREWS_H where ' + ' CREWS.ID in (' +
	// clist.get_crewid_list_as_string() + ') ' + ' and CREWS_H.STATETIME > ' + sdate +
	// ' and CREWS_H.CREWID = CREWS.ID ' + ' order by CREWS_H.STATETIME desc';
	// res := get_list(sel);
	// clist.set_crews_state_by_crewId(res); // - не нужно, т.к. State заполняется в set_crewId_by_gpsId

	clist.Crews.Sort(sort_crews_by_state_dist);
	result := res;
end;

function get_order_list(sdate : string; var clist : TCrewList) : TSTringList;
// заказы занятых экипажей
var
	sel : string;
	res : TSTringList;
begin
	// маршрут для " занятых " экипажей;
	// ID    SOURCE                       DESTINATION         STARTTIME            FINISHTIME
	// 143 | АКАДЕМИКА ЛЕБЕДЕВА УЛ., 6 | КОРОЛЕВА ПРОСП., 34 | 03.10.2011 14:22:44 | <null>     |
	// STATE_TIME           SOURCE_TIME          CREW_ACCEPT_TIME     GPRS_STATE_TIME
	// | 03.10.2011 14:48:57 | 03.10.2011 14:42:26 | 03.10.2011 14:22:44 | 03.10.2011 14:48:57 |

	sdate := '''' + sdate + '''';
	// sel := 'select STARTTIME, STATE, SOURCE, STOPS_COUNT, STOPS, DESTINATION  from ORDERS
	// where STOPS_COUNT > 0   order by STARTTIME DESC';
	sel := 'select ' //
		+ ' CREWS.ID, ORDERS.ID, ORDERS.SOURCE_TIME, ORDERS.SOURCE, ORDERS.DESTINATION, ' //
		+ ' ORDERS.STOPS_COUNT, ORDERS.STOPS ' //
		+ ' from CREWS, ORDERS ' //
		+ ' where ' //
		+ ' CREWS.ID in (' + clist.get_nonfree_crewid_list_as_string() + ') ' //
		+ ' and (ORDERS.CREWID = CREWS.ID) ' //
		+ ' and (ORDERS.STATE in (select ID from ORDER_STATES where SYSTEMSTATE = 1) ) ' //
		+ ' order by ORDERS.SOURCE_TIME desc ';

	res := get_sql_list(sel, false);
	clist.set_crews_orderId(res);
	exit(res);
end;

function get_current_orders() : TSTringList;
// заказы занятых экипажей
var
	sel : string;
	res : TSTringList;
begin
	// маршрут для " занятых " экипажей;
	// ID    SOURCE                       DESTINATION         STARTTIME            FINISHTIME
	// 143 | АКАДЕМИКА ЛЕБЕДЕВА УЛ., 6 | КОРОЛЕВА ПРОСП., 34 | 03.10.2011 14:22:44 | <null>     |
	// STATE_TIME           SOURCE_TIME          CREW_ACCEPT_TIME     GPRS_STATE_TIME
	// | 03.10.2011 14:48:57 | 03.10.2011 14:42:26 | 03.10.2011 14:22:44 | 03.10.2011 14:48:57 |

	// sdate := '''' + sdate + '''';
	// sel := 'select STARTTIME, STATE, SOURCE, STOPS_COUNT, STOPS, DESTINATION  from ORDERS
	// where STOPS_COUNT > 0   order by STARTTIME DESC';
	sel := 'select ' //
		+ ' ORDERS.ID, ORDERS.SOURCE_TIME, ORDERS.SOURCE, ORDERS.DESTINATION, ' //
		+ ' ORDERS.STOPS_COUNT, ORDERS.STOPS ' //
		+ ' from ORDERS ' //
		+ ' where ' //
	// + ' CREWS.ID in (' + clist.get_nonfree_crewid_list_as_string() + ') ' //
	// + ' and (ORDERS.CREWID = CREWS.ID) ' //
		+ ' (ORDERS.STATE in ' //
		+ '   (select ORDER_STATES.ID from ORDER_STATES where ORDER_STATES.SYSTEMSTATE in (0, 1) ) ' //
		+ ' ) ' //
		+ ' and ORDERS.IS_PRIOR = 0 ' //
		+ ' order by ORDERS.SOURCE_TIME desc ';

	res := get_sql_list(sel, false);
	// clist.set_crews_orderId(res);
	exit(res);
end;

function html_to_string(WB : TWebBrowser) : string;
var
	StringStream : TStringStream;
	Stream : IStream;
	PersistStream : IPersistStreamInit;
	res : string;
begin
	res := 'Error';
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
var Form : TForm;
	browser : TWebBrowser;
	s : string;
begin
	Form := TForm.Create(nil);
	browser := TWebBrowser.Create(nil);
	try
		InternetSetOption(nil, INTERNET_OPTION_END_BROWSER_SESSION, nil, 0); // end IE session
		// sleep(900);
		TWinControl(browser).Parent := Form;
		browser.Silent := true;
		browser.Align := alClient;
		Form.Width := 400;
		Form.Height := 100;
		Form.Show;
		if not DEBUG then
			Form.Hide;
		browser.Navigate(surl);
		while browser.ReadyState < READYSTATE_COMPLETE do
			Application.ProcessMessages;
		s := html_to_string(browser);
		if DEBUG then
			sleep(1000);
	finally
		browser.Free;
		Form.Free;
	end;
	exit(s); // 'Foo String';
end;

// function get_zapros_old(surl : string) : string;
// var
// Doc : IHTMLDocument2;
// s : string;
// begin
// with form_main do
// begin
// browser.Navigate(surl);
// Complete_Flag := false;
// Doc := browser.Document as IHTMLDocument2;
// while browser.ReadyState < READYSTATE_COMPLETE do
// Application.ProcessMessages;
// // while not browser.OnDocumentComplete do
// // pass;
// // Complete_Flag := false;
// s := html_to_string(browser);
// result := s; // 'Foo String';
// end;
// end;

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
	surl := ac_taxi_url + 'order?i_generate_address=1&service=0&';
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
	// surl := '"' + surl + '"' + ' "id=\"recalcOutput\" align=\"left\">" "</td>"';
	surl := '"' + surl + '"' + ' "DayVremyaPuti" "</td>"';
	form_main.edit_zakaz4ik.Text := surl;
	// form_main.Memo1.Text := form_main.Memo1.Text + '\n' + surl;
	surl := param64(surl);
	surl := 'http://robocab.ru/ac-taxi.php?param=' + surl;
	res := get_zapros(surl);

	// ------
	show_status(res);
	res := get_substr(res, 'Время (с учетом пробок): ', ' мин.');
	if (length(res) > 0) and (pos('Error', res) < 1) then
		try
			t := StrToInt(res);
			exit(t);
		except
			exit(-1);
		end;
	exit(-1);
end;

function get_gps_coords_for_adres(ulica, dom, korpus : string) : string;
	function get_coords() : string;
	var surl : string;
	begin
		surl := ac_taxi_url + 'order?i_generate_address=1&service=0&';
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
		res := 'Error';
	result := res;
end;

function get_track_time(surl : string) : Integer;
begin
	with form_main do
	begin
	end;
	result := 0;
end;

procedure show_orders_grid(var list : TOrderList);
var pp : Pointer;
	r : Integer;
	order : TOrder;
begin
	with form_main do
	begin
		with grid_order do
		begin
			// Width := 1280 - 10;     //  - define as alClient
			ColCount := 6;
			ColWidths[0] := 50;
			// ColWidths[1] := 200;
			ColWidths[2] := 120;
			ColWidths[3] := ColWidths[0];
			ColWidths[4] := 200; // (Width - ColWidths[0] - ColWidths[1] - ColWidths[2] - ColWidths[3] - 20) div 2;
			ColWidths[5] := ColWidths[4];
			ColWidths[1] := Width - 24 - ColWidths[0] - ColWidths[2] //
				- ColWidths[3] - ColWidths[4] - ColWidths[5];
		end;

		grid_order.RowCount := 0;
		grid_order.Rows[0].Clear;
		r := 0;
		for pp in list.Orders do
		begin
			order := list.order(pp);
			grid_order.RowCount := r + 1;
			grid_order.Cells[0, r] := IntToStr(order.id);
			if crew_list.crew(order.CrewId) <> nil then
				grid_order.Cells[1, r] := crew_list.crew(order.CrewId).name
			else
				grid_order.Cells[1, r] := '! ' + IntToStr(order.CrewId);
			grid_order.Cells[2, r] := order.source_time;
			grid_order.Cells[3, r] := order.time_as_string();
			with order.source do
				grid_order.Cells[4, r] := street + ', ' + house + '-' + korpus;
			with order.dest do
				grid_order.Cells[5, r] := street + ', ' + house + '-' + korpus;
			inc(r);
		end;
	end;
end;

procedure show_result_crews_grid(var list : TCrewList);
var pp : Pointer;
	r : Integer;
	crew : TCrew;
begin
	with form_main do
	begin
		with grid_crews do
		begin
			Width := form_main.GroupBox_crew.Width - 10;
			ColCount := 4;
			ColWidths[0] := 300;
			ColWidths[1] := 60;
			ColWidths[2] := 60;
			ColWidths[3] := 60;
		end;

		grid_crews.RowCount := 0;
		r := 0;
		for pp in list.Crews do
		begin
			crew := list.crew(pp);
			// if crew.Time < 0 then
			// Continue;

			grid_crews.RowCount := r + 1;
			grid_crews.Cells[0, r] := IntToStr(crew.CrewId) + ' | ' + crew.name;
			// grid_crews.Cells[0, r] := IntToStr(crew.CrewId);
			// grid_crews.Cells[1, r] := IntToStr(crew.Time);
			grid_crews.Cells[1, r] := crew.state_as_string;
			grid_crews.Cells[2, r] := crew.time_as_string;
			grid_crews.Cells[3, r] := FloatToStrF(crew.dist / 1000.0, ffFixed, 8, 3);
			inc(r);
		end;
	end;
end;

procedure get_show_crews_times(var clist : TCrewList; var rlist : TCrewList);
	procedure copy_list();
	var cr : TCrew;
		pp : Pointer;
	begin
		rlist.Crews.Clear;
		for pp in clist.Crews do
		begin
			cr := clist.crew(pp);
			if cr.Time >= 0 then
				rlist.Crews.Add(Pointer(cr));
		end;
	end;

	procedure ret_adr(value : string; var s, h, k : string);
	begin
		s := get_substr(value, '', ',');
		h := get_substr(value, ',', '');
		if pos('/', h) > 0 then
		begin
			k := get_substr(h, '/', '');
			h := get_substr(h, '', '/');
			if pos('-', k) > 0 then
				k := get_substr(k, '', '-');
		end
		else
			k := '';
	end;

var a1, a2, a3, a4 : TAdres;
	alist : TList;
	pp : Pointer;
	t, t_stops : Integer;
	ss2, ss3, s2, s3, h2, h3, k2, k3 : string;
	crew : TCrew;
begin
	// !!
	a1 := TAdres.Create('', '', '', '');
	a2 := TAdres.Create('', '', '', '');
	a3 := TAdres.Create('', '', '', '');
	with clist do
		a4 := TAdres.Create(ap_street, ap_house, ap_korpus, ap_gps);
	alist := TList.Create();
	rlist.Crews.Clear();

	while (clist.Crews.Count > rlist.Crews.Count) do
		for pp in clist.Crews do
			if (clist.crew(pp).Time < 0) { and (clist.crew(pp).State = 1) } then
			begin
				crew := clist.crew(pp);
				alist.Clear();
				a1.Clear();
				a1.setAdres('', '', '', crew_list.crew(pp).Coord);
				alist.Add(Pointer(a1));
				t_stops := 0;

				a2.Clear(); a3.Clear();
				if (crew_list.crew(pp).State = CREW_NAZAKAZE) then
				begin
					ss2 := get_substr(crew.order_way, '', ';');
					ss3 := get_substr(crew.order_way, ';', '');
					ret_adr(ss2, s2, h2, k2);
					ret_adr(ss3, s3, h3, k3);
					a2.setAdres(s2, h2, k2, '');
					a3.setAdres(s3, h3, k3, '');
					alist.Add(Pointer(a2));
					alist.Add(Pointer(a3));
					t_stops := 10 + 3;
				end;

				alist.Add(Pointer(a4));
				show_status('запрос времени для экипажа ' + IntToStr(clist.crew(pp).CrewId));
				t := get_crew_way_time(alist);
				if (t >= 0) then
				begin
					crew.set_time(t + t_stops);
					copy_list();
					rlist.Crews.Sort(sort_crews_by_time);
					show_result_crews_grid(rlist);
				end;
			end;
end;

procedure show_grid(var list : TSTringList; var grid : TStringGrid);
begin
	grid.ColCount := 1; grid.RowCount := list.Count; grid.ColWidths[0] := grid.Width;
	grid.Cols[0].Assign(list);
end;

procedure show_tmp();
var list_coord, list_crew, list_order, list_tmp : TSTringList;
	surl, sc1, sc2, ap_coord, SDAY, SCOORDTIME : string;
	i, t : Integer;
	pp : Pointer;
begin
	cur_time := now();
	// !!----------------------------------------------------------------------
	// form_main.edit_zakaz4ik.Text := //
	// replace_time('{Last_minute_0}', cur_time) //
	// + ' ' + replace_time('{Last_hour_10}', cur_time) //
	// + ' ' + replace_time('{Last_day_31}', cur_time) //
	// + ' ' + replace_time('{Last_minute_10}', cur_time) //
	// ;
	// exit();
	// ------------------------------------------------------------------------

	crew_list.clear_crew_list();
	with form_main do
	begin

		// 30.628900,60.031448       - crew 55
		// 30.362589,59.848299
		// 30.375401,59.90293 - самойловой 7

		// маршрут для " занятых " экипажей;
		// ID    SOURCE                       DESTINATION         STARTTIME            FINISHTIME
		// 143 | АКАДЕМИКА ЛЕБЕДЕВА УЛ., 6 | КОРОЛЕВА ПРОСП., 34 | 03.10.2011 14:22:44 | <null>     |
		// STATE_TIME           SOURCE_TIME          CREW_ACCEPT_TIME     GPRS_STATE_TIME
		// | 03.10.2011 14:48:57 | 03.10.2011 14:42:26 | 03.10.2011 14:22:44 | 03.10.2011 14:48:57 |

		grid_crews.RowCount := 0; // clear grid

		SDAY := '2011-10-03 00:00:00'; // for back-up base
		DEBUG_SDATE_FROM := '2011-10-03 00:00:00';
		DEBUG_SDATE_TO := '2011-10-04 00:00:00';
		SCOORDTIME := '2011-10-03 14:57:50'; // for back-up base

		if cb_real_base.Checked then
		begin
			SCOORDTIME := replace_minute('{Last_minute_30}', cur_time); // for real database
			SDAY := replace_hour('{Last_hour_4}', cur_time); // for real database
		end;

		if edit_ap_gps.Text = '' then
			edit_ap_gps.Text := get_gps_coords_for_adres(edit_ap_street.Text, edit_ap_house.Text,
				edit_ap_korpus.Text);

		// try to get current orders
		order_list := TOrderList.Create(ibquery_main);
		list_order := order_list.get_current_orders();
		crew_list.get_crew_list_by_crewid_string(order_list.get_crews_id_as_string());
		crew_list.get_crew_list();

		// Show orders:
		show_orders_grid(order_list);
		show_result_crews_grid(crew_list);
		exit(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		// set AP for crew_list and get coords for crews
		crew_list.set_ap(edit_ap_street.Text, edit_ap_house.Text, edit_ap_korpus.Text, edit_ap_gps.Text);
		list_coord := get_coord_list(SCOORDTIME, crew_list);
		// show_grid(list_coord, grid_gps);

		// edit_adres.Text := IntToStr(crew_list.Crews.Count);

		list_crew := get_crew_list(SDAY, crew_list);
		// show_grid(list_crew, grid_crews);

		list_tmp := ret_crews_stringlist(crew_list);
		show_grid(list_tmp, grid_order);
		// show_result_crews_grid(crew_list);

		list_crew := get_order_list(SDAY, crew_list);
		// show_grid(list_crew, grid_crews);

		// !---
		get_show_crews_times(crew_list, res_crew_list);
		show_status('Request of crew times complete.');

		// if crew_list.crewByGpsId(9).is_crew_was_in_coord('30.3088703155518,59.9947509765625') then
		// edit_zakaz4ik.Text := 'ASDFGHJKL!';

		// list_order := get_order_list(SDAY); show_grid(list_order, grid_order);

		// sc1 := get_gps_coords_for_adres('ВИТЕБСКИЙ ПРОСП.', '53', '3');
		// sc2 := get_gps_coords_for_adres('МОСКОВСКИЙ ПРОСП.', '194', '');
		// sc1 := '30.362589,59.848299';
		// sc2 := '30.363829,59.848945';
		// edit_zakaz4ik.Text := sc1 + ' :: ' + sc2;
		// edit_adres.Text := floattostr(get_dist_from_coord(sc1, sc2));
	end;
end;

function open_database() : boolean;
var MyPath, base, user, password : string;
	FIniFile : TIniFile;
begin
	try
		MyPath := ExtractFilePath(Application.ExeName);
		// read configure
		if fileexists(MyPath + 'config.ini') then
		begin
			show_status('reading conf.ini');
			FIniFile := TIniFile.Create(MyPath + 'config.ini');
			try
				base := FIniFile.ReadString('Base', 'Path', '');
				user := FIniFile.ReadString('Base', 'User', '');
				password := FIniFile.ReadString('Base', 'Password', '');
			finally
			end;
		end;
	finally
	end;

	with form_main do
	begin
		with db_main do
		begin
			SQLDialect := 3;
			DatabaseName := base; // 'localhost:D:\fbdb\tme.fdb';
			// DatabaseName := 'localhost:c:\Program Files\TMEnterpriseDemo\tme_demo_db.fdb';
			LoginPrompt := false; { off window-prompt user and passwd }
			Params.Clear; { see dfm.form_main.db_main.Params }
			Params.Add('user_name=' + user);
			Params.Add('password=' + password);
			Params.Add('lc_ctype=WIN1251');
		end;
		try
			db_main.Connected := true; show_status('успешное подключение к БД'); result := true;
		except
			show_status('ошибка при открытии БД');
			result := false;
		end;
	end;
end;

procedure Tform_main.browserDocumentComplete(ASender : TObject; const pDisp : IDispatch;
	var URL : OleVariant);
begin
	show_status('html request completed');
	Complete_Flag := true;
end;

procedure Tform_main.Button1Click(Sender : TObject);
begin
	// form_main.GridPanel_main.RowCollection.Items[0].SizeStyle := ssAbsolute;
	// form_main.GridPanel_main.RowCollection.Items[0].Value := 0;
	// exit();

	show_tmp();
end;

procedure Tform_main.cb_real_baseClick(Sender : TObject);
begin
	DEBUG := not form_main.cb_real_base.Checked;
end;

procedure Tform_main.FormClose(Sender : TObject; var Action : TCloseAction);
begin
	halt(0);
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	ac_taxi_url := 'http://test.robocab.ru/';
	with form_main do
	begin
		cb_real_base.Checked := true; // work with real base, not back-up
		grid_crews.ColWidths[0] := 360; // 120;
		grid_crews.ColWidths[1] := 180;
		grid_crews.ColWidths[2] := 180;
		grid_crews.ColWidths[3] := 280;
		edit_ap_street.Text := 'улица Самойловой';
		edit_ap_house.Text := '7';
		edit_ap_korpus.Text := '';
		edit_ap_gps.Text := '30.375401,59.902930';
	end;
	// form_main.DBGrid1.Hide();

	crew_list := TCrewList.Create(form_main.ibquery_main);
	res_crew_list := TCrewList.Create(form_main.ibquery_main);

	form_main.panel_ap.Show();

	if open_database() then
	begin
		// show_tmp();
	end;
	form_main.Resizing(wsMaximized);
end;

end.
