unit crew;

interface

uses crew_utils, Classes, SysUtils, Math, SHDocVw, MSHTML, ActiveX;

type
	TCrew = class(TObject)
		CrewID : Integer;
		GpsId : Integer;
		State : Integer; // ���������: 1 - ��������, 3 - �� ������;
		Code : string;
		name : string;
		coord : string; // ������� (����� ������) ���������� GPS
		dist : double; // ���������� �� ������ ������ (��)
		time : Integer; // ����� �������� � �� � �������;
		coords : TStringList; // gps-���� �� ��������� ���������� �������;
		coords_times : TStringList; // gps-���� �� ��������� ���������� �������;
		constructor Create(GpsId : Integer);
		function set_current_coord() : Integer;
		function append_coords(coord : string; time : string) : Integer;
	end;

type
	PTCrew = ^TCrew;

type
	TCrewList = class(TObject)
		Crews : TList;
		AdresPodachi : string;
		ap_gps : string;
		constructor Create();
		function crew(p : Pointer) : TCrew;
		function crewByGpsId(GpsId : Integer) : TCrew;
		function Append(GpsId : Integer) : Pointer; // add new crew to list by CREW_GPS_ID
		function isCrewInList(ID : Integer; GPS : boolean) : boolean;
		function isCrewIdInList(ID : Integer) : boolean;
		function isGpsIdInList(ID : Integer) : boolean;
		function findByCrewId(ID : Integer) : Pointer;
		function findByGpsId(ID : Integer) : Pointer;

		function get_gpsid_list_as_string() : string;
		function get_crewid_list_as_string() : string;
		function delete_all_none_crewId() : Integer;
		function set_crewId_by_gpsId(list : TStringList) : Integer;
		function set_current_crews_coord() : Integer;
	private
		function findById(ID : Integer; GPS : boolean) : Pointer;
		function get_id_list_as_string(GPS : boolean) : string;

	end;

implementation

{ TCrew }

function TCrew.append_coords(coord, time : string) : Integer;
begin
	self.coords.Append(coord);
	self.coords_times.Append(time);
	exit(0);
end;

constructor TCrew.Create(GpsId : Integer);
begin
	inherited Create;
	self.GpsId := GpsId;
	self.coords := TStringList.Create;
	self.coords_times := TStringList.Create;
	self.CrewID := -1;
	self.State := -1; // ���������: 1 - ��������, 3 - �� ������;
	Code := '';
	name := '';
	coord := ''; // ������� (����� ������) ���������� GPS
	dist := -1.0; // ���������� �� ������ ������ (��)
	time := -1; // ����� �������� � �� � �������;
end;

function TCrew.set_current_coord() : Integer;
var sl : TStringList;
	s : string;
	crew : TCrew;
	count, i : Integer;
begin
	count := IfThen(self.coords.count < self.coords_times.count, self.coords.count, self.coords_times.count);
	if (count <= 0) then
		exit(0);
	sl := TStringList.Create();
	for i := 0 to (count - 1) do
		sl.Append(self.coords_times.Strings[i] + '|' + self.coords.Strings[i]);
	sl.Sorted := True;
	self.coord := get_substr(sl.Strings[sl.Count -1], '|', '');
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
	result := self.findById(ID, True);
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
	result := self.get_id_list_as_string(True);
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
	result := self.isCrewInList(ID, True);
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

function TCrewList.set_current_crews_coord : Integer;
var pp : Pointer;
begin
	for pp in self.Crews do
		self.crew(pp).set_current_coord();
	exit(0);
end;

function TCrewList.isCrewInList(ID : Integer; GPS : boolean) : boolean;
var
	crew : TCrew;
	pp : Pointer;
begin
	for pp in self.Crews do
	begin
		crew := self.crew(pp);
		if ((not GPS) and (crew.CrewID = ID)) or (GPS and (crew.GpsId = ID)) then
			exit(True);
	end;
	exit(false);
end;

end.
