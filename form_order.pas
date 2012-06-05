unit form_order;

interface

uses
	crew_utils, //
	crew, //
	crew_globals, //
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, ExtCtrls, OleCtrls, SHDocVw;

type
	TFormOrder = class(TForm)
		GroupBox_crews : TGroupBox;
		grid_crews : TStringGrid;
		GridPanel_main : TGridPanel;
		GroupBox_controls : TGroupBox;
		GroupBox1 : TGroupBox;
		WebBrowser1 : TWebBrowser;
		Button_get_crew : TButton;
		GridPanel_order : TGridPanel;
		GridPanel_crews_browser : TGridPanel;
		grid_order : TStringGrid;
		Button_show_on_map : TButton;
		GroupBox_order : TGroupBox;
		Timer_get_gps : TTimer;
		Timer_get_crews : TTimer;
		Timer_show_crews : TTimer;
		Edit_gps : TEdit;
		procedure FormCreate(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
		procedure Button_get_timeClick(Sender : TObject);
		procedure Button_get_crewClick(Sender : TObject);

		procedure Timer_show_crewsTimer(Sender : TObject);

		procedure Timer_get_gpsTimer(Sender : TObject);
		procedure Timer_get_crewsTimer(Sender : TObject);
	private
		{ Private declarations }
		POrder : Pointer;

	public
		{ Public declarations }
		PCrewList : Pointer;
		POrderList : Pointer;
		slist, cr_slist : tstringlist;
		cr_count : integer;
		procedure get_show_crews(var order_list : TOrderList; var crew_list : TCrewList);
		procedure show_crews();
		procedure show_order(); overload;
		procedure show_order(POrd : Pointer); overload;
		procedure start_def_times();
		procedure ret_sl(var cr_sl : tstringlist; first : boolean; var sl : tstringlist);
	end;

var
	FormOrder : TFormOrder;

implementation

{$R *.dfm}
// prprocedure TFormOrder.Button_get_timeClick(Sender: TObject);
// begin
//
// end;

procedure TFormOrder.get_show_crews(var order_list : TOrderList; var crew_list : TCrewList);
	procedure ret_sl(var cr_sl : tstringlist; first : boolean; var sl : tstringlist);
	var j : integer;
		cr : TCRew;
	begin
		sl.Clear();
		sl.Sorted := True;
		for j := 0 to cr_sl.Count - 1 do
		begin
			cr := crew_list.crewByCrewId(StrToInt(cr_sl.Strings[j]));
			if first then
				cr.set_time(-1, -1);
			if cr.state in [CREW_SVOBODEN, CREW_NAZAKAZE] then
				sl.Add(cr.ret_data());
		end;
	end;

var order : TOrder;
	ordId, i : integer;
	pp : Pointer;
	crew : TCRew;
	slist, cr_slist : tstringlist;

begin
	order := TOrder(POrder);
	if order = nil then
		exit();
	slist := tstringlist.Create();
	// выводим пстую шапку
	self.show_crews();

	if order.source.gps = '' then
		order.source.get_gps();
	// with order.source do
	// gps := get_gps_coords_for_adres(street, house, korpus);

	// with order.source do
	// crew_list.set_ap(street, house, korpus, gps);
	// crew_list.set_crews_dist(crew_list.ap_gps);
	// crew_list.Crews.Sort(sort_crews_by_state_dist);

	cr_slist := crew_list.get_crew_list_for_ap(order.source);
	if cr_slist.Count = 0 then
	begin
		ShowMessage('Нет подходящих экипажей!');
		exit();
	end;

	ret_sl(cr_slist, True, slist);
	// выводим шапку
	self.show_crews();

	// for pp in crew_list.Crews do
	for i := 0 to cr_slist.Count - 1 do
	begin
		if not self.Visible then
			break;

		// crew := crew_list.crew(pp);
		crew := crew_list.crewByCrewId(StrToInt(cr_slist.Strings[i]));
		with order.source do
			crew.ap.setAdres(street, house, korpus, gps);
		// crew.get_time(order_list, true);
		crew.get_time_for_ap(order_list, order.source);
		// crew_list.Crews.Sort(sort_crews_by_time); // !!!!!!!!!!!!!!!!  :((
		// slist := crew_list.ret_crews_stringlist();
		ret_sl(cr_slist, false, slist);
		self.show_crews();
		// crew_list.Crews.Sort(sort_crews_by_state_dist); // !!!!!!!!!!  :)))
	end;
	FreeAndNil(slist);
end;

procedure TFormOrder.ret_sl(var cr_sl : tstringlist; first : boolean; var sl : tstringlist);
var j : integer;
	cr : TCRew;
begin
	sl.Clear();
	sl.Sorted := True;
	for j := 0 to cr_sl.Count - 1 do
	begin
		cr := TCrewList(self.PCrewList).crewByCrewId(StrToInt(cr_sl.Strings[j]));
		if first then
			cr.set_time(-1, -1);
		if cr.state in [CREW_SVOBODEN, CREW_NAZAKAZE] then
			sl.Add(cr.ret_data_to_ap(TOrder(POrder).source_time));
	end;
end;

procedure TFormOrder.Button_get_crewClick(Sender : TObject);
begin
	self.slist.Clear();
	if TOrder(POrder).source.gps = '' then
		TOrder(POrder).source.get_gps();
	self.Timer_get_gps.Enabled := True;
	// self.get_show_crews(TOrderList(self.POrderList), TCrewList(self.PCrewList));
end;

procedure TFormOrder.Button_get_timeClick(Sender : TObject);
var pc : Pointer;
	order : TOrder;
begin
	order := TOrder(self.POrder);
	if order.CrewID = -1 then
		exit();
	pc := TCrewList(PCrewList).findByCrewId(order.CrewID);
	// order.get_time_to_end(pc);
	self.show_order();
end;

procedure TFormOrder.FormClose(Sender : TObject; var Action : TCloseAction);
begin
	self.Hide();
end;

procedure TFormOrder.FormCreate(Sender : TObject);
begin
	self.Width := 800;
	self.Height := 400;
	self.slist := tstringlist.Create();
	self.cr_slist := tstringlist.Create();
end;

procedure TFormOrder.show_crews();
var s : string;
	r : integer;
	order : TOrder;
begin
	order := TOrder(POrder);
	self.Caption := 'Заказ № ' + inttostr(order.ID);
	self.GroupBox_crews.Caption := 'Подбор экипажа для заказ № ' + inttostr(order.ID) //
		+ ' ' + order.source.get_as_string() + ' --> ' + order.dest.get_as_string();
	with self.grid_crews do
	begin
		RowCount := 2;
		ColCount := 5;
		FixedRows := 1;
		ColWidths[0] := 50;
		// ColWidths[1] := 200;
		ColWidths[2] := 120;
		ColWidths[3] := 100;
		ColWidths[4] := 120; // (Width - ColWidths[0] - ColWidths[1] - ColWidths[2] - ColWidths[3] - 20) div 2;
		ColWidths[1] := Width - 24 - ColWidths[0] - ColWidths[2] //
			- ColWidths[3] - ColWidths[4];

		Cells[0, 0] := '№';
		Cells[1, 0] := 'Экипаж';
		Cells[2, 0] := 'Состояние';
		Cells[3, 0] := 'Время подачи';
		Cells[4, 0] := 'Расстояние';
	end;

	r := 1;
	for s in self.slist do
		with self.grid_crews do
		begin
			RowCount := r + 1;
			Cells[0, r] := get_substr(s, '$', '|');
			Cells[1, r] := get_substr(s, '|', '||');
			Cells[2, r] := get_substr(s, '||', '|||');
			Cells[3, r] := get_substr(s, '|||', '||||');
			Cells[4, r] := get_substr(s, '||||', ''); // + 'км';
			inc(r);
		end;
end;

procedure TFormOrder.show_order(POrd : Pointer);
begin
	self.POrder := POrd;

	self.slist.Clear();
	self.cr_slist.Clear();
	self.grid_crews.RowCount := 2;
	self.grid_crews.Rows[1].Clear();
	self.Edit_gps.Text := '';

	// выводим пстую шапку
	// self.show_crews();

	self.show_order();
end;

procedure TFormOrder.start_def_times;
begin
	// выводим пстую шапку
	self.show_crews();
	// опрееделяем список подходящихз экипажей
	self.cr_slist := TCrewList(self.PCrewList).get_crew_list_for_ap(TOrder(POrder).source);
	if self.cr_slist.Count = 0 then
	begin
		ShowMessage('Нет подходящих экипажей!');
		exit();
	end;

	self.ret_sl(cr_slist, True, slist);
	// выводим шапку
	self.show_crews();

	// запускаем таймеры
	cr_count := 0;
	self.Timer_get_crews.Enabled := True;
	self.Timer_show_crews.Enabled := True;

end;

procedure TFormOrder.show_order;
	function da_net(b : boolean) : string;
	begin
		if b then
			exit('Да')
		else
			exit('Нет');
	end;

	procedure add_row(var grid : TStringGrid; s1, s2 : string);
	begin
		with grid do
		begin
			Cells[0, RowCount - 1] := s1;
			Cells[1, RowCount - 1] := s2;
			RowCount := RowCount + 1;
		end;
	end;

var order : TOrder;
begin
	order := TOrder(POrder);
	if order = nil then
		exit();
	self.Resizing(wsMaximized);
	self.Show();
	self.Caption := 'Заказ № ' + inttostr(order.ID);
	self.GroupBox_order.Caption := self.Caption;
	with self.grid_order do
	begin
		RowCount := 1;
		Rows[0].Clear();
		ColCount := 2;
		ColWidths[0] := 60;
		ColWidths[1] := Width - ColWidths[0] - 20;
	end;
	add_row(self.grid_order, 'ID', inttostr(order.ID));
	add_row(self.grid_order, 'CrewID', inttostr(order.CrewID));
	add_row(self.grid_order, 'prior_crewid', inttostr(order.prior_crewid));
	add_row(self.grid_order, 'prior', da_net(order.prior));
	add_row(self.grid_order, 'state', order.state_as_string());
	add_row(self.grid_order, 'source_time', order.source_time);
	add_row(self.grid_order, 'source', order.source.get_as_string());
	add_row(self.grid_order, 'dest', order.dest.get_as_string());
	add_row(self.grid_order, 'time_to_end', order.time_to_end_as_string());
	add_row(self.grid_order, 'time_to_ap', order.time_to_ap_as_string());
	add_row(self.grid_order, 'stops_time', inttostr(order.stops_time));
end;

procedure TFormOrder.Timer_get_crewsTimer(Sender : TObject);
var crew : TCRew;
begin
	if self.cr_count >= cr_slist.Count then
	begin
		self.cr_count := 0;
		self.Timer_get_crews.Enabled := false;
		exit();
	end;

	crew := TCrewList(self.PCrewList).crewByCrewId(StrToInt(cr_slist.Strings[self.cr_count]));
	with TOrder(POrder).source do
		crew.ap.setAdres(street, house, korpus, gps);
	crew.def_time_to_ap(self.POrderList);
	inc(self.cr_count);
end;

procedure TFormOrder.Timer_get_gpsTimer(Sender : TObject);
begin
	if TOrder(self.POrder).source.gps = '' then
		// ещё не готова координата, ждём
		exit()
	else
	begin
		self.Timer_get_gps.Enabled := false;
		self.Edit_gps.Text := TOrder(self.POrder).source.gps;
		self.start_def_times();
	end;
end;

procedure TFormOrder.Timer_show_crewsTimer(Sender : TObject);
begin
	self.ret_sl(self.cr_slist, false, self.slist);
	self.show_crews();
end;

end.
