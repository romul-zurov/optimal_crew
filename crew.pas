unit crew;

interface

uses Classes, SysUtils;

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
	end;

type
	PTCrew = ^TCrew;

type
	TCrewList = class(TObject)
		Crews : TList;
		constructor Create();
		function Append(ID : Integer) : Pointer;
		function isCrewInList(ID : Integer; GPS : boolean) : boolean;
		function isCrewIdInList(ID : Integer) : boolean;
		function isGpsIdInList(ID : Integer) : boolean;
		function findByCrewId(ID : Integer) : Pointer;
		function findByGpsId(ID : Integer) : Pointer;
		function findById(ID : Integer; GPS : boolean) : Pointer;
	end;

implementation

{ TCrew }

constructor TCrew.Create(GpsId : Integer);
begin
	inherited Create;
	self.GpsId := GpsId;
	self.coords := TStringList.Create;
	self.coords_times := TStringList.Create;
end;

{ TCrewList }

function TCrewList.Append(ID : Integer) : Pointer;
var i : Integer;
begin
	i := self.Crews.Add(TCrew.Create(ID));
	result := Pointer(self.Crews[i]);
end;

constructor TCrewList.Create;
begin
	inherited Create;
	self.Crews := TList.Create();
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

function TCrewList.isCrewIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, false);
end;

function TCrewList.isGpsIdInList(ID : Integer) : boolean;
begin
	result := self.isCrewInList(ID, true);
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



// function TCrewList.isCrewInList(sID : string) : boolean;
// begin
// result := self.isCrewInList(StrToInt(sID));
// end;

end.
