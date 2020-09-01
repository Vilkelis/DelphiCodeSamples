unit dmuLang;

interface

uses
  SysUtils, Classes, QLocal, QLocalSource;

type
  TdmLang = class(TDataModule)
    LangSource: TQLanguageSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmLang: TdmLang;


function GetLanguageString(const SectionName:string;const MsgName,DefaultValue:string):string;
function GetMessageRulerString(const DefId:string;const DefStr:string):string; //Возвращает локализованную строку Линеек

implementation

{$R *.dfm}

function GetLanguageString(const SectionName:string;const MsgName,DefaultValue:string):string;
begin
  if Assigned(dmLang) and Assigned(dmLang.LangSource) then
  begin
    dmLang.LangSource.FormSection := SectionName;
    Result := dmLang.LangSource.LoadString(MsgName, DefaultValue);
    {$IFDEF LANGUAGESTRINGSWRITE}
    if DefaultValue = Result then
    begin
      dmLang.LangSource.SaveString(MsgName,DefaultValue);
    end;
    {$ENDIF}
  end
  else
    Result := DefaultValue;
end;


function GetMessageRulerString(const DefId:string;const DefStr:string):string; //Возвращает локализованную строку Линеек
begin
  Result := GetLanguageString('Ruler form',DefId,DefStr);
end;


end.
