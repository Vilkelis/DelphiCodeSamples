unit uMain;

interface

uses
  Contnrs, uLib, uStorage, ShellAPI,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, pngimage, XPMan, Mask, ComCtrls, Spin,
  ImgList;

const cIntervalW = 6;
const cIntervalFirstW = 4;
const cIntervalH = 6;
const cRbW = 14;
const cRbH = 14;
const cEditorWidth  =  100;
const cEditorLeft = 180;
const cUnitInterval = 6;
const cEditorIntervalW = 10;
const cDistanceLeft = 4;
const cDistanceLeftEditor = 150;

//Координаты расположения картинок
const cImLeft = 16;
const cImTop = 104;

type
  TfmMain = class(TForm)
    cbForma: TComboBox;
    cbMaterial: TComboBox;
    lbW1: TLabel;
    lbWeight: TLabel;
    lbW2: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    lbA1: TLabel;
    lbA2: TLabel;
    lbA3: TLabel;
    lbArea: TLabel;
    Image4: TImage;
    lbTemplate: TLabel;
    XPManifest1: TXPManifest;
    imShveller: TImage;
    ImageList1: TImageList;
    imDvutavr: TImage;
    imKvadrat: TImage;
    imList: TImage;
    imPrutok: TImage;
    imTavr: TImage;
    imTruba: TImage;
    imUgol: TImage;
    imProfil: TImage;
    imShestigran: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure cbFormaChange(Sender: TObject);
    procedure cbMaterialChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit1Exit(Sender: TObject);
    procedure cbFormaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbMaterialKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RbKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
     Lib:TLib;
     FControlsBrands:TComponentList;
     FControlsForma:TComponentList;
     FColorOrange:TColor;
    procedure makeSetFocusNext(Sender:TObject);
  public
    { Public declarations }
    procedure MetalListChanged(Sender:TObject);
    procedure FormaChanged(Sender:TObject);
    procedure MetalChanged(Sender:TObject);
    procedure BrandChanged(Sender:TObject);
    procedure EditorChanged(Sender:TObject);
    procedure Calculated(Sender:TObject);
    procedure RbClick(Sender:TObject);
    procedure LbClick(Sender:TObject);
    procedure makeTabOrder; //Восстановление TabOrder контролов
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}



procedure TfmMain.FormCreate(Sender: TObject);
var pColor:TColor;
begin
   Caption := Application.Title;
   FControlsBrands := TComponentList.Create(True);
   FControlsForma := TComponentList.Create(True);
   FColorOrange := RGB(223, 105, 48);

  Lib := loadLib(Self);

  pColor := FColorOrange; // RGB(223, 105, 48);
  lbWeight.Font.Color := pColor;
  lbW1.Font.Color := pColor;
  lbW2.Font.Color := pColor;

  lbArea.Font.Color := pColor;
  lbA1.Font.Color := pColor;
  lbA2.Font.Color := pColor;
  lbA3.Font.Color := pColor;

  pColor := RGB(32,32,33);
  cbForma.Font.Color := pColor;
  cbMaterial.Font.Color := pColor;
  lbTemplate.Font.Color := pColor;

  cbForma.Items.Clear;
  cbMaterial.Items.Clear;

  Lib.LoadFormas(cbForma.Items);
  cbForma.ItemIndex := 0;
  Lib.OnChangeForma := FormaChanged;
  Lib.OnChangeMetalList := MetalListChanged;
  Lib.OnChangeMetal := MetalChanged;
  Lib.OnChangeBrand := BrandChanged;
  Lib.OnCalculated := Calculated;
  cbFormaChange(Self);
end;

procedure TfmMain.Image4Click(Sender: TObject);
var pFilePath:string;
begin
 //Переход на сайт
  pFilePath := 'http://mk74.ru';
  ShellExecute(Handle, PChar('Open'), PChar(pFilePath), nil,
                 PChar(ExtractFileDir(Application.ExeName)), SW_SHOWNORMAL);
end;

procedure TfmMain.cbFormaChange(Sender: TObject);
begin
  //При изменении формы изделия.
  //Изменение списка материалов (если надо)
  Lib.CurrentForma :=  TForma(Lib.Formas[cbForma.ItemIndex]);
end;

procedure TfmMain.cbMaterialChange(Sender: TObject);
begin
  Lib.CurrentMetal := TMetal(Lib.CurrentMetalList.Metals[cbMaterial.ItemIndex]);
end;

procedure TfmMain.FormaChanged(Sender: TObject);
var i:integer;
    Lb:TLabel;
    LbU:TLabel;
    Ed:TEdit;
begin
   lbA1.Visible := Lib.CurrentForma.UseArea;
   lbA2.Visible := Lib.CurrentForma.UseArea;
   lbA3.Visible := Lib.CurrentForma.UseArea;
   lbArea.Visible := Lib.CurrentForma.UseArea;

   for i := 0 to Lib.Formas.Count - 1 do
   begin
     if Assigned(TForma(Lib.Formas[i]).Picture) then
     begin
        if TForma(Lib.Formas[i]) <> Lib.CurrentForma then
        begin
          TForma(Lib.Formas[i]).Picture.Visible := False;
        end
        else   begin
         TForma(Lib.Formas[i]).Picture.Top := cImTop;
         TForma(Lib.Formas[i]).Picture.Left := cImLeft;
         TForma(Lib.Formas[i]).Picture.Visible := True;
        end;

     end;
   end;

   //Переделать
   FControlsForma.Clear;
   for i := 0 to Lib.CurrentForma.Params.Count -  1 do
   begin
      Ed := TEdit.Create(Self);
      Lb := TLabel.Create(Self);
      LbU := TLabel.Create(Self);
      FControlsForma.Add(Ed);
      FControlsForma.Add(Lb);
      FControlsForma.Add(LbU);
      Ed.Parent := Self;
      Lb.Parent := Self;
      LbU.Parent := Self;
      Lb.Font.Assign(lbTemplate.Font);
      Lb.Height := lbTemplate.Height;
      LbU.Font.Assign(lbTemplate.Font);
      LbU.Height := lbTemplate.Height;
      Ed.Font.Assign(lbTemplate.Font);
      Ed.Font.Color := FColorOrange;

      Lb.Caption := TFormaParam(Lib.CurrentForma.Params[i]).Caption;
      Lb.Transparent := True;
      Lb.AutoSize := True;

      LbU.Caption := TFormaParam(Lib.CurrentForma.Params[i]).UnitText;
      LbU.Transparent := True;
      LbU.AutoSize := True;

      Ed.Tag := Integer(Lib.CurrentForma.Params[i]);
      Ed.Text := TFormaParam(Lib.CurrentForma.Params[i]).ValueText;
      Ed.OnChange := EditorChanged;
      Ed.OnKeyPress := Edit1KeyPress;
      Ed.OnExit := Edit1Exit;
      Ed.Hint := TFormaParam(Lib.CurrentForma.Params[i]).Hint;
      if Ed.Hint <> '' then
        Ed.ShowHint := True;
      Lb.Hint := Ed.Hint;
      Lb.ShowHint := Ed.ShowHint;


      Lb.Left := cbForma.Left  + cDistanceLeftEditor;
      Ed.Width := cEditorWidth;
      Ed.Left := Lb.Left + cEditorLeft;
      LbU.Left := Ed.Left + Ed.Width + cUnitInterval;

      Ed.Top := (cbForma.Top + cbForma.Height) + (cEditorIntervalW)*(i+1) + Ed.Height*(i);
      if i = 0 then
      begin
       Ed.Top := Ed.Top + cIntervalFirstW;
      end;
      Lb.Top := Ed.Top + Round( (Ed.Height - Lb.Height)/2) ;
      LbU.Top := Lb.Top;
      Lb.Tag := Integer(Ed);
      LbU.Tag := Integer(Ed);

   end;
   Lib.Calculate;
   makeTabOrder;
end;

procedure TfmMain.MetalListChanged(Sender: TObject);
var i:integer;
    m:TMetal;
begin
 //Нужно по возможности восстановить подсвеченный итем.
 m := Lib.CurrentMetal;
 i := Lib.CurrentMetalList.FindMetalNo(m);
 Lib.LoadMetals(cbMaterial.Items);
 if i >= 0 then
  cbMaterial.ItemIndex := i
 else
  cbMaterial.ItemIndex := 0;
 Lib.CurrentMetal := TMetal(Lib.CurrentMetalList.Metals[cbMaterial.ItemIndex]);
end;



procedure TfmMain.MetalChanged(Sender: TObject);
var i:integer;
    Rb:TRadioButton;
    Lb:TLabel;
begin

  //Пересоздать список марок.
  FControlsBrands.Clear;
  Lib.CurrentBrand := nil;
  //Очистка текущих брендов
  if Lib.CurrentMetal.UseBrands = True then
  begin
    for i := 0  to Lib.CurrentMetal.Brands.Count - 1 do
    begin
      Rb := TRadioButton.Create(Self);
      Lb := TLabel.Create(Self);
      FControlsBrands.Add(Rb);
      FControlsBrands.Add(Lb);
      Rb.Parent := Self;
      Rb.OnKeyDown := RbKeyDown;
      Lb.Parent := Self;
      Rb.Width := cRbW;
      Rb.Height := cRbH;
      Lb.Font.Assign(lbTemplate.Font);
      Rb.Font.Assign(lbTemplate.Font);
      Lb.Height := lbTemplate.Height;

      Lb.Caption := TBrand(Lib.CurrentMetal.Brands[i]).Caption;
      Lb.Transparent := True;
      Lb.AutoSize := True;

      Rb.Tag := Integer(Lib.CurrentMetal.Brands[i]);
      Rb.Width := Rb.Height;
      Rb.Left := cbMaterial.Left + cDistanceLeft;
      Lb.Top := (cbMaterial.Top + cbMaterial.Height) + (cIntervalW)*(i+1) + Lb.Height*(i);
      if i = 0 then
      begin
       Lb.Top := Lb.Top + cIntervalFirstW;
       Rb.Checked := True;
       Lib.CurrentBrand := TBrand(Rb.Tag);
      end;
      Rb.OnClick := RbClick;
      Rb.Top := Lb.Top + Round( (Lb.Height - Rb.Height)/2) ;
      Lb.Left := Rb.Left + Rb.Width + cIntervalH;
      Lb.Tag := Integer(Rb);
      Lb.OnClick := LbClick;

    end;
  end;
  makeTabOrder;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
   FControlsBrands.Free;
   FControlsForma.Free;
end;

procedure TfmMain.RbClick(Sender: TObject);
begin
  if TRadioButton(Sender).Checked then
   Lib.CurrentBrand := TBrand(TRadioButton(Sender).Tag);
end;

procedure TfmMain.LbClick(Sender: TObject);
begin
  TRadioButton(TLabel(Sender).Tag).Checked := True;
  RbClick(TRadioButton(TLabel(Sender).Tag));
end;

procedure TfmMain.EditorChanged(Sender: TObject);
begin
  //Нужно выполнить перерасчет Объема и Веса
  TFormaParam(TEdit(Sender).Tag).ValueText := TEdit(Sender).Text;
  Lib.Calculate;
end;

procedure TfmMain.makeSetFocusNext(Sender:TObject) ;
var   j, i:integer;
      isFound:boolean;
begin
   isFound := False;
   i := TEdit(Sender).TabOrder;
   for j := 0  to  self.ControlCount - 1 do
   begin
     if (Self.Controls[j] is TWinControl) and (TWinControl(Self.Controls[j]).TabOrder = i + 1) then
     begin
       TWinControl(Self.Controls[j]).SetFocus;
       isFound := True;
       break;
     end;
   end;
   if isFound = False then
   begin
     for j := 0  to  self.ControlCount - 1 do
     begin
       if (Self.Controls[j] is TWinControl) and (TWinControl(Self.Controls[j]).TabOrder = 0) then
       begin
         TWinControl(Self.Controls[j]).SetFocus;
         break;
       end;
     end;
   end;
end;

procedure TfmMain.Edit1KeyPress(Sender: TObject; var Key: Char);
var m: set of char;
begin

 { case Key of
  '0'..'9':;
  #8:;
  else Key:=#0;
  end;
  }
{if (key in [ #48..#57]) or (key in [ #37..#40]) or (key=#8)
    then
 else key:=#0}
 m := ['0'..'9','.',',',#8];
 if ord(key) = 13 then
 begin
   makeSetFocusNext(Sender);
 end;
 if not (key in m) then key := chr(0);


end;

procedure TfmMain.Edit1Exit(Sender: TObject);
begin
  TEdit(Sender).Text := TFormaParam(TEdit(Sender).Tag).ValueText;
  Lib.Calculate;
end;

procedure TfmMain.Calculated(Sender: TObject);
begin
 //Выполнены вычисления.
 lbWeight.Caption := Lib.CurrentForma.CalculatedWeight;
 //Нужно вывести значения
 lbArea.Caption := Lib.CurrentForma.CalculatedArea;
end;

procedure TfmMain.BrandChanged(Sender: TObject);
begin
  Lib.Calculate;    
end;

procedure TfmMain.makeTabOrder;
var i:integer;
    tOrd:integer;
begin
 tOrd := 0;
 cbForma.TabOrder := tOrd; tOrd := tOrd + 1;
 //Контролы формы
 for i := 0  to FControlsForma.Count - 1 do
 begin
   if FControlsForma[i] is TWinControl then
     TWinControl(FControlsForma[i]).TabOrder := tOrd; tOrd := tOrd + 1;
 end;

 cbMaterial.TabOrder := tOrd; tOrd := tOrd + 1;
 //Контролы брендов
 for i := 0  to FControlsBrands.Count - 1 do
 begin
   if FControlsBrands[i] is TWinControl then
     TWinControl(FControlsBrands[i]).TabOrder := tOrd; tOrd := tOrd + 1;
 end;

end;

procedure TfmMain.cbFormaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if ord(key) = 13 then
 begin
   makeSetFocusNext(Sender);
 end;
end;

procedure TfmMain.cbMaterialKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if ord(key) = 13 then
 begin
   makeSetFocusNext(Sender);
 end;
end;

procedure TfmMain.RbKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if ord(key) = 13 then
 begin
   makeSetFocusNext(Sender);
 end;

end;

end.
