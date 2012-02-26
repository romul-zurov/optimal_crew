unit crew_utils;

interface

uses StrUtils, DateUtils, SysUtils, Classes;

function replace_day(const value : string; const MyTime : TDateTime) : string;
function replace_hour(const value : string; const MyTime : TDateTime) : string;
function replace_minute(const value : string; const MyTime : TDateTime) : string;

procedure RemoveDuplicates(const stringList : TStringList);

implementation

function replace_day(const value : string; const MyTime : TDateTime) : string;
var
	p1, p2, n : integer;
	res, s, s2 : string;

begin
	res := value;
	repeat
		p1 := pos('{Last_day_', res);
		p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 10;
			s := copy(res, p1, p2 - p1);
			if s <> '' then
			begin
				try
					n := strtoint(s);
					if (n > 0) and (n <= 31) then
					begin
						DateTimeToString(s2, 'yyyy-mm-dd hh:nn:ss', IncDay(MyTime, n * (-1)));
						res := ReplaceStr(res, '{Last_day_' + s + '}', s2);
					end;
				except
					n := 0;
				end;
			end;
		end;
	until (p1 = 0) or (p2 = 0) or (n <= 0);

	result := res;
end;

function replace_hour(const value : string; const MyTime : TDateTime) : string;
var
	p1, p2, n : integer;
	res, s, s2 : string;
begin
	res := value;
	repeat
		p1 := pos('{Last_hour_', res);
		p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 11;
			s := copy(res, p1, p2 - p1);
			if s <> '' then
			begin
				try
					n := strtoint(s);
					if (n > 0) and (n <= 23) then
					begin
						DateTimeToString(s2, 'yyyy-mm-dd hh:nn:ss', IncHour(MyTime, n * (-1)));
						res := ReplaceStr(res, '{Last_hour_' + s + '}', s2);
					end;
				except
					n := 0;
				end;
			end;
		end;
	until (p1 = 0) or (p2 = 0) or (n <= 0);

	result := res;
end;

function replace_minute(const value : string; const MyTime : TDateTime) : string;
var
	p1, p2, n : integer;
	res, s, s2 : string;

begin
	res := value;
	repeat
		p1 := pos('{Last_minute_', res);
		p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 13;
			s := copy(res, p1, p2 - p1);
			if s <> '' then
			begin
				try
					n := strtoint(s);
					if (n > 0) and (n <= 59) then
					begin
						DateTimeToString(s2, 'yyyy-mm-dd hh:nn:ss', IncMinute(MyTime, n * (-1)));
						res := ReplaceStr(res, '{Last_minute_' + s + '}', s2);
					end;
				except
					n := 0;
				end;
			end;
		end;
	until (p1 = 0) or (p2 = 0) or (n <= 0);

	result := res;
end;


procedure RemoveDuplicates(const stringList : TStringList);
var
	buffer : TStringList;
	cnt : integer;
begin
	stringList.Sort;
	buffer := TStringList.Create;
	try
		buffer.Sorted := True;
		buffer.Duplicates := dupIgnore;
		buffer.BeginUpdate;
		for cnt := 0 to stringList.Count - 1 do
			buffer.Add(stringList[cnt]);
		buffer.EndUpdate;
		stringList.Assign(buffer);
	finally
		FreeandNil(buffer);
	end;
end;

end.
