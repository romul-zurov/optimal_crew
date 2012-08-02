unit thread_get_times;

interface

uses
	Classes, ExtCtrls;

type
	TThread_get_times = class(TThread)
	private
		{ Private declarations }
		flag_pass : boolean;
		flag_get_db : boolean;
		interval : Int64;
		timer : TTimer;

		procedure do_get_times();
		procedure do_get_db();
		procedure flag_on_get_db(Sender : TObject);
	protected
		procedure Execute; override;
	public
    	procedure init();
		procedure pause();
		procedure cont();
	end;

implementation

uses main;

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TThread_get_times.UpdateCaption;
  begin
  Form1.Caption := 'Updated in a thread';
  end;

  or

  Synchronize(
  procedure
  begin
  Form1.Caption := 'Updated in thread via an anonymous method'
  end
  )
  );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ TThread_get_times }

procedure TThread_get_times.cont;
begin
	self.flag_pass := false;
end;

procedure TThread_get_times.Init;
begin
	self.flag_pass := false;
	self.flag_get_db := false;
	self.interval := 0;

	self.timer := TTimer.Create(nil);
	self.timer.interval := form_main.interval_orders_req;
	self.timer.OnTimer := self.flag_on_get_db;
	self.timer.Enabled := true;
end;

procedure TThread_get_times.flag_on_get_db(Sender : TObject);
begin
	self.flag_get_db := true;
end;

procedure TThread_get_times.do_get_db;
begin
	if self.interval > form_main.interval_coords_req then
	begin
		self.interval := 0;
		form_main.crews_request();
	end
	else
	begin
		self.interval := self.interval + self.timer.interval;
		form_main.orders_request();
	end;
end;

procedure TThread_get_times.do_get_times;
begin
	if form_main.flag_order_get_time_process then // расчёт уже идёт, неча отвлекать
	else
		form_main.get_orders_times();
end;

procedure TThread_get_times.Execute;
begin
	{ Place thread code here }

    (*
	// !!!!
	if not self.timer.Enabled then
	begin
		self.timer := TTimer.Create(nil);
		self.timer.interval := 5 * 1000;
		self.timer.OnTimer := self.flag_on_get_db;
		self.timer.Enabled := true;
	end;
	// !!!
    *)

	while true do
	begin
		if self.Terminated then
			exit();
		if self.flag_pass then
		else
		begin
			// synchronize(self.do_get_times);
			if self.flag_get_db then
			begin
				synchronize(self.do_get_db);
				self.flag_get_db := false;
			end;
		end;
	end;
end;

procedure TThread_get_times.pause;
begin
	self.flag_pass := true;
end;

end.
