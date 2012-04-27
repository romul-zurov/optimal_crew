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
		Button_get_time : TButton;
		procedure FormCreate(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
		procedure Button_get_timeClick(Sender : TObject);
		procedure Button_get_crewClick(Sender : TObject);

	private
		{ Private declarations }
		POrder : Pointer;

	public
		{ Public declarations }
		PCrewList : Pointer;
		POrderList : Pointer;
		procedure get_show_crews(var order_list : TOrderList; var crew_list : TCrewList);
		procedure show_crews(OrderId : integer; source, dest : string; var slist : tstringlist);
		procedure show_order(); overload;
		procedure show_order(POrd : Pointer); overload;
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
				cr.set_time(-1);
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
	// ������� ����� �����
	self.show_crews(order.id, order.source.get_as_string(), order.dest.get_as_string(), slist);

	if order.source.gps = '' then
		with order.source do
			gps := get_gps_coords_for_adres(street, house, korpus);

	// with order.source do
	// crew_list.set_ap(street, house, korpus, gps);
	// crew_list.set_crews_dist(crew_list.ap_gps);
	// crew_list.Crews.Sort(sort_crews_by_state_dist);

	cr_slist := crew_list.get_crew_list_for_ap(order.source);
	if cr_slist.Count = 0 then
	begin
		ShowMessage('��� ���������� ��������!');
		exit();
	end;

	ret_sl(cr_slist, True, slist);
	// ������� �����
	self.show_crews(order.id, order.source.get_as_string(), order.dest.get_as_string(), slist);

	// for pp in crew_list.Crews do
	for i := 0 to cr_slist.Count - 1 do
	begin
		if not self.Visible then
			break;

		// crew := crew_list.crew(pp);
		crew := crew_list.crewByCrewId(StrToInt(cr_slist.Strings[i]));
		crew.ap := order.source;
		// crew.get_time(order_list, true);
		crew.get_time_for_ap(order_list, order.source);
		// crew_list.Crews.Sort(sort_crews_by_time); // !!!!!!!!!!!!!!!!  :((
		// slist := crew_list.ret_crews_stringlist();
		ret_sl(cr_slist, false, slist);
		self.show_crews(order.id, order.source.get_as_string(), order.dest.get_as_string(), slist);
		// crew_list.Crews.Sort(sort_crews_by_state_dist); // !!!!!!!!!!  :)))
	end;
	FreeAndNil(slist);
end;

procedure TFormOrder.Button_get_crewClick(Sender : TObject);
begin
	self.get_show_crews(TOrderList(self.POrderList), TCrewList(self.PCrewList));
end;

procedure TFormOrder.Button_get_timeClick(Sender : TObject);
var pc : Pointer;
	order : TOrder;
begin
	order := TOrder(self.POrder);
	if order.CrewID = -1 then
		exit();
	pc := TCrewList(PCrewList).findByCrewId(order.CrewID);
	order.get_time_to_end(pc);
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
end;

procedure TFormOrder.show_crews(OrderId : integer; source, dest : string; var slist : tstringlist);
var s : string;
	r : integer;
begin
	self.Caption := '����� � ' + inttostr(OrderId);
	self.GroupBox_crews.Caption := '������ ������� ��� ����� � ' + inttostr(OrderId) //
		+ ' ' + source + ' --> ' + dest;
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

		Cells[0, 0] := '�';
		Cells[1, 0] := '������';
		Cells[2, 0] := '���������';
		Cells[3, 0] := '����� ������';
		Cells[4, 0] := '����������';
	end;

	r := 1;
	for s in slist do
		with self.grid_crews do
		begin
			RowCount := r + 1;
			Cells[0, r] := get_substr(s, '$', '|');
			Cells[1, r] := get_substr(s, '|', '||');
			Cells[2, r] := get_substr(s, '||', '|||');
			Cells[3, r] := get_substr(s, '|||', '||||');
			Cells[4, r] := get_substr(s, '||||', ''); // + '��';
			inc(r);
		end;
end;

procedure TFormOrder.show_order(POrd : Pointer);
begin
	self.POrder := POrd;
	self.show_order();
end;

procedure TFormOrder.show_order;
	function da_net(b : boolean) : string;
	begin
		if b then
			exit('��')
		else
			exit('���');
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
	self.Caption := '����� � ' + inttostr(order.id);
	self.GroupBox_order.Caption := self.Caption;
	with self.grid_order do
	begin
		RowCount := 1;
		rows[0].Clear();
		ColCount := 2;
		ColWidths[0] := 120;
		ColWidths[1] := Width - ColWidths[0] - 20;
	end;
	add_row(self.grid_order, 'ID', inttostr(order.id));
	add_row(self.grid_order, '����������� ������', inttostr(order.CrewID));
	add_row(self.grid_order, '�������������� ����������� ������', //
		inttostr(order.prior_crewid));
	add_row(self.grid_order, '��������������� �����', da_net(order.prior));
	add_row(self.grid_order, '���������', order.state_as_string());
	add_row(self.grid_order, '����� ������', order.source_time);
	add_row(self.grid_order, '����� ������', order.source.get_as_string());
	add_row(self.grid_order, '����� ����������', order.dest.get_as_string());
	add_row(self.grid_order, '�� ���������', order.time_to_end_as_string());

	// ID : Integer; // order main ID in ORDERS table, -1 if not defined
	// CrewID : Integer; // crew ID for a order, -1 if not defined
	// // want_CrewId : Integer; // �������� ������ �� ������ - �� �����!
	// prior_CrewId : Integer; // ��������������� ������ �� �������. ������
	// prior : boolean; // ������� ���������������� ������
	// state : Integer; // -1 - not defined, 0 - ������, ������� �����
	// // .                 1 - � ������, 2 - ��������;
	// source : TAdres; // address from
	// dest : TAdres; // address to
	// source_time : string; // ����� ������ �������
	// time_to_end : Integer; // ����� �� ��������� ������ � �������

end;

end.
