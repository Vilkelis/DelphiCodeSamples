unit fmuLine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxControls, cxContainer, cxEdit, cxLabel, ExtCtrls, QLocal,
  QFormLocal, Placemnt;

type
  TfmLine = class(TForm)
    FormStorage: TFormStorage;
    Localizer: TQFormLocalizer;
    imRotate: TImage;
    imSettings: TImage;
    imClose: TImage;
    imSizeW: TImage;
    imSizeH: TImage;
    imShActive: TImage;
    imShNotActive: TImage;
    pnTop: TPanel;
    pnLeft: TPanel;
    pnRight: TPanel;
    pnBottom: TPanel;
    lbNum: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imRotateClick(Sender: TObject);
    procedure pnLeftMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnLeftMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnLeftMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnRightMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnRightMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnRightMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnBottomMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnBottomMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnBottomMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnTopMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnTopMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imCloseClick(Sender: TObject);
    procedure imSizeWClick(Sender: TObject);
    procedure imSizeHClick(Sender: TObject);
    procedure imShActiveClick(Sender: TObject);
    procedure imShNotActiveClick(Sender: TObject);
    procedure LocalizerLanguageChanged(Sender: TObject);
  private
    { Private declarations }
   { Private declarations }
    pShActive:boolean;
    pDown:boolean;
    pSizeWL:boolean;
    pSizeWR:boolean;
    pSizeHT:boolean;
    pSizeHB:boolean;
    pX,pY:integer;
    pColorLine:TColor;
    pColorSelf:TColor;
    function GetIsVertical: boolean;
    procedure SetIsVertical(const Value: boolean);
    function GetIsShActive: boolean;
    procedure SetIsShActive(const Value: boolean);
    function GetRulerName: string;
    procedure SetRulerName(const Value: string);
    function GetSettingsButtonVisible: boolean;
    procedure SetSettingsButtonVisible(const Value: boolean);
  public
    { Public declarations }
    procedure Localize; virtual;
    { Public declarations }
    procedure RealingButtons;

    property IsVertical:boolean read GetIsVertical write SetIsVertical;
    property IsShActive:boolean read GetIsShActive write SetIsShActive;
    property RulerName:string read GetRulerName write SetRulerName;
    property SettingsButtonVisible:boolean read GetSettingsButtonVisible write SetSettingsButtonVisible;

  end;

var
  fmLine: TfmLine;

const
cRulerimShActive = 'IdRulerimShActive';
cRulerimShNotActive = 'IdRulerimShNotActive';
cRulerimSizeH = 'IdRulerimSizeH';
cRulerimSizeW = 'IdRulerimSizeW';
cRulerimSettings = 'IdRulerimSettings';
cRulerimRotate = 'IdRulerimRotate';
cRulerimClose = 'IdRulerimClose';

resourcestring
IdRulerimShActive = 'Remove fixing';
IdRulerimShNotActive = 'Fix';
IdRulerimSizeH = 'Full sceen height';
IdRulerimSizeW = 'Full sceen width';
IdRulerimSettings = 'Settings';
IdRulerimRotate = 'Rotate';
IdRulerimClose = 'Close';


const cDistMax = 1;
const cDist = 5;
const cMouseZoneWidth = 4;
const cLineWidth = 1;
const cFactor = 5;

implementation
uses dmuLang, Unit1;
{$R *.dfm}

procedure TfmLine.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Shift = [ssLeft] then
 begin
   if Cursor <> crHandPoint then
   begin
     pDown := True;
     pX := X;
     pY := Y
   end;
 end;
end;

procedure TfmLine.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var pDistX,pDistY:integer;
begin
 if pDown then
 begin
   pDistX := pX - X;
   pDistY := pY - Y;
   if pShActive then
   begin
     if Width > Height then
     begin
       SetBounds(Left, Top - pDistY, Width, Height);
     end
     else begin
       SetBounds(Left - pDistX, Top, Width, Height);
     end;
   end
   else begin
     SetBounds(Left - pDistX, Top - pDistY, Width, Height);
   end;
 end;
end;

procedure TfmLine.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  pDown := False;
end;

procedure TfmLine.FormCreate(Sender: TObject);
begin
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  inherited;
  RulerName := '';
  pShActive := False;
  pDown := False;
  pSizeWL := False;
  pSizeWR := False;
  pSizeHT := False;
  pSizeHB := False;
  pColorLine := clInfoText;
  pColorSelf := clGradientActiveCaption;
  RealingButtons;
  SettingsButtonVisible := False;
  Localize;
end;



procedure TfmLine.imRotateClick(Sender: TObject);
begin
  if Height < Width then
   SetBounds(Left + Width - Height - imRotate.Width - cDist*2 , Top - imRotate.Height  - cDist*2, Height,Width)
  else
   SetBounds(Left - Height + Width + imRotate.Width + cDist*2 , Top + imRotate.Height  + cDist*2 , Height,Width);
  RealingButtons;
end;

procedure TfmLine.RealingButtons;
begin
 if Width > Height then
 begin
  imClose.Left := Width - imRotate.Width - cDist;
  imClose.Top := Trunc((Height - imRotate.Height) /2) ;

  imRotate.Left := imClose.Left - 2 * cDist  - imRotate.Width;
  imRotate.Top := imClose.Top;

  imSizeW.Left := imRotate.Left - cDist - imSizeW.Width ;
  imSizeW.Top := imRotate.Top;
  imSizeH.Left := imSizeW.Left;
  imSizeH.Top := imSizeW.Top;
  imSizeW.Visible := True;
  imSizeH.Visible := False;



  lbNum.Left := cDist;
  lbNum.Top :=  Trunc((Height - lbNum.Height) /2);

  imSettings.Left := lbNum.Left + lbNum.Width + cDist;
  imSettings.Top := imSizeW.Top;

  imShActive.Left := imSizeW.Left - cDist - imSettings.Width ;
  imShActive.Top := imSettings.Top;
  imShNotActive.Left := imShActive.Left;
  imShNotActive.Top := imShActive.Top;
  imShNotActive.Visible := not pShActive;
  imShActive.Visible := pShActive;




  pnLeft.Cursor := crSizeWE;
  pnRight.Cursor := crSizeWE;
  pnTop.Cursor := crDefault;
  pnBottom.Cursor := crDefault;
  pnTop.Color := pColorLine;
  pnRight.Color := pColorSelf;
  pnLeft.Color := pColorSelf;
  pnBottom.Color := pColorSelf;


  pnLeft.Align := alLeft;
  pnTop.Align := alTop;
  pnBottom.Align := alBottom;
  pnRight.Align := alRight;

  pnLeft.Width := cMouseZoneWidth;
  pnTop.Height := cLineWidth;
  pnBottom.Height := cMouseZoneWidth;
  pnRight.Width := cMouseZoneWidth;

  pnTop.BringToFront;
 end
 else begin

  imClose.Left := Trunc((Width - imRotate.Width ) / 2);
  imClose.Top := cDist;

  imRotate.Left := imClose.Left;
  imRotate.Top := imClose.Top + 2 * cDist  + imRotate.Height;



  imSizeH.Left := imRotate.Left;
  imSizeH.Top := imRotate.Top  + cDist + imSizeW.Height;
  imSizeW.Left := imSizeH.Left;
  imSizeW.Top := imSizeH.Top;
  imSizeW.Visible := False;
  imSizeH.Visible := True;

  imShActive.Left := imRotate.Left;
  imShActive.Top := imSizeW.Top  +  cDist + imShActive.Height;
  imShNotActive.Left := imShActive.Left;
  imShNotActive.Top := imShActive.Top;
  imShNotActive.Visible := not pShActive;
  imShActive.Visible := pShActive;


  lbNum.Left := Trunc((Width - lbNum.Width) /2);
  lbNum.Top :=  Self.Height - cDist - lbNum.Height;

  imSettings.Left := imRotate.Left;
  imSettings.Top := lbNum.Top - cDist - imSettings.Height;



  pnTop.Cursor := crSizeNS;
  pnBottom.Cursor := crSizeNS;
  pnLeft.Cursor := crDefault;
  pnRight.Cursor := crDefault;

  pnTop.Color := pColorSelf;
  pnLeft.Color := pColorLine;
  pnRight.Color := pColorSelf;
  pnBottom.Color := pColorSelf;

  pnLeft.Align := alLeft;
  pnTop.Align := alNone;
  pnBottom.Align := alNone;
  pnRight.Align := alRight;

  pnLeft.Width := cLineWidth;
  pnTop.Height := cMouseZoneWidth;
  pnBottom.Height := cMouseZoneWidth;
  pnRight.Width := cMouseZoneWidth;

  pnBottom.Left := pnLeft.Width;
  pnBottom.Top := Self.Height - pnBottom.Height;
  pnBottom.Width := Self.Width - pnLeft.Width - pnRight.Width;
  pnTop.Left := pnLeft.Width;
  pnTop.Top := 0;
  pnTop.Width := Self.Width  - pnLeft.Width - pnRight.Width;

  pnLeft.BringToFront;
 end;
end;

procedure TfmLine.pnLeftMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Shift = [ssLeft] then
 begin
   if TPanel(Sender).Cursor <> crDefault then
   begin
     pX := X;
     pY := Y;
     pSizeWL := True;
   end;
 end;
end;

procedure TfmLine.pnLeftMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var pDistX,pDistY:integer;
begin
 if pSizeWL then
 begin
   pDistX := pX - X;
   pDistY := pY - Y;
   if Width + pDistX > Height * cFactor then
   begin
     SetBounds(Left - pDistX, Top , Width + pDistX, Height);
     RealingButtons;
   end;
 end;
end;

procedure TfmLine.pnLeftMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   pSizeWL := False;
end;

procedure TfmLine.pnRightMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Shift = [ssLeft] then
 begin
   if TPanel(Sender).Cursor <> crDefault then
   begin
     pX := X;
     pY := Y;
     pSizeWR := True;
   end;
 end;
end;

procedure TfmLine.pnRightMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  var pDistX,pDistY:integer;
begin
 if pSizeWR then
 begin
   pDistX := pX - X;
   pDistY := pY - Y;
   if Width - pDistX > Height * cFactor then
   begin
     SetBounds(Left, Top , Width - pDistX, Height);
     RealingButtons;
   end;
 end;
end;

procedure TfmLine.pnRightMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 pSizeWR := False;
end;

procedure TfmLine.pnBottomMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Shift = [ssLeft] then
 begin
   if TPanel(Sender).Cursor <> crDefault then
   begin
     pX := X;
     pY := Y;
     pSizeHB := True;
   end;
 end;
end;

procedure TfmLine.pnBottomMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var pDistX,pDistY:integer;
begin
 if pSizeHB then
 begin
   pDistX := pX - X;
   pDistY := pY - Y;
   if Height - pDistY > Width * cFactor then
   begin
     SetBounds(Left, Top , Width, Height - pDistY);
     RealingButtons;
   end;
 end;
end;

procedure TfmLine.pnBottomMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  pSizeHB := False;
end;

procedure TfmLine.pnTopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Shift = [ssLeft] then
 begin
   if TPanel(Sender).Cursor <> crDefault then
   begin
     pX := X;
     pY := Y;
     pSizeHT := True;
   end;
 end;
end;

procedure TfmLine.pnTopMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var pDistX,pDistY:integer;
begin
 if pSizeHT then
 begin
   pDistX := pX - X;
   pDistY := pY - Y;
   if Height + pDistY > Width * cFactor then
   begin
     SetBounds(Left , Top - pDistY, Width, Height + pDistY);
     RealingButtons;
   end;
 end;
end;

procedure TfmLine.pnTopMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  pSizeHT := False;
end;

procedure TfmLine.imCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmLine.imSizeWClick(Sender: TObject);
begin
 if Width > Height then
 begin
   SetBounds(0, Top, Screen.Width, Height);
   RealingButtons;
 end;
end;

procedure TfmLine.imSizeHClick(Sender: TObject);
begin
 if Width < Height then
 begin
   SetBounds(Left, 0, Width, Screen.Height);
   RealingButtons;
 end;
end;

procedure TfmLine.imShActiveClick(Sender: TObject);
begin
  pShActive := False;
  imShActive.Visible := pShActive;
  imShNotActive.Visible := not pShActive;
end;

procedure TfmLine.imShNotActiveClick(Sender: TObject);
begin
  pShActive := True;
  imShActive.Visible := pShActive;
  imShNotActive.Visible := not pShActive;
end;

function TfmLine.GetIsVertical: boolean;
begin
  Result := Height > Width;
end;

procedure TfmLine.SetIsVertical(const Value: boolean);
begin
 if Value then
 begin
   if  Height < Width then
   begin
     imRotateClick(nil);
   end;
 end
 else begin
   if  Height > Width then
   begin
     imRotateClick(nil);
   end;
 end;

end;

function TfmLine.GetIsShActive: boolean;
begin
 Result := pShActive;
end;

procedure TfmLine.SetIsShActive(const Value: boolean);
begin
 if Value <> pShActive then
 begin
   pShActive := Value;
   imShNotActive.Visible := not pShActive;
   imShActive.Visible := pShActive;
 end;
end;


function TfmLine.GetRulerName: string;
begin
  Result := lbNum.Caption;
end;

procedure TfmLine.SetRulerName(const Value: string);
begin
 if Value <> lbNum.Caption then
 begin
  lbNum.Caption := Value;
  RealingButtons;
 end;
end;

function TfmLine.GetSettingsButtonVisible: boolean;
begin
  Result := imSettings.Visible;
end;

procedure TfmLine.SetSettingsButtonVisible(const Value: boolean);
begin
  imSettings.Visible := Value;
end;

procedure TfmLine.Localize;
begin
  inherited;
  imShActive.Hint := GetMessageRulerString(cRulerimShActive,IdRulerimShActive);
  imShNotActive.Hint := GetMessageRulerString(cRulerimShNotActive,IdRulerimShNotActive);
  imSizeH.Hint := GetMessageRulerString(cRulerimSizeH,IdRulerimSizeH);
  imSizeW.Hint := GetMessageRulerString(cRulerimSizeW,IdRulerimSizeW);
  imSettings.Hint := GetMessageRulerString(cRulerimSettings,IdRulerimSettings);
  imRotate.Hint := GetMessageRulerString(cRulerimRotate,IdRulerimRotate);
  imClose.Hint := GetMessageRulerString(cRulerimClose,IdRulerimClose);

end;


procedure TfmLine.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfmLine.LocalizerLanguageChanged(Sender: TObject);
begin
 Localize;
end;

end.
