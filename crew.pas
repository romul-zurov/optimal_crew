unit crew;

interface

uses Classes, SysUtils;

type
	TCrew = class(TObject)
		CrewID : Integer;
		GpsId : Integer;
		State : Integer; // состояние: 1 - свободен, 3 - на заказе;
		Code : string;
		name : string;
		coord : string; // текущая (самая свежая) координата GPS
		dist : double; // расстояние до адреса подачи (АП)
		time : Integer; // время подъезда к АП в минутах;
		coords : TStringList; // gps-трек за выбранный промежуток времени;
		coords_times : TStringList; // gps-трек за выбранный промежуток времени;
		constructor Create(GpsId : Integer);
	end;

type
	PTCrew = ^TCrew;

type
	TCrewList = class(TObject)
		Crews : TList;
		constructor Create();
		function crew(p : Pointer) : TCrew;
		function crewByGpsId(GpsId : Integer) : TCrew;
		function Append(GpsId : Integer) : Pointer; // add new crew to list by CREW_GPS_ID
		function isCrewInList(ID : Integer; GPS : boolean) : boolean;
		function isCrewIdInList(ID : Integer) : boolean;
		function isGpsIdInList(ID : Integer) : boolean;
		function findByCrewId(ID : Integer) : Pointer;
		function findByGpsId(ID : Integer) : Pointer;
		function findById(ID : Integer; GPS : boolean) : Pointer;
		function get_id_list_as_string(GPS : boolean) : string;
		function get_gpsid_list_as_string() : string;
		function get_crewid_list_as_string() : string;
		function delete_all_none_crewId() : Integer;
		function set_crewId_by_gpsId(list : TStringList) : Integer;
	end;

implementation

{ TCrew }

constructor TCrew.Create(GpsId : Integer);
begin
	inherited Create;
	self.GpsId := GpsId;
	self.coords := TStringList.Create;
	self.coords_times := TStringList.Create;
	self.CrewID := -1;
	self.State := -1; // состояние: 1 - свободен, 3 - на заказе;
	Code := '';
	name := '';
	coord := ''; // текущая (самая свежая) координата GPS
	dist := -1.0; // расстояние до адреса подачи (АП)
	time := -1; // время подъезда к АП в минутах;
end;

{ TCrewList }

function TCrewList.Append(GpsId : Integer) : Pointer;
var i : Integer;
begin
	i := self.Crews.Add(TCrew.Create(GpsId));
	result := Pointer(self.Crews[i]);
end;

constructor TCrewList.Create;
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
	result := 0;
end;

function TCrewList.findByCrewId(ID : Integer) : Pointer;
begin
	result := self.findById(ID, false);
end;

function TCrewList.findByGpsId(ID : Integer) : Pointer;
begin
	result := self.findById(ID, true);
end;

function TCrewList.findById(ID : Integer; GPS : boolean) : Pointer;
var
	crew : TCrew;
	pcrew : PTCrew;
begin
	result := nil;
	for pcrew in self.Crews do
	begin
		crew := TCrew(pcrew);
		if ((not GPS) and (crew.CrewID = ID)) or (GPS and (crew.GpsId = ID)) then
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
	result := self.get_id_list_as_string(true);
end;

function TCrewList.get_id_list_as_string(GPS : boolean) : string;
var s : string;
	pp : Pointer;
begin
	s := '';
	for pp in self.Crews do
		if GPS then
			s := s + ',' + IntToStr(self.crew(pp).GpsId)
		else
			s := s + ',' + IntToStr(self.crew(pp).CrewID);
	Delete(s, 1, 1);
	result := s;
end;

function TCrewList.isCrewIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, false);
end;

function TCrewList.isGpsIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, true);
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
	end;
	self.delete_all_none_crewId();
	FreeAndNil(sl);
	result := 0;
end;

function TCrewList.isCrewInList(ID : Integer; GPS : boolean) : boolean;
var
	crew : TCrew;
	pcrew : PTCrew;
begin
	result := false;
	for pcrew in self.Crews do
	begin
		crew := TCrew(pcrew);
		// if crew.CrewID = ID then
		if ((not GPS) and (crew.CrewID = ID)) or (GPS and (crew.GpsId = ID)) then
		begin
			result := true;
			exit();
		end;
	end;
end;

end.
