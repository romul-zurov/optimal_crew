unit main;

interface

uses
	crew, form_crew, form_order, form_debug, crew_utils, crew_globals, //
	thread_get_times, //
	ExtCtrls, DB, IBCustomDataSet, IBQuery, IBDatabase,
	ComCtrls, Grids, StdCtrls, Classes, Controls,
	Windows, Messages, SysUtils, Variants, Graphics, Forms,
	Dialogs, DBGrids,
	StrUtils, DateUtils, OleCtrls, SHDocVw, MSHTML, ActiveX, IniFiles, WinInet,
	ActnList, Math;

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
		Button_get_time_to_end : TButton;
		ibquery_coords : TIBQuery;
		ta_coords : TIBTransaction;
		cb_timers_times : TCheckBox;
		cb_timers_orders_coords : TCheckBox;
		cb_show_times_to_end : TCheckBox;
		cb_show_orders_id : TCheckBox;
		Timer_main : TTimer;
		Timer_pass : TTimer;
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
		procedure Button_get_time_to_endClick(Sender : TObject);
		procedure cb_timers_timesClick(Sender : TObject);
		procedure cb_timers_orders_coordsClick(Sender : TObject);
		procedure Button_orders_coordsClick(Sender : TObject);
		procedure grid_order_currentDrawCell(Sender : TObject; ACol, ARow : Integer; Rect : TRect;
			State : TGridDrawState);
		procedure Timer_mainTimer(Sender : TObject);
		procedure Timer_passTimer(Sender : TObject);
	private
		{ Private declarations }
		flag_get_coords : boolean;
		flag_get_orders : boolean;
		flag_show_orders : boolean;
		flag_req_or_show : boolean;
		deb_list : TSTringList;
		Interval : int64;
		ord_req_count, coo_req_count : int64;

		procedure show_request(txt : string);
		procedure show_counts();
		procedure show_OrderID(id : Integer);
	public
		{ Public declarations }
		flag_order_get_time_process : boolean;
		thread_times : TThread_get_times;
		interval_coords_req, interval_orders_req : Cardinal;

		procedure show_orders_grid();
		procedure show_orders(var list : TOrderList; var grid_order : TStringGrid; prior_flag : boolean);
		procedure show_result_crews_grid(var list : TCrewList);
		procedure crews_request();
		procedure orders_request();
		function open_database() : boolean;
		procedure get_orders_times();
	end;

	// function reconnect_db() : boolean;

var
	form_main : Tform_main;
	form_debug : TFormDebug;
	crew_list, res_crew_list, tmp_clist : TCrewList;
	order_list : TOrderList;
	Complete_Flag : boolean;
	flag_coords_request : boolean;
	index_current_order : Integer;

	// SDAY : string;
	// SCOORDTIME : string;
	// order_crew : TOrderCrews;

	form_cur_crew : TFormCrew;
	form_cur_order : TFormOrder;

implementation

{$R *.dfm}

procedure Tform_main.show_request(txt : string);
begin
	exit(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	self.stbar_main.Panels[2].Text := txt;
end;

procedure Tform_main.show_result_crews_grid(var list : TCrewList);
var pp : Pointer;
	r : Integer;
	crew : TCrew;
begin
	with form_main do
	begin
		with grid_crews do
		begin
			Width := form_main.GroupBox_crew.Width - 10;
			ColCount := 3; // 4; // 5;
			ColWidths[0] := 30; // 300;
			ColWidths[1] := 240; // 60;
			ColWidths[2] := 90;
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
			// grid_crews.Cells[1, r] := crew.Coord;
			if crew.coords_full.Count > 0 then
				grid_crews.Cells[1, r] := crew.coords_full[crew.coords_full.Count - 1]
			else
				grid_crews.Cells[1, r] := '';
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
	grid.ColCount := 1;
	grid.RowCount := list.Count;
	grid.ColWidths[0] := grid.Width;
	grid.Cols[0].Assign(list);
end;

procedure Tform_main.crews_request();
begin
	inc(self.coo_req_count);
	flag_coords_request := true; // ��������� ������ � �-���� :))
	crew_list.get_crews_coords();
	crew_list.Crews.Sort(sort_crews_by_crewid);
	self.show_result_crews_grid(crew_list);
	if form_cur_crew.Showing then
		form_cur_crew.show_crew();
	flag_coords_request := false; // ����������� ������ :)
end;

procedure Tform_main.orders_request();
begin
	inc(self.ord_req_count);

	// order_list.get_current_orders(deb_list);
	order_list.get_current_orders_with_data();
	crew_list.get_crew_list_by_order_list(order_list);
end;

procedure Tform_main.get_orders_times();
var order : TOrder;
	pc, pp : Pointer;
label quit;
begin
	if self.flag_order_get_time_process or (order_list.Orders.Count = 0) then
		exit();

	if not(index_current_order in [0 .. order_list.Orders.Count - 1]) then
		index_current_order := 0;

	self.flag_order_get_time_process := true; // ��������� ������ ��-�� :)
	while index_current_order < order_list.Orders.Count do
	begin
		try
			order := TOrder(order_list.Orders.Items[index_current_order]);
		except
			order := nil;
		end;
		if order <> nil then
		begin
			if not order.destroy_flag then
			begin
				if order.is_not_prior() then
				begin
					self.show_OrderID(order.id);
					if order.CrewId > -1 then
					begin
						// ������� ...
						pc := crew_list.findByCrewId(order.CrewId);
						// if order.State = ORDER_VODITEL_PODTVERDIL then
						order.def_time_to_ap(pc);
						order.def_time_to_end(pc);
					end
					else
					begin
						// ���� ������ �� ��������
						// ����������� gps-���������� �� - ���������� ��� ������� :)
						if //
						// (order.State = ORDER_PRINYAT) and //
							(order.source.gps = '') //
							then
							order.source.get_gps();
					end;
					// � �������
					goto quit;
				end;
			end;
		end;
		// ���� ����� �� �����., ��������� � ����������
		inc(index_current_order);
	end;

quit :
	inc(index_current_order);
	self.flag_order_get_time_process := false;
end;

procedure show_order(var grid : TStringGrid);
var order : TOrder;
	sid : string;
	ordId : Integer;
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
end;

function Tform_main.open_database() : boolean;
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
				self.interval_coords_req := StrToInt(FIniFile.ReadString('Const', 'Timer_Coords', ''));
				form_main.Timer_coords.Interval := self.interval_coords_req;
				self.interval_orders_req := StrToInt(FIniFile.ReadString('Const', 'Timer_Orders', ''));
				form_main.Timer_orders.Interval := self.interval_orders_req;
			finally
			end;
		end;
	finally
	end;

	with self do
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
			db_main.Connected := true;
			show_status('�������� ����������� � ��');
			result := true;
		except
			show_status('������ ��� �������� ��');
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
	self.Timer_coordsTimer(Sender);
end;

procedure Tform_main.Button_get_time_to_apClick(Sender : TObject);
begin
	// get_show_order_time_to_ap();
	// self.Timer_get_time_order_to_apTimer(Sender);
end;

procedure Tform_main.Button_get_time_to_endClick(Sender : TObject);
begin
	self.Timer_get_time_orderTimer(Sender);
end;

procedure Tform_main.Button_orders_coordsClick(Sender : TObject);
begin
	self.Timer_coordsTimer(Sender);
	self.Timer_ordersTimer(Sender);
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
var w : Integer;
begin
	if self.cb_show_crews.Checked then
		w := 400
	else
		w := 0;
	self.GridPanel_grids.ColumnCollection.Items[1].value := w;
end;

procedure Tform_main.cb_timers_orders_coordsClick(Sender : TObject);
var flag : boolean;
begin
	flag := self.cb_timers_orders_coords.Checked;
	self.Timer_orders.Enabled := flag;
	self.Timer_coords.Enabled := flag;
end;

procedure Tform_main.cb_timers_timesClick(Sender : TObject);
var flag : boolean;
begin
	flag := self.cb_timers_times.Checked;
	self.Timer_get_time_order.Enabled := flag;
end;

procedure Tform_main.FormClose(Sender : TObject; var Action : TCloseAction);
begin
	self.thread_times.Terminate();
	FreeAndNil(order_list);
	FreeAndNil(crew_list);
	FreeAndNil(self.deb_list);
	halt(0);
end;

procedure first_request();
begin
	form_main.orders_request();
	form_main.crews_request();
	form_main.show_orders_grid();
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	browser_panel := TPanel(Pointer(self.Panel_browser));
	self.GridPanel_grids.ColumnCollection.Items[1].value := 0;
	self.flag_get_coords := false;
	self.flag_get_orders := false;
	self.flag_show_orders := false;
	self.flag_req_or_show := false;
	self.deb_list := TSTringList.Create();
	self.flag_order_get_time_process := false;
	flag_coords_request := false;
	index_current_order := 0;
	GetZaprosCounter := 0;

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

	sql_string_list := TSTringList.Create();
	form_cur_crew := TFormCrew.Create(nil);
	form_cur_order := TFormOrder.Create(self);
	form_main.grid_order_current.RowCount := 2;
	form_main.grid_order_prior.RowCount := 2;
	PGlobalStatusBar := Pointer(form_main.stbar_main);

	order_list := TOrderList.Create(self.ibquery_main);
	crew_list := TCrewList.Create(self.ibquery_coords);
	PMainCrewList := Pointer(crew_list);
	form_cur_order.PCrewList := Pointer(crew_list);
	form_cur_order.POrderList := Pointer(order_list);

	form_main.panel_ap.Show();

	form_debug := TFormDebug.Create(nil);
	form_main.Resizing(wsMaximized);
	if open_database() then
	begin
		// show_tmp();
		create_order_and_crew_states(ibquery_main);
		// self.Timer_ordersTimer(Sender); // ������ ������
		// self.Timer_coordsTimer(Sender); // ������ ���������� ���������
		first_request(); // ������ ������

		// ���������� �������:
		// form_main.Timer_orders.Enabled := true;
		// form_main.Timer_coords.Enabled := true;
		// form_main.Timer_get_time_order.Enabled := true;
		self.Timer_show_order_grid.Enabled := true;
		self.Timer_main.Enabled := true; //

		CoInitialize(nil);
		self.thread_times := TThread_get_times.Create(true);
		self.thread_times.Priority := tpLowest;
		self.thread_times.init();
		self.thread_times.Start();
	end;

	// ������ ������ ��������
	// form_main.GridPanel_grids.ColumnCollection.Items[1].Value := 0;
	// show_orders_grid(order_list);
end;

procedure Tform_main.grid_crewsDblClick(Sender : TObject);
var pp : Pointer;
	id, r : Integer;
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

procedure Tform_main.grid_order_currentDrawCell(Sender : TObject; ACol, ARow : Integer; Rect : TRect;
	State : TGridDrawState);
var sub : string;
begin
	if (ACol in [1, 2, 4, 5, 6]) and (ARow > 0) then // ������ ��� ������� �������/�������
		with TStringGrid(Sender) do
		begin
			if Cells[ACol, ARow] = '' then
				exit();
			sub := '';
			if pos('!!!', Cells[ACol, ARow]) = 1 then
			begin
				Canvas.Brush.color := clRed;
				sub := '!!!';
			end
			else
				if pos('!', Cells[ACol, ARow]) = 1 then
				begin
					Canvas.Brush.color := clYellow;
					sub := '!';
				end
				else
					if pos('#', Cells[ACol, ARow]) = 1 then
					begin
						Canvas.Brush.color := $CCCCCC; // clGray;
						sub := '#';
					end
					else
						if pos('%', Cells[ACol, ARow]) = 1 then
						begin
							Canvas.Brush.color := $6D6D6D;
							sub := '%';
						end
						else
							Canvas.Brush.color := ifthen(ACol in [1, 2], $00FF00, $FFFFFF);

			Canvas.FillRect(Rect);
			Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, get_substr(Cells[ACol, ARow], sub, ''));
		end;
end;

procedure Tform_main.grid_order_priorDblClick(Sender : TObject);
begin
	show_order(grid_order_prior);
end;

procedure Tform_main.show_counts;
begin
	self.stbar_main.Panels[2].Text := //
		IntToStr(self.ord_req_count) //
		+ '/' //
		+ IntToStr(self.coo_req_count) //
		;

	self.stbar_main.Panels[3].Text := //
		IntToStr(self.grid_order_current.RowCount - 1) + //
		'/' + IntToStr(self.grid_order_prior.RowCount - 1) + //
		'/' + IntToStr(order_list.Orders.Count) + '*' //
		;
	self.stbar_main.Panels[4].Text := //
		IntToStr(crew_list.free_crews_count()) //
		+ '|' + IntToStr(crew_list.not_free_crews_count()) //
		+ '/' + IntToStr(order_list.orders_time_to_end_count()) //
		;
end;

procedure Tform_main.show_OrderID(id : Integer);
begin
	self.stbar_main.Panels[0].Text := 'Order ' + IntToStr(id);
end;

procedure Tform_main.show_orders(var list : TOrderList; var grid_order : TStringGrid; prior_flag : boolean);
var pp : Pointer;
	row, ord_id, cur_col, cur_row, adr_w : Integer;
	order : TOrder;
	sord_id, prior_stime, s_crew : string;
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
			Cells[0, 0] := '�'; // �� ������������ �� ���������
			Cells[1, 0] := '�������� ������';
			Cells[2, 0] := '�� ���������'; // �� ������������ �� ���������
			Cells[3, 0] := '���������';
			Cells[4, 0] := '������';
			Cells[5, 0] := '����� ������';
			Cells[6, 0] := '����� ����������';
			Cells[7, 0] := '����� ������';

			ColWidths[0] := ifthen(self.cb_show_orders_id.Checked, 50, 0);
			ColWidths[1] := 240; // 160;
			ColWidths[2] := ifthen(self.cb_show_times_to_end.Checked, 300, 0);
			ColWidths[3] := 180; // 260; // 80;
			ColWidths[4] := 260; // 128; // 80;
			ColWidths[7] := 88;

			adr_w := ( //
				Width - ColWidths[0] - ColWidths[1] - ColWidths[2] - ColWidths[3] //
					- ColWidths[4] - ColWidths[7] - 24 //
				) //
				div 2; // 210
			ColWidths[5] := ifthen(adr_w > 192, adr_w, 192);
			ColWidths[6] := ColWidths[5];
		end;

		// ����������, ��� ��� "������"
		ord_id := -1;
		cur_col := grid_order.Col; // !!
		if grid_order.Cells[0, grid_order.row] = '' then
		else
			ord_id := StrToInt(grid_order.Cells[0, grid_order.row]);

		// ���������� ������� �� ������
		grid_order.RowCount := 2;
		grid_order.Rows[1].Clear();
		row := 1;
		prior_stime := replace_time('{Last_hour_-1}', now());
		for pp in list.Orders do
		begin
			order := list.order(pp);

			if //
				order.destroy_flag // ���������� ��� �������� ������
				or //
				(order.id < 0) // "������" ������
				then // �� ����������!
				continue;

			if ( //
				prior_flag //
					and (order.source_time < prior_stime) //
				) //
				or //
				( //
				not prior_flag //
					and (order.source_time >= prior_stime) //
				) //
				then
				continue;

			// �� ������������ �� ���������
			grid_order.Cells[0, row] := IntToStr(order.id);

			grid_order.Cells[1, row] := order.status();

			// �� ������������ �� ���������
			grid_order.Cells[2, row] := order.time_to_end_as_string() //
				+ ' (' + time_without_date(order.datetime_of_time_to_ap) //
				+ '/' + time_without_date(order.datetime_of_time_to_end) + ')';

			grid_order.Cells[3, row] := order.state_as_string() //
			// �������� ������ � ����. �����������
				+ ifthen(order.count_int_stops > 0, '~', '');

			if order.CrewId > 0 then
			begin
				if crew_list.crew(order.CrewId) <> nil then
				begin
					s_crew := crew_list.crew(order.CrewId).name;
					if self.cb_show_crews.Checked then
						s_crew := IntToStr(order.CrewId) + ' | ' + s_crew;
				end
				else
					s_crew := '!!!CREW ERROR';
			end
			else
				s_crew := '!!!';

			grid_order.Cells[4, row] := s_crew;
			grid_order.Cells[5, row] := order.source.get_as_color_string();
			grid_order.Cells[6, row] := order.dest.get_as_color_string();
			grid_order.Cells[7, row] := order.source_time_without_date();

			row := row + 1;
			with grid_order do
				RowCount := RowCount + 1;
		end;
		// ������� ������ ������ � �����
		with grid_order do
			if RowCount > 2 then
				RowCount := RowCount - 1;

		// ������� ���� "������" �����
		row := grid_order.Cols[0].IndexOf(IntToStr(ord_id));
		if row < 0 then
			row := 1;
		grid_order.row := row;
		grid_order.Col := cur_col;
	end;
end;

procedure Tform_main.show_orders_grid;
begin
	self.show_orders(order_list, form_main.grid_order_current, false);
	self.show_orders(order_list, form_main.grid_order_prior, true);
	self.show_counts();
end;

procedure Tform_main.Timer_coordsTimer(Sender : TObject);
var flag, flag_ord : boolean;
begin
	self.Timer_coords.Enabled := false;
	self.flag_get_coords := true;
	exit();

	if flag_coords_request then
		exit();
	flag := self.Timer_coords.Enabled;
	flag_ord := self.Timer_orders.Enabled;
	self.Timer_coords.Enabled := false;
	self.Timer_orders.Enabled := false;

	self.show_request('Coords request...');

	{
	  // �������� ������ ����� � ���������� ��������� :(
	  try
	  db_main.Connected := false;
	  db_main.Connected := true;
	  show_status('�������� ����������� � ��');
	  except
	  show_status('������ ��� �������� ��');
	  end;
	  }

	self.crews_request();
	self.show_request('Coords complete.');

	self.Timer_coords.Enabled := flag;
	self.Timer_orders.Enabled := flag_ord;

end;

procedure Tform_main.Timer_get_time_orderTimer(Sender : TObject);
begin
	exit();
	// ----------------------

	if self.flag_order_get_time_process then // ������ ��� ���, ���� ���������
		exit();
	self.get_orders_times();
end;

procedure Tform_main.Timer_mainTimer(Sender : TObject);
begin
	// exit();
	// ��������� �����, ���� �� ������ ��� ����
	// self.Timer_main.Enabled := false;

	// if flag_order_get_time then // ������ ��� ���, ���� ���������
	// exit();
	self.get_orders_times(); // ��-������ 1 ��� �������

	(*
	  if self.flag_get_coords then
	  begin
	  self.crews_request();
	  self.flag_get_coords := false;
	  // self.Timer_coords.Enabled := true;
	  self.Timer_orders.Enabled := true;
	  end
	  else
	  if self.flag_get_orders then
	  begin
	  self.orders_request();
	  self.flag_get_orders := false;
	  self.Timer_orders.Enabled := true;
	  end;
	  *)

	// self.show_orders_grid();
	(*
	  if self.flag_show_orders then
	  begin
	  self.show_orders_grid();
	  self.flag_show_orders := false;
	  self.Timer_show_order_grid.Enabled := true;
	  end;
	  *)

	// �������� ������
	// self.Timer_main.Enabled := true;
	// self.Timer_pass.Enabled := true; // !!!
end;

procedure Tform_main.Timer_ordersTimer(Sender : TObject);
var flag : boolean;
begin
	exit(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	if self.Interval > self.interval_coords_req then
	begin
		self.Interval := 0;
		self.flag_get_coords := true;
	end
	else
	begin
		self.Interval := self.Interval + self.Timer_orders.Interval;
		self.flag_get_orders := true;
	end;

	if self.flag_get_coords then
	begin
		self.crews_request();
		self.flag_get_coords := false;
	end
	else
		if self.flag_get_orders then
		begin
			if self.flag_req_or_show then
				self.show_orders_grid()
			else
				self.orders_request();
			self.flag_req_or_show := not self.flag_req_or_show;
			self.flag_get_orders := false;
		end;
	// self.show_counts();
	// self.show_orders_grid();

	exit(); // !!!!!!!!!!!!!!

	// ---------------------------------------------------------
	flag := self.Timer_orders.Enabled;
	self.Timer_orders.Enabled := false;
	if self.Interval > self.interval_coords_req then
	begin
		self.Interval := 0;
		self.Timer_coordsTimer(Sender);
	end
	else
	begin
		self.Interval := self.Interval + self.Timer_orders.Interval;
		self.show_request('Orders request...');
		self.orders_request();
		self.show_request('Orders complete.');
	end;
	self.Timer_orders.Enabled := flag;
end;

procedure Tform_main.Timer_passTimer(Sender : TObject);
begin
	exit();

	self.Timer_pass.Enabled := false;
	self.Timer_main.Enabled := true;
end;

procedure Tform_main.Timer_show_order_gridTimer(Sender : TObject);
begin
	self.show_counts();
	self.show_orders_grid();
	exit(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	self.Timer_show_order_grid.Enabled := false;
	self.flag_show_orders := true;
	exit();

	self.show_orders_grid();
end;

end.
