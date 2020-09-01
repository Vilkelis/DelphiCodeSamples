unit uIndMemorySQL;

interface
{Комопненты по выполнению SQL по таблицам памяти}
uses Variants, DB, Classes, SysUtils, IndSQLDataSetU, uIndVarValue;


type
//Для вычисления суммарных данных по полям закешированных таблиц памяти
TIndBaseAggregatesCalculator = class (TComponent)
private
    FSQL:TIndMemSQL;
    FCalsResult:TIndVarValueList;
    FTableName: string;
    FFilter: string;
    FExpression: string;
    FCalcResult: TIndVarValueList;
    FDetailFields:TStringList;
    function GetDefailFields: string;
    function GetParams: TParams;
    procedure SetDetailFields(const Value: string);
    procedure SetExpression(const Value: string);
    procedure SetFilter(const Value: string);
    procedure SetTableName(const Value: string);
protected
  procedure Changed; virtual;
  procedure MakeSQL; virtual; //Формирование SQL запроса
public
  property Expression:string read FExpression write SetExpression;
  property TableName:string read FTableName write SetTableName;
  property DetailFields:string read GetDefailFields write SetDetailFields; //Поля связки Master-Detail
  property Filter:string read FFilter write SetFilter; //Дополнительный фильтр
  property Params:TParams read GetParams;
  property CalcResult:TIndVarValueList read FCalcResult; //Результат вычислений

  function Calculate:variant; virtual; //Вычисляет агрегированные поля, возврашает значение первого полученного агрегированного поля
  constructor Create(AOwner:TComponent); override;
  destructor Destroy; override;
end;

TIndAggregatesCalculator = class (TIndBaseAggregatesCalculator)
private
 FTable: TComponent;
 procedure SetTable(const Value: TComponent);
protected
 procedure TableChanged;
public
 function Calculate:variant; override;
 property Table:TComponent read FTable write SetTable;
published
 property Expression;
 property Filter;
 property Params;
 property CalcResult;

end;

implementation
uses uIndTables, RvDataSetBaseU, SQLMemMain;


{ TIndBaseAggregatesCalculator }

function TIndBaseAggregatesCalculator.Calculate: variant;
var i:integer;
begin
 FCalcResult.Clear;
 try
  FSQL.Open;
  try
    for i := 0 to FSQL.FieldCount - 1 do
    begin
     FCalsResult.Add(FSQL.Fields[i].FieldName,FSQL.Fields[i].Value);
    end;
    if FCalsResult.Count > 0 then
     Result := FCalsResult.Items[0].Value
    else
     Result := null;
  finally
    FSQL.Active := False;
  end;
 except
  on E:Exception do
  begin
    raise Exception.Create('Same parameters are incorect. (' + ClassName + '). Error: ' + E.Message);
  end;
 end;
end;

procedure TIndBaseAggregatesCalculator.Changed;
begin
 MakeSQL; 
end;

constructor TIndBaseAggregatesCalculator.Create(AOwner: TComponent);
begin
  inherited;
  FSQL := TIndMemSQL.Create(Self);
  FCalcResult :=  TIndVarValueList.Create;
  FDetailFields := TStringList.Create;
  FDetailFields.Delimiter := ';';
end;

destructor TIndBaseAggregatesCalculator.Destroy;
begin
  FreeAndNil(FCalcResult);
  FreeAndNil(FSQL);
  FreeAndNil(FDetailFields);
  inherited;
end;

function TIndBaseAggregatesCalculator.GetDefailFields: string;
begin
 Result := FDetailFields.DelimitedText;
end;

function TIndBaseAggregatesCalculator.GetParams: TParams;
begin
 Result := FSQL.Params;
end;


procedure TIndBaseAggregatesCalculator.MakeSQL;
var i:integer;
    s:string;
begin
 FSQL.Active := False;
 FSQL.SQL.BeginUpdate;
 try
   FSQL.SQL.Add('select ');
   FSQL.SQL.Add(Expression);
   FSQL.SQL.Add('from ' + TableName);
   FSQL.SQL.Add('where ');
   for i := 0 to FDetailFields.Count - 1 do
   begin
     s := FDetailFields[i] + ' = :' + FDetailFields[i];
     if i > 0 then
     begin
      s := '  and ' + s;
      if i = FDetailFields.Count - 1 then
       s := s + ' )';
     end
     else begin
      s := '(     ';
     end;
     FSQL.SQL.Add(s);
   end;
   FSQL.SQL.Add(Filter);
 finally
  FSQL.SQL.EndUpdate;
 end;
end;

procedure TIndBaseAggregatesCalculator.SetDetailFields(
  const Value: string);
begin
 if Value <> FDetailFields.DelimitedText then
 begin
   FDetailFields.DelimitedText := Value;
   Changed;
 end;
end;

procedure TIndBaseAggregatesCalculator.SetExpression(const Value: string);
begin
 if Value <> FExpression then
 begin
  FExpression := Value;
  Changed;
 end;
end;

procedure TIndBaseAggregatesCalculator.SetFilter(const Value: string);
begin
 if Value <> FFilter then
 begin
  FFilter := Value;
  Changed;
 end;
end;

procedure TIndBaseAggregatesCalculator.SetTableName(const Value: string);
begin
 if Value <> FTableName then
 begin
   FTableName := Value;
   Changed;
 end;
end;

{ TIndAggregatesCalculator }

function TIndAggregatesCalculator.Calculate: variant;
begin
  if Assigned(FTable) then
  begin
   if TIndBaseTable(FTable).Active then
   begin
    if Assigned(TIndBaseTable(FTable).MasterTable) then
    begin
      TIndBaseTable(FTable).DataProvider.SetMasterSQLParameters(Params);
    end;
    Result := inherited Calculate;
   end
   else begin
     raise Exception.Create('Table must be active for use AggrecatesCalcularor.Calculate method');
   end;
  end
  else begin
    Result := null;
  end;
end;

procedure TIndAggregatesCalculator.SetTable(const Value: TComponent);
begin
 if (Value <> FTable) and (FTable is TIndBaseTable) then
 begin
   if Assigned(FTable) then FTable.RemoveFreeNotification(Self);
   FTable := Value;
   if Assigned(FTable) then FTable.FreeNotification(Self);
   TableChanged;
 end;
end;

procedure TIndAggregatesCalculator.TableChanged;
begin
  if Assigned(Table) then
  begin
    DetailFields := TIndBaseTable(Table).DetailFields;
    TableName := TRvSQLMemTable(TIndTable(Table).Data).TableName;
  end
  else begin
    DetailFields := '';
    TableName := '';
  end;
end;

end.
