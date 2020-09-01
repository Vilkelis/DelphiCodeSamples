unit uIndTree;

interface
uses Forms, Controls,
     cxCustomData,
     Variants,
     Classes,
     Messages,
     DB,
     ImgList,
     SysUtils,
     ExtCtrls,
     Graphics,
     cxGraphics,
     cxDBTL,
     cxTL,
     cxEdit,
     cxTextEdit,
     cxButtonEdit,
     cxMaskEdit,
     cxInplaceContainer,
     cxTlData,
     smDialogs,
     uIndEditProperties,
     uIndDataConstant,
     uIndDataCommonClasses,
     uIndFieldsMetadata,
     uIndFormManager,
     uCommonClasses,
     uIndManagers,
     uIndGrid,
     uDBAStringsE,
     uIndTables,
     RvDesignU,
     uIndChecker,
     uIndButtonProperties;

type
{Дерево}
TIndTree = class;
TIndBaseTreeView = class;

TIndTreeViewType = (gvTree, gvBandedTree);// , gvCard);

//Позиция колонки дерева
TIndTreeColumnPosition = class (TPersistent)
private
 FCol:TcxDBTreeListColumn;
 function GetRowIndex: integer;
 procedure SetRowIndex(const Value: integer);
 function GetBandIndex: integer;
 function GetColIndex: integer;
 procedure SetBandIndex(const Value: integer);
 procedure SetColIndex(const Value: integer);
public
 procedure Assign(Source: TPersistent); override;

 constructor Create(ACol:TcxDBTreeListColumn); virtual;
 property Col:TcxDbTreeListColumn read FCol;
published
 property BandIndex:integer read GetBandIndex write SetBandIndex;
 property RowIndex:integer read GetRowIndex write SetRowIndex;
 property ColIndex:integer read GetColIndex write SetColIndex;
end;

TIndTreeBandPosition = class (TPersistent)
private
 FBand:TcxTreeListBand;
 function GetVisibleIndex: integer;
 procedure SetVisibleIndex(const Value: integer);
public
 procedure Assign(Source: TPersistent); override;

 constructor Create(ABand:TcxTreeListBand); virtual;
published
  property Index:integer read GetVisibleIndex write SetVisibleIndex;
end;

TIndTreeBand = class (TIndFieldItemCaption)
private
 FBand:TcxTreeListBand;
 FPosition:TIndTreeBandPosition;
 function GetGridView: TIndBaseTreeView;

 function GetVisible: Boolean;
 procedure SetVisible(const Value: Boolean);
 procedure SetPosition(const Value: TIndTreeBandPosition);
 function GetFixedKind: TcxTreeListBandFixedKind;
 function GetWidth: integer;
 procedure SetFixedKind(const Value: TcxTreeListBandFixedKind);
 procedure SetWidth(const Value: integer);

protected
 class function DefaultUseFieldCaption:boolean; override;
 procedure UpdateObjectCaption; override;

 class function BaseName:string; override;
 procedure FreeBand;

 property GridBand:TcxTreeListBand read FBand;
 procedure CreateBand;
public
 function GetBand:TcxTreeListBand;
 constructor Create(ACollection:TCollection); override;
 constructor CreateForBand(ACollection:TCollection; ABand:TcxTreeListBand);
 destructor Destroy; override;
 property View:TIndBaseTreeView read GetGridView;
published
 property Position:TIndTreeBandPosition read FPosition write SetPosition;
 property UseFieldCaption default  False;
 property Caption;
 property Visible: Boolean read GetVisible write SetVisible default True;
 property Name;
 property Field;
 property Width:integer read GetWidth write SetWidth;
 property FixedKind:TcxTreeListBandFixedKind read GetFixedKind write SetFixedKind;
end;


TIndTreeBands = class (TIndFieldItemCollection)
private
 function GetItems(AIndex: integer): TIndTreeBand;
 procedure SetItems(AIndex: integer; const Value: TIndTreeBand);
 function GetView: TIndBaseTreeView;
// function FindIndBand(ABand: TcxTreeListBand): TIndTreeBand;
protected
 procedure FreeBands;
 procedure Loaded;
 procedure CheckForFirstBand;
public
 function FindIndBandByName(FName:string): TIndTreeBand;
 constructor Create(AOwner:TIndBaseTreeView); virtual;
 destructor Destroy;override;
 procedure Notify(Item: TCollectionItem; Action: TCollectionNotification);override;
 function Add:TIndTreeBand;
 procedure Update(Item: TCollectionItem);override;
 property Items[AIndex:integer]:TIndTreeBand read GetItems write SetItems; default;
 property View:TIndBaseTreeView read GetView;
published

end;

TIndTreeColumnSaver = class(TIndPersistentSaver)
protected
  function GetStoreObjectName:string;override;
  procedure GetStorageProperties(const AValue: {TStringList}TIndStorePropertiesList);override;
  procedure SetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);override;

  function GetPersistentStorager:TComponent;override;
  //function GetPathToStoredObject:string;override;
public
  function GetSaveOwner:TComponent;override;

end;

TIndTreeColumn = class (TIndFieldEditorItem)
private
 FPosition:TIndTreeColumnPosition;
 FColumn:TcxDBTreeListColumn;
 FColumnSaver:TIndTreeColumnSaver;
// FButtonView:TcxEditButton;
 function GetGridView: TIndBaseTreeView;

 function GetVisible: Boolean;
 procedure SetVisible(const Value: Boolean);
 procedure SetPosition(const Value: TIndTreeColumnPosition);
 function GetWidth: integer;
 procedure SetWidth(const Value: integer);
//    procedure SetButtonView(const Value: TcxEditButton);

protected
 function GetCol:TcxDBTreeListColumn;
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
 procedure FreeColumn;
 property GridColumn:TcxDBTreeListColumn read FColumn;
 procedure CreateColumn;
public
 {IIndVisualControl}
 function IndFocused:boolean; override;
 procedure IndSetFocus; override;
 function IndCanFocus:boolean; override;
 procedure IndSetEnable(const AValue:boolean); override;
 function IndGetEnable:boolean; override;
 procedure IndSetVisible(const AValue:boolean); override;
 function IndGetVisible:boolean; override;


 constructor Create(ACollection:TCollection); override;
 destructor Destroy; override;
 property View:TIndBaseTreeView read GetGridView;
// property ButtonView:TcxEditButton read FButtonView write SetButtonView;
published
 property UseFieldCaption default True;
 property Visible: Boolean read GetVisible write SetVisible default True;
 property Position:TIndTreeColumnPosition read FPosition write SetPosition;
 property Caption;
 property Name;
 property Field;
 property Width:integer read GetWidth write SetWidth;
end;

TIndTreeColumns = class (TIndFieldItemCollection)
private
 function GetItems(AIndex: integer): TIndTreeColumn;
 procedure SetItems(AIndex: integer; const Value: TIndTreeColumn);
 function GetView: TIndBaseTreeView;
 //function FindIndColumn(AColumn: TcxDBTreeListColumn): TIndTreeColumn;
protected
 procedure FreeColumns;
 procedure Loaded;
public
 function FindIndColumnByName(FName:string): TIndTreeColumn;
 constructor Create(AOwner:TIndBaseTreeView); virtual;
 destructor Destroy;override;
 procedure Notify(Item: TCollectionItem; Action: TCollectionNotification);override;
 function Add:TIndTreeColumn;
 procedure Update(Item: TCollectionItem);override;
 property Items[AIndex:integer]:TIndTreeColumn read GetItems write SetItems; default;
 property View:TIndBaseTreeView read GetView;
published

end;

TIndBaseTreeView = class (TInterfacedPersistent)
private
  FIndGrid: TIndTree;
  FTable:TIndTableRef;
  FOnTableChanged: TNotifyEvent;
  FBands: TIndTreeBands;
  FColumns: TIndTreeColumns;
  procedure SetIndGrid(const Value: TIndTree);

  procedure UpdateTableProperties;
  procedure DoBeforeTableChange(const Sender:TObject; const OldTable:TIndMetadataTable; const NewTable:TIndMetadataTable);
  procedure SetDataSet(const Value: TIndBaseDataSet);
  procedure SetTable(const Value: TIndTableRef);
  function GetDataSet: TIndbaseDataSet;
  function GetTable: TIndTableRef;

  procedure DoGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure DoGridDblClick(Sender:TObject);
  procedure DblClickAction;
  procedure SetBands(const Value: TIndTreeBands);
  procedure SetColumns(const Value: TIndTreeColumns);
  function GetViewType: TIndTreeViewType;
  procedure SetViewType(const Value: TIndTreeViewType);
  function GetAutoWidth: boolean;
  procedure SetAutoWidth(const Value: boolean);
  function GetGridLines: TcxTreeListGridLines;
  procedure SetGridLines(const Value: TcxTreeListGridLines);
protected
  FDraggedNode:TcxTreeListNode;
  procedure DoDragOther(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  procedure TreeDragDrop(Sender, Source: TObject; X, Y: Integer);
  procedure TreeStartDrag(Sender: TObject; var DragObject: TDragObject);
  procedure TreeEndDrag(Sender, Target: TObject; X, Y: Integer);
  procedure TreeMoveTo(Sender: TObject; AttachNode: TcxTreeListNode;
      AttachMode: TcxTreeListNodeAttachMode; Nodes: TList; var IsCopy,
      Done: Boolean);



  procedure DummiNotEnabledGetDisplayText(Sender: TcxTreeListColumn; ANode: TcxTreeListNode; var Value: String);
  procedure DummiNotVisibleGetDisplayText(Sender: TcxTreeListColumn; ANode: TcxTreeListNode; var Value: String);


 procedure GetNodeImageIndex(Sender: TObject;
  ANode: TcxTreeListNode; AIndexType: TcxTreeListImageIndexType;
  var AIndex: TImageIndex);

  procedure DoCustomDrawCell(Sender: TObject;
                             ACanvas: TcxCanvas;
                             AViewInfo: TcxTreeListEditCellViewInfo;
                             var ADone: Boolean);

  procedure ViewEditing(Sender: TObject; AColumn: TcxTreeListColumn; var Allow: Boolean); virtual; //Здесь производится разрешение показа редактора поля
  procedure DoOnClickViewButton;virtual;
  procedure DoAfterEditingTree;

  procedure TableChanged(Sender:TObject); virtual;

  function ViewTable:TIndBaseTable; virtual;
  procedure SetDataSource;
  procedure CreateGridColumns;
  procedure FreeGridColumns;



  function GetGrid: TcxDBTreeList;
  property Grid:TcxDBTreeList read GetGrid;
public
  property IndGrid:TIndTree read FIndGrid write SetIndGrid;

  procedure Assign(Source: TPersistent); override;
  constructor Create(AGrid:TIndTree); virtual;
  destructor Destroy; override;

  property DataSet:TIndBaseDataSet read GetDataSet write SetDataSet;
  property Table:TIndTableRef read GetTable write SetTable;
  property OnTableChanged:TNotifyEvent read FOnTableChanged write FOnTableChanged;
  property Bands:TIndTreeBands read FBands write SetBands;
  property Columns:TIndTreeColumns read FColumns write SetColumns;
  property ViewType:TIndTreeViewType read GetViewType write SetViewType default gvTree;
  property ColumnAutoWidth:boolean read GetAutoWidth write SetAutoWidth;
  property GridLines:TcxTreeListGridLines read GetGridLines write SetGridLines;
end;

TIndTreeColumnViewInfo = class (TIndColumnViewInfo)
private
  FRecordIndex: integer;
  FTreeColumn: TcxDBTreeListColumn;
  procedure SetRecordIndex(const Value: integer);
  procedure SetTreeColumn(const Value: TcxDBTreeListColumn);
protected
 function GetFieldValue: variant; override;
 function GetValueInfo(const AFieldName:string; var AExists:boolean):variant; override;
public
 property TreeColumn:TcxDBTreeListColumn read FTreeColumn write SetTreeColumn;
 property RecordIndex:integer read FRecordIndex write SetRecordIndex;

 constructor Create; override;
published
 property FieldValue;
 property FieldName;
 property FieldNameUp;
 property Visible;
 property Enabled;
end;

TIndTreeView = class (TIndBaseTreeView,IPropertiesGroup)
public
 //IPropertiesGroup
 function PropertyName:string;

 property DataSet;
 property Table;
 
published
  property Bands;
  property Columns;
  property ViewType;
  property ColumnAutoWidth;
  property GridLines;  
end;

TIndTreeManager = class (TIndControlDataSetActionManager)
protected
 function GetTableRef:TIndTableRef; override;
public
 function GetGroupName:string; override;

end;

TIndcxTreeListController = class(TcxTreeListController)
public
  procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
end;

TIndTreeListButtonProperties = class(TIndButtonProperties)
protected
  function Properties(AButtonParent:TPersistent):TcxCustomEditProperties;override;
  function GetField(AButtonParent:TPersistent):TIndFieldRef;override;
//  function GetButtonBrowse(AButtonParent:TPersistent):TcxEditButton;override;
//  procedure SetButtonBrowse(AButtonParent:TPersistent;AButton:TcxEditButton);override;
  function IsEditing(AButtonParent:TPersistent):boolean;override;  
  function GetIndFieldEditorItem(AButtonParent:TPersistent):TPersistent;override;
end;

TIndDBTreeList = class (TcxDBTreeList,IIndControlRefreshSelection)
private
  FIndTree:TIndTree;
  FButtonProperties:TIndTreeListButtonProperties;
  function IsLoading:boolean;
protected
  procedure DoMoveTo(AttachNode: TcxTreeListNode;
      AttachMode: TcxTreeListNodeAttachMode; ANodes: TList; IsCopy: Boolean); override;
  procedure RepaintControl(AObject:TPersistent);
  function GetIndObject(AObject:Tpersistent):TObject;
  function GetNativeObject(AObject:Tpersistent):TObject;
  function IsNativeObject(AObject:TPersistent):boolean;
  function GetControllerClass: TcxCustomControlControllerClass; override;

public
  procedure DoFocusColumn(Sender: TObject;
      APrevFocusedColumn, AFocusedColumn: TcxTreeListColumn);virtual;
  procedure DoOnTreeListEdited(Sender: TObject; AColumn: TcxTreeListColumn);virtual;
  procedure DoOnChangeRecord(Sender: TObject;
  APrevFocusedNode, AFocusedNode: TcxTreeListNode);virtual;
  procedure DoAfterEditingTree;virtual;

  constructor Create(AOwner:TComponent);override;
  property IndTree:TIndTree read FIndTree write FIndTree;


end;

TIndTreeSaver = class(TIndComponentsSaver)
private
  function GetTree: TIndTree;
protected
  property Tree:TIndTree read GetTree;
public
  procedure LoadComponentsFromStorage;override;
  procedure SaveComponentsToStorage;override;
end;

TIndTreeChecker = class(TIndRecnoChecker)
private
  procedure EnableColumnsSorting;
  procedure EnableSortingRecno;
protected
//  function HasRecnoField(RecnoField: TField): boolean;override;
  procedure UpdateOptions;override;
  function GetTableRef(AComponent:TComponent):TIndTableRef;override;
public
  procedure SetCanSorting;override;
end;

TIndTree = class (TIndCustomGridPanel,
                IIndListener, IIndActionSource, IOwnerControl, IActionShortCut,
                IDesignerCanAcceptControls,IIndActiveControl, IIndSaverImplementor,
                IIndGetForm, IIndGetTable
                )
private
 FTreeSaver:TIndTreeSaver;
 FManager:TIndTreeManager;
 FGrid:TIndDBTreeList;
 FView:TIndTreeView;
 FIndTreeChecker:TIndTreeChecker;
 FIndFormTransmitter:TIndFormTransmitter;
 FOnChange:TNotifyEvent;
 function GetDataSet: TIndBaseDataSet;
 function GetTable: TIndTableRef;
 procedure SetDataSet(const Value: TIndBaseDataSet);
 procedure SetTable(const Value: TIndTableRef);
 procedure SetView(const Value: TIndTreeView);
 procedure GetEditProperties(Sender: TcxTreeListColumn;
      ANode: TcxTreeListNode; var EditProperties: TcxCustomEditProperties);
 function FindBand(ABand:TcxTreeListBand):TIndTreeBand;
 function FindColumn(AColumn:TcxDBTreeListColumn):TIndTreeColumn;
//    function GetField: TIndFieldRef;
//    procedure SetField(const Value: TIndFieldRef);
 function GetOptionsView: TcxTreeListOptionsView;
 function GetOptionsSelection: TcxTreeListOptionsSelection;
 procedure SetOnChange(const Value: TNotifyEvent);
 function GetSelectionCount: integer;
 function GetNodes: TcxTreeListNodes;
 procedure ResizeChanged(var Message: TWMSize); message WM_SIZE;
protected
 procedure Loaded;override;
 procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 function GetSaver:TIndSaver;
 function GetIndObject(AObject:Tpersistent):TObject;
 function GetIndTable:TIndMetadataTable;

 property IndFormTransmitter:TIndFormTransmitter read FIndFormTransmitter implements IIndGetForm;
public
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

 constructor Create(AOwner:TComponent); override;
 destructor Destroy; override;

 property Manager:TIndTreeManager read FManager;
 property OptionsView:TcxTreeListOptionsView read GetOptionsView;
 property OptionsSelection:TcxTreeListOptionsSelection read GetOptionsSelection;
 property OnChange:TNotifyEvent read FOnChange write SetOnChange;
 property SelectionCount:integer read GetSelectionCount;
 property Nodes:TcxTreeListNodes read GetNodes;
published
 property Grid:TIndDBTreeList read FGrid;
 property Width;
 property Height;
 property Top;
 property Left;
 property Align;
 property View:TIndTreeView read FView write SetView;
 property Table:TIndTableRef read GetTable write SetTable;
 property DataSet:TIndBaseDataSet read GetDataSet write SetDataSet;
end;




implementation
uses dmuStyles,dmuConnection, cxControls, dmuLanguages, uIndTablesMetadata, uIndDBEditCommon, uConstant;

{ TIndVerticalGrid }

procedure TIndTree.AddBar(const IndBar: TComponent);
begin
 FManager.Addbar(IndBar);
end;


function TIndTree.CanActionShortCut: boolean;
begin
 Result := FGrid.IsFocused;
end;

function TIndTree.CanSelectAction: boolean;
begin
 Result := Assigned(Table.Table) and Assigned(Table.Table.Data) and Table.Table.Data.CanModify;
end;

function TIndTree.CanShowEditors: boolean;
begin
 Result := True;
end;

constructor TIndTree.Create(AOwner: TComponent);
begin
  inherited;
  TabStop := False;
  SetBounds(10,10,200,100);
  ControlStyle := [ csAcceptsControls, csOpaque, csSetCaption, csCaptureMouse, csClickEvents, csDoubleClicks];
  FGrid := TIndDBTreeList.Create(Self);
  FGrid.IndTree := Self;
  FGrid.BorderStyle := cxcbsNone;

  BevelInner := bvNone;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  BorderWidth := 1;
  Color := GetGridFocusedCellFocusedColor;

  FGrid.Parent := Self;
  //m.proh
  FGrid.Align := alCustom;//alClient;

  FView := TIndTreeView.Create(Self);
  FManager := TIndTreeManager.Create(Self);
  FManager.AddOwnerControl(Self);
  FView.OnTableChanged := FManager.TableChanged;
  FGrid.OnEditing := FView.ViewEditing;
  FGrid.OnKeyDown := FView.DoGridKeyDown;
  FGrid.OnDblClick := FView.DoGridDblClick;
  FGrid.OnGetNodeImageIndex := FView.GetNodeImageIndex;
  FGrid.RootValue := null;
  FGrid.OnCustomDrawCell := FView.DoCustomDrawCell;
  FGrid.Images := dmConnection.Configuration.ImageList.Images;
  FGrid.OptionsView.Indicator := True;
  FGrid.OptionsBehavior.IncSearch := True;
  FGrid.OptionsBehavior.ExpandOnIncSearch := True;
  FGrid.OptionsBehavior.ExpandOnDblClick := False;
//  FGrid.OptionsSelection.InvertSelect := False;
  FGrid.Styles.IncSearch := dmStyles.sIncSearch;
  FGrid.OptionsData.CancelOnExit := False;
  FGrid.FreeNotification(Self);
  //создаем хранитель компонента
  FTreeSaver := TindTreeSaver.Create(self);
  FTreeSaver.SavedComponent := Self;

  FIndTreeChecker := TIndTreeChecker.Create(Self);
  FIndTreeChecker.IndComponent := Self;

  FIndFormTransmitter := TIndFormTransmitter.Create(Self);
  FIndFormTransmitter.Component := Self;
end;

procedure TIndTree.CreateBarView(const IndBar: TComponent);
begin
 FManager.CreateBarView(IndBar);
end;

procedure TIndTree.DeleteBar(const IndBar: TComponent);
begin
  FManager.DeleteBar(IndBar);
end;

procedure TIndTree.DeleteBarView(const IndBar: TComponent);
begin
 FManager.DeleteBarView(IndBar);
end;

procedure TIndTree.GetEditProperties(Sender: TcxTreeListColumn; ANode: TcxTreeListNode; var EditProperties: TcxCustomEditProperties);
begin
 EditProperties := nil;
end;

destructor TIndTree.Destroy;
var i:integer;
begin
   FGrid.CancelEdit;
 // FGrid.DeleteAllColumns;
 // FGrid.Bands.Clear;
  //Application.ProcessMessages;
//  FTreeSaver.SaveComponentsToStorage;
  for i := 0 to FGrid.ColumnCount - 1 do
  begin
   FGrid.Columns[i].OnGetEditProperties := GetEditProperties;
   FGrid.Columns[i].SortOrder := soNone;
  end;

  FView.Free;
{  FGrid.DeleteAllColumns;
  Application.ProcessMessages;
  FGrid.Bands.Clear;
  Application.ProcessMessages;
  FGrid.Free;}
  inherited;
end;

function TIndTree.GetDataSet: TIndBaseDataSet;
begin
  Result := FView.DataSet;
end;

function TIndTree.GetHitTest(Message: TMessage;
  Sender: TControl): boolean;
var //X,Y:integer;
    pHitTest:TcxTreeListHitTest;
begin
 Result := False;
{ X := TWMMouse(Message).XPos;
 Y := TWMMouse(Message).YPos; }
 if (Sender is TcxDBTreeList) then
 begin
   pHitTest := FGrid.HitTest;
   if  pHitTest.HitAtBandHeader
    or pHitTest.HitAtColumnHeader
    or pHitTest.HitAtColumn
    or pHitTest.HitAtBand
    or pHitTest.HitAtSeparator
    or pHitTest.HitAtBandContainer
    or pHitTest.HitAtSizingHorz
    then Result := True;

   if ((Message.WParam and WM_LBUTTONDOWN <> 0) and (Message.Msg = WM_MOUSEMOVE) and  (not pHitTest.HitAtSizingVert)) then
   begin
    Result := True;
   end;

   Exit;
 end;
end;


function TIndTree.GetTable: TIndTableRef;
begin
  Result := FView.Table;
end;

procedure TIndTree.HandleEvent(ASender: TObject;
  const AEvent: integer);
begin
 if AEvent = cControlSelectionRefresh then
    FGrid.RepaintControl(Self);
end;

procedure TIndTree.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
   if AComponent is TcxDBTreeList then
    FGrid := nil
   else if AComponent is TcxDBTreeListColumn then
    TcxDBTreeListColumn(AComponent).SortOrder := soNone;
  end;
end;

procedure TIndTree.SetDataSet(const Value: TIndBaseDataSet);
begin
 FView.DataSet := Value;
end;

procedure TIndTree.SetTable(const Value: TIndTableRef);
begin
   FView.Table := Value;
end;

procedure TIndTree.SetView(const Value: TIndTreeView);
begin
 if Value <> FView then
 begin
  FView.Assign(Value);
 end;
end;

{ TIndBaseVerticalGridView }

procedure TIndBaseTreeView.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TIndBaseTreeView) then
  begin
   
  end
  else
   inherited;

end;

constructor TIndBaseTreeView.Create(AGrid: TIndTree);
begin
  inherited Create;
  FTable := TIndTableRef.Create(AGrid);
  FTable.OnTableChanged := TableChanged;
  FBands := TIndTreeBands.Create(Self);
  FColumns := TIndTreeColumns.Create(Self);
  IndGrid := AGrid; 
end;

procedure TIndBaseTreeView.CreateGridColumns;
begin

end;

procedure TIndBaseTreeView.DblClickAction;
begin
 IndGrid.Manager.ExecuteDefaultAction;
end;

destructor TIndBaseTreeView.Destroy;
begin
  if Assigned(FColumns) then FreeAndNil(FColumns);
  if Assigned(FBands) then FreeAndNil(FBands);
  if Assigned(FTable) then FreeAndNil(FTable);
  inherited;
end;

procedure TIndBaseTreeView.DoBeforeTableChange(
  const Sender: TObject; const OldTable, NewTable: TIndMetadataTable);
begin
// if Assigned(OldTable) then
//  OldTable.RemoveFetchListener(Self);
end;


procedure TIndBaseTreeView.DoGridDblClick(Sender: TObject);
begin
 if (not Grid.HitTest.HitAtIndent) and Grid.HitTest.HitAtNode then
  DblClickAction; 
end;

procedure TIndBaseTreeView.DoGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
 if (Key = 13) and (Shift = []) then
    DblClickAction;
end;

procedure TIndBaseTreeView.FreeGridColumns;
begin

end;

function TIndBaseTreeView.GetDataSet: TIndbaseDataSet;
begin
  Result := FTable.DataSet;
end;

function TIndBaseTreeView.GetGrid: TcxDBTreeList;
begin
 if Assigned(FIndGrid) then Result := FIndGrid.FGrid
 else Result := nil;
end;


function TIndBaseTreeView.GetTable: TIndTableRef;
begin
 Result := FTable;
end;


procedure TIndBaseTreeView.SetBands(
  const Value: TIndTreeBands);
begin
 if Value <> FBands then
  FBands.Assign(Value);
end;

procedure TIndBaseTreeView.SetDataSet(
  const Value: TIndBaseDataSet);
begin
 FTable.DataSet := Value;
end;

procedure TIndBaseTreeView.SetDataSource;

  procedure InnerSetDataSource(ADataSource:TDataSource);
  begin
    Grid.DataController.DataSource := ADataSource;
  end;

var t:TIndBaseTable;
begin
   t := ViewTable;
   if Assigned(t) and t.SupportTreeView then
   begin
    if t.IsTablePart then
    begin
     //Разрешение операций Drag&Drop
 //     Grid.DragMode := dmAutomatic;
      Grid.DragMode := dmAutomatic;
      Grid.OnDragOver := DoDragOther;
      Grid.OnDragDrop := TreeDragDrop;
      Grid.OnStartDrag := TreeStartDrag;
      Grid.OnEndDrag := TreeEndDrag;
      Grid.OnMoveTo := TreeMoveTo;
    end
    else begin
      //Заперт операций Drag&Drop
      Grid.DragMode := dmManual;
      Grid.OnDragOver := nil;
      Grid.OnDragDrop := nil;
      Grid.OnStartDrag := nil;
      Grid.OnEndDrag := nil;
      Grid.OnMoveTo := nil;
    end;
    InnerSetDataSource(t.DataSource);
    if t is TIndMetadataTable then
    begin
     Grid.DataController.ParentField := TIndMetadataTable(t).DataProvider.GetFieldIdParentName;
     Grid.DataController.KeyField := TIndMetadataTable(t).DataProvider.GetFieldIdName;
     Grid.DataController.ImageIndexFieldName := TIndMetadataTable(t).DataProvider.GetFieldImageIndexName;
    end;
   end
   else begin
    InnerSetDataSource(nil);
    Grid.DataController.ParentField := '';
    Grid.DataController.KeyField := '';
   end;
end;

procedure TIndBaseTreeView.SetColumns(
  const Value: TIndTreeColumns);
begin
 if Value <> FColumns then
  FColumns.Assign(Value);
end;

procedure TIndBaseTreeView.SetIndGrid(
  const Value: TIndTree);
begin
 if Value <> FIndGrid then
  FIndGrid := Value;
end;


procedure TIndBaseTreeView.SetTable(const Value: TIndTableRef);
begin
 FTable.Assign(Value);
end;


procedure TIndBaseTreeView.TableChanged(Sender: TObject);
begin
 SetDataSource;
 UpdateTableProperties;
 if Assigned(FOnTableChanged) then FOnTableChanged(Self);
end;

procedure TIndBaseTreeView.UpdateTableProperties;
begin
  if Assigned(Table) and Assigned(Table.Table) then
  begin
    Table.BeforeTableChange := DoBeforeTableChange;
  end;
end;

procedure TIndBaseTreeView.ViewEditing(Sender: TObject; AColumn: TcxTreeListColumn; var Allow: Boolean);

  procedure fsGetVisibleEnable(const AViewInfo:TIndColumnViewInfo);
  begin
    //Вызов FastScrip-а для определения видимости колонки и свойства Enable
    if Assigned(Table.Table)
       and Assigned(Table.Table.DataProvider)
    then begin
      Table.Table.DataProvider.fsDrawGridCell(AViewInfo);
    end;
  end;

var m:TIndField;
    f:TField;
    VInf:TIndTreeColumnViewInfo;
begin
 Allow := False;

 if Assigned(Table.Table) then
 begin
  f := TcxDBTreeListColumn(AColumn).DataBinding.Field;
  if not Assigned(F) then exit;
  m := TIndField(F.Tag);

  if not Assigned(AColumn.OnGetDisplayText) then
  begin
   VInf := TIndTreeColumnViewInfo.Create;
   try
      VInf.TreeColumn := TcxDBTreeListColumn(AColumn);
      VInf.RecordIndex :=  TcxDBTreeListColumn(AColumn).TreeList.FocusedNode.RecordIndex;
     //Здесь запуск процедуры Fs
     fsGetVisibleEnable(VInf);
     if not VInf.Visible then
     begin
      AColumn.OnGetDisplayText := DummiNotVisibleGetDisplayText;
     end
     else if not VInf.Enabled then
     begin
      AColumn.OnGetDisplayText := DummiNotEnabledGetDisplayText;
     end;
     if VInf.Enabled and VInf.Visible then
     begin
      AColumn.OnGetDisplayText := nil;
     end;
   finally
     VInf.Free;
   end;
  end;
  Allow := (not Assigned(AColumn.OnGetDisplayText))  and AllowShowEditor(Table,F,M);
  if Allow then
    DoAfterEditingTree;
 end;

end;

function TIndBaseTreeView.ViewTable: TIndBaseTable;
begin
 Result := Table.Table;
end;

{ TIndVerticalGridManager }

function TIndTreeManager.GetGroupName: string;
begin
 if Owner is TIndTree then
  Result := Owner.Name
 else
  Result := Self.Name;
end;

function TIndTreeManager.GetTableRef: TIndTableRef;
begin
   if Owner is TIndTree then
  begin
    Result := TIndTree(Owner).Table;
  end
  else Result := nil;
end;

{ TIndVerticalGridView }

function TIndTreeView.PropertyName: string;
begin
 Result := 'View';
end;

{ TIndVerticalGridCategories }

function TIndTreeBands.Add: TIndTreeBand;
begin
 Result := TIndTreeBand(inherited Add);
end;

constructor TIndTreeBands.Create(AOwner:TIndBaseTreeView);
begin
  inherited Create(AOwner,AOwner.Table,TIndTreeBand);
end;

destructor TIndTreeBands.Destroy;
begin
  FreeBands;
  inherited;
end;

function TIndTreeBands.FindIndBandByName(
  FName: string): TIndTreeBand;
var I:integer;
begin
   Result := nil;
   for I := 0 to Count - 1 do
   begin
      if Items[I].Name = FName then
         Result := Items[I];
   end;
end;

{function TIndTreeBands.FindIndBand(
  ABand: TcxTreeListBand): TIndTreeBand;
var K:integer;
begin
    Result := nil;
    for K := 0 to Count - 1 do
    begin
      if Items[K].FBand = ABand then
      begin
         Result := Items[K];
         Break;
      end;
    end;
end;}

procedure TIndTreeBands.FreeBands;
var i:integer;
begin
  for i := 0 to Count - 1 do
  begin
   Items[i].FreeBand;
  end;
end;



function TIndTreeBands.GetItems(
  AIndex: integer): TIndTreeBand;
begin
  Result := TIndTreeBand(inherited GetItem(AIndex));
end;

function TIndTreeBands.GetView: TIndBaseTreeView;
begin
 Result := TIndBaseTreeView(Owner);
end;

procedure TIndTreeBands.Loaded;
begin

end;

procedure TIndTreeBands.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
//var I:integer;
    //AColList:TList;
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

procedure TIndTreeBands.SetItems(AIndex: integer;
  const Value: TIndTreeBand);
begin
  inherited SetItem(AIndex, Value);
end;

procedure TIndTreeBands.Update(Item: TCollectionItem);
begin
  inherited;
//  View. GridView.Changed(vcSize);
end;

{ TIndVerticalGridCategory }

class function TIndTreeBand.BaseName: string;
begin
  Result := 'Band';
end;

constructor TIndTreeBand.Create(ACollection: TCollection);
begin
  inherited;
  FPosition := nil;
  CreateBand;
end;

procedure TIndTreeBand.CreateBand;
begin
  FBand := View.Grid.Bands.Add;
  FPosition := TIndTreeBandPosition.Create(FBand);
end;

constructor TIndTreeBand.CreateForBand(ACollection: TCollection;
  ABand: TcxTreeListBand);
begin
  inherited Create(ACollection);
  FBand := ABand;
  FPosition := TIndTreeBandPosition.Create(FBand);
end;

class function TIndTreeBand.DefaultUseFieldCaption: boolean;
begin
 Result := False;
end;

destructor TIndTreeBand.Destroy;
begin
  FreeBand;
  inherited;
end;


procedure TIndTreeBand.FreeBand;
begin
 if Assigned(FPosition) then
 begin
   FPosition.Free;
   FPosition := nil;
 end;
 if Assigned(FBand) then
 begin
  if not (csDestroying in View.IndGrid.ComponentState) then
  begin
   View.IndGrid.FGrid.Bands.Delete(FBand.Index);
  end;
  FBand := nil;
 end;
end;


function TIndTreeBand.GetBand: TcxTreeListBand;
begin
  Result := FBand;
end;

function TIndTreeBand.GetFixedKind: TcxTreeListBandFixedKind;
begin
 if Assigned(FBand) then
  Result := FBand.FixedKind
 else
  Result := tlbfNone;
end;

function TIndTreeBand.GetGridView: TIndBaseTreeView;
begin
 Result := TIndTreeBands(Collection).View;
end;






function TIndTreeBand.GetVisible: Boolean;
var pBand:TcxTreeListBand;
begin
 pBand := GetBand;
 if Assigned(pBand) then
  Result := pBand.Visible
 else
  Result := False;
end;




function TIndTreeBand.GetWidth: integer;
begin
 Result := FBand.Width;
end;

procedure TIndTreeBand.SetFixedKind(const Value: TcxTreeListBandFixedKind);
begin
  if Assigned(FBand) then
   FBand.FixedKind := Value;
end;

procedure TIndTreeBand.SetPosition(
  const Value: TIndTreeBandPosition);
begin
 if Assigned(FPosition) then
  FPosition.Assign(Value);
end;

procedure TIndTreeBand.SetVisible(const Value: Boolean);
var pBand:TcxTreeListBand;
begin
 pBand := GetBand;
 if Assigned(pBand) then
 begin
  if Value <> pBand.Visible then
  begin
//   pBand.VerticalGrid.BeginUpdate;
   try
     pBand.Visible := Value;
   finally
//     pBand.VerticalGrid.EndUpdate;
   end;
  end;
 end;
end;

procedure TIndTreeBand.SetWidth(const Value: integer);
begin
 FBand.Width := Value;
end;

procedure TIndTreeBand.UpdateObjectCaption;
begin
  inherited;
  if Assigned(FBand) then
  begin
   if UseFieldCaption then
    FBand.Caption.Text := GetFieldCaption
   else
    FBand.Caption.Text := Caption;
  end;
end;

{ TIndVerticalGridEditor }

class function TIndTreeColumn.BaseName: string;
begin
 Result := 'Column';
end;


function TIndTreeColumn.CanShowEditors: boolean;
begin
  Result := View.IndGrid.CanShowEditors;
end;

constructor TIndTreeColumn.Create(ACollection: TCollection);
begin
  inherited;
  CreateColumn;
  View.Bands.CheckForFirstBand;
  //создаем и инициализируем хранитель
  FColumnSaver := TIndTreeColumnSaver.Create(Self.View.IndGrid);
  FColumnSaver.SavedPersistent := Self;
end;

procedure TIndTreeColumn.CreateColumn;
begin
  FColumn := TcxDBTreeListColumn(View.Grid.CreateColumn(nil));
  //FColumn.Parent := nil;
  FColumn.Tag := Integer(Self);
  FPosition := TIndTreeColumnPosition.Create(FColumn);
  FColumn.FreeNotification(View.IndGrid);
end;


class function TIndTreeColumn.DefaultUseFieldCaption: boolean;
begin
 Result := True;
end;

destructor TIndTreeColumn.Destroy;
begin
  FreeColumn;
  inherited;
end;



function TIndTreeColumn.FieldEditor: TComponent;
begin
 Result := FColumn;
end;


procedure TIndTreeColumn.FreeColumn;
begin
 if Assigned(FPosition) then
 begin
  FPosition.Free;
  FPosition := nil;
 end;
 if Assigned(FColumn) then
 begin
  if not (csDestroying in View.IndGrid.ComponentState) then
  begin
   FColumn.Free;
  end;
  FColumn := nil;
 end;
end;

procedure TIndTreeColumn.SetFieldEditorPropertiesClass(AClass:TcxCustomEditPropertiesClass);
//var i:integer;
begin
 if Assigned(FColumn) then FColumn.PropertiesClass := AClass;
{ //Добавил Степа 10.12.2008
 if Assigned(FColumn.Properties) then
 begin
  for i := 0 to FColumn.Properties.Buttons.Count - 1 do
  begin
    FColumn.Properties.Buttons[I].Visible := False;
  end;
 end;
 //Конец Добавил Степа 10.12.2008}
end;

function TIndTreeColumn.GetFieldEditorProperties: TcxCustomEditProperties;
begin
 Result := FColumn.Properties;
end;


function TIndTreeColumn.GetGridView: TIndBaseTreeView;
begin
 Result := TIndTreeColumns(Collection).View;
end;



procedure TIndTreeColumn.SetDataBindingProperty(
  const AFieldName: string);
begin
  inherited;
  if Assigned(FColumn) then
   FColumn.DataBinding.FieldName := AFieldName;
end;






procedure TIndTreeColumn.SetIsEditor;
begin
  inherited;
  FColumn.Options.ShowEditButtons := eisbDefault;
  FColumn.Options.Editing := True;
end;

procedure TIndTreeColumn.SetNotEditor;
begin
  inherited;
  FColumn.Options.ShowEditButtons := eisbNever;
  FColumn.Options.Editing := False;
end;





procedure TIndTreeColumn.UpdateObjectCaption;
begin
  inherited;
  if Assigned(FColumn) and (not (csDestroying in FColumn.ComponentState)) then
  begin
    if UseFieldCaption then
     FColumn.Caption.Text := GetFieldCaption
    else
     FColumn.Caption.Text := Caption;
  end;
end;

function TIndTreeColumn.GetCol: TcxDBTreeListColumn;
begin
 Result := FColumn;
end;


function TIndTreeColumn.GetVisible: Boolean;
var pCol:TcxDBTreeListColumn;
begin
 pCol := GetCol;
 if Assigned(pCol) then
  Result := pCol.Visible
 else
  Result := False;
end;


procedure TIndTreeColumn.SetVisible(const Value: Boolean);
var pCol:TcxDBTreeListColumn;
begin
 pCol := GetCol;
 if Assigned(pCol) then
 begin
  if Value <> pCol.Visible then
  begin
   //pCol.VerticalGrid.BeginUpdate;
   try
     pCol.Visible := Value;
   finally
     //pCol.VerticalGrid.EndUpdate;
   end;
  end;
 end;
end;

procedure TIndTreeColumn.SetPosition(
  const Value: TIndTreeColumnPosition);
begin
 if Assigned(FPosition) then
  FPosition.Assign(Value);
end;

{ TIndVerticalGridEditors }

function TIndTreeColumns.Add: TIndTreeColumn;
begin
 Result := TIndTreeColumn(inherited Add);
end;

constructor TIndTreeColumns.Create(
  AOwner: TIndBaseTreeView);
begin
  inherited Create(AOwner,AOwner.Table,TIndTreeColumn);
end;

destructor TIndTreeColumns.Destroy;
begin
  FreeColumns;
  inherited;
end;

{function TIndTreeColumns.FindIndColumn(
  AColumn: TcxDBTreeListColumn): TIndTreeColumn;
var K:integer;
begin
    Result := nil;
    for K := 0 to Count - 1 do
    begin
      if Items[K].FColumn = AColumn then
      begin
         Result := Items[K];
         Break;
      end;
    end;
end;}

function TIndTreeColumns.FindIndColumnByName(
  FName: string): TIndTreeColumn;
var I:integer;
begin
   Result := nil;
   for I := 0 to Count - 1 do
   begin
      if Items[I].Name = FName then
         Result := Items[I];
   end;
end;

procedure TIndTreeColumns.FreeColumns;
var i:integer;
begin
 // View.Grid.DeleteAllColumns;
  for i := 0 to Count - 1 do
  begin
   Items[i].FreeColumn;
  end;
end;

function TIndTreeColumns.GetItems(
  AIndex: integer): TIndTreeColumn;
begin
  Result := TIndTreeColumn(inherited GetItem(AIndex));
end;

function TIndTreeColumns.GetView: TIndBaseTreeView;
begin
 Result := TIndBaseTreeView(Owner);
end;

procedure TIndTreeColumns.Loaded;
begin

end;

procedure TIndTreeColumns.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;
{  if Action = cnAdded then
  begin
   View.Bands.CheckForFirstBand;
  end;}
end;

procedure TIndTreeColumns.SetItems(AIndex: integer;
  const Value: TIndTreeColumn);
begin
  inherited SetItem(AIndex, Value);
end;

procedure TIndTreeColumns.Update(Item: TCollectionItem);
begin
  inherited;

end;


{ TIndVerticalGridRowPosition }

procedure TIndTreeColumnPosition.Assign(Source: TPersistent);
begin
  if Source is TIndTreeColumnPosition then
  begin
    RowIndex := TIndTreeColumnPosition(Source).RowIndex;
    ColIndex := TIndTreeColumnPosition(Source).ColIndex;
    BandIndex := TIndTreeColumnPosition(Source).BandIndex;
  end
  else
   inherited;
end;

constructor TIndTreeColumnPosition.Create(ACol:TcxDBTreeListColumn);
begin
 inherited Create;
 FCol := ACol;
end;


function TIndTreeColumnPosition.GetBandIndex: integer;
begin
 Result := FCol.Position.BandIndex;
end;

function TIndTreeColumnPosition.GetColIndex: integer;
begin
 Result := FCol.Position.ColIndex;
end;

function TIndTreeColumnPosition.GetRowIndex: integer;
begin
 Result := FCol.Position.RowIndex;
end;




procedure TIndTreeColumnPosition.SetBandIndex(const Value: integer);
begin
 if Value <> FCol.Position.BandIndex then
 begin
  if (Value > -1)  then
    FCol.Position.BandIndex := Value;
 end;
end;

procedure TIndTreeColumnPosition.SetColIndex(const Value: integer);
begin
 if Value <> FCol.Position.ColIndex then
 begin
  if (Value > -1)  then
    FCol.Position.ColIndex := Value;
 end;
end;

procedure TIndTreeColumnPosition.SetRowIndex(const Value: integer);
begin
 if Value <> FCol.Position.RowIndex then
 begin
  if (Value > -1)  then
    FCol.Position.RowIndex := Value;
 end;
end;



{ TIndTreeBandPosition }

procedure TIndTreeBandPosition.Assign(Source: TPersistent);
begin
  if Source is TIndTreeBandPosition then
  begin
    Index := TIndTreeBandPosition(Source).Index;
  end
  else
   inherited;
end;

constructor TIndTreeBandPosition.Create(ABand: TcxTreeListBand);
begin
 inherited Create;
 FBand := ABand;
end;

function TIndTreeBandPosition.GetVisibleIndex: integer;
begin
 Result := FBand.VisibleIndex;
end;

procedure TIndTreeBandPosition.SetVisibleIndex(const Value: integer);
begin
 if Value <> FBand.VisibleIndex then
 begin
  if (Value > -1)  then
    FBand.VisibleIndex := Value;
 end;
end;

function TIndBaseTreeView.GetViewType: TIndTreeViewType;
begin
 if IndGrid.FGrid.OptionsView.Bands then
  Result := gvBandedTree
 else
  Result := gvTree;
end;

procedure TIndBaseTreeView.SetViewType(const Value: TIndTreeViewType);
begin
 if Value = gvBandedTree then
  IndGrid.FGrid.OptionsView.Bands := True
 else
  IndGrid.FGrid.OptionsView.Bands := False;
end;

function TIndTreeColumn.GetWidth: integer;
begin
 Result := FColumn.Width;
end;

procedure TIndTreeColumn.SetWidth(const Value: integer);
begin
 FColumn.Width := Value;
end;

procedure TIndTreeBands.CheckForFirstBand;
var i:integer;
   // pBand:TIndTreeBand;
begin
 if (Count = 0) and (View.Grid.Bands.Count > 0) then
 begin
  for i := 0 to View.Grid.Bands.Count - 1 do
  begin
   {pBand :=} TIndTreeBand.CreateForBand(Self,View.Grid.Bands[i]);
  end;
 end;
end;

function TIndBaseTreeView.GetAutoWidth: boolean;
begin
 Result := Grid.OptionsView.ColumnAutoWidth;
end;

procedure TIndBaseTreeView.SetAutoWidth(const Value: boolean);
begin
 Grid.OptionsView.ColumnAutoWidth := Value;
end;

procedure TIndBaseTreeView.DoCustomDrawCell(Sender: TObject;
  ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo;
  var ADone: Boolean);

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
     ACanvas.FillRect(AViewInfo.ContentRect);
     ADone := True;
  end;

  procedure MakeDisable;
  begin
    ACanvas.Font.Color := clGrayText;
  end;

var VInf:TIndTreeColumnViewInfo;
begin

 if AViewInfo.Control.IsFocused then
 begin
   if  AViewInfo.Column.Focused  and AViewInfo.Focused then
   begin
    ACanvas.Brush.Color := GetGridFocusedCellFocusedColor;
    ACanvas.Font.Color := GetGridFocusedCellFocusedColorText;
   end
   else if AViewInfo.Selected then
   begin
    ACanvas.Brush.Color := GetGridFocusedCellSelectedColor;
    ACanvas.Font.Color := GetGridFocusedCellSelectedColorText;
   end;
 end
 else begin
   if AViewInfo.Column.Focused and AViewInfo.Focused then
   begin
     ACanvas.Brush.Color := GetGridNotFocusedCellFocusedColor;
     ACanvas.Font.Color := GetGridNotFocusedCellFocusedColorText; //clHighlightText;
   end
   else if AViewInfo.Selected then begin
     ACanvas.Brush.Color := GetGridNotFocusedCellSelectedColor;
     ACanvas.Font.Color := GetGridNotFocusedCellSelectedColorText; //clHighlightText;
   end;
 end;

 VInf := TIndTreeColumnViewInfo.Create;
 try
    VInf.TreeColumn := TcxDBTreeListColumn(AViewInfo.Column);
    VInf.RecordIndex := AViewInfo.RecordIndex;
   //Здесь запуск процедуры Fs
   fsGetVisibleEnable(VInf);
   if not VInf.Visible then
   begin
    AViewInfo.Column.OnGetDisplayText := DummiNotVisibleGetDisplayText;
    MakeEmpty;
   end
   else if not VInf.Enabled then
   begin
    AViewInfo.Column.OnGetDisplayText := DummiNotEnabledGetDisplayText;
    MakeDisable;
   end;
   if VInf.Enabled and VInf.Visible then
   begin
    AViewInfo.Column.OnGetDisplayText := nil;
   end;
 finally
   VInf.Free;
 end;


end;

function TIndBaseTreeView.GetGridLines: TcxTreeListGridLines;
begin
 Result := IndGrid.FGrid.OptionsView.GridLines;
end;

procedure TIndBaseTreeView.SetGridLines(const Value: TcxTreeListGridLines);
begin
 IndGrid.FGrid.OptionsView.GridLines := Value;
end;



procedure TIndBaseTreeView.GetNodeImageIndex(Sender: TObject;
  ANode: TcxTreeListNode; AIndexType: TcxTreeListImageIndexType;
  var AIndex: TImageIndex);
var pTableProp:TIndTableIconsProperty;
begin
 if not (csDestroying in IndGrid.ComponentState) then
 begin
   if Assigned(Table.Table) and Assigned(Table.Table.Metadata) then
   begin
     if not Table.Table.IsTablePart then
     begin
        if ANode.Count > 0 then
         pTableProp := Table.Table.Metadata.TableIcons.TreeFolderIcons
        else
         pTableProp := Table.Table.Metadata.TableIcons.TreeIcons;
        if AIndex = Table.Table.Metadata.TableIcons.CommonIcons.IconCommonIndex then
         AIndex := pTableProp.IconCommonIndex
        else  if AIndex = Table.Table.Metadata.TableIcons.CommonIcons.IconDeletedIndex then
         AIndex := pTableProp.IconDeletedIndex
        else  if AIndex = Table.Table.Metadata.TableIcons.CommonIcons.IconRegisteredIndex then
         AIndex := pTableProp.IconRegisteredIndex;
     end
     else begin
       if ANode.Count > 0 then
        pTableProp := Table.Table.Metadata.TableIcons.TreeFolderIcons
       else
        pTableProp := Table.Table.Metadata.TableIcons.TreeIcons;
       AIndex := pTableProp.IconCommonIndex;
     end;
   end;
 end;
end;

function TIndTree.CanAcceptControls: boolean;
begin
 Result := False;
end;

function TIndTree.GetActiveControl: TWinControl;
begin
 Result := FGrid;

end;

function TIndTreeColumn.IndCanFocus: boolean;
begin
 Result := Assigned(FColumn) and FColumn.Visible;
end;

function TIndTreeColumn.IndFocused: boolean;
begin
 Result := Assigned(FColumn) and FColumn.Focused;
end;

function TIndTreeColumn.IndGetEnable: boolean;
begin
 Result := Assigned(FColumn) and FColumn.Visible;
end;

function TIndTreeColumn.IndGetVisible: boolean;
begin
 Result := Assigned(FColumn) and FColumn.Visible;
end;

procedure TIndTreeColumn.IndSetEnable(const AValue: boolean);
begin

end;

procedure TIndTreeColumn.IndSetFocus;
begin
 if Assigned(FColumn) and FColumn.Visible then
 begin
  FColumn.MakeVisible;
  FColumn.Focused := True;
 end;
end;

procedure TIndTreeColumn.IndSetVisible(const AValue: boolean);
begin
 if Assigned(FColumn) and Assigned(Field.Table)
    and (Field.Table is TIndOneRecordMetadataTable) then
 begin
  FColumn.Visible := AValue;
 end;
end;

{ TIndTreeColumnViewInfo }

constructor TIndTreeColumnViewInfo.Create;
begin
  inherited;
  FRecordIndex := -1;
end;

function TIndTreeColumnViewInfo.GetFieldValue: variant;
begin
 if Assigned(FTreeColumn) and (RecordIndex >= 0) then
  Result := FTreeColumn.Values[RecordIndex]
 else
  Result := null; 
end;

function TIndTreeColumnViewInfo.GetValueInfo(const AFieldName: string;
  var AExists: boolean): variant;
var s:string;
    i:integer;
begin
 if Assigned(FTreeColumn) and (RecordIndex >= 0) then
 begin
  s := IndUpper(AFieldName);
  if s = FieldNameUp then
   Result := FieldValue
  else begin
    AExists := False;
    Result := null;
    for i := 0 to TcxDBTreeList(FTreeColumn.TreeList).ColumnCount - 1 do
    begin
     if IndUpper(TcxDBTreeList(FTreeColumn.TreeList).Columns[i].DataBinding.FieldName) = s then
     begin
      AExists := True;
      Result := TcxDBTreeList(FTreeColumn.TreeList).Columns[i].Values[RecordIndex];
      break;
     end;
    end;
  end;
 end
 else begin
  AExists := False;
  Result := null;
 end;
end;

procedure TIndTreeColumnViewInfo.SetRecordIndex(const Value: integer);
begin
  FRecordIndex := Value;
end;

procedure TIndTreeColumnViewInfo.SetTreeColumn(
  const Value: TcxDBTreeListColumn);
var f:TIndField;
begin
  FTreeColumn := Value;
  if Assigned(FTreeColumn) then
  begin
   SetFieldName(FTreeColumn.DataBinding.FieldName);
   if Assigned(FTreeColumn.DataBinding.Field) then
   begin
     f := TIndField(FTreeColumn.DataBinding.Field.Tag);
     SetTable(f.Table);
     SetField(f);
   end
   else
    SetTable(nil);
    SetField(nil);
  end
  else begin
   SetFieldName('');
   SetTable(nil);
   SetField(nil);
  end;
end;

procedure TIndBaseTreeView.DummiNotEnabledGetDisplayText(
  Sender: TcxTreeListColumn; ANode: TcxTreeListNode; var Value: String);
begin

end;

procedure TIndBaseTreeView.DummiNotVisibleGetDisplayText(
  Sender: TcxTreeListColumn; ANode: TcxTreeListNode; var Value: String);
begin

end;

procedure TIndBaseTreeView.DoDragOther(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  //Еще узел тащим
  Accept := False;
  if Assigned(FDraggedNode) and (Source = Grid) and (Sender = Grid)
    and Assigned(Table.Table)
    and (Table.Table.CanEdit) then
  begin

    Accept := True;
  end;
end;

{ TIndDBTreeList }

constructor TIndDBTreeList.Create(AOwner: TComponent);
begin
  inherited;
  OptionsData.Deleting := False;
  OptionsData.Inserting := False;
//  OptionsData.Editing := False;
//  OptionsData.CancelOnExit := False;


  OptionsView.ShowEditButtons := ecsbNever; //ecsbFocused;
//  OptionsBehavior.ImmediateEditor := False;
  OnEdited := DoOnTreeListEdited;
  OnFocusedNodeChanged := DoOnChangeRecord;
  OnFocusedColumnChanged := DoFocusColumn;
  FButtonProperties := TIndTreeListButtonProperties.Create(Self);
end;

procedure TIndDBTreeList.DoMoveTo(AttachNode: TcxTreeListNode;
  AttachMode: TcxTreeListNodeAttachMode; ANodes: TList; IsCopy: Boolean);
begin

  inherited;

end;


procedure TIndBaseTreeView.TreeEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  FDraggedNode := nil;
end;

procedure TIndBaseTreeView.TreeMoveTo(Sender: TObject;
  AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode;
  Nodes: TList; var IsCopy, Done: Boolean);
var
  NodeTo: TcxTreeListNode;
begin
  //Конец переноса... Update и Присоединение узла
  Done := True;
  if Assigned(FDraggedNode)  then
  begin
   if (not Assigned(Table.Table)) then exit;
   if (not Table.Table.CanEdit) then exit;
   NodeTo := AttachNode;
   if Assigned(NodeTo)
      and (NodeTo <> FDraggedNode)
      and (not NodeTo.HasAsParent(FDraggedNode))
      and (NodeTo <> FDraggedNode.Parent)
      and (TcxTreeListDataNode(FDraggedNode).ParentValue <> TcxTreeListDataNode(NodeTo).KeyValue)
   then  begin
     Table.Table.Edit;
     try
      Table.Table.Data.FieldByName('IDPARENT').Value := TcxTreeListDataNode(NodeTo).KeyValue;
      Table.Table.Save;
     except
       Table.Table.Cancel;
       raise;
     end;
   end;
  end;
end;

procedure TIndBaseTreeView.TreeStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  if Assigned(Grid) and Grid.HitTest.HitAtNode then
    FDraggedNode := Grid.HitTest.HitNode
  else
    FDraggedNode := nil;
end;

procedure TIndBaseTreeView.TreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var NodeTo: TcxTreeListNode;
begin
  if not Assigned(Grid) then exit;
  if (not Assigned(Table.Table)) then exit;
  if (not Table.Table.CanEdit) then exit;
  NodeTo := Grid.GetNodeAt(X,Y);
  if (not Assigned(NodeTo)) and Assigned(FDraggedNode) then
  begin
     //Присоединяем к корневому узлу
     if not IsNullId(Table.Table.Data.FieldByName('IDPARENT').Value) then
     begin
       Table.Table.Edit;
       try
        Table.Table.Data.FieldByName('IDPARENT').Value := null;
        Table.Table.Save;
       except
         Table.Table.Cancel;
         raise;
       end;
     end;
  end;
end;

procedure TIndDBTreeList.DoOnChangeRecord(Sender: TObject;
  APrevFocusedNode, AFocusedNode: TcxTreeListNode);
var I:integer;
begin
  if IsLoading then Exit;
  if  OptionsView.ShowEditButtons <> ecsbFocused then
  begin
    if not Assigned(APrevFocusedNode) then
    begin
      for I := 0 to ColumnCount - 1 do
        FButtonProperties.HideAllButtons(Columns[I]);
    end; //Убрал Степа 10.12.2008
    OptionsView.ShowEditButtons := ecsbFocused;
  end;
  FButtonProperties.ShowBrowseButton(FocusedColumn);
end;

procedure TIndDBTreeList.DoOnTreeListEdited(Sender: TObject;
  AColumn: TcxTreeListColumn);
begin
  if IsLoading then Exit;
  FButtonProperties.BeginBtUpdate(AColumn);
  try
    FButtonProperties.HideEditButton(AColumn);
    FButtonProperties.ShowBrowseButton(AColumn);
  finally
    FButtonProperties.EndBtUpdate(AColumn);
  end;
end;

procedure TIndDBTreeList.DoFocusColumn(Sender: TObject; APrevFocusedColumn,
  AFocusedColumn: TcxTreeListColumn);
begin
  if IsLoading then Exit;
  if Assigned(APrevFocusedColumn) then
    FButtonProperties.HideAllButtons(APrevFocusedColumn);
  FButtonProperties.ShowBrowseButton(AFocusedColumn);
end;

function TIndDBTreeList.GetControllerClass: TcxCustomControlControllerClass;
begin
  Result := TIndCxTreeListController;
end;

function TIndDBTreeList.GetIndObject(AObject: Tpersistent): TObject;
begin
  Result := FindTree.GetIndObject(AObject);

end;

function TIndDBTreeList.GetNativeObject(AObject: Tpersistent): TObject;
begin
  if AObject is TIndTreeColumn then
    Result := TIndTreeColumn(AObject).FColumn
  else if AObject is TIndTreeBand then
    Result := TIndTreeBand(AObject).FBand
  else
    Result := AObject;

end;

function TIndDBTreeList.IsNativeObject(AObject: TPersistent): boolean;
begin
  Result := not ((AObject is TIndTreeColumn) or (AObject is TIndTreeBand));
end;

procedure TIndDBTreeList.RepaintControl(AObject: TPersistent);
begin
   BeginUpdate;
   EndUpdate;
end;

{procedure TIndDBTreeList.ShowBrowseButton(
  AColumn: TcxTreeListColumn);
begin
  if CanShowBrowseButton(AColumn) then
  begin
    AColumn.Properties.BeginUpdate;
    TIndTreeColumn(AColumn.Tag).ButtonView := TcxEditButton(AColumn.Properties.Buttons.Add);
    MakeButtonGlyph(TIndTreeColumn(AColumn.Tag).ButtonView,cIndButtonImageView);
    AColumn.Properties.EndUpdate;
    AColumn.Options.ShowEditButtons := eisbDefault;
  end;
end;

function TIndDBTreeList.CanShowBrowseButton(AColumn:TcxTreeListColumn): boolean;
begin
  Result := Assigned(AColumn) and Assigned(AColumn.Properties) and Assigned(TIndTreeColumn(AColumn.Tag).Field) and
            (TIndTreeColumn(AColumn.Tag).Field.FieldMetadata.DataType in [dtRefObj,dtObj]);
end;     }

procedure TIndDBTreeList.DoAfterEditingTree;
begin
  if IsLoading then Exit;
  FButtonProperties.BeginBtUpdate(FocusedColumn);
  try
    FButtonProperties.HideBrowseButton(FocusedColumn);
    FButtonProperties.ShowEditButton(FocusedColumn);
  finally
    FButtonProperties.EndBtUpdate(FocusedColumn);
  end;
end;

{procedure TIndDBTreeList.HideBrowseButton(AColumn: TcxTreeListColumn);
begin
  if CanShowBrowseButton(AColumn) and Assigned(TIndTreeColumn(AColumn.Tag).ButtonView) then
  begin
    AColumn.Properties.BeginUpdate;
    AColumn.Properties.Buttons.Delete(TIndTreeColumn(AColumn.Tag).ButtonView.Index);
    TIndTreeColumn(AColumn.Tag).ButtonView := nil;
    AColumn.Properties.EndUpdate;
  end;
end;

procedure TIndDBTreeList.ToggleEditButtonsState(AColumn:TcxTreeListColumn;Visible: boolean);
var I:integer;
begin
  for I := 0 to AColumn.Properties.Buttons.Count - 1 do
    AColumn.Properties.Buttons[I].Visible := Visible;
end;

procedure TIndDBTreeList.ShowEditButton(AColumn: TcxTreeListColumn);
begin
  if Assigned(AColumn) and Assigned(AColumn.Properties) then
  begin
    AColumn.Properties.BeginUpdate;
    ToggleEditButtonsState(AColumn,True);
    AColumn.Properties.EndUpdate;
  end;
end;

procedure TIndDBTreeList.HideEditButton(AColumn: TcxTreeListColumn);
begin
  if Assigned(AColumn) and Assigned(AColumn.Properties) then
  begin
    AColumn.Properties.BeginUpdate;
    ToggleEditButtonsState(AColumn,False);
    AColumn.Properties.EndUpdate;
  end;
end;

procedure TIndDBTreeList.HideAllButtons(AColumn: TcxTreeListColumn);
begin
  HideBrowseButton(AColumn);
  HideEditButton(AColumn);
end; }

function TIndDBTreeList.IsLoading: boolean;
begin
  Result := (csLoading in IndTree.ComponentState) or
            (csDestroying in IndTree.ComponentState); 
end;

{ TIndTreeSaver }

function TIndTreeSaver.GetTree: TIndTree;
begin
  Result := TIndTree(SavedComponent);
end;

procedure TIndTreeSaver.LoadComponentsFromStorage;
var ItemIndex:integer;
begin
  inherited;
  if not Assigned(Storage) then Exit;
  for ItemIndex := 0 to Tree.View.Columns.Count - 1 do
     LoadComponent(Tree.View.Columns[ItemIndex].FColumnSaver);
end;

procedure TIndTreeSaver.SaveComponentsToStorage;
var ItemIndex:integer;
begin
  inherited;
  if not Assigned(Storage) then Exit;
  for ItemIndex := 0 to Tree.View.Columns.Count - 1 do
     SaveComponent(Tree.View.Columns[ItemIndex].FColumnSaver);
end;

procedure TIndTree.Loaded;
begin
  inherited;
//  FTreeSaver.LoadComponentsFromStorage;
end;

{ TIndTreeColumnSaver }

{function TIndTreeColumnSaver.GetPathToStoredObject: string;
begin
  Result := TIndTreeColumn(SavedPersistent).View.IndGrid.Name;
  Result := GetPathToComponent(TIndTreeColumn(SavedPersistent).View.IndGrid,ComponentStorager)+'\' + Result;
end;}

function TIndTreeColumnSaver.GetPersistentStorager: TComponent;
begin
  Result := TIndTreeColumn(SavedPersistent).View.IndGrid.Owner;
end;

function TIndTreeColumnSaver.GetSaveOwner: TComponent;
begin
  Result := TIndTreeColumn(SavedPersistent).View.IndGrid.Owner;
end;

procedure TIndTreeColumnSaver.GetStorageProperties(const AValue: {TStringList}TIndStorePropertiesList);
begin
  AValue.Clear;
  if Assigned(SavedPersistent) then
  begin
    AValue.Properties['Index'].Value := IntToStr(TIndTreeColumn(SavedPersistent).Position.ColIndex);
    AValue.Properties['Width'].Value := IntToStr(TIndTreeColumn(SavedPersistent).Width);
    AValue.Properties['Width'].WriteScreenSize := True;
    AValue.Properties['LineCount'].Value := IntToStr(TIndTreeColumn(SavedPersistent).GridColumn.Position.LineCount);
    AValue.Properties['BandIndex'].Value := IntToStr(TIndTreeColumn(SavedPersistent).GridColumn.Position.BandIndex);
    AValue.Properties['RowIndex'].Value := IntToStr(TIndTreeColumn(SavedPersistent).GridColumn.Position.RowIndex);
  end;
end;

procedure TIndTreeColumnSaver.SetStorageProperties(
  const AValue: {TStringList}TIndStorePropertiesList);
begin
  inherited;
  TIndTreeColumn(SavedPersistent).Position.ColIndex := StrToIntDef(AValue.Properties['Index'].Value,TIndTreeColumn(SavedPersistent).Position.ColIndex);
  TIndTreeColumn(SavedPersistent).Width := StrToIntDef(AValue.Properties['Width'].Value,TIndTreeColumn(SavedPersistent).Width);
  TIndTreeColumn(SavedPersistent).GridColumn.Position.LineCount := StrToIntDef(AValue.Properties['LineCount'].Value,TIndTreeColumn(SavedPersistent).GridColumn.Position.LineCount);
  TIndTreeColumn(SavedPersistent).GridColumn.Position.BandIndex := StrToIntDef(AValue.Properties['BandIndex'].Value,TIndTreeColumn(SavedPersistent).GridColumn.Position.BandIndex);
  TIndTreeColumn(SavedPersistent).GridColumn.Position.RowIndex := StrToIntDef(AValue.Properties['RowIndex'].Value,TIndTreeColumn(SavedPersistent).GridColumn.Position.RowIndex);
end;


function TIndTreeColumnSaver.GetStoreObjectName: string;
begin
  Result := TIndTreeColumn(SavedPersistent).Name;
end;


function TIndTreeChecker.GetTableRef(AComponent: TComponent): TIndTableRef;
begin
  Result := TIndTree(AComponent).Table;
end;

procedure TIndTreeChecker.SetCanSorting;
begin
  if Assigned(IndComponent) then
  begin
 //   if CanSorting then
      EnableColumnsSorting
 //   else
 //     EnableSortingRecno;
  end;
end;

procedure TIndTreeChecker.UpdateOptions;
begin
   SetCanSorting;
end;

{function TIndTreeChecker.HasRecnoField(RecnoField: TField): boolean;
var I:integer;
begin
  Result := False;
  if not Assigned(RecnoField) then Exit;
  for I := 0 to TIndTree(IndComponent).View.Columns.Count - 1 do
  begin
     if Assigned(TIndTree(IndComponent).View.Columns[I].Field) and
        Assigned(TIndTree(IndComponent).View.Columns[I].Field.Field) and
        (TIndTree(IndComponent).View.Columns[I].Field.Field.Field = RecnoField) then
            Result := True;
  end;
end;    }

procedure TIndTreeChecker.EnableColumnsSorting;
var ColIndex:integer;
begin
  for ColIndex := 0 to TIndTree(IndComponent).View.Columns.Count - 1 do
    TIndTree(IndComponent).View.Columns[ColIndex].FColumn.Options.Sorting := True;
  EnableSortingRecno;  
end;

procedure TIndTreeChecker.EnableSortingRecno;
var ColIndex:integer;
begin
  for ColIndex := 0 to TIndTree(IndComponent).View.Columns.Count - 1 do
  begin
     if Assigned(TIndTree(IndComponent).View.Columns[ColIndex].Field) and
        Assigned(TIndTree(IndComponent).View.Columns[ColIndex].Field.FieldMetadata) and
        (TIndTree(IndComponent).View.Columns[ColIndex].Field.FieldMetadata.DataType = dtRecno) then
        TIndTree(IndComponent).View.Columns[ColIndex].FColumn.SortOrder := soAscending;
    // else
     //   TIndTree(IndComponent).View.Columns[ColIndex].FColumn.Options.Sorting := False;
  end;
end;

function TIndTree.GetSaver: TIndSaver;
begin
  Result := FTreeSaver;
end;

function TIndTree.GetIndObject(AObject: Tpersistent): TObject;
begin
  if AObject is TcxTreeListBand then
    Result := FindBand(TcxTreeListBand(AObject))
  else if AObject is TcxDBTreeListColumn then
    Result := FindColumn(TcxDBTreeListColumn(AObject))
  else
    Result := AObject;
end;

function TIndTree.FindBand(ABand: TcxTreeListBand): TIndTreeBand;
var BandIndex:integer;
begin
  Result := nil;
  for BandIndex := 0 to View.Bands.Count - 1 do
  begin
    if View.Bands[BandIndex].FBand = ABand then
    begin
      Result := View.Bands[BandIndex];
      Break;
    end;
  end;
end;

function TIndTree.FindColumn(AColumn: TcxDBTreeListColumn): TIndTreeColumn;
var ColIndex:integer;
begin
  Result := nil;
  for ColIndex := 0 to View.Columns.Count - 1 do
  begin
    if View.Columns[ColIndex].FColumn = AColumn then
    begin
       Result := View.Columns[ColIndex];
       Break;
    end;
  end;
end;

{ TIndcxTreeListController }

procedure TIndcxTreeListController.DoMouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if HitTestController.HitTestItem is TcxTreeListEditCellViewInfo and
     (TcxTreeListEditCellViewInfo(HitTestController.HitTestItem).EditViewInfo.SelectedButton = 0)  then
  begin
     TIndDBTreeList(TreeList).IndTree.View.DoOnClickViewButton
  end
  else
   inherited;
end;

procedure TIndBaseTreeView.DoOnClickViewButton;
begin
  IndGrid.FindColumn(TcxDBTreeListColumn(Grid.FocusedColumn)).DoButtonViewClick(Grid);
end;

procedure TIndBaseTreeView.DoAfterEditingTree;
begin
  TIndDBTreeList(Grid).DoAfterEditingTree;
end;

{procedure TIndTreeColumn.SetButtonView(const Value: TcxEditButton);
begin
  if FButtonView <> Value then
    FButtonView := Value;

end;}


{ TIndTreeListButtonProperties }

{function TIndTreeListButtonProperties.Column(
  AButtonParent: TPersistent): TcxTreeListColumn;
begin
  Result := TcxTreeListColumn(AButtonParent);
end;}

{function TIndTreeListButtonProperties.GetButtonBrowse(AButtonParent:TPersistent): TcxEditButton;
begin
  Result := TIndTreeColumn(TcxTreeListColumn(AButtonParent).Tag).ButtonView
end;}

function TIndTreeListButtonProperties.GetField(AButtonParent:TPersistent): TIndFieldRef;
begin
  Result := TIndTreeColumn(TcxTreeListColumn(AButtonParent).Tag).Field;
end;

{procedure TIndTreeListButtonProperties.HideBrowseButton(
  AButtonParent: TPersistent);
begin
  if CanShowBrowseButton(Column(AButtonParent)) and Assigned(TIndTreeColumn(Column(AButtonParent).Tag).ButtonView) then
  begin
    Column(AButtonParent).Properties.BeginUpdate;
    Column(AButtonParent).Properties.Buttons.Delete(TIndTreeColumn(Column(AButtonParent).Tag).ButtonView.Index);
    TIndTreeColumn(Column(AButtonParent).Tag).ButtonView := nil;
    Column(AButtonParent).Properties.EndUpdate;
  end;
end;}

{procedure TIndTreeListButtonProperties.HideEditButton(
  AButtonParent: TPersistent);
begin
  if Assigned(AButtonParent) and Assigned(Column(AButtonParent).Properties) then
  begin
    Column(AButtonParent).Properties.BeginUpdate;
    ToggleEditButtonsState(Column(AButtonParent),False);
    Column(AButtonParent).Properties.EndUpdate;
  end;

end;               }

function TIndTreeListButtonProperties.GetIndFieldEditorItem(
  AButtonParent: TPersistent): TPersistent;
begin
  Result := TIndTreeColumn(TcxTreeListColumn(AButtonParent).Tag);
end;

function TIndTreeListButtonProperties.IsEditing(
  AButtonParent: TPersistent): boolean;
begin
  Result := TcxTreeListColumn(AButtonParent).TreeList.IsEditing;
end;

function TIndTreeListButtonProperties.Properties(AButtonParent:TPersistent): TcxCustomEditProperties;
begin
  Result := TcxTreeListColumn(AButtonParent).Properties;
end;

{procedure TIndTreeListButtonProperties.SetButtonBrowse(AButtonParent:TPersistent;
  AButton:TcxEditButton);
begin
  inherited;
  TIndTreeColumn(TcxTreeListColumn(AButtonParent).Tag).ButtonView := AButton;
end;}

{procedure TIndTreeListButtonProperties.ShowBrowseButton(
  AButtonParent: TPersistent);
begin
  if CanShowBrowseButton(AButtonParent) then
  begin
    Column(AButtonParent).Properties.BeginUpdate;
    TIndTreeColumn(Column(AButtonParent).Tag).ButtonView := TcxEditButton(Column(AButtonParent).Properties.Buttons.Add);
    MakeButtonGlyph(TIndTreeColumn(Column(AButtonParent).Tag).ButtonView,cIndButtonImageView);
    Column(AButtonParent).Properties.EndUpdate;
    Column(AButtonParent).Options.ShowEditButtons := eisbDefault;
  end;

end; }

{procedure TIndTreeListButtonProperties.ShowEditButton(
  AButtonParent: TPersistent);
begin
  if Assigned(Column(AButtonParent)) and Assigned(Column(AButtonParent).Properties) then
  begin
    Column(AButtonParent).Properties.BeginUpdate;
    ToggleEditButtonsState(Column(AButtonParent),True);
    Column(AButtonParent).Properties.EndUpdate;
  end;
end;}


{function TIndTree.GetField: TIndFieldRef;
begin
   Result := nil;
end;

procedure TIndTree.SetField(const Value: TIndFieldRef);
begin

end;}

function TIndTree.GetIndTable: TIndMetadataTable;
begin
  Result := Table.Table;
end;

function TIndTree.GetOptionsView: TcxTreeListOptionsView;
begin
  Result := FGrid.OptionsView;
end;

function TIndTree.GetOptionsSelection: TcxTreeListOptionsSelection;
begin
  Result := FGrid.OptionsSelection;
end;

procedure TIndTree.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
  FGrid.OnChange := Value;
end;

function TIndTree.GetSelectionCount: integer;
begin
  Result := FGrid.SelectionCount;
end;

function TIndTree.GetNodes: TcxTreeListNodes;
begin
  Result := Fgrid.Nodes;
end;


procedure TIndTree.ResizeChanged(var Message: TWMSize);
begin
  //FGrid.Align := alNone;
  //FGrid.Align := alClient;
  FGrid.SetBounds(BorderWidth, BorderWidth, Width - 2*BorderWidth, Height - 2*BorderWidth);
end;

end.
