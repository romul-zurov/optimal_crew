unit form_order;

interface

uses
	crew_utils, //
	crew, //
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
		procedure FormCreate(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
	private
		{ Private declarations }
		POrder : Pointer;
	public
		{ Public declarations }
		procedure show_crews(OrderId : integer; source, dest : string; var slist : tstringlist);
		procedure show_order(); overload;
		procedure show_order(POrd : Pointer); overload;
	end;

var
	FormOrder : TFormOrder;

implementation

{$R *.dfm}

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
			Cells[0, r] := get_substr(s, '', '|');
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
	self.Caption := '����� � ' + inttostr(order.ID);
	self.GroupBox_order.Caption := self.Caption;
	with self.grid_order do
	begin
		RowCount := 1;
		rows[0].Clear();
		ColCount := 2;
		ColWidths[0] := 120;
		ColWidths[1] := Width - ColWidths[0] - 20;
	end;
	add_row(self.grid_order, 'ID', inttostr(order.ID));
	add_row(self.grid_order, '����������� ������', inttostr(order.crewid));
	add_row(self.grid_order, '�������������� ����������� ������', //
		inttostr(order.prior_crewid));
	add_row(self.grid_order, '��������������� �����', da_net(order.prior));
	add_row(self.grid_order, '���������', order.state_as_string());
    add_row(self.grid_order, '����� ������', order.source_time);
	add_row(self.grid_order, '����� ������', order.source.get_as_string());
	add_row(self.grid_order, '����� ����������', order.dest.get_as_string());
    add_row(self.grid_order, '�� ���������', order.time_as_string());

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
