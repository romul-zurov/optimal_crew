unit crew;

interface

uses crew_utils, // utils from robocap and mine
	crew_globals, // my global var and function
	Generics.Collections, // for forward class definition
	Controls, Forms, Classes, SysUtils, Math, SHDocVw, MSHTML, ActiveX, //
	IBQuery, DB, WinInet, StrUtils, DateUtils;

function sort_crews_by_state_dist(p1, p2 : Pointer) : Integer;
function sort_crews_by_time(p1, p2 : Pointer) : Integer;
function sort_crews_by_crewid(p1, p2 : Pointer) : Integer;
function sort_orders_by_source_time(p1, p2 : Pointer) : Integer;

type
	TCrewList = class;

	TOrder = class(TObject)
		ID : Integer; // order main ID in ORDERS table, -1 if not defined
		CrewID : Integer; // crew ID for a order, -1 if not defined
		// want_CrewId : Integer; // желаемый экипаж на заказе - НЕ НУЖЕН!
		prior_CrewId : Integer; // предварительный экипаж на предвар. заказе
		prior : boolean; // признак предварительного заказа
		state : Integer; // -1 - not defined, 0 - принят, маршрут задан
		// .                 1 - в работе, 2 - выполнен;
		source : TAdres; // address from
		source_raw : string; // address from raw-format
		dest : TAdres; // address to
		dest_raw : string; // address to raw-format
		source_time : string; // время подачи экипажа
		time_to_end : Integer; // время до окончания заказа в минутах
		datetime_of_time_to_end : TDateTime; // момент, когда считалось время до окончания
		// нужно для отладки
		time_to_ap : Integer; // время до подъезда к адресу подачи в минутах
		datetime_of_time_to_ap : TDateTime; // момент, когда считалось время до ап
		deleted : boolean; // признак удалённого или отменённого заказа
		query : TIBQuery;
		points_ap : TList;
		points_end : TList;
		way_to_ap : TWay;
		way_to_end : TWay;
		stops_time : Integer; // время на остановки экипажа на заказе в минутах
		na_bortu : boolean; // признак, что клиент на борту при исполнении заказа
		pcrew : Pointer; // указатель на экипаж, нужен в def_time_to_end и set_time_to_end

		stop_int_count : Integer; // количество промежуточных остановок в заказе
		destroy_flag : boolean; // флаг, что заказ можно удалять из списка
		destroy_time : string; // время, когда установлен флаг удаления. заказ
		// будет удалён через ORDER_DESTROY_TIME

		// form : TFormOrder; // form to show order

		// crews_list : TCrewList;

		constructor Create(OrderId : Integer; var IBQuery : TIBQuery);
		destructor Destroy(); override;
		procedure def_time_to_end(var pcrew : Pointer);
		procedure def_time_to_ap(var pcrew : Pointer);
		// function get_time_to_end(var PCrew : Pointer) : Integer;
		// function get_time_to_ap(var PCrew : Pointer) : Integer;
		function get_order_data() : string;
		function time_to_end_as_string() : string; // время до окончания заказа в виде часы-минуты;
		function time_to_ap_as_string() : string; // время до подъезда к АП в мин/часах;
		// function color
		function state_as_string() : string;
		function status() : string;
		function source_time_without_date() : string;
		function is_not_prior() : boolean;
	private
		// brow_comp_eve : TBrowserComplete2Event;
		procedure set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		procedure set_time_to_end(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		function time_as_string(time : Integer) : string;
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
		function Append(OrderId : Integer) : Pointer;
		function get_current_orders() : TStringList;
		function get_crews_id_as_string() : string;
		function del_bad_orders() : Integer;
		function get_orders_data() : TStringList;
	end;

	TCrew = class(TObject)
		CrewID : Integer;
		GpsId : Integer;
		state : Integer; // состояние: 1 - свободен, 3 - на заказе;
		Code : string;
		name : string;
		coord : string; // текущая (самая свежая) координата GPS
		old_coord : string; // предыдущая координата
		dist : double; // расстояние до адреса подачи (АП) радиальное, по прямой, метров;
		dist_way : double; // длина маршрута до АП, км;

		time : Integer; // время подъезда к АП в минутах;
		coords : TStringList; // gps-трек за выбранный промежуток времени;
		coords_times : TStringList; // gps-трек за выбранный промежуток времени;
		// coord_list : TStringList;
		OrderId : Integer; // ID заказа занятого экипажа
		order_way : string; // маршрут занятого экипажа

		source : TAdres; // address_from for state==3
		dest : TAdres; // address_to for state==3
		ap : TAdres; // адрес подачи экипажа
		way_to_ap : TWay;
		cur_pos : TAdres; // тек. положение экипажа
		points : TList;
		POrder : Pointer; // указатель на заказ

		constructor Create(GpsId : Integer);
		destructor Destroy(); override;
		function state_as_string() : string;
		function time_as_string() : string; // в виде часы-минуты
		function dist_way_as_string() : string;
		function set_current_coord() : Integer;
		function sort_coords_by_time_desc() : Integer;
		function del_old_coords() : Integer;
		function append_coords(coord : string; time : string) : Integer;
		function was_in_coord(coord : string) : boolean;
		function now_in_coord(coord : string) : boolean;
		function is_moved() : boolean; // сместился более чем на...
		procedure calc_dist(coord : string);
		procedure set_time(m : Integer; d : double); // set time and time_as_string;
		function get_time(var List : TOrderList; newOrder : boolean) : Integer;
		function get_time_for_ap(var o_list : TOrderList; n_ap : TAdres) : Integer;
		procedure show_status(s : string);
		procedure reset_old_coord();
		function ret_data() : string;
		function ret_data_to_ap(source_time : string) : string;
		procedure def_time_to_ap(var polist : Pointer);
	private
		function time_to_str(time : Integer) : string;
		function time_str() : string; // в виде '00000056'
		function dist_way_str() : string; // в виде '000015.6' для сортировки TStringList.sort()
		function dist_str() : string;
		procedure set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
	end;

	TCrewList = class(TObject)
		Crews : TList;
		query : TIBQuery;

		ap_street : string;
		ap_house : string;
		ap_korpus : string;
		ap_gps : string;

		meausure_time : string; // время выборки координат из базы

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
		// function del_all_none_coord() : Integer;
		function set_crewId_by_gpsId(List : TStringList) : Integer;
		function set_crews_orderId(List : TStringList) : Integer;
		function set_crews_state_by_crewId(var List : TStringList) : Integer;
		function set_current_crews_coord() : Integer;
		function set_crews_dist(coord : string) : Integer;
		function set_ap(street, house, korpus, gps : string) : Integer;
		function clear_crew_list() : Integer;
		function get_crew_list_by_crewid_string(screws_id : string) : TStringList;
		function get_crew_list_by_order_list(var List : TOrderList) : TStringList;
		function get_crew_list_for_ap(new_ap : TAdres; Order_ID : Integer) : TStringList;
		function get_crew_list() : TStringList;
		function set_crews_data(List : TStringList) : Integer;
		function get_crews_coords() : Integer;
		function ret_crews_stringlist() : TStringList;
	private
		function findById(ID : Integer; gps : boolean) : Pointer;
		function get_id_list_as_string(gps : boolean) : string;
		// function del_all_non_work_crews() : Integer;
		// function del_all_none_orderId() : Integer;
		function del_crews_old_coords() : Integer;
		procedure set_crews_orderId_by_order_list(var List : TOrderList);
	end;

	// TOrderCrews = class(TObject)
	// OrderId : Integer;
	// crew_list : TCrewList;
	// constructor Create(var IBQuery : TIBQuery; ordId : Integer);
	// end;

implementation

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
			if (id1 < id2) then // если время подачи совпадает сортируем по OrderID
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
	c1 := TCrew(p1); c2 := TCrew(p2);
	id1 := c1.CrewID; id2 := c2.CrewID;
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
	c1 := TCrew(p1); c2 := TCrew(p2);
	t1 := c1.time; t2 := c2.time;
	d1 := c1.dist_way; d2 := c2.dist_way;
	if (t1 < t2) then
		exit(-1)
	else
		if (t1 > t2) then
			exit(1)
		else
			if (d1 < d2) then // если время равно, сравниваем длину маршрута
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
	c1 := TCrew(p1); c2 := TCrew(p2);
	d1 := c1.dist; d2 := c2.dist;
	{
	  // состояние не учитываем нафиг
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

{ TCrew }

function TCrew.append_coords(coord, time : string) : Integer;
begin
	self.coords.Append(coord);
	self.coords_times.Append(time);
	exit(0);
end;

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
	if (self.state = CREW_NAZAKAZE) { and (self.POrder <> nil) } then
	begin
		// если экипаж на заказе, то расстояние меряем от точки высадки
		if self.POrder <> nil then
			try
				order := TOrder(self.POrder);
				if (order.time_to_end = ORDER_AN_OK) then
					// заказ РЕАЛЬНО завершён, но водитель ещё не мяфкнул
					// считаем экипаж свободным и меряем от текущей координаты
					coord_from := self.coord
				else
					if (order.time_to_end >= 0) and (order.dest.gps_ok()) then
						coord_from := TOrder(self.POrder).dest.gps;
			except
				coord_from := ''; // на всякий случай
			end;
	end
	else
		coord_from := self.coord;

	// if coord_from = '' then
	// coord_from := self.coord;

	if coord_from = '' then
		exit()
	else
		self.dist := get_dist_from_coord(coord, coord_from);
end;

constructor TCrew.Create(GpsId : Integer);
begin
	inherited Create;
	self.GpsId := GpsId;
	self.coords := TStringList.Create;
	self.coords_times := TStringList.Create;
	self.CrewID := -1;
	self.state := -1; // состояние: 1 - свободен, 3 - на заказе;
	self.Code := '';
	self.name := '';
	// self.state_as_string := '';
	self.coord := ''; // текущая (самая свежая) координата GPS
	old_coord := ''; // предыдущая координата
	self.dist := -1.0; // расстояние до адреса подачи (АП)
	self.time := -1; // время подъезда к АП в минутах;
	self.OrderId := -1; // ID заказа занятого экипажа
	self.order_way := ''; // маршрут занятого экипажа

	source := TAdres.Create('', '', '', ''); // address from
	dest := TAdres.Create('', '', '', ''); // address to
	ap := TAdres.Create('', '', '', ''); // адрес подачи
	self.way_to_ap := TWay.Create();
	self.way_to_ap.zapros.browser.OnNavigateComplete2 := self.set_time_to_ap;
	self.points := TList.Create();
	self.cur_pos := TAdres.Create('', '', '', '');
	self.POrder := nil;
end;

procedure TCrew.def_time_to_ap(var polist : Pointer);
begin
	if //
		not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
	// считаем только свободные и занятые экипажи, исключая нерабочие и т.п.
		or (self.coord = '') // если нет текущей коорд.
		or (self.ap.isEmpty()) // если хреновый адрес подачи
		then
	begin
		self.set_time(-1, -1);
		exit();
	end;
	self.cur_pos.setAdres('', '', '', self.coord); // начало маршрута - текущая координата машины
	self.points.Clear(); // список точек маршрута
	if self.state = CREW_SVOBODEN then
	begin
		self.points.Add(Pointer(cur_pos));
		self.POrder := nil; // на случай всяких там инцестов в self.set_time_to_ap
	end
	else
	begin
		self.POrder := TOrderList(polist).find_by_Id(self.OrderId);
		self.points.Add(Pointer(TOrder(self.POrder).dest));
	end;

	self.points.Add(Pointer(self.ap));
	// вызываем расчёт
	self.way_to_ap.get_way_time_dist(self.points);
end;

function TCrew.del_old_coords : Integer;
var sdt : string;
	Count, i : Integer;
begin
	if DEBUG then
		exit(0); // для бэк-ап базы координаты не отбрасываем :)
	Count := ifthen(self.coords.Count < self.coords_times.Count, self.coords.Count, self.coords_times.Count);
	if (Count <= 0) then
		exit(-1);
	sdt := replace_time(COORDS_BUF_SIZE, now());
	for i := (Count - 1) downto 0 do
		if self.coords_times.Strings[i] < sdt then
		begin
			self.coords_times.Delete(i);
			self.coords.Delete(i);
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

	inherited;
end;

function TCrew.dist_str : string;
begin
	if self.dist < 0 then
		exit('99999999');
	// result := IntToStr(round(self.dist));
	result := FloatToStrF(self.dist / 1000, ffFixed, 8, 1) + 'км';
	while length(result) < 8 do
		result := ' ' + result;
end;

function TCrew.dist_way_as_string : string;
begin
	if self.dist_way < 0 then
		result := '# - '
	else
		result := FloatToStrF(self.dist_way, ffFixed, 8, 1) + ' км';
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
	stops_time : Integer; // время на остановки для экипажа на заказе
	order : TOrder;
begin
	if not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
	// .....считаем только свободные и занятые экипажи, исключая нерабочие и т.п.
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
	points := TList.Create(); // список точек маршрута
	cur_pos := TAdres.Create('', '', '', self.coord);
	// начало маршрута - текущая координата машины
	points.Add(Pointer(cur_pos));

	if self.state = CREW_NAZAKAZE then
	// если экипаж на заказе, то проверяем, был ли он в точках source и dest
	// если нет - добавляем их в маршрут и прибавляем время на остановки
	begin
		order := List.order(List.find_by_Id(self.OrderId));
		if (order.state <> ORDER_KLIENT_NA_BORTU) // клиент НЕ на борту
			and (not self.was_in_coord(get_set_gps(order.source))) // и водитель в АП не был ещё
			then
		begin
			// т.е. если экипаж ещё не забрал клиента
			points.Add(Pointer(order.source));
			points.Add(Pointer(order.dest));
			stops_time := stops_time + 10 + 3;
		end
		else
			if not self.was_in_coord(get_set_gps(order.dest)) then
			begin
				// если уже забрал, но не высадил
				points.Add(Pointer(order.dest));
				stops_time := stops_time + 3;
			end
			else
			begin
				// забрал-высадил, то делаем заказ завёршенным и экипаж свободным
				stops_time := -1; // см. далее
				self.state := CREW_SVOBODEN;
				order.CrewID := -1; // сбрасываем экипаж в заказе
				order.state := ORDER_DONE;
			end;
	end;

	if (not newOrder) and (stops_time = -1) then
		// если забрал-высадил и нет нового АП, то считаем заказ завёршенным
		result := 0
	else
	begin
		if newOrder then
			points.Add(Pointer(self.ap)); // конец маршрута - адрес подачи для нового заказа

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
	// ПОКА ТОЛЬКО РАБОЧИЕ!!!
		not(self.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
	// .....считаем только свободные и занятые экипажи, исключая нерабочие и т.п.
		or (self.coord = '') // если нет текущей коорд.
		or (n_ap.isEmpty()) // если хреновый адрес подачи
		then
	begin
		result := -1;
		self.set_time(-1, -1);
		exit(result);
	end;

	points := TList.Create(); // список точек маршрута
	cur_pos := TAdres.Create('', '', '', self.coord);
	// начало маршрута - текущая координата машины
	result := -1; // на случай неудавшегося просчёта
	if self.state = CREW_SVOBODEN then
	begin
		// просто считаем маршрут "экипаж -- АП"
		points.Add(Pointer(cur_pos)); // первая точка - экипаж
		points.Add(Pointer(n_ap)); // вторая - заданый АП
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
				// сначала определяем время до конца заказа:
				if order.time_to_end > -1 then
					t1 := order.time_to_end
				else
					// t1 := order.get_time_to_end(Pointer(self));
					if t1 > -1 then
					begin
						// теперь считаем время маршрута от конца текушего заказа до АП
						d1 := self.dist_way; points.Add(Pointer(order.dest));
						// от конца выполняемого заказа
						points.Add(Pointer(n_ap)); // вторая - заданый АП
						t2 := get_crew_way_time(points, d2);
						if t2 > -1 then
						begin
							result := t1 + t2; self.dist_way := d1 + d2;
						end;
					end;
			end;
		end;
	end;

	self.set_time(result, self.dist_way); // если result = -1, то и dist_way станет -1, если нет, то нет :)
	FreeAndNil(points);
end;

function TCrew.was_in_coord(coord : string) : boolean;
var cc : string; d : double;
begin
	for cc in self.coords do
	begin
		d := get_dist_from_coord(coord, cc);
		if (d >= 0) and (d < CREW_RADIUS) then
			exit(true);
	end; exit(false);
end;

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

function TCrew.now_in_coord(coord : string) : boolean;
begin
	if self.coord = '' then
		exit(false);
	result := get_dist_from_coord(coord, self.coord) < CREW_RADIUS;
end;

function TCrew.set_current_coord() : Integer;
var coord_stime, cur_stime : string;
begin
	if self.sort_coords_by_time_desc() < 0 then
		exit(-1);

	coord_stime := self.coords_times[0];
	cur_stime := replace_time(CREW_CUR_COORD_TIME, now());
	if coord_stime < cur_stime then
	begin
		// координата экипажа "устарела" на CREW_CUR_COORD_TIME минут и более
		self.coord := '';
		self.old_coord := '';
	end
	else
	begin
		self.coord := self.coords.Strings[0];
	end;
	exit(0);
end;

procedure TCrew.reset_old_coord;
begin
	self.old_coord := self.coord;
end;

function TCrew.ret_data : string;
begin
	result := '' //
		+ self.time_str + '$' // для сортировки по времени тупым stringlist.sort()
		+ IntToStr(self.CrewID) + '|' //
		+ self.name + '||' //
		+ self.state_as_string + '|||' //
		+ self.time_as_string + '||||' //
		+ self.dist_way_as_string;
end;

function TCrew.ret_data_to_ap(source_time : string) : string;
var s_opozdanie, scolor, prefix, res : string;
	dt, ap_dt : TDateTime;
	opozdanie : Integer;
begin
	{
	  result := '' //
	  // + self.time_str() + '$' // для сортировки по времени тупым stringlist.sort()
	  + self.dist_way_str() + '$' // для сортировки по времени тупым stringlist.sort()
	  + IntToStr(self.CrewID) + '|' //
	  + self.name + '||' //
	  + self.state_as_string() + '|||' //
	  ;
	  }
	if self.time < 0 then
	begin
		prefix := '_';
		res := self.dist_str();
		s_opozdanie := self.time_as_string();
		scolor := '';
	end
	else
	begin
		dt := IncMinute(now(), self.time);
		ap_dt := source_time_to_datetime(source_time);
		opozdanie := MinutesBetween(ap_dt, dt);
		s_opozdanie := self.time_to_str(opozdanie);
		if dt > ap_dt then
		begin
			s_opozdanie := 'опоздает на ' + s_opozdanie;
			if opozdanie < 10 then
			begin
				res := self.dist_way_str();
				scolor := '!';
				prefix := '#'; // вместе с успевающими !
			end
			else
			begin
				res := self.time_str();
				scolor := '!!! ';
				prefix := '&';
			end;
		end
		else
		begin
			s_opozdanie := 'успевает с запасом ' + s_opozdanie;
			prefix := '#';
			res := self.dist_way_str();
			// if opozdanie < 10 then
			// scolor := '! '
			// else
			scolor := '*';
		end;
	end;
	result := '' //
		+ prefix //
		+ res + '$' //
	// + IntToStr(self.CrewID) + '|' //
		+ self.dist_str() + '|' // !!!
		+ self.name + '||' //
		+ self.state_as_string() + '|||' //
		+ scolor + s_opozdanie //
		+ '||||' //
		+ scolor + self.dist_way_as_string();
end;

procedure TCrew.set_time(m : Integer; d : double);
begin
	self.time := m;
	if m < 0 then
		self.dist_way := -1
	else
		self.dist_way := d;
end;

procedure TCrew.set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
var dob : Integer;
	// dob2 : double; // при подборе экипажа для экипажа "на заказе" длинц пути
	// учитываем только от точки высадки до АП, не прибавляя текущий путь!
begin
	self.way_to_ap.set_way_time_dist(ASender, pDisp, url);

	dob := 0;
	if (self.state = CREW_NAZAKAZE) and (self.POrder <> nil) then
		// для экипажа "на заказе добавляем время до окончания тек. заказа
		try
			dob := TOrder(self.POrder).time_to_end;
		except
			dob := 0; // на всякий случай :)
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

function TCrew.sort_coords_by_time_desc : Integer;
var sl : TStringList; s : string; Count, i : Integer;
begin
	Count := ifthen(self.coords.Count < self.coords_times.Count, self.coords.Count, self.coords_times.Count);
	if (Count <= 0) then
		exit(-1);
	sl := TStringList.Create();
	sl.Duplicates := dupIgnore; // не допускаем дубликатов
	sl.Sorted := true;
	for i := 0 to (Count - 1) do
		sl.Append(self.coords_times.Strings[i] + '|' + self.coords.Strings[i]);
	reverseStringList(sl);
	self.coords.Clear(); self.coords_times.Clear();
	for s in sl do
	begin
		self.coords_times.Append(get_substr(s, '', '|'));
		self.coords.Append(get_substr(s, '|', ''));
	end; FreeAndNil(sl); exit(0);
end;

function TCrew.state_as_string : string;
begin
	result := crew_states.Values[IntToStr(self.state)];
	result := StringReplace(result, '_', ' ', [rfReplaceAll]);
end;

function TCrew.time_as_string : string;
begin
	if self.time = ORDER_WAY_ERROR then
		exit('%расчёт не удался')
	else
		if self.time < 0 then
			exit('# - ');

	result := IntToStr(self.time mod 60) + ' мин.';
	if self.time > 59 then
		result := IntToStr(self.time div 60) + ' ч. ' + result;
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
	result := IntToStr(time mod 60) + ' мин.';
	if time > 59 then
		result := IntToStr(time div 60) + ' ч. ' + result;
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
	meausure_time := '';
	// время выборки координат из базы
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

// function TCrewList.del_all_none_coord : Integer;
// var pp : Pointer;
// begin
// for pp in self.Crews do
// if (self.crew(pp).coord = '') then
// self.Crews.Delete(self.Crews.IndexOf(pp));
// exit(0);
// end;

function TCrewList.del_all_none_crewId : Integer;
var pp : Pointer; i : Integer;
begin
	for i := self.Crews.Count - 1 downto 0 do
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

// function TCrewList.del_all_none_orderId() : Integer;
// var pp : Pointer;
// begin
// for pp in self.Crews do
// if (self.crew(pp).state = CREW_NAZAKAZE) then
// if (self.crew(pp).OrderId = -1) then
// self.Crews.Delete(self.Crews.IndexOf(pp));
// exit(0);
// end;

// function TCrewList.del_all_non_work_crews : Integer;
// var pp : Pointer;
// begin
// for pp in self.Crews do
// if self.crew(pp).state in [CREW_SVOBODEN, CREW_NAZAKAZE] then
// pass
// else
// self.Crews.Delete(self.Crews.IndexOf(pp));
// exit(0);
// end;

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
	for i := self.Crews.Count - 1 downto 0 do
		TCrew(self.Crews.Items[i]).Free();

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
var crew : TCrew; pcrew : ^TCrew;
begin
	result := nil;
	for pcrew in self.Crews do
	begin
		crew := TCrew(pcrew);
		if ((not gps) and (crew.CrewID = ID)) or (gps and (crew.GpsId = ID)) then
		begin
			result := pcrew; exit();
		end;
	end;
end;

function TCrewList.get_crewid_list_as_string : string;
begin
	result := self.get_id_list_as_string(false);
end;

function TCrewList.get_crews_coords() : Integer;
	function s_2_6(sc : string) : string;
	var n : double;
	begin
		n := dotStrtoFloat(sc);
		sc := FloatToStrF(n, ffFixed, 8, 6);
		sc := StringReplace(sc, ',', '.', [rfReplaceAll]);
		exit(sc);
	end;

	function coords_to_str(fields : TFields) : Integer;
	var field : TField; // main file
		j, l, ID, GpsId : Integer; b : TBytes; pint : ^Integer; plat, plong : ^single;
		s, scoords, slat, slong : string; date1, date2, date0 : TDateTime; crew : TCrew;
		pp : Pointer;
	begin
		date1 := fields[1].AsDateTime;
		date2 := fields[2].AsDateTime;
		field := fields[3];
		l := field.DataSize;
		setlength(b, l);
		// создаём условную дельту по времени для координат
		date0 := (date2 - date1) / (l div 12);
		b := field.AsBytes;
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
				crew.append_coords(scoords, date_to_full(date1));
			end;
			date1 := date1 + date0;
			j := j + 12;
		end;
		exit(0);
	end;

var sel : string; stime : string;
begin
	stime := replace_time(COORDS_BUF_SIZE, now());
	if (self.meausure_time = '') or (self.meausure_time < stime) then
		// если запроса координат не было слишком или был давно, то запрашиваем его
		// за период COORDS_BUF_SIZE
		self.meausure_time := stime;

	stime := '''' + self.meausure_time + ''''; // время запроса координат
	// теперь сохраняем текущее время для следующей выборки
	self.meausure_time := date_to_full(now()); // replace_time('{Last_minute_0}', now());

	if DEBUG then
		stime := DEBUG_MEASURE_TIME; // for back-up DB

	sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS ' //
		+ 'from CREWS_COORDS ' //
		+ ' where MEASURE_START_TIME > ' + stime //
	// + ' order by MEASURE_START_TIME ASC, ID ASC';
		;

	// sql_select(self.query, sel);
	// вместо ^^^^^^^^^^ делаем прямо по пунктам:
	self.query.Close();
	self.query.SQL.Clear();
	self.query.SQL.Add(sel);
	try
		self.query.Open();
	except
		show_status('неверный запрос GPS-координат из БД');
		exit(-1);
	end;
	// show_status('запрос произведён');

	while (not self.query.Eof) do
	begin
		coords_to_str(self.query.fields);
		self.query.Next();
	end;
	// ???
	self.query.Close();

	self.get_crew_list();
	self.set_current_crews_coord();
	self.del_crews_old_coords();
	self.del_all_none_crewId();
	exit(0);
end;

function TCrewList.get_crew_list_by_crewid_string(screws_id : string) : TStringList;
var sel : string;
begin
	result := TStringList.Create();
	if length(screws_id) = 0 then
		exit(result);
	sel := //
		'select CREWS.ID, CREWS.IDENTIFIER, CREWS.CODE, CREWS.NAME, CREWS.STATE ' //
		+ ' from CREWS ' //
		+ ' where ' //
		+ ' CREWS.ID in (' + screws_id + ') '; //
	result := get_sql_stringlist(self.query, sel); self.set_crews_data(result);
end;

function TCrewList.get_crew_list_by_order_list(var List : TOrderList) : TStringList;
var pp : Pointer;
	order : TOrder; crew : TCrew;
begin
	result := self.get_crew_list_by_crewid_string(List.get_crews_id_as_string());
	self.set_crews_orderId_by_order_list(List);
	for pp in List.Orders do
	begin
		order := List.order(pp);
		crew := self.crewByCrewId(order.CrewID);
		if (order <> nil) and (crew <> nil) then
		begin
			crew.source := order.source;
			crew.dest := order.dest;
			crew.POrder := Pointer(order);
		end;
	end;
end;

function TCrewList.get_crew_list_for_ap(new_ap : TAdres; Order_ID : Integer) : TStringList;
var
	crew : TCrew;
	i : Integer;

begin
	with new_ap do
		self.set_ap(street, house, korpus, gps);
	self.set_crews_dist(self.ap_gps);
	self.Crews.Sort(sort_crews_by_state_dist);
	result := TStringList.Create();

	for i := 0 to self.Crews.Count - 1 do
	begin
		crew := self.crew(self.Crews.Items[i]);

		// if //
		// (crew.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
		// and (crew.coord <> '') //
		// // отбрасываем экипаж, УЖЕ назначенный на заказ :)
		// and not((crew.state = CREW_NAZAKAZE) and (crew.OrderId = Order_ID)) //
		// then
		// result.Add(IntToStr(crew.CrewID));

		if //
			(crew.state in [CREW_SVOBODEN, CREW_NAZAKAZE]) //
			and (crew.coord <> '') //
			and (crew.dist >= 0) //
			then
			result.Add(IntToStr(crew.CrewID))
	end;
end;

function TCrewList.get_crew_list() : TStringList;
var sel, screws_gpsid : string;
begin
	screws_gpsid := self.get_gpsid_list_as_string(); // gpsId экипажей из списка
	if length(screws_gpsid) = 0 then
		exit(nil);
	sel := //
		'select CREWS.ID, CREWS.IDENTIFIER, CREWS.CODE, CREWS.NAME, CREWS.STATE ' //
		+ ' from CREWS ' //
		+ ' where ' //
		+ ' CREWS.IDENTIFIER in (' + screws_gpsid + ') ' // только экипажи из списка
	// + ' and CREWS.STATE in (1,3) '; // с состоянием "свободен" и "на заказе"
		;
	result := get_sql_stringlist(self.query, sel);
	self.set_crews_data(result);
	// self.del_all_none_crewId(); self.del_all_none_crewId(); // так работает :-/
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
	Delete(s, 1, 1); result := s;
end;

function TCrewList.get_nonfree_crewid_list_as_string() : string;
var s : string; pp : Pointer;
begin
	s := '';
	for pp in self.Crews do
		if (self.crew(pp).state = CREW_NAZAKAZE) and (self.crew(pp).CrewID > -1) then
			s := s + ',' + IntToStr(self.crew(pp).CrewID);
	if length(s) > 0 then
		Delete(s, 1, 1);
	exit(s);
end;

function TCrewList.isCrewIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, false);
end;

function TCrewList.isGpsIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, true);
end;

function TCrewList.ret_crews_stringlist : TStringList;
var pp : Pointer; crew : TCrew; s : string;
begin
	result := TStringList.Create();
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
				+ crew.dist_way_as_string; result.Append(s);
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

function TCrewList.set_crewId_by_gpsId(List : TStringList) : Integer;
var sl : TStringList; s : string;
	crew : TCrew;
begin
	sl := TStringList.Create();
	// sl.Delimiter := '|';
	for s in List do
	begin
		sl.Clear(); sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		crew := self.crewByGpsId(StrToInt(sl.Strings[0])); crew.CrewID := StrToInt(sl.Strings[1]);
		crew.Code := sl.Strings[2]; crew.name := sl.Strings[3];
		crew.state := StrToInt(sl.Strings[4]);
		// if crew.state = CREW_SVOBODEN then
		// crew.state_as_string := 'Свободен'
		// else
		// crew.state_as_string := 'На заказе';
	end;
	// self.del_all_none_crewId(); self.del_all_none_crewId();
	FreeAndNil(sl); exit(0);
end;

function TCrewList.set_crews_data(List : TStringList) : Integer;
var sl : TStringList; s : string;
	crew : TCrew; ID, GpsId : Integer;
begin
	sl := TStringList.Create();
	// sl.Delimiter := '|';
	for s in List do
	begin
		sl.Clear(); sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		ID := StrToInt(sl.Strings[0]); GpsId := StrToInt(sl.Strings[1]);
		if self.isGpsIdInList(GpsId) then
			crew := self.crewByGpsId(GpsId)
		else
			crew := self.crew(self.Append(GpsId));

		crew.CrewID := ID;
		crew.GpsId := GpsId;
		crew.Code := sl.Strings[2];
		crew.name := sl.Strings[3];
		crew.state := StrToInt(sl.Strings[4]);
		if crew.state = 11 then // "на заказе с бордюра" приравниваем к "свободен"
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

function TCrewList.set_crews_orderId(List : TStringList) : Integer;
var sl : TStringList; s : string;
	crew : TCrew;
begin
	sl := TStringList.Create();
	for s in List do
	begin
		sl.Clear();
		sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		crew := self.crewByCrewId(StrToInt(sl.Strings[0]));

		if (crew.OrderId <> -1) or (crew.state <> CREW_NAZAKAZE) then
			continue;
		// если уже назначен заказ, то пропускаем,
		// т.к. для экипажа на заказе м.б. несколько
		// заказов в состоянии исполнения

		// if sl.Strings[5] <> '' then
		// continue; // пропускаем заказы с промежуточными остановками;

		crew.OrderId := StrToInt(sl.Strings[1]);
		// sl.Strings[2]; // - пропускаем
		crew.order_way := sl.Strings[3] + ';' + sl.Strings[4];
	end;
	// self.del_all_none_orderId(); self.del_all_none_orderId();
	FreeAndNil(sl); exit(0);
end;

procedure TCrewList.set_crews_orderId_by_order_list(var List : TOrderList);
var order : TOrder;
	pp : Pointer;
begin
	for pp in List.Orders do
	begin
		order := List.order(pp);
		if self.isCrewIdInList(order.CrewID) then
		begin
			self.crewByCrewId(order.CrewID).OrderId := order.ID;
			self.crewByCrewId(order.CrewID).POrder := Pointer(order);
		end;
	end;
	// убираем сслыки на заказы у свободных экипажей
	for pp in self.Crews do
	begin
		if TCrew(pp).state = CREW_SVOBODEN then
			TCrew(pp).POrder := nil;
	end;
end;

function TCrewList.set_crews_state_by_crewId(var List : TStringList) : Integer;
// уже не нужен;
var s, sid, sstate : string; crew : TCrew;
begin
	for s in List do
	begin
		sid := get_substr(s, '', '|');
		sstate := get_substr(s, '|', ''); crew := self.crewByCrewId(StrToInt(sid));
		if crew.state = -1 then
			crew.state := StrToInt(sstate);
	end;
	// self.del_all_non_work_crews(); self.del_all_non_work_crews(); // мистика, но так работает :-/
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
var crew : TCrew; pp : Pointer;
begin
	for pp in self.Crews do
	begin
		crew := self.crew(pp);
		if ((not gps) and (crew.CrewID = ID)) or (gps and (crew.GpsId = ID)) then
			exit(true);
	end; exit(false);
end;

{ TOrder }

constructor TOrder.Create(OrderId : Integer; var IBQuery : TIBQuery);
begin
	inherited Create();
	self.ID := OrderId; self.CrewID := -1;
	// want_CrewId := -1; // желаемый экипаж на заказе - НЕ НУЖЕН
	self.prior_CrewId := -1; // предварительный экипаж на предвар. заказе
	self.prior := false; // признак предварительного заказа
	self.state := -1; // -1 - not defined, 0 - принят, маршрут задан
	// .                 1 - в работе, 2 - выполнен, остальное см. crew_globals;
	self.source := TAdres.Create('', '', '', ''); // address from
	self.source_raw := '';
	self.dest := TAdres.Create('', '', '', ''); // address to
	self.dest_raw := '';
	self.source_time := ''; // время подачи экипажа
	self.time_to_end := -1; // время до окончания заказа в минутах
	self.time_to_ap := -1; // время до подъезда к адресу подачи в минутах
	self.query := IBQuery;
	self.deleted := false;
	self.way_to_ap := TWay.Create();
	self.way_to_end := TWay.Create();
	self.points_ap := TList.Create();
	self.points_end := TList.Create();
	self.way_to_ap.zapros.browser.OnNavigateComplete2 := self.set_time_to_ap;
	self.way_to_end.zapros.browser.OnNavigateComplete2 := self.set_time_to_end;
	self.stops_time := 0;
	self.na_bortu := false;
	self.pcrew := nil;
	self.datetime_of_time_to_ap := IncHour(now(), -1);
	self.datetime_of_time_to_end := self.datetime_of_time_to_ap;
	self.stop_int_count := 0;
	destroy_flag := false; // флаг, что заказ можно удалять из списка
	destroy_time := '';
	// form := TFormOrder.Create(nil);
end;

procedure TOrder.def_time_to_ap(var pcrew : Pointer);
var cur_pos : TAdres;
	gps : string;
	d : double;
	// points : TList;
	// время на остановки для экипажа на заказе
	crew : TCrew;
	res : Integer;
begin
	// проверяем состояние заказа, возможен ли вообще расчёт
	if //
		(self.destroy_flag) // заказ отмечен на удаление
		or (pcrew = nil) //
	// or (self.state <> ORDER_VODITEL_PODTVERDIL) //
		or not(self.state in [ //
			ORDER_VODITEL_PODTVERDIL, //
		ORDER_PRIGLASITE_KILIENTA, ORDER_KLIENT_NE_VYSHEL, //
		ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
			]) //
		or (self.CrewID = -1) //
		or (self.source.isEmpty) //
		then
	begin
		self.time_to_ap := -1;
		exit();
	end;

	if self.time_to_ap = ORDER_AP_OK then
		// клиент забран, незачем считать его
		exit();

	crew := TCrew(pcrew);
	if crew = nil then
	begin
		self.time_to_ap := -1;
		exit();
	end;

	if (crew.coord = '') then
	begin
		self.time_to_ap := ORDER_CREW_NO_COORD;
		exit();
	end;

	if (self.time_to_ap < 0) // ещё не считалось
	// or (replace_time('Last_minute_1', now()) > self.datetime_of_time_to_ap) //
		or (MinutesBetween(now(), self.datetime_of_time_to_ap) > 0)
	// считалось и прошло больше минуты после расчёта
		then // тогда считаем, а иначе выходим и не считаем
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
	if gps = '' then // нет координаты у адреса подачи
	begin
		self.source.get_gps();
		exit();
	end;

	if (not crew.was_in_coord(gps)) then // водитель в АП не был ещё
	begin
		// заполняем точки маршрута
		cur_pos := TAdres.Create('', '', '', crew.coord);
		// начало маршрута - текущая координата машины
		self.points_ap.Clear(); // список точек маршрута
		self.points_ap.Add(Pointer(cur_pos));
		self.points_ap.Add(Pointer(self.source));
		// вызываем расчёт
		self.way_to_ap.get_way_time_dist(self.points_ap);
	end
	else
	begin
		// если уже был
		if crew.now_in_coord(gps) then
			// экипаж в настоящий момент находится в АП
			self.time_to_ap := 0
		else
			// был, но уехал, видимо, забрал клиента, ага :)
			self.time_to_ap := ORDER_AP_OK;
	end;
end;

procedure TOrder.def_time_to_end(var pcrew : Pointer);
var cur_pos : TAdres;
	gps : string;
	// points : TList;
	// stops_time : Integer;  - сделать self.stops_time
	// время на остановки для экипажа на заказе
	crew : TCrew;
	dobavka : Integer; // разность между текущим временем и временем подачи в минутах
	cur_dt, ap_dt : TDateTime;
	// na_bortu : boolean; - сделать self.na_bortu
begin
	if (self.destroy_flag) then // заказ отмечен на удаление, выходим нафиг
		exit();

	// проверяем состояние заказа, возможен ли вообще расчёт
	if not(self.state in [ //
			ORDER_VODITEL_PODTVERDIL, ORDER_KLIENT_NA_BORTU, //
		ORDER_PRIGLASITE_KILIENTA, ORDER_KLIENT_NE_VYSHEL, //
		ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
			]) //
		then
		exit();

	if self.time_to_end = ORDER_AN_OK then
		// заказ уже был завершён, незачем считать его
		exit();

	// проверяем назначенность экипажа и адресов
	if
	// (self.state in [ORDER_DONE, ORDER_CANCEL, ORDER_DISCONTNUED]) //
	// or
		(self.CrewID = -1) //
		or (self.source.isEmpty) //
		or (self.dest.isEmpty) //
		then
		exit();

	if self.stop_int_count > 0 then // заказы с промежут. остановками пока не обсчитываем
	begin
		self.time_to_end := ORDER_HAS_STOPS;
		exit();
	end;

	crew := TCrew(pcrew);
	if crew = nil then
		exit();

	if (crew.coord = '') then
	begin
		self.time_to_end := ORDER_CREW_NO_COORD;
		exit();
	end;

	if (self.time_to_end > 0) // уже считалось
		and (not crew.is_moved()) // и экипаж не переместился с просчёта на заданное расстояние
		then // то не пересчитываем, просто ждём, когда экипаж переедет
		exit();

	if self.dest.gps = '' then
	begin
		self.dest.get_gps();
		exit();
	end;

	cur_dt := now();
	ap_dt := source_time_to_datetime(self.source_time);
	if cur_dt < ap_dt then
		dobavka := MinutesBetween(cur_dt, ap_dt)
	else
		dobavka := 0;

	self.stops_time := 0;
	self.points_end.Clear(); // список точек маршрута
	cur_pos := TAdres.Create('', '', '', crew.coord);
	// начало маршрута - текущая координата машины
	self.points_end.Add(Pointer(cur_pos));

	// если экипаж на заказе, то проверяем, был ли он в точках source и dest
	// если нет - добавляем их в маршрут и прибавляем время на остановки
	self.na_bortu := false;
	// if (self.state <> ORDER_KLIENT_NA_BORTU) then // клиент НЕ на борту
	if (self.state = ORDER_VODITEL_PODTVERDIL) then // клиент НЕ на борту
	begin
		if self.time_to_ap = ORDER_AP_OK then
			self.na_bortu := true // клиент на борту и водятел УЕХАЛ уже с АП, не сменив статус!
		else
			if self.time_to_ap < 0 then
				exit() // ошибка либо не считалось
			else
				if self.time_to_ap = 0 then // водитель на месте и ждёт
				begin
					self.na_bortu := true;
					self.stops_time := dobavka + 10;
				end
				else // определяем точки и паузу
				begin
					self.points_end.Clear(); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					self.points_end.Add(Pointer(self.source));
					self.points_end.Add(Pointer(self.dest));
					self.stops_time := ifthen(dobavka > self.time_to_ap, dobavka, self.time_to_ap);
					self.stops_time := self.stops_time + 10 + 3;
				end;

		{
		  gps := self.source.gps;
		  if gps = '' then // нет координаты у адреса подачи
		  begin
		  self.source.get_gps();
		  self.dest.get_gps(); // всё равно нужна будет, так что...
		  exit();
		  end;

		  if (not crew.was_in_coord(gps)) then // и водитель в АП не был ещё
		  // т.е. если экипаж ещё не забрал клиента
		  begin
		  self.points_end.Add(Pointer(self.source));
		  self.points_end.Add(Pointer(self.dest));
		  self.stops_time := self.stops_time + dobavka + 10 + 3; // !!!!!!!!!!!!!!!!!!!!!
		  end
		  else
		  begin
		  self.na_bortu := true;
		  if crew.now_in_coord(gps) then
		  // если водитель ожидает клиента, накидываем время на ожидание
		  self.stops_time := self.stops_time + dobavka + 10; // !!!!!!!!!!!!!!!!!!!!!
		  end;
		  }
	end
	else
		if (self.state in [ //
				ORDER_PRIGLASITE_KILIENTA, ORDER_KLIENT_NE_VYSHEL, //
			ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
				]) //
			then
		begin
			// если водитель ожидает клиента, накидываем время на ожидание
			self.na_bortu := true;
			self.stops_time := dobavka + 10;
		end;

	// если уже забрал, но не высадил
	if (self.na_bortu) or (self.state = ORDER_KLIENT_NA_BORTU) then
	begin
		gps := self.dest.gps;
		if pos('Error', gps) > 0 then
		begin
			self.dest.gps := '';
			self.time_to_end := ORDER_BAD_ADRES;
			exit();
		end;
		if gps = '' then // нет координаты у адреса высадки
		begin
			self.dest.get_gps();
			exit();
		end;

		if not crew.was_in_coord(gps) then // ещё не высадил
		begin
			self.points_end.Add(Pointer(self.dest));
			self.stops_time := self.stops_time + 3;
		end
		else
		begin
			if crew.now_in_coord(gps) then
				// высаживает
				self.time_to_end := 0
			else
				// забрал-высадил, то делаем заказ завёршенным и экипаж свободным
				self.time_to_end := ORDER_AN_OK;

			// self.state := ORDER_DONE;
			// self.CrewID := -1; // сбрасываем экипаж в заказе
			self.stops_time := 0;
			// crew.OrderId := -1;
			// crew.state := CREW_SVOBODEN;
			exit();
		end;
	end;

	self.pcrew := pcrew;
	self.datetime_of_time_to_end := now(); // засекаем момент взятия времени
	self.way_to_end.get_way_time_dist(self.points_end);
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

	self.points_ap.Free();
	self.points_end.Free();

	self.pcrew := nil;

	inherited;
end;

function TOrder.get_order_data() : string;
var sel, s, h, k : string; res : TStringList;
begin
	// CrewID : Integer; // crew ID for a order, -1 if not defined
	// state : Integer; // -1 - not defined, 0 - принят, маршрут задан
	// // .                 1 - в работе, 2 - выполнен;
	// source : TAdres; // address from
	// dest : TAdres; // address to
	// source_time : string; // время подачи экипажа
	// time_to_end : Integer; // время до окончания заказа в минутах
	// time_as_string : string; // оно же в виде часы-минуты;

	sel := 'select ' //
		+ ' ORDERS.CREWID, ORDERS.STATE, ORDERS.SOURCE_TIME, ' //
		+ ' ORDERS.SOURCE, ORDERS.DESTINATION ' //
		+ ' , ORDERS.DELETED ' // deleted and canceled orders
		+ ' , ORDERS.PRIOR_CREW_ID ' // prior_crew
		+ ' , ORDERS.STOPS_COUNT ' // кол-во промежут. остановок
	// + ' , ORDER_COORDS.COORDS_ADDR   ' // координаты адресов заказа, пока не исп.
		+ ' from ORDERS ' //
	// + ' , ORDER_COORDS ' //
		+ ' where ' //
		+ ' ORDERS.ID = ' + IntToStr(self.ID) //
	// + ' and ORDER_COORDS.ORDER_ID = ' + IntToStr(self.ID) //
		; res := get_sql_stringlist(self.query, sel);
	// result := res.Text; // return raw data as string
	result := res[0];

	res.Text := StringReplace(res.Text, '|', #13#10, [rfReplaceAll]);

	if res.Strings[0] <> '' then
		self.CrewID := StrToInt(res.Strings[0])
	else
	begin
		if self.CrewID > -1 then
		begin
			// снимаем экипаж с заказа
			self.time_to_end := -1;
			self.time_to_ap := -1;
			self.pcrew := nil;
		end;
		self.CrewID := -1; // !!!
	end;
	try
		self.state := StrToInt(res.Strings[1]);
	except
		self.state := -1;
	end;

	self.source_time := date_to_full(res.Strings[2]);

	self.source.set_raw_adres(res.Strings[3]);
	self.dest.set_raw_adres(res.Strings[4]);
	// return_adres(res.Strings[3], s, h, k);
	// self.source.setAdres(s, h, k, self.source.gps);
	// return_adres(res.Strings[4], s, h, k);
	// self.dest.setAdres(s, h, k, self.dest.gps);

	// проверяем удалённые и отменённые заказы
	if (length(res.Strings[5]) = 0) or (res.Strings[5] = '0') then
		self.deleted := false
	else
		self.deleted := true;

	// предварительно назначенный экипаж:
	if (length(res.Strings[6]) > 0) then
		try
			self.prior_CrewId := StrToInt(res.Strings[6]);
		except
			self.prior_CrewId := -1;
		end
	else
		self.prior_CrewId := -1; // сбрасываем, если нет

	// кол-во промежут. остановок
	if (length(res.Strings[7]) > 0) then
		try
			self.stop_int_count := StrToInt(res.Strings[7]);
		except
			self.stop_int_count := 0;
		end
	else
		self.stop_int_count := 0; // сбрасываем, если нет

	exit(result);
end;

// function TOrder.get_time_to_ap(var PCrew : Pointer) : Integer;
// var cur_pos : TAdres;
// gps : string;
// d : double;
// // points : TList;
// // время на остановки для экипажа на заказе
// crew : TCrew;
// begin
// // проверяем состояние заказа, возможен ли вообще расчёт
// if //
// (PCrew = nil) //
// or (self.state <> ORDER_VODITEL_PODTVERDIL) //
// or (self.CrewID = -1) //
// or (self.source.isEmpty) //
// then
// begin
// self.time_to_ap := -1;
// exit(-1);
// end;
//
// crew := TCrew(PCrew);
// if crew = nil then
// begin
// self.time_to_ap := -1;
// exit(-1);
// end;
//
// if (crew.coord = '') then
// begin
// self.time_to_ap := ORDER_CREW_NO_COORD;
// exit(ORDER_CREW_NO_COORD);
// end;
//
// cur_pos := TAdres.Create('', '', '', crew.coord); // начало маршрута - текущая координата машины
// points := TList.Create(); // список точек маршрута
// points.Add(Pointer(cur_pos));
// points.Add(Pointer(self.source));
//
// gps := get_set_gps(self.source);
// if gps = '' then // нет координаты у адреса подачи
// begin
// self.time_to_ap := ORDER_BAD_ADRES;
// exit(ORDER_BAD_ADRES);
// end;
//
// if (not crew.was_in_coord(gps)) then // и водитель в АП не был ещё
// begin
// result := get_crew_way_time(points, d);
// if result < 0 then
// result := ORDER_WAY_ERROR;
// end
// else
// // экипаж прибыл в АП
// result := 0;
// self.time_to_ap := result;
//
// FreeAndNil(points);
// exit(result);
// end;

// function TOrder.get_time_to_end(var PCrew : Pointer) : Integer;
// var cur_pos : TAdres; gps : string;
// points : TList;
// stops_time : Integer;
// // время на остановки для экипажа на заказе
// crew : TCrew; na_bortu : boolean;
// begin
// // проверяем состояние заказа, возможен ли вообще расчёт
// if not(self.state in [ //
// ORDER_VODITEL_PODTVERDIL, ORDER_KLIENT_NA_BORTU, //
// ORDER_PRIGLASITE_KILIENTA, ORDER_KLIENT_NE_VYSHEL, //
// ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
// ]) //
// then
// exit(-1);
//
// // проверяем назначенность экипажа и адресов
// if
// // (self.state in [ORDER_DONE, ORDER_CANCEL, ORDER_DISCONTNUED]) //
// // or
// (self.CrewID = -1) //
// or (self.source.isEmpty) //
// or (self.dest.isEmpty) //
// then
// exit(-1);
//
// crew := TCrew(PCrew);
// if crew = nil then
// exit(-1);
//
// if (crew.coord = '') then
// begin
// self.time_to_end := ORDER_CREW_NO_COORD; exit(ORDER_CREW_NO_COORD);
// end;
//
// stops_time := 0; points := TList.Create(); // список точек маршрута
// cur_pos := TAdres.Create('', '', '', crew.coord); // начало маршрута - текущая координата машины
// points.Add(Pointer(cur_pos));
//
// // если экипаж на заказе, то проверяем, был ли он в точках source и dest
// // если нет - добавляем их в маршрут и прибавляем время на остановки
// na_bortu := false;
// // if (self.state <> ORDER_KLIENT_NA_BORTU) then // клиент НЕ на борту
// if (self.state = ORDER_VODITEL_PODTVERDIL) then // клиент НЕ на борту
// begin
// gps := get_set_gps(self.source);
// if gps = '' then // нет координаты у адреса подачи
// begin
// self.time_to_end := ORDER_BAD_ADRES; exit(ORDER_BAD_ADRES);
// end;
//
// if (not crew.was_in_coord(gps)) then // и водитель в АП не был ещё
// // т.е. если экипаж ещё не забрал клиента
// begin
// points.Add(Pointer(self.source)); points.Add(Pointer(self.dest));
// stops_time := stops_time + 10 + 3;
// end
// else
// begin
// na_bortu := true;
// if crew.now_in_coord(gps) then
// // если водитель ожидает клиента, накидываем время на ожидание
// stops_time := stops_time + 10;
// end;
// end
// else if (self.state in [ //
// ORDER_PRIGLASITE_KILIENTA, ORDER_KLIENT_NE_VYSHEL, //
// ORDER_SMS_PRIGL, ORDER_TEL_PRIGL //
// ]) //
// then
// begin
// // если водитель ожидает клиента, накидываем время на ожидание
// na_bortu := true; stops_time := stops_time + 10;
// end;
//
// // если уже забрал, но не высадил
// if (na_bortu) or (self.state = ORDER_KLIENT_NA_BORTU) then
// begin
// gps := get_set_gps(self.dest);
// if gps = '' then // нет координаты у адреса высадки
// begin
// self.time_to_end := ORDER_BAD_ADRES; exit(ORDER_BAD_ADRES);
// end;
// if not crew.was_in_coord(gps) then // ещё не высадил
// begin
// points.Add(Pointer(self.dest)); stops_time := stops_time + 3;
// end
// else
// begin
// // забрал-высадил, то делаем заказ завёршенным и экипаж свободным
// self.time_to_end := 0;
// // self.state := ORDER_DONE;
// // self.CrewID := -1; // сбрасываем экипаж в заказе
// crew.OrderId := -1; crew.state := CREW_SVOBODEN; exit(0);
// end;
// end;
//
// result := get_crew_way_time(points, crew.dist_way);
// result := ifthen(result > -1, result + stops_time, -1); self.time_to_end := result;
// if result = -1 then
// self.time_to_end := ORDER_WAY_ERROR;
// FreeAndNil(points); exit(result);
// end;

function TOrder.is_not_prior : boolean;
begin
	result := self.source_time < replace_time('{Last_hour_-1}', now());
end;

procedure TOrder.set_time_to_ap(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin
	self.way_to_ap.set_way_time_dist(ASender, pDisp, url);
	if self.way_to_ap.time < 0 then
		self.time_to_ap := ORDER_WAY_ERROR
	else
	begin
		self.time_to_ap := self.way_to_ap.time;
		// сбрасываем время расчёта
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
		TCrew(self.pcrew).reset_old_coord(); // сбрасываем координату
	end;


	// if self.time_to_end > -1  then self.dfgh;

	// result := ifthen(result > -1, result + stops_time, -1); self.time_to_end := result;
	// if result = -1 then
	// self.time_to_end := ORDER_WAY_ERROR;
end;

function TOrder.source_time_without_date : string;
begin
	result := '    ' + time_without_date(self.source_time);
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
			result := result + ' подачи!'; // self.source.get_as_string();
	end
	else
	begin
		if self.time_to_end > 0 then
			result := 'выполняется'
		else
		begin
			result := self.time_to_end_as_string();
			if self.time_to_end = ORDER_BAD_ADRES then
				result := result + ' назначения!'; // self.dest.get_as_string();
		end;
	end;
end;

function TOrder.time_as_string(time : Integer) : string;
begin
	result := IntToStr(time mod 60) + ' мин.';
	if time > 59 then
		result := IntToStr(time div 60) + ' ч. ' + result;
end;

function TOrder.time_to_ap_as_string : string;
var prib_dt, ap_dt, cur_dt : TDateTime;
	opozdanie, porog : Int64;
	s_opoz : string;
begin
	if self.time_to_ap = ORDER_AP_OK then
		result := '!клиент на борту'
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
					if self.state = ORDER_VODITEL_PODTVERDIL then
						result := '!ожидание клиента'
					else
						result := 'ожидание клиента'
				end
				else
				begin
					cur_dt := now();
					prib_dt := IncMinute(cur_dt, self.time_to_ap);
					ap_dt := source_time_to_datetime(self.source_time);
					opozdanie := MinutesBetween(prib_dt, ap_dt); // насколько опаздываем/раньше
					s_opoz := self.time_as_string(opozdanie);
					if prib_dt > ap_dt then // опаздываем нахер :) !
					begin
						result := 'опаздывает на ' + s_opoz;
						// if cur_dt < ap_dt then
						// porog := MinutesBetween(cur_dt, ap_dt) mod 10
						// else
						// porog := 0;
						porog := 5;
						if opozdanie > porog then
							// песенц опаздываем :)
							result := '!!!' + result
						else
							// ничо страшного, но волнуемся :)
							result := '!' + result;
					end
					else
						// result :=  self.time_as_string(self.time_to_ap);
						result := 'будет раньше на ' + s_opoz;
				end;
end;

function TOrder.time_to_end_as_string : string;
begin
	case self.time_to_end of
		ORDER_AN_OK :
			if self.state in [ORDER_DONE, ORDER_VODITEL_VYPOLNIL_ZAKAZ] then
				exit('заказ завершён')
			else
				exit('!!!заказ завершён');
		-1 :
			exit('');
		0 :
			if self.state in [ORDER_DONE, ORDER_VODITEL_VYPOLNIL_ZAKAZ] then
				exit('заказ завершён')
			else
				exit('!высадка клиента');
	else // case
		if self.time_to_end < 0 then
		begin
			result := order_states.Values[IntToStr(self.time_to_end)];
			result := StringReplace(result, '_', ' ', [rfReplaceAll]);
		end
		else
			result := self.time_as_string(self.time_to_end) //
				+ ' ' + time_without_date(self.datetime_of_time_to_end);
		// exit('выполняется');
	end; // case
end;

{ TOrder_List }

function TOrderList.Append(OrderId : Integer) : Pointer;
var i : Integer;
begin
	if self.is_defined(OrderId) then
		exit(self.find_by_Id(OrderId));
	// если заказ уже в списке, возвращаем
	// .								   указатель на него
	i := self.Orders.Add(TOrder.Create(OrderId, self.query)); result := Pointer(self.Orders[i]);
end;

function TOrderList.clear_order_list : Integer;
begin
	self.Orders.Clear(); exit(0);
end;

constructor TOrderList.Create(var IBQuery : TIBQuery);
begin
	inherited Create;
	self.Orders := TList.Create();
	self.query := IBQuery;
end;

function TOrderList.del_bad_orders : Integer;
var pp : Pointer;
	order : TOrder;
	i : Integer;
	s_now, s_past : string;
	cur_t : TDateTime;
begin
	cur_t := now();
	s_now := date_to_full(cur_t);
	s_past := replace_time(ORDER_DESTROY_TIME, cur_t);

	for i := self.Orders.Count - 1 downto 0 do
	begin
		order := self.order(self.Orders.Items[i]);
		if //
			order.source.isEmpty() // нет адреса подачи
			or order.dest.isEmpty() // нет адреса назначения
			or order.deleted // заказ удалён/отменён
			or (order.state = ORDER_DONE) // заказ завершён
			or (order.state = ORDER_CANCEL) // заказ отменён
			or (order.state = ORDER_DISCONTNUED) // заказ прекращён
			or (order.state = ORDER_NO_CREWS) // нет машин
			then
		begin
			if order.destroy_flag then
			begin
				if order.destroy_time < s_past then
				begin
					self.del_order(i); // удаляем заказ из списка
				end; // иначе просто ждём
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
	if ListIndex in [0 .. self.Orders.Count - 1] then
		try
			TOrder(self.Orders.Items[ListIndex]).Free();
			// FreeMem(self.Orders.Items[ListIndex]);
			self.Orders.Delete(ListIndex);
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
	for i := self.Orders.Count - 1 downto 0 do
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

function TOrderList.get_crews_id_as_string : string;
var s : string; pp : Pointer;
begin
	s := '';
	for pp in self.Orders do
		s := s + ',' + IntToStr(self.order(pp).CrewID);
	Delete(s, 1, 1); result := s;
end;

function TOrderList.get_current_orders() : TStringList;
var sel, s, s1 : string; res : TStringList;
	sdate_from, sdate_to : string;
begin
	cur_time := now();
	if DEBUG then
	begin
		sdate_from := DEBUG_SDATE_FROM; // for back-up base
		sdate_to := DEBUG_SDATE_TO; // for back-up base
	end
	else
	begin
		sdate_from := replace_time('{Last_day_1}', cur_time); // for real database
		sdate_to := replace_time('{Last_day_-1}', cur_time); // for real database
	end;
	sdate_from := '''' + sdate_from + '''';
	sdate_to := '''' + sdate_to + '''';

	sel := 'select ' //
		+ ' ORDERS.ID ' //
		+ ' from ORDERS ' //
		+ ' where ' //

	// отбрасываем удалённые и отменённые заказы
		+ ' (ORDERS.DELETED is null or ORDERS.DELETED = 0) '
	// + ' (ORDERS.DELETED is null) '

	// . только заказы с состоянием "принят", "в работе" и т.п.
	// . см. данные таблицы ORDER_STATES
		+ ' and (ORDERS.STATE in ' //
		+ '   (select ORDER_STATES.ID from ORDER_STATES where ORDER_STATES.SYSTEMSTATE in (0, 1) ) '
	//
		+ ' ) ' //

	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// фильтр по дате :
	// в числе прочего убирает глючные незакрытые заказы
		+ ' and ORDERS.SOURCE_TIME > ' + sdate_from + ' ' // ну так, что б уж поменьше
	// предварительные не убираем, ибо пусть видны в отд. вкладке
	// + ' and ORDERS.SOURCE_TIME < ' + sdate_to + ' ' // по времени подачи

	// . заказы с промежуточными остановками тоже читаем, но не считаем пока
	// + ' and (ORDERS.STOPS_COUNT is null  or  ORDERS.STOPS_COUNT = 0) ' //
	// + ' order by ORDERS.SOURCE_TIME asc ' //
		;

	res := get_sql_stringlist(self.query, sel);
	// result := TStringList.Create();
	for s in res do
		if not self.is_defined(StrToInt(s)) then
			// если заказа нет в списке, то добавляем
			self.Append(StrToInt(s));
	// запрашиваем его данные заказов
	// если есть - всё равно зпрашиваем, а то вдруг обновились :))
	// s1 := self.order(self.Append(StrToInt(s))).get_order_data();
	// result.Append(s1);

	result := self.get_orders_data();
	self.del_bad_orders();
	// self.delete_all_none_adres();
	self.Orders.Sort(sort_orders_by_source_time);
	exit(result);
end;

function TOrderList.get_orders_data : TStringList;
var pp : Pointer;
begin
	if self.Orders.Count = 0 then
		exit();
	result := TStringList.Create();
	for pp in self.Orders do
		result.Append(self.order(pp).get_order_data());
	exit(result);
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

{ TOrderCrews }

// constructor TOrderCrews.Create(var IBQuery : TIBQuery; ordId : Integer);
// begin
// inherited Create();
// self.OrderId := ordId;
// self.crew_list.Create(IBQuery);
// end;

end.
