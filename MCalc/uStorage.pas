unit uStorage;

interface
uses Math, SysUtils, Classes, Contnrs, QStrings,ExtCtrls;

//Преобразование из строки в число и обратно
function TextToNum(AText:string):double;
function NumToText(ANum:double):string;


function IndRound(const Value:double;const Scale:integer = 0):double;

type
  TUnitKind = (ukMM, ukM);  //Вид единицы измерения

type

 //Металл
 TMetal = class(TObject)
  private
    FUseBrands: boolean;
    FDensity: double;
    FCaption: string;
    FBrands: TObjectList;
 public
   constructor Create(ACaption:string;AUseBrands:boolean = True; ADensity:double =0);
   destructor Destroy; override;
   function AddBrand(ACaption:string; ADensity:double):TObject; //Добавляет бренд в список
   function BrandAdd(ADensity:double;ACaption:string):TObject;

   property Caption:string read FCaption write FCaption; //Наименование металла для списка
   property Brands:TObjectList read FBrands; //Доступные марки
   property UseBrands:boolean read FUseBrands write FUseBrands; //Использует марки
   property Density:double read FDensity write FDensity; //Плотность если не использует марки
 end;

 //Марка металла
 TBrand = class(TObject)
  private
    FDensity: double;
    FCaption: string;
 public
   constructor Create(ACaption:string; ADensity:double);
   property Caption:string read FCaption write FCaption; //Наименование
   property Density:double read FDensity write FDensity; //Плотность
 end;

 //Список металлов (их у нас будет 2 скорее всего)
 TMetalList = class(TObject)
 private
    FMetals: TObjectList;
    FDescription: string;
 public
   constructor Create(ADescription:string);
   destructor Destroy; override;
   function FindMetalNo(AMetal:TMetal):integer; //Ищет в списке метал и возвращает его индекс, если не найден, то -1   
   property Metals:TObjectList read FMetals;
   property Description:string read FDescription;
 end;



 //Параметр формы (длина, ширина, высота и т.д.)
 TFormaParam = class (TObject)
  private
    FCaption: string;
    FHint: string;
    FName: string;
    FUnitKind: TUnitKind;
    FValue: double;
    function getUnitText: string;
    function getValueText: string;
    procedure setValueText(const AValue: string);
 public
    constructor Create(AName:string; ACaption:string; AUnitKind:TUnitKind; AHint:string = '');
    property Name:string read FName write FName; //Наименование для поиска
    property Caption:string read FCaption write FCaption; //Наименование
    property Hint:string read FHint write FHint; //Хинт
    property UnitKind:TUnitKind read FUnitKind write FUnitKind; //Единицы измерения
    property Value:double read FValue write FValue; //Текущее значение
    property UnitText:string read getUnitText;
    property ValueText:string read getValueText write setValueText;
 end;


 //Форма (лист, пруток и т.д.)
 TForma = class (TObject)
  private
    FCaption: string;
    FMetalList: TMetalList;
    FUseArea: boolean;
    FParams: TObjectList;
    FName: string;
    FPicture: TImage;

    function getCalculatedArea: string;
    function getCalculatedWeight: string;
 protected
   FCalculatedW:double;
   FCalculatedA:double;
 public
   property Name:string read FName write FName;
   property Caption:string read FCaption write FCaption;
   property MetalList:TMetalList read FMetalList write FMetalList;
   property UseArea:boolean read FUseArea write FUseArea;//Использует ли прощадь (отображает и расчитывает ее)
   property Params:TObjectList read FParams; //Форма ввода параметров и хранилище их значений
   property CalculatedWeight:string read getCalculatedWeight; //Вычисленный вес
   property CalculatedArea:string read getCalculatedArea; //Вычисленный объем
   property Picture:TImage read FPicture write FPicture; //Картинка 
   function AddParam(AName:string; ACaption:string; AUnitKind:TUnitKind; AHint:string = ''):TFormaParam;
   procedure SetCalculated(W:double;A:double);
   function getParamValue(AName:string):double; //Возвращает значение параметра по его имени
   function val(AName:string):double; //Краткая запись getParamValue

   constructor Create(ACaption:string; AMetalList:TMetalList);
   destructor Destroy; override;
 end;

  TSaveValue =  class(TObject)
  private
    FValue: double;
    FName: string;
    procedure SetName(const Value: string);
    procedure SetValue(const Value: double);
 public
   property Name:string read FName write SetName;
   property Value:double read FValue write SetValue;
 end;

 TLib = class (TComponent)
  private
    FLibObj: TObjectList;
    FFormas: TObjectList;
    FSavedValues:TObjectList;
    FCurrentForma: TForma;
    FCurrentMetalList: TMetalList;
    FOnChangeMetalList: TNotifyEvent;
    FOnChangeForma: TNotifyEvent;
    FMetal: TMetal;
    FOnChangeMetal: TNotifyEvent;
    FOnCalculated: TNotifyEvent;
    FBrand: TBrand;
    FOnChangeBrand: TNotifyEvent;
    FLastForma: TForma;
    procedure SetCurrentForma(const Value: TForma);
    procedure SetCurrentMetalList(const Value: TMetalList);
    procedure SetMetal(const Value: TMetal);
    procedure SetBrand(const Value: TBrand);
    function FindSavedValue(AName:string):TSaveValue;
    procedure AddSavedValue(AName:string; AValue:double);
    function getSavedValue(AName:string):double;
 public
   function AddMetal(ACaption:string;AUseBrands:boolean = True; ADensity:double =0):TMetal; //Добавить металл
   function AddMetalList(ADescription:string):TMetalList; //Добавить список металов
   function AddForma(ACaption:string; AMetalList:TMetalList):TForma; //Добавить форму изделия
   procedure LoadFormas(AItems:TStrings);  //Загружает список форм
   procedure LoadMetals(AItems:TStrings); //Загружает список
   procedure Calculate; //Вычислить


   property LibObj:TObjectList read FLibObj; //Список всех объектов

   property Formas:TObjectList read FFormas; //Список всех форм


   property CurrentForma:TForma read FCurrentForma write SetCurrentForma;
   property LastForma:TForma read FLastForma;
   property CurrentMetalList:TMetalList read FCurrentMetalList write SetCurrentMetalList;
   property CurrentMetal:TMetal read FMetal write SetMetal;
   property CurrentBrand:TBrand read FBrand write SetBrand;
//   property CurrentBrand:TBrand read FBrand write SetBrand;

   property OnChangeMetalList:TNotifyEvent read FOnChangeMetalList write FOnChangeMetalList;
   property OnChangeForma:TNotifyEvent read FOnChangeForma write FOnChangeForma;
   property OnChangeMetal:TNotifyEvent read FOnChangeMetal write FOnChangeMetal;
   property OnChangeBrand:TNotifyEvent read FOnChangeBrand write FOnChangeBrand;
   property OnCalculated:TNotifyEvent read FOnCalculated write FOnCalculated;



   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
 end;



implementation
uses uLib;

function RoundToExWork(const AV: Extended; const ADigit: integer = -2): double;
var
  s: string;
  st: Int64;
  sf: real;
  AValue:extended;
begin
  AValue := ABS(AV);
  s:=floattostr(AValue * IntPower(10, -ADigit));
  st:=trunc(strtofloat(s));
  sf:=Frac(strtofloat(s));
  if (not IsZero(sf - 0.5)) then
  begin
    if sf<0.5 then result:=st*IntPower(10, ADigit);
    if sf>=0.5 then result:=(st+1)*IntPower(10, ADigit);
  end
  else begin
    result:=(st+1)*IntPower(10, ADigit);
  end;
  if IsZero(AV) then
    Result := 0
  else if AV < 0 then
    Result := - Result;
end;


function SimpleRoundToEx(const AValue: Extended; const ADigit: TRoundToRange = -2): Extended;
begin
  Result := RoundToExWork(AValue,ADigit);
end;


function RRoundFracPart( X: Extended; AScale : Integer ): Extended;
begin
  if AScale < 0 then raise Exception.Create('Scale must be >= 0. Function Round');
  Result := SimpleRoundToEx(X,-AScale);
end;


function RoundToScale(const AValue: Double; const AScale: integer): Double;
begin
 Result := RRoundFracPart(AValue,AScale);
end;

function IndRound(const Value:double;const Scale:integer = 0):double;
begin
  Result := RoundToScale(Value,Scale);
end;



//Арифметическое округление (вроде работает)



//Преобразование из строки в число и обратно
function TextToNum(AText:string):double;
var s:string;
    Fs:TFormatSettings;
begin
  Fs.ThousandSeparator := ' ';
  Fs.DecimalSeparator := '.';
  s := trim(AText);
  s := Q_ReplaceText(s,' ','');
  s := Q_ReplaceText(s,',','.');
  try
    Result := StrToFloat(s,Fs);
  except
    Result := 0;
  end;
end;

function NumToText(ANum:double):string;
begin
  Result := FloatToStr(ANum);
end;


{ TMetal }

function TMetal.AddBrand(ACaption: string; ADensity: double): TObject;
var b:TBrand;
begin
  b := TBrand.Create(ACaption,ADensity);
  FBrands.Add(b);
  Result := b;
end;

function TMetal.BrandAdd(ADensity: double; ACaption: string): TObject;
begin
  Result := AddBrand(ACaption,ADensity);
end;

constructor TMetal.Create(ACaption:string;AUseBrands:boolean = True; ADensity:double =0);
begin
 FCaption := ACaption;
 FUseBrands := AUseBrands;
 FDensity := ADensity;
 FBrands := TObjectList.Create(True);
end;

destructor TMetal.Destroy;
begin
  FBrands.Clear;
  FBrands.Free;
  inherited;
end;

{ TMetalList }

constructor TMetalList.Create(ADescription:string);
begin
 FMetals := TObjectList.Create(False);
 FDescription := ADescription;
end;

destructor TMetalList.Destroy;
begin
  FMetals.Clear;
  FMetals.Free;
  inherited;
end;

function TMetalList.FindMetalNo(AMetal: TMetal): integer;
var i:integer;
begin
  if Assigned(AMetal) then
  begin
    Result :=  FMetals.IndexOf(AMetal);
    if Result < 0 then
    begin
      for i := 0 to FMetals.Count - 1 do
      begin
         if uppercase(TMetal(FMetals[i]).Caption) =  uppercase(AMetal.Caption) then
         begin
           Result := i;
           break;
         end;
      end;
    end;
  end
  else begin
    Result := -1;
  end;


end;

{ TLib }

function TLib.AddForma(ACaption: string; AMetalList: TMetalList): TForma;
begin
 Result := TForma.Create(ACaption,AMetalList);
 FLibObj.Add(Result);
 FFormas.Add(Result);
end;

function TLib.AddMetal(ACaption: string; AUseBrands: boolean;
  ADensity: double): TMetal;
begin
  Result := TMetal.Create(ACaption, AUseBrands, ADensity);
  FLibObj.Add(Result);
end;

function TLib.AddMetalList(ADescription: string): TMetalList;
begin
  Result := TMetalList.Create(ADescription);
  FLibObj.Add(Result);
end;

procedure TLib.AddSavedValue(AName: string; AValue: double);
var v:TSaveValue;
begin
  if AValue <> 0 then
  begin
    v := FindSavedValue(AName);
    if not Assigned(v) then
    begin
      v := TSaveValue.Create;
      FSavedValues.Add(v);
      v.Name := AName;
      v.Value := AValue;
    end
    else begin
      if v.Value = 0 then
        v.Value := AValue;
    end;
  end;
end;

procedure TLib.Calculate;
var pDensity:double;
begin
  if Assigned(CurrentMetal) then
  begin
    if CurrentMetal.UseBrands = False then
    begin
     pDensity := CurrentMetal.Density;
    end
    else begin
     if Assigned(CurrentBrand) then
       pDensity := CurrentBrand.Density
     else
      pDensity := 0;

    end;
    calculateValues(CurrentForma,pDensity);
    if Assigned(FOnCalculated) then FOnCalculated(Self);
  end;
end;

constructor TLib.Create(AOwner: TComponent);
begin
  inherited;
  FLibObj := TObjectList.Create(True);
  FFormas := TObjectList.Create(False);
  FSavedValues := TObjectList.Create(True);
  FCurrentForma := nil;
  FCurrentMetalList := nil;
  FLastForma := nil;
end;

destructor TLib.Destroy;
begin
  FFormas.Free;
  FLibObj.Clear;
  FLibObj.Free;
  FSavedValues.Clear;
  FSavedValues.Free;
  inherited;
end;

function TLib.FindSavedValue(AName: string): TSaveValue;
var i:integer;
begin
  Result := nil;
  for i := 0 to FSavedValues.Count - 1 do
  begin
    if TSaveValue(FSavedValues[i]).Name = AName then
    begin
      Result := TSaveValue(FSavedValues[i]);
      break;
    end;
  end;
end;

function TLib.getSavedValue(AName: string): double;
var v:TSaveValue;
begin
  v := FindSavedValue(AName);
  if Assigned(v) then
  begin
    Result := v.Value;
  end
  else begin
    Result := 0;
  end;
end;

procedure TLib.LoadFormas(AItems: TStrings);
var i:integer;
begin
 AItems.Clear;
 for i := 0 to FFormas.Count - 1 do
 begin
   AItems.AddObject(TForma(FFormas.Items[i]).Caption,FFormas.Items[i]);
 end;
end;

procedure TLib.LoadMetals(AItems: TStrings);
var i:integer;
begin
 if Assigned(FCurrentMetalList) then
 begin
   AItems.Clear;
   for i := 0 to FCurrentMetalList.Metals.Count - 1 do
   begin
     AItems.AddObject(TMetal(FCurrentMetalList.Metals[i]).Caption,FCurrentMetalList.Metals[i]);
   end;
 end;
end;

procedure TLib.SetBrand(const Value: TBrand);
begin
 if Value <> FBrand then
 begin
    FBrand := Value;
  if Assigned(FOnChangeBrand) then FOnChangeBrand(Self);
 end;

end;

procedure TLib.SetCurrentForma(const Value: TForma);
var i:integer;
    s:string;
    p:TFormaParam;
begin
 if Value <> FCurrentForma then
 begin
  FLastForma := FCurrentForma; //Сохраняем прошлую форму
  FCurrentForma := Value;
  //Сохраняем все параметры
  if Assigned(FLastForma) then
  begin
    for i := 0 to FLastForma.Params.Count - 1 do
    begin
      p := TFormaParam(FLastForma.Params[i]);
      if p.Value <> 0 then
        AddSavedValue(p.Name,p.Value);
    end;
  end;
  //Устанавливаем значения из сохраненных значений, если мы это можем
  for i := 0 to FCurrentForma.Params.Count - 1 do
  begin
    p := TFormaParam(FCurrentForma.Params[i]);
    if p.Value = 0 then
     p.Value :=  getSavedValue(p.Name);
  end;


  if Assigned(FOnChangeForma) then FOnChangeForma(Self);
  if Assigned(FCurrentForma) then  CurrentMetalList := FCurrentForma.MetalList;
 end;
end;

procedure TLib.SetCurrentMetalList(const Value: TMetalList);
begin
 if Value <> FCurrentMetalList then
 begin
   FCurrentMetalList := Value;
   if Assigned(FOnChangeMetalList) then FOnChangeMetalList(Self);
 end;
end;

procedure TLib.SetMetal(const Value: TMetal);
begin
 if Value <> FMetal then
 begin
  FMetal := Value;
  if Assigned(FOnChangeMetal) then FOnChangeMetal(Self);
 end;
end;

{ TBrand }

constructor TBrand.Create(ACaption: string; ADensity: double);
begin
  FCaption := ACaption;
  FDensity := ADensity;
end;

{ TForma }

function TForma.AddParam(AName, ACaption: string; AUnitKind: TUnitKind;
  AHint: string):TFormaParam;
begin
  Result := TFormaParam.Create(AName, ACaption,AUnitKind,AHint);
  FParams.Add(Result);
end;


constructor TForma.Create(ACaption: string; AMetalList: TMetalList);
begin
  FCaption := ACaption;
  FMetalList := AMetalList;
  FUseArea := False;
  FParams := TObjectList.Create(True);
end;

destructor TForma.Destroy;
begin
  FParams.Clear;
  FParams.Free;
  inherited;
end;

function TForma.getCalculatedArea: string;
begin
  Result := FormatFloat('#0.00',IndRound(FCalculatedA,2));
end;

function TForma.getCalculatedWeight: string;
begin
  Result :=  FormatFloat('#0.000', IndRound(FCalculatedW,3));
end;

function TForma.getParamValue(AName: string): double;
var i:integer;
begin
 Result := 0;
 for i := 0 to FParams.Count - 1 do
 begin
   if uppercase(trim(TFormaParam(FParams[i]).Name)) = trim(uppercase(AName)) then
   begin
     Result := TFormaParam(FParams[i]).Value;
     break;
   end;
 end;
end;

procedure TForma.SetCalculated(W, A: double);
begin
   if W >= 0 then
   begin
    FCalculatedW := W;
   end
   else begin
    FCalculatedW := 0;
   end;

   if A >= 0 then
   begin
     FCalculatedA := A;
   end
   else begin
     FCalculatedA := 0;
   end;
end;

function TForma.val(AName: string): double;
begin
 Result := getParamValue(AName); 
end;

{ TFormaParam }

constructor TFormaParam.Create(AName, ACaption: string;
  AUnitKind: TUnitKind; AHint: string);
begin
  FName := AName;
  FCaption := ACaption;
  FUnitKind := AUnitKind;
  FHint := AHint;
  FValue := 0;
end;

function TFormaParam.getUnitText: string;
begin
  if FUnitKind = ukM then
    Result := 'м'
  else
    Result := 'мм';
end;

function TFormaParam.getValueText: string;
begin
  Result := NumToText(Value);
end;

procedure TFormaParam.setValueText(const AValue: string);
begin
  Value := TextToNum(AValue);
end;

{ TSaveValue }

procedure TSaveValue.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TSaveValue.SetValue(const Value: double);
begin
  FValue := Value;
end;

end.
