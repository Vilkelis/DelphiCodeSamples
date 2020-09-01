unit VersU;

interface

uses
  ShellAPI,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,IniFiles,StdCtrls, ComCtrls, ExtCtrls, cxControls, cxContainer,
  cxEdit, cxProgressBar;

type
  TVersFm = class(TForm)
    Label1: TLabel;
    Shape1: TShape;
    ProgressBar1: TcxProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    {Вспомогательные процедуры}
    //Копирование файлов
    procedure DoCopyFiles(FileServer,FileLocal:string);
    function MakeCopyFiles(FileServer, FileLocal:string):boolean;
  public
    { Public declarations }
    Memo:TMemo;
    bt:TButton;
    pWaitTime:integer;
    pWaitTimeFile:integer;
    pCaption:string;
    function RunVers:boolean;
    procedure WriteHelp(Value:string);
    {Контроль версий файлов}
    //Производит контроль за версиями программы
    {параметр - Ini-файл с перечнем копируемых файлов}
    procedure MakeVersControl(FileName:string);
    procedure PrepareHelp; //Создание объектов для отображения помощи
    function RunShell(FileName,Parameters:string;Directory:string='';
                ShowCmd:integer=SW_SHOWNORMAL;
                Operation:string='open'):integer;
    function StrToShowCmd(Value:string):integer;
    procedure WriteProgress(Value:string);

    constructor Create(AOwner:TComponent); override;
  end;

var
  VersFm: TVersFm;


implementation

{$R *.dfm}

//Открывает файл Windows
{ShowCmd =
 SW_HIDE,
 SW_MINIMIZE
 SW_RESTORE
 SW_SHOW
 SW_SHOWDEFAULT
 SW_SHOWMAXIMIZED
 SW_SHOWMINNOACTIVE
 SW_SHOWNA
 SW_SHOWNOACTIVE
 SW_SHOWNORMAL
Operation = 'open','print','explore'
 }
procedure TVersFm.WriteProgress(Value:string);
begin
 Self.Label1.Caption:=Value;
end;

function TVersFm.StrToShowCmd(Value:string):integer;
begin
 Value:=trim(uppercase(Value));
 if Value='SW_HIDE' then  Result:=SW_HIDE
 else if Value='SW_MINIMIZE' then Result:=SW_MINIMIZE
 else if Value='SW_RESTORE' then Result:=SW_RESTORE
 else if Value='SW_SHOW' then Result:=SW_SHOW
 else if Value='SW_SHOWMAXIMIZED' then Result:=SW_SHOWMAXIMIZED
 else if Value='SW_SHOWNA' then Result:=SW_SHOWNA
// else if Value='SW_SHOWNOACTIVE' then Result:=SW_SHOWNOACTIVE
 else if Value='SW_SHOWNORMAL' then Result:=SW_SHOWNORMAL
 else Result:=SW_SHOWNORMAL;
end;

function TVersFm.RunShell(FileName,Parameters:string;Directory:string='';
                ShowCmd:integer=SW_SHOWNORMAL;
                Operation:string='open'):integer;
begin
 Result:=ShellExecute(Application.Handle,PChar(Operation),
                      PChar(FileName),
                      PChar(Parameters),
                      PChar(Directory),ShowCmd);
end;

procedure TVersFm.PrepareHelp; //Создание объектов для отображения помощи
begin
 Self.Label1.Free;
 Self.ProgressBar1.Free;
 Self.Shape1.Free;
 Memo:=TMemo.Create(Self);
 Memo.Parent:=Self;
 Memo.ReadOnly:=True;
 Memo.WordWrap:=False;
 Memo.ScrollBars:=ssBoth;
 Memo.Clear;
 Memo.Height:=Round(Screen.Height/2);
 Memo.Width:=Round(Screen.Width/2);
 Self.Top:=Round(Screen.Height/2-Self.Height/2);
 Self.Left:=Round(Screen.Width/2-Self.Width/2);
 Self.BorderStyle:=bsDialog;
// Self.AutoSize:=False;
 Self.Top:=Round(Screen.Height/2-Self.Height/2);
 Self.Left:=Round(Screen.Width/2-Self.Width/2);
 Caption:='Vers';
end;

procedure TVersFm.WriteHelp(Value:string);
begin
 Memo.Lines.Add(Value);
end;

function TVersFm.RunVers:boolean;
  {Параметром передается имя ini-файла настроек}
begin
 Result:=True;
 if (ParamCount()>=1)
    and (ParamStr(1)<>'/?')
    and (ParamStr(1)<>'\?')
    and (ParamStr(1)<>'?')
    and (uppercase(ParamStr(1))<>'\HELP')
    and (uppercase(ParamStr(1))<>'/HELP')
    and (uppercase(ParamStr(1))<>'-HELP')
    and (uppercase(ParamStr(1))<>'\H')
    and (uppercase(ParamStr(1))<>'/H')
    and (uppercase(ParamStr(1))<>'-H')
    and (uppercase(ParamStr(1))<>'\help')
    and (uppercase(ParamStr(1))<>'/help')
    and (uppercase(ParamStr(1))<>'-help')
    and (uppercase(ParamStr(1))<>'\h')
    and (uppercase(ParamStr(1))<>'/h')
    and (uppercase(ParamStr(1))<>'-h')
 then
   MakeVersControl(ParamStr(1))
 else begin
   Result:=False;
   PrepareHelp;
   WriteHelp (' -------------------------------VERS-------------------------------------');
   WriteHelp (' Program of files versions coordination. ');
   WriteHelp (' Copies new files for place old and runs one program. ');
   WriteHelp (' ------------------------------------------------------------------------');
   WriteHelp (' This program receives one parameter - ini-file name, ');
   WriteHelp (' which contains the actions description. ');
   WriteHelp (' Structure of ini-file: ');
   WriteHelp (' [VERSSETUP] ');
   WriteHelp (' VERSFOLDER = <Folder of new files versions> ');
   WriteHelp (' LOCALFOLDER = <Folder of old files versions> ');
   WriteHelp (' Caption = <Progress window caption>');
   WriteHelp (' WaitTime = <Wait time to run program>');
   WriteHelp (' WaitTimeFile = <Wait time to copy one file>');
   WriteHelp (' [RUN]');
   WriteHelp (' FileName = <File to run>');
   WriteHelp (' Parameters = <Parameters to run file>');
   WriteHelp (' Directory = <Start folder>');
   WriteHelp (' ShowCmd = <Show command>');
   WriteHelp (' Operation = <Operation to run file>');

   WriteHelp (' [VERSFILES] ');
   WriteHelp (' <file name 1> ');
   WriteHelp (' <file name 2> ');
   WriteHelp (' . . .       ');
   WriteHelp (' <file name N> ');
   WriteHelp ('        ');
   WriteHelp (' ------------------------------------------------------------------------');
   WriteHelp (' ShowCmd values:');
   WriteHelp ('     SW_HIDE');
 WriteHelp ('     SW_MINIMIZE');
 WriteHelp ('     SW_RESTORE');
 WriteHelp ('     SW_SHOW');
 WriteHelp ('     SW_SHOWDEFAULT');
 WriteHelp ('     SW_SHOWMAXIMIZED');
 WriteHelp ('     SW_SHOWMINNOACTIVE');
 WriteHelp ('     SW_SHOWNA');
 WriteHelp ('     SW_SHOWNOACTIVE');
 WriteHelp ('     SW_SHOWNORMAL');
WriteHelp('Operation values:');
 WriteHelp ('    open');
 WriteHelp ('    print');
 WriteHelp ('    explore');
 WriteHelp ('WaitTime and WaitTimeFile mast be set in milliseconds.');
   WriteHelp (' ------------------------------------------------------------------------');
   WriteHelp (' Example of ini-file (VersAction.ini): ');
   WriteHelp (' [VERSSETUP] ');
   WriteHelp (' VERSFOLDER = \\SERVER\INSTALL\ ');
   WriteHelp (' LOCALFOLDER=C:\PROG\ ');
   WriteHelp (' Caption = Files versions  coordination...');
   WriteHelp (' WaitTime = 100');
   WriteHelp (' WaitTimeFile = 100');
   WriteHelp (' [RUN]');
   WriteHelp (' FileName = C:\PROG\prog.exe');
   WriteHelp (' Parameters = c:\mm.rar ');
   WriteHelp (' Directory = c:\PROG\');
   WriteHelp (' ShowCmd = SW_SHOWNORMAL');
   WriteHelp (' Operation = open');
   WriteHelp (' [VERSFILES] ');
   WriteHelp (' prog.exe');
   WriteHelp (' data.dbf');
   WriteHelp ('        ');
   WriteHelp (' ------------------------------------------------------------------------');
   WriteHelp (' Example of start line: ');
   WriteHelp (' C:\Vers.exe c:\VersAction.ini ');
   WriteHelp ('        ');
   WriteHelp (' ------------------------------------------------------------------------');
   WriteHelp (' This command will replace files prog.exe and data.dbf of folder C:\PROG\');
   WriteHelp (' them by newer versions taken from folder \\SERVER\INSTALL\');
   WriteHelp (' If files prog.exe and data.dbf in folder \\SERVER\INSTALL\ have older');
   WriteHelp (' date of modification then replacement will not be made. ');
   WriteHelp (' If files prog.exe and data.dbf in folder C:\PROG\ do not exist then ');
   WriteHelp (' they will be created. After this actions, will be running program prog.exe ');
   Memo.SelStart:=1;
   Memo.SetFocus;

//   readln;
 end;
end;

//Копирование файлов
procedure TVersFm.DoCopyFiles(FileServer,FileLocal:string);
begin
 CopyFile(PChar(FileServer), PChar(FileLocal), False);
end;

function TVersFm.MakeCopyFiles(FileServer, FileLocal:string):boolean;
var LocalDate,ServerDate:TDateTime;
begin
 ServerDate:=StrToDate('01.02.1900');
 if FileExists(FileLocal) then
 begin
    LocalDate := FileDateToDateTime(FileAge(FileLocal));
 end
 else begin
    LocalDate:=StrToDate('01.01.1900');
 end;

 if FileExists(FileServer) then
 begin
    ServerDate := FileDateToDateTime(FileAge(FileServer));
    if LocalDate < ServerDate then Result:=True
    else Result:=False;
 end
 else begin
   Result:=False;
 end;

end;

//Производит контроль за версиями программы
procedure TVersFm.MakeVersControl(FileName:string);
var IniFile:TMemIniFile;
    i:integer;
    fileServer,fileLocal,LocalFolder,VersFolder:string;
    ss:TStringList;
begin
// LocalFolder:=
 IniFile:=TMemIniFile.Create(FileName);
 IniFile.CaseSensitive:=False;
 ss:=TStringList.Create;
 try
    pWaitTimeFile:=IniFile.ReadInteger('VERSSETUP','WaitTimeFile',0);
    pCaption:=IniFile.ReadString('VERSSETUP','Caption','Versions coordination...');
    pWaitTime:=IniFile.ReadInteger('VERSSETUP','WaitTime',0);

    Self.WriteProgress(pCaption+' 0%');
    VersFolder:=IniFile.ReadString('VERSSETUP','VERSFOLDER','');
    LocalFolder:=IniFile.ReadString('VERSSETUP','LOCALFOLDER','');
    IniFile.ReadSectionValues('VERSFILES',ss);
    Application.ProcessMessages;
    Self.ProgressBar1.Properties.Max := ss.Count;
    Self.ProgressBar1.Properties.Min := 0;
//    Self.ProgressBar1.Step:=1;
    for i:=0 to  ss.Count-1 do
    begin
     fileServer:=VersFolder+ss.Strings[i];
     fileLocal:=LocalFolder+ss.Strings[i];
     if MakeCopyFiles(fileServer, fileLocal)=True then
     begin
       DoCopyFiles(fileServer,fileLocal);
     end;
     Self.WriteProgress(pCaption);
//     Self.ProgressBar1.StepIt;
     Self.ProgressBar1.Position := Self.ProgressBar1.Position + 1;
     Application.ProcessMessages;
     if pWaitTimeFile>0 then Sleep(pWaitTimeFile);
    end;
    Application.ProcessMessages;
    if pWaitTime>0 then Sleep(pWaitTime);
    RunShell(
      IniFile.ReadString('RUN','FILENAME',''),
      IniFile.ReadString('RUN','PARAMETERS',''),
      IniFile.ReadString('RUN','Directory',''),
      StrToShowCmd(IniFile.ReadString('RUN','ShowCmd','')),
      IniFile.ReadString('RUN','Operation','open'));
 finally
  IniFile.Free;
  ss.Free;
 end;

end;


procedure TVersFm.Button1Click(Sender: TObject);
begin
 Self.Close;
end;

procedure TVersFm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action:=caFree;
end;

constructor TVersFm.Create(AOwner: TComponent);
begin
  inherited;
end;

end.
