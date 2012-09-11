unit crew_utils;

interface

uses StrUtils, DateUtils, SysUtils, Classes, EncdDecd, Math, Grids;

type
	TMyGrid = class(TCustomGrid)
	end;

procedure pass;

procedure del_grid_row(var Grid : TStringGrid; Row : Integer);
function replace_time(const value : string; const MyTime : TDateTime) : string;
function replace_day(const value : string; const MyTime : TDateTime) : string;
function replace_hour(const value : string; const MyTime : TDateTime) : string;
function replace_minute(const value : string; const MyTime : TDateTime) : string;

function dotStrtoFloat(s : string) : double;
function float_to_dotstr_2_6(f : real) : string;
function float_to_dotstr_8_2(f : double) : string;
function get_dist_from_coord(scoord1, scoord2 : string) : double;

function reverseStringList(var list : TStringList) : Integer;
function param64(s : string) : string;
function date_to_full(date : string) : string; overload;
function date_to_full(date : TDateTime) : string; overload;
function time_without_date(full_date : string) : string; overload;
function time_without_date(dt : TDateTime) : string; overload;
function source_time_to_datetime(date : string) : TDateTime;
function get_substr(value : string; sub1, sub2 : string) : string;
procedure RemoveDuplicates(const stringList : TStringList);
function s_2_6(sc : string) : string;

implementation

procedure pass;
begin
end;

function float_to_dotstr_2_6(f : real) : string;
begin
	result := StringReplace(FloatToStrF(f, ffFixed, 8, 6), ',', '.', [rfReplaceAll]);
end;

function float_to_dotstr_8_2(f : double) : string;
begin
	result := StringReplace(FloatToStrF(f, ffFixed, 8, 2), ',', '.', [rfReplaceAll]);
end;


function s_2_6(sc : string) : string;
begin
	result := float_to_dotstr_2_6(dotStrtoFloat(sc));
end;

function reverseStringList(var list : TStringList) : Integer;
var i, c : Integer;
begin
	c := list.Count;
	if c <= 0 then
		exit(-1);
	for i := 0 to (c div 2) - 1 do
		list.Exchange(i, c - 1 - i);
	exit(0);
end;

function param64(s : string) : string;
var ss : RawByteString;
	p : Pointer;
begin
	ss := UTF8Encode(s);
	p := Pointer(ss);
	ss := EncodeBase64(p, length(ss));
	ss := StringReplace(ss, chr(10), '', [rfReplaceAll]);
	ss := StringReplace(ss, chr(13), '', [rfReplaceAll]);
	ss := StringReplace(ss, '+', ';', [rfReplaceAll]);
	ss := StringReplace(ss, '=', '_', [rfReplaceAll]);
	result := ss;
end;

function date_to_full(date : string) : string;
var y, m, d, h, n, s : string;
	// MySettings : TFormatSettings;
begin
	date := ReplaceStr(date, ' ', '');
	date := ReplaceStr(date, '.', '');
	date := ReplaceStr(date, ':', '');
	date := ReplaceStr(date, '-', '');
	date := ReplaceStr(date, '_', '');
	if length(date) = 13 then
		Insert('0', date, 9);

	d := copy(date, 1, 2);
	m := copy(date, 3, 2);
	y := copy(date, 5, 4);
	h := copy(date, 9, 2);
	n := copy(date, 11, 2);
	s := copy(date, 13, 2);
	result := y + '-' + m + '-' + d + ' ' + h + ':' + n + ':' + s;

	// MySettings.DateSeparator := '-';
	// MySettings.TimeSeparator := ':';
	// MySettings.ShortDateFormat := 'yyyy-mm-dd';
	// MySettings.ShortTimeFormat := 'hh:nn:ss';
	// StrToDateTime(result, MySettings);
end;

function date_to_full(date : TDateTime) : string;
var s : string;
begin
	DateTimeToString(s, 'yyyy-mm-dd hh:nn:ss', date);
	exit(s);
end;

function time_without_date(full_date : string) : string;
begin
	result := copy(full_date, 12, 8);
end;

function time_without_date(dt : TDateTime) : string;
begin
	result := time_without_date(date_to_full(dt));
end;

function source_time_to_datetime(date : string) : TDateTime;
var y, m, d, h, n, s : string;
	MySettings : TFormatSettings;
begin
	MySettings.DateSeparator := '-';
	MySettings.TimeSeparator := ':';
	MySettings.ShortDateFormat := 'yyyy-mm-dd';
	MySettings.ShortTimeFormat := 'hh:nn:ss';
	result := StrToDateTime(date, MySettings);
	exit(result);

	// 'yyyy-mm-dd hh:nn:ss'
	// y := copy(date, 1, 4);
	// m := copy(date, 6, 2);
	// d := copy(date, 9, 2);
	// h := copy(date, 12, 2);
	// n := copy(date, 15, 2);
	// s := copy(date, 18, 2);
	// result := d + '/' + m + '/' + y + ' ' + h + ':' + n + ':' + s;
	// 'dd/mm/yyyy hh:nn:ss'
end;

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
		ad := arctan(y / x);
		dist := ad * RAD;
		result := abs(dist);
		// result := (1852.0 * 60.0) * sqrt(sqr(long2 - long1) + sqr(lat2 - lat1));
	end;

	function s2f(sc : string; var long, lat : double) : boolean;
	var slat, slong : string;
	begin
		result := false;
		sc := StringReplace(sc, ' ', '', [rfReplaceAll]); // ReplaceStr(sc, ' ', '');
		slong := get_substr(sc, '', ','); slat := get_substr(sc, ',', '');
		if (slong = '') or (slat = '') then
			exit();
		try
			long := dotStrtoFloat(slong);
			lat := dotStrtoFloat(slat);
			result := true;
		except
			exit();
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
var p1, p2 : Integer; res, s : string;
begin
	res := value;

	if sub1 = '' then
		p1 := 1
	else
		p1 := pos(sub1, res);
	if sub2 = '' then
		p2 := length(res) + 1
	else
		p2 := posex(sub2, res, p1 + length(sub1));

	if (p1 > 0) and (p2 > 0) then
	begin
		p1 := p1 + length(sub1);
		s := copy(res, p1, p2 - p1);
		res := s;
	end
	else
		res := '';
	result := res;
end;

function replace_day(const value : string; const MyTime : TDateTime) : string;
var p1, p2, n : Integer;
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
					if (n >= -31) and (n <= 31) then
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
var p1, p2, n : Integer;
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
					if (n >= -23) and (n <= 23) then
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
var p1, p2, n : Integer;
	res, s, s2 : string;

begin
	res := value;
	repeat
		p1 := pos('{Last_minute_', res);
		p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 13; s := copy(res, p1, p2 - p1);
			if s <> '' then
			begin
				try
					n := strtoint(s);
					if (n >= -59) and (n <= 59) then
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

function replace_second(const value : string; const MyTime : TDateTime) : string;
var p1, p2, n : Integer;
	res, s, s2 : string;

begin
	res := value;
	repeat
		p1 := pos('{Last_second_', res);
		p2 := posex('}', res, p1);
		if (p1 > 0) and (p2 > 0) then
		begin
			p1 := p1 + 13; s := copy(res, p1, p2 - p1);
			if s <> '' then
			begin
				try
					n := strtoint(s);
					if (n >= -59) and (n <= 59) then
					begin
						DateTimeToString(s2, 'yyyy-mm-dd hh:nn:ss', IncSecond(MyTime, n * (-1)));
						res := ReplaceStr(res, '{Last_second_' + s + '}', s2);
					end;
				except
					n := 0;
				end;
			end;
		end;
	until (p1 = 0) or (p2 = 0) or (n <= 0);

	result := res;
end;

function replace_time(const value : string; const MyTime : TDateTime) : string;
begin
	result := value;
	if pos('{Last_second_', value) > 0 then
		result := replace_second(value, MyTime)
	else
		if pos('{Last_minute_', value) > 0 then
			result := replace_minute(value, MyTime)
		else
			if pos('{Last_hour_', value) > 0 then
				result := replace_hour(value, MyTime)
			else
				if pos('{Last_day_', value) > 0 then
					result := replace_day(value, MyTime);
end;

procedure RemoveDuplicates(const stringList : TStringList);
var buffer : TStringList; cnt : Integer;
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

procedure del_grid_row(var Grid : TStringGrid; Row : Integer);
begin
	TMyGrid(Grid).DeleteRow(Row);
end;

end.
