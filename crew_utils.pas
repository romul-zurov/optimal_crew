unit crew_utils;

interface

uses StrUtils, DateUtils, SysUtils, Classes;

function replace_day(const value : string; const MyTime : TDateTime) : string;
function replace_hour(const value : string; const MyTime : TDateTime) : string;
function replace_minute(const value : string; const MyTime : TDateTime) : string;

function dotStrtoFloat(s : string) : double;
function get_dist_from_coord(scoord1, scoord2 : string) : double;

function get_substr(value : string; sub1, sub2 : string) : string;
procedure RemoveDuplicates(const stringList : TStringList);

implementation

function dotStrtoFloat(s : string) : double;
begin
	if pos('.', s) > 0 then
		s := ReplaceStr(s, '.', ',');
	result := StrToFloat(s);
end;

function get_dist_from_coord(scoord1, scoord2 : string) : double;
	function ret_dist(long1, lat1, long2, lat2 : double) : double;
	const PI = 3.14159;
	const RAD = 6372795.0;
	var cl1, cl2, sl1, sl2, cdelta, sdelta, delta, ad, dist, x, y : double;
	begin
		lat1 := lat1 * PI / 180; lat2 := lat2 * PI / 180;
		long1 := long1 * PI / 180; long2 := long2 * PI / 180;

		// #косинусы и синусы широт и разницы долгот
		cl1 := cos(lat1);
		cl2 := cos(lat2);
		sl1 := sin(lat1);
		sl2 := sin(lat2);
		delta := long2 - long1;
		cdelta := cos(delta);
		sdelta := sin(delta);

		// #вычисления длины большого круга
		y := sqrt(sqr(cl2 * sdelta) + sqr(cl1 * sl2 - sl1 * cl2 * cdelta));
		x := sl1 * sl2 + cl1 * cl2 * cdelta;
		ad := arctan(y/x);
		dist := ad * RAD;
		result := dist;
		// result := (1852.0 * 60.0) * sqrt(sqr(long2 - long1) + sqr(lat2 - lat1));
	end;

	function s2f(sc : string; var long, lat : double) : boolean;
	var slat, slong : string;
	begin
		result := false;
		try
			slong := get_substr(sc, '', ','); slat := get_substr(sc, ',', ''); long := dotStrtoFloat(slong);
			lat := dotStrtoFloat(slat); result := true;
		finally
		end;
	end;

var lat1, long1, lat2, long2 : double;
begin
	if s2f(scoord1, long1, lat1) and s2f(scoord2, long2, lat2) then
		result := ret_dist(long1, lat1, long2, lat2)
	else
		result := -1.0;
end;

function get_substr(value : string; sub1, sub2 : string) : string;
var p1, p2 : integer; res, s : string;
begin
	res := value;

	if sub1 = '' then
		p1 := 1
	else
		p1 := pos(sub1, res);
	if sub2 = '' then
		p2 := length(res)
	else
		p2 := posex(sub2, res, p1);

	if (p1 > 0) and (p2 > 0) then
	begin
		p1 := p1 + length(sub1); s := copy(res, p1, p2 - p1); res := s;
	end
	else
		res := '';
	result := res;
end;

function replace_day(const value : string; const MyTime : TDateTime) : string;
var p1, p2, n : integer;
	res, s, s2 : string;

begin
	res := value;
	repeat
		p1 := pos('{Last_day_', res); p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 10; s := copy(res, p1, p2 - p1);
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
var p1, p2, n : integer;
	res, s, s2 : string;
begin
	res := value;
	repeat
		p1 := pos('{Last_hour_', res); p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 11; s := copy(res, p1, p2 - p1);
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
var p1, p2, n : integer;
	res, s, s2 : string;

begin
	res := value;
	repeat
		p1 := pos('{Last_minute_', res); p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 13; s := copy(res, p1, p2 - p1);
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
var buffer : TStringList; cnt : integer;
begin
	stringList.Sort; buffer := TStringList.Create;
	try
		buffer.Sorted := true; buffer.Duplicates := dupIgnore;
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
