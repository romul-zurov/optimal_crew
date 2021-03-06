unit crew_globals;

interface

uses crew_utils, // utils from robocap and mine
	Generics.Collections, // for forward class definition
	Controls, Forms, Classes, SysUtils, Math, SHDocVw, MSHTML, ActiveX, //
	windows, DateUtils, //
	IBQuery, IBDataBase, DB, WinInet, StrUtils, ComCtrls, IniFiles, ExtCtrls;

// const FOO_COORD = '-'; // '-' < ����� �����

const GRID_CARS_COLUMN_WIDTH = 534;

const RUB_ZA_KM = 35.0; // ����� �� ��

const CREW_SVOBODEN = 1;

const CREW_NAZAKAZE = 3;

const CREW_MOVE_DIST = 200.0; // ���� ������ ������� ���������� ����� ��� -
	// . 							������������� ����� ������

const CREW_RADIUS = 150.0; // ������ "���������" ������� � �����, ������

const CREW_CUR_COORD_TIME = '{Last_minute_10}'; // "���� ��������" ������� ����������

const ORDER_DESTROY_TIME = '{Last_minute_10}'; // �����, ����� �������� �����,
	// ���������� �� ��������, ��������� ������������

const ORDER_PRINYAT = 1; // "������", �������� ORDER_STATES

const ORDER_VODITEL_PODTVERDIL = 2; // �������� ORDER_STATES

const ORDER_V_OCHEREDI = 3; // �������� ORDER_STATES

const ORDER_DONE = 4; // "��������", �������� ORDER_STATES

const ORDER_DISCONTNUED = 5; // "���������", �������� ORDER_STATES

const ORDER_NO_CREWS = 6; // "��� �����", �������� ORDER_STATES

const ORDER_KLIENT_NA_BORTU = 29; // �������� ORDER_STATES

const ORDER_ZAKAZ_OTPRAVLEN = 30; // �������� ORDER_STATES

const ORDER_PRIGLASITE_KLIENTA = 31; // �������� ORDER_STATES

const ORDER_KLIENT_NE_VYSHEL = 32; // �������� ORDER_STATES

const ORDER_ZAKAZ_POLUCHEN = 33; // �������� ORDER_STATES

const ORDER_VODITEL_OTKAZALSYA = 34; // �������� ORDER_STATES

const ORDER_VODITEL_PRINYAL = 35; // �������� ORDER_STATES

const ORDER_CANCEL = 37; // "�������", �������� ORDER_STATES

const ORDER_SMS_PRIGL = 38; // �������� ORDER_STATES

const ORDER_VODITEL_VYPOLNIL_ZAKAZ = 39; // �������� ORDER_STATES

const ORDER_TEL_PRIGL = 40; // �������� ORDER_STATES

const ORDER_CREW_NO_COORD = -2; // � ������� ��� ���������, ������� �������� ����������

const ORDER_BAD_ADRES = -4; // �����(�) �������� ������ �� ����������� ������,
	// . 						������� �������� ����������

const ORDER_WAY_ERROR = -8; // ������ ��� �������� ��������, ����� �� ����������

const ORDER_HAS_STOPS = -16; // ����� � ��������. ����������� ���� �� ���������

const ORDER_AP_OK = -128; // ������ ��� � �� � ����� (������ �������)

const ORDER_AN_OK = -192; // ������ ��� � ������ ���������� � ����� (������� �������)

	// ������ ������ ��������� �������
const COORDS_BUF_SIZE = '{Last_hour_2}'; // '{Last_minute_20}';//

const COORDS_NO_INT_BUF_SIZE = '{Last_minute_20}'; // ��� ������� ��� ����. ���.
	// ���� ������, ����� �� ���� ����-����

const INT_STOP_TIME = 10; // ���-�� �����, ������������� �������� �� ������. ���������

const DEBUG_MEASURE_TIME = '''2011-10-03 13:57:50'''; // for back-up base

const MAX_GET_ZAPROS = 16; // 24; // !!!

type
	TZapros = class(TObject)
		// ������� ����� ��� ������� �������, ��������� � ������� ����� php-�������
		// ����� ZaporsComplete ���������������� ��� �������������
		otvet : string;
		browser : TWebBrowser;
		timer : TTimer;
		constructor Create();
		destructor Destroy; override;
		function get_zapros(surl : string) : integer;
		function get_zapros_unlim(surl : string) : integer;
		procedure timeout_error(Sender : TObject);
		procedure zapros_complete(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		function get_flag_zapros() : boolean;
	private
		flag_zapros : boolean;
		flag_count : boolean;

		procedure inc_counter();
		procedure dec_counter();
		procedure show_counter();
		function get_request(surl : string { ; count_flag : boolean } ) : integer;
	end;

	TAdres = class(TObject)
		raw_adres : string; // ����� � ������������ ����
		street : string;
		house : string;
		korpus : string;
		gps : string;
		zapros : TZapros;
		constructor Create(street, house, korpus, gps : string);
		destructor Destroy; override;
		procedure setAdres(street, house, korpus, gps : string);
		procedure set_raw_adres(adres : string);
		procedure Clear();
		function isEmpty() : boolean;
		function get_as_string() : string;
		function get_as_color_string() : string;
		procedure get_gps();
		procedure get_gps_unlim();
		function gps_ok() : boolean;
		function is_visited(pcrew : pointer) : boolean;
		function when_visited() : string; // ����� ���������
		function was_visited() : boolean;
		function was_not_visited() : boolean;
		procedure set_visited();
	private
		visited : boolean; // ���� ��� �� ����� "�������" ��������
		time_visited : string; // ����� ���������
		function s_color() : string; // ���� ��� ������������ �������
		procedure def_gps(count_flag : boolean);
		procedure gps_complete(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
		// procedure complete(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
	end;

	TWay = class(TObject)
		time : integer;
		dist_way : double;
		points : TList;
		zapros : TZapros;

		constructor Create();
		destructor Destroy; override;
		function get_way_time_dist() : integer;
		function get_way_time_dist_unlim() : integer;
		procedure set_way_time_dist(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
	private
		count_flag : boolean;
		function def_way_time_dist() : integer;
	end;

	TSpeed = class(TObject)
		constructor Create(dist : double; time : integer);
		function speed() : double;
	private
		speed_avg : double;
		dt : TDateTime;
	end;

	TSpeedList = class(TObject)
		constructor Create();
		function average_speed() : double;
		function average_speed_as_string() : string;
		procedure append(dist : double; time : integer);
	private
		speed_list : TList;
		timer : TTimer;
		old_speed : double;
		procedure del_old_speeds(Sender : TObject);
	end;

	TBrowserComplete2Event = procedure(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);

	TBrowserComplete2Provider = class
	public
		constructor Create(AEvent : TBrowserComplete2Event);
		procedure NavigateComplete2(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
	private
		FEvent : TBrowserComplete2Event;
	end;

function get_zapros(surl : string) : string;
function create_order_and_crew_states(var IBQuery : TIBQuery) : integer;
function sql_select(var query : TIBQuery; sel : string) : integer;
function get_sql_stringlist(var query : TIBQuery; sel : string) : Tstringlist;
function ret_sql_stringlist(var query : TIBQuery; sel : string; var res : Tstringlist) : integer;
function get_gps_coords_for_adres(ulica, dom, korpus : string) : string;
function get_crew_way_time(var points : TList; var dist_way : double) : integer;
procedure show_status(status : string);
function get_set_gps(var adr : TAdres) : string;
procedure string_to_stringlist(source : string; var res : Tstringlist);

var
	sql_string_list : Tstringlist;
	DEBUG : boolean;
	DEBUG_SDATE_FROM : string;
	DEBUG_SDATE_TO : string;
	// cur_time : TDateTime;
	ac_taxi_url : string;
	PHP_Url : string;
	robocab_api_url : string;
	robocab_api_key : string;
	robocab_api_type : string;
	robocab_api_test : string;
	order_states : Tstringlist;
	crew_states : Tstringlist;
	PGlobalStatusBar : pointer;
	// browser_form : Tform;
	browser_panel : TPanel;
	GetZaprosCounter : Int64;
	PMainCrewList : pointer;
	average_speed : double;
	speed_list : TSpeedList;
	// CoordsInterval : Int64;


	// main_db : TIBDatabase;
	// main_ta : TIBTransaction;
	// main_ds : TDataSource;
	// main_ibquery : TIBQuery;

implementation

uses crew;

type
	TIEProgressEvent2 = procedure(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);

	TProgressProvider = class
	public
		flag : boolean;
		constructor Create(AEvent : TIEProgressEvent2);
		procedure IOProgress(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
	private
		FEvent : TIEProgressEvent2;
	end;

constructor TProgressProvider.Create(AEvent : TIEProgressEvent2);
begin
	inherited Create;
	FEvent := AEvent;
	self.flag := true;
end;

procedure TProgressProvider.IOProgress(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin
	if Assigned(FEvent) then
		self.flag := false;
end;

procedure IOProgress(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin

end;

function get_crew_way_time(var points : TList; var dist_way : double) : integer;
	procedure add_s(var s : string; s1, s2, s3, s4 : string; num : integer);
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

var i, c, n, t : integer;
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
		else
			if i = (c - 1) then
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
	dist_res := get_substr(res, '������� (��� ����� ������): ', ' ��.');
	res := get_substr(res, '����� (� ������ ������): ', ' ���.');
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
		// !!!!!!
		surl := surl + ' "cp1251"';
		show_status(surl);
		surl := param64(surl);
		surl := PHP_Url + '?param=' + surl;
		// show_status('������ ��������� ��� ������ ' + ulica + ' ' + dom + ' ' + korpus + '...');
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
			show_status('��� ���������� � ����������');
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

procedure BrowserNavigateComplete2(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin
	// ShowMessage('��-�� :) !');
	pass();
	// flag := false;
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
		if Assigned(hSession) then
		begin
			hfile := InternetOpenURL(hSession, PChar(url), nil, 0, INTERNET_FLAG_RELOAD, 0);
			dwindex := 0;
			dwcodelen := 10;
			HttpQueryInfo(hfile, HTTP_QUERY_STATUS_CODE, @dwcode, dwcodelen, dwindex);
			res := PChar(@dwcode);
			result := (res = '200') or (res = '302'); // '200'(��) ��� '302' (��������)
			if Assigned(hfile) then
				InternetCloseHandle(hfile);
			InternetCloseHandle(hSession);
		end;
	end;

var
	Provider : TProgressProvider;
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

		// @#$%^&*(!!!
		Provider := TProgressProvider.Create(IOProgress);
		browser.OnNavigateComplete2 := Provider.IOProgress;
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

		// if True then
		// if CheckUrl(surl) then
		if CheckUrl(PHP_Url) then
		begin
			browser.Navigate(surl);
			while Provider.flag do
				Application.ProcessMessages;

			// while browser.ReadyState < READYSTATE_COMPLETE do
			// Application.ProcessMessages;
			s := html_to_string(browser);
			// InternetCloseHandle(hSession);
		end
		else
		begin
			s := '';
			show_status('��� ���������� � ����������');
		end;
	finally
		browser.Free;
		// form.Free;
	end;
	exit(s); // 'Foo String';
end;

function sql_select(var query : TIBQuery; sel : string) : integer;
begin
	query.Close();
	query.SQL.Clear();
	query.SQL.Add(sel);
	try
		query.Prepare();
	except
		show_status('�������� ������ � ��');
		result := -1;
		exit;
	end;
	query.Open();
	// show_status('������ ���������');
	result := 0;
end;

function get_sql_stringlist(var query : TIBQuery; sel : string) : Tstringlist;
var
	res : string;
	// list : Tstringlist;
	field : TField;
	i : integer;
begin
	sql_select(query, sel);
	// list := Tstringlist.Create;

	// ������� ������ ��-��!
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
		sql_string_list.append(res);
		query.Next;
	end;
	// result := list;
	exit(sql_string_list);
end;

function ret_sql_stringlist(var query : TIBQuery; sel : string; var res : Tstringlist) : integer;
var
	sres : string;
	// list : Tstringlist;
	field : TField;
	i : integer;
begin
	query.Close();
	query.SQL.Clear();
	query.SQL.Add(sel);
	try
		query.Prepare();
	except
		show_status('�������� ������ � ��');
		exit(-1);
	end;
	query.Open();

	// ������� ������ ��-��!
	// sql_string_list.Destroy();
	// sql_string_list := Tstringlist.Create();

	res.Clear();

	while (not query.Eof) do
	begin
		sres := '';
		for field in query.fields do
		begin
			sres := sres + field.AsString + '|';
		end;
		if sres[length(sres)] = '|' then
			Delete(sres, length(sres), 1);
		res.append(sres);
		query.Next;
	end;
	exit(0);
end;

{ TAdres }

procedure TAdres.Clear;
begin
	self.street := '';
	self.house := '';
	self.korpus := '';
	self.gps := '';
	self.raw_adres := '';
	self.visited := false;
	self.time_visited := '';
end;

constructor TAdres.Create(street, house, korpus, gps : string);
begin
	inherited Create;
	self.raw_adres := '';
	self.street := street;
	self.house := house;
	self.korpus := korpus;
	self.gps := gps;
	// self.s_color := '';
	self.zapros := TZapros.Create();
	self.zapros.browser.OnNavigateComplete2 := self.gps_complete;
	self.visited := false;
	self.time_visited := '';
end;

procedure TAdres.def_gps(count_flag : boolean);
var surl : string;
begin
	surl := ac_taxi_url + 'order?i_generate_address=1&service=0&';
	surl := surl + 'point_from[obj][]=' + self.street + '&';
	surl := surl + 'point_from[house][]=' + self.house + '&';
	surl := surl + 'point_from[corp][]=' + self.korpus + '&';
	surl := surl + 'point_to[obj][]=' + self.street + '&';
	surl := surl + 'point_to[house][]=' + self.house + '&';
	surl := surl + 'point_to[corp][]=' + self.korpus + '&';

	surl := '"' + surl + '"' + ' "DayGPSKoordinatPoAdresu" "foo"';
	surl := surl + ' "cp1251"';
	show_status(surl);
	surl := param64(surl);
	surl := PHP_Url + '?param=' + surl;
	if count_flag then
		self.zapros.get_zapros(surl)
	else
		self.zapros.get_zapros_unlim(surl);
end;

destructor TAdres.Destroy;
begin
	self.zapros.Free();
	inherited;
end;

function TAdres.get_as_color_string : string;
begin
	// result := self.s_color + self.get_as_string();
	result := self.s_color() + self.raw_adres;
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
end;

procedure TAdres.get_gps;
var surl : string;
begin
	self.def_gps(true);
end;

procedure TAdres.get_gps_unlim;
begin
	self.def_gps(false);
end;

procedure TAdres.gps_complete(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin
	// self.gps := html_to_string(self.zapros.browser);
	self.zapros.zapros_complete(ASender, pDisp, url);
	// if pos('Error', self.zapros.otvet) > 0 then
	// self.gps := ''
	// else
	self.gps := self.zapros.otvet;
	// if pos('Error', self.gps) > 0 then
	// s_color := '!!!'
	// else
	// s_color := '';
end;

function TAdres.gps_ok : boolean;
begin
	result := not((length(self.gps) = 0) or (pos('Error', self.gps) > 0));
end;

function TAdres.isEmpty : boolean;
begin
	if (length(self.gps) > 0) or (length(self.street) > 0) then
		// ���� ���� ���������� ��� �����, �� ����� �� ������
		exit(false)
	else
		exit(true);
end;

function TAdres.is_visited(pcrew : pointer) : boolean;
var when : string;
begin
	if (pcrew = nil) or (self.gps = '') then
		exit(false);
	try
		when := TCrew(pcrew).when_was_in_coord(self.gps);
	except
		exit(false);
	end;
	result := length(when) > 0;
	self.time_visited := when;
	self.visited := result;
end;

procedure TAdres.setAdres(street, house, korpus, gps : string);
begin
	self.street := street;
	self.house := house;
	self.korpus := korpus;
	self.gps := gps;
end;

procedure TAdres.set_raw_adres(adres : string);
	procedure ret_adr(var value : string; var s, h, k : string);
	begin
		s := '';
		h := '';
		k := '';
		s := get_substr(value, '', ',');
		if s = '' then
		begin
			// ���� ����� ���� "����������� ������" ��� "�������-1"
			// �� ������� ��� � ����� � �������
			s := value;
			exit();
		end;
		h := get_substr(value, ',', '');
		if pos('/', h) > 0 then // ���� ���� ����� �������
		begin
			// �������� ������
			k := get_substr(h, '/', '');
			h := get_substr(h, '', '/');
			if pos('-', k) > 0 then // ����������� ��������
				k := get_substr(k, '', '-');
		end
		else
			if pos('-', h) > 0 then // ����������� ��������
				h := get_substr(h, '', '-');
	end;

var
	s, h, k : string;
begin
	if adres = self.raw_adres then
		exit(); // ���� ����� ��� ��, ��� � ������, �� ������

	// ����� ���������� ����� � ���������� �����������
	while (length(adres) > 0) and (pos(' ', adres) = 1) do
		// ����������� ��������� �������
		adres := StringReplace(adres, ' ', '', []); //
	self.raw_adres := adres;
	ret_adr(adres, s, h, k);
	self.setAdres(s, h, k, '');
end;

procedure TAdres.set_visited();
begin
	self.visited := true;
end;

function TAdres.s_color : string;
begin
	result := ifthen((pos('Error', self.gps) > 0) or (length(self.gps) = 0), '!!!', '');
end;

function TAdres.was_not_visited : boolean;
begin
	result := not self.visited;
end;

function TAdres.was_visited : boolean;
begin
	result := self.visited;
end;

function TAdres.when_visited : string;
begin
	result := self.time_visited;
end;

procedure show_status(status : string);
var stbar : TStatusBar;
begin
	// �������� ���������
	// exit();

	if PGlobalStatusBar = nil then
		exit();
	stbar := TStatusBar(PGlobalStatusBar);
	stbar.Panels[0].Text := status;
end;

function get_set_gps(var adr : TAdres) : string;
begin
	if adr.gps = '' then
		with adr do
			gps := get_gps_coords_for_adres(street, house, korpus);
	exit(adr.gps);
end;

{ TBrowserComplete2Provider }

constructor TBrowserComplete2Provider.Create(AEvent : TBrowserComplete2Event);
begin

end;

procedure TBrowserComplete2Provider.NavigateComplete2(ASender : TObject; const pDisp : IDispatch;
	var url : OleVariant);
begin

end;

{ TZapros }

constructor TZapros.Create;
begin
	inherited Create();
	self.otvet := '';
	self.flag_zapros := false;
	self.flag_count := true;
	// CoInitialize(nil);
	try
		self.browser := TWebBrowser.Create(nil);
		// TWinControl(self.browser).Parent := browser_panel; // global panel

		self.browser.Silent := true;
		self.browser.Width := 10;
		self.browser.Height := 10;

		self.timer := TTimer.Create(browser_panel);
		self.timer.Interval := 60 * 1000;
		self.timer.Enabled := false;

		// ���������� ����������� �� ���������,
		// ����� ��������������, ���� �����
		self.browser.OnNavigateComplete2 := self.zapros_complete;
		self.timer.OnTimer := self.timeout_error;
	finally
		// CoUnInitialize();
	end;
end;

procedure TZapros.dec_counter;
begin
	// if GetZaprosCounter > 0 then
	dec(GetZaprosCounter);
	// self.show_counter();
end;

destructor TZapros.Destroy;

begin
	if self.flag_zapros then
		self.dec_counter();
	self.browser.Free();
	self.timer.Free();
	inherited;
end;

function TZapros.get_flag_zapros : boolean;
begin
	result := self.flag_zapros;
end;

function TZapros.get_request(surl : string { ; count_flag : boolean } ) : integer;
begin
	if //
		self.flag_count and //
		(GetZaprosCounter >= MAX_GET_ZAPROS) then
		// ���� ������� ����� ��������, �� �� �����������
		// ��������� ��� count_flag = false
		exit(-1);

	// if self.browser.ReadyState < READYSTATE_COMPLETE then
	if self.flag_zapros then
		// ���� ��� ��� ������, �������
		exit(0);

	self.inc_counter();
	self.timer.Enabled := true;
	self.otvet := '';
	result := 1;
	self.flag_zapros := true;
	// CoInitialize(nil);
	try
		self.browser.Navigate(surl);
	finally
		// CoUnInitialize();
	end;
end;

function TZapros.get_zapros(surl : string) : integer;
begin
	self.flag_count := true;
	result := self.get_request(surl);
	exit();
end;

function TZapros.get_zapros_unlim(surl : string) : integer;
begin
	self.flag_count := false;
	result := self.get_request(surl);
end;

procedure TZapros.inc_counter;
begin
	inc(GetZaprosCounter);
	// self.show_counter();
end;

procedure TZapros.show_counter;
begin
	exit();
	if PGlobalStatusBar = nil then
		exit()
	else
		try
			TStatusBar(PGlobalStatusBar).Panels[1].Text := //
				'Get: ' + IntToStr(GetZaprosCounter);
		except
			exit();
		end;
end;

procedure TZapros.timeout_error(Sender : TObject);
var pDisp : IDispatch;
	url : OleVariant;
begin
	self.timer.Enabled := false;
	// if self.flag_zapros then
	// self.dec_counter();
	self.flag_zapros := false;
	self.otvet := 'ErrorTimeout';
	self.zapros_complete(Sender, pDisp, url);
	// self.browser.Stop();
end;

procedure TZapros.zapros_complete(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
begin
	self.timer.Enabled := false;
	self.flag_zapros := false;
	self.dec_counter();
	if self.otvet = 'ErrorTimeout' then
		exit();
	self.otvet := html_to_string(self.browser);
	if self.otvet = '' then
		self.otvet := 'ErrorNetwork';
end;

{ TWay }

constructor TWay.Create;
begin
	self.time := -1;
	self.dist_way := -1.0;
	self.points := TList.Create();
	self.zapros := TZapros.Create();
	self.zapros.browser.OnNavigateComplete2 := self.set_way_time_dist;
end;

function TWay.def_way_time_dist() : integer;
	procedure add_s(var s : string; s1, s2, s3, s4 : string; num : integer);
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

var i, c, n, t : integer;
	a : TAdres;
	surl, res, dist_res : string;
begin
	c := self.points.Count;
	if c < 2 then
		exit(-1);
	surl := ac_taxi_url + 'order?i_generate_address=1&service=0&';
	for i := 0 to c - 1 do
	begin
		if i = 0 then
			n := 0
		else
			if i = (c - 1) then
				n := -1
			else
				n := 1;
		a := TAdres(self.points.Items[i]);
		add_s(surl, a.street, a.house, a.korpus, a.gps, n);
	end;
	surl := '"' + surl + '"' + ' "DayVremyaPuti" "foo"';
	surl := param64(surl);
	surl := PHP_Url + '?param=' + surl;
	if self.count_flag then
		result := self.zapros.get_zapros(surl) // if true
	else
		result := self.zapros.get_zapros_unlim(surl); // else
end;

destructor TWay.Destroy;
var pa : pointer;
begin

	{
	  for pa in self.points do
	  begin
	  try
	  self.points.Remove(pa);
	  TAdres(pa).Free();
	  finally

	  end;
	  end;
	  self.points.Pack();
	  }
	self.points.Clear();
	self.points.Free();
	self.zapros.Free();
	inherited;
end;

function TWay.get_way_time_dist() : integer;
begin
	self.count_flag := true;
	result := self.def_way_time_dist();
end;

function TWay.get_way_time_dist_unlim : integer;
begin
	self.count_flag := false;
	result := self.def_way_time_dist();
end;

procedure TWay.set_way_time_dist(ASender : TObject; const pDisp : IDispatch; var url : OleVariant);
var res, dist_res : string;
begin
	self.zapros.zapros_complete(ASender, pDisp, url);
	res := self.zapros.otvet;
	if pos('Error', res) > 0 then
	begin
		self.time := -1;
		self.dist_way := -1.0;
		exit();
	end;
	dist_res := get_substr(res, '������� (��� ����� ������): ', ' ��.');
	res := get_substr(res, '����� (� ������ ������): ', ' ���.');
	if (length(res) > 0) and (length(dist_res) > 0) then
		try
			self.dist_way := dotStrtoFloat(dist_res);
			self.time := StrToInt(res);
			speed_list.append(self.dist_way, self.time);

			exit();
		except
			self.time := -1;
			self.dist_way := -1.0;
			exit();
		end;
end;

function create_order_and_crew_states(var IBQuery : TIBQuery) : integer;
	procedure set_states(var states : Tstringlist; table_name : string);
	var sel, s : string;
		i : integer;
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
		s := '-1=#��_����������';
		states.append(s);
	end;

begin
	order_states := Tstringlist.Create();
	set_states(order_states, 'ORDER_STATES');

	crew_states := Tstringlist.Create();
	set_states(crew_states, 'CREW_STATE');

	with order_states do
	begin
		append(IntToStr(ORDER_CREW_NO_COORD) + '=%���_���������_�������');
		append(IntToStr(ORDER_BAD_ADRES) + '=!!!������������_�����');
		append(IntToStr(ORDER_WAY_ERROR) + '=%������_�������');
		append(IntToStr(ORDER_HAS_STOPS) + '=%�����_�_�����������');
	end;

	exit(0);
end;

procedure string_to_stringlist(source : string; var res : Tstringlist);
begin
	res.Clear();
	res.Text := StringReplace(source, '|', #13#10, [rfReplaceAll]);
end;

{ TSpeed }

constructor TSpeed.Create(dist : double; time : integer);
begin
	inherited Create();
	self.speed_avg := 0;
	if (dist > 0) and (time > 0) then
	begin
		self.speed_avg := dist / (time / 60);
		self.speed_avg := ifthen(self.speed_avg > 150, 0, self.speed_avg);
	end;
	self.dt := now();
end;

function TSpeed.speed : double;
begin
	result := self.speed_avg;
end;

{ TSpeedList }

procedure TSpeedList.append(dist : double; time : integer);
begin
	self.speed_list.Add(TSpeed.Create(dist, time));
end;

function TSpeedList.average_speed : double;
var pp : pointer;
	sp : double;
	cou : integer;
begin
	if self.speed_list.Count = 0 then
		exit(self.old_speed)
	else
	begin
		result := 0;
		cou := 0;
		for pp in self.speed_list do
			try
				sp := TSpeed(pp).speed();
				if (sp > 0.5) and (sp < 200.0) then // ����������� ������� � ������� ��������
				begin
					result := result + sp;
					inc(cou);
				end;
			except
				exit(self.old_speed);
			end;
		if cou > 0 then
		begin
			result := result / cou;
			self.old_speed := result;
		end
		else
			result := self.old_speed;
	end;
end;

function TSpeedList.average_speed_as_string : string;
begin
	result := FloatToStrF(self.average_speed(), ffFixed, 4, 0) //
		+ '��/�' //
		+ ' (' //
		+ IntToStr(self.speed_list.Count) //
		+ ')' //
		;
end;

constructor TSpeedList.Create;
begin
	inherited Create();
	self.old_speed := 25;
	self.speed_list := TList.Create();
	self.timer := TTimer.Create(nil);
	self.timer.Interval := 60 * 1000;
	self.timer.Enabled := true;
	self.timer.OnTimer := self.del_old_speeds;
end;

procedure TSpeedList.del_old_speeds(Sender : TObject);
var i : integer;
	dt : TDateTime;
begin
	dt := now();
	for i := self.speed_list.Count - 1 downto 0 do
		try
			if MinutesBetween(dt, TSpeed(self.speed_list.Items[i]).dt) > 10 then
				self.speed_list.Delete(i);
		except
			exit();
		end;
end;

end.
