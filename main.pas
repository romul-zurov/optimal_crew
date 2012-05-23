unit main;

interface

uses
	crew, form_crew, form_order, form_debug, crew_utils, crew_globals, //
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, DB, IBDatabase, DBGrids, ComCtrls, IBCustomDataSet,
	StrUtils, DateUtils, IBQuery, OleCtrls, SHDocVw, MSHTML, ActiveX, IniFiles, WinInet,
	ExtCtrls, ActnList;

type
	Tform_main = class(TForm)
		grid_crews : TStringGrid;
		db_main : TIBDatabase;
		stbar_main : TStatusBar;
		ta_main : TIBTransaction;
		ibquery_main : TIBQuery;
		grid_order_current : TStringGrid;
		GridPanel_main : TGridPanel;
		panel_ap : TPanel;
		Button1 : TButton;
		cb_real_base : TCheckBox;
		GridPanel_grids : TGridPanel;
		GroupBox_order : TGroupBox;
		GroupBox_crew : TGroupBox;
		button_show_sl : TButton;
		Timer_coords : TTimer;
		Button_show_order : TButton;
		Timer_orders : TTimer;
		PageControl_orders : TPageControl;
		TabSheet_current : TTabSheet;
		TabSheet_prior : TTabSheet;
		grid_order_prior : TStringGrid;
		Timer_get_time_order : TTimer;
		cb_show_crews : TCheckBox;
		Panel_browser : TPanel;
		Timer_show_order_grid : TTimer;
		Button_get_time_to_ap : TButton;
		Timer_get_time_order_to_ap : TTimer;
		Button_get_time_to_end : TButton;
		procedure FormCreate(Sender : TObject);
		procedure Button1Click(Sender : TObject);
		procedure browserDocumentComplete(ASender : TObject; const pDisp : IDispatch; var URL : OleVariant);
		procedure cb_real_baseClick(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
		procedure grid_order_currentDblClick(Sender : TObject);
		procedure button_show_slClick(Sender : TObject);
		procedure grid_crewsDblClick(Sender : TObject);
		procedure Timer_coordsTimer(Sender : TObject);
		procedure Button_show_orderClick(Sender : TObject);
		procedure Timer_ordersTimer(Sender : TObject);
		procedure Timer_get_time_orderTimer(Sender : TObject);
		procedure cb_show_crewsClick(Sender : TObject);
		procedure grid_order_priorDblClick(Sender : TObject);
		procedure Timer_show_order_gridTimer(Sender : TObject);
		procedure Button_get_time_to_apClick(Sender : TObject);
		procedure Timer_get_time_order_to_apTimer(Sender : TObject);
		procedure Button_get_time_to_endClick(Sender : TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

function open_database() : boolean;
function reconnect_db() : boolean;

var
	form_main : Tform_main;
	form_debug : TFormDebug;
	crew_list, res_crew_list, tmp_clist : TCrewList;
	order_list : TOrderList;
	Complete_Flag : boolean;
	flag_order_get_time : boolean;
	index_current_order : integer;
	deb_list : TSTringList;
	// SDAY : string;
	// SCOORDTIME : string;
	// order_crew : TOrderCrews;

	form_cur_crew : TFormCrew;
	form_cur_order : TFormOrder;

implementation

{$R *.dfm}
// procedure show_status(status : string);
// begin
// form_main.stbar_main.Panels[0].Text := status;
// end;

function reconnect_db() : boolean;
begin
	try
		form_main.db_main.Connected := false;
		result := open_database();
		exit(result);
	except
		exit(false);
	end;
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
	j, l, id : integer;
	// s, s2, d : string;
	b : TBytes;
	pint : ^integer;
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
	j : integer;
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

function get_track_time(surl : string) : integer;
begin
	with form_main do
	begin
	end;
	result := 0;
end;

procedure show_orders(var list : TOrderList; var grid_order : TStringGrid; prior_flag : boolean);
var pp : Pointer;
	row, ord_id, cur_col, cur_row : integer;
	order : TOrder;
	sord_id : string;
begin
	with form_main do
	begin
		with grid_order do
		begin
			// Width := 1280 - 10;     //  - define as alClient
			// !!!
			// RowCount := 2;
			FixedRows := 1;
			ColCount := 8;
			ColWidths[0] := 50;
			ColWidths[1] := 100;
			ColWidths[2] := 100;
			ColWidths[3] := 250; // 80;
			ColWidths[4] := 120; // 80;
			ColWidths[5] := 120;
			ColWidths[6] := 250; // (Width - ColWidths[0] - ColWidths[1] - ColWidths[2] - ColWidths[3] - 20) div 2;
			ColWidths[7] := ColWidths[6];
			// ColWidths[1] := Width - 24 - ColWidths[0] - ColWidths[2] //
			// - ColWidths[3] - ColWidths[4] - ColWidths[5];

			Cells[0, 0] := '№';
			Cells[1, 0] := 'До подачи';
			Cells[2, 0] := 'До окончания';
			Cells[3, 0] := 'Экипаж';
			Cells[4, 0] := 'Время подачи';
			Cells[5, 0] := 'Состояние';
			Cells[6, 0] := 'Адрес подачи';
			Cells[7, 0] := 'Адрес назначения';
		end;

		// запоминаем, где был "курсор"
		ord_id := -1;
		cur_col := grid_order.Col; // !!
		if grid_order.Cells[0, grid_order.row] = '' then
		else
			ord_id := StrToInt(grid_order.Cells[0, grid_order.row]);

		// отображаем экипажи из списка
		grid_order.RowCount := 2;
		grid_order.Rows[1].Clear();
		row := 1;
		for pp in list.Orders do
		begin
			order := list.order(pp);
			if ( //
				prior_flag //
					and (order.source_time < replace_time('{Last_hour_-1}', now())) //
				) //
				or //
				( //
				not prior_flag //
					and (order.source_time >= replace_time('{Last_hour_-1}', now())) //
				) //
				then
				continue;


			// sord_id := IntToStr(order.id);
			// row := grid_order.Cols[0].IndexOf(sord_id);
			// if row > -1 then
			// begin
			// // если заказ уже есть в сетке то row - уже определена
			// show_status('заказ № ' + sord_id + ' найден')
			// end
			// else
			// begin
			// row := grid_order.RowCount;
			// if (row = 2) and (length(grid_order.Cells[0, 1]) = 0) then
			// // если в сетке ещё нет заказов
			// // то пишем со строки 1
			// row := 1
			// else
			// // иначе добавляем пустую строку в сетку и пишем в неё
			// with grid_order do
			// RowCount := RowCount + 1;
			// end;

			grid_order.Cells[0, row] := IntToStr(order.id);

			grid_order.Cells[1, row] := order.time_to_ap_as_string();

			grid_order.Cells[2, row] := order.time_to_end_as_string();
			if crew_list.crew(order.CrewId) <> nil then
				grid_order.Cells[3, row] := IntToStr(order.CrewId) + ' | ' + crew_list.crew(order.CrewId).name
			else
				grid_order.Cells[3, row] := IntToStr(order.CrewId);
			grid_order.Cells[4, row] := order.source_time;
			grid_order.Cells[5, row] := order.state_as_string();
			grid_order.Cells[6, row] := order.source.get_as_string();
			grid_order.Cells[7, row] := order.dest.get_as_string();

			row := row + 1;
			with grid_order do
				RowCount := RowCount + 1;
		end;
		// убираем пустую строку в конце
		with grid_order do
			if RowCount > 2 then
				RowCount := RowCount - 1;

		// вертаем взад "курсор" сетки
		row := grid_order.Cols[0].IndexOf(IntToStr(ord_id));
		if row < 0 then
			row := 1;
		grid_order.row := row;
		grid_order.Col := cur_col;

		// теперь удаляем заказы из сетки, коих нет в списке
		// remove all grid lines, which not in order_list :)
		// for row := grid_order.RowCount - 1 downto 1 do
		// begin
		// sord_id := grid_order.Cells[0, row];
		// if sord_id = '' then
		// continue;
		// try
		// ord_id := StrToInt(sord_id);
		// finally
		// end;
		// if order_list.is_defined(ord_id) then
		// pass
		// else
		// // если такого заказа уже нет в списке, удаляем его из сетки
		// show_status('Устаревший заказ № ' + IntToStr(ord_id) + ' убран из списка видимых.');
		// del_grid_row(grid_order, row);
		// end;
	end;
end;

procedure show_orders_grid();
begin
	show_orders(order_list, form_main.grid_order_current, false);
	show_orders(order_list, form_main.grid_order_prior, true);
end;

procedure show_result_crews_grid(var list : TCrewList);
var pp : Pointer;
	r : integer;
	crew : TCrew;
begin
	with form_main do
	begin
		with grid_crews do
		begin
			Width := form_main.GroupBox_crew.Width - 10;
			ColCount := 3; // 5;
			ColWidths[0] := 30; // 300;
			ColWidths[1] := 120; // 60;
			ColWidths[2] := 90;
			// ColWidths[3] := 60;
			// ColWidths[4] := 60; // 120;
		end;

		grid_crews.RowCount := 0;
		grid_crews.Rows[0].Clear();
		r := 0;
		for pp in list.Crews do
		begin
			crew := list.crew(pp);
			// if crew.Time < 0 then
			// Continue;

			grid_crews.RowCount := r + 1;
			grid_crews.Cells[0, r] := IntToStr(crew.CrewId); // + ' | ' + crew.name;
			// grid_crews.Cells[0, r] := IntToStr(crew.CrewId);
			// grid_crews.Cells[1, r] := IntToStr(crew.Time);
			grid_crews.Cells[1, r] := crew.Coord;
			grid_crews.Cells[2, r] := crew.state_as_string();
			// grid_crews.Cells[3, r] := FloatToStrF(crew.dist / 1000.0, ffFixed, 8, 3);
			// grid_crews.Cells[4, r] := crew.time_as_string;
			inc(r);
		end;
	end;
	// show_status(list.meausure_time);
end;

procedure show_grid(var list : TSTringList; var grid : TStringGrid);
begin
	grid.ColCount := 1; grid.RowCount := list.Count; grid.ColWidths[0] := grid.Width;
	grid.Cols[0].Assign(list);
end;

procedure set_bd_times();
begin
	// SDAY := '2011-10-03 00:00:00'; // for back-up base

	// SCOORDTIME := '2011-10-03 14:57:50'; // for back-up base

	if form_main.cb_real_base.Checked then
	begin
		cur_time := now();
		// SCOORDTIME := replace_time(COORDS_BUF_SIZE, cur_time); // for real database
		// SDAY := replace_time('{Last_hour_4}', cur_time); // for real database
	end;
end;

procedure crews_request();
begin
	crew_list.get_crews_coords();
	crew_list.Crews.Sort(sort_crews_by_crewid);
	show_result_crews_grid(crew_list);
	if form_cur_crew.Showing then
		form_cur_crew.show_crew();
end;

procedure orders_request();
begin
	deb_list := order_list.get_current_orders();
	crew_list.get_crew_list_by_order_list(order_list);

	// координаты экипажей берутся по таймеру
	// crew_list.get_crews_coords();
	// crew_list.Crews.Sort(sort_crews_by_crewid);

	// Show orders:
	form_debug.show_orders(deb_list); // for info

	// отображение сетки - по таймеру Timer_show_order_grid
	// show_orders_grid(); - не нужно, сетка обновляется по таймеру
	// show_result_crews_grid(crew_list); // - не нужно, сетка обновляется по таймеру
end;

procedure show_tmp();
var list_coord, list_crew, list_order, list_tmp : TSTringList;
	surl, sc1, sc2, ap_coord : string;
	i, t : integer;
	pp, po : Pointer;
	order : TOrder;
	crew : TCrew;
begin
	cur_time := now();
	with form_main do
	begin
		grid_crews.RowCount := 0; // clear grid
		list_order := order_list.get_current_orders();
		form_debug.show_orders(list_order);
		crew_list.get_crew_list_by_order_list(order_list);
		crew_list.get_crews_coords();
		// if crew_list.get_crew_list() = nil then
		// edit_zakaz4ik.Text := 'Nil!';
		crew_list.Crews.Sort(sort_crews_by_crewid);

		// Show orders:
		// отображение сетки - по таймеру Timer_show_order_grid
		// show_orders_grid();
		show_result_crews_grid(crew_list);

		exit(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	end;
end;

procedure show_order_time(var grid_order : TStringGrid);
var order : TOrder;
	ordId : integer;
	pp, pc : Pointer;
begin
	if grid_order.Cells[0, grid_order.row] = '' then
		exit();
	try
		ordId := StrToInt(grid_order.Cells[0, grid_order.row]);
	except
		exit();
	end;
	order := order_list.order(order_list.find_by_Id(ordId));
	if order = nil then
		exit();
	if order.CrewId <> -1 then
	begin
		pc := crew_list.findByCrewId(order.CrewId);
		// order.get_time_to_end(pc);
		// отображение сетки - по таймеру Timer_show_order_grid
		// show_orders_grid();
		exit();
	end;
end;

procedure get_show_order_time_to_ap();
var order : TOrder;
	crew : TCrew;
	pc : Pointer;
	pp : Pointer;
begin
	if order_list.Orders.Count = 0 then
		exit();

	for pp in order_list.Orders do
	begin
		order := order_list.order(pp);
		if order <> nil then
		begin
			if order.CrewId > -1 then
			begin
				if order.is_not_prior() then //
				begin
					pc := crew_list.findByCrewId(order.CrewId);
					crew := crew_list.crew(pc);
					if order.State = ORDER_VODITEL_PODTVERDIL then
					begin
						// считаем время до прибытия
						show_status('Расчёт времени подачи заказа № ' + IntToStr(order.id));
						order.def_time_to_ap(pc);
						// order.get_time_to_ap(pc);
						// show_orders_grid();
					end;
				end;
			end;
		end;
	end;
end;

procedure get_show_order_time_to_end();
var order : TOrder;
	crew : TCrew;
	pc, pp : Pointer;
begin
	if order_list.Orders.Count = 0 then
		exit();

	if not(index_current_order in [0 .. order_list.Orders.Count - 1]) then
		index_current_order := 0;

	flag_order_get_time := true; // блокируем таймер вп-ду :)
	while index_current_order < order_list.Orders.Count do
	begin
		order := order_list.order(order_list.Orders.Items[index_current_order]);
		if order <> nil then
		begin
			if order.is_not_prior() then
			begin
				if order.CrewId > -1 then
				begin
					// считаем ...
					show_status('Расчёт окончания заказа № ' + IntToStr(order.id));
					pc := crew_list.findByCrewId(order.CrewId);
					// crew := crew_list.crew(pc);

					// if order.State = ORDER_VODITEL_PODTVERDIL then
					order.def_time_to_ap(pc);

					order.def_time_to_end(pc);
					// и выходим
					inc(index_current_order);
					flag_order_get_time := false;
					exit();
				end
				else
				begin
					// если экипаж не назначен
					// запрашиваем gps-координату АП - пригодится при подборе :)
					if (order.State = ORDER_PRINYAT) //
						and (order.source.gps = '') //
						then
						order.source.get_gps();
				end;
			end;
		end;
		// если заказ не удовл., переходим к следующему
		inc(index_current_order);
	end;
	// список кончился, выходим, вход по таймеру будет
	flag_order_get_time := false;
end;

procedure get_show_order_time();
var order : TOrder;
	crew : TCrew;
	pc : Pointer;
begin
	if order_list.Orders.Count = 0 then
		exit();

	flag_order_get_time := true; // блокируем таймер вп-ду :)
	if not(index_current_order in [0 .. order_list.Orders.Count - 1]) then
		index_current_order := 0;

	while true do
	begin
		order := order_list.order(order_list.Orders.Items[index_current_order]);
		if order <> nil then
		begin
			show_status('Расчёт заказа № ' + IntToStr(order.id));
			if order.CrewId > -1 then
			begin
				if order.is_not_prior() then //
				begin
					pc := crew_list.findByCrewId(order.CrewId);
					crew := crew_list.crew(pc);
					if order.State = ORDER_VODITEL_PODTVERDIL then
					begin
						// считаем время до прибытия
						// order.get_time_to_ap(pc);
						// отображение сетки - по таймеру Timer_show_order_grid
						// show_orders_grid();
					end
					else
						order.time_to_ap := -1;

					if (order.time_to_end = -1) // ещё не считалось,
						or (order.time_to_end = ORDER_CREW_NO_COORD) // не было координат,
						or (order.time_to_end = ORDER_BAD_ADRES) // не было координат адреса
						or (order.time_to_end = ORDER_WAY_ERROR) // была ошибка расчёта
						or ( //
						(order.time_to_end > 0) //
							and //
							crew.is_moved() // или имело место перемещение экипажа
						) //
						then
					begin
						// if order.get_time_to_end(pc) >= 0 then
						// // при удачном просчёте сбрасываем "старую координату"
						// crew.reset_old_coord();

						// отображение сетки - по таймеру Timer_show_order_grid
						// show_orders_grid();

						// выходим
						inc(index_current_order);
						flag_order_get_time := false;
						exit();
					end;
				end;
			end;
		end;
		// переходим к след. заказу
		inc(index_current_order);
		if index_current_order >= order_list.Orders.Count then
		begin
			flag_order_get_time := false;
			exit();
		end;
	end;
end;

procedure show_order(var grid : TStringGrid);
var order : TOrder;
	sid : string;
	ordId : integer;
	pp : Pointer;
	crew : TCrew;
	slist : TSTringList;
	clist : TCrewList;

begin
	// sid := form_main.grid_order_current.Cells[0, form_main.grid_order_current.row];
	sid := grid.Cells[0, grid.row];
	if sid = '' then
		exit();

	try
		ordId := StrToInt(sid);
	except
		exit();
	end;

	pp := order_list.find_by_Id(ordId);
	if pp = nil then
		exit();

	with form_cur_order do
	begin
		POrderList := Pointer(order_list);
		PCrewList := Pointer(crew_list);
		show_order(pp);
	end;
	exit();

	// order := order_list.order(order_list.find_by_Id(ordId));
	// if order = nil then
	// exit();
	//
	// if order.CrewId <> -1 then
	// begin
	// crew := TCrew(crew_list.findByCrewId(order.CrewId));
	// order.time_to_end := crew.get_time(order_list, false);
	// show_orders_grid(order_list);
	//
	// exit();
	// end;

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
				ac_taxi_url := FIniFile.ReadString('Url', 'Main_Url', '');
				PHP_Url := FIniFile.ReadString('Url', 'PHP_Url', '');
				form_main.Timer_coords.Interval := StrToInt(FIniFile.ReadString('Const', 'Timer_Coords', ''));
				form_main.Timer_orders.Interval := StrToInt(FIniFile.ReadString('Const', 'Timer_Orders', ''));
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
	// form_cur_crew.Close();
	// show_tmp();
	self.Timer_ordersTimer(Sender);
end;

procedure Tform_main.Button_get_time_to_apClick(Sender : TObject);
begin
	// get_show_order_time_to_ap();
	self.Timer_get_time_order_to_apTimer(Sender);
end;

procedure Tform_main.Button_get_time_to_endClick(Sender : TObject);
begin
	self.Timer_get_time_orderTimer(Sender);
end;

procedure Tform_main.Button_show_orderClick(Sender : TObject);
begin
	// show_order();
end;

procedure Tform_main.button_show_slClick(Sender : TObject);
begin
	if form_debug.Showing then
		form_debug.Hide()
	else
		form_debug.Show();
end;

procedure Tform_main.cb_real_baseClick(Sender : TObject);
begin
	DEBUG := not form_main.cb_real_base.Checked;
end;

procedure Tform_main.cb_show_crewsClick(Sender : TObject);
var w : integer;
begin
	if self.cb_show_crews.Checked then
		w := 250
	else
		w := 0;
	self.GridPanel_grids.ColumnCollection.Items[1].value := w;
end;

procedure Tform_main.FormClose(Sender : TObject; var Action : TCloseAction);
begin
	FreeAndNil(order_list);
	FreeAndNil(crew_list);
	halt(0);
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	browser_panel := TPanel(Pointer(self.Panel_browser));
	self.GridPanel_grids.ColumnCollection.Items[1].value := 0;
	flag_order_get_time := false;
	index_current_order := 0;
	// browser_form := TForm.Create(nil);
	// with browser_form do
	// begin
	// Width := 0;
	// height := 0;
	// left := 0;
	// top := 600;
	// Show();
	// end;
	// browser_form.Hide;

	DEBUG_SDATE_FROM := '2011-10-03 00:00:00'; // for backup database
	DEBUG_SDATE_TO := '2011-10-04 00:00:00'; // for backup database

	with form_main do
	begin
		cb_real_base.Checked := true; // work with real base, not back-up
		grid_crews.ColWidths[0] := 360; // 120;
		grid_crews.ColWidths[1] := 180;
		grid_crews.ColWidths[2] := 180;
		grid_crews.ColWidths[3] := 280;
	end;
	// form_main.DBGrid1.Hide();

	sql_string_list := TSTringList.Create();
	form_cur_crew := TFormCrew.Create(nil);
	form_cur_order := TFormOrder.Create(self);
	form_main.grid_order_current.RowCount := 2;
	form_main.grid_order_prior.RowCount := 2;
	PGlobalStatusBar := Pointer(form_main.stbar_main);
	crew_list := TCrewList.Create(form_main.ibquery_main);
	form_cur_order.PCrewList := Pointer(crew_list);
	form_cur_order.POrderList := Pointer(order_list);
	order_list := TOrderList.Create(ibquery_main);
	// crews_count := 0;

	form_main.panel_ap.Show();

	form_debug := TFormDebug.Create(nil);
	form_main.Resizing(wsMaximized);
	if open_database() then
	begin
		// show_tmp();
		create_order_and_crew_states(ibquery_main);
		self.Timer_ordersTimer(Sender); // читаем заказы
		self.Timer_coordsTimer(Sender); // читаем координаты экипажефф
		// first_request(); - не нужно, всё  и так сработает по таймерам

		// активируем таймеры:
		form_main.Timer_orders.Enabled := true;
		form_main.Timer_coords.Enabled := true;
		form_main.Timer_get_time_order.Enabled := true;
		form_main.Timer_show_order_grid.Enabled := true;
		form_main.Timer_get_time_order_to_ap.Enabled := true;
	end;

	// прячем список экипажей
	// form_main.GridPanel_grids.ColumnCollection.Items[1].Value := 0;
	// show_orders_grid(order_list);
end;

procedure Tform_main.grid_crewsDblClick(Sender : TObject);
var pp : Pointer;
	id, r : integer;
	sid : string;
begin
	r := self.grid_crews.row;
	sid := self.grid_crews.Cells[0, r];
	// sid := get_substr(sid, '', ' |');
	id := StrToInt(sid);
	pp := crew_list.findByCrewId(id);
	form_cur_crew.show_crew(pp);
end;

procedure Tform_main.grid_order_currentDblClick(Sender : TObject);
begin
	// show_order_time(grid_order_current);
	show_order(grid_order_current);
end;

procedure Tform_main.grid_order_priorDblClick(Sender : TObject);
begin
	show_order(grid_order_prior);
end;

procedure Tform_main.Timer_coordsTimer(Sender : TObject);
begin
	crews_request();
end;

procedure Tform_main.Timer_get_time_orderTimer(Sender : TObject);
begin
	if flag_order_get_time then // расчёт уже идёт, неча отвлекать
		exit();
	get_show_order_time_to_end();
end;

procedure Tform_main.Timer_get_time_order_to_apTimer(Sender : TObject);
begin
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// get_show_order_time_to_ap();
end;

procedure Tform_main.Timer_ordersTimer(Sender : TObject);
begin
	orders_request();
end;

procedure Tform_main.Timer_show_order_gridTimer(Sender : TObject);
begin
	show_orders_grid();
end;

end.
