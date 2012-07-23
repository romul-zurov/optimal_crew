unit thread_get_times;

interface

uses
	Classes;

type
	TThread_get_times = class(TThread)
	private
		{ Private declarations }
		flag_pass : boolean;

		procedure do_get_times();
	protected
		constructor Create();
		procedure Execute; override;
	public
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

constructor TThread_get_times.Create;
begin
	self.flag_pass := false;
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
	while true do
	begin
		if self.Terminated then
			exit();
		if self.flag_pass then
		else
			synchronize(self.do_get_times);
	end;
end;

procedure TThread_get_times.pause;
begin
	self.flag_pass := true;
end;

end.
