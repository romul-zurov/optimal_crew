unit crew;

interface

uses crew_utils, // utils from robocap and mine
	crew_globals, // my global var and function
	idHTTP,
	Generics.Collections, // for forward class definition
	Controls, Forms, Classes, SysUtils, Math, SHDocVw, MSHTML, ActiveX, //
	IBQuery, DB, WinInet, StrUtils, DateUtils, ExtCtrls, StdCtrls, Grids, //
	Types, Graphics, Dialogs;

function sort_cars_by_app_time(p1, p2 : Pointer) : Integer;
function sort_cars_by_dist(p1, p2 : Pointer) : Integer;
function sort_crews_by_state_dist(p1, p2 : Pointer) : Integer;
function sort_crews_by_time(p1, p2 : Pointer) : Integer;
function sort_crews_by_crewid(p1, p2 : Pointer) : Integer;
function sort_orders_by_source_time(p1, p2 : Pointer) : Integer;

type
	TCrewList = class;

	TCar = class(TObject)
		// ��������������� ����� ��� ������ ������� �� �����
		PCrew : Pointer; // ��������� �� crew:TCrew
		ap : TAdres; // ��, ������, ���� ��� ����
		from : TAdres; // ������ ����
		way_to_ap : TWay; // ������� �� ��
		// dist_to_ap : double; // �� ������ �� ��, ������
		dist_way_to_ap : double; // ����� �������� �� ��, ��;
		raw_dist_way : double; // �������� "�����" ��������, ������������ �� ��� ����, ��
		time_to_ap : Integer; // ����� �������� � �� � �������;
		ap_source_time : TDateTime;
		crew_state : Integer; // ��� ������������ � crew.state ����������
		// ����������, ���� �������� ������� �� ������
		car_coord : string; // ���������� ��� ����������� ������ �������

		constructor Create();
		destructor Destroy(); override;
		procedure Clear();
		procedure def_time_to_ap();
		function ret_data() : string;
		function opozdanie() : Integer;
	private
		procedure def_way_to_ap();
		procedure set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		function is_moved() : boolean;
		function approx_time(flag_po_pryamoy : boolean) : Integer;
		function approximate_time() : Integer;
		function approximate_time_po_pryamoy() : Integer;
		function approximate_dist_way() : double;
		function dist_to_ap() : double; // �� ������ �� ��, ������
		function approximate_opozdaet() : boolean;
	end;

	TOrder = class(TObject)
	private
		opozdun20_flag : boolean;
		robocab_http : TIdHTTP;
		coord_of_crew : string; // ����������, ��� ������� ���������� ������
		new_coord_of_crew : string; // ����� ���������� ��� ���������� �������

		function crew_is_moved() : boolean;
		function crew_is_not_moved() : boolean;
		function get_crew_coord() : string;

		procedure set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		procedure set_time_to_end(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		function time_as_string(time : Integer) : string;
		function get_cars_for_ap() : Integer;
		function add_cars_and_sort() : Integer;
		procedure add_cars_grid_to_panel();
		procedure cars_grid_DrawCell(Sender : TObject; ACol, ARow : Integer; Rect : TRect;
			state : TGridDrawState);
		procedure hide_cars_by_hand(Sender : TObject);
		procedure clear_cars();
		procedure click_send_to_robocab(Sender : TObject; Button : TMouseButton; Shift : TShiftState;
			X, Y : Integer);
		function send_to_robocab() : Integer;
		function is_in_robocab() : boolean;
		function add_to_robocab() : boolean;
		procedure set_car_data(PCar : Pointer);
		function del_car(PCar : Pointer) : Integer;
		procedure clear_crew();

	public
		ID : Integer; // order main ID in ORDERS table, -1 if not defined
		CrewID : Integer; // crew ID for a order, -1 if not defined
		// want_CrewId : Integer; // �������� ������ �� ������ - �� �����!
		prior_CrewId : Integer; // ��������������� ������ �� �������. ������
		// prior : boolean; // ������� ���������������� ������
		state : Integer; // -1 - not defined, 0 - ������, ������� �����
		// .                 1 - � ������, 2 - ��������;
		source : TAdres; // address from
		dest : TAdres; // address to
		customer : string; // ��������
		phone : string; // ���. ���������

		source_time : string; // ����� ������ �������
		time_to_end : Integer; // ����� �� ��������� ������ � �������
		datetime_of_time_to_end : TDateTime; // ������, ����� ��������� �����
		// �� ���������, ����� ��� �������
		time_to_ap : Integer; // ����� �� �������� � ������ ������ � �������
		datetime_of_time_to_ap : TDateTime; // ������, ����� ��������� ����� �� ��
		deleted : boolean; // ������� ��������� ��� ����������� ������
		query : TIBQuery;
		way_to_ap : TWay;
		way_to_end : TWay;
		stops_time : Integer; // ����� �� ��������� ������� �� ������ � �������
		na_bortu : boolean; // �������, ��� ������ �� ����� ��� ���������� ������
		PCrew : Pointer; // ��������� �� ������, ����� � def_time_to_end � set_time_to_end

		count_int_stops : Integer; // ���������� ������������� ��������� � ������
		raw_int_stops : string; // ������ ����. ��������� "��� ����", �� ����
		int_stops : TList; // ������ ����. ��������� � ������� TAdres

		destroy_flag : boolean; // ����, ��� ����� ����� ������� �� ������
		destroy_time : string; // �����, ����� ���������� ���� ��������. �����
		// ����� ����� ����� ORDER_DESTROY_TIME

		raw_price : double; // ���� ��������, ����
		raw_dist_way : double; // �������� "�����" ��������, ������������ �� ��� ����, ��
		dobavka_v_ocheredi : Integer; // ������� ������� ��� ������� ������ "� �������"

		Cars : TList; // ������ �������� ��� ������� ������������ �� �����
		// �������� ������ pointer'� �� Tcar-�
		PCrews_tmp : TList;
		Cars_StringList : TstringList;
		cars_gbox : TGroupBox; // ������ ��� ����������� ������ cars-��
		cars_gbox_visible : boolean; // ����� ������� � ������ �������
		cars_grid : TStringGrid;
		hand_get_cars_flag : boolean; // �������������� ������ ������� ��� ������

		timer_cars : TTimer; // ������ ������� ������� ��� ������
		// ���� enabled - ��� �������  - ���� �� �����

		button_send_to_robocab : TButton;

		property crew_coord : string read get_crew_coord;
		property coordOfCrew : string read coord_of_crew;

		constructor Create(OrderId : Integer; var IBQuery : TIBQuery);
		destructor Destroy(); override;
		procedure del_order(); // ������ ������� ����� ��� �������� �� ������
		procedure def_time_to_end(var PCrew : Pointer);
		procedure def_time_to_ap(var PCrew : Pointer);
		function time_to_end_as_string() : string; // ����� �� ��������� ������ � ���� ����-������;
		function time_to_ap_as_string() : string; // ����� �� �������� � �� � ���/�����;
		function state_as_string() : string;
		function status() : string;
		function source_time_without_date() : string;
		function is_not_prior() : boolean;
		function is_prior() : boolean;
		function is_bad() : boolean;
		function get_cars_times_for_ap() : Integer;
		function crew_in_cars(PCrew : Pointer) : boolean;
		function car_for_crew(PCrew : Pointer) : Pointer;
		procedure refresh_cars_stringlist();
		procedure show_cars();
		function need_get_cars() : boolean;
		function need_show_cars() : boolean;
		procedure hide_button_send_to_robocab();
		function opozdun() : boolean;
		function opozdanie() : Integer;
	end;

	TOrderList = class(TObject)
		Orders : TList;
		query : TIBQuery;

		constructor Create(var IBQuery : TIBQuery);
		destructor Destroy(); override;
		function del_order(ListIndex : Integer) : Integer;
		function clear_order_list() : Integer;
		function order(p : Pointer) : TOrder;
		function find_by_Id(OrderId : Integer) : Pointer;
		function is_defined(OrderId : Integer) : boolean;
		function ret_free_order() : Pointer;
		function Append(OrderId : Integer) : Pointer;
		function get_crews_id_as_string() : string;
		function del_bad_orders() : Integer;
		function get_current_orders_with_data() : Integer;
		function orders_time_to_end_count() : Integer;
		function ret_orders_as_grid(prior_flag : boolean; var slist : TstringList) : Integer;
		procedure set_sort_col(col : Integer);
		function get_sort_col() : Integer;
		procedure hide_buttons_send_to_robocab();

	private
		sort_col : Integer;
		procedure get_adres_coords();
		function orders_id_as_string() : string;
	end;

	TCrew = class(TObject)
		CrewID : Integer;
		GpsId : Integer;
		state : Integer; // ���������: 1 - ��������, 3 - �� ������;
		Code : string;
		name : string;
		coord : string; // ������� (����� ������) ���������� GPS
		// old_coord : string; // ���������� ����������
		dist : double; // ���������� �� ������ ������ (��) ����������, �� ������, ������;
		dist_way : double; // ����� �������� �� ��, ��;

		time : Integer; // ����� �������� � �� � �������;
		// coords : TStringList; // gps-���� �� ��������� ���������� �������;
		// coords_times : TStringList; // gps-���� �� ��������� ���������� �������;
		coords_full : TstringList; // ������� ����: ���������� + �����
		// coord_list : TStringList;
		OrderId : Integer; // ID ������ �������� �������
		order_way : string; // ������� �������� �������

		source : TAdres; // address_from for state==3
		dest : TAdres; // address_to for state==3
		ap : TAdres; // ����� ������ �������
		way_to_ap : TWay;
		cur_pos : TAdres; // ���. ��������� �������
		// points : TList;
		POrder : Pointer; // ��������� �� �����
		POrder_vocheredi : Pointer; // ��������� �� ����� "� �������", ���������. �.�.
		POrder_time_to_ap : Pointer; // ��������� �� �����, � ������� ������
		// ������������� ��� �������. ������������ � set_time() ��� ��������
		// ����������

		constructor Create(GpsId : Integer);
		destructor Destroy(); override;
		function state_as_string() : string;
		function time_as_string() : string; // � ���� ����-������
		function dist_way_as_string() : string;
		function set_current_coord() : Integer;
		function del_old_coords() : Integer;
		function when_was_in_coord(coord : string) : string;
		function was_in_coord(coord : string) : boolean;
		function now_in_coord(coord : string) : boolean;
		// function is_moved() : boolean; // ��������� ����� ��� ��...
		procedure calc_dist(coord : string);
		procedure set_time(m : Integer; d : double); // set time and time_as_string;
		function get_time(var List : TOrderList; newOrder : boolean) : Integer;
		function get_time_for_ap(var o_list : TOrderList; n_ap : TAdres) : Integer;
		procedure show_status(s : string);
		// procedure reset_old_coord();
		function ret_data() : string;
		function ret_data_to_ap(source_time : string; half_dist_way : double) : string;
		// function def_time_to_ap(var polist : Pointer) : Integer;
		function def_time_to_ap() : Integer;
		function pererasxod_color(half_dist_way : double) : string;
		function real_state() : Integer;
		function order_time_to_end() : Integer;
		function last_porder() : Pointer;
		function coord_depend_state() : string; // ���������� ���������� ���� �������,
		// ���� ����� dest of last_order
	private
		rasxod : double;
		function time_to_str(time : Integer) : string;
		function time_str() : string; // � ���� '00000056'
		function dist_way_str() : string; // � ���� '000015.6' ��� ���������� TStringList.sort()
		function dist_str() : string;
		procedure set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		function pererasxod(half_dist_way : double) : Integer; // -1 - not defined, 0 - ��, 1 - ��, 2 - ��
		function line_number_color() : string;
	end;

	TCrewList = class(TObject)
		Crews : TList;
		query : TIBQuery;

		ap_street : string;
		ap_house : string;
		ap_korpus : string;
		ap_gps : string;

		constructor Create(var IBQuery : TIBQuery);
		destructor Destroy(); override;
		function crew(p : Pointer) : TCrew; overload;
		function crew(CrewID : Integer) : TCrew; overload;
		function crewByGpsId(GpsId : Integer) : TCrew;
		function crewByCrewId(CrewID : Integer) : TCrew;
		function Append(GpsId : Integer) : Pointer; // add new crew to list by CREW_GPS_ID
		function isCrewInList(ID : Integer; gps : boolean) : boolean;
		function isCrewIdInList(ID : Integer) : boolean;
		function isGpsIdInList(ID : Integer) : boolean;
		function findByCrewId(ID : Integer) : Pointer;
		function findByGpsId(ID : Integer) : Pointer;

		function get_gpsid_list_as_string() : string;
		function get_crewid_list_as_string() : string;
		function get_nonfree_crewid_list_as_string() : string;
		function del_all_none_crewId() : Integer;
		function set_crewId_by_gpsId(var List : TstringList) : Integer;
		function set_crews_state_by_crewId(var List : TstringList) : Integer;
		function set_current_crews_coord() : Integer;
		function set_crews_dist(coord : string) : Integer;
		function set_ap(street, house, korpus, gps : string) : Integer;
		function set_crews_data() : Integer;
		function clear_crew_list() : Integer;
		function get_crew_list_by_crewid_string(screws_id : string) : Integer;
		function get_crew_list_by_order_list(var List : TOrderList) : Integer;
		function get_crew_list_for_ap(new_ap : TAdres; Order_ID : Integer; var res_slist : TstringList)
			: Integer;

		// �� ������������, ��. TCrewList.get_pcrews_for_porder !!!!!!!!!!!!!!!!!!!!!!!!!!!!
		function get_pcrews_for_ap(new_ap : TAdres; var res_pcrews : TList) : Integer;

		function get_pcrews_for_porder(a_porder : Pointer; var res_pcrews : TList) : Integer;

		function get_crew_list() : Integer;
		function get_crews_coords() : Integer;
		function ret_crews_stringlist() : TstringList;
		function free_crews_count() : Integer;
		function not_free_crews_count() : Integer;
	private
		sql_crews_stringlist : TstringList;
		tmp_slist : TstringList;
		coords_last_id : int64;
		function findById(ID : Integer; gps : boolean) : Pointer;
		function get_id_list_as_string(gps : boolean) : string;
		function del_crews_old_coords() : Integer;
		procedure set_crews_orderId_by_order_list(var List : TOrderList);
	end;

implementation

uses main;

function sort_orders_by_source_time(p1, p2 : Pointer) : Integer;
var s1, s2 : string;
	id1, id2 : Integer;
begin
	s1 := TOrder(p1).source_time;
	s2 := TOrder(p2).source_time;
	id1 := TOrder(p1).ID;
	id2 := TOrder(p2).ID;
	if (s1 < s2) then
		exit(-1)
	else
		if (s1 > s2) then
			exit(1)
		else
			if (id1 < id2) then // ���� ����� ������ ��������� ��������� �� OrderID
				exit(-1)
			else
				if (id1 > id2) then
					exit(1)
				else
					exit(0);
end;

function sort_crews_by_crewid(p1, p2 : Pointer) : Integer;
var id1, id2 : Integer;
	c1, c2 : TCrew;
begin
	c1 := TCrew(p1);
	c2 := TCrew(p2);
	id1 := c1.CrewID;
	id2 := c2.CrewID;
	if (id1 < id2) then
		exit(-1)
	else
		if (id1 > id2) then
			exit(1)
		else
			exit(0);
end;

function sort_crews_by_time(p1, p2 : Pointer) : Integer;
var t1, t2 : Integer;
	d1, d2 : double;
	c1, c2 : TCrew;
begin
	c1 := TCrew(p1);
	c2 := TCrew(p2);
	t1 := c1.time;
	t2 := c2.time;
	d1 := c1.dist_way;
	d2 := c2.dist_way;
	if (t1 < t2) then
		exit(-1)
	else
		if (t1 > t2) then
			exit(1)
		else
			if (d1 < d2) then // ���� ����� �����, ���������� ����� ��������
				exit(-1)
			else
				if (d1 > d2) then
					exit(1)
				else
					exit(0);
end;

function sort_crews_by_state_dist(p1, p2 : Pointer) : Integer;
var s1, s2 : Integer;
	d1, d2 : double;
	c1, c2 : TCrew;
begin
	c1 := TCrew(p1);
	c2 := TCrew(p2);
	d1 := c1.dist;
	d2 := c2.dist;
	{
	  // ��������� �� ��������� �����
	  s1 := c1.state; s2 := c2.state;
	  if (s1 < s2) then
	  exit(-1)
	  else
	  if (s1 > s2) then
	  exit(1)
	  else
	  }
	if (d1 < d2) then // if state1 == state2
		exit(-1)
	else
		if (d1 > d2) then
			exit(1)
		else
			exit(0);
end;

function sort_cars_by_dist(p1, p2 : Pointer) : Integer;
var
	d1, d2 : double;
	c1, c2 : TCar;
begin
	c1 := TCar(p1);
	c2 := TCar(p2);
	d1 := c1.dist_to_ap;
	d2 := c2.dist_to_ap;
	if (d1 < d2) then
		exit(-1)
	else
		if (d1 > d2) then
			exit(1)
		else
			exit(0);
end;

function sort_cars_by_app_time(p1, p2 : Pointer) : Integer;
var t1, t2 : Integer;
	c1, c2 : TCar;
begin
	c1 := TCar(p1);
	c2 := TCar(p2);
	t1 := c1.approximate_time();
	t2 := c2.approximate_time();

	if t1 = t2 then
		exit(0);
	if (t1 < 0) and (t2 >= 0) then
		exit(1);
	if (t2 < 0) and (t1 >= 0) then
		exit(-1);
	if (t1 < t2) then
		exit(-1)
	else
		exit(1);
end;

{ TCrew }

procedure TCrew.calc_dist(coord : string);
var coord_from : string;
	order : TOrder;
begin
	self.dist := -1.0; //
	if (length(coord) = 0) //
		or not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
		then
		exit();

	coord_from := '';
	if (self.state = CREW_NAZAKAZE) then
	begin
		order := nil;
		// ���� ������ �� ������ "� �������" �� ���� �� ����� ������
		if self.POrder_vocheredi <> nil then
		begin
			try
				order := TOrder(self.POrder_vocheredi);
			except
				order := nil;
			end;
		end;

		// ����� ���� �����, �� ������� ������
		if (order = nil) and (self.POrder <> nil) then
		begin
			try
				order := TOrder(self.POrder);
			except
				order := nil;
			end;
		end;

		// ���������� ������ �� �� ������
		if order <> nil then
		begin
			try
				// ��� �� ������������ ������ � ����. ����������� :)
				{ if order.count_int_stops > 0 then
				  exit(); }

				if (order.time_to_end = ORDER_AN_OK) then
					// ����� ������� ��������, �� �������� ��� �� �������
					// ������� ������ ��������� � ������ �� ������� ����������
					coord_from := self.coord
				else
					if (order.time_to_end >= 0) and (order.dest.gps_ok()) then
						coord_from := order.dest.gps;
			except
				coord_from := ''; // �� ������ ������
			end;
		end;
	end
	else
		coord_from := self.coord;

	if coord_from = '' then
		exit()
	else
		self.dist := get_dist_from_coord(coord, coord_from);
end;

function TCrew.coord_depend_state : string;
var order : TOrder;
begin
	result := '';
	if self.state = CREW_NAZAKAZE then
	begin
		try
			if self.last_porder() = nil then
				exit()
			else
			begin
				order := TOrder(self.last_porder());
				if order.time_to_end = ORDER_AN_OK then
					result := self.coord
				else
					if order.dest.gps_ok() then
						result := order.dest.gps;
			end;
		except
			exit();
		end;
	end
	else
		result := self.coord;
end;

constructor TCrew.Create(GpsId : Integer);
begin
	inherited Create;
	self.GpsId := GpsId;

	self.coords_full := TstringList.Create;
	self.coords_full.Duplicates := dupIgnore; // �� ��������� ����������
	self.coords_full.Sorted := true;

	self.CrewID := -1;
	self.state := -1; // ���������: 1 - ��������, 3 - �� ������;
	self.Code := '';
	self.name := '';
	// self.state_as_string := '';
	self.coord := ''; // ������� (����� ������) ���������� GPS
	// old_coord := ''; // ���������� ����������
	self.dist := -1.0; // ���������� �� ������ ������ (��)
	self.time := -1; // ����� �������� � �� � �������;
	self.OrderId := -1; // ID ������ �������� �������
	self.order_way := ''; // ������� �������� �������

	source := TAdres.Create('', '', '', ''); // address from
	dest := TAdres.Create('', '', '', ''); // address to
	ap := TAdres.Create('', '', '', ''); // ����� ������
	self.way_to_ap := TWay.Create();
	self.way_to_ap.zapros.browser.OnNavigateComplete2 := self.set_time_to_ap;
	// self.points := TList.Create();
	self.cur_pos := TAdres.Create('', '', '', '');
	self.POrder := nil;
	self.POrder_vocheredi := nil;
	self.POrder_time_to_ap := nil;
end;

// function TCrew.def_time_to_ap(var polist : Pointer) : Integer;
function TCrew.def_time_to_ap() : Integer;
var order : TOrder;
begin
	if //
		not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
	// ������� ������ ��������� � ������� �������, �������� ��������� � �.�.
		or (self.coord = '') // ���� ��� ������� �����.
		or (self.ap.isEmpty()) // ���� �������� ����� ������
		then
	begin
		self.set_time(-1, -1);
		exit(-1);
	end;
	self.cur_pos.setAdres('', '', '', self.coord); // ������ �������� - ������� ���������� ������
	self.way_to_ap.points.Clear(); // ������ ����� ��������

	order := nil;
	if (self.state = CREW_NAZAKAZE) then
	begin
		if self.POrder_vocheredi <> nil then
		begin
			try
				order := TOrder(self.POrder_vocheredi);
				if order.state <> ORDER_V_OCHEREDI then
					order := nil;
			except
				order := nil;
			end;
		end
		else
		begin
			if (self.POrder <> nil) then
				try
					order := TOrder(self.POrder);
				except
					order := nil;
				end;
		end;
	end;

	if //
		(self.state = CREW_SVOBODEN) //
	// ����� ���������� ��������, ������ ��������
		or ((order <> nil) and (order.time_to_end = ORDER_AN_OK)) //
		then
	begin
		self.way_to_ap.points.Add(Pointer(cur_pos));
		self.POrder := nil; // �� ������ ������ ��� �������� � self.set_time_to_ap
	end
	else
	begin
		// self.way_to_ap.points.Add(Pointer(TOrder(self.POrder).dest));
		try
			self.way_to_ap.points.Add(Pointer(order.dest));
		except
			exit(-1);
		end;
	end;

	self.way_to_ap.points.Add(Pointer(self.ap));

	// �������� ������
	result := self.way_to_ap.get_way_time_dist_unlim();
end;

function TCrew.del_old_coords : Integer;
var sdt, s : string;
	i : Integer;
begin
	if DEBUG then
		exit(0); // ��� ���-�� ���� ���������� �� ����������� :)

	sdt := replace_time(COORDS_BUF_SIZE, now());
	for i := (self.coords_full.count - 1) downto 0 do
	begin
		s := get_substr(self.coords_full.Strings[i], '', '|');
		if (s < sdt) then
			self.coords_full.Delete(i);
	end;
	exit(0);
end;

destructor TCrew.Destroy;
begin
	// self.coords.Free();
	// self.coords_times.Free();
	// self.source.Free();
	// self.dest.Free();
	// self.ap.Free();
	self.POrder := nil;
	self.POrder_vocheredi := nil;
	self.POrder_time_to_ap := nil;
	FreeAndNil(self.coords_full);
	inherited;
end;

function TCrew.dist_str : string;
begin
	if self.dist < 0 then
		exit('99999999');
	// result := IntToStr(round(self.dist));
	result := FloatToStrF(self.dist / 1000, ffFixed, 8, 1) + '��';
	while length(result) < 8 do
		result := ' ' + result;
end;

function TCrew.dist_way_as_string : string;
begin
	if self.dist_way < 0 then
		result := '# - '
	else
		result := FloatToStrF(self.dist_way, ffFixed, 8, 1) + ' ��';
end;

function TCrew.dist_way_str : string;
begin
	if self.dist_way < 0 then
		exit('99999999');
	result := FloatToStrF(self.dist_way, ffFixed, 8, 1);
	while length(result) < 8 do
		result := '0' + result;
end;

function TCrew.get_time(var List : TOrderList; newOrder : boolean) : Integer;
	function get_set_gps(var adr : TAdres) : string;
	begin
		if adr.gps = '' then
			with adr do
				gps := get_gps_coords_for_adres(street, house, korpus);
		exit(adr.gps);
	end;

var cur_pos : TAdres;
	points : TList;
	stops_time : Integer; // ����� �� ��������� ��� ������� �� ������
	order : TOrder;
begin
	if not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
	// .....������� ������ ��������� � ������� �������, �������� ��������� � �.�.
		or (self.coord = '') //
		or (newOrder and self.ap.isEmpty()) //
		or ( //
		(self.state = CREW_NAZAKAZE) //
			and ((self.OrderId = -1) or (self.source.isEmpty()) or (self.dest.isEmpty())) //
		) //
		then
	begin
		result := -1;
		self.set_time(-1, -1);
		exit(result);
	end;

	stops_time := 0;
	points := TList.Create(); // ������ ����� ��������
	cur_pos := TAdres.Create('', '', '', self.coord);
	// ������ �������� - ������� ���������� ������
	points.Add(Pointer(cur_pos));

	if self.state = CREW_NAZAKAZE then
	// ���� ������ �� ������, �� ���������, ��� �� �� � ������ source � dest
	// ���� ��� - ��������� �� � ������� � ���������� ����� �� ���������
	begin
		order := List.order(List.find_by_Id(self.OrderId));
		if (order.state <> ORDER_KLIENT_NA_BORTU) // ������ �� �� �����
			and (not self.was_in_coord(get_set_gps(order.source))) // � �������� � �� �� ��� ���
			then
		begin
			// �.�. ���� ������ ��� �� ������ �������
			points.Add(Pointer(order.source));
			points.Add(Pointer(order.dest));
			stops_time := stops_time + 10 + 3;
		end
		else
			if not self.was_in_coord(get_set_gps(order.dest)) then
			begin
				// ���� ��� ������, �� �� �������
				points.Add(Pointer(order.dest));
				stops_time := stops_time + 3;
			end
			else
			begin
				// ������-�������, �� ������ ����� ���������� � ������ ���������
				stops_time := -1; // ��. �����
				self.state := CREW_SVOBODEN;
				order.CrewID := -1; // ���������� ������ � ������
				order.state := ORDER_DONE;
			end;
	end;

	if (not newOrder) and (stops_time = -1) then
		// ���� ������-������� � ��� ������ ��, �� ������� ����� ����������
		result := 0
	else
	begin
		if newOrder then
			points.Add(Pointer(self.ap)); // ����� �������� - ����� ������ ��� ������ ������

		result := get_crew_way_time(points, self.dist_way);

		result := ifthen(result > -1, result + stops_time, -1);
		if newOrder then
			self.set_time(result, self.dist_way);
	end;

	FreeAndNil(points);
	exit(result);
end;

function TCrew.get_time_for_ap(var o_list : TOrderList; n_ap : TAdres) : Integer;
var cur_pos : TAdres;
	points : TList;
	order : TOrder;
	t1, t2 : Integer;
	d1, d2 : double;
	po : Pointer;
begin
	if // !!!!!!!!!!!!!!!
	// ���� ������ �������!!!
		not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
	// .....������� ������ ��������� � ������� �������, �������� ��������� � �.�.
		or (self.coord = '') // ���� ��� ������� �����.
		or (n_ap.isEmpty()) // ���� �������� ����� ������
		then
	begin
		result := -1;
		self.set_time(-1, -1);
		exit(result);
	end;

	points := TList.Create(); // ������ ����� ��������
	cur_pos := TAdres.Create('', '', '', self.coord);
	// ������ �������� - ������� ���������� ������
	result := -1; // �� ������ ������������ ��������
	if self.state = CREW_SVOBODEN then
	begin
		// ������ ������� ������� "������ -- ��"
		points.Add(Pointer(cur_pos)); // ������ ����� - ������
		points.Add(Pointer(n_ap)); // ������ - ������� ��
		result := get_crew_way_time(points, self.dist_way);
	end
	else
	begin
		po := o_list.find_by_Id(self.OrderId);
		if po <> nil then
		begin
			order := o_list.order(po);
			if order <> nil then
			begin
				// ������� ���������� ����� �� ����� ������:
				if order.time_to_end > -1 then
					t1 := order.time_to_end
				else
					// t1 := order.get_time_to_end(Pointer(self));
					if t1 > -1 then
					begin
						// ������ ������� ����� �������� �� ����� �������� ������ �� ��
						d1 := self.dist_way;
						points.Add(Pointer(order.dest));
						// �� ����� ������������ ������
						points.Add(Pointer(n_ap)); // ������ - ������� ��
						t2 := get_crew_way_time(points, d2);
						if t2 > -1 then
						begin
							result := t1 + t2;
							self.dist_way := d1 + d2;
						end;
					end;
			end;
		end;
	end;

	self.set_time(result, self.dist_way); // ���� result = -1, �� � dist_way ������ -1, ���� ���, �� ��� :)
	FreeAndNil(points);
end;

function TCrew.was_in_coord(coord : string) : boolean;
var cc, s, sdt : string; //
	d : double;
	i : Integer;
	int_flag : boolean;
	order : TOrder;
begin
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	result := length(self.when_was_in_coord(coord)) > 0;
	exit();
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	result := false;
	int_flag := false;
	sdt := replace_time(COORDS_NO_INT_BUF_SIZE, now());
	if self.POrder <> nil then
	begin
		try
			order := TOrder(self.POrder);
		except
			int_flag := false;
		end;
		if order <> nil then
			try
				int_flag := (order.int_stops.count > 0);
			except
				int_flag := false;
			end;
	end;

	(*
	  for cc in self.coords_full do
	  begin
	  d := get_dist_from_coord(coord, get_substr(cc, '|', ''));
	  if (d >= 0) and (d < CREW_RADIUS) then
	  exit(true);
	  end;
	  exit(false);
	  *)

	for i := (self.coords_full.count - 1) downto 0 do
	begin
		s := get_substr(self.coords_full.Strings[i], '', '|');
		if int_flag or (s < sdt) then
		begin
			cc := get_substr(self.coords_full.Strings[i], '|', '');
			d := get_dist_from_coord(coord, cc);
			if (d >= 0) and (d < CREW_RADIUS) then
				exit(true);
		end;
	end;
	exit(false);
end;

function TCrew.when_was_in_coord(coord : string) : string;
var cc, s, sdt : string; //
	d : double;
	i : Integer;
	int_flag : boolean;
	order : TOrder;
begin
	result := '';
	int_flag := false;
	sdt := replace_time(COORDS_NO_INT_BUF_SIZE, now());
	if self.POrder <> nil then
	begin
		try
			order := TOrder(self.POrder);
		except
			int_flag := false;
		end;
		if order <> nil then
			try
				int_flag := (order.int_stops.count > 0);
			except
				int_flag := false;
			end;
	end;

	for i := 0 to (self.coords_full.count - 1) do
	begin
		s := get_substr(self.coords_full.Strings[i], '', '|');
		if int_flag or (s >= sdt) then
		begin
			cc := get_substr(self.coords_full.Strings[i], '|', '');
			d := get_dist_from_coord(coord, cc);
			if (d >= 0) and (d < CREW_RADIUS) then
				exit(s);
		end;
	end;
	exit('');
end;

{
  function TCrew.is_moved : boolean;
  begin
  if self.coord = '' then
  exit(false);
  if self.old_coord = '' then
  result := true
  else
  result := get_dist_from_coord(self.coord, self.old_coord) > CREW_MOVE_DIST;
  // if result then
  // self.old_coord := self.coord;
  end;
}

function TCrew.last_porder : Pointer;
begin
	result := self.POrder_vocheredi;
	if result = nil then
		result := self.POrder;
end;

function TCrew.line_number_color : string;
begin
	result := ifthen(pos('-2', self.Code) > 0, '!    2', '*    1');
end;

function TCrew.now_in_coord(coord : string) : boolean;
begin
	if self.coord = '' then
		exit(false);
	result := get_dist_from_coord(coord, self.coord) < CREW_RADIUS;
end;

function TCrew.order_time_to_end : Integer;
var
	order : TOrder;
begin
	if not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) then
		exit(-1);

	if self.state = CREW_SVOBODEN then
		exit(0);

	result := -1;
	order := nil;
	if self.POrder_vocheredi <> nil then
	begin
		try
			order := TOrder(self.POrder_vocheredi);
			if order.state <> ORDER_V_OCHEREDI then
				order := nil;
		except
			exit();
		end;
	end
	else
		if self.POrder <> nil then
			try
				order := TOrder(self.POrder);
			except
				exit();
			end
		else
			exit();

	if (order <> nil) then
	begin
		// ��� ������� "�� ������ ��������� ����� �� ��������� ���. ������
		try
			result := order.time_to_end;
			// ���� ����� ��������, �� ��� ��� ���������� �������
			if result = ORDER_AN_OK then
				result := 0;
		except
			exit();
		end;
	end;
end;

function TCrew.pererasxod(half_dist_way : double) : Integer;
begin
	result := -1;
	self.rasxod := -1.0;
	if (self.dist_way < 0) or (self.dist < 0) then
		exit();

	self.rasxod := half_dist_way / 2.0;

	if self.dist_way < self.rasxod then
		exit(0)
	else
		if self.dist_way < 10.0 then
			exit(1)
		else
			exit(2);
end;

function TCrew.pererasxod_color(half_dist_way : double) : string;
begin
	result := '';
	// FloatToStrF(self.rasxod, ffFixed, 8, 1);
	case self.pererasxod(half_dist_way) of
		0 :
			result := '*' + result;
		1 :
			result := '!' + result;
		2 :
			result := '!!!' + result;
	else
		result := '#' + result;
	end;
end;

function TCrew.set_current_coord() : Integer;
var coord_stime, cur_stime : string;
begin
	if self.coords_full.count > 0 then
		coord_stime := get_substr(self.coords_full[self.coords_full.count - 1], '', '|')
	else
		coord_stime := '';

	cur_stime := replace_time(CREW_CUR_COORD_TIME, now());
	if (length(coord_stime) < 19) // 'yyyy-mm-dd hh:nn:ss'
		or (coord_stime < cur_stime) //
		then
	begin
		// ���������� ������� "��������" �� CREW_CUR_COORD_TIME ����� � �����
		self.coord := '';
		// self.old_coord := '';
	end
	else
	begin
		self.coord := get_substr(self.coords_full[self.coords_full.count - 1], '|', '');
	end;
	if (length(self.coord) < 19) then // '30.123456,59.123456'
		self.coord := '';
	exit(0);
end;

function TCrew.real_state : Integer;
var order : TOrder;
begin
	if self.state <> CREW_NAZAKAZE then
		exit(self.state);

	result := self.state;
	order := nil;
	try
		if self.POrder_vocheredi <> nil then
		begin
			order := TOrder(self.POrder_vocheredi);
			if order.state <> ORDER_V_OCHEREDI then
				order := nil;
		end
		else
		begin
			if (self.POrder <> nil) then
				order := TOrder(self.POrder);
		end;
	except
		exit();
	end;

	if (order <> nil) //
		and (order.time_to_end = ORDER_AN_OK) // ����� ���������� ��������, ������ ��������
		then
		result := CREW_SVOBODEN;
end;

{
  procedure TCrew.reset_old_coord;
  begin
  self.old_coord := self.coord;
  end;
}

function TCrew.ret_data : string;
begin
	result := '' //
		+ self.time_str + '$' // ��� ���������� �� ������� ����� stringlist.sort()
		+ IntToStr(self.CrewID) + '|' //
		+ self.name + '||' //
		+ self.state_as_string + '|||' //
		+ self.time_as_string + '||||' //
		+ self.dist_way_as_string;
end;

function TCrew.ret_data_to_ap(source_time : string; half_dist_way : double) : string;
var
	s_opozdanie, scolor, prefix, res, rasxod, line_num, pref_r, pref_l : string;
	dt, ap_dt : TDateTime;
	opozdanie : Integer;
	prev_flag : boolean;
	buf_time : Integer;
	buf_dist_way : double;
begin
	prev_flag := false;
	line_num := self.line_number_color();
	rasxod := self.pererasxod_color(half_dist_way);
	pref_l := ifthen(line_num[1] = '*', '#', '&');
	pref_r := ifthen((rasxod[1] in ['*', '!']) and (pos('!!!', rasxod) = 0), '#', '&');

	if self.time < 0 then
	begin
		prev_flag := true;
		buf_time := self.time;
		buf_dist_way := self.dist_way;
		try
			self.dist_way := 1.3 * self.dist / 1000;
			self.time := round(60 * self.dist_way / speed_list.average_speed());

			// prefix := '___';
			// res := self.dist_str();
			// s_opozdanie := self.time_as_string();
			// scolor := '';
		except
			exit('');
		end;
	end
	else
	begin
		pass();
	end;
	dt := IncMinute(now(), self.time);
	ap_dt := source_time_to_datetime(source_time);
	opozdanie := MinutesBetween(ap_dt, dt);
	s_opozdanie := self.time_to_str(opozdanie);
	if dt > ap_dt then
	begin
		s_opozdanie := '�������� �� ' + s_opozdanie;
		if opozdanie < 10 then
		begin
			res := self.dist_way_str();
			scolor := '!';
			prefix := '#' + pref_r + ifthen(pref_r = '#', pref_l, '_'); // ������ � ����������� !
		end
		else
		begin
			res := self.time_str();
			scolor := '!!! ';
			prefix := '&&&';
		end;
	end
	else
	begin
		s_opozdanie := '�������� � ������� ' + s_opozdanie;
		// prefix := '#';
		prefix := '#' + pref_r + ifthen(pref_r = '#', pref_l, '_');
		res := self.dist_way_str();
		scolor := '*';
	end;

	if prev_flag then
	begin
		scolor := '^';
		// rasxod := '^';
		prefix := '___';
		res := self.dist_str();
	end;

	result := '' //
		+ prefix + res //
		+ '$' + self.dist_str() //
		+ '|' + self.Code //
		+ '||' + self.state_as_string() //
		+ '|||' + scolor + s_opozdanie //
		+ '||||' + rasxod + self.dist_way_as_string() //
		+ '|||||' + rasxod //
		+ '||||||' + line_num //
		;

	if prev_flag then
	begin
		self.time := buf_time;
		self.dist_way := buf_dist_way;
	end;
end;

procedure TCrew.set_time(m : Integer; d : double);
var order : TOrder;
	PCar : Pointer;
	car : TCar;
begin
	self.time := m;
	if m < 0 then
		self.dist_way := -1
	else
		self.dist_way := d;
	{
	  if self.POrder_time_to_ap <> nil then
	  begin
	  try
	  order := TOrder(self.POrder_time_to_ap);
	  if order.need_get_cars() then
	  begin
	  PCar := order.car_for_crew(Pointer(self));
	  if PCar <> nil then
	  begin
	  car := TCar(PCar);
	  car.dist_way_to_ap := self.dist_way;
	  car.time_to_ap := self.time;
	  car.res_data := self.ret_data_to_ap(order.source_time, order.raw_dist_way);
	  end;
	  end;
	  except
	  self.POrder_time_to_ap := nil;
	  end;
	  self.POrder_time_to_ap := nil;
	  end;
	  }
end;

procedure TCrew.set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
var dob : Integer;
	order : TOrder;
	// dob2 : double; // ��� ������� ������� ��� ������� "�� ������" ����� ����
	// ��������� ������ �� ����� ������� �� ��, �� ��������� ������� ����!
begin
	self.way_to_ap.set_way_time_dist(ASender, pDisp, url);

	dob := 0;
	order := nil;
	if (self.state = CREW_NAZAKAZE) then
	begin
		if self.POrder_vocheredi <> nil then
		begin
			try
				order := TOrder(self.POrder_vocheredi);
				if order.state <> ORDER_V_OCHEREDI then
					order := nil;
			except
				order := nil;
			end;
		end;
		if order = nil then
			if self.POrder <> nil then
				try
					order := TOrder(self.POrder);
				except
					order := nil;
				end;

		if (order <> nil) then
		begin
			// ��� ������� "�� ������ ��������� ����� �� ��������� ���. ������
			try
				dob := order.time_to_end;
				// ���� ����� ��������, �� ��� ��� ���������� �������
				if dob = ORDER_AN_OK then
					dob := 0;
			except
				dob := 0; // �� ������ ������ :)
			end;
		end;
	end;

	if dob < 0 then
	begin
		self.set_time(ORDER_WAY_ERROR, -1);
		exit();
	end;

	if (self.way_to_ap.time < 0) then
		self.set_time(ORDER_WAY_ERROR, -1)
	else
		self.set_time(self.way_to_ap.time + dob, self.way_to_ap.dist_way);
end;

procedure TCrew.show_status(s : string);
begin
	show_status(s);
end;

function TCrew.state_as_string : string;
begin
	result := crew_states.Values[IntToStr(self.state)];
	result := StringReplace(result, '_', ' ', [rfReplaceAll]);
end;

function TCrew.time_as_string : string;
begin
	if self.time = ORDER_WAY_ERROR then
		exit('%������ �� ������')
	else
		if self.time < 0 then
			exit('# - ');

	result := IntToStr(self.time mod 60) + ' ���.';
	if self.time > 59 then
		result := IntToStr(self.time div 60) + ' �. ' + result;
end;

function TCrew.time_str : string;
begin
	result := IntToStr(self.time);
	if self.time < 0 then
		result := '99999999'
	else
		while length(result) < 8 do
			result := '0' + result;
end;

function TCrew.time_to_str(time : Integer) : string;
begin
	result := IntToStr(time mod 60) + ' ���.';
	if time > 59 then
		result := IntToStr(time div 60) + ' �. ' + result;
end;

{ TCrewList }

function TCrewList.Append(GpsId : Integer) : Pointer;
var i : Integer;
begin
	i := self.Crews.Add(TCrew.Create(GpsId));
	result := Pointer(self.Crews[i]);
end;

function TCrewList.clear_crew_list : Integer;
begin
	self.Crews.Clear();
	exit(0);
end;

constructor TCrewList.Create(var IBQuery : TIBQuery);
begin
	inherited Create;
	self.Crews := TList.Create();
	self.query := TIBQuery(Pointer(IBQuery));
	// ����� ������� ��������� �� ����
	self.sql_crews_stringlist := TstringList.Create();
	self.tmp_slist := TstringList.Create();
	self.coords_last_id := -1;
end;

function TCrewList.crew(p : Pointer) : TCrew;
var i : Integer;
begin
	i := self.Crews.IndexOf(p);
	if (i > -1) then
		result := TCrew(self.Crews.Items[i])
	else
		result := nil;
end;

function TCrewList.crew(CrewID : Integer) : TCrew;
var pp : Pointer;
begin
	pp := self.findByCrewId(CrewID);
	if pp = nil then
		exit(nil)
	else
		exit(self.crew(pp));
end;

function TCrewList.crewByCrewId(CrewID : Integer) : TCrew;
begin
	if self.isCrewIdInList(CrewID) then
		result := TCrew(self.findByCrewId(CrewID))
	else
		result := nil;
end;

function TCrewList.crewByGpsId(GpsId : Integer) : TCrew;
begin
	if self.isGpsIdInList(GpsId) then
		result := TCrew(self.findByGpsId(GpsId))
	else
		result := nil;
end;

function TCrewList.del_all_none_crewId : Integer;
var pp : Pointer; i : Integer;
begin
	for i := self.Crews.count - 1 downto 0 do
	begin
		pp := Pointer(self.Crews.Items[i]);
		if (self.crew(pp).CrewID = -1) then
			self.Crews.Delete(i);
	end;
	// for pp in self.Crews do
	// if (self.crew(pp).CrewID = -1) then
	// self.Crews.Delete(self.Crews.IndexOf(pp));
	exit(0);
end;

function TCrewList.del_crews_old_coords : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		self.crew(pp).del_old_coords();
	exit(0);
end;

destructor TCrewList.Destroy;
var i : Integer;
begin
	for i := self.Crews.count - 1 downto 0 do
		TCrew(self.Crews.Items[i]).Free();
	FreeAndNil(self.sql_crews_stringlist);
	FreeAndNil(self.tmp_slist);
	inherited;
end;

function TCrewList.findByCrewId(ID : Integer) : Pointer;
begin
	result := self.findById(ID, false);
end;

function TCrewList.findByGpsId(ID : Integer) : Pointer;
begin
	result := self.findById(ID, true);
end;

function TCrewList.findById(ID : Integer; gps : boolean) : Pointer;
var crew : TCrew;
	PCrew : ^TCrew;
begin
	result := nil;
	for PCrew in self.Crews do
	begin
		crew := TCrew(PCrew);
		if ((not gps) and (crew.CrewID = ID)) or (gps and (crew.GpsId = ID)) then
		begin
			result := PCrew;
			exit();
		end;
	end;
end;

function TCrewList.free_crews_count : Integer;
var pc : Pointer;
begin
	result := 0;
	for pc in self.Crews do
		if (TCrew(pc).state = CREW_SVOBODEN) and (length(TCrew(pc).coord) > 0) then
			result := result + 1;
end;

function TCrewList.get_crewid_list_as_string : string;
begin
	result := self.get_id_list_as_string(false);
end;

function TCrewList.get_crews_coords() : Integer;
	function coords_to_str(fields : TFields) : Integer;
	var field : TField; // main file
		j, l, ID, GpsId : Integer; b : TBytes; pint : ^Integer; plat, plong : ^single;
		s, scoords, slat, slong : string; date1, date2, date0 : TDateTime; crew : TCrew; pp : Pointer;
	begin
		ID := StrToInt(fields[0].AsString);
		if ID > self.coords_last_id then // !
			self.coords_last_id := ID;
		date1 := fields[1].AsDateTime;
		date2 := fields[2].AsDateTime;
		field := fields[3];
		l := field.DataSize;
		setlength(b, l);
		b := field.AsBytes;
		// ������ �������� ������ �� ������� ��� ���������
		date0 := (date2 - date1) / (l div 12);

		j := 0;
		while j < l do
		begin
			pint := @b[j];
			plat := @b[j + 8];
			plong := @b[j + 4];
			GpsId := pint^;
			if GpsId > 0 then
			begin
				slat := s_2_6(StringReplace(FloatToStr(plat^), ',', '.', [rfReplaceAll]));
				slong := s_2_6(StringReplace(FloatToStr(plong^), ',', '.', [rfReplaceAll]));
				scoords := slat + ',' + slong; //
				pp := self.findByGpsId(GpsId);
				if pp = nil then
					crew := self.crew(self.Append(GpsId))
				else
					crew := self.crew(pp);
				// crew.append_coords(scoords, date_to_full(date1));
				// crew.coords.Append(scoords); crew.coords_times.Append(date_to_full(date1));
				crew.coords_full.Append(date_to_full(date1) + '|' + scoords);
			end;
			date1 := date1 + date0;
			j := j + 12;
		end;
		exit(0);
	end;

var sel, stime : string; sel_where : string; cur_time : TDateTime;
begin
	if self.coords_last_id < 0 then
	begin
		sel_where := ' MEASURE_START_TIME > ' //
			+ '''' //
			+ replace_time(COORDS_BUF_SIZE, now()) //
			+ '''' //
			+ ' ' //
			;
	end
	else
		sel_where := ' ID > ' + IntToStr(self.coords_last_id) + ' ';

	sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS ' //
		+ 'from CREWS_COORDS ' //
		+ ' where ' //
		+ sel_where //
	// + ' MEASURE_START_TIME > ' + stime //
	// + ' MEASURE_END_TIME > ' + stime // !!!
		;

	self.query.Close();
	self.query.SQL.Clear();
	self.query.SQL.Add(sel);
	try
		self.query.Open();
	except
		show_status('�������� ������ GPS-��������� �� ��');
		exit(-1);
	end;

	while (not self.query.Eof) do
	begin
		coords_to_str(self.query.fields);
		self.query.Next();
	end;
	// ???
	self.query.Close();

	self.del_crews_old_coords();
	self.set_current_crews_coord();
	self.get_crew_list();
	self.del_all_none_crewId();
	exit(0);
end;

function TCrewList.get_crew_list_by_crewid_string(screws_id : string) : Integer;
var sel : string;
begin
	// result := TStringList.Create();
	if length(screws_id) = 0 then
		exit(-1);
	sel := //
		'select CREWS.ID, CREWS.IDENTIFIER, CREWS.CODE, CREWS.NAME, CREWS.STATE ' //
		+ ' from CREWS ' //
		+ ' where ' //
		+ ' CREWS.ID in (' + screws_id + ') '; //
	// result := get_sql_stringlist(self.query, sel);
	ret_sql_stringlist(self.query, sel, self.sql_crews_stringlist);
	// self.set_crews_data(result);
	self.set_crews_data();
end;

function TCrewList.get_crew_list_by_order_list(var List : TOrderList) : Integer;
var pp : Pointer; order : TOrder; crew : TCrew;
begin
	// result := self.get_crew_list_by_crewid_string(List.get_crews_id_as_string());
	self.get_crew_list_by_crewid_string(List.get_crews_id_as_string());
	self.set_crews_orderId_by_order_list(List);
	for pp in List.Orders do
	begin
		order := TOrder(pp);
		crew := self.crewByCrewId(order.CrewID);
		if (order <> nil) and (crew <> nil) then
		begin
			crew.source := order.source;
			crew.dest := order.dest;
			// crew.POrder := Pointer(order); // �� ����, ��� ������� � set_crews_orderId_by_order_list
		end;
	end;
	exit(0);
end;

function TCrewList.get_crew_list_for_ap( //
	new_ap : TAdres; Order_ID : Integer; var res_slist : TstringList //
	) : Integer;
var crew : TCrew;
	i : Integer;

begin
	with new_ap do
		self.set_ap(street, house, korpus, gps);
	self.set_crews_dist(self.ap_gps);
	self.Crews.Sort(sort_crews_by_state_dist);
	res_slist.Clear();

	for i := 0 to self.Crews.count - 1 do
	begin
		crew := self.crew(self.Crews.Items[i]);

		// if //
		// (crew.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
		// and (crew.coord <> '') //
		// // ����������� ������, ��� ����������� �� ����� :)
		// and not((crew.state = CREW_NAZAKAZE) and (crew.OrderId = Order_ID)) //
		// then
		// result.Add(IntToStr(crew.CrewID));

		if //
			(crew.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
			and (crew.coord <> '') //
			and (crew.dist >= 0) //
			then
			res_slist.Add(IntToStr(crew.CrewID))
	end;
	exit(0);
end;

function TCrewList.get_crew_list() : Integer;
var sel, screws_gpsid : string;
begin
	screws_gpsid := self.get_gpsid_list_as_string(); // gpsId �������� �� ������
	if length(screws_gpsid) = 0 then
		exit(-1);
	sel := //
		'select CREWS.ID, CREWS.IDENTIFIER, CREWS.CODE, CREWS.NAME, CREWS.STATE ' //
		+ ' from CREWS ' //
		+ ' where ' //
		+ ' CREWS.IDENTIFIER in (' + screws_gpsid + ') ' // ������ ������� �� ������
	// + ' and CREWS.STATE in (1,3) '; // � ���������� "��������" � "�� ������"
		;
	// result := get_sql_stringlist(self.query, sel);
	// self.set_crews_data(result);

	ret_sql_stringlist(self.query, sel, self.sql_crews_stringlist);
	self.set_crews_data();
	exit(0);
end;

function TCrewList.get_gpsid_list_as_string : string;
begin
	result := self.get_id_list_as_string(true);
end;

function TCrewList.get_id_list_as_string(gps : boolean) : string;
var s : string; pp : Pointer;
begin
	s := '';
	for pp in self.Crews do
		if gps then
			s := s + ',' + IntToStr(self.crew(pp).GpsId)
		else
			s := s + ',' + IntToStr(self.crew(pp).CrewID);
	Delete(s, 1, 1);
	result := s;
end;

function TCrewList.get_nonfree_crewid_list_as_string() : string;
var pp : Pointer;
begin
	result := '';
	for pp in self.Crews do
		if (self.crew(pp).state = CREW_NAZAKAZE) and (self.crew(pp).CrewID > -1) then
			result := result + ',' + IntToStr(self.crew(pp).CrewID);
	if length(result) > 0 then
		Delete(result, 1, 1);
end;

function TCrewList.get_pcrews_for_ap(new_ap : TAdres; var res_pcrews : TList) : Integer;
var crew : TCrew;
	i : Integer;

begin
	// �� ������������, ��. TCrewList.get_pcrews_for_porder !!!!!!!!!!!!!!!!!!!!!!!!!!!!
	with new_ap do
		self.set_ap(street, house, korpus, gps);
	self.set_crews_dist(self.ap_gps);
	// self.Crews.Sort(sort_crews_by_state_dist); // �� �����, ������������� ����� ��������
	res_pcrews.Clear();

	for i := 0 to self.Crews.count - 1 do
	begin
		crew := self.crew(self.Crews.Items[i]);

		if //
			(crew.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
			and (crew.coord <> '') //
			and (crew.dist >= 0) //
			then
			res_pcrews.Add(self.Crews.Items[i]);
	end;
	if res_pcrews.count = 0 then
		exit(0)
	else
		exit(1);
end;

function TCrewList.get_pcrews_for_porder(a_porder : Pointer; var res_pcrews : TList) : Integer;
var crew : TCrew;
	i : Integer;
	order : TOrder;
begin
	result := -1;
	res_pcrews.Clear();
	try
		order := TOrder(a_porder);
	except
		exit();
	end;
	if not order.source.gps_ok() then
		exit();

	with order.source do
		self.set_ap(street, house, korpus, gps);
	self.set_crews_dist(self.ap_gps);

	for i := 0 to self.Crews.count - 1 do
	begin
		crew := self.crew(self.Crews.Items[i]);

		if //
			(crew.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
			and (crew.coord <> '') //
			and (crew.dist >= 0) //
			and (crew.POrder <> a_porder) //
			and (crew.POrder_vocheredi <> a_porder) //
			then
			res_pcrews.Add(self.Crews.Items[i]);
	end;
	if res_pcrews.count = 0 then
		exit(0)
	else
		exit(1);
end;

function TCrewList.isCrewIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, false);
end;

function TCrewList.isGpsIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, true);
end;

function TCrewList.not_free_crews_count : Integer;
var pc : Pointer;
begin
	result := 0;
	for pc in self.Crews do
		if (TCrew(pc).state = CREW_NAZAKAZE) and (length(TCrew(pc).coord) > 0) then
			result := result + 1;
end;

function TCrewList.ret_crews_stringlist : TstringList;
var pp : Pointer; crew : TCrew;
	s : string;
begin
	result := TstringList.Create();
	for pp in self.Crews do
	begin
		crew := self.crew(pp);
		if crew.time > -1 then
		begin
			s := '' //
			// + IntToStr(crew.time) + '$' //
				+ IntToStr(crew.CrewID) + '|' //
				+ crew.name + '||' //
				+ crew.state_as_string + '|||' //
				+ crew.time_as_string + '||||' //
				+ crew.dist_way_as_string;
			result.Append(s);
		end;
	end;

end;

function TCrewList.set_ap(street, house, korpus, gps : string) : Integer;
begin
	self.ap_street := street;
	self.ap_house := house;
	self.ap_korpus := korpus;
	self.ap_gps := gps;
	exit(0);
end;

function TCrewList.set_crewId_by_gpsId(var List : TstringList) : Integer;
var sl : TstringList;
	s : string; crew : TCrew;
begin
	sl := TstringList.Create();
	// sl.Delimiter := '|';
	for s in List do
	begin
		sl.Clear();
		sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);

		crew := self.crewByGpsId(StrToInt(sl.Strings[0]));

		crew.CrewID := StrToInt(sl.Strings[1]);
		crew.Code := sl.Strings[2];
		crew.name := sl.Strings[3];
		crew.state := StrToInt(sl.Strings[4]);
	end;
	FreeAndNil(sl);
	exit(0);
end;

function TCrewList.set_crews_data() : Integer;
var sl : TstringList; s : string; crew : TCrew;
	ID, GpsId : Integer;
begin
	sl := TstringList.Create();
	// sl.Delimiter := '|';
	for s in self.sql_crews_stringlist do
	begin
		sl.Clear();
		sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		ID := StrToInt(sl.Strings[0]);
		GpsId := StrToInt(sl.Strings[1]);
		if self.isGpsIdInList(GpsId) then
			crew := self.crewByGpsId(GpsId)
		else
			crew := self.crew(self.Append(GpsId));

		crew.CrewID := ID;
		crew.GpsId := GpsId;
		crew.Code := sl.Strings[2];
		crew.name := sl.Strings[3];
		crew.state := StrToInt(sl.Strings[4]);
		if crew.state = 11 then
			// "�� ������ � �������" ������������ � "��������"
			crew.state := CREW_SVOBODEN;
	end;
	FreeAndNil(sl);
	exit(0);
end;

function TCrewList.set_crews_dist(coord : string) : Integer;
var pp : Pointer;
begin
	if length(coord) = 0 then
		result := -1
	else
		result := 0;
	for pp in self.Crews do
		self.crew(pp).calc_dist(coord);
end;

procedure TCrewList.set_crews_orderId_by_order_list(var List : TOrderList);
var order : TOrder;
	crew : TCrew;
	pp : Pointer;
begin
	for pp in List.Orders do
	begin
		order := List.order(pp);
		if //
			(order.CrewID > 0) //
			and (order.state in [ //
				ORDER_V_OCHEREDI, //
			ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, ORDER_VODITEL_PRINYAL, //
			ORDER_VODITEL_PODTVERDIL, //
			ORDER_PRIGLASITE_KLIENTA, ORDER_KLIENT_NE_VYSHEL, //
			ORDER_SMS_PRIGL, ORDER_TEL_PRIGL, //
			ORDER_KLIENT_NA_BORTU //
				]) //
			and self.isCrewIdInList(order.CrewID) //
			then
		begin
			if order.state = ORDER_V_OCHEREDI then
			begin
				self.crewByCrewId(order.CrewID).POrder_vocheredi := pp;
			end
			else
			begin
				self.crewByCrewId(order.CrewID).OrderId := order.ID;
				self.crewByCrewId(order.CrewID).POrder := pp; // Pointer(order);
			end;
		end;
	end;
	// ������� ������ �� ������ � ��������� ��������
	// � ����� ������� �����. ������ �� ������
	for pp in self.Crews do
	begin
		crew := TCrew(pp);
		if crew.state = CREW_SVOBODEN then
			crew.POrder := nil;
		if crew.POrder_vocheredi <> nil then
		begin
			try
				order := TOrder(crew.POrder_vocheredi);
				if order.state <> ORDER_V_OCHEREDI then
					crew.POrder_vocheredi := nil;
			except
				crew.POrder_vocheredi := nil;
			end;
		end;
	end;
end;

function TCrewList.set_crews_state_by_crewId(var List : TstringList) : Integer;
// ��� �� �����;
var s, sid, sstate : string; crew : TCrew;
begin
	for s in List do
	begin
		sid := get_substr(s, '', '|');
		sstate := get_substr(s, '|', '');
		crew := self.crewByCrewId(StrToInt(sid));
		if crew.state = -1 then
			crew.state := StrToInt(sstate);
	end;
	// self.del_all_non_work_crews(); self.del_all_non_work_crews(); // �������, �� ��� �������� :-/
	exit(0);
end;

function TCrewList.set_current_crews_coord : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		self.crew(pp).set_current_coord();
	exit(0);
end;

function TCrewList.isCrewInList(ID : Integer; gps : boolean) : boolean;
var crew : TCrew;
	pp : Pointer;
begin
	for pp in self.Crews do
	begin
		crew := self.crew(pp);
		if ((not gps) and (crew.CrewID = ID)) or (gps and (crew.GpsId = ID)) then
			exit(true);
	end;
	exit(false);
end;

{ TOrder }

function TOrder.add_cars_and_sort : Integer;
var
	i, j : Integer;
	car : TCar;
	PCar : Pointer;
begin
	result := self.get_cars_for_ap();
	if result <= 0 then
		exit();
	// ������� ������� ������� �� �������� ������, ������� ��� � �����,
	// ��� ��� ��� �� �����.
	for PCar in self.Cars do
		if self.PCrews_tmp.IndexOf(TCar(PCar).PCrew) < 0 then
			self.del_car(PCar);

	// ������ ��������� �����, ��-� :)
	for i := self.PCrews_tmp.count - 1 downto 0 do
	begin
		if self.crew_in_cars(self.PCrews_tmp.Items[i]) then
			// ���� ��� ���� � ������, �� ������
		else
		begin
			// ���������
			j := self.Cars.Add(Pointer(TCar.Create()));
			TCar(self.Cars.Items[j]).PCrew := self.PCrews_tmp.Items[i];
			// self.set_car_data(self.Cars.Items[j]);
		end;
	end;
	// ���� ������ ����, �������
	if self.Cars.count = 0 then
		exit(0)
	else
	begin
		// ����� ��������� ������ car-�� � ����� ��������:
		for i := self.Cars.count - 1 downto 0 do
		begin
			self.set_car_data(self.Cars.Items[i]);
			// TCar(self.Cars.Items[i]).def_way_to_ap(); �� �����, ��. car.def_time_to_ap()
		end;
		// � ��������� �� ���������� �� ������ �� ��
		// self.Cars.Sort(sort_cars_by_dist);

		// � ��������� �� ������� ������
		self.Cars.Sort(sort_cars_by_app_time);
		exit(1);
	end;
end;

procedure TOrder.add_cars_grid_to_panel;
var i_ctrl, i_col : Integer;
begin
	if self.cars_gbox_visible then
		exit();
	self.cars_grid.Parent := self.cars_gbox;
	self.cars_gbox.Parent := form_main.ScrollBox_cars; // form_main.GridPanel_cars;
	self.cars_gbox.Font := form_main.grid_order_current.Font;
	// self.cars_gbox.Width := GRID_CARS_COLUMN_WIDTH;
	self.cars_gbox_visible := true;

	(*
	  with form_main.GridPanel_cars do
	  begin
	  ControlCollection.AddControl(self.cars_gbox);
	  i_ctrl := ControlCollection.IndexOf(self.cars_gbox);
	  i_col := ControlCollection.Items[i_ctrl].Column;
	  self.cars_gbox_visible := i_col;
	  ColumnCollection.Items[i_col].Value := GRID_CARS_COLUMN_WIDTH;
	  end;
	  *)
end;

function TOrder.add_to_robocab : boolean;
var
	HTTP : TIdHTTP;
	Request : TstringList;
	Response, s : string;
	table, data, ID, add_time, go_time : string;
	dt_now : TDateTime;
	i : Integer;

	function post() : boolean;
	begin
		result := false;
		Request := TstringList.Create;
		HTTP := TIdHTTP.Create;
		// HTTP.ConnectTimeout := MyConnectTimeout;
		// HTTP.ReadTimeout := MyReadTimeout;
		try
			Request.Values['key'] := robocab_api_key;
			Request.Values['type'] := robocab_api_type;

			// data := StringReplace(data, '|', chr(9), [rfReplaceAll]);
			Request.Values['separator'] := '|';

			Request.Values['test'] := robocab_api_test;
			Request.Values['table'] := table;
			Request.Values['text'] := data;
			try
				Response := HTTP.post(robocab_api_url, Request);
				result := pos('ERROR', Response) = 0;
				if not result then
					showmessage(Response);
				// showmessage(data + chr(10) + chr(13) + Response);
			except
				on E : Exception do
				begin
					// showmessage(E.message);
				end;
			end;
		finally
			HTTP.Free;
			Request.Free;
		end;
	end;

begin
	result := false;

	dt_now := now();
	add_time := replace_time('{Last_minute_0}', dt_now);
	go_time := self.source_time;

	ID := IntToStr(self.ID);

	table := 'orders';
	data := ID //
		+ '|1' // ������
		+ '|' + self.customer //
		+ '|' + self.phone //
		+ '|' + float_to_dotstr_8_2(self.raw_dist_way) // ����� �������� � ����������
		+ '|' // ������������ �������� � ��������
		+ '|' + float_to_dotstr_8_2(self.raw_price) // ��������� �������
		+ '|7' // ��������� 4-������, 7 -�����
		+ '|0' // ������, 0 - �� ��������
		+ '|' + add_time // ����� ���������� ������
		+ '|' + go_time // ����� ������
		+ '|' // ����� ���������
		+ '|' // ����������� ����, �� ���������!
		+ '|' + IntToStr(2 + self.int_stops.count) //
		;
	result := post();
	if not result then
		exit();

	table := 'order_points';
	data := ID + '|' + self.source.gps + '|' + self.source.raw_adres;
	for i := 0 to self.int_stops.count - 1 do
		try
			data := data //
				+ '|' + TAdres(self.int_stops.Items[i]).gps //
				+ '|' + TAdres(self.int_stops.Items[i]).raw_adres //
				;
		except
			exit(false);
		end;
	data := data + '|' + self.dest.gps + '|' + self.dest.raw_adres;
	for i := 0 to ((7 - self.int_stops.count) - 1) do
		data := data + '||';

	// +'|30.235819,59.929871|�����-���������, ������� �������� �.�., 103' //
	// + '|30.374905,59.902384|�����-���������, ����������, 7' //
	// + '||||||||||||||';
	result := post();
end;

procedure TOrder.cars_grid_DrawCell(Sender : TObject; ACol, ARow : Integer; Rect : TRect;
	state : TGridDrawState);
var sub : string;
begin
	if (ACol in [3, 4, 5, 6]) and (ARow > 0) then // ������ ��� ������� �������/������� � ��� ��-��������� �����
	begin
		with TStringGrid(Sender) do
		begin
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
						Canvas.Brush.color := $CCCCCC;
						sub := '#';
					end
					else
						if pos('*', Cells[ACol, ARow]) = 1 then
						begin
							Canvas.Brush.color := $00FF00;
							sub := '*';
						end
						else
							if pos('%', Cells[ACol, ARow]) = 1 then
							begin
								Canvas.Brush.color := $6D6D6D;
								sub := '%';
							end
							else
								if pos('^', Cells[ACol, ARow]) = 1 then
								begin
									Canvas.Brush.color := $FFAAAA;
									sub := '^';
								end
								else
									Canvas.Brush.color := $FFFFFF;

			{
			  if self.hand_get_cars_flag // ��� �������������� ������� ������ �������
			  or (self.state in [ORDER_PRINYAT, ORDER_VODITEL_OTKAZALSYA]) //
			  then
			  pass()
			  else
			  Canvas.Brush.color := $CCCCCC;
			  }

			Canvas.FillRect(Rect);
			Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, get_substr(Cells[ACol, ARow], sub, ''));
		end;
	end;
end;

function TOrder.car_for_crew(PCrew : Pointer) : Pointer;
var pc : Pointer;
begin
	result := nil;
	for pc in self.Cars do
	begin
		try
			if TCar(pc).PCrew = PCrew then
				exit(pc);
		except
			continue;
		end;
	end;
end;

procedure TOrder.clear_cars;
var pp : Pointer;
begin
	for pp in self.Cars do
	begin
		// TCar(pp).time_to_ap := -1;
		self.del_car(pp);
	end;
end;

procedure TOrder.clear_crew;
begin
	// ������� ������ � ������
	self.time_to_end := -1;
	self.time_to_ap := -1;
	self.PCrew := nil;
	self.CrewID := -1; // !!!
	self.clear_cars();
end;

procedure TOrder.click_send_to_robocab(Sender : TObject; Button : TMouseButton; Shift : TShiftState;
	X, Y : Integer);
var but : Integer;
	mes : string;
begin
	if Button <> mbLeft then
		exit();
	mes := '��������� ����� ' //
		+ ifthen(form_main.cb_show_orders_id.Checked, IntToStr(self.ID) + ' ', '') //
		+ self.source.get_as_string() + ' -- > ' + self.dest.get_as_string() //
		+ ' � Robocab.ru?';
	but := MessageDlg(mes, mtConfirmation, mbOKCancel, 0);
	if but = mrOk then
		self.send_to_robocab();
end;

constructor TOrder.Create(OrderId : Integer; var IBQuery : TIBQuery);
begin
	inherited Create();

	self.source := TAdres.Create('', '', '', ''); // address from
	self.dest := TAdres.Create('', '', '', ''); // address to
	self.way_to_ap := TWay.Create(); //
	self.way_to_end := TWay.Create();
	self.way_to_ap.zapros.browser.OnNavigateComplete2 := self.set_time_to_ap;
	self.way_to_end.zapros.browser.OnNavigateComplete2 := self.set_time_to_end;
	self.query := IBQuery;
	self.Cars := TList.Create();
	self.int_stops := TList.Create();
	self.PCrews_tmp := TList.Create();

	self.Cars_StringList := TstringList.Create();
	self.Cars_StringList.Sorted := true; // !

	self.cars_gbox_visible := false;
	self.cars_gbox := TGroupBox.Create(form_main);
	with self.cars_gbox do
	begin
		Width := 0; // GRID_CARS_COLUMN_WIDTH;
		Align := alLeft;
		Visible := true;
		OnDblClick := self.hide_cars_by_hand;
	end;

	self.cars_grid := TStringGrid.Create(form_main);
	with self.cars_grid do
	begin
		Align := alClient;
		FixedRows := 1;
		FixedCols := 0;
		RowCount := 2;
		Font := form_main.grid_order_current.Font;
		DefaultRowHeight := form_main.grid_order_current.DefaultRowHeight;
		ScrollBars := ssVertical;
		OnDrawCell := self.cars_grid_DrawCell;
	end;

	self.timer_cars := TTimer.Create(nil);
	self.timer_cars.Enabled := false;
	self.timer_cars.Interval := 100;

	self.button_send_to_robocab := TButton.Create(form_main.grid_order_current);
	with self.button_send_to_robocab do
	begin
		Parent := form_main.grid_order_current;
		Left := -500;
		Caption := '��������';
		OnMouseUp := self.click_send_to_robocab;
	end;

	self.robocab_http := TIdHTTP.Create;

	self.del_order();
	self.ID := OrderId;

end;

function TOrder.crew_in_cars(PCrew : Pointer) : boolean;
var pc : Pointer;
begin
	result := false;
	for pc in self.Cars do
	begin
		try
			if TCar(pc).PCrew = PCrew then
				exit(true);
		except
			continue;
		end;
	end;
end;

function TOrder.crew_is_moved : boolean;
var coord : string;
begin
	result := false;
	coord := self.crew_coord;
	if coord = '' then
		exit();
	if self.coord_of_crew = '' then
		exit(true);
	result := get_dist_from_coord(coord, self.coord_of_crew) > CREW_MOVE_DIST;
end;

function TOrder.crew_is_not_moved : boolean;
begin
	result := not self.crew_is_moved();
end;

procedure TOrder.def_time_to_ap(var PCrew : Pointer);
var cur_pos : TAdres;
	gps, cur_coord : string;
	d : double;
	crew : TCrew;
	res : Integer;

	procedure do_def();
	begin
		self.way_to_ap.points.Clear(); // ������� ������ ����� ��������
		self.way_to_ap.points.Add(Pointer(cur_pos)); // �� "���������" �����
		self.way_to_ap.points.Add(Pointer(self.source)); // �� ������ ������� ��������
		// �������� ������
		self.way_to_ap.get_way_time_dist();
	end;

begin
	// ��������� ��������� ������, �������� �� ������ ������
	if //
		(self.destroy_flag) // ����� ������� �� ��������
		or (PCrew = nil) //
	// or (self.state <> ORDER_VODITEL_PODTVERDIL) //
		or not(self.state in [ //
			ORDER_V_OCHEREDI, //
		ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, ORDER_VODITEL_PRINYAL, //
		ORDER_VODITEL_PODTVERDIL, //
		ORDER_PRIGLASITE_KLIENTA, ORDER_KLIENT_NE_VYSHEL, //
		ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
			]) //
		or (self.CrewID = -1) //
		or (self.source.isEmpty()) //
		then
	begin
		self.time_to_ap := -1;
		exit();
	end;

	if self.time_to_ap = ORDER_AP_OK then
		// ������ ������, ������� ������� ���
		exit();

	try
		crew := TCrew(PCrew);
	except
		self.time_to_ap := -1;
		exit();
	end;

	if crew = nil then
	begin
		self.time_to_ap := -1;
		exit();
	end;

	cur_coord := self.crew_coord;
	if (cur_coord = '') then
	begin
		self.time_to_ap := ORDER_CREW_NO_COORD;
		exit();
	end;

	if (self.time_to_ap < 0) // ��� �� ���������
	// or (replace_time('Last_minute_1', now()) > self.datetime_of_time_to_ap) //
		or (MinutesBetween(now(), self.datetime_of_time_to_ap) > 0)
	// ��������� � ������ ������ ������ ����� �������
		then // ����� �������, � ����� ������� � �� �������
		pass()
	else
		exit();

	gps := self.source.gps;
	if pos('Error', gps) > 0 then
	begin
		self.source.gps := '';
		self.time_to_ap := ORDER_BAD_ADRES;
		exit();
	end;
	if gps = '' then
	// ��� ���������� � ������ ������
	begin
		self.source.get_gps();
		exit();
	end;
	if (self.state = ORDER_V_OCHEREDI) then
	begin
		if crew.POrder <> nil then
			try
				self.dobavka_v_ocheredi := TOrder(crew.POrder).time_to_end;
			except
				self.time_to_ap := -1;
				exit();
			end
		else
		begin
			self.time_to_ap := -1;
			exit();
		end;
		if (self.dobavka_v_ocheredi = ORDER_AN_OK) or (self.dobavka_v_ocheredi >= 0) then
		begin
			if self.dobavka_v_ocheredi = ORDER_AN_OK then
			begin
				self.dobavka_v_ocheredi := 0;
				cur_pos := TAdres.Create('', '', '', cur_coord) // ���. �����. �������
			end
			else
				try
					cur_pos := TOrder(crew.POrder).dest;
				except
					self.time_to_ap := -1;
					exit();
				end;

			do_def();
		end
		else
		begin
			self.time_to_ap := -1;
			exit();
		end;
	end
	else
	begin
		self.dobavka_v_ocheredi := 0; // �� ������ ������, �� �...
		if (not crew.was_in_coord(gps)) then // �������� � �� �� ��� ���
		begin
			// ������ �������� - ������� ���������� ������
			cur_pos := TAdres.Create('', '', '', cur_coord);
			do_def();
		end
		else
		begin
			// ���� ��� ���
			if crew.now_in_coord(gps) then
				// ������ � ��������� ������ ��������� � ��
				self.time_to_ap := 0
			else
				// ���, �� �����, ������, ������ �������, ��� :)
				self.time_to_ap := ORDER_AP_OK;
		end;
	end;
end;

procedure TOrder.def_time_to_end(var PCrew : Pointer);
var
	cur_pos, adr : TAdres;
	gps, cur_coord : string;
	// points : TList;
	// stops_time : Integer;  - ������� self.stops_time
	// ����� �� ��������� ��� ������� �� ������
	crew : TCrew; //
	dobavka : Integer; // �������� ����� ������� �������� � �������� ������ � �������
	cur_dt, ap_dt : TDateTime;
	ppi : Pointer;
	i, j : Integer;
	int_ok_flag : boolean;
	// na_bortu : boolean; - ������� self.na_bortu

label ras4et;

	procedure add_all_int();
	var ii : Integer;
	begin
		for ii := 0 to self.int_stops.count - 1 do
			self.way_to_end.points.Add(self.int_stops.Items[ii])
	end;

begin

	if (self.destroy_flag) then // ����� ������� �� ��������, ������� �����
	begin
		self.time_to_end := -1;
		exit();
	end;

	if self.state in [ORDER_DONE, ORDER_VODITEL_VYPOLNIL_ZAKAZ] then
		// ������ ������� �� ��������� �����
		exit();

	// ��������� ��������� ������, �������� �� ������ ������
	if //
		not(self.state in [ //
			ORDER_V_OCHEREDI, //
		ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, ORDER_VODITEL_PRINYAL, //
		ORDER_VODITEL_PODTVERDIL, ORDER_KLIENT_NA_BORTU, //
		ORDER_PRIGLASITE_KLIENTA, ORDER_KLIENT_NE_VYSHEL, //
		ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
			]) //
		then
	begin
		self.time_to_end := -1;
		exit();
	end;

	if self.time_to_end = ORDER_AN_OK then
		// ����� ��� ��� ��������, ������� ������� ���
		exit();

	// ��������� ������������� ������� � �������
	if
	// (self.state in [ORDER_DONE, ORDER_CANCEL, ORDER_DISCONTNUED]) //
	// or
		(self.CrewID = -1) //
		or (self.source.isEmpty()) //
		or (self.dest.isEmpty()) //
		then
		exit();

	// if self.count_int_stops > 0 then // ������ � ��������. ����������� ���� �� �����������
	// begin
	// self.time_to_end := ORDER_HAS_STOPS;
	// exit();
	// end;

	crew := TCrew(PCrew);
	if crew = nil then
		exit();

	cur_coord := self.crew_coord;
	if (cur_coord = '') then
	begin
		self.time_to_end := ORDER_CREW_NO_COORD;
		exit();
	end;

	if (self.time_to_end > 0) // ��� ���������
		and self.crew_is_not_moved() // � ������ �� ������������ � �������� �� �������� ����������
		then // �� �� �������������, ������ ���, ����� ������ ��������
		exit();

	if pos('Error', self.dest.gps) > 0 then
	begin
		self.dest.gps := '';
		self.time_to_end := ORDER_BAD_ADRES;
		exit();
	end;

	if self.dest.gps = '' then
	begin
		self.dest.get_gps();
		exit();
	end;

	// ���� ���� �����. ��������� ��������� ��� ���-���������� ��!
	if self.int_stops.count > 0 then
		for ppi in self.int_stops do
			try
				if TAdres(ppi).gps_ok() then
				else
				begin
					TAdres(ppi).get_gps();
					exit();
				end;
			except
				exit();
			end;

	cur_dt := now();
	ap_dt := source_time_to_datetime(self.source_time);
	if cur_dt < ap_dt then
		dobavka := MinutesBetween(cur_dt, ap_dt)
	else
		dobavka := 0;

	self.stops_time := 0; // + self.count_int_stops * INT_STOP_TIME; // !!!!!!!!!!!!
	self.way_to_end.points.Clear(); // ������ ����� ��������
	// ������ �������� - ������� ���������� ������ (������, �� �� ������)
	cur_pos := TAdres.Create('', '', '', cur_coord);

	// ���� ������ �� ������, �� ���������, ��� �� �� � ������ source � dest
	// ���� ��� - ��������� �� � ������� � ���������� ����� �� ���������
	self.na_bortu := false;

	if (self.state = ORDER_V_OCHEREDI) then // ������ ������
	begin
		if self.time_to_ap > 0 then
		begin
			// ���������� ����� � �����
			self.way_to_end.points.Clear(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			self.way_to_end.points.Add(Pointer(self.source));
			add_all_int(); // ! ��������� ����. �����, ���� ����
			self.way_to_end.points.Add(Pointer(self.dest));
			self.stops_time := //
				ifthen(dobavka > self.time_to_ap, dobavka, self.time_to_ap) //
				+ (self.count_int_stops * INT_STOP_TIME) + 10 + 3;
			goto ras4et; // !!! ������� �� ������!
		end
		else
		begin
			exit() // ������ ���� �� ���������
		end;
	end
	else
	begin
		if ( //
			self.state in [ //
				ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, ORDER_VODITEL_PRINYAL, //
			ORDER_VODITEL_PODTVERDIL //
				] //
			) //
			then // ������ �� �� �����
		begin
			if self.time_to_ap = ORDER_AP_OK then
				// ������ �� ����� � ������� ����� ��� � ��, �� ������ ������!
				self.na_bortu := true
			else
				if self.time_to_ap < 0 then
					exit() // ������ ���� �� ���������
				else
					if self.time_to_ap = 0 then // �������� �� ����� � ���
					begin
						// self.na_bortu := true;
						self.way_to_end.points.Clear();
						self.way_to_end.points.Add(Pointer(cur_pos));
						add_all_int(); // ! ��������� ����. �����, ���� ����
						self.way_to_end.points.Add(Pointer(self.dest));
						self.stops_time := dobavka //
							+ (self.count_int_stops * INT_STOP_TIME) + 10 + 3;
						goto ras4et; // !!! ������� �� ������!
					end
					else
					// ���������� ����� � �����
					begin
						self.way_to_end.points.Clear(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						self.way_to_end.points.Add(Pointer(self.source));
						add_all_int(); // ! ��������� ����. �����, ���� ����
						self.way_to_end.points.Add(Pointer(self.dest));
						self.stops_time := //
							ifthen(dobavka > self.time_to_ap, dobavka, self.time_to_ap) //
							+ (self.count_int_stops * INT_STOP_TIME) + 10 + 3;
						goto ras4et; // !!! ������� �� ������!
					end;
		end
		else
		begin
			if (self.state in [ //
					ORDER_PRIGLASITE_KLIENTA, ORDER_KLIENT_NE_VYSHEL, //
				ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
					]) //
				then
			begin
				if self.time_to_ap = ORDER_AP_OK then
					// ������ �� ����� � ������� ����� ��� � ��, �� ������ ������!
					self.na_bortu := true
				else
				begin
					// ���� �������� ������� �������, ���������� ����� �� ��������
					// self.na_bortu := true;
					self.way_to_end.points.Clear();
					self.way_to_end.points.Add(Pointer(cur_pos));
					add_all_int(); // ! ��������� ����. �����, ���� ����
					self.way_to_end.points.Add(Pointer(self.dest));
					self.stops_time := dobavka //
						+ (self.count_int_stops * INT_STOP_TIME) + 10 + 3;
					goto ras4et; // !!! ������� �� ������!
				end;
			end;
		end;
	end;

	// ���� ��� ������, ����� � ��, �� �� ������� � ��
	if (self.na_bortu) or (self.state = ORDER_KLIENT_NA_BORTU) then
	begin
		self.stops_time := 0;
		self.way_to_end.points.Clear();
		self.way_to_end.points.Add(Pointer(cur_pos));

		// ��������� ����. �����
		if self.int_stops.count > 0 then
		begin
			int_ok_flag := true;
			for i := 0 to self.int_stops.count - 1 do { ���� ������ ����. ��������� }
			begin
				try
					adr := TAdres(self.int_stops.Items[i]);
				except
					continue;
				end;
				if adr.was_visited() then
					continue
				else
				begin
					{
					  if crew.was_in_coord(adr.gps) then
					  adr.set_visited()
					  }
					if adr.is_visited(PCrew) then
						pass()
					else
					begin // ������ � ����� �� ���, ��������� �� ��� �� �����
						int_ok_flag := false;
						for j := i to self.int_stops.count - 1 do
							self.way_to_end.points.Add(self.int_stops.Items[j]);
						self.way_to_end.points.Add(Pointer(self.dest)); //
						self.stops_time := //
							(self.int_stops.count - i) * INT_STOP_TIME + 3; //
						goto ras4et; // !!! ������� �� ������!
					end;
				end;
			end;
		end
		else
			int_ok_flag := true;

		if int_ok_flag then
		begin
			if not self.dest.is_visited(PCrew) then // ��� �� �������
			begin
				self.way_to_end.points.Add(Pointer(self.dest)); //
				self.stops_time := 3; //
				goto ras4et; // !!! ������� �� ������!
			end
			else
			begin
				if self.count_int_stops > 0 then
				begin
					try
						adr := TAdres(self.int_stops.Items[self.int_stops.count - 1]);
					except
						self.time_to_end := -1;
						exit();
					end;

					if self.dest.when_visited() <= adr.when_visited() then
					begin
						// ���� �� ������� ������ ��������� ����. �����
						// �� ��� �������� ���������� ��������
						// ��� �� ���������  �� ��� ����� �� ����. �����
						// ������ ���������� �������
						self.way_to_end.points.Add(Pointer(self.dest)); //
						self.stops_time := 3; //
						goto ras4et; // !!! ������� �� ������!
					end;
					// ����� ������� ����� ����������
				end;

				if crew.now_in_coord(self.dest.gps) then
					// ����������
					self.time_to_end := 0
				else
					// ������-�������
					self.time_to_end := ORDER_AN_OK;

				self.stops_time := 0;
				exit();
			end;
		end;

		{
		  if int_ok_flag then
		  begin
		  gps := self.dest.gps;
		  if not crew.was_in_coord(gps) then // ��� �� �������
		  begin
		  self.way_to_end.points.Add(Pointer(self.dest)); //
		  self.stops_time := 3; //
		  goto ras4et; // !!! ������� �� ������!
		  end
		  else
		  begin
		  if crew.now_in_coord(gps) then
		  // ����������
		  self.time_to_end := 0
		  else
		  // ������-�������
		  self.time_to_end := ORDER_AN_OK;

		  self.stops_time := 0;
		  exit();
		  end;
		  end;
		  }
	end;

ras4et :
	self.PCrew := PCrew;
	self.datetime_of_time_to_end := now(); // �������� ������ ������ �������
	self.new_coord_of_crew := cur_coord; // ��������, ��� ����� ���������� �������� ����� ������
	self.way_to_end.get_way_time_dist();
end;

function TOrder.del_car(PCar : Pointer) : Integer;
begin
	result := -1;
	try
		result := self.Cars.Remove(PCar);
		if result < 0 then
			exit();
		self.Cars.Pack();
		FreeAndNil(TCar(PCar));
	except
		exit();
	end;
end;

procedure TOrder.del_order();
begin
	self.ID := -1; //
	self.CrewID := -1; //
	self.prior_CrewId := -1; // ��������������� ������ �� �������. ������
	// self.prior := false; // ������� ���������������� ������
	self.state := -1; // -1 - not defined, 0 - ������, ������� �����
	// .                 1 - � ������, 2 - ��������, ��������� ��. crew_globals;
	self.source.Clear(); // address from
	self.dest.Clear(); // address to
	self.source_time := ''; // ����� ������ �������
	self.time_to_end := -1; // ����� �� ��������� ������ � �������
	self.time_to_ap := -1; // ����� �� �������� � ������ ������ � �������
	self.deleted := false; //
	self.way_to_ap.points.Clear(); //
	self.way_to_end.points.Clear(); //
	self.stops_time := 0; //
	self.na_bortu := false; //
	self.PCrew := nil; //
	self.datetime_of_time_to_ap := IncHour(now(), -1); //
	self.datetime_of_time_to_end := self.datetime_of_time_to_ap; //
	self.count_int_stops := 0; //
	self.destroy_flag := false; // ����, ��� ����� ����� ������� �� ������
	self.destroy_time := ''; //
	self.raw_price := -1.0;
	self.raw_dist_way := -1.0; //
	self.dobavka_v_ocheredi := 0; //
	self.timer_cars.Enabled := false; //
	self.Cars.Clear(); //
	self.int_stops.Clear(); //
	self.PCrews_tmp.Clear(); //
	self.Cars_StringList.Clear(); //
	self.hand_get_cars_flag := false; //
	self.cars_gbox.Caption := ''; //
	self.opozdun20_flag := false;
	self.coord_of_crew := '';
	self.new_coord_of_crew := '';
end;

destructor TOrder.Destroy;
begin
	// self.source.zapros.browser.Stop();
	self.source.Free();

	// self.dest.zapros.browser.Stop();
	self.dest.Free();

	// self.query.Free();       // Runtime Error!

	// self.way_to_ap.zapros.browser.Stop();
	self.way_to_ap.Free();

	// self.way_to_end.zapros.browser.Stop();
	self.way_to_end.Free();

	self.Cars.Free();

	// self.cars_gbox.Free();

	self.PCrew := nil;

	inherited;
end;

function TOrder.get_cars_for_ap : Integer;
begin
	if not self.source.gps_ok() then
	begin
		self.source.get_gps_unlim();
		exit(-1);
	end;

	if PMainCrewList = nil then
		exit(-1);
	try
		// result := TCrewList(PMainCrewList).get_pcrews_for_ap(self.source, self.PCrews_tmp);
		result := TCrewList(PMainCrewList).get_pcrews_for_porder(Pointer(self), self.PCrews_tmp);
	except
		exit(-1);
	end;
end;

function TOrder.get_cars_times_for_ap : Integer;
var PCar : Pointer;
	car : TCar;
	crew : TCrew;
begin
	if not self.need_get_cars() then
	// ������ ����������
	begin
		// ������� ���������� �� ������, ����� ����� ���������� �� ���������
		// ��� ��������� �������
		self.clear_cars();
		exit(-1);
	end;

	result := self.add_cars_and_sort();
	if result <= 0 then // ��� ���������� �������� ���� ������ ��� �������
		exit();
	for PCar in self.Cars do
	begin
		try
			car := TCar(PCar);
			car.def_time_to_ap();
		except
			continue; // ������ ��������� � ����. �������
		end;
	end;
end;

function TOrder.get_crew_coord : string;
begin
	result := '';
	if self.CrewID < 0 then
		exit();
	try
		result := TCrew(crew_list.crewByCrewId(self.CrewID)).coord;
	except
		exit();
	end;
end;

procedure TOrder.hide_button_send_to_robocab;
begin
	self.button_send_to_robocab.Left := -512;
end;

procedure TOrder.hide_cars_by_hand(Sender : TObject);
begin
	self.hand_get_cars_flag := false;
	self.clear_cars();
end;

function TOrder.is_bad : boolean;
begin
	result := self.destroy_flag // ���������� ��� �������� ������
		or (self.ID < 0) // ������ �����
		or self.deleted // ����� �����/�������
		or (self.state = ORDER_DONE) // ����� ��������
		or (self.state = ORDER_CANCEL) // ����� �������
		or (self.state = ORDER_DISCONTNUED) // ����� ���������
		or (self.state = ORDER_NO_CREWS) // ��� �����
		or self.source.isEmpty() // ��� ������ ������
		or self.dest.isEmpty() // ��� ������ ����������
	// or (length(self.source_time) < length('2012-01-01 05:35:48')) //
		;
end;

function TOrder.is_in_robocab : boolean;
const tables : array [0 .. 4] of string = //
		('orders_current', 'orders_job', 'orders_complete', //
		'orders_cancel', 'orders_transferred');
var
	HTTP : TIdHTTP;
	Request : TstringList;
	Response : string;
	table, ID : string;

	function get_order() : boolean;
	begin
		result := false;
		Request := TstringList.Create;
		HTTP := TIdHTTP.Create;
		// HTTP.ConnectTimeout := MyConnectTimeout;
		// HTTP.ReadTimeout := MyReadTimeout;
		try
			Request.Values['key'] := robocab_api_key;
			Request.Values['type'] := robocab_api_type;

			// data := StringReplace(data, '|', chr(9), [rfReplaceAll]);
			Request.Values['separator'] := '|';

			Request.Values['download'] := '1';
			Request.Values['test'] := robocab_api_test;
			Request.Values['table'] := table;
			if ID <> '' then
				Request.Values['id'] := ID;
			try
				Response := HTTP.post(robocab_api_url, Request);
				result := length(Response) > 0;
			except
				on E : Exception do
				begin
					// showmessage(E.message);
				end;
			end;
		finally
			HTTP.Free;
			Request.Free;
		end;
	end;

begin
	result := false;
	ID := IntToStr(self.ID);
	for table in tables do
		if get_order() then
			exit(true);
end;

function TOrder.is_not_prior : boolean;
begin
	result := self.source_time < replace_time('{Last_hour_-1}', now());
end;

function TOrder.is_prior : boolean;
begin
	result := not self.is_not_prior();
end;

function TOrder.need_get_cars : boolean;
begin
	if self.is_bad() //
		then
		exit(false);

	if self.hand_get_cars_flag then
		exit(true)
	else
	begin
		if (self.state in //
				[ //
			// ORDER_VODITEL_PODTVERDIL, // ��� �������� �����
				ORDER_PRINYAT, //
			// ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, //�� �����, ������� ��� "���������"
			ORDER_VODITEL_OTKAZALSYA //
			// , ORDER_VODITEL_PRINYAL // �� �����, ������� ��� "���������"
				]) //
			and //
			self.is_not_prior() // � ����� �� ���������������
			then
			result := true
		else
			result := self.opozdun(); //
	end;
end;

function TOrder.need_show_cars : boolean;
var opoz, car_opoz : Integer;
	PCar : Pointer;
begin
	if self.hand_get_cars_flag then
		exit(true);
	result := self.need_get_cars();
	if result then
		if self.opozdun() then
		begin
			result := false; // true ������, ���� ���� cars � ����� ������� ����������
			opoz := self.opozdanie();
			for PCar in self.Cars do
			begin
				car_opoz := TCar(PCar).opozdanie();
				if (car_opoz >= 0) and (car_opoz < (opoz div 2)) then
					exit(true);
			end;
		end;
end;

function TOrder.opozdanie : Integer;
var dt, ap_dt : TDateTime;
begin
	result := 0;
	if self.is_bad() then
		exit();
	// ��������� ��������� ������
	if not(self.state in [ //
			ORDER_V_OCHEREDI, //
		ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, ORDER_VODITEL_PRINYAL, //
		ORDER_VODITEL_PODTVERDIL //
			]) //
		then
		exit();
	if (self.CrewID = -1) then
		exit();
	if self.time_to_ap <= 0 then
		exit();

	dt := IncMinute(now, self.time_to_ap);
	ap_dt := source_time_to_datetime(self.source_time);
	if dt > ap_dt then
		result := MinutesBetween(dt, ap_dt);
end;

function TOrder.opozdun : boolean;
var opoz : Integer;
begin
	// result := false;
	opoz := self.opozdanie();
	if opoz >= 20 then
	begin
		self.opozdun20_flag := true;
		result := true;
	end
	else
		if opoz <= 15 then
		begin
			self.opozdun20_flag := false;
			result := false;
		end
		else
			result := self.opozdun20_flag;
end;

procedure TOrder.refresh_cars_stringlist;
var PCar : Pointer;
	car : TCar;
begin
	self.Cars_StringList.Clear();
	for PCar in self.Cars do
	begin
		try
			car := TCar(PCar);
			// if length(car.res_data) > 0 then
			self.Cars_StringList.Append(car.ret_data());
		except
			continue;
		end;
	end;
end;

function TOrder.send_to_robocab : Integer;
begin
	if self.is_in_robocab() then
		result := 0
	else
		if self.add_to_robocab() then
			result := 1
		else
			result := -1;
	case result of
		0 :
			showmessage('����� ��� ��� ������� � Robocab.ru');
		1 :
			showmessage('����� ������� ������� � Robocab.ru!');
		-1 :
			showmessage('������ ��� �������� ������ � Robocab.ru!!!');
	end;
end;

procedure TOrder.set_car_data(PCar : Pointer);
var car : TCar;
begin
	if PCar = nil then
		exit()
	else
		try
			car := TCar(PCar);
			with self.source do
				car.ap.setAdres(street, house, korpus, gps);
			car.ap_source_time := source_time_to_datetime(self.source_time);
			car.raw_dist_way := self.raw_dist_way;
		except
			exit();
		end;
end;

procedure TOrder.set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin
	self.way_to_ap.set_way_time_dist(ASender, pDisp, url);
	if self.way_to_ap.time < 0 then
		self.time_to_ap := ORDER_WAY_ERROR
	else
	begin
		if self.state = ORDER_V_OCHEREDI then
			self.time_to_ap := self.way_to_ap.time + self.dobavka_v_ocheredi
		else
			self.time_to_ap := self.way_to_ap.time;
		// ���������� ����� �������
		// self.datetime_of_time_to_ap := replace_time('{Last_minute_0}', now());
		self.datetime_of_time_to_ap := now();
	end;
end;

procedure TOrder.set_time_to_end(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin
	self.way_to_end.set_way_time_dist(ASender, pDisp, url);
	if self.way_to_end.time < 0 then
		self.time_to_end := ORDER_WAY_ERROR
	else
	begin
		self.time_to_end := self.way_to_end.time + self.stops_time;
		// with self.way_to_end do
		// speed_list.Append(dist_way, time);

		// ��������� ����������
		// TCrew(self.PCrew).reset_old_coord();  -- �� ����!
		self.coord_of_crew := self.new_coord_of_crew;
	end;
end;

procedure TOrder.show_cars;
var i_ctrl, i_col, j, rr, ww : Integer;
	PCar : Pointer;
	car : TCar;
	crew : TCrew;
	s, Code : string;
	clfl : boolean;

	procedure get_Kursor();
	begin
		// ����������, ��� ��� "������"
		// if self.cars_grid.Cells[1, self.cars_grid.row] = '' then
		// Code := ''
		// else
		Code := self.cars_grid.Cells[1, self.cars_grid.row];
	end;

	procedure put_Kursor();
	var r : Integer;
	begin
		// ������� ���� "������" �����
		if Code = '' then
			r := 1
		else
			r := self.cars_grid.Cols[1].IndexOf(Code);
		if r < 0 then
			r := 1;
		self.cars_grid.row := r;
	end;

begin
	if self.need_show_cars() then
	begin // ����������
		if not self.cars_gbox_visible then
			self.add_cars_grid_to_panel();
		// if self.cars_gbox.Width = 0 then
		// self.cars_gbox.Width := GRID_CARS_COLUMN_WIDTH;
	end
	else
	// ����� ������� �� ���������
	begin
		if self.cars_gbox_visible then
			self.cars_gbox.Width := 0;
		// self.clear_cars();
		exit();
	end;

	// ������� ���������
	self.cars_gbox.Caption := self.source.raw_adres + ' --> ' + self.dest.raw_adres;

	if form_main.cb_show_orders_id.Checked then
		with self.cars_gbox do
			Caption := IntToStr(self.ID) + ' ' // ID ������
				+ ' (' //
				+ IntToStr(self.Cars.count) // ���-�� �������� � ��������
				+ '/' //
				+ IntToStr(self.Cars_StringList.count) // ���-�� ������������
				+ ')' //
				+ Caption //
				;

	self.refresh_cars_stringlist();
	get_Kursor();

	with self.cars_grid do
	begin
		RowCount := 2;
		ColCount := 8;
		FixedRows := 1;
		rows[1].Clear();

		Cells[0, 0] := '�� ������';
		Cells[1, 0] := '������';
		Cells[2, 0] := '���������';
		Cells[3, 0] := '����� ������';
		Cells[4, 0] := '����������';
		Cells[5, 0] := '������';
		Cells[6, 0] := '�����';

		ColWidths[0] := 64; // ifthen(self.cb_debug.Checked, 128, 64); // 64; // 50; // ������ :)
		ColWidths[1] := 50;
		ColWidths[2] := 70;
		ColWidths[3] := 200;
		ColWidths[4] := 80; // (Width - ColWidths[0] - ColWidths[1] - ColWidths[2] - ColWidths[3] - 20) div 2;
		ColWidths[5] := 0; // ifthen(self.cb_debug.Checked, 80, 0);
		ColWidths[6] := 40;
		ColWidths[7] := ifthen(form_main.cb_show_orders_id.Checked, 220, 0);
		ww := GRID_CARS_COLUMN_WIDTH + ColWidths[7];
		if ww <> self.cars_gbox.Width then
			self.cars_gbox.Width := ww;
	end;

	// for s in self.Cars_StringList do
	for rr := 0 to self.Cars_StringList.count - 1 do
	begin
		try
			// car := Tcar(pcar);
			// crew := TCRew(car.PCrew);
			s := self.Cars_StringList.Strings[rr];
			if length(s) > 0 then
				with self.cars_grid do
				begin
					RowCount := RowCount + 1;
					Cells[0, rr + 1] := get_substr(s, '$', '|'); // ifthen(self.cb_debug.Checked, get_substr(s, '', '|'), get_substr(s, '$', '|'));
					Cells[1, rr + 1] := get_substr(s, '|', '||');
					Cells[2, rr + 1] := get_substr(s, '||', '|||');
					Cells[3, rr + 1] := get_substr(s, '|||', '||||');
					Cells[4, rr + 1] := get_substr(s, '||||', '|||||');
					// + '��';
					Cells[5, rr + 1] := get_substr(s, '|||||', '||||||');
					Cells[6, rr + 1] := get_substr(s, '||||||', '|||||||');
					Cells[7, rr + 1] := get_substr(s, '|||||||', '');
				end;
		except
			continue;
		end;
	end;
	// ������� ������ ������ � �����
	with self.cars_grid do
		if RowCount > 2 then
			RowCount := RowCount - 1;
	put_Kursor();
end;

function TOrder.source_time_without_date : string;
begin
	result := time_without_date(self.source_time);
	result := ifthen(length(result) < length('01:45:56'), '!!!    ', '    ') //
		+ result;
end;

function TOrder.state_as_string : string;
begin
	// result := IntToStr(self.state);
	result := order_states.Values[IntToStr(self.state)];
	result := StringReplace(result, '_', ' ', [rfReplaceAll]);
end;

function TOrder.status : string;
var scol : string;
begin
	if (self.time_to_ap = ORDER_AP_OK) or (self.time_to_ap = ORDER_BAD_ADRES) //
		or (self.time_to_ap >= 0) then
	begin
		result := self.time_to_ap_as_string();
		if self.time_to_ap = ORDER_BAD_ADRES then
			result := result + ' ������!';
		// self.source.get_as_string();
	end
	else
	begin
		// if self.time_to_end > 0 then
		// result := '�����������'
		// else
		// begin
		result := self.time_to_end_as_string();
		if self.time_to_end = ORDER_BAD_ADRES then
			result := result + ' ����������!'; // self.dest.get_as_string();
		// end;
	end;
end;

function TOrder.time_as_string(time : Integer) : string;
begin
	result := IntToStr(time mod 60) + ' ���.';
	if time > 59 then
		result := IntToStr(time div 60) + ' �. ' + result;
end;

function TOrder.time_to_ap_as_string : string;
var prib_dt, ap_dt, cur_dt : TDateTime;
	opozdanie, porog : int64; s_opoz : string;
begin
	if self.time_to_ap = ORDER_AP_OK then
	begin
		if (self.state in [ //
				ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, ORDER_VODITEL_PRINYAL, //
			ORDER_VODITEL_PODTVERDIL, //
			ORDER_PRIGLASITE_KLIENTA, ORDER_KLIENT_NE_VYSHEL, //
			ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
				]) then
			result := '!������ �� �����'
		else
			result := '';
	end
	else
		if self.time_to_ap = -1 then
			result := ''
		else
			if self.time_to_ap < 0 then
			begin
				result := order_states.Values[IntToStr(self.time_to_ap)];
				result := StringReplace(result, '_', ' ', [rfReplaceAll]);
			end
			else
				if self.time_to_ap = 0 then
				begin
					if self.state in [ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, //
						ORDER_VODITEL_PRINYAL, ORDER_VODITEL_PODTVERDIL] //
						then
						result := '!�������� �������'
					else
						result := '�������� �������'
				end
				else
				// self.time_to_ap > 0
				begin
					if self.state in [ORDER_PRIGLASITE_KLIENTA, ORDER_KLIENT_NE_VYSHEL, //
						ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
						] //
						then
						result := '�������� �������'
					else
						if self.state in [ORDER_V_OCHEREDI, //
							ORDER_ZAKAZ_OTPRAVLEN, ORDER_ZAKAZ_POLUCHEN, //
							ORDER_VODITEL_PRINYAL, ORDER_VODITEL_PODTVERDIL] //
							then
						begin
							cur_dt := now();
							prib_dt := IncMinute(cur_dt, self.time_to_ap);
							ap_dt := source_time_to_datetime(self.source_time);
							// ��������� ����������/������
							opozdanie := MinutesBetween(prib_dt, ap_dt);
							s_opoz := self.time_as_string(opozdanie);
							if prib_dt > ap_dt then // ���������� ����� :) !
							begin
								result := '���������� �� ' + s_opoz;
								// if cur_dt < ap_dt then
								// porog := MinutesBetween(cur_dt, ap_dt) mod 10
								// else
								// porog := 0;
								porog := 5;
								if opozdanie > porog then
									// ������ ���������� :)
									result := '!!!' + result
								else
									// ���� ���������, �� ��������� :)
									result := '!' + result;
							end
							else
								// result :=  self.time_as_string(self.time_to_ap);
								result := '����� ������ �� ' + s_opoz;
						end
						else
							result := ''
				end;
end;

function TOrder.time_to_end_as_string : string;
begin
	case self.time_to_end of
		ORDER_AN_OK :
			if self.state in [ORDER_DONE, ORDER_VODITEL_VYPOLNIL_ZAKAZ] then
				exit('����� ��������')
			else
				exit('!!!����� ��������');
		-1 :
			exit('');
		0 :
			if self.state in [ORDER_DONE, ORDER_VODITEL_VYPOLNIL_ZAKAZ] then
				exit('����� ��������')
			else
				exit('!������� �������');
	else
		// case
		if self.time_to_end < 0 then
		begin
			result := order_states.Values[IntToStr(self.time_to_end)];
			result := StringReplace(result, '_', ' ', [rfReplaceAll]);
		end
		else
			if self.state in [ORDER_DONE, ORDER_VODITEL_VYPOLNIL_ZAKAZ] then
				exit('����� ��������')
			else
				result := '���������� ����� ' + self.time_as_string(self.time_to_end) //
				// + ' ' + time_without_date(self.datetime_of_time_to_end)//
					;
	end; // case
end;

{ TOrder_List }

function TOrderList.Append(OrderId : Integer) : Pointer;
var i : Integer;
begin
	// ���� ����� ��� � ������, ���������� ��������� �� ����
	if self.is_defined(OrderId) then
		exit(self.find_by_Id(OrderId))
	else
	begin
		// ���� "���������" ����� � ������
		result := self.ret_free_order();
		if result = nil then
		begin
			i := self.Orders.Add(TOrder.Create(OrderId, self.query));
			result := Pointer(self.Orders[i]);
		end
		else
		begin
			TOrder(result).ID := OrderId;
			exit(result);
		end;
	end;
end;

function TOrderList.clear_order_list : Integer;
begin
	self.Orders.Clear();
	exit(0);
end;

constructor TOrderList.Create(var IBQuery : TIBQuery);
begin
	inherited Create;
	self.Orders := TList.Create();
	self.query := IBQuery;
	self.sort_col := 7;
	// �� ��������� ���������� �� ����
end;

function TOrderList.del_bad_orders : Integer;
var pp : Pointer; order : TOrder; i : Integer;
	s_now, s_past : string; cur_t : TDateTime;
begin
	cur_t := now();
	s_now := date_to_full(cur_t);
	s_past := replace_time(ORDER_DESTROY_TIME, cur_t);

	for i := self.Orders.count - 1 downto 0 do
	begin
		order := self.order(self.Orders.Items[i]);
		if //
			order.deleted // ����� �����/�������
			or (order.state = ORDER_DONE) // ����� ��������
			or (order.state = ORDER_CANCEL) // ����� �������
			or (order.state = ORDER_DISCONTNUED) // ����� ���������
			or (order.state = ORDER_NO_CREWS) // ��� �����
			or order.source.isEmpty() // ��� ������ ������
			or order.dest.isEmpty() // ��� ������ ����������
			then
		begin
			if order.destroy_flag then
			begin
				if order.destroy_time < s_past then
				begin
					self.del_order(i); // ������� ����� �� ������
				end; // ����� ������ ���
			end
			else
			begin
				order.destroy_flag := true;
				order.destroy_time := s_now;
			end;
		end
		else
		begin
			order.destroy_flag := false;
			order.destroy_time := '';
		end;
	end;
	exit(0);
end;

function TOrderList.del_order(ListIndex : Integer) : Integer;
begin
	if ListIndex in [0 .. self.Orders.count - 1] then
		try
			// TOrder(self.Orders.Items[ListIndex]).Free();
			// self.Orders.Delete(ListIndex);

			TOrder(self.Orders.Items[ListIndex]).del_order();

			exit(0);
		except
			exit(-2)
		end
	else
		exit(-1);
end;

destructor TOrderList.Destroy;
var i : Integer;
begin
	for i := self.Orders.count - 1 downto 0 do
		TOrder(self.Orders.Items[i]).Free();

	inherited;
end;

function TOrderList.find_by_Id(OrderId : Integer) : Pointer;
var pp : Pointer;
begin
	for pp in self.Orders do
		if self.order(pp).ID = OrderId then
			exit(pp);
	exit(nil);
end;

procedure TOrderList.get_adres_coords;
var sel, s, h, k, ss, sraw : string; res : TstringList;
	order : TOrder; ord_id, jj, tt : Integer;

	procedure add_coo(var adr : TAdres; coo : string);
	begin
		if (not adr.gps_ok()) and (coo <> '0.000000,0.000000') then
			adr.gps := coo;
	end;

	procedure add_coo_p(padres : Pointer; coo : string);
	begin
		if (not TAdres(padres).gps_ok()) and (coo <> '0.000000,0.000000') then
			TAdres(padres).gps := coo;
	end;

	function coords2str(fields : TFields) : string;
	var field : TField; // main file
		j, l, cou : Integer; sid, sordid : string; b : TBytes; plat, plong : ^single;
		scoords, slat, slong : string;
	begin
		result := '';
		// ID := fields[1].AsInteger; // ����� ������, �� ������������
		// cou := fields.Count;
		// sid := fields[0].AsString;
		// sordid := fields[1].AsString;
		field := fields[0];
		l := field.DataSize;
		setlength(b, l);
		b := field.AsBytes;
		j := 2;
		while j < l do
		begin
			plat := @b[j];
			plong := @b[j + 4];
			slat := float_to_dotstr_2_6(plat^);
			slong := float_to_dotstr_2_6(plong^);
			scoords := slat + ',' + slong + '|'; //
			result := result + scoords;
			j := j + 9;
		end;
		if length(result) > 0 then
			if result[length(result)] = '|' then
				Delete(result, length(result), 1);
	end;

begin
	res := TstringList.Create();

	// ���������� �������:
	sel := 'select ' //
		+ ' ORDER_COORDS.COORDS_ADDR   ' // ���������� ������� ������
		+ ' , ORDER_COORDS.ORDER_ID ' // order.ID
		+ ' from ' //
		+ ' ORDER_COORDS ' //
		+ ' where ' //
		+ ' ORDER_COORDS.ORDER_ID in ( ' + self.orders_id_as_string() + ' ) ' //
		;

	self.query.Close();
	self.query.SQL.Clear();
	self.query.SQL.Add(sel);
	try
		self.query.Open();
	except
		show_status('�������� ������ ��������� ������� �� ��');
		exit();
	end;

	while (not self.query.Eof) do
	begin
		ord_id := StrToInt(self.query.fields[1].AsString);
		if self.is_defined(ord_id) then
		begin
			order := TOrder(self.find_by_Id(ord_id)); //
			res.Clear(); //
			res.Text := coords2str(self.query.fields); //
			res.Text := StringReplace(res.Text, '|', #13#10, [rfReplaceAll]); //
			if res.count < 2 then
				pass()
			else
			begin
				add_coo(order.source, res[0]); //
				add_coo(order.dest, res[res.count - 1]); //
			end; //

			if res.count > 2 then // ����� � ����. �����������
			begin
				if order.int_stops.count <> (res.count - 2) then
				// ���� �� �����., �� ���������
				begin
					ss := order.raw_int_stops;
					order.int_stops.Clear();
					for jj := 1 to res.count - 2 do
					begin
						tt := order.int_stops.Add(Pointer(TAdres.Create('', '', '', '')));
						sraw := get_substr(ss, '', ';'); //
						TAdres(order.int_stops.Items[tt]).set_raw_adres(sraw);
						add_coo_p(order.int_stops.Items[tt], res[jj]);
						//

						ss := StringReplace(ss, sraw + ';', '', []); // ������ ������ ����������!
					end;
				end;
			end
			else
				order.int_stops.Clear();

		end; //
		self.query.Next();
	end;
	// ???
	self.query.Close();

	FreeAndNil(res);
end;

function TOrderList.get_crews_id_as_string : string;
var s : string; pp : Pointer;
begin
	s := '';
	for pp in self.Orders do
		s := s + ',' + IntToStr(self.order(pp).CrewID);
	Delete(s, 1, 1);
	result := s;
end;

function TOrderList.get_current_orders_with_data : Integer;
var sel, s, s1 : string;
	res, sl : TstringList;
	sdate_from, sdate_to : string;
	ord_id : Integer; order : TOrder;
	cur_time : TDateTime;
	pord : Pointer;
	cr_id : Integer;
begin
	cur_time := now(); //
	sdate_from := '''' + replace_time('{Last_day_1}', cur_time) + ''''; //
	sdate_to := '''' + replace_time('{Last_day_-1}', cur_time) + ''''; //
	res := TstringList.Create();
	sl := TstringList.Create();

	// ����������� ID ����� �������
	sel := 'select ' //
		+ ' ORDERS.ID ' //
		+ ' from ORDERS ' //
		+ ' where ' //

	// ����������� �������� � ���������� ������
		+ ' (ORDERS.DELETED is null or ORDERS.DELETED = 0) '
	// + ' (ORDERS.DELETED is null) '

	// . ������ ������ � ���������� "������", "� ������" � �.�.
	// . ��. ������ ������� ORDER_STATES
		+ ' and ' //
		+ ' ( ' //
		+ '   ORDERS.STATE in ' //
		+ '   ( ' //
		+ '     select ORDER_STATES.ID from ORDER_STATES ' //
		+ '       where ORDER_STATES.SYSTEMSTATE in (0, 1) ' //
		+ '   ) ' //
		+ ' ) ' //

	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// ������ �� ���� :
	// � ����� ������� ������� ������� ���������� ������
		+ ' and ORDERS.SOURCE_TIME > ' + sdate_from + ' ' //
	// ��������������� �� �������, ��� ����� ����� � ���. �������
	// + ' and ORDERS.SOURCE_TIME < ' + sdate_to + ' ' // �� ������� ������
		;

	ret_sql_stringlist(self.query, sel, res);

	for s in res do
		if not self.is_defined(StrToInt(s)) then
			// ���� ������ ��� � ������, �� ���������
			self.Append(StrToInt(s));

	// ���������
	sel := 'select ' //
		+ ' ORDERS.CREWID, ORDERS.STATE, ORDERS.SOURCE_TIME ' //
		+ ' , ORDERS.SOURCE, ORDERS.DESTINATION ' //
		+ ' , ORDERS.DELETED ' // deleted and canceled orders
		+ ' , ORDERS.PRIOR_CREW_ID ' // prior_crew
		+ ' , ORDERS.STOPS_COUNT ' // ���-�� ��������. ���������
		+ ' , ORDERS.SUMM ' // ��������� ������ ��� ����� ������(�������) ��� ������� ����� ��������
		+ ' , ORDERS.STOPS ' // ����. ���������

		+ ' , ORDERS.ID ' //
		+ ' , ORDERS.CUSTOMER ' // ��������
		+ ' , ORDERS.PHONE ' // ���. ���������

		+ ' from ORDERS ' //
		+ ' where ' //
		+ ' ORDERS.ID in ( ' + self.orders_id_as_string() + ' ) ' //
		;

	ret_sql_stringlist(self.query, sel, sl);

	for s in sl do
	begin
		ord_id := -1;
		pord := nil;

		string_to_stringlist(s, res);

		// ���� ����� ������
		if length(res.Strings[10]) > 0 then
		begin
			try
				ord_id := StrToInt(res.Strings[10]);
			except
				ord_id := -1;
			end;
			if ord_id > 0 then
			begin
				try
					pord := self.find_by_Id(ord_id);
					if pord = nil then
						continue // ����� ���������� ��������
					else
						order := TOrder(pord);
				except
					continue; // ����� ���������� ��������
				end;
			end
			else
				continue; // ����� ���������� ��������
		end
		else
			continue; // ����� ���������� ��������

		// ��������� ������ ������
		if res.Strings[0] <> '' then
		begin
			cr_id := StrToInt(res.Strings[0]);
			if cr_id <> order.CrewID then
			begin
				order.clear_crew();
				order.CrewID := cr_id;
			end;
		end
		else
			order.clear_crew();

		try
			order.state := StrToInt(res.Strings[1]);
		except
			order.state := -1;
		end;

		order.source_time := date_to_full(res.Strings[2]); //
		order.source.set_raw_adres(res.Strings[3]); //
		order.dest.set_raw_adres(res.Strings[4]); //

		// ��������� �������� � ���������� ������
		if (length(res.Strings[5]) = 0) or (res.Strings[5] = '0') then
			order.deleted := false
		else
			order.deleted := true;

		// �������������� ����������� ������:
		if (length(res.Strings[6]) > 0) then
			try
				order.prior_CrewId := StrToInt(res.Strings[6]);
			except
				order.prior_CrewId := -1;
			end
		else
			order.prior_CrewId := -1; // ����������, ���� ���

		// ���-�� ��������. ���������
		if (length(res.Strings[7]) > 0) then
			try
				order.count_int_stops := StrToInt(res.Strings[7]);
			except
				order.count_int_stops := 0;
			end
		else
			order.count_int_stops := 0; // ����������, ���� ���

		if (length(res.Strings[8]) > 0) then
			try
				order.raw_price := dotStrtoFloat(res.Strings[8]);
				order.raw_dist_way := order.raw_price / RUB_ZA_KM;
			except
				order.raw_price := -1.0;
				order.raw_dist_way := -1.0;
			end
		else
			order.raw_dist_way := -1.0;
		// ����������, ���� ���

		if (length(res.Strings[9]) > 0) then
			try
				order.raw_int_stops := res.Strings[9];
			except
				order.raw_int_stops := '';
			end
		else
			order.raw_int_stops := ''; // ����������, ���� ���

		order.customer := res.Strings[11];
		order.phone := res.Strings[12];
	end;

	// ������ ���������� �������
	self.get_adres_coords();

	// ������� ������ ������
	self.del_bad_orders();

	// ��������� �� ������� ������:
	// �� ����� - ���� ���������� �� �������� ���!!!!!!!!!!!!!!!!
	// self.Orders.Sort(sort_orders_by_source_time);

	FreeAndNil(sl);
	FreeAndNil(res);
	exit(0);
end;

function TOrderList.get_sort_col : Integer;
begin
	result := self.sort_col;
end;

procedure TOrderList.hide_buttons_send_to_robocab;
var pp : Pointer;
begin
	for pp in self.Orders do
		TOrder(pp).hide_button_send_to_robocab();
end;

function TOrderList.is_defined(OrderId : Integer) : boolean;
var pp : Pointer;
begin
	for pp in self.Orders do
		if self.order(pp).ID = OrderId then
			exit(true);
	exit(false);
end;

function TOrderList.order(p : Pointer) : TOrder;
var i : Integer;
begin
	i := self.Orders.IndexOf(p);
	if (i > -1) then
		result := TOrder(self.Orders.Items[i])
	else
		result := nil;
end;

function TOrderList.orders_id_as_string : string;
var pp : Pointer;
begin
	result := '';
	for pp in self.Orders do
		if (not self.order(pp).deleted) and (self.order(pp).ID > 0) then
			result := result + ',' + IntToStr(self.order(pp).ID);
	if length(result) > 0 then
		Delete(result, 1, 1);
end;

function TOrderList.orders_time_to_end_count : Integer;
var te : Integer; pp : Pointer;
	order : TOrder;
begin
	result := 0;
	for pp in self.Orders do
	begin
		try
			order := TOrder(pp);
			if order.destroy_flag or order.deleted //
				or (order.CrewID < 0) then
				pass()
			else
			begin
				if (order.time_to_end = ORDER_AN_OK) //
					or (order.time_to_end >= 0) then
					result := result + 1;
			end;
		except
			pass();
		end;
	end;
end;

function TOrderList.ret_free_order : Pointer;
var pp : Pointer;
begin
	for pp in self.Orders do
		if TOrder(pp).ID = -1 then
			exit(pp);
	exit(nil);
end;

function TOrderList.ret_orders_as_grid(prior_flag : boolean; var slist : TstringList) : Integer;
var sort_str, s, s_crew : string; pp : Pointer; order : TOrder;
label end_for;
begin
	slist.Clear();
	slist.Sorted := true; // !!!

	for pp in self.Orders do
	begin
		try
			order := TOrder(pp);
		except
			continue;
		end;
		if order.is_bad() //
			or (prior_flag <> order.is_prior()) //
			then
			// goto end_for; // continue;
			pass()
		else
		begin

			s := IntToStr(order.ID); // 0
			s := s + '|' + order.status(); // 1
			s := s + '|' + order.time_to_end_as_string() // 2
				+ ' (' + time_without_date(order.datetime_of_time_to_ap) //
				+ '/' + time_without_date(order.datetime_of_time_to_end) + ')';
			s := s + '|' + order.state_as_string() // 3
			// �������� ������ � ����. �����������
				+ ifthen(order.count_int_stops > 0, '~', '');

			if order.CrewID > 0 then
			begin
				try
					s_crew := TCrewList(PMainCrewList).crewByCrewId(order.CrewID).name;
				except
					s_crew := '!!!CREW ERROR';
				end;
			end
			else
				s_crew := '!!!';
			s := s + '|' + s_crew;
			// 4
			s := s + '|' + order.source.get_as_color_string(); // 5
			s := s + '|' + order.dest.get_as_color_string(); // 6
			s := s + '|' + order.source_time_without_date(); // 7

			case self.sort_col of
				0 :
					sort_str := IntToStr(order.ID);
				1 :
					sort_str := order.status();
				3 :
					sort_str := order.state_as_string();
				4 :
					sort_str := s_crew;
				5 :
					sort_str := order.source.get_as_string(); // 5
				6 :
					sort_str := order.dest.get_as_string(); // 6
			else
				sort_str := order.source_time; // �� ��������� ��������� �� ������� ������
			end;

			s := sort_str + '|||' + s; // ������ ����������, ������������� ��� ������
			slist.Append(s); // !

		end;
end_for : // ����� ������ ������
	end;

	result := slist.count;
end;

procedure TOrderList.set_sort_col(col : Integer);
begin
	self.sort_col := col;
end;

{ TOrderCrews }

// constructor TOrderCrews.Create(var IBQuery : TIBQuery; ordId : Integer);
// begin
// inherited Create();
// self.OrderId := ordId;
// self.crew_list.Create(IBQuery);
// end;

{ TCar }

function TCar.is_moved : boolean;
var crew : TCrew;
begin
	result := false;
	if self.PCrew = nil then
		exit()
	else
		try
			crew := TCrew(self.PCrew);
		except
			exit();
		end;
	if self.car_coord = '' then
	begin
		self.car_coord := crew.coord;
		if self.car_coord = '' then
			exit(false)
		else
			exit(true);
	end;
	result := get_dist_from_coord(self.car_coord, crew.coord) > CREW_MOVE_DIST;
end;

function TCar.opozdanie : Integer;
var dt : TDateTime;
begin
	result := -1;
	if self.time_to_ap < 0 then
		exit();
	dt := IncMinute(now(), self.time_to_ap);
	if dt > self.ap_source_time then
		result := MinutesBetween(dt, self.ap_source_time)
	else
		result := 0;
end;

function TCar.approximate_dist_way : double;
var d : double;
begin
	result := -1.0;
	d := self.dist_to_ap();
	if d < 0 then
		exit();
	result := (d * 1.3) / 1000;
end;

function TCar.approximate_opozdaet : boolean;
var dt, ap_dt : TDateTime;
	app_time : Integer;
begin
	result := false;
	app_time := self.approximate_time_po_pryamoy();
	if app_time < 0 then
		exit();
	dt := IncMinute(now(), app_time);
	ap_dt := IncMinute(self.ap_source_time, 30);
	result := dt > ap_dt;
end;

function TCar.approximate_time : Integer;
begin
	result := self.approx_time(false);
end;

function TCar.approximate_time_po_pryamoy : Integer;
begin
	result := self.approx_time(true);
end;

function TCar.approx_time(flag_po_pryamoy : boolean) : Integer;
var crew : TCrew;
	dw : double;
	dob : Integer;
begin
	result := -1;
	if self.PCrew = nil then
		exit()
	else
		try
			crew := TCrew(self.PCrew);
		except
			exit();
		end;
	if not(crew.real_state in [CREW_SVOBODEN, CREW_NAZAKAZE]) then
		exit();

	if flag_po_pryamoy then
	begin
		dw := self.dist_to_ap();
		if dw > 0 then
			dw := dw / 1000;
	end
	else
		dw := self.approximate_dist_way();

	if dw < 0 then
		exit();
	result := round(60 * dw / speed_list.average_speed());
	dob := crew.order_time_to_end();
	if crew.real_state() = CREW_NAZAKAZE then
	begin
		if dob >= 0 then
			result := result + dob
		else
			result := -1;
	end;
end;

procedure TCar.Clear;
begin
	self.PCrew := nil;
	// self.dist_to_ap := -1.0;
	self.dist_way_to_ap := -1.0;
	self.raw_dist_way := -1.0;
	self.time_to_ap := -1;
	self.crew_state := -1;
	self.car_coord := '';
end;

constructor TCar.Create;
begin
	inherited Create();
	self.ap := TAdres.Create('', '', '', '');
	self.from := TAdres.Create('', '', '', '');

	self.way_to_ap := TWay.Create();
	self.way_to_ap.zapros.browser.OnNavigateComplete2 := self.set_time_to_ap;

	self.Clear();
end;

procedure TCar.def_time_to_ap;
var st : Integer;
begin
	if self.way_to_ap.zapros.get_flag_zapros() then
		exit();
	try
		st := TCrew(self.PCrew).state;
	except
		exit();
	end;
	if (self.time_to_ap > 0) //
		and (self.crew_state = st) //
		and (not self.is_moved()) //
		then
		exit();

	if self.approximate_opozdaet() then
		exit();
	self.def_way_to_ap();
	if self.way_to_ap.points.count < 2 then
		exit();

	self.crew_state := st;
	self.way_to_ap.get_way_time_dist_unlim();
end;

procedure TCar.def_way_to_ap;
var
	crew : TCrew;
	coo : string;
begin
	if (self.PCrew = nil) or self.way_to_ap.zapros.get_flag_zapros() then
		exit();

	self.way_to_ap.points.Clear();

	if not self.ap.gps_ok() then
	begin
		self.ap.get_gps_unlim();
		exit();
	end;

	try
		crew := TCrew(self.PCrew);
		if not(crew.real_state() in [CREW_SVOBODEN, CREW_NAZAKAZE]) then
			exit();
		coo := crew.coord_depend_state();
		if coo = '' then
			exit();
	except
		exit();
	end;

	from.setAdres('', '', '', coo);
	self.way_to_ap.points.Add(Pointer(self.from));
	self.way_to_ap.points.Add(Pointer(self.ap));
end;

destructor TCar.Destroy;
begin
	self.ap.Free();
	self.from.Free();
	self.way_to_ap.Free();
	self.PCrew := nil;
	inherited;
end;

function TCar.dist_to_ap : double;
var crew : TCrew;
	coo : string;
begin
	result := -1.0;
	if not(self.ap.gps_ok()) then
		exit();
	if self.PCrew = nil then
		exit()
	else
		try
			crew := TCrew(self.PCrew);
		except
			exit();
		end;

	coo := crew.coord_depend_state();
	if coo = '' then
		exit();
	result := get_dist_from_coord(coo, self.ap.gps);
end;

function TCar.ret_data : string;
var
	crew : TCrew;
	s_opozdanie, scolor, prefix, res, rasxod, line_num, pref_r, pref_l, sdebug : string;
	dt : TDateTime;
	opozdanie, dob : Integer;
	approx_time, buf_time : Integer;
	approx_dist_way, buf_dist_way : double;
	approx_flag : boolean;

	function pererasxod() : Integer;
	var r : double;
	begin
		result := -1;
		if (self.dist_way_to_ap < 0) or (self.dist_to_ap < 0) then
			exit();

		r := self.raw_dist_way / 2.0;

		if self.dist_way_to_ap < r then
			exit(0)
		else
			if self.dist_way_to_ap < 10.0 then
				exit(1)
			else
				exit(2);
	end;

	function pererasxod_color() : string;
	begin
		result := '';
		// FloatToStrF(self.rasxod, ffFixed, 8, 1);
		case pererasxod() of
			0 :
				result := '*' + result;
			1 :
				result := '!' + result;
			2 :
				result := '!!!' + result;
		else
			result := '#' + result;
		end;
	end;

	function line_number_color : string;
	begin
		result := ifthen(pos('-2', crew.Code) > 0, '!    2', '*    1');
	end;

	function time_str : string;
	begin
		if self.time_to_ap < 0 then
			result := IntToStr(approx_time)
		else
			result := IntToStr(self.time_to_ap);
		// if self.time_to_ap < 0 then
		// result := '99999999'
		// else
		while length(result) < 8 do
			result := '0' + result;
	end;

	function time_to_str(time : Integer) : string;
	begin
		result := IntToStr(time mod 60) + ' ���.';
		if time > 59 then
			result := IntToStr(time div 60) + ' �. ' + result;
	end;

	function dist_str : string;
	begin
		if self.dist_to_ap < 0 then
			exit('99999999');
		result := FloatToStrF(self.dist_to_ap / 1000, ffFixed, 8, 1) + '��';
		while length(result) < 8 do
			result := ' ' + result;
	end;

	function dist_way_as_string : string;
	begin
		if self.dist_way_to_ap < 0 then
			result := '# - '
		else
			result := FloatToStrF(self.dist_way_to_ap, ffFixed, 8, 1) + ' ��';
	end;

	function dist_way_str : string;
	begin
		if self.dist_way_to_ap < 0 then
			exit('99999999');
		result := FloatToStrF(self.dist_way_to_ap, ffFixed, 8, 1);
		while length(result) < 8 do
			result := '0' + result;
	end;

begin
	result := '';
	if self.PCrew = nil then
		exit()
	else
		try
			crew := TCrew(self.PCrew);
		except
			exit();
		end;

	approx_dist_way := self.approximate_dist_way();
	approx_time := self.approximate_time();
	if (approx_time < 0) or (approx_dist_way < 0) then
		exit();

	approx_flag := self.time_to_ap < 0;
	if approx_flag then
	begin
		buf_time := self.time_to_ap;
		buf_dist_way := self.dist_way_to_ap;
		self.time_to_ap := approx_time;
		self.dist_way_to_ap := approx_dist_way;
	end;

	line_num := line_number_color();
	rasxod := pererasxod_color();
	pref_l := ifthen(line_num[1] = '*', '#', '&');
	pref_r := ifthen((rasxod[1] in ['*', '!']) and (pos('!!!', rasxod) = 0), '#', '&');

	dt := IncMinute(now(), self.time_to_ap);
	// ap_dt := source_time_to_datetime(source_time);
	opozdanie := MinutesBetween(self.ap_source_time, dt);
	s_opozdanie := time_to_str(opozdanie);
	if dt > self.ap_source_time then
	begin
		s_opozdanie := '�������� �� ' + s_opozdanie;
		if opozdanie < 10 then
		begin
			res := dist_way_str();
			scolor := '!';
			prefix := '#' + pref_r + ifthen(pref_r = '#', pref_l, '_');
			// ������ � ����������� !
		end
		else
		begin
			res := time_str();
			scolor := '!!! ';
			prefix := '&&&';
		end;
	end
	else
	begin
		s_opozdanie := '�������� � ������� ' + s_opozdanie;
		prefix := '#' + pref_r + ifthen(pref_r = '#', pref_l, '_');
		res := dist_way_str();
		scolor := '*';
	end;

	if approx_flag then
	begin
		scolor := '^';
		// rasxod := '^';
		// prefix := '___';   �������� !!!!
		res := time_str(); // dist_str();
	end;

	result := '' //
		+ prefix + res //
		+ '$' + dist_str() //
		+ '|' + crew.Code //
		+ '||' + crew.state_as_string() //
		+ '|||' + scolor + s_opozdanie //
		+ '||||' + rasxod + dist_way_as_string() //
		+ '|||||' + rasxod //
		+ '||||||' + line_num //
	// + '|||||||' + sdebug //
		;

	if approx_flag then
	begin
		self.time_to_ap := buf_time;
		self.dist_way_to_ap := buf_dist_way;
	end;

	sdebug := //
		'(' //
		+ '~' + IntToStr(approx_time) + '���.' //
		+ '/' + IntToStr(self.time_to_ap) + '���.' //
		+ ')' //
		+ '(' //
		+ '~' + FloatToStrF(approx_dist_way, ffFixed, 8, 1) + '��' //
		+ '/' + FloatToStrF(self.dist_way_to_ap, ffFixed, 8, 1) + '��' //
		+ ')' //
		;
	if self.ap.zapros.get_flag_zapros() then
		sdebug := '!' + sdebug;

	result := result //
		+ '|||||||' + sdebug;
end;

procedure TCar.set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
var dob : Integer; order : TOrder; crew : TCrew;
begin
	self.way_to_ap.set_way_time_dist(ASender, pDisp, url);
	self.time_to_ap := -1;
	self.dist_way_to_ap := -1;
	try
		crew := TCrew(self.PCrew);
		if crew.last_porder() <> nil then
			order := TOrder(crew.last_porder())
		else
			order := nil;
	except
		exit();
	end;

	if not(crew.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) then
		exit();

	dob := 0;
	if (crew.state = CREW_NAZAKAZE) then
	begin
		try
			dob := crew.order_time_to_end();
		except
			dob := -1;
		end;
	end;

	if dob < 0 then
		exit();

	if (self.way_to_ap.time < 0) then
		exit()
	else
	begin
		self.time_to_ap := self.way_to_ap.time + dob;
		self.dist_way_to_ap := self.way_to_ap.dist_way;
		self.car_coord := crew.coord;
	end;
end;

end.
