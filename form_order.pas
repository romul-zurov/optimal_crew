unit form_order;

interface

uses
	crew_utils, //
	crew, //
	crew_globals, //
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, ExtCtrls, OleCtrls, SHDocVw, Math, StrUtils, ComCtrls;

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
		cb_debug : TCheckBox;
		stbar_crews : TStatusBar;
		procedure FormCreate(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
		procedure Button_get_timeClick(Sender : TObject);
		procedure Button_get_crewClick(Sender : TObject);

		procedure Timer_show_crewsTimer(Sender : TObject);

		procedure Timer_get_gpsTimer(Sender : TObject);
		procedure Timer_get_crewsTimer(Sender : TObject);
		procedure grid_crewsDrawCell(Sender : TObject; ACol, ARow : Integer; Rect : TRect;
			State : TGridDrawState);

		procedure cb_debugClick(Sender : TObject);
	private
		{ Private declarations }
		POrder : Pointer;

	public
		{ Public declarations }
		PCrewList : Pointer;
		POrderList : Pointer;
		slist, cr_slist : tstringlist;
		cr_count : Integer;
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

procedure TFormOrder.grid_crewsDrawCell(Sender : TObject; ACol, ARow : Integer; Rect : TRect;
	State : TGridDrawState);
var sub : string;
begin
	if (ACol in [3, 4, 5, 6]) and (ARow > 0) then // только для колонок расчёта/статуса и для не-заглавных строк
		with TStringGrid(Sender) do
		begin
			sub := '';
			if pos('!!!', Cells[ACol, ARow]) = 1 then
			begin
				Canvas.Brush.color := clRed;
				sub := '!!!';
			end
			else
				if pos('!', Cells[ACol, ARow]) = 1 then
				begin
					Canvas.Brush.color := clYellow;
					sub := '!';
				end
				else
					if pos('#', Cells[ACol, ARow]) = 1 then
					begin
						Canvas.Brush.color := $CCCCCC;
						sub := '#';
					end
					else
						if pos('*', Cells[ACol, ARow]) = 1 then
						begin
							Canvas.Brush.color := $00FF00;
							sub := '*';
						end
						else
							if pos('%', Cells[ACol, ARow]) = 1 then
							begin
								Canvas.Brush.color := $6D6D6D;
								sub := '%';
							end
							else
								Canvas.Brush.color := $FFFFFF;

			Canvas.FillRect(Rect);
			Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, get_substr(Cells[ACol, ARow], sub, ''));
		end;
end;

procedure TFormOrder.ret_sl(var cr_sl : tstringlist; first : boolean; var sl : tstringlist);
var j : Integer;
	cr : TCRew;
begin
	sl.Clear();
	sl.Sorted := True;
	for j := 0 to cr_sl.Count - 1 do
	begin
		cr := TCrewList(self.PCrewList).crewByCrewId(StrToInt(cr_sl.Strings[j]));
		if first then
			cr.set_time(-1, -1);
		if cr.State in [CREW_SVOBODEN, CREW_NAZAKAZE] then
			sl.Add(cr.ret_data_to_ap(TOrder(POrder).source_time, TOrder(POrder).raw_dist_way));
	end;
end;

procedure TFormOrder.Button_get_crewClick(Sender : TObject);
begin
	self.slist.Clear();
	if TOrder(POrder).source.gps = '' then
		TOrder(POrder).source.get_gps_unlim();
	self.Edit_gps.Text := 'Определяем доступные экипажи...';
	self.Timer_get_gps.Enabled := True;
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

procedure TFormOrder.cb_debugClick(Sender : TObject);
begin
	self.GroupBox_order.Visible := self.cb_debug.Checked;
end;

procedure TFormOrder.FormClose(Sender : TObject; var Action : TCloseAction);
begin
	self.Timer_get_gps.Enabled := false;
	self.Timer_get_crews.Enabled := false;
	self.Timer_show_crews.Enabled := false;
	self.Hide();
end;

procedure TFormOrder.FormCreate(Sender : TObject);
begin
	self.Width := 800;
	self.Height := 400;
	self.slist := tstringlist.Create();
	self.cr_slist := tstringlist.Create();
	self.GroupBox_order.Visible := self.cb_debug.Checked;
end;

procedure TFormOrder.show_crews();
var s : string;
	r : Integer;
	order : TOrder;
begin
	order := TOrder(POrder);
	self.Caption := 'Заказ № ' + inttostr(order.ID);
	self.GroupBox_crews.Caption := 'Подбор экипажа для заказ № ' + inttostr(order.ID) //
		+ ' ' + order.source.get_as_string() + ' --> ' + order.dest.get_as_string();
	with self.grid_crews do
	begin
		RowCount := 2;
		ColCount := 7;
		FixedRows := 1;

		Cells[0, 0] := 'По прямой';
		Cells[1, 0] := 'Экипаж';
		Cells[2, 0] := 'Состояние';
		Cells[3, 0] := 'Время подачи';
		Cells[4, 0] := 'Расстояние';
		Cells[5, 0] := 'Расход';
		Cells[6, 0] := 'Линия';

		ColWidths[0] := ifthen(self.cb_debug.Checked, 128, 64); // 64; // 50; // прячем :)
		// ColWidths[1] := 200;
		ColWidths[2] := 70;
		ColWidths[3] := 200;
		ColWidths[4] := 80; // (Width - ColWidths[0] - ColWidths[1] - ColWidths[2] - ColWidths[3] - 20) div 2;
		ColWidths[5] := ifthen(self.cb_debug.Checked, 80, 0);
		ColWidths[6] := 40;
		ColWidths[1] := Width - 24 - ColWidths[0] - ColWidths[2] //
			- ColWidths[3] - ColWidths[4] - ColWidths[5] - ColWidths[6];

	end;

	r := 1;
	for s in self.slist do
		with self.grid_crews do
		begin
			RowCount := r + 1;
			Cells[0, r] := ifthen(self.cb_debug.Checked, get_substr(s, '', '|'), get_substr(s, '$', '|'));
			Cells[1, r] := get_substr(s, '|', '||');
			Cells[2, r] := get_substr(s, '||', '|||');
			Cells[3, r] := get_substr(s, '|||', '||||');
			Cells[4, r] := get_substr(s, '||||', '|||||'); // + 'км';
			Cells[5, r] := get_substr(s, '|||||', '||||||');
			Cells[6, r] := get_substr(s, '||||||', '');
			inc(r);
		end;
	self.stbar_crews.Panels[0].Text := inttostr(self.grid_crews.RowCount - 1);
end;

procedure TFormOrder.show_order(POrd : Pointer);
begin
	self.POrder := POrd;

	self.slist.Clear();
	self.cr_slist.Clear();
	self.grid_crews.RowCount := 2;
	self.grid_crews.Rows[1].Clear();
	self.Edit_gps.Text := '';
	// выводим пустую шапку
	self.show_crews();
	self.show_order();
end;

procedure TFormOrder.start_def_times;
begin
	// выводим пстую шапку
	self.show_crews();
	// определяем список подходящихз экипажей
	TCrewList(self.PCrewList).get_crew_list_for_ap(TOrder(POrder).source, TOrder(POrder).ID, self.cr_slist);
	if self.cr_slist.Count = 0 then
	begin
		ShowMessage('Нет подходящих экипажей!');
		exit();
	end;

	self.ret_sl(self.cr_slist, True, self.slist);
	// выводим шапку
	self.show_crews();

	// запускаем таймеры
	self.cr_count := 0;
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
	add_row(self.grid_order, 'time_to_end', inttostr(order.time_to_end));
	add_row(self.grid_order, 'time_to_end_str', order.time_to_end_as_string());
	add_row(self.grid_order, 'time_to_ap', inttostr(order.time_to_ap));
	add_row(self.grid_order, 'time_to_ap_str', order.time_to_ap_as_string());
	add_row(self.grid_order, 'stops_time', inttostr(order.stops_time));
	add_row(self.grid_order, 'source.gps', order.source.gps);
	add_row(self.grid_order, 'dest.gps', order.dest.gps);
	add_row(self.grid_order, 'raw_dist_way', FloatToStrF(order.raw_dist_way, ffFixed, 8, 1));
	add_row(self.grid_order, 'int_stops', order.raw_int_stops);
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
	// if crew.def_time_to_ap(self.POrderList) = 1 then
	if crew.def_time_to_ap() = 1 then
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
		if pos('Error', TOrder(self.POrder).source.gps) > 0 then
			ShowMessage('Некорректный адрес подачи!')
		else
			self.start_def_times();
	end;
end;

procedure TFormOrder.Timer_show_crewsTimer(Sender : TObject);
begin
	self.ret_sl(self.cr_slist, false, self.slist);
	self.show_crews();
end;

end.
