program Vers;

uses
  Windows,
  Forms,
  VersU in 'VersU.pas' {VersFm};

{$R *.res}

begin
  Application.ShowMainForm := False;
  Application.Initialize;
  Application.Title := 'Контроль версий';
  Application.CreateForm(TVersFm, VersFm);

{ SetWindowLong(VersFm.Handle,
               GWL_EXSTYLE,
               GetWindowLong(VersFm.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and
               not WS_EX_APPWINDOW);
 ShowWindow(VersFm.handle, SW_HIDE);}
 VersFm.Show;
 if  VersFm.RunVers=True then
 begin
  VersFm.Close;
 end;
 Application.Run;
end.
