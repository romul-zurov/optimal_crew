unit crew_globals;

interface

uses crew_utils, // utils from robocap and mine
	Generics.Collections, // for forward class definition
	Controls, Forms, Classes, SysUtils, Math, SHDocVw, MSHTML, ActiveX, //
	windows, //
	IBQuery, IBDataBase, DB, WinInet, StrUtils, ComCtrls, IniFiles, ExtCtrls;

const CREW_SVOBODEN = 1;

const CREW_NAZAKAZE = 3;

const CREW_MOVE_DIST = 100.0; // если экипаж изменил координаты более чем -
	// . 							пересчитываем время заказа

const CREW_RADIUS = 150.0; // радиус "попадания" экипажа в адрес, метров

const ORDER_DONE = 4; // согласно ORDER_STATES

const ORDER_CANCEL = 37; // "отменён", согласно ORDER_STATES

const ORDER_DISCONTNUED = 5; // "прекращён", согласно ORDER_STATES

const ORDER_NO_CREWS = 6; // "нет машин", согласно ORDER_STATES

const ORDER_VODITEL_PODTVERDIL = 2; // согласно ORDER_STATES

const ORDER_KLIENT_NA_BORTU = 29; // согласно ORDER_STATES

const ORDER_PRIGLASITE_KILIENTA = 31; // согласно ORDER_STATES

const ORDER_KLIENT_NE_VYSHEL = 32; // согласно ORDER_STATES

const ORDER_SMS_PRIGL = 38; // согласно ORDER_STATES

const ORDER_TEL_PRIGL = 40; // согласно ORDER_STATES

const ORDER_CREW_NO_COORD = -2; // у экипажа нет координат, просчёт маршрута невозможен

const ORDER_BAD_ADRES = -4; // адрес(а) маршрута заказа не определются картой,
	// . 						просчёт маршрута невозможен

const ORDER_WAY_ERROR = -8; // ошибка при просчёте маршрута, время не определено

const COORDS_BUF_SIZE = '{Last_hour_2}'; // размер буфера координат экипажа, в часах

const DEBUG_MEASURE_TIME = '''2011-10-03 13:57:50'''; // for back-up base

function get_zapros(surl : string) : string;
function create_order_and_crew_states(var IBQuery : TIBQuery) : Integer;
function sql_select(var query : TIBQuery; sel : string) : Integer;
function get_sql_stringlist(var query : TIBQuery; sel : string) : Tstringlist;
function get_gps_coords_for_adres(ulica, dom, korpus : string) : string;
function get_crew_way_time(var points : TList; var dist_way : double) : Integer;
procedure show_status(status : string);

type
	TAdres = class(TObject)
		street : string;
		house : string;
		korpus : string;
		gps : string;
		constructor Create(street, house, korpus, gps : string);
		procedure setAdres(street, house, korpus, gps : string);
		procedure Clear();
		function isEmpty() : boolean;
		function get_as_string() : string;
	end;

var
	sql_string_list : Tstringlist;
	DEBUG : boolean;
	DEBUG_SDATE_FROM : string;
	DEBUG_SDATE_TO : string;
	cur_time : TDateTime;
	ac_taxi_url : string;
	PHP_Url : string;
	order_states : Tstringlist;
	crew_states : Tstringlist;
	PGlobalStatusBar : Pointer;
	// browser_form : Tform;
	browser_panel : TPanel;

	main_db : TIBDatabase;
	main_ta : TIBTransaction;
	main_ds : TDataSource;
	main_ibquery : TIBQuery;

implementation

function get_crew_way_time(var points : TList; var dist_way : double) : Integer;
	procedure add_s(var s : string; s1, s2, s3, s4 : string; num : Integer);
	var ss : string;
	begin
		case num of
			0 :
				ss := 'from';
			1 :
				ss := 'int';
			-1 :
				ss := 'to';
		end;
		s := s + 'point_' + ss + '[obj][]=' + s1 + '&';
		s := s + 'point_' + ss + '[house][]=' + s2 + '&';
		s := s + 'point_' + ss + '[corp][]=' + s3 + '&';
		s := s + 'point_' + ss + '[coords][]=' + s4 + '&';
	end;

var i, c, n, t : Integer;
	a : TAdres;
	surl, res, dist_res : string;
begin
	dist_way := -1;
	c := points.Count;
	if c < 2 then
		exit(-1);
	surl := ac_taxi_url + 'order?i_generate_address=1&service=0&';
	for i := 0 to c - 1 do
	begin
		if i = 0 then
			n := 0
		else if i = (c - 1) then
			n := -1
		else
			n := 1;
		a := TAdres(points.Items[i]);
		add_s(surl, a.street, a.house, a.korpus, a.gps, n);
	end;
	show_status(surl);
	surl := '"' + surl + '"' + ' "DayVremyaPuti" "</td>"';
	surl := param64(surl);
	surl := PHP_Url + '?param=' + surl;
	res := get_zapros(surl);

	show_status(res);
	dist_res := get_substr(res, 'Маршрут (без учета пробок): ', ' км.');
	res := get_substr(res, 'Время (с учетом пробок): ', ' мин.');
	if (length(res) > 0) and (pos('Error', res) < 1) then
		try
			dist_way := dotStrtoFloat(dist_res);
			t := StrToInt(res);
			exit(t);
		except
			exit(-1);
		end;
	exit(-1);
end;

function get_gps_coords_for_adres(ulica, dom, korpus : string) : string;
	function get_coords() : string;
	var surl : string;
	begin
		surl := ac_taxi_url + 'order?i_generate_address=1&service=0&';
		surl := surl + 'point_from[obj][]=' + ulica + '&';
		surl := surl + 'point_from[house][]=' + dom + '&';
		surl := surl + 'point_from[corp][]=' + korpus + '&';
		surl := surl + 'point_to[obj][]=' + ulica + '&';
		surl := surl + 'point_to[house][]=' + dom + '&';
		surl := surl + 'point_to[corp][]=' + korpus + '&';

		surl := '"' + surl + '"' + ' "DayGPSKoordinatPoAdresu" "foo"';
		surl := param64(surl);
		surl := PHP_Url + '?param=' + surl;
		show_status('Запрос координат для адреса ' + ulica + ' ' + dom + ' ' + korpus + '...');
		result := get_zapros(surl);
		show_status(result);
	end;

var surl, res : string;
begin
	res := get_coords();
	if pos('Error', res) > 0 then
		// res := 'Error';
		res := '';
	result := res;
end;

function html_to_string(WB : TWebBrowser) : string;
var
	StringStream : TStringStream;
	Stream : IStream;
	PersistStream : IPersistStreamInit;
	res : string;
begin
	res := 'Error';
	PersistStream := WB.Document as IPersistStreamInit;
	StringStream := TStringStream.Create('');
	Stream := TStreamAdapter.Create(StringStream, soReference) as IStream;
	try
		PersistStream.Save(Stream, true);
		res := StringStream.DataString;
	finally
		StringStream.Free;
	end;
	res := get_substr(res, '&lt;&lt;&lt;', '&gt;&gt;&gt;');
	result := res;
end;

function get_zapros_tmp_QWERTYUI(surl : string) : string;
var
	form : Tform;
	browser : TWebBrowser;
	s : string;
	hSession, hfile, hRequest, hUrl : hInternet;
begin
	form := Tform.Create(nil);
	browser := TWebBrowser.Create(nil);
	try
		InternetSetOption(nil, INTERNET_OPTION_END_BROWSER_SESSION, nil, 0); // end IE session
		sleep(900);
		TWinControl(browser).Parent := form;
		// TWinControl(browser).Parent := browser_form;
		browser.Silent := false;
		browser.Align := alClient;
		form.Width := 400;
		form.Height := 100;
		form.Show;
		// if not DEBUG then
		// form.Hide;
		hSession := InternetOpen('InetURL:/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
		hUrl := InternetOpenURL(hSession, PChar(PHP_Url), nil, 0, 0, 0);
		// if IsConnectedToInternet() then
		// if assigned(hSession) then
		if hUrl <> nil then
		begin
			browser.Navigate(surl);
			while browser.ReadyState < READYSTATE_COMPLETE do
				Application.ProcessMessages;
			s := html_to_string(browser);
			InternetCloseHandle(hSession);
		end
		else
		begin
			s := '';
			show_status('Нет соединения с интернетом');
		end;

		if DEBUG then
			sleep(1000);
	finally
		// InternetSetOption(nil, INTERNET_OPTION_END_BROWSER_SESSION, nil, 0); // end IE session
		browser.Free;
		form.Free;
	end;
	exit(s); // 'Foo String';
end;

function get_zapros(surl : string) : string;
	function CheckUrl(url : string) : boolean;
	var
		hSession, hfile, hRequest : hInternet;
		dwindex, dwcodelen : dword;
		dwcode : array [1 .. 20] of char;
		res : PChar;
	begin
		if pos('http://', lowercase(url)) = 0 then
			url := 'http://' + url;
		result := false;
		hSession := InternetOpen('InetURL:/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
		if assigned(hSession) then
		begin
			hfile := InternetOpenURL(hSession, PChar(url), nil, 0, INTERNET_FLAG_RELOAD, 0);
			dwindex := 0;
			dwcodelen := 10;
			HttpQueryInfo(hfile, HTTP_QUERY_STATUS_CODE, @dwcode, dwcodelen, dwindex);
			res := PChar(@dwcode);
			result := (res = '200') or (res = '302'); //'200'(ОК) или '302' (Редирект)
			if assigned(hfile) then
				InternetCloseHandle(hfile);
			InternetCloseHandle(hSession);
		end;
	end;

var
	// form : TForm;
	browser : TWebBrowser;
	s : string;
	// hSession, hUrl, hRequest : hInternet;
begin
	// form := TForm.Create(nil);
	browser := TWebBrowser.Create(nil);
	try
		InternetSetOption(nil, INTERNET_OPTION_END_BROWSER_SESSION, nil, 0); // end IE session
		// sleep(900);
		// TWinControl(browser).Parent := form;
		TWinControl(browser).Parent := browser_panel; // browser_form;
		browser.Silent := true;
		browser.Width := 10;
		browser.Height := 10;
		// browser.Align := alClient;
		// form.Width := 400;
		// form.Height := 100;
		// form.Show;
		// if not DEBUG then
		// form.Hide;
		// hSession := InternetOpen('InetURL:/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
		// hUrl := InternetOpenURL(hSession, PChar(PHP_Url), nil, 0, 0, 0);
		// if IsConnectedToInternet() then
		// if assigned(hSession) then
		// if hUrl <> nil then
		if CheckUrl(surl) then
		begin
			browser.Navigate(surl);
			while browser.ReadyState < READYSTATE_COMPLETE do
				Application.ProcessMessages;
			s := html_to_string(browser);
			// InternetCloseHandle(hSession);
		end
		else
		begin
			s := '';
			show_status('Нет соединения с интернетом');
		end;
	finally
		browser.Free;
		// form.Free;
	end;
	exit(s); // 'Foo String';
end;

function create_order_and_crew_states(var IBQuery : TIBQuery) : Integer;
	procedure set_states(var states : Tstringlist; table_name : string);
	var sel, s : string;
		i : Integer;
		st : Tstringlist;
	begin
		sel := 'select ' //
			+ ' ID, NAME ' //
			+ ' from ' //
			+ table_name;
		st := get_sql_stringlist(IBQuery, sel);
		for i := 0 to st.Count - 1 do
		begin
			s := st.Strings[i];
			s := StringReplace(s, ' ', '_', [rfReplaceAll]);
			s := StringReplace(s, '|', '=', [rfReplaceAll]);
			states.Add(s);
		end;
		s := '-1=не_определено';
		states.Append(s);
	end;

begin
	order_states := Tstringlist.Create();
	set_states(order_states, 'ORDER_STATES');

	crew_states := Tstringlist.Create();
	set_states(crew_states, 'CREW_STATE');

	with order_states do
	begin
		Append(IntToStr(ORDER_CREW_NO_COORD) + '=нет_координат_экипажа');
		Append(IntToStr(ORDER_BAD_ADRES) + '=невозможно_определить_координаты_адреса');
		Append(IntToStr(ORDER_WAY_ERROR) + '=просчёт_маршрута_неудачен');
	end;

	exit(0);
end;

function sql_select(var query : TIBQuery; sel : string) : Integer;
begin
	query.SQL.Clear;
	query.SQL.Add(sel);
	try
		query.Prepare;
	except
		show_status('неверный запрос к БД');
		result := -1;
		exit;
	end;
	query.Open;
	// show_status('запрос произведён');
	result := 0;
end;

function get_sql_stringlist(var query : TIBQuery; sel : string) : Tstringlist;
var
	res : string;
	// list : Tstringlist;
	field : TField;
	i : Integer;
begin
	sql_select(query, sel);
	// list := Tstringlist.Create;

	// очищаем список вп-ду!
	sql_string_list.Destroy();
	sql_string_list := Tstringlist.Create();
	// for i := sql_string_list.Count - 1 downto 0 do
	// begin
	// FreeMem(Pointer(sql_string_list.Strings[i]));
	// sql_string_list.Delete(i);
	// end;
	// sql_string_list.Clear();

	while (not query.Eof) do
	begin
		res := '';
		for field in query.fields do
		begin
			res := res + field.AsString + '|';
		end;
		if res[length(res)] = '|' then
			Delete(res, length(res), 1);
		// list.Append(res);
		sql_string_list.Append(res);
		query.Next;
	end;
	// result := list;
	exit(sql_string_list);
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

function TAdres.get_as_string : string;
begin
	if length(self.street) > 0 then
		result := self.street
	else
		exit('');
	if length(self.house) > 0 then
	begin
		result := result + ', ' + self.house;
		if length(self.korpus) > 0 then
			result := result + '/' + self.korpus;
	end;
	exit(result);
end;

function TAdres.isEmpty : boolean;
begin
	if (length(self.gps) > 0) or (length(self.street) > 0) then
		// если есть координата или улица, то адрес не пустой
		exit(false)
	else
		exit(true);
end;

procedure TAdres.setAdres(street, house, korpus, gps : string);
begin
	self.street := street;
	self.house := house;
	self.korpus := korpus;
	self.gps := gps;
end;

procedure show_status(status : string);
var stbar : TStatusBar;
begin
	// временно отключено
	// exit();

	if PGlobalStatusBar = nil then
		exit();
	stbar := TStatusBar(PGlobalStatusBar);
	stbar.Panels[0].Text := status;
end;

end.
