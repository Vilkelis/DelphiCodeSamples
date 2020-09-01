unit uIndVerticalGrid;

interface
uses Controls,
     Types,
     StdCtrls,
     DB,
     DBCtrls,
     Variants,
     Classes,
     Messages,
     Forms,
     ExtCtrls,
     cxEditTextUtils,
     cxGraphics,
     SysUtils,
     Graphics,
     cxVGrid,
     cxDBVGrid,
     cxEdit,
     cxTextEdit,
     cxButtonEdit,
     cxMaskEdit,
     cxInplaceContainer,
     cxVGridViewInfo,
     uIndEditProperties,
     uIndDataConstant,
     uIndDataCommonClasses,
     uIndFieldsMetadata,
     uIndFormManager,
     uCommonClasses,
     uIndGrid, uIndManagers, 
     uDBAStringsE,
     smDialogs,
     uIndTables,
     RvDesignU,
     uMessages,
     Windows,
     uIndButtonProperties,
     uIndFormulaMetadata,
     uIndCommonControls
     ;

const  cIndVGOneRowGridModeBufferCount = 1;
       cIndVGMultyRowGridModeBufferCount = 50;


type
{Вертикальный грид}


TIndCustomVerticalGrid = class;
TIndVerticalGrid = class;
TIndBaseVerticalGridView = class;




//Позиция строки грида
TIndVerticalGridRowPosition = class (TPersistent)
private
 FRow:TcxCustomRow;
 FNotif:TIndNotif;

 FParentRowIndex:integer;
 FParentRow:string;
 FRowIndex:integer;

 function GetRowIndex: integer;
 procedure SetRowIndex(const Value: integer);
 function GetParentRowIndex: integer;
 procedure SetParentRowIndex(const Value: integer);
 function GetParentRow: string;
 procedure SetParentRow(const Value: string);
 function GetFullName: string;
protected

 procedure DoNotification(ANotificator:TComponent; AComponent: TComponent; Operation: TOperation); 
public
 class function CategoriesBaseName:string;virtual;
 class function EditorsBaseName:string;virtual;
 procedure Assign(Source: TPersistent); override;

 constructor Create(ARow:TcxCustomRow); virtual;
 destructor Destroy; override;
 property Row:TcxCustomRow read FRow;
 property FullName:string read GetFullName;

 property StoredRowIndex:integer read FRowIndex;
published
 property RowIndex:integer read GetRowIndex write SetRowIndex; //Порядок текущей строки
// property ParentRowIndex:integer read GetParentRowIndex write SetParentRowIndex; //Номер владельца
 property ParentRow:string read GetParentRow write SetParentRow; 
end;

TIndVerticalGridCategorySaver = class(TIndPersistentSaver)
protected
  function GetStoreObjectName:string;override;
  procedure GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);override;
  procedure SetStorageProperties(const Value:{TStringList}TIndStorePropertiesList);override;

  function GetPersistentStorager:TComponent;override;
//  function GetPathToStoredObject:string;override;
public
  function GetSaveOwner:TComponent;override;
end;

TIndSimpleUpdaterRowIndex = class(TIndSimpleIndexUpdater)
private
  FRow: TIndFieldItem;
protected
  function GetSortByParam(Index:integer):string;override;
  function GetSortObject(Index:integer):TObject;override;
  function GetCount:integer;override;
  procedure MakeUpdateAction(Index:integer);override;
public
  property Row:TIndFieldItem read FRow write FRow;
end;

//установщик индексов editor и category для нулевого уровня вложенности
TIndSimpleUpdaterZeroLevelIndex = class(TIndSimpleIndexUpdater)
private
  FZeroLevelList:TList;
protected
  function GetSortByParam(Index:integer):string;override;
  function GetSortObject(Index:integer):TObject;override;
  function GetCount:integer;override;
  procedure MakeUpdateAction(Index:integer);override;

public
  constructor Create;
  destructor Destroy;override;
  property ZeroLevelList:TList read FZeroLevelList;

end;


TIndVerticalGridCategory = class (TIndFieldItemCaption)
private
 FGridCategory:TcxCategoryRow;
 FPosition:TIndVerticalGridRowPosition;
 FFieldCaptionType: TIndDBCaptionType;
 FDataLink:TFieldDataLink;
 FEnable:boolean;
 FVisible:boolean;
 FDefaultCollapse: Boolean;
 FVerticalGridCategorySaver:TIndVerticalGridCategorySaver;
 FUpdaterCategoryRowIndex:TIndSimpleUpdaterRowIndex;

 function GetGridView: TIndBaseVerticalGridView;

 function GetVisible: Boolean;
 procedure SetVisible(const Value: Boolean);
 function GetParentRow: TcxCustomRow;
 procedure SetParentRow(const Value: TcxCustomRow);
 function GetParentIndRow: TIndFieldItem;
 procedure SetParentIndRow(const Value: TIndFieldItem);
 procedure SetPosition(const Value: TIndVerticalGridRowPosition);
 procedure SetFieldCaptionType(const Value: TIndDBCaptionType);
 procedure SetDefaultCollapse(const Value: Boolean);
 function GetExpanded: Boolean;
 procedure SetExpanded(const Value: Boolean);
 function GetLevel: integer;


protected
 procedure DataChange(Sender:TObject);
 procedure FieldChanged(Sender:TObject); override;

 function GetRow:TcxCustomRow; //Возвращает строку грида
 class function DefaultUseFieldCaption:boolean; override;
 procedure UpdateObjectCaption; override;

 class function BaseName:string; override;
 procedure FreeCategory;

 property GridCategory:TcxCategoryRow read FGridCategory;
 procedure CreateCategory;

 property ParentRow:TcxCustomRow read GetParentRow write SetParentRow;
 property ParentIndRow:TIndFieldItem read GetParentIndRow write SetParentIndRow;
public

 function GetStoredIndex:integer;override;
 procedure SetRealIndex(const Value:integer);override;
 function GetChildCount: integer;override;
 function GetChildren(Index: integer): TIndFieldItem;override;
 {IIndVisualControl}
 function IndFocused:boolean; override;
 procedure IndSetFocus; override;
 function IndCanFocus:boolean; override;
 procedure IndSetEnable(const AValue:boolean); override;
 function IndGetEnable:boolean; override;
 procedure IndSetVisible(const AValue:boolean); override;
 function IndGetVisible:boolean; override;

 procedure UpdateIndexes;
 constructor Create(ACollection:TCollection); override;
 destructor Destroy; override;
 property View:TIndBaseVerticalGridView read GetGridView;
 property Expanded:Boolean read GetExpanded write SetExpanded;
 property CategorySaver:TIndVerticalGridCategorySaver read FVerticalGridCategorySaver;

 property ChildCount:integer read GetChildCount;
 property Children[Index:integer]:TIndFieldItem read GetChildren;
 property Level:integer read GetLevel;
published
 property DefaultCollapse:Boolean read FDefaultCollapse write SetDefaultCollapse;
 property Position:TIndVerticalGridRowPosition read FPosition write SetPosition;
 property UseFieldCaption default  False;
 property FieldCaptionType:TIndDBCaptionType read FFieldCaptionType write SetFieldCaptionType default ctFieldCaption;
 property Caption;
 property Visible: Boolean read GetVisible write SetVisible default True;
 property Name;
 property Field;
end;


TIndVerticalGridCategories = class (TIndFieldItemCollection)
private
 function GetItems(AIndex: integer): TIndVerticalGridCategory;
 procedure SetItems(AIndex: integer; const Value: TIndVerticalGridCategory);
 function GetView: TIndBaseVerticalGridView;
 function FindIndCategory(ACategory: TcxCategoryRow): TIndVerticalGridCategory;
protected
 procedure FreeCategories;
 procedure Loaded;
public

 function FindIndCaregoryByName(FName:string): TIndVerticalGridCategory;
 function FindRowByName(const FName:string):TcxCustomRow;
 constructor Create(AOwner:TIndBaseVerticalGridView); virtual;
 destructor Destroy;override;
 procedure Notify(Item: TCollectionItem; Action: TCollectionNotification);override;
 function Add:TIndVerticalGridCategory;
 procedure Update(Item: TCollectionItem);override;
 property Items[AIndex:integer]:TIndVerticalGridCategory read GetItems write SetItems; default;
 property View:TIndBaseVerticalGridView read GetView;
published

end;


TIndVerticalGridEditorSaver = class(TIndPersistentSaver)
protected
  function GetStoreObjectName:string;override;
  procedure GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);override;
  procedure SetStorageProperties(const Value:{TStringList}TIndStorePropertiesList);override;

  function GetPersistentStorager:TComponent;override;
  //function GetPathToStoredObject:string;override;
public
  function GetSaveOwner:TComponent;override;

end;

TIndVerticalGridEditor = class (TIndFieldEditorItem)
private
 FPosition:TIndVerticalGridRowPosition;
 FGridEditor:TcxDBEditorRow;
 FEditorSaver:TIndVerticalGridEditorSaver;
 FDefaultCollapse: Boolean;
 FUpdaterEditorRowIndex:TIndSimpleUpdaterRowIndex;

// FButtonView:TcxEditButton;
 function GetGridView: TIndBaseVerticalGridView;

 function GetVisible: Boolean;
 procedure SetVisible(const Value: Boolean);
 function GetParentRow: TcxCustomRow;
 procedure SetParentRow(const Value: TcxCustomRow);
 procedure SetPosition(const Value: TIndVerticalGridRowPosition);
 function GetExpanded: Boolean;
 procedure SetExpanded(const Value: Boolean);
 procedure SetDefaultCollapse(const Value: Boolean);
    function GetLevel: integer;

protected
 function GetRow:TcxCustomRow;
 class function DefaultUseFieldCaption:boolean; override;
 procedure SetDataBindingProperty(const AFieldName:string); override;
 function FieldEditor:TComponent; override; //Возвращает компонент -редактор (например в случае грида TcxDbGridColumn)
 procedure UpdateObjectCaption; override; //Обновление Caption в объекте (необходимо перекрыть в наследнике)
 procedure SetFieldEditorPropertiesClass(AClass:TcxCustomEditPropertiesClass); override;
 function GetFieldEditorProperties:TcxCustomEditProperties; override;
 function CanShowEditors:boolean; override;
 procedure SetIsEditor; override;
 procedure SetNotEditor; override;


 class function BaseName:string; override;
 procedure FreeEditor;
 property GridEditor:TcxDBEditorRow read FGridEditor;
 procedure CreateEditor;

 function GetEditValue: Variant;override;
 procedure SetEditValue(const Value: Variant);override;

public
 function GetStoredIndex:integer;override;
 procedure SetRealIndex(const Value:integer);override;
 function GetChildCount: integer;override;
 function GetChildren(Index: integer): TIndFieldItem;override;

 {IIndVisualControl}
 function IndFocused:boolean; override;
 procedure IndSetFocus; override;
 function IndCanFocus:boolean; override;
 procedure IndSetEnable(const AValue:boolean); override;
 function IndGetEnable:boolean; override;
 procedure IndSetVisible(const AValue:boolean); override;
 function IndGetVisible:boolean; override;

 procedure UpdateIndexes;
 constructor Create(ACollection:TCollection); override;
 destructor Destroy; override;
 property View:TIndBaseVerticalGridView read GetGridView;
 property Expanded:Boolean read GetExpanded write SetExpanded;
// property ButtonView:TcxEditButton read FButtonView write FButtonView;

 property ChildCount:integer read GetChildCount;
 property Children[Index:integer]:TIndFieldItem read GetChildren;
 property Level:integer read GetLevel;
published
 property DefaultCollapse:Boolean read FDefaultCollapse write SetDefaultCollapse;
 property UseFieldCaption default True;
 property Visible: Boolean read GetVisible write SetVisible default True;
 property Position:TIndVerticalGridRowPosition read FPosition write SetPosition;
 property Caption;
 property Name;
 property Field;
end;

TIndVerticalGridEditors = class (TIndFieldItemCollection)
private
 function GetItems(AIndex: integer): TIndVerticalGridEditor;
 procedure SetItems(AIndex: integer; const Value: TIndVerticalGridEditor);
 function GetView: TIndBaseVerticalGridView;
 function FindIndEditor(AEditor: TcxDBEditorRow): TIndVerticalGridEditor;
protected
 procedure FreeEditors;
 procedure Loaded;
public
 function FindIndEditorByName(FName:string): TIndVerticalGridEditor;
 function FindRowByName(const FName:string):TcxCustomRow;
 constructor Create(AOwner:TIndBaseVerticalGridView); virtual;
 destructor Destroy;override;
 procedure Notify(Item: TCollectionItem; Action: TCollectionNotification);override;
 function Add:TIndVerticalGridEditor;
 procedure Update(Item: TCollectionItem);override;
 property Items[AIndex:integer]:TIndVerticalGridEditor read GetItems write SetItems; default;
 property View:TIndBaseVerticalGridView read GetView;
published

end;

TIndVerticalGridColumnViewInfo = class(TIndColumnViewInfo)
private
  FRecordIndex: integer;
  FRowProperties: TcxDBEditorRowProperties;
  procedure SetRecordIndex(const Value: integer);
  procedure SetRowProperties(const Value: TcxDBEditorRowProperties);
protected
 function GetFieldValue: variant; override;
 function GetValueInfo(const AFieldName:string; var AExists:boolean):variant; override;
public
  property RecordIndex:integer read FRecordIndex write SetRecordIndex;
  property RowProperties:TcxDBEditorRowProperties read FRowProperties write SetRowProperties;
 constructor Create;override;
published
 property FieldValue;
 property FieldName;
 property FieldNameUp;
 property Visible;
 property Enabled;
end;



TIndBaseVerticalGridView = class (TInterfacedPersistent,IFetchLimitListener)
private
  FIndGrid: TIndCustomVerticalGrid;
  FTable:TIndTableRef;
  FOnTableChanged: TNotifyEvent;
  FCategories: TIndVerticalGridCategories;
  FEditors: TIndVerticalGridEditors;
  procedure SetIndGrid(const Value: TIndCustomVerticalGrid);
  procedure DoFetchLimitChanged(Sender:TObject);
//  function GetStatusMessage: string;
//  procedure SetStatusMessage(const Value: string);

  procedure UpdateTableProperties;
  procedure DoBeforeTableChange(const Sender:TObject; const OldTable:TIndMetadataTable; const NewTable:TIndMetadataTable);
  procedure SetDataSet(const Value: TIndBaseDataSet);
  procedure SetTable(const Value: TIndTableRef);
  function GetDataSet: TIndbaseDataSet;
  function GetTable: TIndTableRef;

  procedure DoGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure DoGridDblClick(Sender:TObject);
  function GetValueMinWidth: integer;
  function GetValueWidth: integer;
  procedure SetValueMinWidth(const Value: integer);
  procedure SetValueWidth(const Value: integer);
  procedure SetCategories(const Value: TIndVerticalGridCategories);
  procedure SetEditors(const Value: TIndVerticalGridEditors);
    function GetLayoutStyle: TcxvgLayoutStyle;
    procedure SetLayoutStyle(const Value: TcxvgLayoutStyle);
    {IFetchLimitListener}
    procedure FetchLimited(Sender: TObject); //Выполянется при двойном щелчке на строке грида или при нажатии клавиши Enter
    procedure FetchNoLimited(Sender: TObject);
    procedure DoLChanged;

protected
 procedure LayoutStyleChanged;virtual;
 procedure DblClickAction; virtual;

 procedure DummiNotVisibleGetDisplayText(Sender: TcxCustomEditorRowProperties; ARecord: Integer; var AText: String);
 procedure DummiNotEnabledGetDisplayText(Sender: TcxCustomEditorRowProperties; ARecord: Integer; var AText: String);

 procedure DoDrawRowHeder(Sender: TObject;
                          ACanvas: TcxCanvas;
                          APainter: TcxvgPainter;
                          AHeaderViewInfo: TcxCustomRowHeaderInfo;
                          var Done: Boolean);



 procedure DoDrawValue(Sender: TObject;
                      ACanvas: TcxCanvas;
                      APainter: TcxvgPainter;
                      AValueInfo: TcxRowValueInfo;
                      var Done: Boolean);


  procedure ViewEditing(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties; var Allow: Boolean); virtual; //Здесь производится разрешение показа редактора поля
  procedure DoAfterEditing(AItem:TcxDBEditorRow);
  procedure DoOnClickViewButton;virtual;

  procedure TableChanged(Sender:TObject); virtual;

  function ViewTable:TIndBaseTable; virtual;
  procedure SetDataSource;
  procedure CreateGridColumns;
  procedure FreeGridColumns;

  function GetGrid: TcxDBVerticalGrid;
  function FindEditor(AEditor:TcxDBEditorRow):TIndVerticalGridEditor;
  function FindCategory(ACategory:TcxCategoryRow):TIndVerticalGridCategory;

//  property StatusMessage:string read GetStatusMessage write SetStatusMessage;
  property Grid:TcxDBVerticalGrid read GetGrid;
public
  property IndGrid:TIndCustomVerticalGrid read FIndGrid write SetIndGrid;
  procedure Assign(Source: TPersistent); override;
  constructor Create(AGrid:TIndCustomVerticalGrid); virtual;
  destructor Destroy; override;

  property DataSet:TIndBaseDataSet read GetDataSet write SetDataSet;
  property Table:TIndTableRef read GetTable write SetTable;
  property OnTableChanged:TNotifyEvent read FOnTableChanged write FOnTableChanged;
  property Categories:TIndVerticalGridCategories read FCategories write SetCategories;
  property Editors:TIndVerticalGridEditors read FEditors write SetEditors;

  property ValueMinWidth:integer read GetValueMinWidth write SetValueMinWidth;
  property ValueWidth:integer read GetValueWidth write SetValueWidth;

  property LayoutStyle:TcxvgLayoutStyle read GetLayoutStyle write SetLayoutStyle default lsSingleRecordView;
end;

TIndVerticalGridView = class (TIndBaseVerticalGridView,IPropertiesGroup)
protected
 procedure LayoutStyleChanged;override;
public
 //IPropertiesGroup
 function PropertyName:string;

 property DataSet;
 property Table;
published
  property ValueMinWidth;
  property ValueWidth;
  property Categories;
  property Editors;
  property LayoutStyle;

end;

TIndVerticalGridViewClass = class of TIndVerticalGridView;

TIndVerticalGridManager = class (TIndControlDataSetActionManager)
protected
 function GetTableRef:TIndTableRef; override;
public
 function GetGroupName:string; override;
end;

TIndVerticalGridButtonProperties = class(TIndButtonProperties)
protected
  function Properties(AButtonParent:TPersistent):TcxCustomEditProperties;override;
  function GetField(AButtonParent:TPersistent):TIndFieldRef;override;
//  function GetButtonBrowse(AButtonParent:TPersistent):TcxEditButton;override;
//  procedure SetButtonBrowse(AButtonParent:TPersistent;AButton:TcxEditButton);override;
  function IsEditing(AButtonParent:TPersistent):boolean;override;
  function GetIndFieldEditorItem(AButtonParent:TPersistent):TPersistent;override;    
end;

TIndCxDBVerticalGridController = class(TcxvgMultiRecordsController)
protected
  procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
end;

TIndcxDBVerticalGrid = class (TcxDBVerticalGrid,IIndControlRefreshSelection)
private
 FIndVerticalGrid:TIndCustomVerticalGrid;
 FButtonProperties:TIndButtonProperties;
 function IsLoading:boolean;
protected
 function GetControllerClass: TcxCustomControlControllerClass; override;
 procedure RepaintControl(AObject:TPersistent);
 function GetIndObject(AObject:Tpersistent):TObject;
 function GetNativeObject(AObject:Tpersistent):TObject;
 function IsNativeObject(AObject:TPersistent):boolean;
public
 //после начала редактирования
 procedure DoAfterEditingGrid(AEditor:TcxDbEditorRow);virtual;
 //при завершении редактирования
 procedure DoEdited(Sender: TObject;
      ARowProperties: TcxCustomEditorRowProperties);virtual;
 procedure DoChangeRecord(Sender: TObject;
      AOldRow: TcxCustomRow; AOldCellIndex: Integer);virtual;
 procedure DoFocusedRecordChanged(Sender: TcxVirtualVerticalGrid; APrevFocusedRecord, AFocusedRecord: Integer);
 constructor Create(AOwner:TComponent);override;
 property IndVerticalGrid:TIndCustomVerticalGrid read FIndVerticalGrid write FIndVerticalGrid;
 property Painter;
end;

TIndVerticalGridSaver = class(TIndComponentsSaver)
private
  function GetVerticalGrid:TIndCustomVerticalGrid;
protected
  property VerticalGrid:TIndCustomVerticalGrid read GetVerticalGrid;
  procedure GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);override;
  procedure SetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);override;

public
  procedure LoadComponentsFromStorage;override;
  procedure SaveComponentsToStorage;override;
end;


TIndCustomVerticalGrid = class (TIndCustomGridPanel,
                           IIndListener, IIndActionSource,
                           IOwnerControl,
                           IActionShortCut,
                           IDesignerCanAcceptControls,
                           IIndActiveControl,
                           IIndSaverImplementor,
                           IIndGetForm,
                           IIndVisualControl,
                           IIndGetTable,
                           ILocalizer
                           )
private
 FManager:TIndVerticalGridManager;
 FGrid:TIndcxDBVerticalGrid;
 FView:TIndVerticalGridView;
// FStatusPanel:TIndGridStatusPanel;
 FStatusPanel:TIndStatusMessagePanel;
 FStatusMessages:TIndStatusMessages;
 FVerticalGridSaver:TIndVerticalGridSaver;
 FIndFormTransmitter:TIndFormTransmitter;
 FFocusEditor: integer;
 FZeroLevelIndexUpdater:TIndSimpleUpdaterZeroLevelIndex;

 procedure SetView(const Value: TIndVerticalGridView);
 function FindRow(AEditor:TcxDBEditorRow):TIndVerticalGridEditor;
 function FindCategory(ACategory:TcxCategoryRow):TIndVerticalGridCategory;
 procedure DoResizeGrid(Sender:TObject);
 procedure ResizeChanged(var Message: TWMSize); message WM_SIZE;
protected
 function GetDataSet: TIndBaseDataSet; virtual;
 function GetTable: TIndTableRef; virtual;
 procedure SetDataSet(const Value: TIndBaseDataSet); virtual;
 procedure SetTable(const Value: TIndTableRef); virtual;

 function GetFetchLimitedText:string;
 function GetFilterSetText:string; 
 class function GetGridViewClass:TIndVerticalGridViewClass; virtual;
 function GetIndTable:TIndMetadataTable;
 procedure Loaded; override;
 //IIndSaverImplementor
 function GetSaver:TIndSaver;
 function GetIndObject(AObject:TPersistent):TObject;
 property IndFormTransmitter:TIndFormTransmitter read FIndFormTransmitter implements IIndGetForm;
 //{ILocalizer}
 function GetLocalizedString(const ID, DefaultValue: string): string;
 function GetStringSection: string;
 procedure Localize; //Дополнительная локализация

public

 procedure ChangeStatusPanelText;
 function GetActiveControl:TWinControl;
 function CanAcceptControls:boolean;
 function CanShowEditors:boolean;
 function GetHitTest(Message:TMessage;Sender:TControl):boolean;override;
 //IListener
 procedure HandleEvent(ASender:TObject; const AEvent:integer);
 //IActionSource
 procedure CreateBarView(const IndBar:TComponent);
 procedure DeleteBarView(const IndBar:TComponent);
 procedure AddBar(const IndBar: TComponent);
 procedure DeleteBar(const IndBar: TComponent);
 //IOwnerControl
 function CanSelectAction:boolean;
 //IActionShortCut
 function CanActionShortCut:boolean;
 {IIndVisualControl}
 function IndFocused:boolean; virtual;
 procedure IndSetFocus; virtual;
 function IndCanFocus:boolean; virtual;
 procedure IndSetEnable(const AValue:boolean); virtual;
 function IndGetEnable:boolean; virtual;
 procedure IndSetVisible(const AValue:boolean); virtual;
 function IndGetVisible:boolean; virtual;

 //property StatusPanel:TIndGridStatusPanel read FStatusPanel;
 property StatusPanel:TIndStatusMessagePanel read FStatusPanel;
 property Manager:TIndVerticalGridManager read FManager;



 constructor Create(AOwner:TComponent); override;
 destructor Destroy; override;

 property FocusEditor:integer read FFocusEditor write FFocusEditor;
 property Width;
 property Height;
 property Top;
 property Left;
 property Align;
 property View:TIndVerticalGridView read FView write SetView;
 property Table:TIndTableRef read GetTable write SetTable;
 property DataSet:TIndBaseDataSet read GetDataSet write SetDataSet;
end;


TIndVerticalGrid = class (TIndCustomVerticalGrid)
published
 property FocusEditor;
 property Width;
 property Height;
 property Top;
 property Left;
 property Align;
 property View;
 property Table;
 property DataSet;
end;

TIndFormulaVGridView = class (TIndVerticalGridView)
private
  FFieldTable:TIndTableRef;
  FFormulaInViewId:variant;
  FFormulaInViewMetadata:TComponent;
  FField:TIndFieldRef;
  function GetField: TIndFieldRef;
  procedure SetField(const Value: TIndFieldRef);
    function GetFieldDataSet: TIndBaseDataSet;
    function GetFieldTable: TIndTableRef;
    procedure SetFieldDataSet(const Value: TIndBaseDataSet);
    procedure SetFieldTable(const Value: TIndTableRef);
protected
  procedure DblClickAction; override;

  procedure ClearVGrid;
  procedure MakeVGrid;

  procedure TableChanged(Sender:TObject); override;

  procedure FieldTableChanged(Sender:TObject); virtual;
  procedure FieldChanged(Sender:TObject); virtual;
  procedure BeforeFieldChanged(const Sender:TObject; const OldField:TIndField; const NewField:TIndField); virtual;
public
  procedure MakeFormulaView;
  procedure ClearFormulaView;
  procedure ClearFormulaViewFull;


  property FieldDataSet:TIndBaseDataSet read GetFieldDataSet write SetFieldDataSet;
  property FieldTable:TIndTableRef read GetFieldTable write SetFieldTable;
  property Field:TIndFieldRef read GetField write SetField;


  constructor Create(AGrid:TIndCustomVerticalGrid); override;
  destructor Destroy; override;

end;


TIndFormulaVGrid = class (TIndCustomVerticalGrid,IIndFormulaListener)
protected
 FNoFormulaPanel:TIndCustomLabelPanel;
 function GetDataSet: TIndBaseDataSet; override;
 function GetTable: TIndTableRef; override;
 procedure SetDataSet(const Value: TIndBaseDataSet); override;
 procedure SetTable(const Value: TIndTableRef); override;
 function GetField: TIndFieldRef; virtual;
 procedure SetField(const Value: TIndFieldRef); virtual;


public
  class function GetGridViewClass:TIndVerticalGridViewClass; override;

  procedure MakeFormulaView;
  procedure ClearFormulaView;

  {IIndFormulaListener}
  procedure FormulaTableRefreshed(Sender:TObject); //Обновилась табличная часть формулы

  constructor Create(AOwner:TComponent); override;
published
 property FocusEditor;
 property Width;
 property Height;
 property Top;
 property Left;
 property Align;
 property Table;
 property DataSet;
 property Field:TIndFieldRef read GetField write SetField;
end;




implementation
uses dmuStyles, dmuConnection, cxControls, dmuLanguages, dmuManager;



{ TIndCustomVerticalGrid }

procedure TIndCustomVerticalGrid.AddBar(const IndBar: TComponent);
begin
 FManager.Addbar(IndBar);
end;

function TIndCustomVerticalGrid.CanAcceptControls: boolean;
begin
 Result := False;
end;

function TIndCustomVerticalGrid.CanActionShortCut: boolean;
begin
 Result := FGrid.IsFocused;
end;

function TIndCustomVerticalGrid.CanSelectAction: boolean;
begin
 Result := Assigned(Table.Table) and Assigned(Table.Table.Data) and Table.Table.Data.CanModify;
end;

function TIndCustomVerticalGrid.CanShowEditors: boolean;
begin
 Result := True;
end;

procedure TIndCustomVerticalGrid.ChangeStatusPanelText;
begin
  if (FGrid.LayoutStyle = lsSingleRecordView) then
  begin
    FStatusPanel.Visible := false;
    Exit;
  end
  else
    FStatusPanel.Visible := true;

  with FStatusMessages.FilterMessage do
  begin
    if AppSettings.Options.IndicationOptions.UseFilterIndication then
      MessageStr := GetFilterSetText
    else
      MessageStr := '';  
    FontStyle := [fsBold];
    FontColor := clWhite;
  end;

  with FStatusMessages.FetchLimitMessage do
  begin
    MessageStr := GetFetchLimitedText;
    FontStyle := [];
  end;
  FStatusMessages.Show;
end;

constructor TIndCustomVerticalGrid.Create(AOwner: TComponent);
begin
  inherited;
  FFocusEditor := 0;
  TabStop := False;
  SetBounds(10,10,200,100);
  ControlStyle := [ csAcceptsControls, csOpaque, csSetCaption, csCaptureMouse, csClickEvents, csDoubleClicks];
  FGrid := TIndcxDBVerticalGrid.Create(Self);
  FGrid.SetSubComponent(True);
  FGrid.BorderStyle := cxcbsNone;

  FGrid.OptionsData.DeletingConfirmation := False;
  FGrid.OptionsData.Deleting := False;
  FGrid.OptionsData.Inserting := False;

//  FGrid.OptionsData.Editing := False;
//  FGrid.OptionsData.CancelOnExit := False;

  //m.proh - теперь процессим через мессагу
  //TIndcxDBVerticalGrid(FGrid).OnResize := DoResizeGrid;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  BorderWidth := 1;
  Color := GetGridFocusedCellFocusedColor;

  FGrid.Parent := Self;
  //m.proh
  FGrid.Align := alCustom;//alClient;
  FGrid.IndVerticalGrid := Self;
  FView := GetGridViewClass.Create(Self);
  //FStatusPanel := TIndGridStatusPanel.Create(Self);
  //FStatusPanel.ParentControl := Self;
  FStatusPanel := TIndStatusMessagePanel.Create(Self);
  FStatusPanel.Parent := Self; 
  FStatusPanel.Visible := False;

  FStatusMessages := TIndStatusMessages.Create;
  FStatusMessages.StatusPanel := FStatusPanel;
  
  FManager := TIndVerticalGridManager.Create(Self);
  FManager.AddOwnerControl(Self);
  FView.OnTableChanged := FManager.TableChanged;
  FGrid.OnEditing := FView.ViewEditing;
  FGrid.OnDblClick := FView.DoGridDblClick;
  FGrid.OnKeyDown := FView.DoGridKeyDown;

  FGrid.OnDrawRowHeader := FView.DoDrawRowHeder;
  FGrid.OnDrawValue := FView.DoDrawValue;
  FGrid.Styles.IncSearch := dmStyles.sIncSearch;
  FGrid.OptionsData.CancelOnExit := False;
  //создаем хранитель
  FVerticalGridSaver := TIndVerticalGridSaver.Create(Self);
  FVerticalGridSaver.SavedComponent := Self;
  FIndFormTransmitter := TIndFormTransmitter.Create(Self);
  FIndFormTransmitter.Component := Self;

  FZeroLevelIndexUpdater := TIndSimpleUpdaterZeroLevelIndex.Create;
  
end;

procedure TIndCustomVerticalGrid.CreateBarView(const IndBar: TComponent);
begin
 if Assigned(FManager) then  FManager.CreateBarView(IndBar);
end;

procedure TIndCustomVerticalGrid.DeleteBar(const IndBar: TComponent);
begin
 if Assigned(FManager) then  FManager.DeleteBar(IndBar);
end;

procedure TIndCustomVerticalGrid.DeleteBarView(const IndBar: TComponent);
begin
 if Assigned(FManager) then  FManager.DeleteBarView(IndBar);
end;

destructor TIndCustomVerticalGrid.Destroy;
begin
 // FVerticalGridSaver.SaveComponentsToStorage;
  if Assigned(FGrid) then
  begin
    FGrid.CancelEdit;
    FGrid.OnDrawRowHeader := nil;
    FGrid.OnDrawValue := nil;
    FreeAndNil(FGrid);
  end;
  FreeAndNil(FStatusMessages);
  if Assigned(FView) then FreeAndNil(FView);
  if Assigned(FManager) then FreeAndNil(FManager);
  FreeAndNil(FZeroLevelIndexUpdater);
  inherited;
end;


procedure TIndCustomVerticalGrid.DoResizeGrid(Sender: TObject);
begin
  ChangeStatusPanelText;
end;

function TIndCustomVerticalGrid.FindCategory(
  ACategory: TcxCategoryRow): TIndVerticalGridCategory;
var CategoryIndex:integer;
begin
  Result := nil;
  for CategoryIndex := 0 to View.Categories.Count - 1 do
  begin
    if View.Categories[CategoryIndex].GridCategory = ACategory then
    begin
       Result := View.Categories[CategoryIndex];
       Break;
    end;
  end;
end;

function TIndCustomVerticalGrid.FindRow(
  AEditor: TcxDBEditorRow): TIndVerticalGridEditor;
var EditorIndex:integer;
begin
  Result := nil;
  for EditorIndex := 0 to View.Editors.Count - 1 do
  begin
    if View.Editors[EditorIndex].GridEditor = AEditor then
    begin
       Result := View.Editors[EditorIndex];
       Break;
    end;
  end;
end;

function TIndCustomVerticalGrid.GetActiveControl: TWinControl;
begin
  Result := Self;
end;

function TIndCustomVerticalGrid.GetDataSet: TIndBaseDataSet;
begin
  Result := FView.DataSet;
end;

function TIndCustomVerticalGrid.GetFetchLimitedText: string;
begin
  if  Assigned(Table) and
      Assigned(Table.Table) and
      Table.Table.FetchLimited and
      (Table.Table.FetchLimit > 0) and
      Table.Table.Data.Active and
      (Table.Table.Data.RecordCount = Table.Table.FetchLimit) then
    Result := Format(GetMessageString(idFetchLimited,langFetchLimited),[Table.Table.FetchLimit])
  else
    Result := '';
end;

function TIndCustomVerticalGrid.GetFilterSetText: string;
begin
  Result := '';
  if Assigned(View.Table) and Assigned(View.Table.Table) then
  begin
    if View.Table.Table is TIndMainMetadataTable then
    begin
      if not TIndMainMetadataTable(View.Table.Table).FilterIsEmpty then
        Result := LocalizeGrids(idTcxGridFilterSet,langTcxGridFilterSet)
      else
        Result := LocalizeGrids(idTcxGridFilterNotSet,langTcxGridFilterNotSet);
    end;
  end;
end;

class function TIndCustomVerticalGrid.GetGridViewClass: TIndVerticalGridViewClass;
begin
 Result := TIndVerticalGridView;
end;

function TIndCustomVerticalGrid.GetHitTest(Message: TMessage;
  Sender: TControl): boolean;
var X,Y:integer;
begin
 Result := False;
 X := TWMMouse(Message).XPos;
 Y := TWMMouse(Message).YPos;
 if (Sender is TIndGridStatusPanel) then Exit;
 if (Sender is TcxControlScrollBar) then
 begin
   Result := True;
   Exit;
 end;
 if (Sender is TcxDBVerticalGrid) then
 begin
   if FGrid.HitTest.HitAtRowHeader or
      FGrid.HitTest.HitAtRowSizing or
      FGrid.HitTest.HitAtBandSizing or
      FGrid.HitTest.HitAtCaption or
      FGrid.HitTest.HitAtDivider then
   begin
      Result := True;
      Exit;
   end;
 end;
end;


function TIndCustomVerticalGrid.GetIndObject(AObject: TPersistent): TObject;
begin
  if AObject is TcxDBEditorRow then
    Result := FindRow(TcxDBEditorRow(AObject))
  else if AObject is TcxCategoryRow then
    Result := FindCategory(TcxCategoryRow(AObject))
  else
    Result := AObject;
end;

function TIndCustomVerticalGrid.GetIndTable: TIndMetadataTable;
begin
  Result := Table.Table;
end;

function TIndCustomVerticalGrid.GetLocalizedString(const ID,
  DefaultValue: string): string;
begin
  Result := LocalizeGrids(Id,DefaultValue); 
end;

function TIndCustomVerticalGrid.GetSaver: TIndSaver;
begin
  Result := FVerticalGridSaver; 
end;

function TIndCustomVerticalGrid.GetStringSection: string;
begin
  Result := ClassName;
end;

function TIndCustomVerticalGrid.GetTable: TIndTableRef;
begin
  Result := FView.Table;
end;

procedure TIndCustomVerticalGrid.HandleEvent(ASender: TObject;
  const AEvent: integer);
begin
 if AEvent = cControlSelectionRefresh then
    FGrid.RepaintControl(Self);
end;

function TIndCustomVerticalGrid.IndCanFocus: boolean;
begin
 Result := FGrid.CanFocusEx;
end;

function TIndCustomVerticalGrid.IndFocused: boolean;
begin
 Result := FGrid.IsFocused;
end;

function TIndCustomVerticalGrid.IndGetEnable: boolean;
begin
 Result := FGrid.Enabled;
end;

function TIndCustomVerticalGrid.IndGetVisible: boolean;
begin
 Result := Visible;
end;

procedure TIndCustomVerticalGrid.IndSetEnable(const AValue: boolean);
begin
 FGrid.Enabled := AValue;
end;

procedure TIndCustomVerticalGrid.IndSetFocus;
var pRow,pFirstEditor:TcxCustomRow;
    i:integer;
    pFocused:boolean;
begin
 FGrid.SetFocus;
 i := 0;
 pFocused := False;
 if FGrid.Rows.Count > 0 then
 begin
  pRow := FGrid.FirstRow;
  while Assigned(pRow) do
  begin
    if (not (pRow is TcxCategoryRow)) and pRow.Visible then
    begin
      i := i + 1;
      //Фокусируемся на первой строке
      if not Assigned(pFirstEditor) then   pFirstEditor := pRow;
      if (FocusEditor <= 0) or (FocusEditor = i) then
      begin
       pRow.MakeVisible;
       pRow.Focused := True;
       pRow := nil;
       pFocused := True;
      end;
    end
    else begin
      pRow := FGrid.NextRow(pRow);
    end;
  end;
  if (not pFocused) and Assigned(pFirstEditor) then
  begin
   pFirstEditor.MakeVisible;
   pFirstEditor.Focused := True;
  end;
 end;
end;

procedure TIndCustomVerticalGrid.IndSetVisible(const AValue: boolean);
begin
 Visible := AValue;
end;

procedure TIndCustomVerticalGrid.Loaded;
var i:integer;
begin
  inherited;
  FGrid.BeginUpdate;
  try
    for i := 0 to View.Categories.Count - 1 do
    begin
     View.Categories[i].Position.ParentRow := View.Categories[i].Position.FParentRow;
    end;
    for i := 0 to View.Editors.Count - 1 do
    begin
     View.Editors[i].Position.ParentRow := View.Editors[i].Position.FParentRow;
    end;


  {  for i := 0 to View.Categories.Count - 1 do
    begin
     View.Categories[i].Position.RowIndex  := View.Categories[i].Position.FRowIndex;
    end;

    for i := 0 to View.Editors.Count - 1 do
    begin
     View.Editors[i].Position.RowIndex := View.Editors[i].Position.FRowIndex;
    end;}
    for I := 0 to View.Categories.Count - 1 do
       View.Categories[I].UpdateIndexes;
    for i := 0 to View.Editors.Count - 1 do
       View.Editors[I].UpdateIndexes;
    //апдейтим индексы корневого уровня
    FZeroLevelIndexUpdater.ZeroLevelList.Clear;
    for I := 0 to View.Categories.Count - 1 do
    begin
      if View.Categories[I].Level = 0 then
        FZeroLevelIndexUpdater.ZeroLevelList.Add(View.Categories[I]);
    end;
    for I := 0 to View.Editors.Count - 1 do
    begin
      if View.Editors[I].Level = 0 then
        FZeroLevelIndexUpdater.ZeroLevelList.Add(View.Editors[I]);
    end;
    FZeroLevelIndexUpdater.SortAndUpdate;

  finally
    FGrid.EndUpdate;
  end;
  //FVerticalGridSaver.LoadComponentsFromStorage;
end;

procedure TIndCustomVerticalGrid.Localize;
begin
  ChangeStatusPanelText;
end;

procedure TIndCustomVerticalGrid.ResizeChanged(var Message: TWMSize);
begin
  //FGrid.Align := alNone;
  ChangeStatusPanelText;
  //FGrid.Align := alClient;
  if FStatusPanel.Visible then
    FGrid.SetBounds(BorderWidth, BorderWidth, Width - 2*BorderWidth, Height - FStatusPanel.Height - 2*BorderWidth)
  else
    FGrid.SetBounds(BorderWidth, BorderWidth, Width - 2*BorderWidth, Height - 2*BorderWidth);
end;

procedure TIndCustomVerticalGrid.SetDataSet(const Value: TIndBaseDataSet);
begin
 FView.DataSet := Value;
end;

procedure TIndCustomVerticalGrid.SetTable(const Value: TIndTableRef);
begin
   FView.Table := Value;;
end;

procedure TIndCustomVerticalGrid.SetView(const Value: TIndVerticalGridView);
begin
 if Value <> FView then
 begin
  FView.Assign(Value);
 end;
end;

{ TIndBaseVerticalGridView }

procedure TIndBaseVerticalGridView.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TIndBaseVerticalGridView) then
  begin
   
  end
  else
   inherited;

end;

constructor TIndBaseVerticalGridView.Create(AGrid: TIndCustomVerticalGrid);
begin
  inherited Create;
  FTable := TIndTableRef.Create(AGrid);
  FTable.OnTableChanged := TableChanged;
  FCategories := TIndVerticalGridCategories.Create(Self);
  FEditors := TIndVerticalGridEditors.Create(Self);
  IndGrid := AGrid;
  Grid.OptionsView.ScrollBars := ssVertical;
  Grid.OptionsView.ShowEditButtons := ecsbFocused;
  Grid.LayoutStyle := lsSingleRecordView;
  DoLChanged; //Доп. установка всего к Layout
end;

procedure TIndBaseVerticalGridView.CreateGridColumns;
begin

end;

procedure TIndBaseVerticalGridView.DblClickAction;
begin
 IndGrid.Manager.ExecuteDefaultAction;
end;

destructor TIndBaseVerticalGridView.Destroy;
begin
  if Assigned(FCategories) then
              FreeAndNil(FCategories);
  if Assigned(FEditors) then
              FreeAndNil(FEditors);
  if Assigned(FTable) then
              FreeAndNil(FTable);
  inherited;
end;

procedure TIndBaseVerticalGridView.DoBeforeTableChange(
  const Sender: TObject; const OldTable, NewTable: TIndMetadataTable);
begin
 if Assigned(OldTable) and (not (csDestroying in OldTable.ComponentState)) then
  OldTable.RemoveFetchListener(Self);
end;

procedure TIndBaseVerticalGridView.DoDrawRowHeder(Sender: TObject;
  ACanvas: TcxCanvas; APainter: TcxvgPainter;
  AHeaderViewInfo: TcxCustomRowHeaderInfo; var Done: Boolean);

//var
//  AColor: TColor;
//  R:TRect;

begin
{  if AHeaderViewInfo.Row is TcxDBEditorRow then
  begin
   AHeaderViewInfo.CaptionsInfo.Items[0].ViewParams.TextColor := clRed;

   if Assigned(TcxDBEditorRow(AHeaderViewInfo.Row).Properties.OnGetDisplayText) and
    (TcxDBVerticalGrid(TcxDBEditorRow(AHeaderViewInfo.Row).VerticalGrid).LayoutStyle = lsSingleRecordView) then
   begin
    R := AHeaderViewInfo.CaptionsInfo.Items[0].CaptionTextRect;
    ACanvas.Font.Color := clRed;
    cxTextOut(ACanvas.Canvas, PcxCaptionChar(AHeaderViewInfo.CaptionsInfo.Items[0].Caption), R, AHeaderViewInfo.CaptionsInfo.Items[0].TextFlags,0,0,clRed,clRed);
    Done := True;
   end;
  end;}
end;


procedure TIndBaseVerticalGridView.DoDrawValue(Sender: TObject;
  ACanvas: TcxCanvas; APainter: TcxvgPainter; AValueInfo: TcxRowValueInfo;
  var Done: Boolean);

  procedure GetParentRowInfo(var AEnabled:boolean; var AVisible:boolean);
  begin

  end;

  procedure fsGetVisibleEnable(const AViewInfo:TIndColumnViewInfo);
  begin
    //Вызов FastScrip-а для определения видимости колонки и свойства Enable
    if Assigned(Table.Table)
       and Assigned(Table.Table.DataProvider)
    then begin
      Table.Table.DataProvider.fsDrawGridCell(AViewInfo);
    end;
  end;

  procedure MakeEmpty;
  begin
     ACanvas.FillRect(AValueInfo.ContentRect);
     Done := True;
  end;

  procedure MakeDisable;
  begin
    ACanvas.Font.Color := clGrayText;
  end;

var VInf:TIndVerticalGridColumnViewInfo;
begin
 if Grid.IsFocused then
 begin

   if  AValueInfo.Row.Focused  then
   begin
    if ((LayoutStyle <> lsMultiRecordView) or AValueInfo.Focused) then
    begin
     ACanvas.Brush.Color := GetGridFocusedCellSelectedColor;//GetLightDownedSelColor;
     ACanvas.Font.Color := GetGridFocusedCellSelectedColorText; // clWindowText; //clHighlightText;
    end
    else if (LayoutStyle = lsMultiRecordView) then
    begin
     ACanvas.Brush.Color := GetGridNotFocusedCellSelectedColor;//GetRealColor(GetLightColor(14, 44, 55 ));
     ACanvas.Font.Color := GetGridNotFocusedCellSelectedColorText;
    end;
   end;
 end
 else begin
   if AValueInfo.Row.Focused then
   begin
    if ((LayoutStyle <> lsMultiRecordView) or AValueInfo.Focused) then
    begin
     ACanvas.Brush.Color := GetGridNotFocusedCellSelectedColor;//GetRealColor(GetLightColor(14, 44, 55 ));
     ACanvas.Font.Color := GetGridNotFocusedCellSelectedColorText;
    end;
   end;
 end;

 VInf := TIndVerticalGridColumnViewInfo.Create;
 try
   VInf.RecordIndex := AValueInfo.RecordIndex;
   VInf.RowProperties := TcxDBEditorRow(AValueInfo.Row).Properties;

   //Здесь запуск процедуры Fs
   fsGetVisibleEnable(VInf);
   if not VInf.Visible then
   begin
     TcxDBEditorRow(AValueInfo.Row).Properties.OnGetDisplayText := DummiNotVisibleGetDisplayText;
     MakeEmpty;
   end
   else if not VInf.Enabled then
   begin
     TcxDBEditorRow(AValueInfo.Row).Properties.OnGetDisplayText := DummiNotEnabledGetDisplayText;
     MakeDisable;
   end;
   if VInf.Enabled and VInf.Visible then
   begin
     TcxDBEditorRow(AValueInfo.Row).Properties.OnGetDisplayText := nil;
   end;
 finally
   VInf.Free;
 end;  

end;

procedure TIndBaseVerticalGridView.DoFetchLimitChanged(Sender: TObject);
begin
  IndGrid.ChangeStatusPanelText;
{  if TIndBaseTable(Sender).FetchLimited and (TIndBaseTable(Sender).FetchLimit > 0) and (TIndBaseTable(Sender).Data.RecordCount = TIndMetadataTable(Sender).FetchLimit) then
    StatusMessage := Format(GetMessageString(idFetchLimited,langFetchLimited),[TIndMetadataTable(Sender).FetchLimit])
  else
    StatusMessage := '';}
end;

procedure TIndBaseVerticalGridView.DoGridDblClick(Sender: TObject);
begin
 if Assigned(Grid.HitTest.HitRow) and (Grid.HitTest.HitRow is TcxDBEditorRow)
   and (not Grid.HitTest.HitAtButton)
   and (not Grid.HitTest.HitAtCaption) then
   DblClickAction; 
end;

procedure TIndBaseVerticalGridView.DoGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
 if (Key = 13) and (Shift = []) then
    DblClickAction;
end;


procedure TIndBaseVerticalGridView.DummiNotEnabledGetDisplayText(
  Sender: TcxCustomEditorRowProperties; ARecord: Integer;
  var AText: String);
begin

end;

procedure TIndBaseVerticalGridView.DummiNotVisibleGetDisplayText(
  Sender: TcxCustomEditorRowProperties; ARecord: Integer;
  var AText: String);
begin

end;

procedure TIndBaseVerticalGridView.FreeGridColumns;
begin

end;

function TIndBaseVerticalGridView.GetDataSet: TIndbaseDataSet;
begin
  Result := FTable.DataSet;
end;

function TIndBaseVerticalGridView.GetGrid: TcxDBVerticalGrid;
begin
 if Assigned(FIndGrid) then Result := FIndGrid.FGrid
 else Result := nil;
end;

function TIndBaseVerticalGridView.GetLayoutStyle: TcxvgLayoutStyle;
begin
 Result := Grid.LayoutStyle;
end;

{function TIndBaseVerticalGridView.GetStatusMessage: string;
begin
  Result := IndGrid.StatusPanel.StatusMessage;
end; }

function TIndBaseVerticalGridView.GetTable: TIndTableRef;
begin
 Result := FTable;
end;

function TIndBaseVerticalGridView.GetValueMinWidth: integer;
begin
 Result := Grid.OptionsView.ValueMinWidth;
end;

function TIndBaseVerticalGridView.GetValueWidth: integer;
begin
 Result := Grid.OptionsView.ValueWidth;
end;

procedure TIndBaseVerticalGridView.SetCategories(
  const Value: TIndVerticalGridCategories);
begin
 if Value <> FCategories then
  FCategories.Assign(Value);
end;

procedure TIndBaseVerticalGridView.SetDataSet(
  const Value: TIndBaseDataSet);
begin
 FTable.DataSet := Value;
end;

procedure TIndBaseVerticalGridView.SetDataSource;

  procedure InnerSetDataSource(ADataSource:TDataSource);
  begin
    Grid.DataController.DataSource := ADataSource;
  end;

var t:TIndBaseTable;
begin
   t := ViewTable;
   if Assigned(t) then
    InnerSetDataSource(t.DataSource)
   else
    InnerSetDataSource(nil);
end;

procedure TIndBaseVerticalGridView.SetEditors(
  const Value: TIndVerticalGridEditors);
begin
 if Value <> FEditors then
  FEditors.Assign(Value);
end;

procedure TIndBaseVerticalGridView.SetIndGrid(
  const Value: TIndCustomVerticalGrid);
begin
 if Value <> FIndGrid then
  FIndGrid := Value;
end;

procedure TIndBaseVerticalGridView.SetLayoutStyle(
  const Value: TcxvgLayoutStyle);
begin
 if Value <> LayoutStyle then
 begin
   Grid.LayoutStyle := Value;
   LayoutStyleChanged;
   DoLChanged;
 end;
end;

procedure TIndBaseVerticalGridView.DoLChanged;
begin
   case Grid.LayoutStyle of
     lsSingleRecordView: begin
       Grid.OptionsView.ScrollBars := ssVertical;
       //Настройка буфера записей
       Grid.DataController.GridMode := True;
       Grid.DataController.GridModeBufferCount := cIndVGOneRowGridModeBufferCount;
       Grid.OptionsBehavior.IncSearch := False; //Нет контекстного поиска в режиме одной записи (а то из-за маленького кеша сильно тормозит)
     end;
     else begin
       Grid.OptionsView.ScrollBars := ssBoth;
       //Настройка буфера записей
       Grid.DataController.GridMode := True;
       Grid.DataController.GridModeBufferCount := cIndVGMultyRowGridModeBufferCount;
       Grid.OptionsBehavior.IncSearch := True; //Есть контекстный поиск
     end;
   end;
end;

{procedure TIndBaseVerticalGridView.SetStatusMessage(const Value: string);
begin
  IndGrid.StatusPanel.StatusMessage := Value;
end;}

procedure TIndBaseVerticalGridView.SetTable(const Value: TIndTableRef);
begin
 FTable.Assign(Value);
end;

procedure TIndBaseVerticalGridView.SetValueMinWidth(const Value: integer);
begin
 Grid.OptionsView.ValueMinWidth := Value;
end;

procedure TIndBaseVerticalGridView.SetValueWidth(const Value: integer);
begin
 Grid.OptionsView.ValueWidth := Value;
end;

procedure TIndBaseVerticalGridView.TableChanged(Sender: TObject);
begin
 SetDataSource;
 UpdateTableProperties;
 if Assigned(FOnTableChanged) then FOnTableChanged(Self);
end;

procedure TIndBaseVerticalGridView.FetchLimited(Sender:TObject);
begin
  DoFetchLimitChanged(Sender);
end;

procedure TIndBaseVerticalGridView.UpdateTableProperties;
begin
  if Assigned(Table) and Assigned(Table.Table) then
  begin
    if (not (csDestroying in Table.Table.ComponentState)) then
    begin
      Table.Table.AddFetchListener(Self);
      Table.BeforeTableChange := DoBeforeTableChange;
      FetchLimited(Table.Table);
    end;
  end;
end;

procedure TIndBaseVerticalGridView.ViewEditing(Sender: TObject;
  ARowProperties: TcxCustomEditorRowProperties; var Allow: Boolean);

  procedure fsGetVisibleEnable(const AViewInfo:TIndColumnViewInfo);
  begin
    //Вызов FastScrip-а для определения видимости колонки и свойства Enable
    if Assigned(Table.Table)
       and Assigned(Table.Table.DataProvider)
    then begin
      Table.Table.DataProvider.fsDrawGridCell(AViewInfo);
    end;
  end;

var VInf:TIndVerticalGridColumnViewInfo;
    m:TIndField;
    f:TField;
begin
 Allow := False;
 if Assigned(Table.Table) and (ARowProperties is TcxDBEditorRowProperties) then
 begin
  f := TcxDBEditorRowProperties(ARowProperties).DataBinding.Field;
  if not Assigned(F) then exit;
  m := TIndField(F.Tag);
   if not Assigned(TcxDBEditorRow(ARowProperties.Row).Properties.OnGetDisplayText) then
   begin
   VInf := TIndVerticalGridColumnViewInfo.Create;
   try
     VInf.RecordIndex := TcxDBVerticalGrid(ARowProperties.Row.VerticalGrid).FocusedRecordIndex;
     VInf.RowProperties := TcxDBEditorRowProperties(ARowProperties);
     //Здесь запуск процедуры Fs
     fsGetVisibleEnable(VInf);
     if not VInf.Visible then
     begin
       TcxDBEditorRowProperties(ARowProperties).OnGetDisplayText := DummiNotVisibleGetDisplayText;
  //     MakeEmpty;
     end
     else if not VInf.Enabled then
     begin
       TcxDBEditorRowProperties(ARowProperties).OnGetDisplayText := DummiNotEnabledGetDisplayText;
//       MakeDisable;
     end;
     if VInf.Enabled and VInf.Visible then
     begin
       TcxDBEditorRowProperties(ARowProperties).OnGetDisplayText := nil;
     end;
    finally
     VInf.Free;
    end;
   end;
   Allow := ( not Assigned(TcxDBEditorRow(ARowProperties.Row).Properties.OnGetDisplayText)) and AllowShowEditor(Table,F,M);
   if Allow then
     DoAfterEditing(TcxDBEditorRow(ARowProperties.Row));
 end;
end;

function TIndBaseVerticalGridView.ViewTable: TIndBaseTable;
begin
 Result := Table.Table;
end;

function TIndBaseVerticalGridView.FindCategory(
  ACategory: TcxCategoryRow): TIndVerticalGridCategory;
var CategoryIndex:integer;
begin
  Result := nil;
  for CategoryIndex := 0 to Categories.Count - 1 do
  begin
    if Categories[CategoryIndex].FGridCategory = ACategory then
    begin
      Result := Categories[CategoryIndex];
      Break;
    end;  
  end;
end;

function TIndBaseVerticalGridView.FindEditor(
  AEditor: TcxDBEditorRow): TIndVerticalGridEditor;
var EditorIndex:integer;
begin
  Result := nil;
  for EditorIndex := 0 to Editors.Count - 1 do
  begin
    if Editors[EditorIndex].FGridEditor = AEditor then
    begin
       Result := Editors[EditorIndex];
       Break;
    end;
  end;
end;

procedure TIndBaseVerticalGridView.FetchNoLimited(Sender: TObject);
begin
  DoFetchLimitChanged(Sender);
end;

procedure TIndBaseVerticalGridView.DoAfterEditing(AItem: TcxDBeditorRow);
begin
  TindCxDBVerticalGrid(IndGrid.FGrid).DoAfterEditingGrid(Aitem);
end;

procedure TIndBaseVerticalGridView.DoOnClickViewButton;
begin
  Editors.FindIndEditor(TcxDBEditorRow(IndGrid.View.Grid.FocusedRow)).DoButtonViewClick(IndGrid);
end;

procedure TIndBaseVerticalGridView.LayoutStyleChanged;
begin

end;

{ TIndVerticalGridManager }

function TIndVerticalGridManager.GetGroupName: string;
begin
 if Owner is TIndCustomVerticalGrid then
  Result := Owner.Name
 else
  Result := Self.Name;
end;

function TIndVerticalGridManager.GetTableRef: TIndTableRef;
begin
  if Owner is TIndCustomVerticalGrid then
  begin
    Result := TIndCustomVerticalGrid(Owner).Table;
  end
  else Result := nil;
end;

{ TIndVerticalGridView }

procedure TIndVerticalGridView.LayoutStyleChanged;
begin
  inherited;
  IndGrid.ChangeStatusPanelText;
end;

function TIndVerticalGridView.PropertyName: string;
begin
 Result := 'View';
end;

{ TIndVerticalGridCategories }

function TIndVerticalGridCategories.Add: TIndVerticalGridCategory;
begin
 Result := TIndVerticalGridCategory(inherited Add);
end;

constructor TIndVerticalGridCategories.Create(AOwner:TIndBaseVerticalGridView);
begin
  inherited Create(AOwner,AOwner.Table,TIndVerticalGridCategory);
end;

destructor TIndVerticalGridCategories.Destroy;
begin
  FreeCategories;
  inherited;
end;

function TIndVerticalGridCategories.FindIndCaregoryByName(
  FName: string): TIndVerticalGridCategory;
var I:integer;
begin
   Result := nil;
   FName := uppercase(trim(FName));
   for I := 0 to Count - 1 do
   begin
      if uppercase(Items[I].Name) = FName then
      begin
        Result := Items[I];
        break;
      end;
   end;
end;

function TIndVerticalGridCategories.FindIndCategory(
  ACategory: TcxCategoryRow): TIndVerticalGridCategory;
var K:integer;
begin
    Result := nil;
    for K := 0 to Count - 1 do
    begin
      if Items[K].FGridCategory = ACategory then
      begin
         Result := Items[K];
         Break;
      end;
    end;
end;

function TIndVerticalGridCategories.FindRowByName(
  const FName: string): TcxCustomRow;
var pCat:TIndVerticalGridCategory;
begin
  pCat := FindIndCaregoryByName(FName);
  if Assigned(pCat) then Result := pCat.FGridCategory
  else Result := nil;
end;

procedure TIndVerticalGridCategories.FreeCategories;
var i:integer;
begin
  for i := Count - 1 downto 0 do
  begin
   Items[i].FreeCategory;
  end;
end;



function TIndVerticalGridCategories.GetItems(
  AIndex: integer): TIndVerticalGridCategory;
begin
  Result := TIndVerticalGridCategory(inherited GetItem(AIndex));
end;

function TIndVerticalGridCategories.GetView: TIndBaseVerticalGridView;
begin
 Result := TIndBaseVerticalGridView(Owner);
end;


procedure TIndVerticalGridCategories.Loaded;
begin

end;

procedure TIndVerticalGridCategories.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
var I:integer;
    //AColList:TIndList;
begin
  inherited;
  if Action = cnDeleting then
  begin
{   if (not (csDestroying in View.Grid.ComponentState )) then
   begin
     if Count = 1 then
       raise ECheckException.Create(GetMessageString(idMustHaveOneBand,langMustHaveOneBand));
   end;
   if TIndGridBand(Item).IsBottom then
    begin
     AColList := TIndGridBand(Item).Columns;
     try
       for I := AColList.Count - 1 downto 0 do
       begin
          TIndGridColumns(View.Columns).Delete(TIndGridColumn(AColList[I]).Index);
       end;
     finally
       AColList.Free;
     end;
    end;}
  end;
end;

procedure TIndVerticalGridCategories.SetItems(AIndex: integer;
  const Value: TIndVerticalGridCategory);
begin
  inherited SetItem(AIndex, Value);
end;

procedure TIndVerticalGridCategories.Update(Item: TCollectionItem);
begin
  inherited;
//  View. GridView.Changed(vcSize);
end;

{ TIndVerticalGridCategory }

class function TIndVerticalGridCategory.BaseName: string;
begin
  Result := 'Category';
end;

constructor TIndVerticalGridCategory.Create(ACollection: TCollection);
begin
  inherited;
  FEnable := True;
  FVisible := True;

  FDataLink := TFieldDataLink.Create;
  FPosition := nil;
  UseFieldCaption := False;
  FFieldCaptionType := ctFieldCaption;
  CreateCategory;
  FDataLink.OnDataChange := DataChange;

  FVerticalGridCategorySaver := TIndVerticalGridCategorySaver.Create(View.Grid);
  FVerticalGridCategorySaver.SavedPersistent := Self;

  FUpdaterCategoryRowIndex := TIndSimpleUpdaterRowIndex.Create;
  FUpdaterCategoryRowIndex.Row := Self;
end;

procedure TIndVerticalGridCategory.CreateCategory;
begin
  FGridCategory := TcxCategoryRow.Create(View.Grid);
  FGridCategory.VerticalGrid := View.Grid;
  FGridCategory.Parent := nil;
  FGridCategory.Tag := Integer(Self);
  FPosition := TIndVerticalGridRowPosition.Create(FGridCategory);
end;

procedure TIndVerticalGridCategory.DataChange(Sender: TObject);
begin
 if (FieldCaptionType = ctFieldValue) and UseFieldCaption then
  UpdateObjectCaption;
end;

class function TIndVerticalGridCategory.DefaultUseFieldCaption: boolean;
begin
 Result := False;
end;

destructor TIndVerticalGridCategory.Destroy;
begin
  FreeCategory;
  FreeAndNil(FDataLink);
  FreeAndNil(FUpdaterCategoryRowIndex);
  inherited;
end;


procedure TIndVerticalGridCategory.FieldChanged(Sender: TObject);
begin
  inherited;
  if Assigned(Field) and Assigned(Field.Table) then
  begin
   FDataLink.DataSource := Field.Table.DataSource;
   if Assigned(Field.Field) and Assigned(Field.Field.FieldForDisplay) then
     FDataLink.FieldName := Field.Field.FieldForDisplay.Name
   else
     FDataLink.FieldName := Field.Ident;
  end
  else begin
    FDataLink.DataSource := nil;
    FDataLink.FieldName := '';
  end;
end;

procedure TIndVerticalGridCategory.FreeCategory;
var i:integer;
begin
 if Assigned(FGridCategory) then
 begin
  if not (csDestroying in View.IndGrid.ComponentState) then
  begin
   for i := FGridCategory.Count - 1 downto 0 do
   begin
    FGridCategory.Rows[i].Parent := nil;
   end;
   View.IndGrid.FGrid.Remove(FGridCategory);
  end;
  FGridCategory := nil;
 end;
 if Assigned(FPosition) then
 begin
   FreeAndNil(FPosition);
 end;
end;


function TIndVerticalGridCategory.GetExpanded: Boolean;
begin
  Result := FGridCategory.Expanded; 
end;

function TIndVerticalGridCategory.GetGridView: TIndBaseVerticalGridView;
begin
 Result := TIndVerticalGridCategories(Collection).View;
end;


function TIndVerticalGridCategory.GetParentIndRow: TIndFieldItem;
var pRow:TcxCustomRow;
begin
 pRow := ParentRow;
 if Assigned(pRow) then
 begin
  Result := TIndFieldItem(pRow.Tag);
 end
 else Result := nil;
end;

function TIndVerticalGridCategory.GetParentRow: TcxCustomRow;
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
 begin
  Result := pRow.Parent;
 end
 else Result := nil;
end;

function TIndVerticalGridCategory.GetRow: TcxCustomRow;
begin
 Result := FGridCategory;
end;

function TIndVerticalGridCategory.GetVisible: Boolean;
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
  Result := pRow.Visible
 else
  Result := False;
end;

function TIndVerticalGridCategory.IndCanFocus: boolean;
begin
 Result := Assigned(FGridCategory) and FGridCategory.Visible;
end;

function TIndVerticalGridCategory.IndFocused: boolean;
begin
 Result := Assigned(FGridCategory) and FGridCategory.Focused;
end;

function TIndVerticalGridCategory.IndGetEnable: boolean;
begin
 Result := FEnable;
end;

function TIndVerticalGridCategory.IndGetVisible: boolean;
begin
  Result := FVisible;
end;

procedure TIndVerticalGridCategory.IndSetEnable(const AValue: boolean);
begin
 FEnable := AValue;
 inherited;
end;

procedure TIndVerticalGridCategory.IndSetFocus;
begin
  if Assigned(FGridCategory) then
  begin
   FGridCategory.MakeVisible;
   FGridCategory.Focused := True;
  end;
end;

procedure TIndVerticalGridCategory.IndSetVisible(const AValue: boolean);
begin
 if Assigned(Field.Table) and ((View.LayoutStyle = lsSingleRecordView) or (Field.Table is TIndOneRecordMetadataTable)) then
 begin
   Visible := AValue;
 end;
 FVisible := AValue;
end;

procedure TIndVerticalGridCategory.SetDefaultCollapse(
  const Value: Boolean);
begin
  if FDefaultCollapse <> Value then
  begin
    FDefaultCollapse := Value;
    if not (csDesigning in View.Grid.ComponentState) then
      FGridCategory.Expanded := not Value;
  end;  
end;

procedure TIndVerticalGridCategory.SetExpanded(const Value: Boolean);
begin
  FGridCategory.Expanded := Value;
end;

procedure TIndVerticalGridCategory.SetFieldCaptionType(
  const Value: TIndDBCaptionType);
begin
 if Value <> FFieldCaptionType then
 begin
  FFieldCaptionType := Value;
 end; 
end;

procedure TIndVerticalGridCategory.SetParentIndRow(
  const Value: TIndFieldItem);
begin
 if Value is TIndVerticalGridCategory then
   ParentRow := TIndVerticalGridCategory(Value).FGridCategory
 else if Value is TIndVerticalGridEditor then
   ParentRow := TIndVerticalGridEditor(Value).FGridEditor;
end;

procedure TIndVerticalGridCategory.SetParentRow(const Value: TcxCustomRow);
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
 begin
  if pRow.Parent <> Value then
  begin
   pRow.VerticalGrid.BeginUpdate;
   try
    pRow.Parent := Value;
   finally
     pRow.VerticalGrid.EndUpdate;
   end;
  end;
 end;
end;

procedure TIndVerticalGridCategory.SetPosition(
  const Value: TIndVerticalGridRowPosition);
begin
 if Assigned(FPosition) then
  FPosition.Assign(Value);
end;

procedure TIndVerticalGridCategory.SetRealIndex(const Value: integer);
begin
  Position.RowIndex := Value;
end;

function TIndVerticalGridCategory.GetStoredIndex: integer;
begin
  Result := Position.StoredRowIndex;
end;

procedure TIndVerticalGridCategory.SetVisible(const Value: Boolean);
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
 begin
  if Value <> pRow.Visible then
  begin
   pRow.VerticalGrid.BeginUpdate;
   try
     pRow.Visible := Value;
   finally
     pRow.VerticalGrid.EndUpdate;
   end;
  end;
 end;
end;

procedure TIndVerticalGridCategory.UpdateIndexes;
begin
  FUpdaterCategoryRowIndex.SortAndUpdate;
end;

procedure TIndVerticalGridCategory.UpdateObjectCaption;
begin
  inherited;
  if Assigned(FGridCategory) then
  begin
   if UseFieldCaption then
   begin
    if FieldCaptionType = ctFieldCaption then
    begin
     FGridCategory.Properties.Caption := GetFieldCaption;
    end
    else if Assigned(Field) and Assigned(Field.Field) then
    begin
     FGridCategory.Properties.Caption := VarToStrDef(Field.Field.Value,'');
    end;
   end
   else
    FGridCategory.Properties.Caption := Caption;
  end;
end;

function TIndVerticalGridCategory.GetChildCount: integer;
begin
  Result := FGridCategory.Count;
end;

function TIndVerticalGridCategory.GetChildren(
  Index: integer): TIndFieldItem;
begin
  Result := TIndFieldItem(FGridCategory.Rows[Index].Tag); 
end;

function TIndVerticalGridCategory.GetLevel: integer;
begin
  Result := FGridCategory.Level; 
end;

{ TIndVerticalGridEditor }

class function TIndVerticalGridEditor.BaseName: string;
begin
 Result := 'Editor';
end;


function TIndVerticalGridEditor.CanShowEditors: boolean;
begin
  Result := View.IndGrid.CanShowEditors;
end;

constructor TIndVerticalGridEditor.Create(ACollection: TCollection);
begin
  inherited;
  CreateEditor;
  //создаем хранитель
  FEditorSaver := TIndVerticalGridEditorSaver.Create(Self.View.IndGrid);
  FEditorSaver.SavedPersistent := Self;

  FUpdaterEditorRowIndex := TIndSimpleUpdaterRowIndex.Create;
  FUpdaterEditorRowIndex.Row := Self;
end;

procedure TIndVerticalGridEditor.CreateEditor;
begin
  FGridEditor := TcxDBEditorRow.Create(View.Grid);
  FGridEditor.VerticalGrid := View.Grid;
  FGridEditor.Parent := nil;
  FGridEditor.Tag := Integer(Self);
  FPosition := TIndVerticalGridRowPosition.Create(FGridEditor);
end;


class function TIndVerticalGridEditor.DefaultUseFieldCaption: boolean;
begin
 Result := True;
end;

destructor TIndVerticalGridEditor.Destroy;
begin
  FreeEditor;
  FreeAndNil(FUpdaterEditorRowIndex);
  inherited;
end;



function TIndVerticalGridEditor.FieldEditor: TComponent;
begin
 Result := FGridEditor;
end;


procedure TIndVerticalGridEditor.FreeEditor;
var i:integer;
begin
 if Assigned(FPosition) then
 begin
  FPosition.Free;
  FPosition := nil;
 end;
 if Assigned(FGridEditor) then
 begin
  if not (csDestroying in View.IndGrid.ComponentState) then
  begin
   for i := FGridEditor.Count - 1 downto 0 do
   begin
    FGridEditor.Rows[i].Parent := nil;
   end;
//   View.IndGrid.FGrid.Remove(FGridEditor);
   FGridEditor.Free;
  end;
  FGridEditor := nil;
 end;
end;

procedure TIndVerticalGridEditor.SetFieldEditorPropertiesClass(AClass:TcxCustomEditPropertiesClass);
begin
 FGridEditor.Properties.EditPropertiesClass := AClass;
end;

function TIndVerticalGridEditor.GetFieldEditorProperties: TcxCustomEditProperties;
begin
 Result := FGridEditor.Properties.EditProperties;
end;


function TIndVerticalGridEditor.GetGridView: TIndBaseVerticalGridView;
begin
 Result := TIndVerticalGridEditors(Collection).View;
end;



procedure TIndVerticalGridEditor.SetDataBindingProperty(
  const AFieldName: string);
begin
  inherited;
  if Assigned(FGridEditor) then
   FGridEditor.Properties.DataBinding.FieldName := AFieldName;
end;






procedure TIndVerticalGridEditor.SetIsEditor;
begin
  inherited;
//  FGridEditor.Properties.Options.ShowEditButtons := eisbDefault;
  FGridEditor.Properties.Options.Editing := True;
end;

procedure TIndVerticalGridEditor.SetNotEditor;
begin
  inherited;
//  FGridEditor.Properties.Options.ShowEditButtons := eisbNever;
  FGridEditor.Properties.Options.Editing := False;
end;





procedure TIndVerticalGridEditor.UpdateObjectCaption;
begin
  inherited;
  if Assigned(FGridEditor) then
  begin
    if UseFieldCaption then
     FGridEditor.Properties.Caption := GetFieldCaption
    else
     FGridEditor.Properties.Caption := Caption;
  end;
end;

function TIndVerticalGridEditor.GetRow: TcxCustomRow;
begin
 Result := FGridEditor;
end;

function TIndVerticalGridEditor.GetParentRow: TcxCustomRow;
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
 begin
  Result := pRow.Parent;
 end
 else Result := nil;
end;

function TIndVerticalGridEditor.GetVisible: Boolean;
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
  Result := pRow.Visible
 else
  Result := False;
end;

procedure TIndVerticalGridEditor.SetParentRow(const Value: TcxCustomRow);
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
 begin
  if pRow.Parent <> Value then
  begin
   pRow.VerticalGrid.BeginUpdate;
   try
    pRow.Parent := Value;
   finally
     pRow.VerticalGrid.EndUpdate;
   end;
  end;
 end;
end;

procedure TIndVerticalGridEditor.SetVisible(const Value: Boolean);
var pRow:TcxCustomRow;
begin
 pRow := GetRow;
 if Assigned(pRow) then
 begin
  if Value <> pRow.Visible then
  begin
   pRow.VerticalGrid.BeginUpdate;
   try
     pRow.Visible := Value;
   finally
     pRow.VerticalGrid.EndUpdate;
   end;
  end;
 end;
end;
procedure TIndVerticalGridEditor.SetPosition(
  const Value: TIndVerticalGridRowPosition);
begin
 if Assigned(FPosition) then
  FPosition.Assign(Value);
end;

function TIndVerticalGridEditor.IndGetVisible: boolean;
begin
 Result := Visible;
end;

procedure TIndVerticalGridEditor.IndSetVisible(const AValue: boolean);
begin
 if Assigned(Field.Table) and ((View.LayoutStyle = lsSingleRecordView) or (Field.Table is TIndOneRecordMetadataTable)) then
   Visible := AValue;
end;

function TIndVerticalGridEditor.IndCanFocus: boolean;
begin
 Result := Assigned(FGridEditor) and FGridEditor.Visible;
end;

function TIndVerticalGridEditor.IndFocused: boolean;
begin
  Result := Assigned(FGridEditor) and FGridEditor.Focused;
end;

function TIndVerticalGridEditor.IndGetEnable: boolean;
begin
 Result := Assigned(FGridEditor);
end;

procedure TIndVerticalGridEditor.IndSetEnable(const AValue: boolean);
begin
{  if Assigned(Field.Table) and ((View.LayoutStyle = lsSingleRecordView) or (Field.Table is TIndOneRecordMetadataTable)) then
   Enabled := AValue;}
end;

procedure TIndVerticalGridEditor.IndSetFocus;
begin
  if Assigned(FGridEditor) then
  begin
   FGridEditor.MakeVisible;
   FGridEditor.Focused := True;
  end;
end;

function TIndVerticalGridEditor.GetEditValue: Variant;
begin
  Result := FGridEditor.Properties.Value;
end;

procedure TIndVerticalGridEditor.SetEditValue(const Value: Variant);
begin
  inherited;
  FGridEditor.Properties.Value := Value;
end;

function TIndVerticalGridEditor.GetExpanded: Boolean;
begin
  Result := FGridEditor.Expanded;
end;

procedure TIndVerticalGridEditor.SetExpanded(const Value: Boolean);
begin
  FGridEditor.Expanded := Value;
end;

procedure TIndVerticalGridEditor.SetDefaultCollapse(const Value: Boolean);
begin
  if FDefaultCollapse <> Value then
  begin
    FDefaultCollapse := Value;
    if not (csDesigning in View.Grid.ComponentState) then
      FGridEditor.Expanded := not Value;
  end;  
end;

procedure TIndVerticalGridEditor.UpdateIndexes;
begin
  FUpdaterEditorRowIndex.SortAndUpdate;
end;

function TIndVerticalGridEditor.GetStoredIndex: integer;
begin
  Result := Position.StoredRowIndex;
end;

procedure TIndVerticalGridEditor.SetRealIndex(const Value: integer);
begin
  Position.RowIndex := Value;
end;

function TIndVerticalGridEditor.GetChildCount: integer;
begin
  Result := FGridEditor.Count;
end;

function TIndVerticalGridEditor.GetChildren(Index: integer): TIndFieldItem;
begin
  Result := TIndFieldItem(FGridEditor.Rows[Index].Tag); 
end;

function TIndVerticalGridEditor.GetLevel: integer;
begin
  Result := FGridEditor.Level;
end;

{ TIndVerticalGridEditors }

function TIndVerticalGridEditors.Add: TIndVerticalGridEditor;
begin
 Result := TIndVerticalGridEditor(inherited Add);
end;

constructor TIndVerticalGridEditors.Create(
  AOwner: TIndBaseVerticalGridView);
begin
  inherited Create(AOwner,AOwner.Table,TIndVerticalGridEditor);
end;

destructor TIndVerticalGridEditors.Destroy;
begin
  FreeEditors;
  inherited;
end;

function TIndVerticalGridEditors.FindIndEditor(
  AEditor: TcxDBEditorRow): TIndVerticalGridEditor;
var K:integer;
begin
    Result := nil;
    for K := 0 to Count - 1 do
    begin
      if Items[K].FGridEditor = AEditor then
      begin
         Result := Items[K];
         Break;
      end;
    end;
end;

function TIndVerticalGridEditors.FindIndEditorByName(
  FName: string): TIndVerticalGridEditor;
var I:integer;
begin
   Result := nil;
   FName := uppercase(trim(FName));
   for I := 0 to Count - 1 do
   begin
      if uppercase(Items[I].Name) = FName then
      begin
         Result := Items[I];
         break;
      end;
   end;
end;

function TIndVerticalGridEditors.FindRowByName(
  const FName: string): TcxCustomRow;
var pEd:TIndVerticalGridEditor;
begin
 pEd := FindIndEditorByName(FName);
 if Assigned(pEd) then
  Result := pEd.FGridEditor
 else
  Result := nil;
end;

procedure TIndVerticalGridEditors.FreeEditors;
var i:integer;
begin
  for i := Count - 1 downto 0 do
  begin
   Items[i].FreeEditor;
  end;
end;

function TIndVerticalGridEditors.GetItems(
  AIndex: integer): TIndVerticalGridEditor;
begin
  Result := TIndVerticalGridEditor(inherited GetItem(AIndex));
end;

function TIndVerticalGridEditors.GetView: TIndBaseVerticalGridView;
begin
 Result := TIndBaseVerticalGridView(Owner);
end;

procedure TIndVerticalGridEditors.Loaded;
begin

end;

procedure TIndVerticalGridEditors.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;

end;

procedure TIndVerticalGridEditors.SetItems(AIndex: integer;
  const Value: TIndVerticalGridEditor);
begin
  inherited SetItem(AIndex, Value);
end;

procedure TIndVerticalGridEditors.Update(Item: TCollectionItem);
begin
  inherited;

end;


{ TIndVerticalGridRowPosition }

procedure TIndVerticalGridRowPosition.Assign(Source: TPersistent);
begin
  if Source is TIndVerticalGridRowPosition then
  begin
    RowIndex := TIndVerticalGridRowPosition(Source).RowIndex;
    ParentRow := TIndVerticalGridRowPosition(Source).ParentRow;
  end
  else
   inherited;
end;

class function TIndVerticalGridRowPosition.CategoriesBaseName: string;
begin
  Result := 'Categories.';
end;

constructor TIndVerticalGridRowPosition.Create(ARow:TcxCustomRow);
begin
 inherited Create;
 FNotif := TIndNotif.Create(nil);
 FNotif.OnNotification := DoNotification;
 FParentRowIndex := -1;
 FRow := ARow;
 if Assigned(FRow) then FNotif.AddComponent(FNotif);
end;

destructor TIndVerticalGridRowPosition.Destroy;
begin
  FreeAndNil(FNotif);
  inherited;
end;

class function TIndVerticalGridRowPosition.EditorsBaseName: string;
begin
  Result := 'Editors.';
end;

function TIndVerticalGridRowPosition.GetFullName: string;
begin
 if Assigned(FRow) then
 begin
  if FRow is TcxCategoryRow then
    Result := CategoriesBaseName + TIndVerticalGridCategory(FRow.Tag).Name
  else if FRow is TcxDBEditorRow then
    Result := EditorsBaseName + TIndVerticalGridEditor(FRow.Tag).Name
 end
 else Result := EditorsBaseName;
end;

function TIndVerticalGridRowPosition.GetParentRow: string;
begin
 if Assigned(FRow) and Assigned(FRow.Parent) then
 begin
  if FRow.Parent is TcxCategoryRow then
  begin
    Result := CategoriesBaseName + TIndVerticalGridCategory(FRow.Parent.Tag).Name;
  end
  else begin
    Result := EditorsBaseName + TIndVerticalGridEditor(FRow.Parent.Tag).Name;
  end;
 end
 else
   Result := '<none>';
end;

function TIndVerticalGridRowPosition.GetParentRowIndex: integer;
begin
 if Assigned(FRow) and Assigned(FRow.Parent) then
   Result := FRow.Parent.AbsoluteIndex
 else
   Result := -1;
end;

function TIndVerticalGridRowPosition.GetRowIndex: integer;
begin
  if Assigned(FRow) then
    Result := FRow.Index
  else
    Result := FRowIndex;
end;

procedure TIndVerticalGridRowPosition.DoNotification(ANotificator:TComponent; AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FRow) then
   FRow := nil;
end;

procedure TIndVerticalGridRowPosition.SetParentRow(const Value: string);
var gr, s:string;
    p:integer;
    pRow:TcxCustomRow;
begin
 if Assigned(FRow) then
 begin
   if not (csLoading in FRow.VerticalGrid.Owner.ComponentState) then
   begin
     if (Value = '') or (Value = '<none>') then
     begin
      FRow.Parent := nil;
     end
     else begin
      pRow := FRow.Parent;
      p := pos('.',Value);
      if p > 0 then
      begin
       gr := uppercase(trim(Copy(Value,1,p)));
       s := Copy(Value,p+1,length(Value));
       if not ((Gr = 'CATEGORIES.') or (Gr = 'EDITORS.')) then
       begin
        gr := '';
        s := '';
       end;
      end
      else begin
       gr := '';
       s := Value;
      end;
      if Gr = 'CATEGORIES.' then
      begin
       pRow := TIndCustomVerticalGrid(FRow.VerticalGrid.Owner).View.Categories.FindRowByName(s);
      end
      else if Gr = 'EDITORS.' then
      begin
       pRow := TIndCustomVerticalGrid(FRow.VerticalGrid.Owner).View.Editors.FindRowByName(s);
      end
      else if (s <> '') then
      begin
        pRow := TIndCustomVerticalGrid(FRow.VerticalGrid.Owner).View.Categories.FindRowByName(s);
        if not Assigned(pRow) then
         pRow := TIndCustomVerticalGrid(FRow.VerticalGrid.Owner).View.Editors.FindRowByName(s);
      end
      else begin
        pRow := nil;
      end;

      if Assigned(pRow) then
      begin
        if not FRow.IsChild(pRow) and not pRow.IsChild(FRow) then FRow.Parent := pRow;

      end;
     end;
    end
    else begin
      FParentRow := Value;
    end;
  end;
end;

procedure TIndVerticalGridRowPosition.SetParentRowIndex(
  const Value: integer);
var pRow:TcxCustomRow;
begin
 if Assigned(FRow) and (not (csLoading in FRow.VerticalGrid.Owner.ComponentState)) then
 begin
   if (Value > -1) then
   begin
    if Value < FRow.VerticalGrid.Rows.Count then pRow := FRow.VerticalGrid.Rows[Value]
    else pRow := nil;
   end
   else
    pRow := nil;

   if (FRow.Parent <> pRow) and (pRow <> FRow)   then
   begin
    if Assigned(pRow) then
    begin
     if not pRow.IsChild(FRow) then FRow.Parent := pRow;
    end
    else
     FRow.Parent := pRow;
   end;
 end
 else FParentRowIndex := Value;
end;

procedure TIndVerticalGridRowPosition.SetRowIndex(const Value: integer);
begin
 if Assigned(FRow) and (not (csLoading in FRow.VerticalGrid.Owner.ComponentState)) then
 begin
   if Value <> FRow.Index then
   begin
    if (Value > -1)  then
    begin
      FRow.Index := Value;
      //SetIndRowIndex(FRow.Index);
    end;  
   end;
 end
 else FRowIndex := Value;
end;


{ TIndVerticalGridColumnViewInfo }

constructor TIndVerticalGridColumnViewInfo.Create;
begin
  inherited;
  FRecordIndex := -1;
  FRowProperties := nil;
end;

function TIndVerticalGridColumnViewInfo.GetFieldValue: variant;
begin
 if Assigned(RowProperties) and (RecordIndex >= 0) then
   Result := FRowProperties.Values[RecordIndex]
 else Result := null;
end;

function TIndVerticalGridColumnViewInfo.GetValueInfo(
  const AFieldName: string; var AExists: boolean): variant;
var s:string;
    i:integer;
begin
 AExists := False;
 Result := null;
 if Assigned(FRowProperties) and (FRowProperties.Row is TcxDBEditorRow) and (RecordIndex >= 0) then
 begin
   s := IndUpper(AFieldName);
   if s = FieldNameUp then
   begin
     Result := FieldValue;
     AExists := True;
   end
   else begin
     for i := 0 to  FRowProperties.Row.VerticalGrid.Rows.Count - 1 do
     begin
       if (FRowProperties.Row.VerticalGrid.Rows.Items[i] is TcxDBEditorRow)
       then begin
        if IndUpper(TcxDBEditorRow(FRowProperties.Row.VerticalGrid.Rows.Items[i]).Properties.DataBinding.FieldName) = s then
        begin
          Result := TcxDBEditorRow(FRowProperties.Row.VerticalGrid.Rows.Items[i]).Properties.Values[RecordIndex];
          AExists := True;
          break;
        end;
       end;
     end;
   end;
 end
 else begin
  AExists := False;
  Result := null;
 end;
end;

procedure TIndVerticalGridColumnViewInfo.SetRecordIndex(
  const Value: integer);
begin
  FRecordIndex := Value;
end;

procedure TIndVerticalGridColumnViewInfo.SetRowProperties(
  const Value: TcxDBEditorRowProperties);
var f:TIndField;
begin
  FRowProperties := Value;
  if Assigned(FRowProperties) then
  begin
   SetFieldName(FRowProperties.DataBinding.FieldName);
   if Assigned(FRowProperties.DataBinding.Field) then
   begin
     f := TIndField(FRowProperties.DataBinding.Field.Tag);
     SetTable(f.Table);
     SetField(f);
   end
   else begin
    SetTable(nil);
    SetField(nil);
   end;
  end
  else begin
   SetFieldName('');
   SetTable(nil);
   SetField(nil);
  end;
end;


{ TIndVerticalGridSaver }

procedure TIndVerticalGridSaver.GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);
begin
 AValue.Clear;
 if Assigned(TIndCustomVerticalGrid(SavedComponent).FGrid) then
 begin
  AValue.Properties['RowHeaderWidth'].Value := IntToStr(TIndCustomVerticalGrid(SavedComponent).FGrid.OptionsView.RowHeaderWidth);
  AValue.Properties['RowHeaderWidth'].WriteScreenSize := True;
  AValue.Properties['RowHeight'].Value := IntToStr(TIndCustomVerticalGrid(SavedComponent).FGrid.OptionsView.RowHeight);
  AValue.Properties['RowHeight'].WriteScreenSize := True;  
 end;
end;

procedure TIndVerticalGridSaver.SetStorageProperties(
  const AValue: {TStringList}TIndStorePropertiesList);
begin
  inherited;
  if Assigned(TIndCustomVerticalGrid(SavedComponent).FGrid) then
  begin
   TIndCustomVerticalGrid(SavedComponent).FGrid.OptionsView.RowHeaderWidth := StrToIntDef(AValue.Properties['RowHeaderWidth'].Value,TIndCustomVerticalGrid(SavedComponent).FGrid.OptionsView.RowHeaderWidth);
   TIndCustomVerticalGrid(SavedComponent).FGrid.OptionsView.RowHeight := StrTointDef(AValue.Properties['RowHeight'].Value,TIndCustomVerticalGrid(SavedComponent).FGrid.OptionsView.RowHeight);
  end;
end;

function TIndVerticalGridSaver.GetVerticalGrid: TIndCustomVerticalGrid;
begin
  Result := TIndCustomVerticalGrid(SavedComponent);
end;

procedure TIndVerticalGridSaver.LoadComponentsFromStorage;
var ItemIndex:integer;
begin
  inherited;
  //загрузили сначала собственные свойства (некомпонентные)
  if not Assigned(Storage) then Exit;
  Storage.LoadPropertiesFromStorage(Self);
    for ItemIndex := 0 to VerticalGrid.View.Categories.Count - 1 do
       LoadComponent(VerticalGrid.View.Categories[ItemIndex].CategorySaver);

    for ItemIndex := 0 to VerticalGrid.View.Editors.Count - 1 do
       LoadComponent(VerticalGrid.View.Editors[ItemIndex].FEditorSaver);
end;

procedure TIndVerticalGridSaver.SaveComponentsToStorage;
var ItemIndex:integer;
begin
  inherited;
  if not Assigned(Storage) then Exit;
  Storage.SavePropertiesToStorage(Self);
    if Assigned(VerticalGrid.View.Categories) then
    begin
     for ItemIndex := 0 to VerticalGrid.View.Categories.Count - 1 do
     begin
       if Assigned(VerticalGrid.View.Categories[ItemIndex].CategorySaver) then
         SaveComponent(VerticalGrid.View.Categories[ItemIndex].CategorySaver);
     end;
    end;
    if Assigned(VerticalGrid.View.Editors) then
    begin
     for ItemIndex := 0 to VerticalGrid.View.Editors.Count - 1 do
     begin
       if Assigned(VerticalGrid.View.Editors[ItemIndex].FEditorSaver) then
         SaveComponent(VerticalGrid.View.Editors[ItemIndex].FEditorSaver);
     end;
    end;
end;


{ TIndVerticalGridEditorSaver }

{function TIndVerticalGridEditorSaver.GetPathToStoredObject: string;
begin
  Result := TIndVerticalGridEditor(SavedPersistent).View.IndGrid.Name;
  Result := GetPathToComponent(TIndVerticalGridEditor(SavedPersistent).View.IndGrid,ComponentStorager)+'\' + Result;

end;    }

function TIndVerticalGridEditorSaver.GetPersistentStorager: TComponent;
begin
  Result := TIndVerticalGridEditor(SavedPersistent).View.IndGrid.Owner; 
end;

function TIndVerticalGridEditorSaver.GetSaveOwner: TComponent;
begin
  Result := TIndVerticalGridEditor(SavedPersistent).View.IndGrid.Owner;
end;

function TIndVerticalGridEditorSaver.GetStoreObjectName: string;
begin
  Result := TIndVerticalGridEditor(SavedPersistent).Name;
end;

procedure TIndVerticalGridEditorSaver.GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);
begin
  AValue.Clear;
//  Result.Values['ParentRow'] := TIndVerticalGridEditor(SavedPersistent).Position.ParentRow;
//  Result.Values['RowIndex'] := IntToStr(TIndVerticalgridEditor(savedPersistent).Position.RowIndex)
  if Assigned(TIndVerticalGridEditor(SavedPersistent).GridEditor) and
     (TIndVerticalGridEditor(SavedPersistent).GridEditor.Count > 0) then
  AValue.Properties['Expanded'].Value := BoolToStr(TIndVerticalGridEditor(SavedPersistent).Expanded);
end;


procedure TIndVerticalGridEditorSaver.SetStorageProperties(
  const Value: {TStringList}TIndStorePropertiesList);
var s:string;
begin
  inherited;
//  TIndVerticalGridEditor(SavedPersistent).Position.ParentRow := Value.Values['ParentRow'];
//  TIndVerticalGridEditor(SavedPersistent).Position.RowIndex := StrTointDef(Value.Values['RowIndex'],TIndVerticalGridEditor(SavedPersistent).Position.RowIndex);
  s := Value.Properties['Expanded'].Value;
  if trim(s) <> '' then
    TIndVerticalGridEditor(SavedPersistent).Expanded := StrToBoolDef(s,TIndVerticalGridEditor(SavedPersistent).Expanded);
end;

{ TIndVerticalGridCategorySaver }

{function TIndVerticalGridCategorySaver.GetPathToStoredObject: string;
begin
  Result := TIndVerticalGridCategory(SavedPersistent).View.IndGrid.Name;
  Result := GetPathToComponent(TIndVerticalGridCategory(SavedPersistent).View.IndGrid,ComponentStorager)+'\' + Result;
end;}

function TIndVerticalGridCategorySaver.GetPersistentStorager: TComponent;
begin
  Result := TIndVerticalGridCategory(SavedPersistent).View.IndGrid.Owner;
end;

function TIndVerticalGridCategorySaver.GetSaveOwner: TComponent;
begin
  Result := TIndVerticalGridCategory(SavedPersistent).View.IndGrid.Owner;
end;


function TIndVerticalGridCategorySaver.GetStoreObjectName: string;
begin
  Result := TIndVerticalGridCategory(SavedPersistent).Name;
end;

procedure TIndVerticalGridCategorySaver.SetStorageProperties(
  const Value: {TStringList}TIndStorePropertiesList);
var s:string;
begin
  inherited;
//  TIndVerticalGridCategory(SavedPersistent).Position.ParentRow := Value.Values['ParentRow'];
//  TIndVerticalGridCategory(SavedPersistent).Position.RowIndex := StrTointDef(Value.Values['RowIndex'],TIndVerticalGridCategory(SavedPersistent).Position.RowIndex );
  s := Value.Properties['Expanded'].Value;
  if trim(s) <> '' then
    TIndVerticalGridCategory(SavedPersistent).Expanded := StrToBoolDef(s,TIndVerticalGridCategory(SavedPersistent).Expanded);
end;

procedure TIndVerticalGridCategorySaver.GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);
begin
  AValue.Clear;
//  Result.Values['ParentRow'] := TIndVerticalGridCategory(SavedPersistent).Position.ParentRow;
//  Result.Values['RowIndex'] := IntToStr(TIndVerticalgridCategory(savedPersistent).Position.RowIndex)
  if Assigned(TIndVerticalGridCategory(SavedPersistent).GridCategory) and
     (TIndVerticalGridCategory(SavedPersistent).GridCategory.Count > 0) then
    AValue.Properties['Expanded'].Value := BoolToStr(TIndVerticalGridCategory(SavedPersistent).Expanded);
end;



{ TIndcxDBVerticalGrid }

constructor TIndcxDBVerticalGrid.Create(AOwner: TComponent);
begin
  inherited;
  FButtonProperties := TIndVerticalGridButtonProperties.Create(Self);
  OnEdited := DoEdited;
  OnItemChanged := DoChangeRecord;
  OnFocusedRecordChanged := DoFocusedRecordChanged;
end;

procedure TIndcxDBVerticalGrid.DoFocusedRecordChanged(
  Sender: TcxVirtualVerticalGrid; APrevFocusedRecord,
  AFocusedRecord: Integer);
var APrevRow:TcxCustomRow;
begin
  APrevRow := nil; 
  if (APrevFocusedRecord > -1) and (APrevFocusedRecord < Rows.Count -1 ) then
    APrevRow := Rows[APrevFocusedRecord];
  DoChangeRecord(Self,APrevRow,APrevFocusedRecord);
end;

procedure TIndcxDBVerticalGrid.DoAfterEditingGrid(AEditor: TcxDbEditorRow);
begin
  if IsLoading then Exit;
  FButtonProperties.BeginBtUpdate(AEditor);
  try
    FButtonProperties.HideBrowseButton(AEditor);
    FButtonProperties.ShowEditButton(AEditor);
  finally
   FButtonProperties.EndBtUpdate(AEditor);
  end;
end;

procedure TIndcxDBVerticalGrid.DoChangeRecord(Sender: TObject;
  AOldRow: TcxCustomRow; AOldCellIndex: Integer);
begin
  if IsLoading then Exit;
  if Assigned(AOldRow) and (AOldRow is TcxDBeditorRow) then
   FButtonProperties.HideAllButtons(AOldRow);
  if FocusedRow is TcxDBeditorRow then
  begin
    FButtonProperties.BeginBtUpdate(FocusedRow);
    try
      FButtonProperties.HideEditButton(FocusedRow);
      FButtonProperties.ShowBrowseButton(FocusedRow);
    finally
      FButtonProperties.EndBtUpdate(FocusedRow);
    end;
  end; 
end;

procedure TIndcxDBVerticalGrid.DoEdited(Sender: TObject;
  ARowProperties: TcxCustomEditorRowProperties);
begin
  if IsLoading then Exit;
  FButtonProperties.BeginBtUpdate(ARowProperties.Row);
  try
    FButtonProperties.HideEditButton(ARowProperties.Row);
    FButtonProperties.ShowBrowseButton(ARowProperties.Row);
  finally
    FButtonProperties.EndBtUpdate(ARowProperties.Row);
  end;
end;


function TIndcxDBVerticalGrid.GetControllerClass: TcxCustomControlControllerClass;
begin
  Result := TIndCxDBVerticalGridController;
end;

function TIndcxDBVerticalGrid.GetIndObject(AObject: Tpersistent): TObject;
begin
  Result := FindVerticalGrid.GetIndObject(AObject); 
end;

function TIndcxDBVerticalGrid.GetNativeObject(
  AObject: Tpersistent): TObject;
begin
  if AObject is TIndVerticalGridEditor then
    Result := TIndVerticalGridEditor(AObject).GridEditor
  else if AObject is TIndVerticalGridCategory then
    Result := TIndVerticalGridCategory(AObject).GridCategory
  else
    Result := AObject;  


end;

function TIndcxDBVerticalGrid.IsLoading: boolean;
begin
  Result := (csLoading in IndVerticalGrid.ComponentState) or
            (csDestroying in IndVerticalGrid.ComponentState);  
end;

function TIndcxDBVerticalGrid.IsNativeObject(
  AObject: TPersistent): boolean;
begin
  Result := not ((AObject is TIndVerticalGridEditor) or (AObject is TIndVerticalGridCategory)); 
end;

procedure TIndcxDBVerticalGrid.RepaintControl(AObject: TPersistent);
begin
  BeginUpdate;
  EndUpdate;   
end;

{ TIndVerticalGridButtonProperties }

{function TIndVerticalGridButtonProperties.GetButtonBrowse(
  AButtonParent: TPersistent): TcxEditButton;
begin
  Result := TIndVerticalGridEditor(TcxDBEditorRow(AButtonParent).Tag).ButtonView;
end;}

function TIndVerticalGridButtonProperties.GetField(
  AButtonParent: TPersistent): TIndFieldRef;
begin
  Result := TIndVerticalGridEditor(TcxDBEditorRow(AButtonParent).Tag).Field;
end;

function TIndVerticalGridButtonProperties.GetIndFieldEditorItem(
  AButtonParent: TPersistent): TPersistent;
begin
  Result := TIndVerticalGridEditor(TcxDbEditorRow(AButtonParent).Tag);
end;

function TIndVerticalGridButtonProperties.IsEditing(AButtonParent:TPersistent): boolean;
begin
  Result := TcxDBEditorRow(AButtonParent).VerticalGrid.IsEditing;
end;

function TIndVerticalGridButtonProperties.Properties(
  AButtonParent: TPersistent): TcxCustomEditProperties;
begin
  Result := TcxDbEditorRow(AButtonParent).Properties.EditProperties;
end;

{procedure TIndVerticalGridButtonProperties.SetButtonBrowse(
  AButtonParent: TPersistent; AButton: TcxEditButton);
begin
  inherited;
  TIndVerticalGridEditor(TcxDBEditorRow(AButtonParent).Tag).ButtonView := AButton;
end;}

{ TIndCxDBVerticalGridController }

procedure TIndCxDBVerticalGridController.DoMouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) and (Shift = [ssRight]) and (csDesigning in VerticalGrid.ComponentState) then
    exit;
  if VerticalGrid.HitTest.HitAtValue then
  begin
    if Assigned(VerticalGrid.HitTest.EditCellViewInfo) and
       Assigned(VerticalGrid.HitTest.EditCellViewInfo.EditViewInfo) and
       (VerticalGrid.HitTest.EditCellViewInfo.EditViewInfo.SelectedButton = 0 ) then
    begin
       TindCxDbVerticalGrid(VerticalGrid).IndVerticalGrid.View.DoOnClickViewButton;
    end else
       inherited;
  end else
    inherited;
  
end;

{ TIndFormulaVGrid }

procedure TIndFormulaVGrid.ClearFormulaView;
begin
 TIndFormulaVGridView(FView).ClearFormulaView; 
end;

constructor TIndFormulaVGrid.Create(AOwner: TComponent);
begin
  inherited;
  FNoFormulaPanel := TIndCustomLabelPanel.Create(Self);
  FNoFormulaPanel.LabelText := GetMessageString(idFormulaVGridNoFormula,langFormulaVGridNoFormula);
  FNoFormulaPanel.Parent := Self;
  FNoFormulaPanel.Align := alClient;
  FNoFormulaPanel.Visible := True;
  FGrid.Visible := False;
end;

procedure TIndFormulaVGrid.FormulaTableRefreshed(Sender: TObject);
begin
  MakeFormulaView;
end;

function TIndFormulaVGrid.GetDataSet: TIndBaseDataSet;
begin
 Result := TIndFormulaVGridView(FView).FieldDataSet;
end;

function TIndFormulaVGrid.GetField: TIndFieldRef;
begin
  Result := TIndFormulaVGridView(FView).Field;
end;

class function TIndFormulaVGrid.GetGridViewClass: TIndVerticalGridViewClass;
begin
  Result := TIndFormulaVGridView;
end;

function TIndFormulaVGrid.GetTable: TIndTableRef;
begin
  Result := TIndFormulaVGridView(FView).FieldTable;
end;


procedure TIndFormulaVGrid.MakeFormulaView;
begin
 TIndFormulaVGridView(FView).MakeFormulaView;
end;

procedure TIndFormulaVGrid.SetDataSet(const Value: TIndBaseDataSet);
begin
  TIndFormulaVGridView(FView).FieldDataSet := Value;
end;

procedure TIndFormulaVGrid.SetField(const Value: TIndFieldRef);
begin
 TIndFormulaVGridView(FView).Field := Value;
end;

procedure TIndFormulaVGrid.SetTable(const Value: TIndTableRef);
begin
  TIndFormulaVGridView(FView).FieldTable := Value;
end;

{ TIndFormulaVGridView }

procedure TIndFormulaVGridView.BeforeFieldChanged(const Sender: TObject;
  const OldField, NewField: TIndField);
begin
  if Assigned(OldField) and Assigned(OldField.Formula) then
  begin
    OldField.Formula.RemoveControl(IndGrid);
  end;
  if Assigned(NewField) and Assigned(NewField.Formula) then
  begin
    NewField.Formula.AddControl(IndGrid);
  end;
end;

procedure TIndFormulaVGridView.ClearFormulaView;
begin
 ClearVGrid;
 Table.SetTable(nil);
end;

procedure TIndFormulaVGridView.ClearFormulaViewFull;
begin
 if Assigned(IndGrid.FGrid) then IndGrid.FGrid.CancelEdit;
 ClearFormulaView;
 if Assigned(IndGrid.FGrid) then IndGrid.FGrid.Visible := False;
 if Assigned(TIndFormulaVGrid(IndGrid).FNoFormulaPanel) then TIndFormulaVGrid(IndGrid).FNoFormulaPanel.Visible := True;
end;

procedure TIndFormulaVGridView.ClearVGrid;
begin
 Grid.BeginUpdate;
 try
  FCategories.Clear;
  FEditors.Clear;
 finally
  Grid.EndUpdate;
 end;
end;

constructor TIndFormulaVGridView.Create(AGrid: TIndCustomVerticalGrid);
begin
  inherited;
  FFieldTable := TIndTableRef.Create(AGrid);
  FFieldTable.OnTableChanged := FieldTableChanged;

  FFormulaInViewId := null;
  FFormulaInViewMetadata := nil;
  FField := FFieldTable.AddFieldRef;
  FField.Control := Self;
  FField.OnFieldChanged := FieldChanged;
  FField.BeforeFieldChange := BeforeFieldChanged;
end;

procedure TIndFormulaVGridView.DblClickAction;
begin
  inherited;
end;

destructor TIndFormulaVGridView.Destroy;
begin
  FreeAndNil(FFieldTable);
  FField := nil;
  inherited;
end;

procedure TIndFormulaVGridView.FieldChanged(Sender: TObject);
begin
  if Assigned(FField.Field) then
  begin
    if Assigned(FField.FieldMetadata) and FField.FieldMetadata.UseFormula then
    begin
      MakeFormulaView;
    end
    else begin
      ClearFormulaViewFull;
      Raise Exception.Create(format('Field "%s" do not use formulas. (%s)',[FField.Field.Name, Table.Ident]));
    end;
  end;
end;

procedure TIndFormulaVGridView.FieldTableChanged(Sender: TObject);
begin
 
end;

function TIndFormulaVGridView.GetField: TIndFieldRef;
begin
 Result := FField;
end;

function TIndFormulaVGridView.GetFieldDataSet: TIndBaseDataSet;
begin
  Result := FFieldTable.DataSet;
end;

function TIndFormulaVGridView.GetFieldTable: TIndTableRef;
begin
 Result := FFieldTable;
end;

procedure TIndFormulaVGridView.MakeFormulaView;
begin
 if (FFormulaInViewId <> FField.Field.FormulaId) or (FFormulaInViewMetadata <> FField.Field.Formula.FormulaMetadata) then
 begin
   Grid.CancelEdit;
   Grid.BeginUpdate;
   try
     ClearFormulaView;
     FFormulaInViewId := null;
     FFormulaInViewMetadata := nil;
     //Ну и здесь накидывание редакторов согласно метаданным текущей формулы,
     //если такая установлена
     FFormulaInViewId := FField.Field.FormulaId;
     FFormulaInViewMetadata := FField.Field.Formula.FormulaMetadata;
     //Загружаем вид формулы по ее метаданным
     //Можно загрузить вертикальный грид
     MakeVGrid;
     Table.SetTable(FField.Field.Formula.EditTable);
   finally
     Grid.EndUpdate;
   end;
 end
 else begin
  if not Assigned(FField.Field.Formula.FormulaMetadata) then
  begin
    ClearFormulaView;
    FFormulaInViewId := null;
    FFormulaInViewMetadata := nil;
  end;
 end;
 if Assigned(FFormulaInViewMetadata) then
 begin
  if Assigned(TIndFormulaVGrid(IndGrid).FNoFormulaPanel) then TIndFormulaVGrid(IndGrid).FNoFormulaPanel.Visible := False;
  if Assigned(IndGrid.FGrid) then IndGrid.FGrid.Visible := True;
 end
 else begin
  if Assigned(IndGrid.FGrid) then IndGrid.FGrid.Visible := False;
  if Assigned(TIndFormulaVGrid(IndGrid).FNoFormulaPanel) then TIndFormulaVGrid(IndGrid).FNoFormulaPanel.Visible := True;
 end;
end;

procedure TIndFormulaVGridView.MakeVGrid;

 procedure MakeOneViewItem(const AItem:TIndFormulaViewItem; AParentRow:TcxCustomRow);
 var  Cat:TIndVerticalGridCategory;
      Ed:TIndVerticalGridEditor;
      i:integer;
      pRow:TcxCustomRow;
 begin
  if AItem.FormulaFieldName = '' then
  begin
   Cat := Categories.Add;
   with Cat do
   begin
     Field.Ident := '';
     UseFieldCaption := False;
     Caption := AItem.DisplayLabel;
     GridCategory.Parent := AParentRow;
   end;
   pRow := Cat.GridCategory;
  end
  else begin
   Ed := Editors.Add;
   with Ed do
   begin
     Field.Ident := AItem.FormulaFieldName;
     UseFieldCaption := AItem.UseFieldCaption;
     Caption := AItem.DisplayLabel;
     GridEditor.Parent := AParentRow;
   end;
   pRow := Ed.GridEditor;
  end;
  //Обработка дочерних полей
  for i := 0 to AItem.ChildrenCount - 1 do
  begin
    MakeOneViewItem(AItem.Children[i],pRow);
  end;
 end;

var p,i:integer;
    pParentRow:TcxCustomRow;
begin
  if Assigned(FField.Field)
     and Assigned(FField.Field.Formula)
     and Assigned(FField.Field.Formula.FormulaMetadata) then
  begin
    pParentRow := nil;
    p := FField.Field.Formula.FormulaMetadata.ViewMetadata.FindByParent(null,0);
    for i := p to FField.Field.Formula.FormulaMetadata.ViewMetadata.Count - 1 do
    begin
      if FField.Field.Formula.FormulaMetadata.ViewMetadata.Items[i].IdParent <> null then
       break
      else begin
        MakeOneViewItem(FField.Field.Formula.FormulaMetadata.ViewMetadata.Items[i], nil);
      end;
    end;
  end;
end;


procedure TIndFormulaVGridView.SetField(const Value: TIndFieldRef);
begin
  FField.Assign(Value);
end;

procedure TIndFormulaVGridView.SetFieldDataSet(
  const Value: TIndBaseDataSet);
begin
 FFieldTable.DataSet := Value;;
end;

procedure TIndFormulaVGridView.SetFieldTable(const Value: TIndTableRef);
begin
 FFieldTable.Assign(Value);
end;

procedure TIndFormulaVGridView.TableChanged(Sender: TObject);
begin
  inherited;

end;

{ TIndSimpleUpdaterRowIndex }

function TIndSimpleUpdaterRowIndex.GetCount: integer;
begin
  Result := FRow.GetChildCount;
end;

function TIndSimpleUpdaterRowIndex.GetSortByParam(
  Index: integer): string;
begin
  Result := IntToStr(FRow.GetChildren(Index).GetStoredIndex);
end;

function TIndSimpleUpdaterRowIndex.GetSortObject(
  Index: integer): TObject;
begin
  Result := FRow.GetChildren(Index);
end;

procedure TIndSimpleUpdaterRowIndex.MakeUpdateAction(
  Index: integer);
begin
  inherited;
  TIndFieldItem(SortList.Objects[Index]).SetRealIndex(TIndFieldItem(SortList.Objects[Index]).GetStoredIndex);
end;

{ TIndSimpleUpdaterAllIndex }

constructor TIndSimpleUpdaterZeroLevelIndex.Create;
begin
  inherited;
  FZeroLevelList := TList.Create;
end;

destructor TIndSimpleUpdaterZeroLevelIndex.Destroy;
begin
  FreeAndNil(FZeroLevelList);
  inherited;
end;

function TIndSimpleUpdaterZeroLevelIndex.GetCount: integer;
begin
  Result := FZeroLevelList.Count;
end;

function TIndSimpleUpdaterZeroLevelIndex.GetSortByParam(Index: integer): string;
begin
  Result := IntToStr(TIndFieldItem(FZeroLevelList[Index]).GetStoredIndex);
end;

function TIndSimpleUpdaterZeroLevelIndex.GetSortObject(Index: integer): TObject;
begin
  Result := TObject(FZeroLevelList[Index]); 
end;

procedure TIndSimpleUpdaterZeroLevelIndex.MakeUpdateAction(Index: integer);
begin
  inherited;
  TIndFieldItem(SortList.Objects[Index]).SetRealIndex(TIndFieldItem(SortList.Objects[Index]).GetStoredIndex);
end;

end.
