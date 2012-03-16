unit crew;

interface

uses crew_utils, Classes, SysUtils, Math, SHDocVw, MSHTML, ActiveX;

const CREW_SVOBODEN = 1;

const CREW_NAZAKAZE = 3;

function sort_crews_by_state_dist(p1, p2 : Pointer) : Integer;
function sort_crews_by_time(p1, p2 : Pointer) : Integer;

type
	TAdres = class(TObject)
		street : string;
		house : string;
		korpus : string;
		gps : string;
		constructor Create(street, house, korpus, gps : string);
		procedure setAdres(street, house, korpus, gps : string);
		procedure Clear();
	end;

type
	TCrew = class(TObject)
		CrewID : Integer;
		GpsId : Integer;
		State : Integer; // состояние: 1 - свободен, 3 - на заказе;
		state_as_string : string;
		Code : string;
		name : string;
		coord : string; // текущая (самая свежая) координата GPS
		dist : double; // расстояние до адреса подачи (АП) радиальное, по прямой, метров;
		dist_way : double; // длина маршрута до АП, км;
		dist_way_as_string : string; // то же;
		time : Integer; // время подъезда к АП в минутах;
		time_as_string : string; // оно же в виде часы-минуты;
		coords : TStringList; // gps-трек за выбранный промежуток времени;
		coords_times : TStringList; // gps-трек за выбранный промежуток времени;
		orderId : Integer; // ID заказа занятого экипажа
		order_way : string; // маршрут занятого экипажа

		constructor Create(GpsId : Integer);
		function set_current_coord() : Integer;
		function sort_coords_by_time_desc() : Integer;
		function append_coords(coord : string; time : string) : Integer;
		function is_crew_was_in_coord(coord : string) : boolean;
		procedure calc_dist(coord : string);
		procedure set_time(m : Integer); // set time and time_as_string;
	end;

type
	PTCrew = ^TCrew;

type
	TCrewList = class(TObject)
		Crews : TList;
		ap_street : string;
		ap_house : string;
		ap_korpus : string;
		ap_gps : string;
		constructor Create();
		function crew(p : Pointer) : TCrew;
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
		function set_crewId_by_gpsId(list : TStringList) : Integer;
		function set_crews_orderId(list : TStringList) : Integer;
		function set_crews_state_by_crewId(var list : TStringList) : Integer;
		function set_current_crews_coord() : Integer;
		function set_crews_dist(coord : string) : Integer;
		function set_ap(street, house, korpus, gps : string) : Integer;
		function clear_crew_list() : Integer;
	private
		function findById(ID : Integer; gps : boolean) : Pointer;
		function get_id_list_as_string(gps : boolean) : string;
		function del_all_non_work_crews() : Integer;
		function delete_all_none_orderId() : Integer;
		procedure set_crews_state_as_string();
	end;

implementation

function sort_crews_by_time(p1, p2 : Pointer) : Integer;
var t1, t2 : Integer;
	c1, c2 : TCrew;
begin
	c1 := TCrew(p1); c2 := TCrew(p2);
	t1 := c1.time; t2 := c2.time;
	if (t1 < t2) then
		exit(-1)
	else if (t1 > t2) then
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
	s1 := c1.State; s2 := c2.State;
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
	if (length(self.coord) > 0) then
		self.dist := get_dist_from_coord(coord, self.coord);
end;

constructor TCrew.Create(GpsId : Integer);
begin
	inherited Create;
	self.GpsId := GpsId;
	self.coords := TStringList.Create;
	self.coords_times := TStringList.Create;
	self.CrewID := -1;
	self.State := -1; // состояние: 1 - свободен, 3 - на заказе;
	self.Code := '';
	self.name := '';
	self.state_as_string := '';
	self.coord := ''; // текущая (самая свежая) координата GPS
	self.dist := -1.0; // расстояние до адреса подачи (АП)
	self.time := -1; // время подъезда к АП в минутах;
	self.orderId := -1; // ID заказа занятого экипажа
	self.order_way := ''; // маршрут занятого экипажа
end;

function TCrew.is_crew_was_in_coord(coord : string) : boolean;
const RADIUS = 100.0;
var cc : string;
	d : double;
begin
	for cc in self.coords do
	begin
		d := get_dist_from_coord(coord, cc);
		if (d >= 0) and (d < RADIUS) then
			exit(True);
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

var sl : TStringList;
	s, s1, s2 : string;
	crew : TCrew;
	count, i : Integer;
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
		exit();
	self.time := m;
	self.time_as_string := IntToStr(m mod 60) + ' мин.';
	if m > 59 then
		self.time_as_string := IntToStr(m div 60) + ' ч. ' + self.time_as_string;
end;

function TCrew.sort_coords_by_time_desc : Integer;
var sl : TStringList;
	s : string;
	crew : TCrew;
	count, i : Integer;
begin
	count := IfThen(self.coords.count < self.coords_times.count, self.coords.count, self.coords_times.count);
	if (count <= 0) then
		exit(-1);
	sl := TStringList.Create();
	for i := 0 to (count - 1) do
		sl.Append(self.coords_times.Strings[i] + '|' + self.coords.Strings[i]);
	sl.Sorted := True;
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

constructor TCrewList.Create();
begin
	inherited Create;
	self.Crews := TList.Create();
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

function TCrewList.delete_all_none_crewId : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		if (self.crew(pp).CrewID = -1) then
			self.Crews.Delete(self.Crews.IndexOf(pp));
	exit(0);
end;

function TCrewList.delete_all_none_orderId() : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		if (self.crew(pp).State = CREW_NAZAKAZE) then
			if (self.crew(pp).orderId = -1) then
				self.Crews.Delete(self.Crews.IndexOf(pp));
	exit(0);
end;

function TCrewList.del_all_non_work_crews : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		if self.crew(pp).State in [CREW_SVOBODEN, CREW_NAZAKAZE] then
			pass
		else
			self.Crews.Delete(self.Crews.IndexOf(pp));
	exit(0);
end;

function TCrewList.findByCrewId(ID : Integer) : Pointer;
begin
	result := self.findById(ID, false);
end;

function TCrewList.findByGpsId(ID : Integer) : Pointer;
begin
	result := self.findById(ID, True);
end;

function TCrewList.findById(ID : Integer; gps : boolean) : Pointer;
var
	crew : TCrew;
	pcrew : PTCrew;
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

function TCrewList.get_gpsid_list_as_string : string;
begin
	result := self.get_id_list_as_string(True);
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
	Delete(s, 1, 1);
	result := s;
end;

function TCrewList.get_nonfree_crewid_list_as_string() : string;
var s : string;
	pp : Pointer;
begin
	s := '';
	for pp in self.Crews do
		if (self.crew(pp).State = CREW_NAZAKAZE) and (self.crew(pp).CrewID > -1) then
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
	result := self.isCrewInList(ID, True);
end;

function TCrewList.set_ap(street, house, korpus, gps : string) : Integer;
begin
	self.ap_street := street;
	self.ap_house := house;
	self.ap_korpus := korpus;
	self.ap_gps := gps;
end;

function TCrewList.set_crewId_by_gpsId(list : TStringList) : Integer;
var sl : TStringList;
	s : string;
	crew : TCrew;
begin
	sl := TStringList.Create();
	// sl.Delimiter := '|';
	for s in list do
	begin
		sl.Clear();
		sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		crew := self.crewByGpsId(StrToInt(sl.Strings[0]));
		crew.CrewID := StrToInt(sl.Strings[1]);
		crew.Code := sl.Strings[2];
		crew.name := sl.Strings[3];
		crew.State := StrToInt(sl.Strings[4]);
		if crew.State = 1 then
			crew.state_as_string := 'Свободен'
		else
			crew.state_as_string := 'На заказе';
	end;
	self.delete_all_none_crewId(); self.delete_all_none_crewId();
	FreeAndNil(sl);
	exit(0);
end;

function TCrewList.set_crews_dist(coord : string) : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		self.crew(pp).calc_dist(coord);
	exit(0);
end;

function TCrewList.set_crews_orderId(list : TStringList) : Integer;
var sl : TStringList;
	s : string;
	crew : TCrew;
begin
	sl := TStringList.Create();
	for s in list do
	begin
		sl.Clear();
		sl.Text := StringReplace(s, '|', #13#10, [rfReplaceAll]);
		crew := self.crewByCrewId(StrToInt(sl.Strings[0]));

		if (crew.orderId <> -1) or (crew.State <> CREW_NAZAKAZE) then
			Continue; // если уже назначен заказ, то пропускаем,
		// т.к. для экипажа на заказе м.б. несколько
		// заказов в состоянии исполнения

		if sl.Strings[5] <> '' then
			Continue; // пропускаем заказы с промежуточными остановками;

		crew.orderId := StrToInt(sl.Strings[1]);
		// sl.Strings[2]; // - пропускаем
		crew.order_way := sl.Strings[3] + ';' + sl.Strings[4];
	end;
	self.delete_all_none_orderId(); self.delete_all_none_orderId();
	FreeAndNil(sl);
	exit(0);
end;

procedure TCrewList.set_crews_state_as_string;
var pp : Pointer;
begin
	for pp in self.Crews do
		if self.crew(pp).State = 1 then
			self.crew(pp).state_as_string := 'Свободен'
		else
			self.crew(pp).state_as_string := 'На заказе';
end;

function TCrewList.set_crews_state_by_crewId(var list : TStringList) : Integer;
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
		if crew.State = -1 then
			crew.State := StrToInt(sstate);
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
			exit(True);
	end;
	exit(false);
end;

{ TAdres }

procedure TAdres.Clear;
begin
	self.street := '';
	self.house := '';
	self.korpus := '';
	self.gps := '';
end;

constructor TAdres.Create(street, house, korpus, gps : string);
begin
	inherited Create;
	self.street := street;
	self.house := house;
	self.korpus := korpus;
	self.gps := gps;
end;

procedure TAdres.setAdres(street, house, korpus, gps : string);
begin
	self.street := street;
	self.house := house;
	self.korpus := korpus;
	self.gps := gps;
end;

end.
