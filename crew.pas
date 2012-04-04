unit crew;

interface

uses crew_utils, // utils from robocap and mine
	crew_globals, // my global var and function
	form_order, // form for orders
	Generics.Collections, // for forward class definition
	Controls, Forms, Classes, SysUtils, Math, SHDocVw, MSHTML, ActiveX, //
	IBQuery, DB, WinInet, StrUtils;

function sort_crews_by_state_dist(p1, p2 : Pointer) : Integer;
function sort_crews_by_time(p1, p2 : Pointer) : Integer;

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
		dest : TAdres; // address to
		source_time : string; // время подачи экипажа
		time_to_end : Integer; // время до окончания заказа в минутах

		query : TIBQuery;
		form : TFormOrder; // form to show order

		// crews_list : TCrewList;

		constructor Create(OrderId : Integer; var IBQuery : TIBQuery);
		function get_order_data() : Integer;
		function time_as_string() : string; // время до окончания заказа в виде часы-минуты;
		function state_as_string() : string; // время до окончания заказа в виде часы-минуты;
	end;

	TOrderList = class(TObject)
		Orders : TList;
		query : TIBQuery;

		constructor Create(var IBQuery : TIBQuery);
		function clear_order_list() : Integer;
		function order(p : Pointer) : TOrder;
		function find_by_Id(OrderId : Integer) : Pointer;
		function is_defined(OrderId : Integer) : boolean;
		function Append(OrderId : Integer) : Pointer;
		function get_current_orders() : Tstringlist;
		function get_crews_id_as_string() : string;
		function delete_all_none_adres() : Integer;
	end;

	TCrew = class(TObject)
		CrewID : Integer;
		GpsId : Integer;
		state : Integer; // состояние: 1 - свободен, 3 - на заказе;
		state_as_string : string;
		Code : string;
		name : string;
		coord : string; // текущая (самая свежая) координата GPS
		dist : double; // расстояние до адреса подачи (АП) радиальное, по прямой, метров;
		dist_way : double; // длина маршрута до АП, км;
		dist_way_as_string : string; // то же;
		time : Integer; // время подъезда к АП в минутах;
		time_as_string : string; // оно же в виде часы-минуты;
		coords : Tstringlist; // gps-трек за выбранный промежуток времени;
		coords_times : Tstringlist; // gps-трек за выбранный промежуток времени;
		OrderId : Integer; // ID заказа занятого экипажа
		order_way : string; // маршрут занятого экипажа

		source : TAdres; // address_from for state==3
		dest : TAdres; // address_to for state==3
		ap : TAdres; // адрес подачи экипажа

		constructor Create(GpsId : Integer);
		function set_current_coord() : Integer;
		function sort_coords_by_time_desc() : Integer;
		function append_coords(coord : string; time : string) : Integer;
		function is_crew_was_in_coord(coord : string) : boolean;
		procedure calc_dist(coord : string);
		procedure set_time(m : Integer); // set time and time_as_string;
		function get_time(var list : TOrderList; newOrder : boolean) : Integer;
	end;

	TCrewList = class(TObject)
		Crews : TList;
		query : TIBQuery;

		ap_street : string;
		ap_house : string;
		ap_korpus : string;
		ap_gps : string;

		constructor Create(var IBQuery : TIBQuery);
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
		function delete_all_none_crewId() : Integer;
		function delete_all_none_coord() : Integer;
		function set_crewId_by_gpsId(list : Tstringlist) : Integer;
		function set_crews_orderId(list : Tstringlist) : Integer;
		function set_crews_state_by_crewId(var list : Tstringlist) : Integer;
		function set_current_crews_coord() : Integer;
		function set_crews_dist(coord : string) : Integer;
		function set_ap(street, house, korpus, gps : string) : Integer;
		function clear_crew_list() : Integer;
		function get_crew_list_by_crewid_string(screws_id : string) : Tstringlist;
		function get_crew_list_by_order_list(var list : TOrderList) : Tstringlist;
		function get_crew_list() : Tstringlist;
		function set_crews_data(list : Tstringlist) : Integer;
		function get_crews_coords(SCTIME : string) : Integer;
		function ret_crews_stringlist() : Tstringlist;
	private
		function findById(ID : Integer; gps : boolean) : Pointer;
		function get_id_list_as_string(gps : boolean) : string;
		function del_all_non_work_crews() : Integer;
		function delete_all_none_orderId() : Integer;
		procedure set_crews_state_as_string();
		procedure set_crews_orderId_by_order_list(var list : TOrderList);
	end;

	// TOrderCrews = class(TObject)
	// OrderId : Integer;
	// crew_list : TCrewList;
	// constructor Create(var IBQuery : TIBQuery; ordId : Integer);
	// end;

implementation

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
	else if (t1 > t2) then
		exit(1)
	else if (d1 < d2) then // если время равно, сравниваем длину маршрута
		exit(-1)
	else if (d1 > d2) then
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
	s1 := c1.state; s2 := c2.state;
	if (s1 < s2) then
		exit(-1)
	else if (s1 > s2) then
		exit(1)
	else if (d1 < d2) then // if state1 == state2
		exit(-1)
	else if (d1 > d2) then
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
begin
	if (length(self.coord) > 0) and (length(coord) > 0) then
		self.dist := get_dist_from_coord(coord, self.coord)
	else
		self.dist := -1.0;
end;

constructor TCrew.Create(GpsId : Integer);
begin
	inherited Create;
	self.GpsId := GpsId;
	self.coords := Tstringlist.Create;
	self.coords_times := Tstringlist.Create;
	self.CrewID := -1;
	self.state := -1; // состояние: 1 - свободен, 3 - на заказе;
	self.Code := '';
	self.name := '';
	self.state_as_string := '';
	self.coord := ''; // текущая (самая свежая) координата GPS
	self.dist := -1.0; // расстояние до адреса подачи (АП)
	self.time := -1; // время подъезда к АП в минутах;
	self.OrderId := -1; // ID заказа занятого экипажа
	self.order_way := ''; // маршрут занятого экипажа

	source := TAdres.Create('', '', '', ''); // address from
	dest := TAdres.Create('', '', '', ''); // address to
	ap := TAdres.Create('', '', '', ''); // адрес подачи
end;

function TCrew.get_time(var list : TOrderList; newOrder : boolean) : Integer;
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
	if (self.state = -1) //
		or (self.coord = '') //
		or (newOrder and self.ap.isEmpty()) //
		or ( //
		(self.state = CREW_NAZAKAZE) //
			and ((self.OrderId = -1) or (self.source.isEmpty()) or (self.dest.isEmpty())) //
		) //
		then
	begin
		result := -1;
		self.set_time(result);
		exit(result);
	end;

	stops_time := 0;
	points := TList.Create(); // список точек маршрута
	cur_pos := TAdres.Create('', '', '', self.coord); // начало маршрута - текущая координата машины
	points.Add(Pointer(cur_pos));

	if self.state = CREW_NAZAKAZE then
	// если экипаж на заказе, то проверяем, был ли он в точках source и dest
	// если нет - добавляем их в маршрут и прибавляем время на остановки
	begin
		order := list.order(list.find_by_Id(self.OrderId));
		if not self.is_crew_was_in_coord(get_set_gps(order.source)) then
		begin
			// если экипаж ещё не забрал клиента
			points.Add(Pointer(order.source));
			points.Add(Pointer(order.dest));
			stops_time := stops_time + 10 + 3;
		end
		else if not self.is_crew_was_in_coord(get_set_gps(order.dest)) then
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
			order.state := ZAKAZ_DONE;
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
			self.set_time(result);
	end;

	FreeAndNil(points);
	exit(result);
end;

function TCrew.is_crew_was_in_coord(coord : string) : boolean;
const RADIUS = 150.0;
var cc : string;
	d : double;
begin
	for cc in self.coords do
	begin
		d := get_dist_from_coord(coord, cc);
		if (d >= 0) and (d < RADIUS) then
			exit(true);
	end;
	exit(false);
end;

function TCrew.set_current_coord() : Integer;
	function s_2_6(sc : string) : string;
	var n : double;
	begin
		n := dotStrtoFloat(sc);
		sc := FloatToStrF(n, ffFixed, 8, 6);
		sc := StringReplace(sc, ',', '.', [rfReplaceAll]);
		exit(sc);
	end;

var sl : Tstringlist;
	s, s1, s2 : string;
	crew : TCrew;
	Count, i : Integer;
begin
	// count := IfThen(self.coords.count < self.coords_times.count, self.coords.count, self.coords_times.count);
	// if (count <= 0) then
	// exit(0);
	// sl := TStringList.Create();
	// for i := 0 to (count - 1) do
	// sl.Append(self.coords_times.Strings[i] + '|' + self.coords.Strings[i]);
	// sl.Sorted := True;
	// self.coord := get_substr(sl.Strings[sl.count - 1], '|', '');
	// FreeAndNil(sl);
	if self.sort_coords_by_time_desc() < 0 then
		exit(-1);
	s := self.coords.Strings[0];
	s1 := get_substr(s, '', ',');
	s2 := get_substr(s, ',', '');
	s := s_2_6(s1) + ',' + s_2_6(s2);
	self.coord := s;
	exit(0);
end;

procedure TCrew.set_time(m : Integer);
begin
	if m < 0 then
	begin
		self.time := -1;
		self.time_as_string := '';
		self.dist_way := -1;
		self.dist_way_as_string := '';
		exit();
	end;
	self.dist_way_as_string := FloatToStrF(self.dist_way, ffFixed, 8, 3) + 'км';
	self.time := m;
	self.time_as_string := IntToStr(m mod 60) + ' мин.';
	if m > 59 then
		self.time_as_string := IntToStr(m div 60) + ' ч. ' + self.time_as_string;
end;

function TCrew.sort_coords_by_time_desc : Integer;
var sl : Tstringlist;
	s : string;
	crew : TCrew;
	Count, i : Integer;
begin
	Count := ifthen(self.coords.Count < self.coords_times.Count, self.coords.Count, self.coords_times.Count);
	if (Count <= 0) then
		exit(-1);
	sl := Tstringlist.Create();
	for i := 0 to (Count - 1) do
		sl.Append(self.coords_times.Strings[i] + '|' + self.coords.Strings[i]);
	sl.Sorted := true;
	sl.Duplicates := dupIgnore;
	reverseStringList(sl);
	self.coords.Clear();
	self.coords_times.Clear();
	for s in sl do
	begin
		self.coords_times.Append(get_substr(s, '', '|'));
		self.coords.Append(get_substr(s, '|', ''));
	end;
	FreeAndNil(sl);
	exit(0);
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
	self.query := IBQuery;
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

function TCrewList.delete_all_none_coord : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		if (self.crew(pp).coord = '') then
			self.Crews.delete(self.Crews.IndexOf(pp));
	exit(0);
end;

function TCrewList.delete_all_none_crewId : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		if (self.crew(pp).CrewID = -1) then
			self.Crews.delete(self.Crews.IndexOf(pp));
	exit(0);
end;

function TCrewList.delete_all_none_orderId() : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		if (self.crew(pp).state = CREW_NAZAKAZE) then
			if (self.crew(pp).OrderId = -1) then
				self.Crews.delete(self.Crews.IndexOf(pp));
	exit(0);
end;

function TCrewList.del_all_non_work_crews : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		if self.crew(pp).state in [CREW_SVOBODEN, CREW_NAZAKAZE] then
			pass
		else
			self.Crews.delete(self.Crews.IndexOf(pp));
	exit(0);
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
var
	crew : TCrew;
	pcrew : ^TCrew;
begin
	result := nil;
	for pcrew in self.Crews do
	begin
		crew := TCrew(pcrew);
		if ((not gps) and (crew.CrewID = ID)) or (gps and (crew.GpsId = ID)) then
		begin
			result := pcrew;
			exit();
		end;
	end;
end;

function TCrewList.get_crewid_list_as_string : string;
begin
	result := self.get_id_list_as_string(false);
end;

function TCrewList.get_crews_coords(SCTIME : string) : Integer;
	function coords_to_str(fields : TFields) : Tstringlist;
	var
		field : TField; // main file
		j, l, ID : Integer;
		// s, s2, d : string;
		b : TBytes;
		pint : ^Integer;
		plat, plong : ^single;
		s, sdate1, sdate2, sgpsid, scoords : string;
		res : Tstringlist;
		crew : TCrew;
		pp : Pointer;

	begin
		res := Tstringlist.Create;
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
				s := sgpsid + '|' + date_to_full(sdate2) + '|(' + scoords + ')';
				res.Append(s);

				pp := self.findByGpsId(StrToInt(sgpsid));
				if pp = nil then
					crew := self.crew(self.Append(StrToInt(sgpsid)))
				else
					crew := self.crew(pp);
				crew.append_coords(scoords, date_to_full(sdate2));
			end;

			j := j + 12;
		end;
		result := res;
	end;

var
	sel : string;
	// Coord : string;
	j : Integer;
	coords, slist : Tstringlist;
begin
	cur_time := now();
	// if DEBUG then
	// SCTIME := '2011-10-03 14:57:50' // for back-up base
	// else
	// SCTIME := replace_time('{Last_minute_30}', cur_time); // for real database
	SCTIME := '''' + SCTIME + '''';

	sel := 'select ID, MEASURE_START_TIME, MEASURE_END_TIME, COORDS ' //
		+ 'from CREWS_COORDS ' //
		+ ' where MEASURE_START_TIME > ' + SCTIME //
		+ ' order by MEASURE_START_TIME ASC, ID ASC';
	sql_select(self.query, sel);
	slist := Tstringlist.Create;
	while (not self.query.Eof) do
	begin
		coords := coords_to_str(self.query.fields);
		j := 0;
		while (j < coords.Count) do
		begin
			slist.Append(coords.Strings[j]);
			inc(j);
		end;
		self.query.Next;
	end;
	slist.Sorted := true;
	self.set_current_crews_coord();
	self.delete_all_none_coord(); self.delete_all_none_coord();
	// self.set_crews_dist(self.ap_gps);

	FreeAndNil(slist);
	// FreeAndNil(coords);
	exit(0);
end;

function TCrewList.get_crew_list_by_crewid_string(screws_id : string) : Tstringlist;
var sel : string;
begin
	result := Tstringlist.Create();
	if length(screws_id) = 0 then
		exit(result);
	sel := //
		'select CREWS.ID, CREWS.IDENTIFIER, CREWS.CODE, CREWS.NAME, CREWS.STATE ' //
		+ ' from CREWS ' //
		+ ' where ' //
		+ ' CREWS.ID in (' + screws_id + ') '; //
	result := get_sql_stringlist(self.query, sel);
	self.set_crews_data(result);
end;

function TCrewList.get_crew_list_by_order_list(var list : TOrderList) : Tstringlist;
var pp : Pointer;
	order : TOrder;
	crew : TCrew;
begin
	result := self.get_crew_list_by_crewid_string(list.get_crews_id_as_string());
	self.set_crews_orderId_by_order_list(list);
	for pp in list.Orders do
	begin
		order := list.order(pp);
		crew := self.crewByCrewId(order.CrewID);
		if (order <> nil) and (crew <> nil) then
		begin
			crew.source := order.source;
			crew.dest := order.dest;
		end;
	end;
end;

function TCrewList.get_crew_list() : Tstringlist;
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
		+ ' and CREWS.STATE in (1,3) '; // с состоянием "свободен" и "на заказе"
	result := get_sql_stringlist(self.query, sel);
	self.set_crews_data(result);
	self.delete_all_none_crewId(); self.delete_all_none_crewId(); // так работает :-/
end;

function TCrewList.get_gpsid_list_as_string : string;
begin
	result := self.get_id_list_as_string(true);
end;

function TCrewList.get_id_list_as_string(gps : boolean) : string;
var s : string;
	pp : Pointer;
begin
	s := '';
	for pp in self.Crews do
		if gps then
			s := s + ',' + IntToStr(self.crew(pp).GpsId)
		else
			s := s + ',' + IntToStr(self.crew(pp).CrewID);
	delete(s, 1, 1);
	result := s;
end;

function TCrewList.get_nonfree_crewid_list_as_string() : string;
var s : string;
	pp : Pointer;
begin
	s := '';
	for pp in self.Crews do
		if (self.crew(pp).state = CREW_NAZAKAZE) and (self.crew(pp).CrewID > -1) then
			s := s + ',' + IntToStr(self.crew(pp).CrewID);
	if length(s) > 0 then
		delete(s, 1, 1);
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

function TCrewList.ret_crews_stringlist : Tstringlist;
var pp : Pointer;
	crew : TCrew;
	s : string;
begin
	result := Tstringlist.Create();
	for pp in self.Crews do
	begin
		crew := self.crew(pp);
		if crew.time > -1 then
		begin
			s := IntToStr(crew.CrewID) + '|' //
				+ crew.name + '||' //
				+ crew.state_as_string + '|||' //
				+ crew.time_as_string + '||||' //
				+ crew.dist_way_as_string;
			// + FloatToStrF(crew.dist / 1000.0, ffFixed, 8, 3);
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

function TCrewList.set_crewId_by_gpsId(list : Tstringlist) : Integer;
var sl : Tstringlist;
	s : string;
	crew : TCrew;
begin
	sl := Tstringlist.Create();
	// sl.Delimiter := '|';
	for s in list do
	begin
		sl.Clear();
		sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		crew := self.crewByGpsId(StrToInt(sl.Strings[0]));
		crew.CrewID := StrToInt(sl.Strings[1]);
		crew.Code := sl.Strings[2];
		crew.name := sl.Strings[3];
		crew.state := StrToInt(sl.Strings[4]);
		if crew.state = CREW_SVOBODEN then
			crew.state_as_string := 'Свободен'
		else
			crew.state_as_string := 'На заказе';
	end;
	self.delete_all_none_crewId(); self.delete_all_none_crewId();
	FreeAndNil(sl);
	exit(0);
end;

function TCrewList.set_crews_data(list : Tstringlist) : Integer;
var sl : Tstringlist;
	s : string;
	crew : TCrew;
	ID, GpsId : Integer;
begin
	sl := Tstringlist.Create();
	// sl.Delimiter := '|';
	for s in list do
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
		if crew.state = CREW_SVOBODEN then
			crew.state_as_string := 'Свободен'
		else
			crew.state_as_string := 'На заказе';
	end;
	FreeAndNil(sl);
	exit(0);
end;

function TCrewList.set_crews_dist(coord : string) : Integer;
var pp : Pointer;
begin
	if length(coord) = 0 then
		exit(-1);
	for pp in self.Crews do
		self.crew(pp).calc_dist(coord);
	exit(0);
end;

function TCrewList.set_crews_orderId(list : Tstringlist) : Integer;
var sl : Tstringlist;
	s : string;
	crew : TCrew;
begin
	sl := Tstringlist.Create();
	for s in list do
	begin
		sl.Clear();
		sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		crew := self.crewByCrewId(StrToInt(sl.Strings[0]));

		if (crew.OrderId <> -1) or (crew.state <> CREW_NAZAKAZE) then
			continue; // если уже назначен заказ, то пропускаем,
		// т.к. для экипажа на заказе м.б. несколько
		// заказов в состоянии исполнения

		if sl.Strings[5] <> '' then
			continue; // пропускаем заказы с промежуточными остановками;

		crew.OrderId := StrToInt(sl.Strings[1]);
		// sl.Strings[2]; // - пропускаем
		crew.order_way := sl.Strings[3] + ';' + sl.Strings[4];
	end;
	self.delete_all_none_orderId(); self.delete_all_none_orderId();
	FreeAndNil(sl);
	exit(0);
end;

procedure TCrewList.set_crews_orderId_by_order_list(var list : TOrderList);
var order : TOrder;
	pp : Pointer;
begin
	for pp in list.Orders do
	begin
		order := list.order(pp);
		if self.isCrewIdInList(order.CrewID) then
			self.crewByCrewId(order.CrewID).OrderId := order.ID;
	end;
end;

procedure TCrewList.set_crews_state_as_string;
var pp : Pointer;
begin
	for pp in self.Crews do
		if self.crew(pp).state = 1 then
			self.crew(pp).state_as_string := 'Свободен'
		else
			self.crew(pp).state_as_string := 'На заказе';
end;

function TCrewList.set_crews_state_by_crewId(var list : Tstringlist) : Integer;
// уже не нужен;
var
	s, sid, sstate : string;
	crew : TCrew;
begin
	for s in list do
	begin
		sid := get_substr(s, '', '|');
		sstate := get_substr(s, '|', '');
		crew := self.crewByCrewId(StrToInt(sid));
		if crew.state = -1 then
			crew.state := StrToInt(sstate);
	end;
	self.del_all_non_work_crews(); self.del_all_non_work_crews(); // мистика, но так работает :-/
	self.set_crews_state_as_string();
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
var
	crew : TCrew;
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

constructor TOrder.Create(OrderId : Integer; var IBQuery : TIBQuery);
begin
	inherited Create();
	self.ID := OrderId;
	self.CrewID := -1;
	// want_CrewId := -1; // желаемый экипаж на заказе - НЕ НУЖЕН
	prior_CrewId := -1; // предварительный экипаж на предвар. заказе
	prior := false; // признак предварительного заказа
	state := -1; // -1 - not defined, 0 - принят, маршрут задан
	// .                 1 - в работе, 2 - выполнен;
	source := TAdres.Create('', '', '', ''); // address from
	dest := TAdres.Create('', '', '', ''); // address to
	source_time := ''; // время подачи экипажа
	time_to_end := -1; // время до окончания заказа в минутах
	self.query := IBQuery;

	form := TFormOrder.Create(nil);
end;

function TOrder.get_order_data() : Integer;
var
	sel, s, h, k : string;
	res : Tstringlist;
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
		+ ' from ORDERS ' //
		+ ' where ' //
		+ ' ORDERS.ID = ' + IntToStr(self.ID); //

	res := get_sql_stringlist(self.query, sel);

	res.Text := StringReplace(res.Text, '|', #13#10, [rfReplaceAll]);

	if res.Strings[0] <> '' then
		self.CrewID := StrToInt(res.Strings[0]);
	self.state := StrToInt(res.Strings[1]);
	self.source_time := date_to_full(res.Strings[2]);
	return_adres(res.Strings[3], s, h, k); self.source.setAdres(s, h, k, '');
	return_adres(res.Strings[4], s, h, k); self.dest.setAdres(s, h, k, '');

	exit(0);
end;

function TOrder.state_as_string : string;
begin
	// result := IntToStr(self.state);
	result := order_states.Values[IntToStr(state)];
	result := StringReplace(result, '_', ' ', [rfReplaceAll]);
end;

function TOrder.time_as_string : string;
begin
	if self.time_to_end < 0 then
		exit('неизвестно')
	else if self.time_to_end = 0 then
		exit('завершён');
	result := IntToStr(self.time_to_end mod 60) + ' мин.';
	if self.time_to_end > 59 then
		result := IntToStr(self.time_to_end div 60) + ' ч. ' + result;
end;

{ TOrder_List }

function TOrderList.Append(OrderId : Integer) : Pointer;
var i : Integer;
begin
	if self.is_defined(OrderId) then
		exit(self.find_by_Id(OrderId)); // если заказ уже в списке, возвращаем
	// .								   указатель на него
	i := self.Orders.Add(TOrder.Create(OrderId, self.query));
	result := Pointer(self.Orders[i]);
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
end;

function TOrderList.delete_all_none_adres : Integer;
var pp : Pointer;
	order : TOrder;
begin
	for pp in self.Orders do
		with self.order(pp) do
			if source.isEmpty() or dest.isEmpty() then
				self.Orders.delete(self.Orders.IndexOf(pp));
	exit(0);
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
var s : string;
	pp : Pointer;
begin
	s := '';
	for pp in self.Orders do
		s := s + ',' + IntToStr(self.order(pp).CrewID);
	delete(s, 1, 1);
	result := s;
end;

function TOrderList.get_current_orders() : Tstringlist;
var
	sel, s : string;
	res : Tstringlist;
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
		sdate_from := replace_time('{Last_hour_2}', cur_time); // for real database
		sdate_to := replace_time('{Last_hour_-4}', cur_time); // for real database
	end;
	sdate_from := '''' + sdate_from + '''';
	sdate_to := '''' + sdate_to + '''';

	sel := 'select ' //
		+ ' ORDERS.ID ' //
		+ ' from ORDERS ' //
		+ ' where ' //
		+ ' (ORDERS.STATE in ' //
		+ '   (select ORDER_STATES.ID from ORDER_STATES where ORDER_STATES.SYSTEMSTATE in (0, 1) ) ' //
	// .         ^^^ только заказы с состоянием "принят", "в работе" и т.п.
	// .             см. данные таблицы ORDER_STATES
		+ ' ) ' //
		+ ' and ORDERS.SOURCE_TIME > ' + sdate_from // выбираем заказы
		+ ' and ORDERS.SOURCE_TIME < ' + sdate_to // по времени подачи
		+ ' and (ORDERS.STOPS_COUNT is null  or  ORDERS.STOPS_COUNT = 0) ' //
	// .      ^^^ отбрасываем заказы с промежуточными остановками
		+ ' order by ORDERS.SOURCE_TIME asc ';

	res := get_sql_stringlist(self.query, sel);
	for s in res do
		if not self.is_defined(StrToInt(s)) then
		begin
			self.order(self.Append(StrToInt(s))).get_order_data();
			// если заказа нет в списке, то запрашиваем его данные
		end;

	self.delete_all_none_adres(); self.delete_all_none_adres();
	exit(res);
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
