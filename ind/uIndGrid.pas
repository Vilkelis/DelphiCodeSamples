unit uIndGrid;

interface
uses  uIndList, dxBar, Variants, Messages, Windows, Forms, ActnList, ExtCtrls, RTLConsts, DB,
      SysUtils,
      Classes,
      Controls,
      Graphics,
      Math,
      Menus,
      cxGridDBDataDefinitions,
      cxGridLevel,
      cxGraphics,
      cxGridCustomView,
      cxGridCustomTableView,
      cxGridTableView,
      cxGridBandedTableView,
      cxGridDBBandedTableView,
      cxGridDBCardView,
      cxGridDBTableView,
      cxGrid,
      cxGridCommon,
      cxGridRows,
      cxFilter,
      cxEdit,
      cxTextEdit,cxButtonEdit,cxMaskEdit,
      cxLabel,
      Types,
      uIndActionsConstants,
      uCommonClasses,
      uIndDataCommonClasses,
      uIndDataConstant,
      uIndFormManager,
      uIndManagers,
      uIndActions,
      uIndTables, RvDesignU, uDBAStringsE, dmuLanguages, smDialogs,
      uIndWindowBodies,
      uIndDataLanguage,
      uIndTablesMetadata,
      uIndConfiguration,
      stdCtrls,
      uIndChecker,
      cxCustomData,
      contnrs,
      cxGridCustomPopupMenu,
      cxGridPopupMenu,
      cxGridStdPopupMenu,
      cxGridMenuOperations,
      cxGridHeaderPopupMenuItems,
      uMessages,
      uIndButtonProperties
      ;


const
  NavigatorOffset = 12;
  cxBorderSize = 2;
  cIndUseFooter = 1;
  cIndNotUseFooter = 0;
  cIndUserBuiltInMenu = 6;
  cIndUserBuiltInMenuAlwaysExpand = 3;
  cIndUserBuiltInMenuClosedGroup = 4;
  cIndUserBuiltInMenuOnlySelected = 5;
  cIndUserGroupOptions = 7;

type





TIndBaseView = class;
TIndGridBand = class;

TIndBandPosition = class (TPersistent)
private
  FOnChange: TNotifyEvent;
  FBand: TIndGridBand;
  procedure SetBandIndex(Value: integer); //modified
  procedure SetColIndex(const Value: integer); //modified
  function GetBandIndex: Integer;   //modified
  function GetColIndex: Integer;   //modified
  procedure Changed; //?
  function GetGridView: TIndBaseView;
public
  constructor Create(ABand:TIndGridBand);
  procedure Assign(Source: TPersistent); override;
  property OnChange:TNotifyEvent read FOnChange write FOnChange;
  property View:TIndBaseView read GetGridView;
  property Band:TIndGridBand read Fband;
published
 property BandIndex:integer read GetBandIndex write SetBandIndex default -1;
 property ColIndex:integer read GetColIndex write SetColIndex default -1;
end;

TIndGridColumn = class;

TIndColumnPosition = class(TPersistent)
private
  FItem:TIndGridColumn;
  procedure SetColIndex(const Value: integer);virtual; //modified
  function GetGridView: TIndBaseView;
  function GetColIndex: integer;virtual;
public
  constructor Create(ACol:TIndGridColumn);virtual;
  procedure Assign(Source: TPersistent); override;
  property Item:TIndGridColumn read FItem;
  property View:TIndBaseView read GetGridView;
published
  property ColIndex:integer read GetColIndex write SetColIndex;
end;

TIndBandedColumnPosition = class (TIndColumnPosition)
private
  FBand:TIndGridBand;
  //индексы столбцов нельзя устанавливать до окончания загрузки ВСЕХ столбцов
  //грида. Столбцы грида - это элементы коллекции и загружаются они в том же
  //порядке, в котором находятся в коллекции. (Рассматриваем режим Design-time!)
  //Например: (ColIndex - индекс в гриде, Index - индекс в коллекции) 
  // допустим, количество загруженных столбцов = 1 (ColIndex = 2, Index = 0)
  // а мы загружаем столбец (ColIndex = 5, Index = 1)
  // соответственно имеем на этом шаге (в скобках тот индекс который в итоге должен быть у столбца, т.е. правильный):
  // Index   ColIndex
  //   0        0  (2)
  //   1        1  (5)
  // Теперь выставляем еще один столбец (ColIndex = 3, Index = 2)
  // В итоге имеем следующее
  // Index   ColIndex
  //   0        0  (2)
  //   1        1  (5)
  //   2        2  (3)
  //В РЕЗУЛЬТАТЕ ИМЕЕМ ЧТО СТОЛБЕЦ C ColIndex 5 оказывается выше столбца с индексом 3
  //- неправильное восстановление позиции в Design-time режиме
  //чтобы избежать такого результата вводим переменную FStoredColIndex
  FStoredColIndex:integer;
  procedure SetBandIndex(const Value: integer); //modified
  procedure SetColIndex(const Value: integer);override; //modified
  procedure SetRowIndex(const Value: integer); //modified
  function GetbandIndex: integer; //modified
  function GetColIndex: integer;override; //modified
  function GetRowIndex: integer; //modified
public
  procedure Assign(Source: TPersistent); override;
  property Band:TIndGridBand read FBand;

  property StoredColIndex:integer read FStoredColIndex write FStoredColIndex;
published
  property BandIndex:integer read GetbandIndex write SetBandIndex;
  property ColIndex:integer read GetColIndex write SetColIndex;
  property RowIndex:integer read GetRowIndex write SetRowIndex;
end;

TIndGrid  = class;

TIndGridStructureNavigator = class (TcxCustomGridStructureNavigator)
private
  function FindIndObj(AObj: TPersistent): TIndNamedItem;
  function GetIndGrid: TIndGrid;
  function GetWindowDesigner:TWindowDesigner;

protected
  function CalculateBoundsRect: TRect; override;
public
  procedure GetSelection(AList:TIndList);
  procedure SetSelection(AList:TIndList);
  function IsObjectSelected(AObject: TPersistent): Boolean; override;
  procedure SelectObject(AObject: TPersistent; AClearSelection: Boolean); override;
  procedure UnselectObject(AObject: TPersistent); override;
  property Designer:TWindowDesigner read GetWindowDesigner;
end;


TIndFieldItem = class (TIndNamedItem,IInterface, IIndVisualControl)
private
 FField:TIndFieldRef;
 FOwnerInterface: IInterface;
 FControl:TObject;
 procedure SetField(Value:TIndFieldRef);
 procedure SetControl(const Value: TObject);
 function GetControl: TObject;

protected

  { IInterface }
  function _AddRef: Integer; stdcall;
  function _Release: Integer; stdcall;

   {IIndVisualControl}
   function IndFocused:boolean; virtual;
   procedure IndSetFocus; virtual;
   function IndCanFocus:boolean; virtual;
   procedure IndSetEnable(const AValue:boolean); virtual;
   function IndGetEnable:boolean; virtual;
   procedure IndSetVisible(const AValue:boolean); virtual;
   function IndGetVisible:boolean; virtual;

 procedure FieldChanged(Sender:TObject); virtual;
 procedure FieldMetadataChanged(Sender:TObject); virtual;
 function GetDataSet: TIndBaseDataSet; virtual;
 function GetTable: TIndMetadataTable; virtual;
 procedure SetCollection(Value: TCollection); override;
 property DataSet:TIndBaseDataSet read GetDataSet;
 property Table:TIndMetadataTable read GetTable;
public
  function GetStoredIndex:integer;virtual;
  procedure SetRealIndex(const Value:integer);virtual;
  function GetChildCount: integer;virtual;
  function GetChildren(Index: integer): TIndFieldItem;virtual;

 function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
 procedure AfterConstruction; override;

 constructor Create(Collection: TCollection); override;
 destructor Destroy; override;

 property Field:TIndFieldRef read FField write SetField;
 property Control:TObject read GetControl write SetControl;
end;


//Объект, который имеет поле и заголовок
TIndFieldItemCaption = class (TIndFieldItem)
private
 FUseFieldCaption: boolean;
 FCaption: string;
 procedure SetCaption(const Value: string);
 procedure SetUseFieldCaption(const Value: boolean);
protected
 class function DefaultUseFieldCaption:boolean; virtual;
 procedure FieldChanged(Sender:TObject); override;
 procedure FieldMetadataChanged(Sender:TObject); override;
 procedure UpdateObjectCaption; virtual; //Обновление Caption в объекте (необходимо перекрыть в наследнике)
 function GetFieldCaption:string; virtual;

 procedure SetCollection(Value: TCollection); override;
public
 property UseFieldCaption:boolean read FUseFieldCaption write SetUseFieldCaption default False;
 property Caption:string read FCaption write SetCaption;
 property Field;
 property Name;
end;

TIndFieldItemCollection = class (TIndNamedCollection)
private
 FTable:TIndTableRef;
 FOnTableChanged: TNotifyEvent;
protected
 function GetDataSet: TIndBaseDataSet; virtual;
 function GetTable: TIndTableRef; virtual;
 procedure SetDataSet(const Value: TIndBaseDataSet); virtual;
 procedure SetTable(const Value: TIndTableRef); virtual;


 property DataSet:TIndBaseDataSet read GetDataSet write SetDataSet;
 property Table:TIndTableRef read GetTable write SetTable;
 property OnTableChanged:TNotifyEvent read FOnTableChanged write FOnTableChanged;
public
 constructor Create(AOwner: TPersistent; ATable:TIndTableRef; ItemClass: TCollectionItemClass); virtual;
end;

{Базовый класс для полей гридов, деревьев и т.д.
 поддерживает строчные редакторы в зависимости от метаданных}

//TIndEditorVisible = (ievVisible, ievInvisible);

TIndButton = class(TPersistent)
private
  FInEditorVisible: boolean;
  FcxButton: TcxEditButton;
  procedure SetcxButton(const Value: TcxEditButton);
public
  property InEditorVisible:boolean read FInEditorVisible;
  property cxButton:TcxEditButton read FcxButton write SetcxButton;
end;


TIndFieldEditorItem = class (TIndFieldItemCaption, IFormManagerNotify)
private
 FButtonSelect:TcxEditButton;
 FButtonView:TcxEditButton;
 FButtonClear:TcxEditButton;
 FButtonType:TcxEditButton;

 //оболочки нативных кнопок для хранения статического состояния их видимости
 //(поскольку при переходе из режима просмотра в редактирование их нативная видимость меняется)
 FIndButtonSelect:TIndButton;
 FIndButtonView:TIndButton;
 FIndButtonClear:TIndButton;
 FIndButtonType:TIndButton;
 FIndButtonBrowse:TIndButton;

 FFieldId:TIndField;
 FFieldFullName:TIndField;
 FFieldTypeId:TIndField;
 FFieldTypeName:TIndField;
 FFieldVisualRepresentation:TIndField;

 FBrowseFormManager:TIndBrowseFormManager;
 FEditFormManager:TIndEditFormManager;
 FCurrentSelectControl:TComponent;


 procedure SetFieldFullName(const Value: TIndField);
 procedure SetFieldId(const Value: TIndField);
 procedure SetFieldTypeId(const Value: TIndField);
 procedure SetFieldTypeName(const Value: TIndField);
 procedure SetFieldVisualRepresentation(const Value: TIndField);

 procedure SetBrowseFormManager(const Value: TIndBrowseFormManager);
 procedure SetEditFormManager(const Value: TIndEditFormManager);



protected
 {Это перекрывать обязательно}
 procedure SetDataBindingProperty(const AFieldName:string); virtual;
 function FieldEditor:TComponent; virtual; //Возвращает компонент -редактор (например в случае грида TcxDbGridColumn)
 function CanShowEditors:boolean; virtual;
 procedure SetIsEditor; virtual;
 procedure SetNotEditor; virtual;

 function GetEditValue: Variant;virtual;
 procedure SetEditValue(const Value: Variant);virtual;

 procedure SetFieldEditorProperties;

 //Определение полей FieldId, FieldFullName и т.д. по установленным метаданным
 procedure FieldChanged(Sender:TObject);override;
 procedure DecodeIndFields; virtual;
 //Работа с менеджерами форм
 function CanFindFormManagers:boolean; virtual;

 function FormManagerSelectValid:boolean; virtual;
 function FormManagerEditValid:boolean; virtual;

 procedure GetFormManagerSelect; virtual;
 procedure GetFormManagerView; virtual;
 procedure GetFormManagerObjView; virtual;

 procedure ShowWarning(const aText:string); virtual;

 procedure DoIndButtonClick(Sender: TObject;AButtonIndex: Integer); virtual;

 procedure DoButtonSelectClick(const SelectControl:TWinControl); virtual;
 procedure DoButtonTypeClick(const SelectControl:TWinControl); virtual;
 procedure DoButtonViewClick(const SelectControl:TWinControl); virtual;
 procedure DoButtonClearClick(const SelectControl:TWinControl); virtual;
 procedure DoSelectRecord(const ATable: TComponent; var ACloseForm: boolean); virtual; //Выполняется при выборе записи из справочника


 property FieldId:TIndField read FFieldId write SetFieldId;
 property FieldFullName:TIndField read FFieldFullName write SetFieldFullName;
 property FieldTypeId:TIndField read FFieldTypeId write SetFieldTypeId;
 property FieldVisualRepresentation:TIndField read FFieldVisualRepresentation write SetFieldVisualRepresentation;
 property FieldTypeName:TIndField read FFieldTypeName write SetFieldTypeName;

 property EditFormManager:TIndEditFormManager read FEditFormManager write SetEditFormManager;
 property BrowseFormManager:TIndBrowseFormManager read FBrowseFormManager write SetBrowseFormManager;

 {IFormManagerNotify}
 function FormManagerDeleteNotify(FormManager:TObject):boolean;

 procedure SetFieldEditorPropertiesClass(AClass:TcxCustomEditPropertiesClass); virtual;
 function GetFieldEditorProperties:TcxCustomEditProperties; virtual;

public

 function FindButton(AButton:TcxEditButton):TIndButton;
 function IsEditButton(AButton:TcxEditButton):boolean;
 procedure ShowBrowseButton;
 procedure HideBrowseButton;
 property EditValue:Variant read GetEditValue write SetEditValue;
 constructor Create(Collection: TCollection);override;
 destructor Destroy; override;
end;


TIndGridRecnoChecker = class(TIndRecnoChecker)
private
  function SupportTreeView: boolean;
  procedure SetSortOnRecno;
  procedure SetFilterOnParent;
  function FindRecnoCol:TIndGridColumn;
protected
  function GetTableRef(AComponent:TComponent):TIndTableRef;override;
  function HasRecnoField(RecnoField:TField):boolean;override;  
public
  procedure SetCanSorting;override;
  procedure SetCanMoving;override;
  procedure SetCanGrouping;override;
  procedure SetCanFiltering;override;
end;

TIndFooterSaver = class(TPersistent)
private
  FSavedColumn:TIndGridColumn;
  function DataSummaryItem(ASummaryItems:TcxDataSummaryItems):TcxDataSummaryItem;
protected
  procedure SetSummaryItemProperties(ASummaryItem:TcxDataSummaryItem;AStorage:TIndStorePropertiesList);virtual;
  function GetFooterUseValue:string;virtual;abstract;
  function GetFooterUseKind:string;virtual;abstract;  
  function GetSummaryItems:TcxDataSummaryItems;virtual;abstract;
  function GetSummaryItem:TcxDataSummaryItem;virtual;
  procedure SaveDefaultValuesToStorage(AStorage:TIndStorePropertiesList);virtual;
  procedure SaveValuesToStorage(AStorage:TIndStorePropertiesList;ASummaryItem:TcxDataSummaryItem);virtual;
public
  procedure LoadGridFooters(const AStorage: TIndStorePropertiesList);
  procedure SaveGridFooters(const AStorage: TIndStorePropertiesList);
  property SavedColumn:TIndGridColumn read FSavedColumn write FSavedColumn;
end;

TIndGridFooterSaver = class(TIndFooterSaver)
protected
  function GetFooterUseValue:string;override;
  function GetFooterUseKind:string;override;
  function GetSummaryItems:TcxDataSummaryItems;override;
end;

TIndDefaultGroupFooterSaver = class(TIndFooterSaver)
protected
  function GetFooterUseValue:string;override;
  function GetFooterUseKind:string;override;
  function GetSummaryItems:TcxDataSummaryItems;override;
end;

TIndGroupFooterSaver = class(TPersistent)
private
  FSavedColumn:TIndGridColumn;
  //сохранение столбцов, которые являются Link для SummaryGroup, содержащих
  //столбец сохраняемый данным классом
  procedure LoadLinkedColumns(AStorage:TIndStorePropertiesList);
  procedure SaveLinkedColumns(AStorage:TIndStorePropertiesList);
  //---------------------------------------------
  //наименование для ключа в реестре, содержащего количество столбцов - владельцов (сохраняемых SaveLinkedColumns)
  function GetLinkCountValue:string;virtual;
  procedure UpdateColumnsList(AStorage:TIndStorePropertiesList);
  function GetGrid:TIndGrid;
  function GetSummaryGroup(AColumn:TIndGridColumn):TcxDataSummaryGroup;
  function MakeColumnLink(AColumn:TIndGridColumn):TcxGridDBTableSummaryItem;
protected
  function GetSavedLinkName(AColumn:TIndGridColumn):string;virtual;
  //---------------------------------------------
  //непосредственно установка линкованных столбцов - владельцев
  procedure LoadGridFooters(const AStorage: TIndStorePropertiesList);
  procedure SaveGridFooters(const AStorage: TIndStorePropertiesList);
  //---------------------------------------------
  //наименования ключей для записи в реестре
  function GetFooterUseKind:string;
  //---------------------------------------------
  property Grid:TIndGrid read GetGrid;
public
  property SavedColumn:TIndGridColumn read FSavedColumn write FSavedColumn;

end;

TIndColumnSaver = class(TIndPersistentSaver)
private
  FIndGridFooterSaver:TIndGridFooterSaver;
  FIndGroupFooterSaver:TIndGroupFooterSaver;
  FIndDefaultGroupFooterSaver:TIndDefaultGroupFooterSaver;
  FPositionNotLoaded: Boolean;
  procedure LoadGridFooters(const AStorage: TIndStorePropertiesList{TStringList});
  procedure SaveGridFooters(const AStorage: TIndStorePropertiesList{TStringList});
  procedure DoSetSavedPersistent(Sender:Tobject);
  procedure UpdateColumnSaveProperties;
  procedure SaveExpandedData(const AStorage: TIndStorePropertiesList);
  procedure LoadExpandedData(const AStorage: TIndStorePropertiesList);
protected
  function GetStoreObjectName:string;override;
  procedure GetStorageProperties(const AValue:TIndStorePropertiesList{TStringList});override;
  procedure SetStorageProperties(const AValue:TIndStorePropertiesList{TStringList});override;
  function GetPersistentStorager:TComponent;override;
public

  constructor Create(AOwner:TComponent);override;
  destructor Destroy;override;
  function GetSaveOwner:TComponent;override;
  property PositionNotLoaded:Boolean read FPositionNotLoaded write FPositionNotLoaded;
end;

TIndColumnSummaryItem = class;

//провайдер Summary для DefaultGroupItems
TIndSummaryProvider = class(TPersistent)
private
   FOwnObj:TObject;
   function IsGroupedByColumn(AItem:TcxDataSummaryItem):boolean;
   function GetGrid:TIndGrid;
   function IndColumn:TIndGridColumn;
   function AssignedGridView:boolean;
   function IndexInSummaryItems(AObject:Tobject):integer;
   function GetSummary:TcxDataSummary;
   function CheckSummaryItemsVisible:boolean;
   function ColumnUseSummary:boolean;
   //получить Summary по объекту к которому он привязан
   function GetSummaryItem(AObject:TObject):TcxDataSummaryItem;
   procedure UpdateRelatedObject;

protected
   function GetIsGroupSummary:boolean;virtual;
   function GetRelatedObject:TIndColumnSummaryItem;virtual;
   function GetSummaryItems:TcxDataSummaryItems;virtual;
   procedure FreeNativeSummary(AObject:TObject);
   function GetIndex(AObject:TObject):integer;
   procedure SetVisibleSummary(AVisible:boolean);virtual;
public
   procedure UpdateSummaryItemsVisibility;
   function CreateSummary:TcxDataSummaryItem;
   procedure FreeSummary(AObject:TObject);
   function CreateColumnNativeSummary:TcxDataSummaryItem;
   property Grid:TIndGrid read GetGrid;
   property SummaryItems:TcxDataSummaryItems read GetSummaryItems;
end;

//провайдер Summary для Grid Footer
TIndSummaryFooterProvider = class(TIndSummaryProvider)
protected
   function GetSummaryItems:TcxDataSummaryItems;override;
   procedure SetVisibleSummary(AVisible:boolean);override;
   function GetRelatedObject:TIndColumnSummaryItem;override;
end;

//провайдер Summary для Column Group
TIndSummaryGroupProvider = class(TIndSummaryProvider)
private
   procedure UpdateLinkedColumns;
   function GetSummaryGroup:TcxDataSummaryGroup;
protected
   function GetIsGroupSummary:boolean;override;
   function GetRelatedObject:TIndColumnSummaryItem;override;
   function GetSummaryItems:TcxDataSummaryItems;override;
   procedure SetVisibleSummary(AVisible:boolean);override;   
end;

TIndSummaryProviderClass = class of TIndSummaryProvider;

TIndColumnSummaryItem = class(TPersistent)
private
  FColumn:TcxGridColumn;
  FNativeSummaryItem:TcxGridDBTableSummaryItem;
  FUseSummary: boolean;
  FSummaryProvider:TIndSummaryProvider;
  FPosition:TcxSummaryPosition;
  FKind:TcxSummaryKind;
  procedure UpdateNativeSummaryOptions(AItem:TcxGridDBTableSummaryItem);
  procedure UpdateSavedOptions(AItem:TcxGridDBTableSummaryItem);
  function CanGetProperties:boolean;
  function GetItemLink: TcxGridColumn;
  function GetKind: TcxSummaryKind;
  function GetPosition: TcxSummaryPosition;
  procedure SetItemLink(const Value: TcxGridColumn);
  procedure SetKind(const Value: TcxSummaryKind);
  procedure SetPosition(const Value: TcxSummaryPosition);
  procedure SetUseSummary(const Value: boolean);
  procedure AddSummary;
  procedure DropSummary;
protected
  function GetSummaryProviderClass:TIndSummaryProviderClass;virtual;
  property SummaryProvider:TIndSummaryProvider read FSummaryProvider;
public
  constructor Create(AColumn:TcxGridColumn);
  destructor Destroy;override;
  property Position:TcxSummaryPosition read GetPosition write SetPosition default spFooter;
  property Kind:TcxSummaryKind read GetKind write SetKind default skCount;
  property ItemLink:TcxGridColumn read GetItemLink write SetItemLink;
  property UseSummary:boolean read FUseSummary write SetUseSummary default False;
end;

TIndGridFooterItem = class(TIndColumnSummaryItem)
protected
  function GetSummaryProviderClass:TIndSummaryProviderClass;override;
published
  property Kind;
  property ItemLink;
  property UseSummary;
end;

TIndColumnGroupItem = class(TIndColumnSummaryItem)
protected
  function GetSummaryProviderClass:TIndSummaryProviderClass;override;
published
  property Position;
  property Kind;
  property ItemLink;
  property UseSummary; 
end;

TIndColumnSummaryOptions = class(TPersistent)
private
 FColumnSummary:TIndColumnGroupItem;
 FGridSummary:TIndGridFooterItem;
 FCol:TcxGridColumn;
 function Grid:TIndGrid;
 procedure DoCheckGroupingChanged(Sender:TObject);
 procedure UpdateSummaryVisibility;
// procedure UpdateSummaryKind;
public
 procedure Init;
 destructor Destroy;override;

published
 property GroupSummary:TIndColumnGroupItem read FColumnSummary write FColumnSummary;
 property TotalSummary:TIndGridFooterItem read FGridSummary write FGridSummary;
end;

TIndView = class;

TIndGridColumn = class (TIndFieldEditorItem)
private
 FCol:TcxCustomGridTableItem;
 FPosition: TIndBandedColumnPosition;
 FColumnSaver:TIndColumnSaver;
 FColumnSummaryOptions:TIndColumnSummaryOptions;
 FExpandSelected: boolean;
 FAlwaysClose: boolean;
 FAlwaysExpand: boolean;
 FStoredGroupIndex: integer;
// FButtonView: TcxEditButton;

 procedure CreateColumnPosition;
 procedure SetPosition(const Value: TIndBandedColumnPosition);
 function GetIsBottom: Boolean; //modified
 function GetGridView: TIndBaseView;
 function GetVisible: boolean;
 function GetPosition: TIndBandedColumnPosition;
 procedure SetVisible(const Value: boolean);
 procedure SetSize(const Value: integer);
 function GetSize: integer;
 function GetAlignment: TAlignment;
 procedure SetAlignment(const Value: TAlignment);
 function GetGroupIndex: integer;
 procedure SetGroupIndex(const Value: integer);

protected
 class function DefaultUseFieldCaption:boolean; override;
 procedure SetDataBindingProperty(const AFieldName:string); override;
 function FieldEditor:TComponent; override; //Возвращает компонент -редактор (например в случае грида TcxDbGridColumn)
 procedure UpdateObjectCaption; override; //Обновление Caption в объекте (необходимо перекрыть в наследнике)
 procedure SetFieldEditorPropertiesClass(AClass:TcxCustomEditPropertiesClass); override;
 function GetFieldEditorProperties:TcxCustomEditProperties; override;

 procedure CheckProperties(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);

 function CanShowEditors:boolean; override;
 procedure SetIsEditor; override;
 procedure SetNotEditor; override;

 class function BaseName:string; override;
// procedure SetCardColumnProperties(ACol:TcxGridDBCardViewRow); virtual;
 procedure CreateGridColumn;
 procedure FreeGridColumn;

 procedure CreateSummary;

 procedure SetCollection(Value:TCollection); override;
 procedure FieldChanged(Sender:TObject);override;

 function GetEditValue: Variant;override;
 procedure SetEditValue(const Value: Variant);override;

public
 {IIndVisualControl}
 function IndFocused:boolean; override;
 procedure IndSetFocus; override;
 function IndCanFocus:boolean; override;
 procedure IndSetEnable(const AValue:boolean); override;
 function IndGetEnable:boolean; override;
 procedure IndSetVisible(const AValue:boolean); override;
 function IndGetVisible:boolean; override;

 constructor Create(Collection:TCollection);override;
 destructor Destroy; override;

// procedure ExpandRecord(ID: Variant;Name:string);
 procedure ExpandAll;
 procedure UnExpandAll;

 property IsBottom:boolean read GetIsBottom;
 property View:TIndBaseView read GetGridView;
 property ColumnSaver:TIndColumnSaver read FColumnSaver;

 //roperty ButtonView:TcxEditButton read FButtonView write FButtonView;
published
 property StoredGroupIndex:integer read FStoredGroupIndex write FStoredGroupIndex stored False;
 property UseFieldCaption default True;
 property Caption;
 property Name;
 property Position:TIndbandedColumnPosition read GetPosition write SetPosition;
 property Width:integer read GetSize write SetSize;
 property Visible: boolean read GetVisible write SetVisible;
 property Field;
 property Alignment:TAlignment read GetAlignment write SetAlignment;
 property GroupIndex:integer read GetGroupIndex write SetGroupIndex;
 property ColumnSummaryOptions:TIndColumnSummaryOptions read FColumnSummaryOptions write FColumnSummaryOptions;


 property AlwaysExpand:boolean read FAlwaysExpand write FAlwaysExpand;
 property AlwaysClose:boolean read FAlwaysClose write FAlwaysClose;
 property ExpandSelected:boolean read FExpandSelected write FExpandSelected;
end;

TIndGridBand = class (TIndFieldItemCaption)
private
 FGridBand:TcxGridBand;
 FPosition: TIndBandPosition;
 procedure SetPosition(const Value: TIndBandPosition);
 procedure PositionChanged(Sender:TObject);
 function GetGridView: TIndBaseView;
 function GetIsBottom: Boolean;     //modified
 procedure SetWidth(const Value: integer);
 function GetWidth: integer;
 function GetGridBand: TcxGridBand; //modified
 procedure SetGridBand(const Value: TcxGridBand);
 function GetVisible: Boolean;
 procedure MoveBand(ABand: TIndGridBand; AColIndex: Integer);
 procedure SetVisible(Value: Boolean);

 function GetFixedKind: TcxGridBandFixedKind;
 procedure SetFixedKind(const Value: TcxGridBandFixedKind);

protected
 class function BaseName:string; override;
 procedure FieldChanged(Sender:TObject);override;
 procedure SetBandProperties(ABand:TcxGridBand);
 procedure UpdateBandProperties;
 procedure FreeBand;

 property Gridband:TcxGridband read FGridBand;
 procedure AddColumn(AColumn: TIndGridColumn);  //modified
 procedure RemoveColumn(AColumn: TIndGridColumn);   //modified
 procedure RemoveBand; //modified
 procedure MoveColumn(AColumn: TIndGridColumn; ARowIndex, AColIndex: Integer); //modified
 procedure CreateBand;

 procedure UpdateObjectCaption; override; //Обновление Caption в объекте (необходимо перекрыть в наследнике)
public
 procedure GetColumns(AList: TIndList);

 constructor Create(ACollection:TCollection); override;
 destructor Destroy; override;


 property IsBottom:Boolean read GetIsBottom;
 property ParentBand:TcxGridBand read GetGridBand write SetGridBand;
// property Columns:TList read GetColumns;
 property View:TIndBaseView read GetGridView;
published
 property Visible: Boolean read GetVisible write SetVisible default True;
 property Position:TIndBandPosition read FPosition write SetPosition;
 property Caption;
 property UseFieldCaption;
 property Name;
 property Field;
 property Width:integer read GetWidth write SetWidth;
 property FixedKind:TcxGridBandFixedKind read GetFixedKind write SetFixedKind;

end;

TIndGridBands = class (TIndFieldItemCollection)
private
 function GetItems(AIndex: integer): TIndGridBand;
 procedure SetItems(AIndex: integer; const Value: TIndGridBand);
 function GetView: TIndBaseView;

 function FindIndBand(FBand: TcxGridBand): TIndGridBand;
    function GetVisibleCount: Integer;
 //function FindIndColumn(AColumn: TcxGridColumn): TIndGridColumn;
protected
 procedure FreeBands;
 procedure Loaded;
public
 procedure GetBottomItemsList(AList:TIndList);

 function FindIndBandByName(FName:string): TIndGridBand;
 constructor Create(AOwner: TIndBaseView);
 destructor Destroy;override;
 procedure Notify(Item: TCollectionItem; Action: TCollectionNotification);override;
 function Add:TIndGridBand;
 procedure Update(Item: TCollectionItem);override;
 property Items[AIndex:integer]:TIndGridBand read GetItems write SetItems; default;
 property View:TIndBaseView read GetView;
 property VisibleCount: Integer read GetVisibleCount;
 //property BottomItems:TList read GetBottomItemsList;
published

end;

TIndGridColumns = class (TIndFieldItemCollection)
private
 function GetItems(AIndex: integer): TIndGridColumn;
 procedure SetItems(AIndex: integer; const Value: TIndGridColumn);
 function GetView: TIndBaseView;
protected
 property View:TIndBaseView read GetView;
 procedure CreateGridColumns;
 procedure FreeGridColumns;
 procedure Notify(Item: TCollectionItem; Action: TCollectionNotification);override;
 procedure Update(Item: TCollectionItem);override;


public
 function Add:TIndGridColumn;
 function FindByName(AColName:string):TIndGridColumn;
 constructor Create(AOwner:TIndBaseView); virtual;
 function FindColumn(const Value: TcxCustomGridtableItem):TIndGridColumn;
 destructor Destroy; override;
 property Items[AIndex:integer]:TIndGridColumn read GetItems write SetItems; default;
end;



TIndGridColumnViewInfo = class(TIndColumnViewInfo)
private
 FGridRecord: TcxCustomGridRecord;
 FGridColumn: TcxCustomGridTableItem;
 procedure SetGridColumn(const Value: TcxCustomGridTableItem);
protected
 function GetFieldValue: variant; override;
 function GetValueInfo(const AFieldName:string; var AExists:boolean):variant; override;
public
 property GridColumn: TcxCustomGridTableItem read FGridColumn write SetGridColumn;
 property GridRecord: TcxCustomGridRecord read FGridRecord write FGridRecord;
published
 property FieldValue;
 property FieldName;
 property FieldNameUp;
 property Visible;
 property Enabled;
end;


TIndGridViewType = (gvTable, gvBandedTable);// , gvCard);

TIndGridButtonProperties = class(TIndButtonProperties)
protected
  function Properties(AButtonParent:TPersistent):TcxCustomEditProperties;override;
  function GetField(AButtonParent:TPersistent):TIndFieldRef;override;
//  function GetButtonBrowse(AButtonParent:TPersistent):TcxEditButton;override;
//  procedure SetButtonBrowse(AButtonParent:TPersistent;AButton:TcxEditButton);override;
  function IsEditing(AButtonParent:TPersistent):boolean;override;
  function GetIndFieldEditorItem(AButtonParent:TPersistent):TPersistent;override;
end;

TIndcxGridBandedTableController = class(TcxGridBandedtableController)
  private
    FGrid: TcxGrid;
public
  procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  function StartDragAndDrop(const P: TPoint): Boolean; override;
  property Grid:TcxGrid read FGrid write FGrid;
end;

TIndcxGridDBBandedTableView = class(TcxGridDBBandedTableView)
private
  FButtonProperties:TIndButtonProperties;
  FIndView: TIndView;

  function IsLoading:boolean;
protected
  function GetControllerClass: TcxCustomGridControllerClass; override;

public
  //при изменение значения в ячейке
  procedure DoEditChangedInner(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);virtual;
  //при начале редактирования value ячейки
  procedure DoAfterEditingGrid(AItem: TcxCustomGridTableItem);virtual;
  //смена столбца в гриде
  procedure DoFocusedColumnChanged(Sender: TcxCustomGridTableView; APrevFocusedItem,
      AFocusedItem: TcxCustomGridTableItem);virtual;
  //смена строки в гриде
  procedure DoChangeRecord(Sender: TcxCustomGridTableView; APrevFocusedRecord,
      AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);virtual;
  procedure InitEditorButtons;
  //изменение количества строк в столбце
  procedure DoChangeColumnSize(Sender: TcxGridTableView; AColumn: TcxGridColumn);
  //установка количества строк по умолчанию в столбце
  procedure MakeDefaultColumnSize(Sender: TcxGridTableView; AColumn: TcxGridColumn);

  procedure DoHideEdit(Sender:TObject);virtual;
  constructor Create(AOwner:TComponent);override;
  property IndView:TIndView read FIndView write FIndView;
  property ButtonProperties:TIndButtonProperties read FButtonProperties;
end;

TIndStatusMessage = class
private
  FMessageStr: string;
  FFontStyle: TFontStyles;
  FFontColor: TColor;
public
  constructor Create;
  property MessageStr:string read FMessageStr write FMessageStr;
  property FontStyle:TFontStyles read FFontStyle write FFontStyle;
  property FontColor:TColor read FFontColor write FFontColor;
end;

TIndStatusMessagePanel = class(TPanel,IDesignerCanAcceptControls,IGetHitTest)
private
  FLabelRight: TcxLabel;
  FLabelLeft: TcxLabel;
  procedure AlignLabels;

  procedure Resized(var Message: TWMSize); message WM_SIZE;
public
  function CanAcceptControls:boolean;
  function GetHitTest(Message:TMessage; Sender:TControl):boolean;
  constructor Create(AOwner:TComponent);override;

  procedure Refresh;
  property LabelLeft:TcxLabel read FLabelLeft;
  property LabelRight:TcxLabel read FLabelRight;
end;

TIndStatusMessages = class
private
  FStatusPanel: TIndStatusMessagePanel;
  FFilterMessage:TIndStatusMessage;
  FFetchLimitMessage:TIndStatusMessage;
public
  constructor Create;
  destructor Destroy;override;
  
  procedure Show;
  property FilterMessage:TIndStatusMessage read FFilterMessage;
  property FetchLimitMessage:TIndStatusMessage read FFetchLimitMessage;
  property StatusPanel:TIndStatusMessagePanel read FStatusPanel write FStatusPanel;
end;

TIndBaseView = class (TInterfacedPersistent, IFetchLimitListener, IStateChangeListener)
private
  FBands: TIndGridBands;
  FColumns: TIndGridColumns;
  FIndGrid: TIndGrid;
  FViewType: TIndGridViewType;
  FGridView:TcxGridDBBandedTableView;
  FGridLevel:TcxGridLevel;
  FTable:TIndTableRef;
  FOnTableChanged: TNotifyEvent;
//  FPreviousOnTableStateChange: TNotifyEvent;
  procedure SetBands(const Value: TIndGridBands);
  procedure SetColumns(const Value: TIndGridColumns);
  procedure SetIndGrid(const Value: TIndGrid);
  procedure SetViewType(const Value: TIndGridViewType);
  procedure DoChangeColumnPosition(Sender: TcxGridTableView; AColumn: TcxGridColumn);
  procedure DoChangeBandPosition(Sender: TcxGridBandedTableView; ABand: TcxGridBand);
  procedure RecreateBands;
  function GetBandsVisible: boolean;
  procedure SetBandsVisible;
  procedure ResetColumn(AColumn: TCxGridColumn);

  procedure DoFetchLimitChanged(Sender:TObject);
//  function GetStatusMessage: string;
//  procedure SetStatusMessage(const Value: string);
  procedure UpdateTableProperties;
  procedure DoBeforeTableChange(const Sender:TObject; const OldTable:TIndMetadataTable; const NewTable:TIndMetadataTable);
  function GetColumnAutoWidth: boolean;
  procedure SetColumnAutoWidth(const Value: boolean);

  procedure SetDataSet(const Value: TIndBaseDataSet);
  procedure SetTable(const Value: TIndTableRef);
  function GetDataSet: TIndbaseDataSet;
  function GetTable: TIndTableRef;
  procedure DoCustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo;
      var ADone: Boolean);

  procedure DoGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure DoGridCellDblClick(Sender: TcxCustomGridTableView;
                                            ACellViewInfo: TcxGridTableDataCellViewInfo;
                                            AButton: TMouseButton;
                                            AShift: TShiftState;
                                            var AHandled: Boolean);

  procedure SetGridViewProperties;
  procedure DblClickAction;
  function GetGroupBox: boolean;
  procedure SetGroupBox(const Value: boolean);
    function GetColumnHeaders: boolean;
    procedure SetColumnHeaders(const Value: boolean);

    {IFetchLimitListener}
    procedure FetchLimited(Sender: TObject); //Выполянется при двойном щелчке на строке грида или при нажатии клавиши Enter
    procedure FetchNoLimited(Sender:TObject);
    {IStateChangeListener}
    procedure DoStateChanged(Sender:TObject);

    procedure BeforeTableChanged(const Sender: TObject; const OldTable,
      NewTable: TIndMetadataTable);


protected
  procedure ViewEditing(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem; var AAllow: Boolean); virtual; //Здесь производится разрешение показа редактора поля
  procedure DoAfterEditing(AItem: TcxCustomGridTableItem);
//  procedure InitInternalEditor(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
  procedure DoOnClickViewButton;virtual;

  procedure TableChanged(Sender:TObject); virtual;

  function ViewTable:TIndBaseTable; virtual;
  procedure SetDataSource;
  procedure CreateGridColumns;
  procedure FreeGridColumns;

  procedure CreateGridView; //modified
  procedure FreeGridView;
  procedure RecreateGridView;

  function GetGrid: TcxCustomGrid;
  property IndGrid:TIndGrid read FIndGrid write SetIndGrid;
  property GridLevel:TcxGridLevel read FGridLevel;
//  property StatusMessage:string read GetStatusMessage write SetStatusMessage;
public
  property GridView:TcxGridDBBandedTableView read FGridView;
  procedure Assign(Source: TPersistent); override;
  constructor Create(AGrid:TIndGrid); virtual;
  destructor Destroy; override;
  property Grid:TcxCustomGrid read GetGrid;
  property ViewType:TIndGridViewType read FViewType write SetViewType default gvBandedTable;
  property Bands:TIndGridBands read FBands write SetBands;
  property Columns:TIndGridColumns read FColumns write SetColumns;
  property GroupByBox:boolean read GetGroupBox write SetGroupBox;
  property ColumnHeaders:boolean read GetColumnHeaders write SetColumnHeaders;

  property DataSet:TIndBaseDataSet read GetDataSet write SetDataSet;
  property Table:TIndTableRef read GetTable write SetTable;
  property OnTableChanged:TNotifyEvent read FOnTableChanged write FOnTableChanged;

  property BandAutoWidth:boolean read GetColumnAutoWidth write SetColumnAutoWidth default True;
end;


TIndGridStatusPanel = class(TPanel,IDesignerCanAcceptControls)
private
  FParentControl:TWinControl;
  procedure SetStatusMessage(const Value: string);
  function GetStatusMessage: string;
  procedure SetParentControl(const Value: TWinControl);
public
  function CanAcceptControls:boolean;
  constructor Create(AOwner:TComponent);override;
  destructor Destroy;override;
  property StatusMessage:string read GetStatusMessage write SetStatusMessage;
  property ParentControl:TWinControl read FParentControl write SetParentControl;
end;

TIndView = class (TIndBaseView,IPropertiesGroup)
public
 function PropertyName:string;

 property DataSet;
 property Table;
published
  property ColumnHeaders;
  property GroupByBox;
  property ViewType;
  property Bands;
  property Columns;
  property BandAutoWidth;
end;

TIndGridManager = class (TIndControlDataSetActionManager)
protected
 function GetTableRef:TIndTableRef; override;
public
 function GetGroupName:string; override;
end;

TIndSimpleIndexUpdater = class
private
  FSortList:TStringList;
protected
  function GetSortByParam(Index:integer):string;virtual;abstract;
  function GetSortObject(Index:integer):TObject;virtual;abstract;
  function GetCount:integer;virtual;abstract;
  procedure MakeUpdateAction(Index:integer);virtual;abstract;

  property SortList:TStringList read FSortList;
public
  constructor Create;
  destructor Destroy;override;
  procedure SortAndUpdate;
end;

TIndSimpleUpdaterGroupIndex = class(TIndSimpleIndexUpdater)
private
  FView: TIndBaseView;
protected
  function GetSortByParam(Index:integer):string;override;
  function GetSortObject(Index:integer):TObject;override;
  function GetCount:integer;override;
  procedure MakeUpdateAction(Index:integer);override;
public
  property View:TIndBaseView read FView write FView;
end;

TIndSimpleUpdaterColIndexDesignTime = class(TIndSimpleIndexUpdater)
private
  FView: TIndBaseView;
protected
  function GetSortByParam(Index:integer):string;override;
  function GetSortObject(Index:integer):TObject;override;
  function GetCount:integer;override;
  procedure MakeUpdateAction(Index:integer);override;
public
  property View:TIndBaseView read FView write FView;
end;


TIndGridSaver = class(TIndComponentsSaver)
private
  FExpandedData:TStrings;
  FSimpleGroupIndexUpdater:TIndSimpleUpdaterGroupIndex;
  function GetGrid: TIndGrid;
  property Grid:TIndGrid read GetGrid;//чтобы можно было проверить на Assigned, добавляем еще как свойство
  function GetParentText(ARow:TcxCustomGridRow):string;
  function GetValuesForGroupRow(ARow:TcxCustomGridRow):string;
  function CheckRowValues(ARow:TcxCustomGridRow;CheckValues:TStrings):boolean;
  function SaveColumns:string;
  function CannotBeExpanded(Level:Integer):boolean;
  function AlwaysExpanded(Level:Integer):boolean;
  function FindGroupColumn(Level:Integer):TIndGridColumn;
  function GetRowLevel(ARow:TcxCustomGridRow):integer;
  procedure SetColumnsStoredPosition;
protected
    procedure GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);override;
  procedure SetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);override;

public
  constructor Create(AOwner:TComponent);override;
  destructor Destroy;override;

  procedure LoadComponentsFromStorage;override;
  procedure SaveComponentsToStorage;override;

  procedure LoadExpandedColumns;
  procedure SaveExpandedColumns;
end;

TIndPopupLinkStorage = class(TComponent)
private
  FStoredLinkOnActionEvent:TdxBarPopupMenuLinkActionEvent;
  FStoredLink:TIndCustomPopupMenuLink;
protected
  property StoredLink:TIndCustomPopupMenuLink read FStoredLink;
  property StoredLinkOnActionEvent:TdxBarPopupMenuLinkActionEvent read
        FStoredLinkOnActionEvent;
public
  constructor Create(AOwner:TComponent;
                     ALink:TIndCustomPopupMenuLink
                     );
end;

TIndPopupLinkStorageList = class(TComponentList)
public
  function IndexOfLink(ALink:TIndCustomPopupMenuLink):integer;

end;

TIndGridPopup = class(TComponent)
private
  FIndGrid:TIndGrid;
  FPopupMenuLink:TIndCustomPopupMenuLink;
  FPopupLinkList:TIndPopupLinkStorageList;
  function GetHitTypeByPoint(APoint:TPoint):TcxGridViewHitType;
  procedure DoActionPopupMenuLink(Sender: TdxBarPopupMenuLink; var X, Y: Integer;
        ClickedByMouse: Boolean; var AllowPopup: Boolean);
public
  constructor Create(AOwner:TComponent);override;
  destructor Destroy;override;
  procedure SetPopupMenuLinkAction(APopupMenuLink:TIndCustomPopupMenuLink);
  procedure ClearPopupMenuAction(APopupMenuLink:TIndCustomPopupMenuLink);
  property IndGrid:TIndGrid read FIndGrid write FIndGrid;
end;

{TIndcxGrid = class(TcxGrid)
private
  FOnChangeEvent: TNotifyEvent;
public
  procedure LayoutChanged; override;
  procedure SizeChanged; override;
  property OnChangeEvent:TNotifyEvent read FOnChangeEvent write FOnChangeEvent;
end;}

//Грид
TIndGrid = class (TIndCustomGridPanel, IIndListener, IIndActionSource, IOwnerControl,ILocalizer,
                IActionShortCut, IDesignerCanAcceptControls,IIndActiveControl,
                IIndSaverImplementor, IIndPopupMenuControl, IIndGridDataEventListener, IIndGetTable)
private
 FManager:TIndGridManager;
 FGridSaver:TIndGridSaver;
 FGrid:TcxCustomGrid;
 FView: TIndView;
 FCreatingStructureNavigator:boolean;
 FStructureNavigator:TIndGridStructureNavigator;
// FStatusPanel:TIndGridStatusPanel;
 FStatusPanel:TIndStatusMessagePanel;
 FStatusMessages:TIndStatusMessages;
 FIndGridRecnoChecker:TIndGridRecnoChecker;
 FGridPopupMenu:TcxGridPopupMenu;
 FIndGridPopup:TIndGridPopup;
 FCurrentHitColumn:TIndGridColumn;
 FKeyFieldsValue:Variant;
 //Пришлось ввести флаг - структура может грузиться и при рефреше
 FAlreadyRefreshed: Boolean;
 FSimpleUpdaterColIndex:TIndSimpleUpdaterColIndexDesignTime;
 procedure ResizeChanged(var Message: TWMSize); message WM_SIZE;

 procedure SetView(const Value: TIndView);
 procedure CreateStructureNavigator;
 function GetStructureNavigator: TIndGridStructureNavigator;
 function GetDataSet: TIndBaseDataSet;
 function GetTable: TIndTableRef;
 procedure SetDataSet(const Value: TIndBaseDataSet);
 procedure SetTable(const Value: TIndTableRef);
 procedure LinkColumnGroups;
 function UpdateGroupSummary(Sender:TObject):TIndColumnSummaryItem;
 function UpdateTotalSummary(Sender:TObject):TIndColumnSummaryItem;
 //реализация интерфейса IIndPopupMenuControl
 //------------------------------------------------
 function GetControl:TWinControl;
 procedure SetPopupMenu(ALink:TIndCustomPopupMenuLink);
 procedure ClearPopupMenu(ALink:TIndCustomPopupMenuLink);
 //------------------------------------------------
 procedure PostLoadColumnsExpandedData;
 procedure PostLoadFocusedRecord;
 procedure LoadColumnsExpandedData;
 procedure SaveColumnsExpandedData;
 procedure DoOnTableStateChange(Sender:TObject);
 procedure DoResizeGrid(Sender:TObject);
 //Установка столбцам загруженных но еще не установленных ColIndex (см TIndBandedColumnPosition)
 procedure SetColumnsRealIndexes;
    procedure SetKeyFieldsValueAsString(const Value: string);
    function GetKeyFieldsValueAsString: string;
protected
 //property Grid:TcxGrid read FGrid stored False;
 function GetIndTable: TIndMetadataTable;
 property Manager:TIndGridManager read FManager;
 procedure Loaded;override;
 function CanActionPopupMenu(MenuItemClass:TcxGridPopupMenuOperation):boolean;virtual;
 procedure DoPopup(ASenderMenu: TComponent;
    AHitTest: TcxCustomGridHitTest; X, Y: Integer; var AllowPopup: Boolean);virtual;
 function GetSaver:TIndSaver;
 function ColumnUseSummary(AGroupSummary:boolean):boolean;
 procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 function GetPopupMenuHitTypes:TcxGridViewHitTypes;virtual;

 procedure LocalizePopupMenu(const ASenderMenu:TComponent);

 {IIndGridDataEventListener}
 procedure GridDataEvent(AEventType:TIndDataEventForGrid);

 procedure HandleGR_LoadColumnsExpandedData(var a:TMessage); message GR_LoadColumnsExpandedData;
 procedure HandleGR_LoadFocusedRecord(var Message:TMessage); message GR_LoadFocusedRecord;

  procedure SetParent(AVal:TWinControl); override;
  function GetFetchLimitedText:string;
  function GetFilterSetText:string;
 {ILocalizer}
  function GetLocalizedString(const ID, DefaultValue: string): string;
  function GetStringSection: string;
  procedure Localize; //Дополнительная локализация
public
 procedure SaveFocusedRecord;
 procedure LoadFocusedRecord;

 function ParentGroupExpanded(Row:TcxCustomGridRow):boolean;
 function GetActiveControl:TWinControl;

 function CanAcceptControls:boolean;
 function CanActionShortCut:boolean;

 function CanShowEditors:boolean;
 function CanSelectAction:boolean;

// property StatusPanel:TIndGridStatusPanel read FStatusPanel;
 property StatusPanel:TIndStatusMessagePanel read FStatusPanel;
 function GetHitTest(Message:Tmessage;Sender:TControl):boolean;override;
 procedure HandleEvent(ASender:TObject; const AEvent:integer);

 procedure CreateBarView(const IndBar:TComponent);
 procedure DeleteBarView(const IndBar:TComponent);
 procedure AddBar(const IndBar: TComponent);
 procedure DeleteBar(const IndBar: TComponent);

 constructor Create(AOwner:TComponent); override;
 destructor Destroy; override;
 property StructureNavigator:TIndGridStructureNavigator read GetStructureNavigator;
 property Grid:TcxCustomGrid read FGrid;

 procedure miSetColumnAlwaysOpen(Sender:TObject);
 procedure miSetColumnAlwaysClose(Sender:TObject);
 procedure miSetColumnExpandOnlySelected(Sender:TObject);
 procedure miShowPreview(Sender: TObject);
 procedure miColumnAutoHeight(Sender: TObject);

 procedure DoInitializeGridPopup;
 procedure DoAlreadyRefreshed;
 procedure ChangeStatusPanelText;
 property KeyFieldsValueAsString:string read GetKeyFieldsValueAsString write SetKeyFieldsValueAsString;

published
 property Width;
 property Height;
 property Top;
 property Left;
 property Align;
 property View:TIndView read FView write SetView;
 property Table:TIndTableRef read GetTable write SetTable;
 property DataSet:TIndBaseDataSet read GetDataSet write SetDataSet;
end;


function CreateTableColumn(const AView:TcxGridDBTableView;const AColumn:TIndGridColumn):TcxGridDBColumn;
function CreateBandedTableColumn(const AView:TcxGridDBBandedTableView;const AColumn:TIndGridColumn):TcxGridDBBandedColumn;
//function CreateCardColumn(const AView:TcxGridDBCardView;const AColumn:TIndGridColumn):TcxGridDBCardViewRow;

function LocalizeGrids(const ID, DefaultValue: string): string;
function GetDesigner(Grid:TcxCustomGrid):TWindowDesigner;

function ConvertStringToVariantKey(Value:string):Variant;
function ConvertVariantKeyToString(Value:Variant):string;

implementation
uses dmuManager, dmuStyles, fmuBaseMetadata, fmuBrowseTable, fmuFilter, fmuEditTable,dmuConnection, uIndEditProperties, cxControls, uIndFieldsMetadata,
  uIndObjReference, uConstant, cxDBData, uIndDBEditCommon, dmuDevPrintSystem, dmuImages, uIndEditConstructor, uIndSelectionFilter;

function ConvertStringToVariantKey(Value:string):Variant;
var Strings:TStringList;
    I:integer;
begin
   Result := null;
   Strings := TStringList.Create;
   try
     Strings.Text := Value;
     if Strings.Count = 1 then
       Result := Strings[0]
     else if Strings.Count > 1 then
     begin
       Result := VarArrayCreate([0,Strings.Count - 1],varVariant);
       for I := 0 to Strings.Count - 1 do
       begin
         if Strings[I] = 'null' then
           Result[I] := null
         else
           Result[I] := Strings[I]
       end;   
     end;  
   finally
     FreeAndNil(Strings);
   end;
end;

function ConvertVariantKeyToString(Value:Variant):string;
var I:integer;
    Strings:TStringList;
begin
  Strings := TStringList.Create;
  try
    if VarIsArray(Value) then
    begin
      for I := VarArrayLowBound(Value,1) to VarArrayHighBound(Value,1) do
        Strings.Add(VarToStrDef(Value[I],'null'));
      Result := Strings.Text;  
    end
    else
      Result := VarToStrDef(Value,'');
  finally
    FreeAndNil(Strings);
  end;
end;

function GetDesigner(Grid:TcxCustomGrid): TWindowDesigner;
var AWindowDesigner:IDesignerImplementor;
    AForm:TCustomForm;
begin
    Result := nil;
    AForm := TCustomForm(Grid.Parent.Owner);
    if Assigned(AForm) and Assigned(AForm.Designer) and (AForm.Designer.QueryInterface(IDesignerImplementor,AWindowDesigner)=0 ) then
       Result := AWindowDesigner.GetImplementor;
end;


function LocalizeGrids(const ID, DefaultValue: string): string;
begin
  Result := dmuLanguages.GetLanguageString(cIndGridsLocalizeSection,
    ID, DefaultValue);
end;

function CreateTableColumn(const AView:TcxGridDBTableView;const AColumn:TIndGridColumn):TcxGridDBColumn;
begin
 Result := AView.CreateColumn;
end;

function CreateBandedTableColumn(const AView:TcxGridDBBandedTableView;const AColumn:TIndGridColumn):TcxGridDBBandedColumn;
begin
 Result := AView.CreateColumn;
end;

{function CreateCardColumn(const AView:TcxGridDBCardView;const AColumn:TIndGridColumn):TcxGridDBCardViewRow;
begin
 Result := AView.CreateRow;
end;}




{ TIndGrid }

procedure TIndGrid.AddBar(const IndBar: TComponent);
begin
 FManager.Addbar(IndBar);
end;

function TIndGrid.CanAcceptControls: boolean;
begin
 Result := False;
end;

function TIndGrid.CanActionPopupMenu(MenuItemClass:TcxGridPopupMenuOperation): boolean;
begin
{  Result := not Assigned(MenuItemClass) or ((not MenuItemClass.InheritsFrom(TcxGridSortColumnAsc)) or (FIndGridRecnoChecker.CanSorting)) and
            ((not MenuItemClass.InheritsFrom(TcxGridSortColumnDesc)) or (FIndGridRecnoChecker.CanSorting)) and
            ((not MenuItemClass.InheritsFrom(TcxGridRemoveColumn)) or (FIndGridRecnoChecker.CanSorting)) and
            ((not MenuItemClass.InheritsFrom(TcxGridFieldChooser)) or (FIndGridRecnoChecker.CanSorting));}
  //В данный момент решено не запрещать действия по сортировке и группировке
  //в случае необходимости это можно легко добавить
 { Result := not Assigned(MenuItemClass) or
            (not MenuItemClass.InheritsFrom(TcxGridFieldChooser) and
             not MenuItemClass.InheritsFrom(TcxGridRemoveColumn));}
   Result := True;
end;

function TIndGrid.CanActionShortCut: boolean;
begin
 Result := FGrid.IsFocused and Assigned(FGrid.FocusedView) and FGrid.FocusedView.Focused;
end;

function TIndGrid.CanSelectAction: boolean;
begin
 Result := Assigned(Table.Table) and Assigned(Table.Table.Data) and Table.Table.Data.CanModify;
end;

function TIndGrid.CanShowEditors: boolean;
begin
 Result := True; //(Owner is TfmEditTable) and Assigned(DataSet) and DataSet.IsSystem;
end;


function TIndGrid.ColumnUseSummary(AGroupSummary:boolean): boolean;
var ColIndex:integer;

    function CheckViewSummary(AColumn:TIndGridColumn):boolean;
    begin
       if AGroupSummary then
         Result := AColumn.ColumnSummaryOptions.GroupSummary.UseSummary
       else
         Result := AColumn.ColumnSummaryOptions.TotalSummary.UseSummary
    end;

begin
   Result := False;
   for ColIndex := 0 to View.Columns.Count - 1 do
   begin
      if CheckViewSummary(View.Columns[ColIndex]) then
      begin
        Result := True;
        Break;
      end;
   end;
end;

constructor TIndGrid.Create(AOwner: TComponent);
begin
  inherited;
  TabStop := False;
  SetBounds(10,10,200,100);
  ControlStyle := [ csAcceptsControls, csOpaque, csSetCaption, csCaptureMouse, csClickEvents, csDoubleClicks];
 // FGrid.SetSubComponent(True); //Почему-то этого здесь нету в отличии от IndVerticalGrid
  BevelInner := bvNone;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  BorderWidth := 1;
  Color := GetGridFocusedCellFocusedColor;
  FGrid := TcxGrid.Create(Self);

  FGrid.Parent := Self;
  FGrid.Align := alCustom;
  TcxGrid(FGrid).BevelInner := bvNone;
  TcxGrid(FGrid).BevelOuter := bvNone;
  TcxGrid(FGrid).BevelKind := TBevelKind(0);
  //m.proh - теперь за это отвечает сама панель
  //TcxGrid(FGrid).OnResize := DoResizeGrid;
  TcxGrid(FGrid).BorderStyle := cxcbsNone;


  FView := TIndView.Create(Self);
  FView.GridView.Site.Align := alClient;

  FView.GridView.OptionsData.DeletingConfirmation := False;
  FView.GridView.OptionsData.Deleting := False;
  FView.GridView.OptionsData.Inserting := False;
  FView.GridView.OptionsData.Appending := False;
//  FView.GridView.OptionsData.CancelOnExit := False;
//  FView.GridView.OptionsData.Appending := False;


  TindcxGridBandedTableController(FView.GridView.Controller).Grid := TcxGrid(FGrid);

//  FStatusPanel := TIndGridStatusPanel.Create(Self);
//  FStatusPanel.ParentControl := Self;
  FStatusPanel := TIndStatusMessagePanel.Create(Self);
  FStatusPanel.Parent := Self; 
  FStatusPanel.Visible := False;
  FStatusPanel.SetSubComponent(True);

  FStatusMessages := TIndStatusMessages.Create;
  FStatusMessages.StatusPanel := FStatusPanel;

  if not (csLoading in ComponentState) then View.Bands.Loaded;
  FManager := TIndGridManager.Create(Self);
  FManager.AddOwnerControl(Self);
  FView.OnTableChanged := FManager.TableChanged;
  //создаем хранитель грида
  FGridSaver := TIndGridSaver.Create(Self);
  FGridSaver.SavedComponent := Self;
  if not (csDesigning in ComponentState) then
  begin
    FIndGridRecnoChecker := TIndGridRecnoChecker.Create(Self);
    FIndGridRecnoChecker.IndComponent := Self;
  end;
  FGridPopupMenu := TcxGridPopupMenu.Create(Self);
  FGridPopupMenu.Grid := TcxGrid(Grid);
  FGridPopupmenu.AlwaysFireOnPopup := True;
  FGridPopupMenu.OnPopup := DoPopup;
  DoInitializeGridPopup;

  FIndGridPopup := TIndGridPopup.Create(Self);
  FIndGridPopup.IndGrid := Self;

  FSimpleUpdaterColIndex := TIndSimpleUpdaterColIndexDesignTime.Create;
  FSimpleUpdaterColIndex.View := FView; 

{  FFilterSetPanel := TPanel.Create(Self);
  FFilterSetPanel.Align := alBottom;
  FFilterSetPanel.BevelOuter := bvNone;
  FFilterSetPanel.BevelInner := bvNone;
  FFilterSetPanel.BorderStyle := bsSingle;
  FFilterSetPanel.BorderWidth := 3;
  FFilterSetPanel.Ctl3D := False;
  FFilterSetPanel.ParentCtl3D := false;
  FFilterSetPanel.Height := 30;
  FFilterSetPanel.Color := clWhite;
  FFilterSetPanel.Parent := Self;


  FFilterSetLabel := TcxLabel.Create(FFilterSetPanel);
  FFilterSetLabel.Align := alClient;
  FFilterSetLabel.Properties.Alignment.Vert := taVCenter;
  FFilterSetLabel.Properties.Alignment.Horz := taCenter;
  FFilterSetLabel.Properties.WordWrap := true;
  FFilterSetLabel.AutoSize := false;
  FFilterSetLabel.Style.Font.Style := [fsBold];
  FFilterSetLabel.Style.Font.Color := clRed;
  FFilterSetLabel.Caption := LocalizeGrids(idTcxGridFilterSet,langTcxGridFilterSet);
  FFilterSetLabel.Parent := FFilterSetPanel;
  FFilterSetPanel.Visible := False;}
end;


procedure TIndGrid.CreateBarView(const IndBar: TComponent);
begin
 FManager.CreateBarView(IndBar);
end;

procedure TIndGrid.CreateStructureNavigator;
begin
  if not Assigned(FStructureNavigator) then begin
    FCreatingStructureNavigator := True;
    try
      FStructureNavigator := TIndGridStructureNavigator.Create(Self.FGrid);
    finally
      FCreatingStructureNavigator := False;
    end;
  end;
end;

procedure TIndGrid.DeleteBar(const IndBar: TComponent);
begin
 if Assigned(FManager) then  FManager.DeleteBar(IndBar);
end;

procedure TIndGrid.DeleteBarView(const IndBar: TComponent);
begin
 if Assigned(FManager) then FManager.DeleteBarView(IndBar);
end;

destructor TIndGrid.Destroy;
begin
//  FGridSaver.SaveComponentsToStorage;
  FreeAndNil(FView);
  FreeAndNil(FStatusMessages);
  FreeAndNil(FSimpleUpdaterColIndex);
  if Assigned(FManager) then FreeAndNil(FManager);
  inherited;
end;

procedure TIndGrid.DoPopup(ASenderMenu: TComponent;
  AHitTest: TcxCustomGridHitTest; X, Y: Integer; var AllowPopup: Boolean);
var MenuItemIndex,I:integer;

begin
  FCurrentHitColumn := View.Columns.FindColumn(TcxGridColumnHeaderViewInfo(AHitTest.ViewInfo).Column);
  if ASenderMenu.InheritsFrom(TcxGridStdHeaderMenu) then
  begin
     for MenuItemIndex := TcxGridStdHeaderMenu(ASenderMenu).Items.Count -1 downto  0 do
     begin
       if integer(TcxGridStdHeaderMenu(ASenderMenu).Items[MenuItemIndex].HelpContext) = cIndUserGroupOptions then
       begin
         with TMenuItem(TcxGridStdHeaderMenu(ASenderMenu).Items[MenuItemIndex]) do
         begin
           for I := 0 to Count - 1 do
           begin
             if integer(Items[I].HelpContext) = cIndUserBuiltInMenuAlwaysExpand then
                Items[I].Checked := FCurrentHitColumn.AlwaysExpand
             else if integer(Items[I].HelpContext) = cIndUserBuiltInMenuClosedGroup then
                Items[I].Checked := FCurrentHitColumn.AlwaysClose
             else if integer(Items[I].HelpContext) = cIndUserBuiltInMenuOnlySelected then
                Items[I].Checked := FCurrentHitColumn.ExpandSelected
           end;
         end;  
       end;
     end; 
  end;
end;

function TIndGrid.GetActiveControl: TWinControl;
begin
 Result := FGrid;
end;

function TIndGrid.GetControl: TWinControl;
begin
  Result := Self.Grid;
end;

function TIndGrid.GetDataSet: TIndBaseDataSet;
begin
  Result := FView.DataSet;
end;

//принимает параметром компонент унаследованный от TControl
//этот контрол - отдельный компонент, входящий в состав cxGrid
//для cxGrid два таких подкомпонента - cxGridSite и cxControlScrollBar
//для обоих из этих компонентов форма не является parent
//и при этом их реакции на события нажатия кнопок мыши и клавиатуры различны,
//соответственно в зависимости от класса компонента Sender'а надо предпринимать различные
//действия по обработке события


function TIndGrid.GetHitTest(Message:TMessage;Sender:TControl): boolean;
var X,Y:integer;
begin
 Result := False;
 X := TWMMouse(Message).XPos;
 Y := TWMMouse(Message).YPos;

 if Sender is TIndStatusMessagePanel then
 begin
    Result := false;
    Exit;
 end;

 if (View.GridView.GetHitTest(X,Y).HitTestCode = htFooterCell) or (View.GridView.GetHitTest(X,Y).HitTestCode = htFooter) then
    Exit;

 if (View.GridView.GetHitTest(X,Y).HitTestCode = htColumnHeaderVertSizingEdge) or
    (View.GridView.GetHitTest(X,Y).HitTestCode = htColumnHeaderFilterButton) or
    (View.GridView.GetHitTest(X,Y).HitTestCode = htIndicator) then
     Exit;

 if (View.GridView.GetHitTest(X,Y).HitTestCode = htBand) and (Message.Msg = WM_LBUTTONDOWN) then Exit;
 if (View.GridView.GetHitTest(X,Y).HitTestCode = htGroupByBox) and (Message.Msg = WM_LBUTTONDOWN) then begin
    if (Sender.ClassType <> TcxGridSite) then Result := True;
     Exit;
 end;
 if (View.GridView.GetHitTest(X,Y).HitTestCode = htColumnHeader) then
    Result := True;


 if (View.GridView.GetHitTest(X,Y).HitTestCode > 0) or ((Message.WParam and WM_LBUTTONDOWN <> 0) and (Message.Msg = WM_MOUSEMOVE) ) then
    Result := True;


end;

function TIndGrid.GetPopupMenuHitTypes: TcxGridViewHitTypes;
begin
  Result := [gvhtGridNone,gvhtGridTab,gvhtNone,gvhtTab,gvhtCell,
            gvhtExpandButton,gvhtRecord,gvhtNavigator,gvhtPreview,
            gvhtGroupByBox,gvhtIndicator,gvhtRowIndicator,gvhtRowLevelIndent,
            gvhtBand,gvhtBandHeader,gvhtRowCaption,gvhtSeparator];
end;

function TIndGrid.GetSaver: TIndSaver;
begin
  Result := FGridSaver;
end;

function TIndGrid.GetStructureNavigator: TIndGridStructureNavigator;
begin
  CreateStructureNavigator;
  Result := FStructureNavigator;
end;

function TIndGrid.GetTable: TIndTableRef;
begin
 Result := FView.Table;
end;

procedure TIndGrid.HandleEvent(ASender: TObject; const AEvent: integer);
begin
 if ASender is TcxGridSite then begin
  if AEvent = WM_LBUTTONDOWN then
    View.GridView.Changed(vcLayout)
 end else if AEvent = cControlSelectionRefresh then
    View.GridView.Changed(vcSize);
end;


procedure TIndGrid.LinkColumnGroups;
begin
  if View.Columns.Count > 0 then
  begin
    TIndSummaryGroupProvider(View.Columns[0].ColumnSummaryOptions.GroupSummary.SummaryProvider).UpdateLinkedColumns;
    //View.Columns[0].ColumnSummaryOptions.UpdateSummaryVisibility;
  end;
end;

procedure TIndGrid.Loaded;
begin
  inherited;
//  FGridSaver.LoadComponentsFromStorage;
  //создаем объект проверки наличия RecNo
  SetColumnsRealIndexes;
  LinkColumnGroups;

end;

procedure TIndGrid.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

end;

procedure TIndGrid.SetDataSet(const Value: TIndBaseDataSet);
begin
 FView.DataSet := Value;
// FView.DataSet.Table.OnStateChange := DoOnTableStateChange;

end;

procedure TIndGrid.SetTable(const Value: TIndTableRef);
begin
 FView.Table := Value;
end;

procedure TIndGrid.LoadColumnsExpandedData;
//var I:integer;
begin
  View.GridView.ViewData.Collapse(True);
//  for I := 0 to View.Columns.Count - 1 do
//    View.Columns[I].FColumnSaver.LoadExpandedData(View.Columns[I].FExpandedData);
  FGridSaver.LoadExpandedColumns;
end;

procedure TIndGrid.SetView(const Value: TIndView);
begin
 if Value <> FView then
 begin
  FView.Assign(Value);
 end;
end;



function TIndGrid.UpdateGroupSummary(Sender: TObject): TIndColumnSummaryItem;
begin
  Result := TIndGridColumn(Sender).ColumnSummaryOptions.GroupSummary;
end;

function TIndGrid.UpdateTotalSummary(Sender: TObject): TIndColumnSummaryItem;
begin
  Result := TIndGridColumn(Sender).ColumnSummaryOptions.TotalSummary;
end;

procedure TIndGrid.ClearPopupMenu(ALink: TIndCustomPopupMenuLink);
begin
  if Assigned(Alink) and not (csDestroying in ComponentState) then
    FIndGridPopup.ClearPopupMenuAction(Alink);

end;

procedure TIndGrid.SetPopupMenu(ALink: TIndCustomPopupMenuLink);
begin
  if Assigned(Alink) then
    FIndGridPopup.SetPopupMenuLinkAction(Alink);
end;

procedure TIndGrid.LocalizePopupMenu(const ASenderMenu: TComponent);
//var i:integer;
begin
{ for i := 0 to TPopupMenu(ASenderMenu).Items.Count - 1 do
 begin

 end;}
end;

procedure TIndGrid.miSetColumnAlwaysOpen(Sender: TObject);
begin
  if not TMenuItem(Sender).Checked then
     TMenuItem(Sender).Checked := True;
  FCurrentHitColumn.AlwaysExpand := TMenuItem(Sender).Checked;
  if FCurrentHitColumn.AlwaysExpand then
  begin
    FCurrentHitColumn.ExpandSelected := False;
    FCurrentHitColumn.AlwaysClose := False;
  end;  
end;

procedure TIndGrid.miSetColumnExpandOnlySelected(Sender: TObject);
begin
  if not TMenuItem(Sender).Checked then
     TMenuItem(Sender).Checked := True;

  FCurrentHitColumn.ExpandSelected := TMenuItem(Sender).Checked;
  if FCurrentHitColumn.ExpandSelected then
  begin
    FCurrentHitColumn.AlwaysExpand := False;
    FCurrentHitColumn.AlwaysClose := False;
  end;
end;

procedure TIndGrid.miSetColumnAlwaysClose(Sender: TObject);
begin
  if not TMenuItem(Sender).Checked then
     TMenuItem(Sender).Checked := True;

  FCurrentHitColumn.AlwaysClose := TMenuItem(Sender).Checked;
  if FCurrentHitColumn.AlwaysClose then
  begin
    FCurrentHitColumn.AlwaysExpand := False;
    FCurrentHitColumn.ExpandSelected := False;
  end;  
end;

procedure TIndGrid.DoInitializeGridPopup;
var I:integer;
    ABuiltInMenus:TcxGridDefaultPopupMenu;
    AMenu: TComponent;
    FMenuItem,FGroupMenuItem: TMenuItem;
begin
  ABuiltInMenus := FGridPopupMenu.BuiltInPopupMenus;
  for I := 0 to ABuiltInMenus.Count - 1 do
  begin
    if ([gvhtColumnHeader] *
      ABuiltInMenus[I].HitTypes) <> [] then
    begin
      AMenu := ABuiltInMenus[I].PopupMenu;
      break;//??? Степа!!! 10.12.2008
    end;
  end;

  if Assigned(AMenu) and AMenu.InheritsFrom(TPopupMenu) then
  begin
    //авто высота всех колонок
    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := LocalizeGrids(idColumnAutoHeight, langColumnAutoHeight);
      OnClick := miColumnAutoHeight;
      if Assigned(dmImages.ilConfRun) and Assigned(TPopupMenu(AMenu).Images) then
      begin
        TPopupMenu(AMenu).Images.AddImage(dmImages.ilConfRun, 120);
        FMenuItem.ImageIndex := TPopupMenu(AMenu).Images.Count - 1;
      end;
    end;
    TPopupMenu(AMenu).Items.Add(FMenuItem);

    FGroupMenuItem := TMenuItem.Create(Self);
    with FGroupMenuItem do
    begin
      Caption := LocalizeGrids(idTcxGridGroups, langTcxGridGroups);
      HelpContext := cIndUserGroupOptions;
    end;
    TPopupMenu(AMenu).Items.Add(FGroupMenuItem);

    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := LocalizeGrids(idTcxGridAlwaysExpandGroup,
        langTcxGridAlwaysExpandGroup);
      OnClick := miSetColumnAlwaysOpen;
      RadioItem := True;
   //   AutoCheck := True;
      GroupIndex := cIndUserBuiltInMenu;
      HelpContext := cIndUserBuiltInMenuAlwaysExpand;
    end;
    FGroupMenuItem.Add(FMenuItem);

    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := LocalizeGrids(idTcxGridAlwaysClosedGroup,
        langTcxGridAlwaysClosedGroup);
      OnClick := miSetColumnAlwaysClose;
      RadioItem := True;
   //   AutoCheck := True;
      GroupIndex := cIndUserBuiltInMenu;
      HelpContext := cIndUserBuiltInMenuClosedGroup;
    end;
    FGroupMenuItem.Add(FMenuItem);

    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := LocalizeGrids(idTcxGridOnlySelectedExpand,
        langTcxGridOnlySelectedExpand);
      OnClick := miSetColumnExpandOnlySelected;
      RadioItem := True;
     // AutoCheck := True;
      HelpContext := cIndUserBuiltInMenuOnlySelected;
      GroupIndex := cIndUserBuiltInMenu;
    end;
    FGroupMenuItem.Add(FMenuItem);

    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := '-';
    end;
    TPopupMenu(AMenu).Items.Add(FMenuItem);    

    //Печать грида
    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := LocalizeGrids(idPrintGrid, langPrintGrid);
      OnClick := miShowPreview;
      //RadioItem := True;
      // AutoCheck := True;
      //HelpContext := cIndUserBuiltInMenuOnlySelected;
      //GroupIndex := cIndUserBuiltInMenu;
      if Assigned(dmImages.ilConfRun) and Assigned(TPopupMenu(AMenu).Images) then
      begin
        TPopupMenu(AMenu).Images.AddImage(dmImages.ilConfRun, 213);
        FMenuItem.ImageIndex := TPopupMenu(AMenu).Images.Count - 1;
      end;
    end;
    TPopupMenu(AMenu).Items.Add(FMenuItem);
  end;
end;

procedure TIndGrid.DoOnTableStateChange(Sender: TObject);
begin
{  if Assigned(View.FPreviousOnTableStateChange) then
     View.FPreviousOnTableStateChange(Sender);}
end;

function TIndGrid.ParentGroupExpanded(Row: TcxCustomGridRow): boolean;
begin
  Result := not Assigned(Row.ParentRecord) or Row.ParentRecord.Expanded;
end;

procedure TIndGrid.GridDataEvent(AEventType: TIndDataEventForGrid);
begin
 if csDesigning in ComponentState then
   Exit; 
 case AEventType of
  degClose:
  begin
    SaveFocusedRecord;
    SaveColumnsExpandedData;
  end;
  degOpen:
  begin
    PostLoadColumnsExpandedData;
    PostLoadFocusedRecord;
    ChangeStatusPanelText;
  end;
  degCloseTpScroll:
  begin
    SaveFocusedRecord;
    SaveColumnsExpandedData;
  end;
  degOpenTp:
  begin
    PostLoadColumnsExpandedData;
    PostLoadFocusedRecord;
    ChangeStatusPanelText;
  end;
  degCloseTp:
  begin
    SaveFocusedRecord;
    SaveColumnsExpandedData;
  end;
 end;
end;

procedure TIndGrid.SaveColumnsExpandedData;
begin
  FGridSaver.SaveExpandedColumns;
end;

procedure TIndGrid.PostLoadColumnsExpandedData;
begin
 PostMessage(Handle,GR_LoadColumnsExpandedData,0,0);
end;

procedure TIndGrid.HandleGR_LoadColumnsExpandedData(var a: TMessage);
begin
 if Assigned(Table.Table) and Assigned(Table.Table.Data) and (Table.Table.Data.State in [dsEdit,dsInsert]) then exit;
 if not FAlreadyRefreshed then
   LoadColumnsExpandedData
 else
   FAlreadyRefreshed := false;
end;


function TIndGrid.GetIndTable: TIndMetadataTable;
begin
  Result := Table.Table; 
end;

procedure TIndGrid.LoadFocusedRecord;
begin
 if TcxGridDBTableView(View.GridView).DataController.Active then
  TcxGridDBTableView(View.GridView).DataController.LocateByKey(FKeyFieldsValue);
end;

procedure TIndGrid.SaveFocusedRecord;
begin
 if TcxGridDBTableView(View.GridView).DataController.Active then
  try
    FKeyFieldsValue := TcxGridDBTableView(View.GridView).DataController.GetKeyFieldsValues;
  except
  
  end;
end;

procedure TIndGrid.PostLoadFocusedRecord;
begin
 PostMessage(Handle,GR_LoadFocusedRecord,0,0);
end;

procedure TIndGrid.HandleGR_LoadFocusedRecord(var Message: TMessage);
begin
  LoadFocusedRecord;
end;

procedure TIndGrid.miShowPreview(Sender: TObject);
begin
  dmDevPrintSystem.ShowPreview(Self);
end;

procedure TIndGrid.miColumnAutoHeight(Sender:TObject);
var I:integer;
begin
  for I := 0 to View.Columns.Count - 1 do
    TIndCxGridDbBandedTableView(View.GridView).MakeDefaultColumnSize(
      TIndCxGridDbBandedTableView(View.GridView),
      TIndCxGridDbBandedTableView(View.GridView).Columns[i]);     

end;

procedure TIndGrid.DoAlreadyRefreshed;
begin
  FAlreadyRefreshed := true;
end;

procedure TIndGrid.SetParent(AVal: TWinControl);
begin
  inherited;
 // if Assigned(AVal) and Assigned(FGrid) then
 //  FGrid.Repaint;
//  TIndcxGrid(FGrid).OnChangeEvent := DoResizeGrid;

end;

procedure TIndGrid.ChangeStatusPanelText;
begin
//  if not Showing then Exit;
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

function TIndGrid.GetFetchLimitedText: string;
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

function TIndGrid.GetFilterSetText: string;
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

procedure TIndGrid.DoResizeGrid(Sender: TObject);
begin
  //m.proh - do nothing, resizing on messages
  {FGrid.Align := alNone;
  FStatusPanel.Refresh;
   FGrid.Align := alClient;}
end;

function TIndGrid.GetLocalizedString(const ID,
  DefaultValue: string): string;
begin
  Result := LocalizeGrids(Id,DefaultValue);
end;

function TIndGrid.GetStringSection: string;
begin
  Result := ClassName;
end;

procedure TIndGrid.Localize;
begin
  ChangeStatusPanelText;
end;



procedure TIndGrid.ResizeChanged(var Message: TWMSize);
begin
  //FGrid.Align := alNone;
  FStatusPanel.Refresh;
  //FGrid.Align := alClient;
  if FStatusPanel.Visible then
    FGrid.SetBounds(BorderWidth, BorderWidth, Width - 2*BorderWidth, Height - FStatusPanel.Height - 2*BorderWidth)
  else
    FGrid.SetBounds(BorderWidth, BorderWidth, Width - 2*BorderWidth, Height - 2*BorderWidth);
end;

procedure TIndGrid.SetColumnsRealIndexes;
var I:integer;
    SortList:TStringList;
begin
{  SortList := TStringList.Create;
  try
    for I := 0 to View.Columns.Count - 1 do
      SortList.AddObject(IntToStr(TIndGridColumn(View.Columns[I]).Position.StoredColIndex),View.Columns[I]);
    SortList.Sort;
    for I := 0 to SortList.Count - 1 do
      TIndGridColumn(SortList.Objects[I]).Position.ColIndex := TIndGridColumn(SortList.Objects[I]).Position.StoredColIndex;
  finally
    SortList.Free;
  end;}
  FSimpleUpdaterColIndex.SortAndUpdate;
end;

procedure TIndGrid.SetKeyFieldsValueAsString(const Value: string);
begin
  try
    FKeyFieldsValue := ConvertStringToVariantKey(Value);
    PostLoadFocusedRecord;
  except
  end;
end;

function TIndGrid.GetKeyFieldsValueAsString: string;
begin
  try
    SaveFocusedRecord;
    Result := ConvertVariantKeyToString(FKeyFieldsValue);
  except

  end;  
end;

{ TIndGridColumn }


class function TIndGridColumn.BaseName: string;
begin
 Result := 'Column';
end;


procedure TIndGridColumn.CreateColumnPosition;
var ABand:TIndGridBand;
begin
  if not Assigned(Position) then
  begin
    FPosition := TIndBandedColumnPosition.Create(Self);
    ABand := View.Bands[0];
    FPosition.FBand := ABand;
  end;
  TcxGridBandedColumn(FCol).Position.BandIndex := FPosition.BandIndex;
  TcxGridBandedColumn(FCol).Position.ColIndex := FPosition.ColIndex;

end;

procedure TIndGridColumn.CreateGridColumn;
begin
 FCol := CreateBandedTableColumn(TcxGridDBBandedTableView(TIndGridColumns(Collection).View.GridView),Self);
// FCol.OnCustomDrawCell := DoCustomDrawCell;
// FCol.OnGetProperties := CheckProperties;
 FCol.Tag := integer(Self);
 CreateColumnPosition;

end;

destructor TIndGridColumn.Destroy;
begin
  FPosition.Free;
  //FColumnSummary.Free;
  //FGridSummary.Free;
  FColumnSummaryOptions.Free;
  FColumnSaver.Free;
  FreeGridColumn;
  inherited;
end;

procedure TIndGridColumn.FreeGridColumn;
begin
 if Assigned(FCol) then
 begin
  if not (csDestroying in View.IndGrid.ComponentState) then
   FCol.Free;
  FCol := nil;
 end;

end;

function TIndGridColumn.GetGridView: TIndBaseView;
begin
  Result := TIndGridColumns(Collection).View;
end;

function TIndGridColumn.GetIsBottom: Boolean;
begin
  Result := TcxGridBandedColumn(FCol).Position.Band.IsBottom;
end;

function TIndGridColumn.GetVisible: boolean;
begin
  if Assigned(FCol) then
   Result := TcxGridBandedColumn(FCol).Visible
  else
   Result := False; 
end;

{procedure TIndGridColumn.SetCardColumnProperties(
  ACol: TcxGridDBCardViewRow);
var F:TIndField;
begin
 ACol.DataBinding.FieldName := FieldName;
 if Assigned(DataSet) and Assigned(DataSet.Table)  then
 begin
   F := DataSet.Table.FieldByName(FieldName);
   if Assigned(F) and Assigned(F.Field) then ACol.Caption := F.Field.DisplayLabel;
   ACol.Index := Position.ColIndex;
 end;
end;}

procedure TIndGridColumn.SetPosition(const Value: TIndBandedColumnPosition);
begin
   if Value <> FPosition then
   begin
     FPosition.Assign(Value);
   end;
end;


procedure TIndGridColumn.SetVisible(const Value: boolean);
begin
  TcxGridBandedColumn(FCol).Visible := Value;
end;


procedure TIndGridColumn.SetSize(const Value: integer);
begin
  if Assigned(FCol) then
  begin
     TcxGridDBBandedColumn(FCol).Width := Value
  end;
end;

function TIndGridColumn.GetSize: integer;
begin
 Result := TcxgridBandedColumn(FCol).Width;
end;

function TIndGridColumn.GetAlignment: TAlignment;
begin
  Result := TcxgridBandedColumn(FCol).HeaderAlignmentHorz;
end;

procedure TIndGridColumn.SetAlignment(const Value: TAlignment);
begin
  TcxgridBandedColumn(FCol).HeaderAlignmentHorz := Value;
end;

procedure TIndGridColumn.SetCollection(Value: TCollection);
begin
  inherited;
  if Assigned(Collection)  then
  begin
    if TIndGridColumns(Collection).View.Bands.Count = 0 then TIndGridColumns(Collection).View.Bands.Add;
    CreateGridColumn;
    CreateSummary;
    TcxGridBandedColumn(FCol).Width := 70;
  end;
end;



function TIndGridColumn.FieldEditor: TComponent;
begin
 Result := FCol;
end;

procedure TIndGridColumn.SetDataBindingProperty(const AFieldName: string);
begin
  inherited;
  if Assigned(FCol) then
    TcxGridDBBandedColumn(FCol).DataBinding.FieldName := AFieldName;
end;

procedure TIndGridColumn.UpdateObjectCaption;
begin
  inherited;
  if Assigned(FCol) then
  begin
    if UseFieldCaption then
     FCol.Caption := GetFieldCaption
    else
     FCol.Caption := Caption;
  end;
end;

class function TIndGridColumn.DefaultUseFieldCaption: boolean;
begin
 Result := True;
end;

function TIndGridColumn.CanShowEditors: boolean;
begin
 Result :=  View.IndGrid.CanShowEditors;
end;

function TIndGridColumn.GetFieldEditorProperties: TcxCustomEditProperties;
begin
 Result := nil;
 if Assigned(FCol) then Result := FCol.Properties;
end;

procedure TIndGridColumn.SetFieldEditorPropertiesClass(
  AClass: TcxCustomEditPropertiesClass);
var i:integer;
begin
 inherited;
 if Assigned(FCol) then FCol.PropertiesClass := AClass;
{ //Добавил Степа 10.12.2008
 if Assigned(FCol.Properties) then
 begin
  for i := 0 to FCol.Properties.Buttons.Count - 1 do
  begin
    FCol.Properties.Buttons[I].Visible := False;
  end;
 end;}
 //Конец Добавил Степа 10.12.2008
end;

procedure TIndGridColumn.SetIsEditor;
begin
  inherited;
//  TcxGridDBBandedColumn(FCol).Options.ShowEditButtons := isebDefault;
  TcxGridDBBandedColumn(FCol).Options.Editing := True;
end;

procedure TIndGridColumn.SetNotEditor;
begin
  inherited;
//  TcxGridDBBandedColumn(FCol).Options.ShowEditButtons := isebNever;
  TcxGridDBBandedColumn(FCol).Options.Editing := False;
end;


procedure TIndGridColumn.CheckProperties(Sender: TcxCustomGridTableItem;
  ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);

  procedure fsGetVisibleEnable(const AViewInfo:TIndColumnViewInfo);
  begin
    //Вызов FastScrip-а для определения видимости колонки и свойства Enable
    if Assigned(Field.Table)
       and Assigned(Field.Table.DataProvider)
    then begin
      Field.Table.DataProvider.fsDrawGridCell(AViewInfo);
    end;
  end;

  procedure MakeEmpty;
  begin
    AProperties := gColPropertiesHided;
  end;

  procedure MakeDisable;
  begin
   AProperties.ReadOnly := True;
  end;

var VInf:TIndGridColumnViewInfo;
begin
 VInf := TIndGridColumnViewInfo.Create;
 try
   VInf.GridRecord := ARecord;
   VInf.GridColumn := Sender;
   //Здесь запуск процедуры Fs
   fsGetVisibleEnable(VInf);
   if not VInf.Visible then
   begin
    MakeEmpty;
   end
   else if not VInf.Enabled then
   begin
    MakeDisable;
   end;
 finally
   VInf.Free;
 end;
end;

function TIndGridColumn.IndCanFocus: boolean;
begin
  Result := Assigned(FCol) and FCol.Visible;
end;

function TIndGridColumn.IndFocused: boolean;
begin
  Result := Assigned(FCol) and FCol.Focused;
end;

function TIndGridColumn.IndGetEnable: boolean;
begin
 Result := True;
end;

function TIndGridColumn.IndGetVisible: boolean;
begin
 Result := Assigned(FCol) and FCol.Visible;
end;

procedure TIndGridColumn.IndSetEnable(const AValue: boolean);
begin

end;

procedure TIndGridColumn.IndSetFocus;
begin
  if Assigned(FCol) then FCol.Focused := True;
end;

procedure TIndGridColumn.IndSetVisible(const AValue: boolean);
begin
 if Assigned(FCol) and Assigned(Field.Table) and (Field.Table is TIndOneRecordMetadataTable) then
 begin
   FCol.Visible := AValue;
 end;
end;

constructor TIndGridColumn.Create(Collection: TCollection);
begin
  inherited;
  FColumnSaver := TIndColumnSaver.Create(Self.View.IndGrid);
  FColumnSaver.SavedPersistent := Self;
  FStoredGroupIndex := -1;
end;

function TIndGridColumn.GetGroupIndex: integer;
begin
  Result := TcxGridColumn(FCol).GroupIndex;
end;

procedure TIndGridColumn.SetGroupIndex(const Value: integer);
begin
  if Value <> GroupIndex then
  begin
    TcxGridColumn(FCol).GroupIndex := Value;
    if not (GroupIndex = -1) then
      Visible := False
    else
      Visible := True;
  end;
  StoredGroupIndex := Value;
end;


procedure TIndGridColumn.CreateSummary;
begin
  {FColumnSummary := TIndColumnGroupItem.Create(TcxGridColumn(FCol));
  FGridSummary := TIndGridFooterItem.Create(TcxGridColumn(FCol));}
  FColumnSummaryOptions := TindColumnSummaryOptions.Create;
  FColumnSummaryOptions.FCol := TcxGridColumn(FCol);
  FColumnSummaryOptions.Init;
  View.GridView.DataController.OnGroupingChanged := FColumnSummaryOptions.DoCheckGroupingChanged; 
  //View.GridView.OptionsView.Footer := True;
  //View.GridView.OptionsView.GroupFooters := gfVisibleWhenExpanded;
end;


procedure TIndGridColumn.FieldChanged(Sender: TObject);
begin
  inherited;
 // if Assigned(Field) then
 //    ColumnSummaryOptions.UpdateSummaryKind;
end;

procedure TIndGridColumn.ExpandAll;
var I,RowCount:integer;
begin
  //здесь нельзя делать BeginUpdate (иначе не апдейтятся раскрытые строки!)
   I := 0;
   while I < View.GridView.ViewData.RowCount do
   begin
     if View.GridView.ViewData.Rows[I].Level = GroupIndex then
       View.GridView.ViewData.Rows[I].Expand(False);
     Inc(I);
   end;

end;

procedure TIndGridColumn.UnExpandAll;
var I:integer;
begin
  for I := 0 to View.GridView.ViewData.RowCount - 1 do
  begin
    View.GridView.ViewData.Collapse(True);
  end;
end;

function TIndGridColumn.GetEditValue: Variant;
begin
  Result := FCol.EditValue;
end;

procedure TIndGridColumn.SetEditValue(const Value: Variant);
begin
  inherited;
  FCol.EditValue := Value;
end;

{ TIndBaseView }

procedure TIndBaseView.CreateGridColumns;
begin
// Bands.CreateBands;
 Columns.CreateGridColumns;
end;

procedure TIndBaseView.CreateGridView;
begin
   FGridView := TIndcxGridDBBandedTableView.Create(Grid);
//   TcxGridDBBandedTableView(FGridView).DataController.DataModeController.GridMode := True;
   TcxGridDBBandedTableView(FGridView).DataController.DataModeController.SmartRefresh := False;
   TcxGridDBBandedTableView(FGridView).DataController.Filter.Options := TcxGridDBBandedTableView(FGridView).DataController.Filter.Options + [fcoCaseInsensitive]; 
   TcxGridDBBandedTableView(FGridView).Bands.Clear;
   FGridView.Control := Grid;
   TIndCxGridDBBandedTableView(FGridView).IndView := TIndView(Self);
   FGridLevel := Grid.Levels.Add;
   FGridLevel.GridView := FGridView;
   TcxGridBandedTableView(FGridView).OnColumnPosChanged := DoChangeColumnPosition;
   TcxGridbandedTableView(FGridView).OnBandPosChanged := DoChangeBandPosition;
   TcxGridbandedTableView(FGridView).OnEditing := ViewEditing;
  
//   TcxGridbandedTableView(FGridView).OnInitEdit := InitInternalEditor;
   FGridView.OptionsCustomize.BandsQuickCustomization := True;
   FgridView.OptionsCustomize.ColumnsQuickCustomization := True;

//   if (Bands.Count = 0) then
//      Bands.Add
//   else
      RecreateBands;
   FGridLevel.Parent := Grid.Levels;
   SetGridViewProperties;
   SetDataSource;
   CreateGridColumns;
end;

procedure TIndBaseView.SetGridViewProperties;
begin
  // TcxGridBandedTableView(FGridView).OptionsView.ShowEditButtons := gsebNever;
   TcxGridBandedTableView(FGridView).OnColumnPosChanged := DoChangeColumnPosition;
   TcxGridbandedTableView(FGridView).OnBandPosChanged := DoChangeBandPosition;
   TcxGridbandedTableView(FGridView).OnCustomDrawCell := DoCustomDrawCell;
   TcxGridbandedTableView(FGridView).OnKeyDown := DoGridKeyDown;
   TcxGridbandedTableView(FGridView).OnCellDblClick := DoGridCellDblClick;

   TcxGridbandedTableView(FGridView).OptionsView.Indicator := True;
   TcxGridbandedTableView(FGridView).OptionsSelection.HideFocusRectOnExit := True; //False
   TcxGridbandedTableView(FGridView).OptionsBehavior.CellHints := False;//True;
   TcxGridbandedTableView(FGridView).OptionsBehavior.IncSearch := True;
   TcxGridbandedTableView(FGridView).Styles.IncSearch := dmStyles.sIncSearch;
end;

procedure TIndBaseView.DoCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);


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
     ACanvas.FillRect(AViewInfo.ContentBounds);
     ADone := True;
  end;

  procedure MakeDisable;
  begin
    ACanvas.Font.Color := clGrayText;
  end;

var VInf:TIndGridColumnViewInfo;
begin
 if  AViewInfo.GridView.Control.IsFocused then
 begin
   if  AViewInfo.Focused  then
   begin
    ACanvas.Brush.Color := GetGridFocusedCellFocusedColor;// clHighlight;
    ACanvas.Font.Color := GetGridFocusedCellFocusedColorText;// clHighlightText;
   end
   else if AViewInfo.Selected then
   begin
    ACanvas.Brush.Color := GetGridFocusedCellSelectedColor; // GetLightDownedSelColor;
    ACanvas.Font.Color := GetGridFocusedCellSelectedColorText; //clWindowText;
   end;
 end
 else begin
   if AViewInfo.Focused then
   begin
     ACanvas.Brush.Color := GetGridNotFocusedCellFocusedColor; //GetLightDownedSelColor;
     ACanvas.Font.Color := GetGridNotFocusedCellFocusedColorText;//clWindowText; //clHighlightText;
   end
   else if AViewInfo.Selected then begin
     ACanvas.Brush.Color := GetGridNotFocusedCellSelectedColor;// GetRealColor(GetLightColor(14, 44, 55 //40));
     ACanvas.Font.Color := GetGridNotFocusedCellSelectedColorText;// clWindowText; //clHighlightText;
   end;
 end;

 VInf := TIndGridColumnViewInfo.Create;
 try
   VInf.GridColumn := AViewInfo.Item;
   VInf.GridRecord := AViewInfo.GridRecord;
   //Здесь запуск процедуры Fs
   fsGetVisibleEnable(VInf);
   if not VInf.Visible then
   begin
    AViewInfo.Text := cCellNotVisible;
    MakeEmpty;
   end
   else if not VInf.Enabled then
   begin
    AViewInfo.Text := cCellNotEnable;
    MakeDisable;
   end;
   if VInf.Enabled and VInf.Visible then
   begin
     AViewInfo.Text := cCellOk;
   end;
 finally
   VInf.Free;
 end;


end;

procedure TIndBaseView.SetBandsVisible;
begin
   case ViewType of
    gvTable:  TcxGridBandedTableView(gridView).OptionsView.BandHeaders := False;
    gvBandedTable: TcxGridBandedTableView(gridView).OptionsView.BandHeaders := True;
   end;
end;

procedure TIndBaseView.RecreateBands;
var I:integer;
begin
  for I := 0 to Bands.Count - 1 do
  begin
      Bands.Items[I].CreateBand;
  end;
end;

{procedure TIndBaseView.DataSetChanged;
begin
  inherited;
  FColumns.DataSet := DataSet;
end;}

{procedure TIndBaseView.DataSetTableChanged;
begin
  inherited;
end;}

destructor TIndBaseView.Destroy;
begin
  if Assigned(Table.Table) then  Table.Table.RemoveFetchListener(Self);
  FreeGridView;
  FreeAndNil(FBands);
  FreeAndNil(FColumns);
  FreeAndNil(FTable);
  inherited;
end;

{function TIndGridBands.FindIndColumn(AColumn:TcxGridColumn):TIndGridColumn;
var K:integer;
begin
    Result := nil;
    for K := 0 to Columns.Count - 1 do
    begin
      if TcxGridBandedColumn(Columns.Items[K].FCol) = AColumn then
      begin
         Result := Columns.Items[K];
         Break;
      end;
    end;
end;}


function TindGridBands.FindIndBand(FBand:TcxGridBand):TIndGridBand;
var K:integer;
begin
    Result := nil;
    for K := 0 to Count - 1 do
    begin
      if Items[K].FGridBand = FBand then
      begin
         Result := Items[K];
         Break;
      end;
    end;
end; 


procedure TIndBaseView.DoChangeBandPosition(Sender: TcxGridBandedTableView;
  ABand: TcxGridBand);
var I:integer;
begin
   for I := 0 to Columns.Count -1 do
   begin
       ResetColumn(TcxGridBandedColumn(Columns[I].FCol));
   end

end;

procedure TIndBaseView.ResetColumn(AColumn:TCxGridColumn);
var  AIndColumn:TIndGridColumn;
begin
    AIndColumn := Columns.FindColumn(AColumn);
    AIndColumn.FPosition.FBand := Bands.FindIndBand(TcxGridBandedColumn(AColumn).Position.Band);
end;

procedure TIndBaseView.DoChangeColumnPosition(
  Sender: TcxGridTableView; AColumn: TcxGridColumn);
begin
  ResetColumn(AColumn);
end;

procedure TIndBaseView.FreeGridColumns;
begin
 Columns.FreeGridColumns;
 Bands.FreeBands; 
end;

procedure TIndBaseView.FreeGridView;
begin
  FreeGridColumns;
  if Assigned(FGridView)  then FreeAndNil(FGridView);
  if Assigned(FGridLevel)  then FreeAndNil(FGridLevel);
end;


function TIndBaseView.GetGrid: TcxCustomGrid;
begin
 if Assigned(FIndGrid) then Result := FIndGrid.FGrid
 else Result := nil;
end;

procedure TIndBaseView.RecreateGridView;
begin
 SetBandsVisible;
end;

procedure TIndBaseView.SetBands(const Value: TIndGridBands);
begin
 if Value <> FBands then
  FBands.Assign(Value);
end;


procedure TIndBaseView.SetColumns(const Value: TIndGridColumns);
begin
 if Value <> FColumns then
  FColumns.Assign(Value);
end;


procedure TIndBaseView.SetDataSource;

  procedure InnerSetDataSource(ADataSource:TDataSource);
  begin
    TcxGridDBBandedTableView(FGridView).DataController.DataSource := ADataSource
  end;

var t:TIndBaseTable;
begin
   t := ViewTable;
   if Assigned(t) then
    InnerSetDataSource(t.DataSource)
   else
    InnerSetDataSource(nil);
end;

procedure TIndBaseView.SetIndGrid(const Value: TIndGrid);
begin
 if Value <> FIndGrid then
  FIndGrid := Value;
end;


procedure TIndBaseView.SetViewType(const Value: TIndGridViewType);
begin
 if FViewType <> Value then
 begin
  FViewType := Value;
  RecreateGridView;
 end;
end;

function TIndBaseView.ViewTable: TIndBaseTable;
begin
 Result := Table.Table;
end;


procedure TIndbaseView.SetDataSet(const Value: TIndBaseDataSet);
begin
 FTable.DataSet := Value;
end;


function TIndGridColumn.GetPosition: TIndBandedColumnPosition;
begin
   Result := FPosition;
end;

function TIndBaseView.GetBandsVisible: boolean;
begin
   Result := TcxGridBandedTableView(GridView).OptionsView.BandHeaders;
end;

procedure TIndGridBand.CreateBand;
var AParentBand:TIndGridBand;
begin
  if Assigned(FGridBand) then Exit;
  FGridBand := TcxGridbandedTableView(View.GridView).Bands.Add;
  if Position.BandIndex <> - 1 then
  begin
    AParentBand := View.Bands[Position.BandIndex];
    if not Assigned(AParentBand.FGridBand) then AParentBand.CreateBand;
    FGridBand.Position.BandIndex := AParentband.Index;
  end;
end;



procedure TIndBaseView.FetchLimited(Sender:TObject);
begin
 DoFetchLimitChanged(Sender);
end;

procedure TIndBaseView.UpdateTableProperties;
//var P1,P2:TNotifyEvent;
begin
  if Assigned(Table) and Assigned(Table.Table) then
  begin
   if (not (csDestroying in Table.Table.ComponentState))  then
   begin
    Table.Table.AddFetchListener(Self);
    Table.BeforeTableChange := DoBeforeTableChange;
    DoFetchLimitChanged(Table.Table);
{    P1 := IndGrid.DoOnTableStateChange;
    P2 := Table.Table.OnStateChange;
    if @P1 <> @P2 then
    begin
     FPreviousOnTableStateChange := Table.Table.OnStateChange;
     Table.Table.OnStateChange := IndGrid.DoOnTableStateChange;
    end;}
   end;
  end;
end;

procedure TIndBaseView.TableChanged(Sender: TObject);
begin
 if Assigned(FGridView) then
 begin
   SetDataSource;
   UpdateTableProperties;
   if Assigned(Table) and Assigned(Table.Table) then
     GridView.DataController.KeyFieldNames := Table.Table.Metadata.FieldsMetadata.PKFieldNamesNoDetails;
//   GridView.DataController.KeyFieldNames := DataSet.Table.DataProvider.GetFieldIdName;
 end;
 if Assigned(FOnTableChanged) then FOnTableChanged(Self);
end;

function TIndBaseView.GetDataSet: TIndBaseDataSet;
begin
  Result := FTable.DataSet;
end;

procedure TIndBaseView.DoFetchLimitChanged(Sender: TObject);
begin
  IndGrid.ChangeStatusPanelText;
  {if TIndBaseTable(Sender).FetchLimited and (TIndBaseTable(Sender).FetchLimit > 0) and TIndBaseTable(Sender).Data.Active and (TIndBaseTable(Sender).Data.RecordCount = TIndBaseTable(Sender).FetchLimit) then
    StatusMessage := Format(GetMessageString(idFetchLimited,langFetchLimited),[TIndMetadataTable(Sender).FetchLimit])
  else
    StatusMessage := '';}
end;

{function TIndBaseView.GetStatusMessage: string;
begin
 Result := IndGrid.StatusPanel.StatusMessage;
end;

procedure TIndBaseView.SetStatusMessage(const Value: string);
begin
  IndGrid.StatusPanel.SetStatusMessage(Value);
end;}

{procedure TIndBaseView.DataSetTableChanged;
begin
  inherited;
  Ftable := nil;
end;}

procedure TIndBaseView.DoBeforeTableChange(const Sender: TObject;
  const OldTable, NewTable: TIndMetadataTable);
begin
 if Assigned(OldTable) {and (not (csDestroying in OldTable.ComponentState))} then
 begin
    OldTable.RemoveFetchListener(Self);
//    OldTable.OnStateChange := FPreviousOnTableStateChange;
 end;
// FPreviousOnTableStateChange := nil;
end;

function TIndBaseView.GetColumnAutoWidth: boolean;
begin
  Result := TcxGridbandedTableView(FGridView).OptionsView.ColumnAutoWidth;
end;

procedure TIndBaseView.SetColumnAutoWidth(const Value: boolean);
begin
 TcxGridbandedTableView(FGridView).OptionsView.ColumnAutoWidth := Value;
end;

constructor TIndBaseView.Create(AGrid:TIndGrid);
begin
  inherited Create;
  FTable := TIndTableRef.Create(AGrid);
  FTable.OnTableChanged := TableChanged;
  FTable.BeforeTableChange := BeforeTableChanged;
  FBands := TIndGridBands.Create(Self);
  FColumns := TIndGridColumns.Create(Self);
  IndGrid := AGrid;
  CreateGridView; //modified
  ViewType := gvBandedTable;
  BandAutoWidth := True;
end;

procedure TIndBaseView.BeforeTableChanged(const Sender:TObject; const OldTable:TIndMetadataTable; const NewTable:TIndMetadataTable);
begin
 if Assigned(OldTable) then
 begin
  OldTable.RemoveGridEventListener(IndGrid);
 end;
 if Assigned(NewTable) then
 begin
  NewTable.AddGridEventListener(IndGrid);
 end;
end;


procedure TIndBaseView.SetTable(const Value: TIndTableRef);
begin
 FTable.Assign(Value);
end;

function TIndBaseView.GetTable: TIndTableRef;
begin
 Result := FTable;
end;


procedure TIndBaseView.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TIndBaseView) then
  begin
    BandAutoWidth := TIndBaseView(Source).BandAutoWidth;
    ViewType := TIndBaseView(Source).ViewType;
  end
  else
   inherited;
end;

procedure TIndBaseView.DblClickAction;
begin
 //ShowMessage('Enter', nil);
 Application.ProcessMessages;
 IndGrid.Manager.ExecuteDefaultAction;
end;

procedure TIndBaseView.DoGridCellDblClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  if (AButton = mbLeft) and (AShift = [ssLeft,ssDouble]) then
    DblClickAction;
end;

procedure TIndBaseView.DoGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Key = 13) and (Shift = []) then
    DblClickAction;
end;

procedure TIndBaseView.ViewEditing(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem; var AAllow: Boolean);
var m:TIndField;
    f:TField;
begin
 AAllow := True;
 if Assigned(Table.Table) then
 begin
  f := TcxGridItemDBDataBinding(AItem.DataBinding).Field;
  if not Assigned(F) then exit;
  m := TIndField(F.Tag);
  AAllow := (AItem.FocusedCellViewInfo.Text = cCellOk) and AllowShowEditor(Table,F,M);
  if AAllow then
    DoAfterEditing(AItem);
 end;
end;

function TIndBaseView.GetGroupBox: boolean;
begin
 Result := FGridView.OptionsView.GroupByBox;
end;

procedure TIndBaseView.SetGroupBox(const Value: boolean);
begin
 FGridView.OptionsView.GroupByBox := Value;
 FGridView.OptionsCustomize.ColumnGrouping := Value;
end;

function TIndBaseView.GetColumnHeaders: boolean;
begin
 Result := FGridView.OptionsView.Header;
end;

procedure TIndBaseView.SetColumnHeaders(const Value: boolean);
begin
 FGridView.OptionsView.Header := Value;
end;

procedure TIndBaseView.FetchNoLimited(Sender: TObject);
begin
 DoFetchLimitChanged(Sender); 
end;

procedure TIndBaseView.DoAfterEditing(AItem: TcxCustomGridTableItem);
begin
  TIndCxGridDbBandedTableView(GridView).DoAfterEditingGrid(AItem);
end;

procedure TIndBaseView.DoOnClickViewButton;
begin
  Columns.FindColumn(GridView.Controller.FocusedColumn).DoButtonViewClick(IndGrid);
end;

procedure TIndBaseView.DoStateChanged(Sender: TObject);
begin
 IndGrid.DoOnTableStateChange(Sender);
end;

{procedure TIndBaseView.InitInternalEditor(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
begin
  TIndCxGridDBbandedTableView(FGridView).InitEditorButtons;
end;}

{ TIndGridBands }

function TIndGridBands.Add: TIndGridBand;
begin
 Result := TIndGridBand(inherited Add);
end;


constructor TIndGridBands.Create(AOwner:TIndBaseView);
begin
  inherited Create(AOwner,AOwner.Table,TIndGridBand);
end;


destructor TIndGridBands.Destroy;
begin
  FreeBands;
  inherited;
end;

procedure TIndGridBands.FreeBands;
var i:integer;
begin
  for i := 0 to Count - 1 do
  begin
   Items[i].FreeBand;
  end;
end;

procedure TIndGridBands.GetBottomItemsList(AList: TIndList);
var I:integer;
begin
   AList.Clear;
   for I := 0 to Count - 1 do
   begin
      if Items[I].IsBottom then
         AList.Add(Items[I]);
   end;
end;

function TIndGridBands.GetItems(AIndex: integer): TIndGridBand;
begin
 Result := TIndGridBand(inherited GetItem(AIndex));
end;

function TIndGridBands.GetView: TIndBaseView;
begin
 Result := TIndBaseView(Owner);
end;


procedure TIndGridBands.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
var I:integer;
    AColList:TIndList;
begin
  inherited;
  if Action = cnDeleting then
  begin
   if (not (csDestroying in View.Grid.ComponentState )) then
   begin
     if Count = 1 then
       raise ECheckException.Create(GetMessageString(idMustHaveOneBand,langMustHaveOneBand));
   end;
   if TIndGridBand(Item).IsBottom then
    begin
     AColList := TIndList.Create;
     try
       TIndGridBand(Item).GetColumns(AColList);
       for I := AColList.Count - 1 downto 0 do
       begin
          TIndGridColumns(View.Columns).Delete(TIndGridColumn(AColList[I]).Index);
       end;
     finally
       AColList.Clear;
       AColList.Free;
     end;
    end;
  end;
end;

procedure TIndGridBands.SetItems(AIndex: integer;
  const Value: TIndGridBand);
begin
 inherited SetItem(AIndex, Value);
end;

procedure TIndGridBands.Update(Item: TCollectionItem);
begin
  inherited;
  View.GridView.Changed(vcSize);
end;

function TIndGridBands.FindIndBandByName(FName: string): TIndGridBand;
var I:integer;
begin
   Result := nil;
   for I := 0 to Count - 1 do
   begin
      if Items[I].Name = FName then
         Result := Items[I];
   end;
end;

procedure TIndGridBands.Loaded;
begin
 if Count = 0 then Add;
end;

function TIndGridBands.GetVisibleCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    if Items[i].Visible then
      Result := Result + 1;
end;

{ TIndGridColumns }

function TIndGridColumns.Add: TIndGridColumn;
begin
 Result := TIndGridColumn(inherited Add);
end;

constructor TIndGridColumns.Create(AOwner: TIndBaseView);
begin
 inherited Create(AOwner,AOwner.Table,TIndGridColumn);
end;

procedure TIndGridColumns.CreateGridColumns;
var i:integer;
begin
 for i := 0 to Count - 1 do
 begin
   Items[i].CreateGridColumn;
 end;
end;

{procedure TIndGridColumns.DatasetTableChanged;
begin
  inherited;

end;}

destructor TIndGridColumns.Destroy;
begin

  inherited;
end;

function TIndGridColumns.FindByName(AColName: string): TIndGridColumn;
var ColIndex:integer;
begin
   Result := nil;
   for ColIndex := 0 to Count - 1 do
   begin
      if IndUpper(Items[ColIndex].Name) = IndUpper(AColName) then
      begin
         Result := Items[ColIndex];
         Break;
      end;
   end;
end;

function TIndGridColumns.FindColumn(
  const Value: TcxCustomGridTableItem): TIndGridColumn;
var i:integer;
begin
   Result := nil;
   for i := 0 to Count -1 do begin
       if TIndGridColumn(Items[i]).FCol = Value then
          Result := TIndgridColumn(Items[i]);
   end;
end;

procedure TIndGridColumns.FreeGridColumns;
var i:integer;
begin
 for i := 0 to Count - 1 do
 begin
   Items[i].FreeGridColumn;
 end;
end;

function TIndGridColumns.GetItems(AIndex: integer): TIndGridColumn;
begin
 Result := TIndGridColumn(inherited GetItem(AIndex));
end;

function TIndGridColumns.GetView: TIndBaseView;
begin
 Result := TIndBaseView(Owner);
end;


procedure TIndGridColumns.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;
end;

procedure TIndGridColumns.SetItems(AIndex: integer;
  const Value: TIndGridColumn);
begin
 inherited SetItem(AIndex, Value);
end;

procedure TIndGridColumns.Update(Item: TCollectionItem);
begin
  inherited;
end;

{ TIndDetailViews }


{ TIndDataItemCollection }


constructor TIndFieldItemCollection.Create(AOwner: TPersistent; ATable:TIndTableRef; ItemClass: TCollectionItemClass);
begin
 FTable := ATable;
 inherited Create(AOwner, ItemClass);
end;


function TIndFieldItemCollection.GetDataSet: TIndBaseDataSet;
begin
 if Assigned(FTable) then Result := FTable.DataSet
 else Result := nil;
end;

function TIndFieldItemCollection.GetTable: TIndTableRef;
begin
 Result := FTable;
end;

procedure TIndFieldItemCollection.SetDataSet(const Value: TIndBaseDataSet);
begin
 if Value <> DataSet then
 begin
   FTable.DataSet := Value;
 end;
end;

{ TIndDataItem }

{procedure TIndDataItem.DataSetChanged;
begin

end;}

{procedure TIndDataItem.DataSetTableChanged;
begin

end;}

procedure TIndFieldItem.FieldChanged(Sender: TObject);
begin

end;

procedure TIndFieldItem.FieldMetadataChanged(Sender: TObject);
begin

end;

function TIndFieldItem.GetDataSet: TIndBaseDataSet;
begin
 if Assigned(FField.TableRef) then Result := FField.TableRef.DataSet
 else Result := nil;
end;

procedure TIndFieldItem.SetCollection(Value: TCollection);
begin
 if Value <> Collection then
 begin
  if (Value = nil) and Assigned(FField) and Assigned(Collection)
     and (Collection is TIndFieldItemCollection) then
  begin
   if Assigned(TIndFieldItemCollection(Collection).Table) and Assigned(FField) then
   begin
     TIndFieldItemCollection(Collection).Table.DeleteFieldRef(FField);
   end;
   FField := nil;
  end;
 end;
 inherited;
 if Assigned(Collection) and  (Collection is TIndFieldItemCollection) then
 begin
   FField := TIndFieldItemCollection(Collection).Table.AddFieldRef;
   FField.OnFieldChanged := FieldChanged;
   FField.Control := Self;
   FField.OnFieldMetadataChanged := FieldMetadataChanged;
 end
 else
  FField := nil;
end;


procedure TIndFieldItemCollection.SetTable(const Value: TIndTableRef);
begin
 if Value <> FTable then
  FTable.Assign(Value);
end;

{ TIndGridBand }

procedure TIndGridBand.AddColumn(AColumn: TIndGridColumn);
var ACol:TcxGridbandedColumn;
begin
  ACol := TcxGridBandedTableView(View.GridView).CreateColumn;
  ACol.Position.BandIndex := FGridBand.Index;
  TIndBandedColumnPosition(AColumn.Position).FBand := Self;
end;

class function TIndGridBand.BaseName: string;
begin
 Result := 'Band';
end;

constructor TIndGridBand.Create(ACollection:TCollection);
begin
  FPosition := TIndBandPosition.Create(Self);
  FPosition.OnChange := PositionChanged;
  inherited;
  FGridBand := TcxGridDBBandedTableView(View.GridView).Bands.Add;
end;


destructor TIndGridBand.Destroy;
begin
  FreeBand;
  FreeAndNil(FPosition);
  inherited;
end;

procedure TIndGridBand.FreeBand;
begin
 if Assigned(FGridBand) then
 begin
   FGridBand.Bands.Delete(FGridBand.Index);
   FGridBand := nil;
 end;
end;

function TIndGridBand.GetGridView: TIndBaseView;
begin
  Result := TIndGridBands(Collection).View;
end;


procedure TIndGridBand.PositionChanged(Sender: TObject);
begin
 UpdateBandProperties;
end;

procedure TIndGridBand.RemoveColumn(AColumn: TIndGridColumn);
begin
  TIndBandedColumnPosition(AColumn.Position).FBand := nil;
  FGridBand.MoveColumn(TcxgridBandedColumn(AColumn.FCol),-1,-1);
end;

procedure TIndGridBand.SetBandProperties(ABand: TcxGridBand);
begin
 ABand.Position.BandIndex := Position.BandIndex;
 ABand.Position.ColIndex := Position.ColIndex;
end;



procedure TIndGridBand.SetPosition(const Value: TIndBandPosition);
begin
 if Value <> FPosition then
 begin
   FPosition.Assign(Value);
 end;
end;

procedure TIndGridBand.SetVisible(Value: Boolean);
begin
  if FgridBand.Visible <> Value then begin
     View.GridView.BeginUpdate;
     try
      FGridBand.Visible := Value;
     finally
      View.GridView.endUpdate;
     end;
  end;
end;

procedure TIndGridBand.UpdateBandProperties;
begin
 if Assigned(FGridBand) then
 begin
  SetBandProperties(FGridBand);
 end;
end;

function TIndGridBand.GetIsBottom: Boolean;
begin
  Result := FGridBand.IsBottom;
end;

procedure TIndGridBand.RemoveBand;
var ABandToAdd:TcxGridband;
begin
   ABandToAdd := TcxgridBandedTableView(TIndGridBands(Collection).View.GridView).Bands.Add;
   GridBand.Position.bandIndex := ABandToAdd.index;
   ABandToAdd.Free;
end;

procedure TIndGridBand.MoveBand(ABand: TIndGridBand; AColIndex: Integer);
begin
  FGridBand.MoveBand(ABand.FGridBand,AColIndex);
end;

procedure TIndGridBand.SetWidth(const Value: integer);
begin
  GridBand.Width := Value;
end;

function TIndGridBand.GetWidth: integer;
begin
  Result := Gridband.Width;
end;

function TIndGridBand.GetVisible: Boolean;
begin
  Result := GridBand.Visible;
end;

procedure TIndGridBand.MoveColumn(AColumn: TIndGridColumn; ARowIndex,
  AColIndex: Integer);
begin
  FGridBand.MoveColumn(TcxGridBandedColumn(AColumn.FCol),ARowIndex,AColIndex);
end;

function TIndGridBand.GetGridBand: TcxGridBand;
begin
  if FGridBand.Position.BandIndex <> -1 then
    Result := FgridBand.ParentBand
  else
    Result := nil;
end;

procedure TIndGridBand.SetGridBand(const Value: TcxGridBand);
begin
   FGridBand.Position.BandIndex := Value.Index
end;


procedure TIndGridBand.GetColumns(AList: TIndList);
var I:Integer;
begin
   AList.Clear;
   for I := 0 to View.Columns.Count - 1 do
   begin
       if View.Columns.Items[I].Position.FBand = Self then
          AList.Add(View.Columns.Items[I]);
   end;

end;

function TIndGridBand.GetFixedKind: TcxGridBandFixedKind;
begin
 Result := FGridBand.FixedKind;
end;

procedure TIndGridBand.SetFixedKind(const Value: TcxGridBandFixedKind);
begin
 FGridBand.FixedKind := Value;
end;


procedure TIndGridBand.FieldChanged(Sender: TObject);
begin
  inherited;
  UpdateBandProperties;
end;

procedure TIndGridBand.UpdateObjectCaption;
begin
  inherited;
  if Assigned(FGridBand) then
  begin
   if UseFieldCaption then
    FGridBand.Caption := GetFieldCaption
   else
    FGridBand.Caption := Caption;
  end;
end;

{ TIndGridStructureNavigator }

function TIndGridStructureNavigator.CalculateBoundsRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
  OffsetRect(Result, Grid.ClientBounds.Right - Result.Right - NavigatorOffset,
    Grid.ClientBounds.Bottom - Result.Bottom - NavigatorOffset);

end;


procedure TIndGridStructureNavigator.GetSelection(AList: TIndList);
var ASelectionList:TIndList;
    I:integer;
    SelectionItem:TPersistent;
begin
    AList.Clear;
    SelectionItem := nil;
    ASelectionList := Designer.SelectionObject;
    for I := 0 to ASelectionList.Count - 1 do begin
      if Assigned(ASelectionList[I]) and (TPersistent(ASelectionList[I]) is TIndGridBand) then
         SelectionItem := TIndGridBand(ASelectionList[I]).FGridBand
      else if Assigned(ASelectionList[I]) and (TPersistent(ASelectionList[I]) is TIndGridColumn) then
         SelectionItem := TIndGridColumn(ASelectionList[I]).FCol;
     // else
     //    SelectionItem := ASelectionList[I];
      if Assigned(SelectionItem) then
        AList.Add(SelectionItem);
    end;
end;

function TIndGridStructureNavigator.IsObjectSelected(
  AObject: TPersistent): Boolean;
var
  AList: TIndList;
  I:integer;
begin
  Result := False;
  AList := TIndList.Create;
  try
    GetSelection(AList);
    for I := 0 to AList.Count - 1 do
    begin
      if TObject(AList[I]) is TcxGridband then
      begin
         if TcxGridBand(AList[I]) = AObject then
         begin
            Result := True;
            Break;
         end;
      end else if TObject(AList[I]) is TcxGridColumn then
      begin
         if TcxGridColumn(AList[I]) = Aobject then
         begin
            Result := True;
            Break;
         end;
      end;
    end;
  finally
    AList.Clear;
    AList.Free;
  end;

end;


function TIndGridStructureNavigator.GetIndGrid:TIndGrid;
begin
   Result := TIndGrid(Grid.Parent);
end;


function TIndGridStructureNavigator.FindIndObj(AObj:TPersistent):TIndNamedItem;
var I:integer;
    AIndGrid:TIndGrid;
begin
    Result := nil;
    AIndGrid := GetIndGrid;
    if not Assigned(AIndGrid) then exit;
    if AObj is TcxGridBand then
    begin
       for I := 0 to AIndGrid.FView.Bands.Count - 1 do
       begin
          if AIndGrid.FView.Bands[I].FGridBand = AObj then
          begin
             Result := AIndGrid.FView.Bands[I];
             Exit;
          end;
       end;
    end else if AObj is TcxGridColumn then
    begin
        for I := 0 to AIndGrid.FView.Columns.Count - 1 do
        begin
          if AIndGrid.FView.Columns.Items[I].FCol = AObj then
          begin
             Result := AIndGrid.FView.Columns.Items[I];
             Break;
          end;
        end;
    end;
end;

procedure TIndGridStructureNavigator.SelectObject(AObject: TPersistent;
  AClearSelection: Boolean);
var AList:TIndList;
begin
{  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.ColumnMoving := not Designer.RvreadOnly;
  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.ColumnSorting := not Designer.RvreadOnly;
  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.ColumnSorting := not Designer.RvreadOnly;
  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.ColumnHorzSizing := not Designer.RvreadOnly;
  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.ColumnGrouping := not Designer.RvreadOnly;
  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.ColumnsQuickCustomization := not Designer.RvreadOnly;
  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.BandMoving := not Designer.RvreadOnly;
  TcxGridBandedTableView(Grid.ActiveView).OptionsCustomize.BandSizing := not Designer.RvreadOnly;}


  if AClearSelection then begin
    try
      Designer.SelectionObject.Clear;
      Designer.SelectionObject.BeginUpdate;
      Designer.SelectionObject.Add(FindIndObj(AObject));
      Grid.ActiveView.Changed(vcSize);
    finally
      Designer.SelectionObject.EndUpdate;
    end;
  end else begin
    AList := TIndList.Create;
    try
      GetSelection(AList);
      AList.Add(AObject);
      SetSelection(AList);
      Grid.ActiveView.Changed(vcSize);
    finally
      AList.Clear;
      AList.Free;
    end;
  end;
end;

procedure TIndGridStructureNavigator.SetSelection(AList: TIndList);
var
  I: Integer;
  AddItem:TIndNamedItem;
begin
  if Designer = nil then Exit;
  Designer.SelectionObject.Clear;
  Designer.SelectionObject.BeginUpdate;
  try
    for I := 0 to AList.Count - 1 do
    begin
      if (TPersistent(AList[I]) is TcxGridBand) or
         (TPersistent(Alist[I]) is TcxGridColumn) then
      begin
       AddItem := FindIndObj(TPersistent(AList[I]));
       if Assigned(AddItem) then
          Designer.SelectionObject.Add(Additem);
      end else
       Designer.SelectionObject.Add(AList[I]);
    end;
  finally
    Designer.SelectionObject.EndUpdate;
  end;
end;

procedure TIndGridStructureNavigator.UnselectObject(AObject: TPersistent);
var
  AList: TIndList;
begin
  if not IsObjectSelected(AObject) then Exit;
  AList := TIndList.Create;
  try
    GetSelection(AList);
    AList.Remove(AObject);
    SetSelection(AList);
  finally
    AList.Clear;
    AList.Free;
  end;

end;



function TIndGridStructureNavigator.GetWindowDesigner: TWindowDesigner;
begin
  Result := GetDesigner(Grid);
end;

{ TIndBandPosition }

procedure TIndBandPosition.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TIndBandPosition then
  begin
    BandIndex := TIndBandPosition(Source).BandIndex;
    ColIndex := TIndBandPosition(Source).ColIndex;
  end;
end;

procedure TIndBandPosition.Changed;
begin
 if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TIndBandPosition.Create(ABand: TIndGridBand);
begin
  Fband := ABand;
end;

function TIndBandPosition.GetBandIndex: Integer;
begin
  if Fband.ParentBand = nil then
    Result := -1
  else
    Result := View.Bands.FindIndBand(Fband.ParentBand).Index;
end;

function TIndBandPosition.GetColIndex: Integer;
begin
 // if Fband.ParentBand = nil then
 //   Result := FBand.FGridBand.Position.ColIndex
 // else
    Result := Fband.FGridBand.Position.ColIndex;

end;

function TIndBandPosition.GetGridView: TIndBaseView;
begin
  Result := TIndGridBands(Fband.Collection).View; 
end;

procedure TIndBandPosition.SetBandIndex(Value: integer);
var I:integer;
    AParentBand:TIndGridBand;
    AColList:TIndList;
begin
  if Value <> BandIndex then begin
  View.Bands.BeginUpdate;
  View.GridView.BeginUpdate;
    try
      if Value <> -1 then
      begin
        FBand.ParentBand := View.Bands.Items[Value].FGridBand;
        FBand.Index := FBand.Gridband.Index;
        AParentBand := TIndGridBands(FBand.Collection).FindIndBand(FBand.ParentBand);
        AColList := TIndList.Create;
        try
          AParentBand.GetColumns(AColList);
          for I := AColList.Count - 1 downto 0 do
             TindGridColumn(AColList[I]).Position.FBand := FBand;
        finally
         AColList.Clear;
         AColList.Free;
        end;
      end else
      begin
        FBand.RemoveBand;
      end;
    finally
      View.GridView.EndUpdate;
      View.Bands.EndUpdate;
    end;
  end;
end;

procedure TIndBandPosition.SetColIndex(const Value: integer);
begin
  if ColIndex <> Value then
  begin
    View.GridView.BeginUpdate;
    try
      if FBand.ParentBand = nil then
        FBand.GridBand.Position.ColIndex := Value
      else begin
        Fband.ParentBand.MoveBand(FBand.Gridband,Value);
      end;
    finally
      View.GridView.EndUpdate;
    end;
  end;
end;

{ TIndColumnPosition }

procedure TIndBandedColumnPosition.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TIndBandedColumnPosition then
  begin
    ColIndex := TIndBandedColumnPosition(Source).ColIndex;
    BandIndex := TIndBandedColumnPosition(Source).BandIndex;
    RowIndex := TIndbandedColumnPosition(Source).RowIndex;
  end;
end;

function TIndBandedColumnPosition.GetbandIndex: integer;
begin
  if Assigned(Fband) then
    Result := View.Bands.FindIndBand(Fband.FGridBand).Index
  else
    result := -1;
end;

function TIndBandedColumnPosition.GetColIndex: integer;
begin
  if (csLoading in View.IndGrid.ComponentState) then
    Result := FStoredColIndex 
  else
    Result := TcxGridBandedColumn(FItem.FCol).Position.ColIndex;
end;

function TIndBandedColumnPosition.GetRowIndex: integer;
begin
    Result := TcxGridBandedColumn(FItem.FCol).Position.RowIndex;

end;

procedure TIndBandedColumnPosition.SetBandIndex(const Value: integer);
begin
  View.GridView.BeginUpdate;
  try
    TcxGridBandedColumn(Item.FCol).Position.BandIndex := Value;
    if Value <> - 1 then
      FBand := View.Bands.Items[Value]
    else
      FBand := nil;
  finally
    View.GridView.EndUpdate;
    View.GridView.Changed(vcSize);
  end;

end;

procedure TIndBandedColumnPosition.SetColIndex(const Value: integer);
begin
 //в том случае, если производим загрузку, нельзя
 //сразу ставить индекс позиции столбца, поскольку не все столбцы загружены (см.пояснение в
 //объявлении класса)
 if (csLoading in View.IndGrid.ComponentState) then
 begin
   FStoredColIndex := Value;
   Exit;
 end;  
 if (Value <> ColIndex) and (Value >= 0) then
 begin
      View.GridView.BeginUpdate;
      try
        TcxGridBandedColumn(Item.FCol).Position.ColIndex := Value;
      finally
        View.GridView.EndUpdate;
        View.FGridView.Changed(vcSize);
      end;
 end;
end;

procedure TIndBandedColumnPosition.SetRowIndex(const Value: integer);
begin
  if (FBand <> nil) and (RowIndex <> Value) then begin
      if Value >= 0 then
      begin
        View.GridView.BeginUpdate;
        try
          TcxGridBandedColumn(Item.FCol).Position.RowIndex := Value;
        finally
          View.GridView.EndUpdate;
        end;
        View.GridView.Changed(vcSize);
      end;
  end;
end;

{ TIndColPosition }

procedure TIndColumnPosition.Assign(Source: TPersistent);
begin
  if Source is TIndColumnPosition then
    ColIndex := TIndColumnPosition(Source).ColIndex
  else inherited;
end;

constructor TIndColumnPosition.Create(ACol: TIndGridColumn);
begin
  FItem := ACol;
end;

function TIndColumnPosition.GetColIndex: integer;
begin
  Result := TcxGridColumn(FItem.FCol).Index;
end;

function TIndColumnPosition.GetGridView: TIndBaseView;
begin
  Result := TIndGridColumn(FItem).View;
end;

procedure TIndColumnPosition.SetColIndex(const Value: integer);
begin
 if (Value <> TcxGridColumn(FItem).Index) and (Value >= 0) then
   View.GridView.BeginUpdate;
   try
     TcxGridColumn(FItem).Index := Value;
   finally
     View.gridView.EndUpdate;
   end;  

end;

{ TIndGridStatusPanel }

function TIndGridStatusPanel.CanAcceptControls: boolean;
begin
 Result := False;
end;

constructor TIndGridStatusPanel.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csAcceptsControls,csFixedWidth,csNoStdEvents];
  Caption :='';
  Color := clBtnShadow;
  Font.Color := clBtnFace;
  BevelOuter := bvNone;
end;

destructor TIndGridStatusPanel.Destroy;
begin

  inherited;
end;

function TIndGridStatusPanel.GetStatusMessage: string;
begin
  Result := Caption;
end;

procedure TIndGridStatusPanel.SetParentControl(const Value: TWinControl);
begin
  if Value <> FParentControl then
  begin
   Parent := Value;
   Align := alBottom;
   Height := 20;
   FParentControl := Value;
   Hide;
  end;
end;

procedure TIndGridStatusPanel.SetStatusMessage(const Value: string);
begin
  Caption := Value;
  Visible := Value <> '';
end;

procedure TIndFieldItem.SetField(Value: TIndFieldRef);
begin
 if Assigned(FField) then FField.Assign(Value);
end;


{ TIndView }

function TIndView.PropertyName: string;
begin
 Result := 'View';
end;





{ TIndFieldEditorItem }

function TIndFieldEditorItem.CanFindFormManagers: boolean;
begin
 Result :=  Assigned(FFieldId) and Assigned(FFieldId.Metadata);
end;

procedure TIndFieldEditorItem.DecodeIndFields;
var m:TIndFieldMetadataObj;
    mTp:TIndFieldMetadataBaseRefTp;
begin
   FieldId := nil;
   FieldFullName := nil;
   FieldTypeId := nil;
   FieldTypeName := nil;
   FieldVisualRepresentation := nil;
   if Assigned(FField) and Assigned(FField.Field) and Assigned(FField.Field.Metadata) then
   begin
    case FField.Field.Metadata.DataType of
      dtRefObj,dtParent: begin
       FieldId := FField.Field.FieldMain;
       FieldFullName := FField.Field.FieldForDisplay;
      end;
      dtObj:begin
        m := TIndFieldMetadataObj(FField.Field.Metadata);
        FieldId := FField.Field.FieldMain;
        FieldFullName :=  FField.Field.FieldForDisplay;
        FieldTypeId := FieldId.Owner.FieldByName(m.ObjTypeMetadata.FieldName);
        FieldVisualRepresentation := FieldTypeId.FieldMain.FieldVisualRepresentation;
        FieldTypeName := FieldTypeId.FieldMain.FieldName;
      end;
      dtObjType:begin
       FieldFullName := FField.Field.FieldMain.FieldForDisplay;
       FieldTypeId := FField.Field.FieldMain;
       FieldId := FieldTypeId;
       FieldVisualRepresentation := FField.Field.FieldMain.FieldVisualRepresentation;
      end;
      dtRefTp, dtParentTp: begin
        mTp := TIndFieldMetadataBaseRefTp(FField.Field.Metadata);
        FieldId := FField.Field.FieldMain;
        FieldFullName :=  FField.Field.FieldForDisplay;
      end;
      else begin
       FieldFullName := FField.Field;
      end;
    end; {case}
   end;
   SetFieldEditorProperties;
end;

procedure TIndFieldEditorItem.DoButtonClearClick(
  const SelectControl: TWinControl);

 procedure DoClearFieldId;
 begin
   if Assigned(FFieldId) and Assigned(FFieldId.Field) and (not FFieldId.Field.ReadOnly) and FFieldId.Field.DataSet.CanModify then
   begin
    if FFieldId.Field.DataSet.State <> dsEdit then FFieldId.Field.DataSet.Edit;
    FFieldId.Field.Value := null;
   end;
 end;

begin
 FCurrentSelectControl := SelectControl;
 case Field.Field.Metadata.DataType of
 dtObj: begin
   DoClearFieldId;
   TcxCustomTextEdit(FCurrentSelectControl).Text := VarToStrDef(FieldFullName.Value,'');
 end;
 dtObjType: begin
   DoClearFieldId;
   TcxCustomTextEdit(FCurrentSelectControl).Text := VarToStrDef(FieldFullName.Value,'');
 end;
 dtRefObj:begin
   DoClearFieldId;
   TcxCustomTextEdit(FCurrentSelectControl).Text := VarToStrDef(FieldFullName.Value,'');
 end;
 end;
end;

procedure TIndFieldEditorItem.DoButtonSelectClick(
  const SelectControl: TWinControl);

 procedure RunSelect;
 begin
   GetFormManagerSelect;
   if Assigned(BrowseFormManager) then
   begin
    if Assigned(FFieldId) and Assigned(FFieldId.Field) then
    begin
                             
       BrowseFormManager.Select(FieldEditor,
                                SelectControl ,
                                Table,
                                Table,
                                FFieldId,
                                DoSelectRecord);
    end;
   end;
 end;

begin
 FCurrentSelectControl := SelectControl;
 case Field.Field.Metadata.DataType of
    dtRefObj:  RunSelect;
    dtObj: begin
      if Assigned(FFieldTypeId) and IsNullId(FFieldTypeId.Value) then
       DoButtonTypeClick(SelectControl)
      else RunSelect;
    end;
 end;
end;

procedure TIndFieldEditorItem.DoButtonTypeClick(
  const SelectControl: TWinControl);
var SaveVal:variant;
begin
 FCurrentSelectControl := SelectControl;
 case Field.Field.Metadata.DataType of
  dtObjType,dtObj: begin
    SaveVal := FieldTypeId.Value;
    ButtonObjTypeClick(FieldTypeId);
    if (not FieldTypeId.Field.ReadOnly) and  (FieldTypeId.Value <> SaveVal)
       and (not IsNullId(FieldTypeId.Value))
    then begin
      TcxCustomTextEdit(FCurrentSelectControl).Text := VarToStrDef(FieldFullName.Value,'');
      DoButtonSelectClick(SelectControl);
    end;
  end;
 end;
end;

procedure TIndFieldEditorItem.DoButtonViewClick(
  const SelectControl: TWinControl);
begin
 FCurrentSelectControl := SelectControl;
 case Field.Field.Metadata.DataType of
   dtRefObj:
   begin
     GetFormManagerView;
     if Assigned(EditFormManager) and Assigned(FFieldId) and
       (not FFieldId.Field.IsNull)
     then begin
      EditFormManager.View(FFieldId.Value);
     end;
   end;
   dtObj:
   begin
     GetFormManagerObjView;
     if  Assigned(EditFormManager) and (EditFormManager.Metadata.DataObj.Id = FFieldTypeId.Value)
      and (EditFormManager.Metadata.DataObj.ObjRefType = orRefObj) then
     begin
       EditFormManager.View(FFieldId.Value);
     end;
   end;
 end;
end;

procedure TIndFieldEditorItem.GetFormManagerObjView;
begin
 if CanFindFormManagers  then
 begin
  if (not FormManagerEditValid) then
  begin
    try
    //Определяем менеджеры форм
     EditFormManager := dmConnection.Configuration.CreateEditFormByObjId(FFieldTypeId.Value,'');
    except
      on E:Exception do
      begin
       EditFormManager := nil;
       ShowWarning(E.Message);
      end;
    end;
  end;
 end
 else begin
  EditFormManager := nil;
 end;
end;

procedure TIndFieldEditorItem.DoIndButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var b:TcxEditButton;
begin
 if (Sender is TcxButtonEdit) then
 begin
   b := TcxButtonEdit(Sender).Properties.Buttons[AButtonIndex];
   if Assigned(b) then
   begin
    if AButtonIndex = FButtonSelect.Index then
     DoButtonSelectClick(TcxButtonEdit(Sender))
    else if AButtonIndex = FButtonView.Index then
     DoButtonViewClick(TcxButtonEdit(Sender))
    else if AButtonIndex = FButtonClear.Index then
     DoButtonClearClick(TcxButtonEdit(Sender))
    else if AButtonIndex = FButtonType.Index then
     DoButtonTypeClick(TcxButtonEdit(Sender));
   end;
 end;
end;

procedure TIndFieldEditorItem.DoSelectRecord(const ATable: TComponent;
  var ACloseForm: boolean);
begin
 case Field.Field.Metadata.DataType of
 dtRefObj:begin
   if Assigned(FFieldId) and Assigned(FFieldId.Field) and (not FFieldId.Field.ReadOnly) then
   begin
    if FFieldId.Field.DataSet.CanModify then
    begin
      if FFieldId.Field.Value <> TIndMetadataTable(ATable).Fields.FieldByName(cFieldId).Value then
      begin
        {if  TIndFieldMetadataBaseObj(Field.Field.Metadata).IsTreeParent then
        begin
         if (TIndMetadataTable(ATable).Fields.FieldByName(cFieldId).Value = TIndMetadataTable(ATable).IdField.Value) then
          Raise Exception.Create('Циклическая зависимость');
        end;}
        if (FFieldId.Field.DataSet.State <> dsEdit) then FFieldId.Field.DataSet.Edit;
        FFieldId.Field.Value := TIndMetadataTable(ATable).Fields.FieldByName(cFieldId).Value;
        TcxButtonEdit(FCurrentSelectControl).Text := VarToStrDef(FFieldFullName.Value,'');
      end;
    end;
   end;
 end;
 dtObj: begin
   if Assigned(FFieldId) and Assigned(FFieldId.Field) and (not FFieldId.Field.ReadOnly) then
   begin
    if FFieldId.Field.DataSet.CanModify then
    begin
      if (FFieldId.Field.DataSet.State <> dsEdit) then FFieldId.Field.DataSet.Edit;
      FFieldId.Field.Value := TIndMetadataTable(ATable).Fields.FieldByName(cFieldId).Value;
      TcxButtonEdit(FCurrentSelectControl).Text := VarToStrDef(FFieldFullName.Value,'');
    end;
   end;
 end;
 end;
end;

procedure TIndFieldEditorItem.FieldChanged(Sender: TObject);
begin
  inherited;
  DecodeIndFields;
end;

function TIndFieldEditorItem.FieldEditor: TComponent;
begin
 Result := nil;
end;

function TIndFieldEditorItem.FormManagerEditValid: boolean;
begin
 if FFieldId.Metadata is TIndFieldMetadataBaseObj then
 begin
   Result := Assigned(EditFormManager)
             and (EditFormManager.Metadata.DataObj.Ident =  TIndFieldMetadataBaseObj(FFieldId.Metadata).ObjIdentUp)
             and (EditFormManager.Metadata.DataObj.ObjRefType = orRefObj);
 end
 else begin
   Result := Assigned(EditFormManager)
             and (EditFormManager.Metadata.DataObj.Id =  FFieldTypeId.Value)
             and (EditFormManager.Metadata.DataObj.ObjRefType = orRefObj);
 end;
end;

function TIndFieldEditorItem.FormManagerSelectValid: boolean;
begin
 if FFieldId.Metadata is TIndFieldMetadataBaseObj then
 begin
  Result := Assigned(BrowseFormManager)
            and (BrowseFormManager.Metadata.DataObj.Ident =  TIndFieldMetadataBaseObj(FFieldId.Metadata).ObjIdentUp)
            and (BrowseFormManager.Metadata.DataObj.ObjRefType = orRefObj)
 end
 else begin
  Result := Assigned(BrowseFormManager)
            and (BrowseFormManager.Metadata.DataObj.Id =  FFieldTypeId.Value)
            and (BrowseFormManager.Metadata.DataObj.ObjRefType = orRefObj)
 end;
end;

procedure TIndFieldEditorItem.GetFormManagerSelect;
var pFormManager:TIndBrowseFormManager;
begin
 if CanFindFormManagers then
 begin
  if (not FormManagerSelectValid) then
  begin
    pFormManager := nil;
    try
    //Определяем менеджеры форм
    if FFieldId.Metadata is TIndFieldMetadataBaseObj then
    begin
     if not IsNullId(TIndFieldMetadataBaseObj(FFieldId.Metadata).ObjId) then
       pFormManager := dmConnection.Configuration.CreateSelectFormByObjId(TIndFieldMetadataBaseObj(FFieldId.Metadata).ObjId,'')
     else
       pFormManager := dmConnection.Configuration.CreateSelectFormByObjId(TIndFieldMetadataBaseObj(FFieldId.Metadata).ObjIdentUp,'');
    end
    else begin
     pFormManager := dmConnection.Configuration.CreateSelectFormByObjId(FieldTypeId.Value,'');
    end;
    except
      on E:Exception do
      begin
       pFormManager := nil;
       ShowWarning(E.Message);
      end;
    end;
    if Assigned(pFormManager) then BrowseFormManager := pFormManager;
  end;
 end
 else begin
  BrowseFormManager := nil;
 end;
end;

procedure TIndFieldEditorItem.GetFormManagerView;
var pFormManager:TIndEditFormManager;
begin
 if CanFindFormManagers then
 begin
  if (not FormManagerEditValid) then
  begin
    pFormManager := nil;
    try
    //Определяем менеджеры форм
     pFormManager := dmConnection.Configuration.CreateEditFormByObjIdent(TIndFieldMetadataBaseObj(FFieldId.Metadata).ObjIdentUp,'');
     EditFormManager := pFormManager;
    except
      on E:Exception do
      begin
       EditFormManager := nil;
       ShowWarning(E.Message);
      end;
    end;
  end;
 end
 else
  EditFormManager := nil;
end;

procedure TIndFieldEditorItem.SetDataBindingProperty(
  const AFieldName: string);
begin

end;

procedure TIndFieldEditorItem.SetFieldVisualRepresentation(const Value: TIndField);
begin
 if Value <> FFieldVisualRepresentation then
  FFieldVisualRepresentation := Value;
end;

procedure TIndFieldEditorItem.SetNotEditor;
begin
{   TcxGridDBBandedColumn(FCol).Options.ShowEditButtons := isebNever;
  TcxGridDBBandedColumn(FCol).Options.Editing := False;}
end;

procedure TIndFieldEditorItem.SetIsEditor;
begin
{   TcxGridDBBandedColumn(FCol).Options.ShowEditButtons := isebDefault;
  TcxGridDBBandedColumn(FCol).Options.Editing := True;}
end;


procedure TIndFieldEditorItem.SetFieldEditorProperties;
var m:TIndFieldMetadata;
    pEd:TComponent;
    PropUpdater:TIndPropertiesUpdater;
begin
 FButtonSelect := nil;
 FButtonView := nil;
 FButtonClear := nil;
 FButtonType := nil;
 pEd := FieldEditor;
 if Assigned(pEd) then
 begin
  if Assigned(FField.Field) then
  begin
   m := FField.Field.Metadata;
   if Assigned(m) then
   begin
   // SetFieldEditorPropertiesClass(m.EditConstructor.EditPropertiesClass);

    try
      PropUpdater := m.EditConstructor.PropertiesUpdaterClass.Create(nil); //SetFieldEditorPropertiesClass(Self);
      //PropUpdater.OnSetupGridEditProperties := m.EditConstructor.SetupGridEditProperties;
      m.EditConstructor.LoadFromDFM(m.Editor.EditorBlob,PropUpdater);
      SetFieldEditorPropertiesClass(PropUpdater.EditPropertiesClass);
      {m.EditConstructor}PropUpdater.SetupGridEditProperties(Self,FField.Field,m,GetFieldEditorProperties,
                          DoIndButtonClick,
                          FButtonSelect,
                          FButtonView,
                          FButtonClear,
                          FButtonType);
      PropUpdater.UpdateProperties(Self,GetFieldEditorProperties);
    finally
      FreeAndNil(PropUpdater);
    end;  
    FIndButtonSelect.cxButton := FButtonSelect;
    FIndButtonView.cxButton := FButtonView;
    FIndButtonClear.cxButton := FButtonClear;
    FIndButtonType.cxButton := FButtonType;
    //Можно ли показывать редактор
    if (m.DataType in [dtText, dtTextRich, dtPicture]) or (CanShowEditors) then
      SetIsEditor
    else
      SetNotEditor;
   end
   else begin
    SetFieldEditorPropertiesClass(TcxTextEditProperties);
    SetNotEditor;
   end;
  end
  else begin
    SetFieldEditorPropertiesClass(TcxTextEditProperties);
    SetNotEditor;
  end;
 end;
end;

procedure TIndFieldEditorItem.SetFieldFullName(const Value: TIndField);
begin
 if Value <> FFieldFullName then
 begin
  FFieldFullName := Value;
  if Assigned(FFieldFullName) and Assigned(FFieldFullName.Field) then
  begin
    SetDataBindingProperty(FFieldFullName.Field.FieldName);
  //  UpdateObjectCaption;
  end
  else  SetDataBindingProperty('');
 end;
end;

procedure TIndFieldEditorItem.SetFieldId(const Value: TIndField);
begin
 if Value <> FFieldId then
  FFieldId := Value;
end;

procedure TIndFieldEditorItem.SetFieldTypeId(const Value: TIndField);
begin
 if Value <> FFieldTypeId then
  FFieldTypeId := Value;
end;

procedure TIndFieldEditorItem.SetFieldTypeName(const Value: TIndField);
begin
 if Value <> FFieldTypeName then
  FFieldTypeName := Value;
end;

procedure TIndFieldEditorItem.ShowWarning(const aText: string);
begin
 if Assigned(FieldId) and Assigned(FieldId.Metadata)
  then
   MessageMonitor.AddWarning(AText,  TIndTableMetadata(FieldId.Metadata.TableMetadata).MetaName + '.' + FieldId.Metadata.MetaName);
end;

function TIndFieldEditorItem.CanShowEditors: boolean;
begin
 Result := True;
end;

function TIndFieldEditorItem.GetFieldEditorProperties: TcxCustomEditProperties;
begin
 Result := nil;
end;

procedure TIndFieldEditorItem.SetFieldEditorPropertiesClass(
  AClass: TcxCustomEditPropertiesClass);
begin

end;


function TIndFieldEditorItem.FormManagerDeleteNotify(
  FormManager: TObject): boolean;
begin
  Result := False; //Не надо меня удалять
  if FormManager = BrowseFormManager then
    BrowseFormManager := nil;
  if FormManager = EditFormManager then
    EditFormManager := nil;
end;

procedure TIndFieldEditorItem.SetBrowseFormManager(
  const Value: TIndBrowseFormManager);
begin
 if Value <> FBrowseFormManager then
 begin
  if Assigned(FBrowseFormManager) then
  begin
   FBrowseFormManager.RemoveNotifyObj(Self);
   FBrowseFormManager.DeleteOwnerForms(FieldEditor);
  end;
  FBrowseFormManager := Value;
  if Assigned(FBrowseFormManager) then FBrowseFormManager.AddNotifyObj(Self);
 end;
end;

procedure TIndFieldEditorItem.SetEditFormManager(
  const Value: TIndEditFormManager);
begin
 if Value <> FEditFormManager then
 begin
  if Assigned(FEditFormManager) then FEditFormManager.RemoveNotifyObj(Self);
  FEditFormManager := Value;
  if Assigned(FEditFormManager) then FEditFormManager.AddNotifyObj(Self);
 end;
end;

destructor TIndFieldEditorItem.Destroy;
begin
  if Assigned(BrowseFormManager) then BrowseFormManager := nil;
  if Assigned(EditFormManager) then EditFormManager := nil;
  if Assigned(FIndButtonSelect) then
     FreeAndNil(FIndButtonSelect);
  if Assigned(FIndButtonView) then
             FreeAndNil(FIndButtonView);
  if Assigned(FIndButtonClear) then
             FreeAndNil(FIndButtonClear);
  if Assigned(FIndButtonType) then
             FreeAndNil(FIndButtonType);
  if Assigned(FIndButtonBrowse) then
             FreeAndNil(FIndButtonBrowse);
  inherited;
end;

constructor TIndFieldEditorItem.Create(Collection: TCollection);
begin
  inherited;
  FIndButtonSelect := TIndButton.Create;
  FIndButtonView := TIndButton.Create;
  FIndButtonClear := TIndButton.Create;
  FIndButtonType := TIndButton.Create;
  FindButtonBrowse := TIndButton.Create;
  HideBrowseButton;
end;

function TIndFieldEditorItem.FindButton(
  AButton: TcxEditButton): TIndButton;
begin
  Result := nil;
  if AButton = FIndButtonSelect.cxButton then
    Result := FIndButtonSelect
  else if AButton = FIndButtonView.cxButton then
    Result := FIndButtonView
  else if AButton = FIndButtonClear.cxButton then
    Result := FIndButtonClear
  else if AButton = FIndButtonType.cxButton then
    Result := FIndButtonType;
end;

procedure TIndFieldEditorItem.ShowBrowseButton;
begin
  if not Assigned(FIndButtonBrowse.cxButton) then
  begin
    FIndButtonBrowse.cxButton := TcxEditButton(GetFieldEditorProperties.Buttons.Add);
    MakeButtonGlyph(FIndButtonBrowse.cxButton,cIndButtonImageView);
  end;
  FIndButtonBrowse.cxButton.Visible := True;
end;

procedure TIndFieldEditorItem.HideBrowseButton;
begin
  if Assigned(FIndButtonBrowse.cxButton) then
    FIndButtonBrowse.cxButton.Visible := False;
end;

function TIndFieldEditorItem.IsEditButton(AButton: TcxEditButton): boolean;
begin
  Result := not (AButton = FIndButtonBrowse.cxButton); 
end;

function TIndFieldEditorItem.GetEditValue: Variant;
begin
  Result := Null;
end;

procedure TIndFieldEditorItem.SetEditValue(const Value: Variant);
begin

end;

{ TIndFieldItemCaption }

class function TIndFieldItemCaption.DefaultUseFieldCaption: boolean;
begin
 Result := False;
end;

procedure TIndFieldItemCaption.FieldChanged(Sender: TObject);
begin
  inherited;
  if UseFieldCaption then
  begin
    UpdateObjectCaption;
  end;
end;

procedure TIndFieldItemCaption.FieldMetadataChanged(Sender: TObject);
begin
  inherited;
  if UseFieldCaption then
  begin
    UpdateObjectCaption;
  end;
end;

function TIndFieldItemCaption.GetFieldCaption: string;
begin
 if Assigned(Field) and Assigned(Field.Field) and Assigned(Field.Field.FieldForDisplay)
   and Assigned(Field.Field.FieldForDisplay.Metadata)
 then
  Result := Field.Field.FieldForDisplay.Metadata.FieldDisplayLabel
 else if Assigned(Field) then
  Result := Field.Name
 else
  Result :='';
end;

procedure TIndFieldItemCaption.SetCaption(const Value: string);
begin
 if Value <> FCaption then
 begin
  FCaption := Value;
  UpdateObjectCaption;
 end;
end;

procedure TIndFieldItemCaption.SetCollection(Value: TCollection);
begin
  inherited;
  UseFieldCaption := DefaultUseFieldCaption;
end;

procedure TIndFieldItemCaption.SetUseFieldCaption(const Value: boolean);
begin
 if Value <> FUseFieldCaption then
 begin
  FUseFieldCaption := Value;
  UpdateObjectCaption;
 end;
end;

procedure TIndFieldItemCaption.UpdateObjectCaption;
begin
 if UseFieldCaption {and (trim(FCaption) = '')} then
 begin
  FCaption := GetFieldCaption;
 end;
end;

{ TIndGridManager }
function TIndGridManager.GetTableRef: TIndTableRef;
begin
  if Owner is TIndGrid then
  begin
    Result := TIndGrid(Owner).Table;
  end
  else Result := nil;
end;


function TIndGridManager.GetGroupName: string;
begin
 if Owner is TIndGrid then
  Result := Owner.Name
 else
  Result := Self.Name;
end;


procedure TIndFieldItem.SetControl(const Value: TObject);
begin
 if Value <> FControl then
  FControl := Value;
end;


function TIndFieldItem.GetControl: TObject;
begin
 Result := FControl;
end;

function TIndFieldItem._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef else
    Result := -1;
end;

function TIndFieldItem._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release else
    Result := -1;
end;

procedure TIndFieldItem.AfterConstruction;
begin
  inherited;
  if GetOwner <> nil then
    GetOwner.GetInterface(IInterface, FOwnerInterface);
end;

function TIndFieldItem.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then Result := 0 else Result := E_NOINTERFACE;
end;

function TIndFieldItem.IndCanFocus: boolean;
begin
 Result := IndControlCanFocus(FControl);
end;

function TIndFieldItem.IndFocused: boolean;
begin
 Result := IndControlFocused(FControl);
end;

function TIndFieldItem.IndGetEnable: boolean;
begin
 Result := IndGetControlEnabled(FControl);
end;

function TIndFieldItem.IndGetVisible: boolean;
begin
 Result := IndGetControlVisible(FControl);
end;

procedure TIndFieldItem.IndSetEnable(const AValue: boolean);
begin
 IndSetControlEnabled(FControl,AValue);
end;

procedure TIndFieldItem.IndSetFocus;
begin
 IndControlSetFocus(FControl);
end;

procedure TIndFieldItem.IndSetVisible(const AValue: boolean);
begin
 IndSetControlVisible(FControl,AValue);
end;

constructor TIndFieldItem.Create(Collection: TCollection);
begin
  inherited;
  FControl := nil;
end;

destructor TIndFieldItem.Destroy;
begin
  FControl := nil;
  inherited;
end;


{ TIndGridColumnViewInfo }

function TIndGridColumnViewInfo.GetFieldValue: variant;
begin
 Result := FGridRecord.Values[FGridColumn.Index];
end;

function TIndGridColumnViewInfo.GetValueInfo(const AFieldName: string;
  var AExists: boolean): variant;
var i:integer;
    s:string;
begin
 Result := null;
 AExists := False;
 s := IndUpper(AFieldName);
 if s = FieldName then
 begin
  Result := FieldValue;
  AExists := True;
 end
 else begin
  for i := 0 to FGridColumn.GridView.ItemCount - 1 do
  begin
   if IndUpper(TcxGridDBBandedColumn(FGridColumn.GridView.Items[i]).DataBinding.FieldName) = s then
   begin
    AExists := True;
    Result := GridRecord.Values[TcxGridDBBandedColumn(FGridColumn.GridView.Items[i]).Index];
    break;
   end;
  end;
 end;
end;

procedure TIndGridColumnViewInfo.SetGridColumn(
  const Value: TcxCustomGridTableItem);
var f:TIndField;
begin
  FGridColumn := Value;
  SetFieldName(TcxGridDBBandedColumn(FGridColumn).DataBinding.FieldName);
  if Assigned(TcxGridDBBandedColumn(FGridColumn).DataBinding.Field) then
  begin
   f := TIndField(TcxGridDBBandedColumn(FGridColumn).DataBinding.Field.Tag);
   SetTable(f.Table);
   SetField(f);
  end
  else begin
   SetTable(nil);
   SetField(nil);
  end;
end;

{ TIndGridSaver }

function TIndGridSaver.GetGrid: TIndGrid;
begin
  Result := TIndGrid(SavedComponent);
  if not Assigned(Storage) then Exit;
  if not Assigned(Result) then
    raise Exception.Create(LocalizeGrids(idMustBeAssignedSaveGridString,
      langMustBeAssignedSaveGridString));
end;

procedure TIndGridSaver.GetStorageProperties(const AValue:{TStringList}TIndStorePropertiesList);
begin
  inherited GetStorageProperties(AValue);
  AValue.Properties['ShowGroupFooter'].Value := IntToStr(integer(TIndGrid(SavedComponent).View.GridView.OptionsView.GroupFooters));
  AValue.Properties['ShowFooter'].Value := BoolToStr(TIndGrid(SavedComponent).View.GridView.OptionsView.Footer);
  SaveExpandedColumns;
  if Trim(FExpandedData.Text) = '' then
    AValue.Properties['ExpandedRows'].Value := ' '
  else
    AValue.Properties['ExpandedRows'].Value := Trim(FExpandedData.Text);


  AValue.Properties['KeyValue'].Value := VarToStrDef(TIndGrid(SavedComponent).KeyFieldsValueAsString,'');
//  SaveGroupProperties(AValue);

end;

procedure TIndGridSaver.SetStorageProperties(const AValue: {TStringList}TIndStorePropertiesList);
begin
  inherited;
  TindGrid(SavedComponent).View.GridView.OptionsView.GroupFooters := TcxgridGroupFootersMode(StrToIntDef(AValue.Properties['ShowGroupFooter'].Value,Ord(TindGrid(SavedComponent).View.GridView.OptionsView.GroupFooters)));
  if AValue.Properties['ShowFooter'].Value <> '' then
    TindGrid(SavedComponent).View.GridView.OptionsView.Footer := StrToBoolDef(AValue.Properties['ShowFooter'].Value,TindGrid(SavedComponent).View.GridView.OptionsView.Footer);
//  LoadGroupProperties(AValues);
  FExpandedData.Text := Trim(AValue.Properties['ExpandedRows'].Value);
  if AValue.Properties['KeyValue'].Value <> '' then
  begin
    TIndGrid(SavedComponent).KeyFieldsValueAsString := AValue.Properties['KeyValue'].Value;
  end;
end;


procedure TIndGridSaver.LoadComponentsFromStorage;
var ItemIndex:integer;
    NotLoadedColumns:array of TIndGridColumn;
begin
    inherited;
    if not Assigned(Storage) then Exit;
    Storage.LoadPropertiesFromStorage(Self);
    for ItemIndex := 0 to Grid.View.Columns.Count - 1 do
    begin
      LoadComponent(Grid.View.Columns[ItemIndex].ColumnSaver);
      if Grid.View.Columns[ItemIndex].ColumnSaver.PositionNotLoaded then
      begin
         SetLength(NotLoadedColumns,Length(NotLoadedColumns) + 1);
         NotLoadedColumns[Length(NotLoadedColumns)-1] := Grid.View.Columns[ItemIndex]; 
      end;
    end;  

    for ItemIndex := 0 to Length(NotLoadedColumns) - 1 do
      NotLoadedColumns[ItemIndex].Position.ColIndex := Grid.View.Columns.Count;
    SetColumnsStoredPosition;
end;

procedure TIndGridSaver.SetColumnsStoredPosition;
//var I:integer;
//    SortList:TStringList;
begin
{  SortList := TStringList.Create;
  try
    for I := 0 to Grid.View.Columns.Count - 1 do
      SortList.AddObject(IntToStr(TIndGridColumn(Grid.View.Columns[I]).StoredGroupIndex),Grid.View.Columns[I]);
    SortList.Sort;
    for I := 0 to SortList.Count - 1 do
      TIndGridColumn(SortList.Objects[I]).GroupIndex := TIndGridColumn(SortList.Objects[I]).StoredGroupIndex;
  finally
    SortList.Free;
  end;}
  FSimpleGroupIndexUpdater.View := Grid.View;
  FSimpleGroupIndexUpdater.SortAndUpdate;
end;

procedure TIndGridSaver.SaveComponentsToStorage;
var ItemIndex:integer;
begin
    inherited;
    if not Assigned(Storage) then Exit;
    Storage.SavePropertiesToStorage(Self);
    for ItemIndex := 0 to Grid.View.Columns.Count - 1 do
       SaveComponent(Grid.View.Columns[ItemIndex].FColumnSaver);
end;

procedure TIndGridSaver.LoadExpandedColumns;
var I:integer;
    ARow:TcxCustomGridRow;
begin
  if not Assigned(Grid) then
    Exit;
  if FExpandedData.Count > 0 then
  begin
    I := 0;
    while I < Grid.View.GridView.ViewData.RowCount do
    begin
      if CheckRowValues(Grid.View.GridView.ViewData.Rows[I],FExpandedData) then
      begin
        ARow := Grid.View.GridView.ViewData.Rows[I];
        ARow.Expand(False);
      end;
      Inc(I);
    end;
  end;
end;

function TIndGridSaver.SaveColumns:string;
var I:integer;
    SavedRowValues:string;
    SL:TStrings;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Grid.View.GridView.ViewData.RowCount - 1 do
    begin
       if (not Grid.View.GridView.ViewData.Rows[I].HasCells) and Grid.View.GridView.ViewData.Rows[I].Expanded then
       begin
         SavedRowValues := GetValuesForGroupRow(Grid.View.GridView.ViewData.Rows[I]);
         if Trim(SavedRowValues) <> '' then
          SL.Add(SavedRowValues);
       end;
    end;
    Result := SL.Text;
  finally
    FreeAndNil(SL);
  end;  
end;

function TIndGridSaver.CheckRowValues(ARow: TcxCustomGridRow;
  CheckValues: TStrings): boolean;
var I:integer;
    ComparedValues:TStringList;

    function CorrectParent:boolean;
    begin
      Result := not Assigned(ARow.ParentRecord) or
                (ARow.ParentRecord.DisplayTexts[0] = ComparedValues.Values['ParentRecord']);
    end;

    function CheckRowCurrentValues:boolean;
    var I:integer;
    begin
      Result := True;
      if ARow.HasCells then
      begin
        Result := False;
        Exit;
      end;

      if CannotBeExpanded(ARow.Level) then
      begin
        Result := False;
        Exit;
      end;

      if (ComparedValues.Count <= ARow.Level) or
         (ComparedValues.Strings[ARow.Level] <> ARow.DisplayTexts[ARow.Level]) or
          not CorrectParent then
         Result := False;
    end;

begin
  Result := AlwaysExpanded(GetRowLevel(ARow));
  if Result then Exit;
  
  ComparedValues := TStringList.Create;
  ComparedValues.Delimiter := '+';
  try
    for I := 0 to CheckValues.Count - 1 do
    begin
       ComparedValues.DelimitedText := CheckValues.Strings[I];
       Result := CheckRowCurrentValues;
       if Result then Break;
    end;
  finally
    FreeAndNil(ComparedValues);
  end;
end;


{procedure TIndGridSaver.SaveGroupProperties(const AStorage: TStrings);
begin
  if Trim(FExpandedData.Text) = '' then
    AStorage.Values['ExpandedRows'] := ' '
  else
    AStorage.Values['ExpandedRows'] := Trim(FExpandedData.Text);
end;}

constructor TIndGridSaver.Create(AOwner: TComponent);
begin
  inherited;
  FExpandedData := TStringList.Create;
  FSimpleGroupIndexUpdater := TIndSimpleUpdaterGroupIndex.Create;
end;

destructor TIndGridSaver.Destroy;
begin
  FreeAndNil(FExpandedData);
  FreeAndNil(FSimpleGroupIndexUpdater);
  inherited;
end;

function TIndGridSaver.GetValuesForGroupRow(
  ARow: TcxCustomGridRow): string;
var ResultList:TStringList;
    ParentRecord:TcxCustomGridRecord;
begin
  Result := ' ';
  ResultList := TStringList.Create;
  ResultList.Delimiter := '+';
  ResultList.Add(ARow.DisplayTexts[0]);
  try
    ParentRecord := ARow.ParentRecord;
    while Assigned(ParentRecord) do
    begin
      ResultList.Insert(0,ParentRecord.DisplayTexts[0]);
      ParentRecord := ParentRecord.ParentRecord;
    end;
    ResultList.Values['ParentRecord'] := GetParentText(ARow);
    Result := ResultList.DelimitedText;
  finally
    FreeAndNil(ResultList);
  end;
end;

function TIndGridSaver.GetParentText(ARow: TcxCustomGridRow): string;
begin
  Result := '';
  if Assigned(ARow.ParentRecord) then
    Result := ARow.ParentRecord.DisplayTexts[0];
end;

function TIndGridSaver.CannotBeExpanded(Level: Integer): boolean;
begin
  if Level = -1 then
    Result := False
  else
    Result := FindGroupColumn(Level).AlwaysClose;
end;

function TIndGridSaver.AlwaysExpanded(Level: Integer): boolean;
begin
  if Level = -1 then
    Result := False
  else
    Result := FindGroupColumn(Level).AlwaysExpand;
end;

function TIndGridSaver.FindGroupColumn(Level: Integer): TIndGridColumn;
var I:integer;
begin
  Result := nil;
  for I := 0 to Grid.View.Columns.Count - 1 do
  begin
     if Grid.View.Columns[I].GroupIndex = Level then
     begin
       Result := Grid.View.Columns[I];
       Break;
     end;
  end;
end;

function TIndGridSaver.GetRowLevel(ARow: TcxCustomGridRow): integer;
begin
  if ARow.HasCells then
    Result := -1
  else
    Result := ARow.Level;
end;


procedure TIndGridSaver.SaveExpandedColumns;
begin
  if not Assigned(Grid) then
    Exit;
  FExpandedData.Text := SaveColumns;
end;

{ TIndColumnSaver }

function TIndColumnSaver.GetSaveOwner: TComponent;
begin
  Result := TIndGridColumn(SavedPersistent).View.IndGrid.Owner;
end;

procedure TIndColumnSaver.GetStorageProperties(const AValue:TIndStorePropertiesList{TStringList});
begin
  AValue.Clear;
  AValue.Properties['Width'].Value := IntToStr(TIndGridColumn(SavedPersistent).Width);
  AValue.Properties['Width'].WriteScreenSize := True;
  AValue.Properties['RowIndex'].Value := IntToStr(TIndGridColumn(SavedPersistent).Position.RowIndex);
  AValue.Properties['LineCount'].Value := IntToStr(TcxGridBandedColumnPosition(TcxGridBandedColumn(
      TIndGridColumn(SavedPersistent).FCol).Position).LineCount);
  //сохраняем свойства только в том случае, если не установлен Column с полем RecNo
 { if TIndGridColumn(SavedPersistent).View.IndGrid.FIndGridRecnoChecker.FindRecnoCol = nil then
  begin}
    AValue.Properties['Index'].Value := IntToStr(TIndGridColumn(SavedPersistent).Position.ColIndex);
    AValue.Properties['GroupIndex'].Value := IntToStr(TcxGridColumn(TIndGridColumn(SavedPersistent).FCol).GroupIndex);
    AValue.Properties['BandIndex'].Value := IntToStr(TIndGridColumn(SavedPersistent).Position.BandIndex);
    AValue.Properties['Visible'].Value :=  BoolToStr(TIndGridColumn(SavedPersistent).Visible);
    AValue.Properties['SortOrder'].Value := IntToStr(Integer(TcxGridColumn(TIndGridColumn(SavedPersistent).FCol).SortOrder));
//  end;
  SaveGridFooters(AValue);
  SaveExpandedData(AValue);
end;

procedure TIndColumnSaver.SetStorageProperties(const AValue:TIndStorePropertiesList{ TStringList});
begin
  if AValue.IsEmpty then
  begin
    PositionNotLoaded := True;
    Exit;
  end;  
  TIndGridColumn(SavedPersistent).Width := StrToIntDef(AValue.Properties['Width'].Value,TIndGridColumn(SavedPersistent).Width);
  TIndGridColumn(SavedPersistent).Position.RowIndex := StrToIntDef(AValue.Properties['RowIndex'].Value,TIndGridColumn(SavedPersistent).Position.RowIndex);
  TcxGridBandedColumnPosition(TcxGridBandedColumn(TIndGridColumn(SavedPersistent).FCol).Position).LineCount :=
     StrToIntDef(AValue.Properties['LineCount'].Value,TcxGridBandedColumnPosition(TcxGridBandedColumn(TIndGridColumn(SavedPersistent).FCol).Position).LineCount);

  //загружаем свойства только в том случае, если не установлен Column с полем RecNo
{  if TIndGridColumn(SavedPersistent).View.IndGrid.FIndGridRecnoChecker.FindRecnoCol = nil then
  begin}
    TIndGridColumn(SavedPersistent).Position.ColIndex := StrToIntDef(AValue.Properties['Index'].Value,TIndGridColumn(SavedPersistent).Position.ColIndex);
    TIndGridColumn(SavedPersistent).StoredGroupIndex := StrToIntDef(AValue.Properties['GroupIndex'].Value,TIndGridColumn(SavedPersistent).GroupIndex);
    TIndGridColumn(SavedPersistent).Position.BandIndex := StrToIntDef(AValue.Properties['BandIndex'].Value,TIndGridColumn(SavedPersistent).Position.BandIndex);
    TIndGridColumn(SavedPersistent).Visible := StrToBoolDef(AValue.Properties['Visible'].Value,TIndGridColumn(SavedPersistent).Visible);
    TcxGridColumn(TIndGridColumn(SavedPersistent).FCol).SortOrder := TcxDataSortOrder(StrToIntDef(AValue.Properties['SortOrder'].Value,0));

//  end;
  LoadGridFooters(AValue);
  //не можем вызывать отсюда, так как на данный момент
  //данные еще не загружены
//  TIndGridColumn(SavedPersistent).ExpandedData.Assign(Value);
  LoadExpandedData(AValue);
end;

procedure TIndColumnSaver.LoadGridFooters(const AStorage: TIndStorePropertiesList{TStringList});
begin
  FIndgridFooterSaver.LoadGridFooters(AStorage);
  FIndDefaultGroupFooterSaver.LoadGridFooters(AStorage);
  FIndGroupFooterSaver.LoadGridFooters(AStorage);
end;

procedure TIndColumnSaver.SaveGridFooters(const AStorage: TIndStorePropertiesList{TStringList});
begin
  FIndGridFooterSaver.SaveGridFooters(AStorage);
  FIndDefaultGroupFooterSaver.SaveGridFooters(AStorage);
  FIndGroupFooterSaver.SaveGridFooters(AStorage); 
end;


function TIndColumnSaver.GetStoreObjectName: string;
begin
  Result := TIndGridColumn(SavedPersistent).Name;
end;

function TIndColumnSaver.GetPersistentStorager:TComponent;
begin
  Result := TIndGridColumn(SavedPersistent).View.IndGrid.Owner;
end;

constructor TIndColumnSaver.Create(AOwner:TComponent);
begin
  inherited;
  FIndGridFooterSaver := TIndGridFooterSaver.Create;
  FIndGroupFooterSaver := TIndGroupFooterSaver.Create;
  FIndDefaultGroupFooterSaver := TIndDefaultGroupFooterSaver.Create;
  Self.OnSavedPersistent := DoSetSavedPersistent;

end;

destructor TIndColumnSaver.Destroy;
begin
  FIndGridFooterSaver.Free;
  FIndDefaultGroupFooterSaver.Free;
  FindGroupFooterSaver.Free;
  inherited;
end;

procedure TIndColumnSaver.DoSetSavedPersistent(Sender: Tobject);
begin
  FIndGridFooterSaver.SavedColumn := TIndGridColumn(SavedPersistent);
  FIndGroupFooterSaver.SavedColumn := TIndGridColumn(SavedPersistent);
  FIndDefaultGroupFooterSaver.SavedColumn := TIndGridColumn(SavedPersistent);
end;

procedure TIndColumnSaver.LoadExpandedData(const AStorage: TIndStorePropertiesList);
var SavedRecords:TStrings;
    I:integer;
begin
{  SavedRecords := TStringList.Create;
  try}
    TIndGridColumn(SavedPersistent).ExpandSelected := StrToBoolDef(AStorage.Properties['ExpandSelectedRows'].Value,TIndGridColumn(SavedPersistent).ExpandSelected);
{    if TIndGridColumn(SavedPersistent).ExpandSelected then
    begin
      SavedRecords.Text := Trim(AStorage.Values['ExpandedRows']);
      for I := 0 to SavedRecords.Count - 1 do
      begin
        if TIndGridColumn(SavedPersistent).GroupIndex > - 1 then
           TIndGridColumn(SavedPersistent).ExpandRecord(SavedRecords.Names[I],SavedRecords.Values[SavedRecords.Names[I]]);
      end;
    end;}
    TIndGridColumn(SavedPersistent).AlwaysExpand := StrToBoolDef(AStorage.Properties['ExpandAllRows'].Value,TIndGridColumn(SavedPersistent).AlwaysExpand);
   // if TIndGridColumn(SavedPersistent).AlwaysExpand then
   //    TIndGridColumn(SavedPersistent).ExpandAll;
    TIndGridColumn(SavedPersistent).AlwaysClose := StrToBoolDef(AStorage.Properties['CloseAllRows'].Value,TIndGridColumn(SavedPersistent).AlwaysClose);
    UpdateColumnSaveProperties;
    
{  finally
    FreeAndNil(SavedRecords);
  end;}
end;

procedure TIndColumnSaver.SaveExpandedData(const AStorage: TIndStorePropertiesList);
//var SavedRecords:TStrings;
begin
//  SavedRecords := TStringList.Create;
//  try
//    if TIndGridColumn(SavedPersistent).ExpandSelected and (TIndGridColumn(SavedPersistent).GroupIndex > -1) then
//      SavedRecords := TIndGridColumn(SavedPersistent).GetSelectedRecordValues;
//    else if TIndGridColumn(SavedPersistent).AlwaysExpand and (TIndGridColumn(SavedPersistent).GroupIndex > -1) then
//      SavedRecords := TIndGridColumn(SavedPersistent).GetAllRecordValues
//    if SavedRecords.Count = 0 then
//      AStorage.Values['ExpandedRows'] := ' '
//    else
//      AStorage.Values['ExpandedRows'] := SavedRecords.Text;
   UpdateColumnSaveProperties;
    AStorage.Properties['ExpandAllRows'].Value := BoolToStr(TIndGridColumn(SavedPersistent).AlwaysExpand and
        (TIndGridColumn(SavedPersistent).GroupIndex > -1));
    AStorage.Properties['CloseAllRows'].Value := BoolToStr(TIndGridColumn(SavedPersistent).AlwaysClose and
        (TIndGridColumn(SavedPersistent).GroupIndex > -1));
    AStorage.Properties['ExpandSelectedRows'].Value := BoolToStr(TIndGridColumn(SavedPersistent).ExpandSelected and
        (TIndGridColumn(SavedPersistent).GroupIndex > -1));

        {  finally
    FreeAndNil(SavedRecords);
  end;}
end;

procedure TIndColumnSaver.UpdateColumnSaveProperties;
begin
   //если не выбрано ни одного типа сохранения раскрытых групп, то
   //по умолчанию устанавливаем сохранение только открытых групп
   if not TIndGridColumn(SavedPersistent).ExpandSelected and
      not TIndGridColumn(SavedPersistent).AlwaysExpand and
      not TIndGridColumn(SavedPersistent).AlwaysClose then
        TIndGridColumn(SavedPersistent).ExpandSelected := True;
end;

{ TIndGridRecnoChecker }

function TIndGridRecnoChecker.FindRecnoCol: TIndGridColumn;
var ColIndex:integer;
begin
   Result := nil;
   for ColIndex := 0 to TIndGrid(IndComponent).View.Columns.Count - 1 do
   begin
     if Assigned(TIndGrid(IndComponent).View.Columns[ColIndex].Field) and
        Assigned(TIndGrid(IndComponent).View.Columns[ColIndex].Field.FieldMetadata) and
        (TIndGrid(IndComponent).View.Columns[ColIndex].Field.FieldMetadata.DataType = dtRecNo) then
     begin
        Result := TIndGrid(IndComponent).View.Columns[ColIndex]; 
     end
   end;
end;

function TIndGridRecnoChecker.GetTableRef(
  AComponent: TComponent): TIndTableRef;
begin
  Result := TIndGrid(AComponent).Table;
end;

function TIndGridRecnoChecker.HasRecnoField(RecnoField: TField): boolean;
var I:integer;
begin
  Result := False;
  if not Assigned(RecnoField) then Exit;
  for I := 0 to TIndGrid(IndComponent).View.Columns.Count - 1 do
  begin
     if Assigned(TIndGrid(IndComponent).View.Columns[I].Field) and
        Assigned(TIndGrid(IndComponent).View.Columns[I].Field.Field) and
        (TIndGrid(IndComponent).View.Columns[I].Field.Field.Field = RecnoField) then
            Result := True;
  end;
end;

procedure TIndGridRecnoChecker.SetCanFiltering;
begin
  if Assigned(IndComponent) then
  begin
     if CanFiltering then
       TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnFiltering := True
     else if SupportRecno and SupportTreeView then
     begin
       SetFilterOnParent;
     end else
       TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnFiltering := False;
  end;     
end;

procedure TIndGridRecnoChecker.SetCanGrouping;
begin
  if Assigned(IndComponent) then
  begin
     if CanGrouping then
       TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnGrouping := True
     else
       TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnGrouping := False
  end;     
end;

procedure TIndGridRecnoChecker.SetCanMoving;
begin
  if Assigned(IndComponent) then
  begin
     if CanMoving then
       TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnMoving := True
     else
       TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnMoving := True; //False;
  end;
end;

procedure TIndGridRecnoChecker.SetCanSorting;
begin
  {if Assigned(IndComponent) then
  begin
    if CanSorting then
       TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnSorting := True
    else if SupportTreeView and SupportRecno then
    begin
      SetSortOnRecno;
    end else
    begin
      TIndGrid(IndComponent).View.GridView.OptionsCustomize.ColumnSorting := False;
      if FindRecnoCol <> nil then
        TcxGridBandedColumn(FindRecnoCol.FCol).SortOrder := soAscending;
    end;
  end;}
  if Assigned(IndComponent) then
  begin
    if FindRecnoCol <> nil then
      TcxGridBandedColumn(FindRecnoCol.FCol).SortOrder := soAscending;
  end;
  
end;

procedure TIndGridRecnoChecker.SetFilterOnParent;
var ColIndex:integer;
begin
   for ColIndex := 0 to TIndGrid(IndComponent).View.Columns.Count - 1 do
   begin
     if Assigned(TIndGrid(IndComponent).View.Columns[ColIndex].Field) and
        Assigned(TIndGrid(IndComponent).View.Columns[ColIndex].Field.FieldMetadata) and
        (TIndGrid(IndComponent).View.Columns[ColIndex].Field.FieldMetadata.DataType = dtId)
        {and TIndGrid(IndComponent).View.Columns[ColIndex].Field.FieldMetadata.FieldSystem} then
        TcxGridColumn(TIndGrid(IndComponent).View.Columns[ColIndex].FCol).Options.Filtering := True
     else
        TcxGridColumn(TIndGrid(IndComponent).View.Columns[ColIndex].FCol).Options.Filtering := False;     
   end;
end;

procedure TIndGridRecnoChecker.SetSortOnRecno;
var ColIndex:integer;
begin
   for ColIndex := 0 to TIndGrid(IndComponent).View.Columns.Count - 1 do
   begin
     if Assigned(TIndGrid(IndComponent).View.Columns[ColIndex].Field) and 
        Assigned(TIndGrid(IndComponent).View.Columns[ColIndex].Field.FieldMetadata) and
        (TIndGrid(IndComponent).View.Columns[ColIndex].Field.FieldMetadata.DataType = dtRecNo) then
     begin
        TcxGridBandedColumn(TIndGrid(IndComponent).View.Columns[ColIndex].FCol).Options.Sorting := True;
        TcxGridBandedColumn(TIndGrid(IndComponent).View.Columns[ColIndex].FCol).SortOrder := soAscending;
     end
     else
        TcxGridBandedColumn(TIndGrid(IndComponent).View.Columns[ColIndex].FCol).Options.Sorting := False;
   end;
end;


function TIndGridRecnoChecker.SupportTreeView: boolean;
begin
  Result := Assigned(Table) and Table.SupportTreeView;
end;

{ TIndColumnSummaryItem }

procedure TIndColumnSummaryItem.AddSummary;
begin
  FNativeSummaryItem := TcxgridDbTableSummaryItem(FSummaryProvider.CreateSummary);
  UpdateNativeSummaryOptions(FNativeSummaryItem);
end;

function TIndColumnSummaryItem.CanGetProperties: boolean;
begin
  Result := Assigned(FNativeSummaryItem) and Assigned(FNativeSummaryItem.ItemLink); 
end;

constructor TIndColumnSummaryItem.Create(AColumn: TcxGridColumn);
begin
  inherited Create;
  FColumn := AColumn;
  FSummaryProvider := GetSummaryProviderClass.Create;
  FSummaryProvider.FOwnObj := FColumn;
  FKind := skCount;
  FPosition := spFooter;
end;

destructor TIndColumnSummaryItem.Destroy;
begin
  if Assigned(FNativeSummaryItem) and not (csDestroying in TIndGridColumn(FColumn.Tag).View.Indgrid.ComponentState) then
    FSummaryProvider.FreeSummary(FNativeSummaryItem);
  FSummaryProvider.Free;
  inherited;
end;

procedure TIndColumnSummaryItem.DropSummary;
begin
  UpdateSavedOptions(FnativeSummaryItem);
  FSummaryProvider.FreeSummary(FNativeSummaryItem);
end;

function TIndColumnSummaryItem.GetItemLink: TcxGridColumn;
begin
  Result := nil;
  if CanGetProperties then
    Result := TcxGridColumn(FNativeSummaryItem.ItemLink);
end;

function TIndColumnSummaryItem.GetKind: TcxSummaryKind;
begin

  if CanGetProperties then
     Result := FNativeSummaryItem.Kind
  else
     Result := FKind;

end;

function TIndColumnSummaryItem.GetPosition: TcxSummaryPosition;
begin
  if CanGetProperties then
     Result := FNativeSummaryItem.Position
  else
     Result := FPosition;
end;

function TIndColumnSummaryItem.GetSummaryProviderClass: TIndSummaryProviderClass;
begin
  Result := TindSummaryProvider;
end;

procedure TIndColumnSummaryItem.SetItemLink(const Value: TcxGridColumn);
begin
  if Value <> ItemLink then
  begin
     if CanGetProperties then
       FNativeSummaryItem.ItemLink := Value;
  end;   
end;

procedure TIndColumnSummaryItem.SetKind(const Value: TcxSummaryKind);
begin
   if Value <> Kind then
   begin
      if CanGetProperties then
        FnativeSummaryItem.Kind := Value
      else
        FKind := Value;
   end;
end;

procedure TIndColumnSummaryItem.SetPosition(
  const Value: TcxSummaryPosition);
begin
   if Value <> Position then
   begin
      if CanGetProperties then
        FnativeSummaryItem.Position := Value
      else
        Fposition := Value;
   end;
end;

procedure TIndColumnSummaryItem.SetUseSummary(const Value: boolean);
begin
  if UseSummary <> Value then
  begin
    FUseSummary := Value;
    if FUseSummary then
       AddSummary
    else
       DropSummary;
    SummaryProvider.UpdateSummaryItemsVisibility;
  end;
end;

procedure TIndColumnSummaryItem.UpdateNativeSummaryOptions(AItem:TcxGridDBTableSummaryItem);
begin
  AItem.Position := FPosition;
  AItem.Kind := FKind;
end;

procedure TIndColumnSummaryItem.UpdateSavedOptions(
  AItem: TcxGridDBTableSummaryItem);
begin
  FPosition := AItem.Position;
  FKind := AItem.Kind;
end;

{ TIndSummaryProvider }

function TIndSummaryProvider.AssignedGridView: boolean;
begin
  Result := Assigned(TcxGridColumn(FownObj).GridView);
end;

function TIndSummaryProvider.CheckSummaryItemsVisible: boolean;
var ItemIndex:integer;
begin
   Result := False;
   for ItemIndex := 0 to SummaryItems.Count - 1 do
   begin
      if not IsGroupedByColumn(SummaryItems[ItemIndex]) and
             Grid.ColumnUseSummary(GetIsGroupSummary) then
      begin
        Result := True;
        Break;
      end;
   end;
end;

function TIndSummaryProvider.ColumnUseSummary: boolean;
begin
  Result := GetRelatedObject.UseSummary;
end;

function TIndSummaryProvider.CreateColumnNativeSummary: TcxDataSummaryItem;
begin
  Result := GetSummaryItems.Add;
end;

function TIndSummaryProvider.CreateSummary: TcxDataSummaryItem;
begin
   Result := CreateColumnNativeSummary;
   Result.ItemLink := FOwnObj;
   UpdateSummaryItemsVisibility;
end;

procedure TIndSummaryProvider.FreeNativeSummary;
begin
  if GetIndex(AObject) > -1 then
      GetSummaryItems.Delete(
        GetIndex(AObject));

end;

procedure TIndSummaryProvider.FreeSummary(AObject:TObject);
begin
 if Assigned(GetSummaryItem(AObject)) then
  begin
    // if AssignedGridView then
   //  begin
       FreeNativeSummary(AObject);
   //  end;
  end;
  UpdateRelatedObject;
  UpdateSummaryItemsVisibility;
end;

function TIndSummaryProvider.GetGrid: TIndGrid;
begin
  Result := IndColumn.View.IndGrid;
end;

function TIndSummaryProvider.GetIndex(AObject: TObject): integer;
begin
  Result := IndexInSummaryItems(AObject);
end;

function TIndSummaryProvider.GetIsGroupSummary: boolean;
begin
  Result := False;
end;

function TIndSummaryProvider.GetRelatedObject: TIndColumnSummaryItem;
begin
 Result := nil;
end;

function TIndSummaryProvider.GetSummary: TcxDataSummary;
begin
  Result := TcxGridColumn(FOwnObj).GridView.DataController.Summary;
end;

function TIndSummaryProvider.GetSummaryItem(
  AObject: TObject): TcxDataSummaryItem;
begin
  Result := TcxDataSummaryItem(AObject);
end;

function TIndSummaryProvider.GetSummaryItems: TcxDataSummaryItems;
begin
  Result := GetSummary.DefaultGroupSummaryItems;

end;


function TIndSummaryProvider.IndColumn: TIndGridColumn;
begin
   result := TIndGridColumn(TcxGridColumn(FOwnObj).Tag);
end;

function TIndSummaryProvider.IndexInSummaryItems(
  AObject: Tobject): integer;
begin
  Result := GetSummaryItems.IndexOfItemLink(
              GetSummaryItem(AObject).ItemLink)
end;

function TIndSummaryProvider.IsGroupedByColumn(AItem:TcxDataSummaryItem): boolean;
begin
 Result := TcxGridDBTableSummaryItem(AItem).Column.GroupIndex > -1;
end;

procedure TIndSummaryProvider.SetVisibleSummary(AVisible: boolean);
begin

end;

procedure TIndSummaryProvider.UpdateRelatedObject;
begin
  GetRelatedObject.FNativeSummaryItem := nil;
end;

procedure TIndSummaryProvider.UpdateSummaryItemsVisibility;
begin
  if CheckSummaryItemsVisible then
    SetVisibleSummary(True)
  else
    SetVisibleSummary(False)
end;

{ TIndGridFooterItem }

function TIndGridFooterItem.GetSummaryProviderClass: TIndSummaryProviderClass;
begin
  Result := TIndSummaryFooterProvider;
end;

{ TIndSummaryFooterProvider }


function TIndSummaryFooterProvider.GetRelatedObject: TIndColumnSummaryItem;
begin
  Result := IndColumn.ColumnSummaryOptions.TotalSummary;
end;

function TIndSummaryFooterProvider.GetSummaryItems: TcxDataSummaryItems;
begin
  Result := GetSummary.FooterSummaryItems;
end;

procedure TIndSummaryFooterProvider.SetVisibleSummary(AVisible: boolean);
begin
  Grid.View.GridView.OptionsView.Footer := AVisible;
end;

{ TIndColumnGroupItem }

function TIndColumnGroupItem.GetSummaryProviderClass: TIndSummaryProviderClass;
begin
  Result := TIndSummaryGroupProvider;
end;

{ TIndSummaryGroupProvider }

function TIndSummaryGroupProvider.GetIsGroupSummary: boolean;
begin
  Result := True;
end;

function TIndSummaryGroupProvider.GetRelatedObject: TIndColumnSummaryItem;
begin
  Result := IndColumn.ColumnSummaryOptions.GroupSummary;
end;

function TIndSummaryGroupProvider.GetSummaryGroup: TcxDataSummaryGroup;
begin
  if Grid.View.GridView.DataController.Summary.SummaryGroups.Count > 0 then
    Result := Grid.View.GridView.DataController.Summary.SummaryGroups[0]
  else
    Result := Grid.View.GridView.DataController.Summary.SummaryGroups.Add;
end;

function TIndSummaryGroupProvider.GetSummaryItems: TcxDataSummaryItems;
begin
  Result := GetSummaryGroup.SummaryItems; 
end;

procedure TIndSummaryGroupProvider.SetVisibleSummary(AVisible: boolean);
begin
 if AVisible then
    Grid.View.GridView.OptionsView.GroupFooters := gfVisibleWhenExpanded
 else
    Grid.View.GridView.OptionsView.GroupFooters := gfInvisible;  
end;

procedure TIndSummaryGroupProvider.UpdateLinkedColumns;
var ColIndex:integer;
begin
  for ColIndex := 0 to Grid.View.Columns.Count - 1 do
     TcxGridTableSummaryGroupItemLink(GetSummaryGroup.Links.Add).Column := TcxGridColumn(Grid.View.Columns[ColIndex].FCol);
end;

{ TIndColumnSummaryOptions }

destructor TIndColumnSummaryOptions.Destroy;
begin
  FColumnSummary.Free;
  FgridSummary.Free;
  inherited;
end;

procedure TIndColumnSummaryOptions.DoCheckGroupingChanged(Sender: TObject);
begin
   UpdateSummaryVisibility;
end;

function TIndColumnSummaryOptions.Grid: TIndGrid;
begin
  Result := TIndGridColumn(FCol.Tag).View.IndGrid;
end;

procedure TIndColumnSummaryOptions.Init;
begin
  if not Assigned(FCol) then
    raise Exception.Create(LocalizeGrids(idTcxGridMustAssignedString,
      langTcxGridMustAssignedString));
  FColumnSummary := TIndColumnGroupItem.Create(FCol);
  FGridSummary := TIndGridFooterItem.Create(FCol);
end;

{procedure TIndColumnSummaryOptions.UpdateSummaryKind;
var ColIndex:integer;
begin
  if Grid.View.Columns.Count > 0 then
  begin
    for ColIndex := 0 to Grid.View.Columns.Count - 1 do
    begin
      if not Grid.View.Columns[ColIndex].SupportSummary then
      begin
        Grid.View.Columns[ColIndex].ColumnSummaryOptions.GroupSummary.SetDefaultSummary;
        Grid.View.Columns[ColIndex].ColumnSummaryOptions.TotalSummary.SetDefaultSummary;
      end;
    end;
  end;
end;}

procedure TIndColumnSummaryOptions.UpdateSummaryVisibility;
begin
   if Grid.View.Columns.Count > 0 then
   begin
     Grid.View.Columns[0].ColumnSummaryOptions.GroupSummary.SummaryProvider.UpdateSummaryItemsVisibility;
     grid.View.Columns[0].ColumnSummaryOptions.TotalSummary.SummaryProvider.UpdateSummaryItemsVisibility;
   end;  
end;

{ TIndGridPopup }


constructor TIndGridPopup.Create(AOwner: TComponent);
begin
  inherited;
  FPopupLinkList := TIndPopupLinkStorageList.Create(False);
end;

destructor TIndGridPopup.Destroy;
begin
  FPopupLinkList.Free;
  inherited;
end;

procedure TIndGridPopup.DoActionPopupMenuLink(Sender: TdxBarPopupMenuLink;
  var X, Y: Integer; ClickedByMouse: Boolean; var AllowPopup: Boolean);
var APoint:TPoint;
begin
  APoint.X := X;
  APoint.Y := Y;
  if GetHitTypeByPoint(APoint) in IndGrid.GetPopupMenuHitTypes then
    AllowPopup := True
  else
    AllowPopup := False;
end;

function TIndGridPopup.GetHitTypeByPoint(
  APoint: TPoint): TcxGridViewHitType;
var FHitTest:TcxCustomGridHitTest;
begin
  FHitTest := IndGrid.View.GridView.GetHitTest(APoint.X, APoint.Y);
  Result := GetHitTypeByHitCode(FHitTest.HitTestCode);
end;

procedure TIndGridPopup.SetPopupMenuLinkAction(APopupMenuLink:TIndCustomPopupMenuLink);
begin
   FPopupLinkList.Add(TIndPopupLinkStorage.Create(Self,APopupMenuLink));
   APopupMenuLink.PopupMenuLink.OnAction := DoActionPopupMenuLink;
   FPopupMenuLink := APopupMenuLink;

end;

procedure TIndGridPopup.ClearPopupMenuAction(APopupMenuLink:TIndCustomPopupMenuLink);
begin
  if FPopupLinkList.IndexOfLink(APopupMenuLink) > -1 then
  begin
    APopupMenuLink.PopupMenuLink.OnAction :=
       TIndPopupLinkStorage(FPopupLinkList.Items[FPopupLinkList.IndexOfLink(ApopupMenuLink)]).StoredLinkOnActionEvent;
    FPopupLinkList.Remove(FPopupLinkList.Items[FPopupLinkList.IndexOfLink(ApopupMenuLink)]);
  end;
end;


{ TIndPopupLinkStorage }

constructor TIndPopupLinkStorage.Create(
  AOwner:TComponent;
  ALink: TIndCustomPopupMenuLink
  );
begin
  inherited Create(AOwner);
  FStoredLink := ALink;
  FStoredLinkOnActionEvent := ALink.PopupMenuLink.OnAction;
end;

{ TIndPopupLinkStorageList }


function TIndPopupLinkStorageList.IndexOfLink(
  ALink: TIndCustomPopupMenuLink): integer;
var LinkIndex:integer;
begin
  Result := -1;
  for LinkIndex := 0 to Count - 1 do
  begin
    if TIndPopupLinkStorage(Items[LinkIndex]).StoredLink = ALink then
    begin
       Result := LinkIndex;
       Break;
    end;
  end;
end;

{ TIndFooterSaver }

function TIndFooterSaver.DataSummaryItem(
  ASummaryItems: TcxDataSummaryItems): TcxDataSummaryItem;
var FooterIndex:integer;
begin
    Result := nil;
    for FooterIndex := 0 to ASummaryItems.Count - 1 do
    begin
       if TcxGridColumn(ASummaryItems[FooterIndex].ItemLink) = TcxGridColumn(SavedColumn.FCol) then
       begin
          Result := ASummaryItems[FooterIndex];
          Break;
       end;   
    end;

end;

function TIndFooterSaver.GetSummaryItem: TcxDataSummaryItem;
begin
  Result := DataSummaryItem(GetSummaryItems);
end;

procedure TIndFooterSaver.LoadGridFooters(const AStorage: TIndStorePropertiesList);
begin
    if StrToIntDef(AStorage.Properties[GetFooterUseValue].Value,cIndUseFooter) = cIndUseFooter then
    begin
      with GetSummaryItems do
         SetSummaryItemProperties(Add,AStorage);
    end;
end;

procedure TIndFooterSaver.SaveDefaultValuesToStorage(
  AStorage: TIndStorePropertiesList);
begin
    AStorage.Properties[GetFooterUseValue].Value := IntToStr(cIndNotUseFooter);
    AStorage.Properties[GetFooterUseKind].Value := IntToStr(integer(skNone));
end;

procedure TIndFooterSaver.SaveGridFooters(const AStorage: TIndStorePropertiesList);
var ASummaryItem:TcxDataSummaryItem;
begin
    ASummaryItem := GetSummaryItem;
    if not Assigned(ASummaryItem) then
      SaveDefaultValuesToStorage(AStorage)
    else
      SaveValuesToStorage(AStorage,ASummaryItem);
end;

procedure TIndFooterSaver.SaveValuesToStorage(AStorage: TIndStorePropertiesList;ASummaryItem:TcxDataSummaryItem);
begin
  AStorage.Properties[GetFooterUseValue].Value := IntToStr(cIndUseFooter);
  AStorage.Properties[GetFooterUseKind].Value := IntToStr(integer(ASummaryItem.Kind));
end;

procedure TIndFooterSaver.SetSummaryItemProperties(
  ASummaryItem: TcxDataSummaryItem; AStorage: TIndStorePropertiesList);
begin
   ASummaryItem.ItemLink := SavedColumn.FCol;
   ASummaryItem.Kind := TcxSummaryKind(StrToIntDef(AStorage.Properties[GetFooterUseKind].Value,Ord(ASummaryItem.Kind)));
end;

{ TIndGridFooterSaver }

function TIndGridFooterSaver.GetFooterUseKind: string;
begin
  Result := 'FooterKind';
end;

function TIndGridFooterSaver.GetFooterUseValue: string;
begin
  Result := 'Footer';
end;

function TIndGridFooterSaver.GetSummaryItems: TcxDataSummaryItems;
begin
  Result := SavedColumn.View.GridView.DataController.Summary.FooterSummaryItems;
end;

{ TIndGroupFooterSaver }

function TIndDefaultGroupFooterSaver.GetFooterUseKind: string;
begin
  Result := 'DefaultGroupFooterKind';
end;

function TIndDefaultGroupFooterSaver.GetFooterUseValue: string;
begin
  Result := 'DefaultGroupFooter';
end;

function TIndDefaultGroupFooterSaver.GetSummaryItems: TcxDataSummaryItems;
begin
  Result := SavedColumn.View.GridView.DataController.Summary.DefaultGroupSummaryItems;
end;

function TIndGroupFooterSaver.GetLinkCountValue: string;
begin
  Result := 'LinkCount';
end;

function TIndGroupFooterSaver.GetSavedLinkName(AColumn:TIndGridColumn): string;
begin
  Result := AColumn.Name;

end;


procedure TIndGroupFooterSaver.LoadGridFooters(
  const AStorage: TIndStorePropertiesList);
begin
  LoadLinkedColumns(AStorage);
end;

procedure TIndGroupFooterSaver.SaveGridFooters(
  const AStorage: TIndStorePropertiesList);
begin
  SaveLinkedColumns(AStorage);
end;

procedure TIndGroupFooterSaver.LoadLinkedColumns(AStorage: TIndStorePropertiesList);
var LinkIndex:integer;
begin
   for LinkIndex := 0 to Grid.View.Columns.Count - 1 do
   begin
      if StrToIntDef(AStorage.Properties[Grid.View.Columns[LinkIndex].Name].Value,0) <> integer(skNone) then
      begin
        with MakeColumnLink(Grid.View.Columns[LinkIndex]) do
        begin
          Kind := TcxSummaryKind(StrToIntDef(AStorage.Properties[GetSavedLinkName(Grid.View.Columns[LinkIndex])].Value,0));
          Position := spFooter;
          Column := TcxGridDBColumn(SavedColumn.FCol);
        end;
      end;  
   end;
end;

function TIndGroupFooterSaver.GetGrid: TIndGrid;
begin
  Result := SavedColumn.View.IndGrid;
end;

function TIndGroupFooterSaver.MakeColumnLink(AColumn: TIndGridColumn):TcxGridDBTableSummaryItem;
begin
  Assert(Assigned(Acolumn));
  with TcxGridTableSummaryGroupItemLink(GetSummaryGroup(AColumn).Links.Add) do
    Column := TcxGridColumn(AColumn.FCol);
  Result := TcxGridDBTableSummaryItem(GetSummaryGroup(AColumn).SummaryItems.Add);
end;

function TIndGroupFooterSaver.GetSummaryGroup(AColumn:TIndGridColumn): TcxDataSummaryGroup;
begin
  if not Assigned(SavedColumn.View.GridView.DataController.Summary.SummaryGroups.FindByItemLink(AColumn.FCol)) then
     Result := SavedColumn.View.GridView.DataController.Summary.SummaryGroups.Add
  else
     Result := SavedColumn.View.GridView.DataController.Summary.SummaryGroups.FindByItemLink(AColumn.FCol);
end;

procedure TIndGroupFooterSaver.UpdateColumnsList(AStorage: TIndStorePropertiesList);
var ColIndex:integer;
begin
  for ColIndex := 0 to Grid.View.Columns.Count - 1 do
    AStorage.Properties[Grid.View.Columns[ColIndex].Name].Value := IntToStr(integer(skNone));
end;

{ TIndGroupFooterSaver }

procedure TIndGroupFooterSaver.SaveLinkedColumns(AStorage: TIndStorePropertiesList);
var LinkIndex,GroupIndex:integer;

    function GetCurrentColumnKind(ASummaryGroup:TcxDataSummaryGroup):integer;
    var SummaryItemIndex:integer;
    begin
       Result := integer(skNone);
       for SummaryItemIndex := 0 to ASummaryGroup.SummaryItems.Count - 1 do
       begin
          if TcxGridDBTableSummaryItem(ASummaryGroup.SummaryItems[SummaryItemIndex]).Column = SavedColumn.FCol then
          begin
             Result := integer(TcxGridDBTableSummaryItem(ASummaryGroup.SummaryItems[SummaryItemIndex]).Kind);
             Break;
          end;
       end;
    end;

begin
  UpdateColumnsList(AStorage);
  with Grid.View.GridView.DataController.Summary do
  begin
    for GroupIndex := 0 to SummaryGroups.Count - 1 do
    begin
      for LinkIndex := 0 to SummaryGroups[GroupIndex].Links.Count - 1 do
      begin
        
        if Assigned(SummaryGroups[GroupIndex].Links[LinkIndex].ItemLink) then
        begin
          AStorage.Properties[GetSavedLinkName(
              TIndGridColumn(
              TcxGridColumn(SummaryGroups[GroupIndex].Links[LinkIndex].ItemLink).Tag))].Value :=
              IntToStr(GetCurrentColumnKind(SummaryGroups[GroupIndex]));
        end;
      end;
    end;
  end;

end;

function TIndGroupFooterSaver.GetFooterUseKind: string;
begin
  Result := 'GroupFooterKind';
end;

{ TIndGridButtonProperties }

{function TIndGridButtonProperties.GetButtonBrowse(
  AButtonParent: TPersistent): TcxEditButton;
begin
  Result := TindGridColumn(TcxGridColumn(AButtonParent).Tag).ButtonView;
end;}

function TIndGridButtonProperties.GetField(
  AButtonParent: TPersistent): TIndFieldRef;
begin
  Result := TIndGridColumn(TcxGridColumn(AButtonParent).Tag).Field;
end;

function TIndGridButtonProperties.GetIndFieldEditorItem(AButtonParent:TPersistent): TPersistent;
begin
  Result := TIndGridColumn(TcxGridColumn(AButtonParent).Tag);
end;

function TIndGridButtonProperties.IsEditing(
  AButtonParent: TPersistent): boolean;
begin
  Result := False;//TcxGridColumn(AButtonParent).GridView.
end;

function TIndGridButtonProperties.Properties(
  AButtonParent: TPersistent): TcxCustomEditProperties;
begin
  Result := TcxGridColumn(AButtonParent).Properties;
end;

{procedure TIndGridButtonProperties.SetButtonBrowse(
  AButtonParent: TPersistent;AButton:TcxEditButton);
begin
  inherited;
  TindGridColumn(TcxGridColumn(AButtonParent).Tag).ButtonView := AButton;
end;}

{ TIndcxGridDBBandedTableView }

constructor TIndcxGridDBBandedTableView.Create(AOwner: TComponent);
begin
  inherited;
  FButtonProperties := TIndGridButtonProperties.Create(Self);
  OnFocusedItemChanged := DoFocusedColumnChanged;
  OnFocusedRecordChanged := DoChangeRecord;
  OnEditChanged := DoEditChangedInner;
  OnHideEdit := DoHideEdit;
  OnColumnSizeChanged := DoChangeColumnSize;
//  OptionsView.ShowEditButtons := gsebForFocusedRecord;
  OptionsView.ShowEditButtons := gsebNever; 

end;

procedure TIndcxGridDBBandedTableView.DoAfterEditingGrid(AItem: TcxCustomGridTableItem);
var I:integer;
begin
  if IsLoading then Exit;
  ButtonProperties.BeginBtUpdate(AItem);
  try
    ButtonProperties.HideBrowseButton(AItem);
    ButtonProperties.ShowEditButton(AItem);
  finally
    ButtonProperties.EndBtUpdate(AItem);
  end;
end;

procedure TIndcxGridDBBandedTableView.DoChangeColumnSize(
  Sender: TcxGridTableView; AColumn: TcxGridColumn);
var GridDataHeight:integer;
begin
  GridDataHeight := IndView.IndGrid.Height - Sender.ViewInfo.GroupByBoxViewInfo.Height -
    IndView.IndGrid.StatusPanel.Height;
  if Sender.ViewInfo.HeaderViewInfo.Items[AColumn.VisibleIndex].Height >
     {GridDataHeight} (Round(GridDataHeight/2)) then
  begin
     TcxGridDBBandedColumn(AColumn).Position.LineCount :=
     Round(Round(GridDataHeight/Sender.ViewInfo.HeaderViewInfo.ItemHeight)/2); //на половину от доступного количества строк
  end;
end;

procedure TIndcxGridDBBandedTableView.MakeDefaultColumnSize(
  Sender: TcxGridTableView; AColumn: TcxGridColumn);
begin
  TcxGridDBBandedColumn(AColumn).Position.LineCount := 1;
end;

procedure TIndcxGridDBBandedTableView.DoChangeRecord(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
var I:integer;
begin
  if IsLoading then Exit;
  if OptionsView.ShowEditButtons <> gsebForFocusedRecord then
  begin
    if not Assigned(APrevFocusedRecord) then
    begin
      for I := 0 to ColumnCount - 1 do
        FButtonProperties.HideAllButtons(Columns[I]);
    end; //Убрал степа 10.12.2008
    OptionsView.ShowEditButtons := gsebForFocusedRecord ;
  end;
  FButtonProperties.ShowBrowseButton(Controller.FocusedColumn);
end;

procedure TIndcxGridDBBandedTableView.DoEditChangedInner(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  if IsLoading then Exit;
  ButtonProperties.BeginBtUpdate(AItem);
  try
    FButtonProperties.HideEditButton(AItem);
    FButtonProperties.ShowBrowseButton(AItem);
  finally
    ButtonProperties.EndBtUpdate(AItem);
  end;
end;

procedure TIndcxGridDBBandedTableView.DoFocusedColumnChanged(
  Sender: TcxCustomGridTableView; APrevFocusedItem,
  AFocusedItem: TcxCustomGridTableItem);
begin
  if IsLoading then Exit;
  if Assigned(APrevFocusedItem) then
    FButtonProperties.HideAllButtons(APrevFocusedItem);
  FButtonProperties.ShowBrowseButton(AFocusedItem);

end;

procedure TIndcxGridDBBandedTableView.DoHideEdit(Sender: TObject);
begin
  if IsLoading then Exit;
  ButtonProperties.BeginBtUpdate(Controller.FocusedColumn);
  try
   FButtonProperties.HideAllButtons(Controller.FocusedColumn);
   FButtonProperties.ShowBrowseButton(Controller.FocusedColumn);
  finally
    ButtonProperties.EndBtUpdate(Controller.FocusedColumn);
  end;
end;

function TIndcxGridDBBandedTableView.GetControllerClass: TcxCustomGridControllerClass;
begin
  Result := TIndcxGridBandedTableController;
end;

procedure TIndcxGridDBBandedTableView.InitEditorButtons;
begin
  if IsLoading then Exit;
  ButtonProperties.BeginBtUpdate(Controller.FocusedColumn);
  try
    ButtonProperties.HideBrowseButton(Controller.FocusedColumn);
    ButtonProperties.ShowEditButton(Controller.FocusedColumn);
  finally
    ButtonProperties.EndBtUpdate(Controller.FocusedColumn);
  end;
end;

function TIndcxGridDBBandedTableView.IsLoading: boolean;
begin
  Result := (csLoading in IndView.IndGrid.ComponentState) or
            (csDestroying in IndView.IndGrid.ComponentState);
end;


{ TIndcxGridBandedTableController }

procedure TIndcxGridBandedTableController.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  AHitType: TcxGridViewHitType;
begin
  AHitType := GetHitTypeByHitCode(GridView.ViewInfo.GetHitTest(X,Y).HitTestCode);
  if AHitType = gvhtCell then
  begin
    if Assigned(TcxGridDataCellViewInfo(GridView.ViewInfo.GetHitTest(X,Y).ViewInfo).EditViewInfo) and
       (TcxGridDataCellViewInfo(GridView.ViewInfo.GetHitTest(X,Y).ViewInfo).EditViewInfo.SelectedButton = 0) then
       TIndcxGridDBBandedTableView(GridView).IndView.DoOnClickViewButton
    else if Length(TcxGridDataCellViewInfo(GridView.ViewInfo.GetHitTest(X,Y).ViewInfo).EditViewInfo.ButtonsInfo) > 0 then
      inherited MouseDown(Button,Shift,TcxGridDataCellViewInfo(GridView.ViewInfo.GetHitTest(X,Y).ViewInfo).EditViewInfo.ButtonsInfo[0].Bounds.Left + 2 , Y)
    else
      inherited;  
  end else
    inherited;
end;

function TIndcxGridBandedTableController.StartDragAndDrop(
  const P: TPoint): Boolean;
begin
  Result := ((GetDesigner(Grid) = nil) or not GetDesigner(Grid).RvReadOnly) and inherited StartDragAndDrop(P);
end;

{ TIndButton }

procedure TIndButton.SetcxButton(const Value: TcxEditButton);
begin
 if FcxButton <> Value then
 begin
   FcxButton := Value;
   FInEditorVisible := FcxButton.Visible;
 end;
end;


function TIndFieldItem.GetTable: TIndMetadataTable;
begin
 if Assigned(FField.TableRef) then Result := FField.TableRef.Table
 else Result := nil;
end;


{ TIndStatusMessages }

constructor TIndStatusMessages.Create;
begin
  FFetchLimitMessage := TIndStatusMessage.Create;
  FFilterMessage := TIndStatusMessage.Create;
end;

destructor TIndStatusMessages.Destroy;
begin
  FreeAndNil(FFilterMessage);
  FreeAndNil(FFetchLimitMessage);
end;

procedure TIndStatusMessages.Show;
begin
  if Assigned(StatusPanel) then
  begin
    FStatusPanel.LabelLeft.Caption := FilterMessage.MessageStr;
    FStatusPanel.LabelLeft.Style.Font.Color := FilterMessage.FontColor;
    FStatusPanel.LabelLeft.Style.Font.Style := FilterMessage.FontStyle;

    FStatusPanel.LabelRight.Caption := FetchLimitMessage.MessageStr;
    FStatusPanel.LabelRight.Style.Font.Color := FetchLimitMessage.FontColor;
    FStatusPanel.LabelRight.Style.Font.Style := FetchLimitMessage.FontStyle;

    FStatusPanel.Refresh;
  end;
end;

{ TIndStatusMessagePanel }

procedure TIndStatusMessagePanel.AlignLabels;
var AverageLength:integer;
    LengthPixLeft,LengthPixRight:integer;
    I:integer;
    TempWidth: Integer;
begin

  {LabelLeft.Width := Floor(Width/2);
  LabelRight.Width := Floor(Width/2);}


  LengthPixLeft := LabelLeft.Canvas.TextWidth(LabelLeft.Caption);
  LengthPixRight := LabelRight.Canvas.TextWidth(LabelRight.Caption);

  AverageLength := Floor((LengthPixLeft + LengthPixRight)/2);

  //m.proh
  if LengthPixLeft > AverageLength then
    {LabelLeft.}TempWidth := {LabelLeft.Width} Floor(Width/2) + (LengthPixLeft - AverageLength)
  else
    {LabelLeft.}TempWidth := {LabelLeft.Width} Floor(Width/2) - (AverageLength - LengthPixLeft);

  LabelLeft.SetBounds(0, 0, TempWidth, Height);
  LabelRight.SetBounds(LabelLeft.Width, 0, Width - LabelLeft.Width, Height);
end;

function TIndStatusMessagePanel.CanAcceptControls: boolean;
begin
  Result := False;
end;

constructor TIndStatusMessagePanel.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csAcceptsControls];//,csFixedWidth,csNoStdEvents];


  FLabelLeft := TcxLabel.Create(Self);
  FLabelLeft.Parent := Self;
  FLabelLeft.Align := alLeft;
  FLabelLeft.AutoSize := False;
  FLabelLeft.Properties.Alignment.Horz := taRightJustify;
  FLabelLeft.Properties.Alignment.Vert := taVCenter;
  FLabelLeft.SetSubComponent(True);
  FLabelRight := TcxLabel.Create(Self);
  FLabelRight.Parent := Self;
  FLabelRight.Align := alCustom;
  FLabelRight.AutoSize := False;
  FLabelRight.Properties.Alignment.Horz := taLeftJustify;
  FLabelRight.Properties.Alignment.Vert := taVCenter;
  FLabelRight.SetSubComponent(True);

  Caption :='';
  Color := clBtnShadow;
  BevelOuter := bvNone;
  Height := 20;
  Align := alBottom;
end;

function TIndStatusMessagePanel.GetHitTest(Message: TMessage;
  Sender: TControl): boolean;
begin
 Result := False;
end;

procedure TIndStatusMessagePanel.Refresh;
var FPrevCaption:string;
begin
  {Visible := False;
  LabelLeft.Visible := False;
  LabelRight.Visible := False;}
  AlignLabels;
  Visible := (LabelLeft.Caption <> '') or (LabelRight.Caption <> '');
  LabelLeft.Visible := Visible;
  LabelRight.Visible := Visible;

end;

procedure TIndStatusMessagePanel.Resized(var Message: TWMSize);
begin
  Refresh;
end;

{ TIndStatusMessage }

constructor TIndStatusMessage.Create;
begin
  FFontColor := clBtnFace;
  FFontStyle := [];
end;


{ TIndSimpleIndexUpdater }

constructor TIndSimpleIndexUpdater.Create;
begin
  inherited;
  FSortList := TStringList.Create;
end;

destructor TIndSimpleIndexUpdater.Destroy;
begin
  FreeAndNil(FSortList);
  inherited;
end;

procedure TIndSimpleIndexUpdater.SortAndUpdate;
var I:integer;
begin
  FSortList.Clear;
  for I := 0 to GetCount - 1 do
    FSortList.AddObject(GetSortByParam(I),GetSortObject(I));
  FSortList.Sort;
  for I := 0 to SortList.Count - 1 do
    MakeUpdateAction(I);
end;

{ TIndSimpleIndexUpdaterGroupIndex }

function TIndSimpleUpdaterGroupIndex.GetCount:integer;
begin
  Result := View.Columns.Count;
end;

function TIndSimpleUpdaterGroupIndex.GetSortByParam(Index:integer): string;
begin
  Result := IntToStr(TIndGridColumn(View.Columns[Index]).StoredGroupIndex);
end;

function TIndSimpleUpdaterGroupIndex.GetSortObject(Index: integer): TObject;
begin
  Result := View.Columns[Index];
end;

procedure TIndSimpleUpdaterGroupIndex.MakeUpdateAction(Index: integer);
begin
  inherited;
  TIndGridColumn(SortList.Objects[Index]).GroupIndex := TIndGridColumn(SortList.Objects[Index]).StoredGroupIndex;
end;

{ TIndSimpleIndexUpdaterColIndexDesignTime }

function TIndSimpleUpdaterColIndexDesignTime.GetCount:integer;
begin
  Result := View.Columns.Count;
end;

function TIndSimpleUpdaterColIndexDesignTime.GetSortByParam(
  Index: integer): string;
begin
  Result := IntToStr(TIndGridColumn(View.Columns[Index]).Position.StoredColIndex);
end;

function TIndSimpleUpdaterColIndexDesignTime.GetSortObject(
  Index: integer): TObject;
begin
  Result := View.Columns[Index];
end;

procedure TIndSimpleUpdaterColIndexDesignTime.MakeUpdateAction(
  Index: integer);
begin
  inherited;
  TIndGridColumn(SortList.Objects[Index]).Position.ColIndex := TIndGridColumn(SortList.Objects[Index]).Position.StoredColIndex;
end;

function TIndFieldItem.GetChildCount: integer;
begin

end;

function TIndFieldItem.GetChildren(Index: integer): TIndFieldItem;
begin

end;

function TIndFieldItem.GetStoredIndex: integer;
begin

end;

procedure TIndFieldItem.SetRealIndex(const Value: integer);
begin

end;

initialization
begin
  cxGridStructureNavigatorClass := TIndGridStructureNavigator;
end;


end.

