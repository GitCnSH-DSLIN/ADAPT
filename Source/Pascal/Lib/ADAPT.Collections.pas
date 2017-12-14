unit ADAPT.Collections;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes,
  {$ELSE}
    Classes,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT, ADAPT.Intf,
  ADAPT.Collections.Intf;

  {$I ADAPT_RTTI.inc}

type
  ///  <summary><c>A Simple Generic Array with basic Management Methods.</c></summary>
  ///  <remarks>
  ///    <para><c>Use IADArray or IADArrayReader if you want to take advantage of Reference Counting.</c></para>
  ///    <para><c>This is NOT Threadsafe</c></para>
  ///  </remarks>
  TADArray<T> = class(TADObject, IADArrayReader<T>, IADArray<T>)
  private
    FArray: TArray<IADValueHolder<T>>;
    FCapacityInitial: Integer;
    // Getters
    { IADArrayReader<T> }
    function GetCapacity: Integer;
    function GetItem(const AIndex: Integer): T;
    { IADArray<T> }
    function GetReader: IADArrayReader<T>;

    // Setters
    { IADArray<T> }
    procedure SetCapacity(const ACapacity: Integer);
    procedure SetItem(const AIndex: Integer; const AItem: T);
  public
    constructor Create(const ACapacity: Integer = 0); reintroduce; virtual;
    destructor Destroy; override;
    // Management Methods
    { IADArray<T> }
    procedure Clear;
    procedure Delete(const AIndex: Integer); overload;
    procedure Delete(const AFirstIndex, ACount: Integer); overload;
    procedure Finalize(const AIndex, ACount: Integer);
    procedure Insert(const AItem: T; const AIndex: Integer);
    procedure Move(const AFromIndex, AToIndex, ACount: Integer);

    // Properties
    { IADArrayReader<T> }
    property Capacity: Integer read GetCapacity;
    property Items[const AIndex: Integer]: T read GetItem; default;
    { IADArray<T> }
    property Items[const AIndex: Integer]: T read GetItem write SetItem; default;
    property Reader: IADArrayReader<T> read GetReader;
  end;

  ///  <summary><c>An Allocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>Dictates how to grow an Array based on its current Capacity and the number of Items we're looking to Add/Insert.</c></remarks>
  TADExpander = class abstract(TADObject, IADExpander)
  public
    { IADExpander }
    ///  <summary><c>Override this to implement the actual Allocation Algorithm</c></summary>
    ///  <remarks><c>Must return the amount by which the Array has been Expanded.</c></remarks>
    function CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer; virtual; abstract;
  end;

  ///  <summary><c>A Geometric Allocation Algorithm for Lists.</c></summary>
  ///  <remarks>
  ///    <para><c>When the number of Vacant Slots falls below the Threshold, the number of Vacant Slots increases by the value of the current Capacity multiplied by the Mulitplier.</c></para>
  ///    <para><c>This Expander Type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADExpanderGeometric = class(TADExpander, IADExpanderGeometric)
  private
    FMultiplier: Single;
    FThreshold: Integer;
  protected
    // Getters
    { IADExpanderGeometric }
    function GetCapacityMultiplier: Single; virtual;
    function GetCapacityThreshold: Integer; virtual;
    // Setters
    { IADExpanderGeometric }
    procedure SetCapacityMultiplier(const AMultiplier: Single); virtual;
    procedure SetCapacityThreshold(const AThreshold: Integer); virtual;
  public
    { IADExpanderGeometric }
    function CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer; override;
  public
    // Properties
    { IADExpanderGeometric }
    property CapacityMultiplier: Single read GetCapacityMultiplier write SetCapacityMultiplier;
    property CapacityThreshold: Integer read GetCapacityThreshold write SetCapacityThreshold;
  end;

  ///  <summary><c>A Deallocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>Dictates how to shrink an Array based on its current Capacity and the number of Items we're looking to Delete.</c></remarks>
  TADCompactor = class abstract(TADObject, IADCompactor)
  public
    { IADCompactor }
    function CheckCompact(const ACapacity, ACurrentCount, AVacating: Integer): Integer; virtual; abstract;
  end;

  ///  <summary><c>Abstract Base Class for all Collection Classes.</c></summary>
  ///  <remarks>
  ///    <para><c>Use IADCollectionReader or IADCollection if you want to take advantage of Reference Counting.</c></para>
  ///    <para><c>This is NOT Threadsafe</c></para>
  ///  </remarks>
  TADCollection = class abstract(TADObject, IADCollectionReader, IADCollection)
  protected
    FCount: Integer;
    FInitialCapacity: Integer;
    FSortedState: TADSortedState;

    // Getters
    { IADCollectionReader }
    function GetCapacity: Integer;
    function GetCount: Integer;
    function GetInitialCapacity: Integer;
    function GetIsCompact: Boolean;
    function GetIsEmpty: Boolean;
    function GetSortedState: TADSortedState;
    { IADCollection }
    function GetReader: IADCollectionReader;

    // Setters
    { IADCollectionReader }
    { IADCollection }
    procedure SetCapacity(const ACapacity: Integer);

    // Overridables
    procedure CreateArray(const AInitialCapacity: Integer); virtual; abstract;
  public
    // Management Methods
    { IADCollectionReader }
    { IADCollection }
    procedure Clear;

    // Properties
    { IADCollectionReader }
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property InitialCapacity: Integer read GetInitialCapacity;
    property IsCompact: Boolean read GetIsCompact;
    property IsEmpty: Boolean read GetIsEmpty;
    property SortedState: TADSortedState read GetSortedState;
    { IADCollection }
    property Reader: IADCollectionReader read GetReader;
  end;

  ///  <summary><c>Abstract Base Type for all Generic List Collection Types.</c></summary>
  ///  <remarks>
  ///    <para><c>Use IADListReader for Read-Only access.</c></para>
  ///    <para><c>Use IADList for Read/Write access.</c></para>
  ///    <para><c>Use IADIterableList for Iterators.</c></para>
  ///    <para><c>Call .Iterator against IADListReader to return the IADIterableList interface reference.</c></para>
  ///  </remarks>
  TADListBase<T> = class abstract(TADCollection, IADListReader<T>, IADList<T>, IADIterableList<T>)
  private
    // Getters
    { IADListReader<T> }
    function GetItem(const AIndex: Integer): T;
    function GetIterator: IADIterableList<T>;
    { IADList<T> }
    function GetReader: IADListReader<T>;
    { IADIterableList<T> }

    // Setters
    { IADListReader<T> }
    { IADList<T> }
    procedure SetItem(const AIndex: Integer; const AItem: T);
    { IADIterableList<T> }
  protected

  public
    // Management Methods
    { IADListReader<T> }
    { IADList<T> }
    function Add(const AItem: T): Integer; overload;
    procedure Add(const AItems: IADListReader<T>); overload;
    procedure AddItems(const AItems: Array of T);
    procedure Delete(const AIndex: Integer);
    procedure DeleteRange(const AFirst, ACount: Integer);
    procedure Insert(const AItem: T; const AIndex: Integer);
    procedure InsertItems(const AItems: Array of T; const AIndex: Integer);
    { IADIterableList<T> }
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure Iterate(const ACallback: TADListItemCallbackAnon<T>; const ADirection: TADIterateDirection = idRight); overload;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure Iterate(const ACallback: TADListItemCallbackOfObject<T>; const ADirection: TADIterateDirection = idRight); overload;
    procedure Iterate(const ACallback: TADListItemCallbackUnbound<T>; const ADirection: TADIterateDirection = idRight); overload;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateBackward(const ACallback: TADListItemCallbackAnon<T>); overload;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateBackward(const ACallback: TADListItemCallbackOfObject<T>); overload;
    procedure IterateBackward(const ACallback: TADListItemCallbackUnbound<T>); overload;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateForward(const ACallback: TADListItemCallbackAnon<T>); overload;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateForward(const ACallback: TADListItemCallbackOfObject<T>); overload;
    procedure IterateForward(const ACallback: TADListItemCallbackUnbound<T>); overload;

    // Properties
    { IADListReader<T> }
    property Items[const AIndex: Integer]: T read GetItem; default;
    property Iterator: IADIterableList<T> read GetIterator;
    { IADList<T> }
    property Items[const AIndex: Integer]: T read GetItem write SetItem; default;
    property Reader: IADListReader<T> read GetReader;
  end;

  ///  <summary><c>Generic List Collection.</c></summary>
  ///  <remarks>
  ///    <para><c>Use IADListReader for Read-Only access.</c></para>
  ///    <para><c>Use IADList for Read/Write access.</c></para>
  ///    <para><c>Use IADIterableList for Iterators.</c></para>
  ///    <para><c>Call .Iterator against IADListReader to return the IADIterableList interface reference.</c></para>
  ///    <para><c>Cast to IADCompactable to define a Compactor Type.</c></para>
  ///    <para><c>Cast to IADExpandable to define an Expander Type.</c></para>
  ///    <para><c>Use IADSortableList to define a Sorter and perform Lookups.</c></para>
  ///  </remarks>
  TADList<T> = class(TADListBase<T>, IADCompactable, IADExpandable, IADSortableList<T>)
  private
    // Getters
    { IADCompactable }
    function GetCompactor: IADCompactor;
    { IADExpandable }
    function GetExpander: IADExpander;
    { IADSortableList<T> }
    function GetSorter: IADListSorter<T>;

    // Setters
    { IADCompactable }
    procedure SetCompactor(const ACompactor: IADCompactor);
    { IADExpandable }
    procedure SetExpander(const AExpander: IADExpander);
    { IADSortableList<T> }
    procedure SetSorter(const ASorter: IADListSorter<T>);
  public
    // Management Methods
    { IADCompactable }
    procedure Compact;
    { IADExpandable }
    { IADSortableList<T> }
    function Contains(const AItem: T): Boolean;
    function ContainsAll(const AItems: Array of T): Boolean;
    function ContainsAny(const AItems: Array of T): Boolean;
    function ContainsNone(const AItems: Array of T): Boolean;
    function EqualItems(const AList: IADSortableList<T>): Boolean;
    function IndexOf(const AItem: T): Integer;
    procedure Remove(const AItem: T);
    procedure RemoveItems(const AItems: Array of T);
    procedure Sort(const AComparer: IADComparer<T>);

    // Properties
    { IADCompactable }
    property Compactor: IADCompactor read GetCompactor write SetCompactor;
    { IADExpandable }
    property Expander: IADExpander read GetExpander write SetExpander;
    { IADSortableList<T> }
    property Sorter: IADListSorter<T> read GetSorter write SetSorter;
  end;

  ///  <summary><c>Abstract Base Type for all Generic Map Collection Types.</c></summary>
  ///  <remarks>
  ///    <para><c>Use IADMapReader for Read-Only access.</c></para>
  ///    <para><c>Use IADMap for Read/Write access.</c></para>
  ///    <para><c>Use IADIterableMap for Iterators.</c></para>
  ///    <para><c>Call .Iterator against IADMapReader to return the IADIterableMap interface reference.</c></para>
  ///  </remarks>
  TADMapBase<TKey, TValue> = class abstract(TADCollection, IADMapReader<TKey, TValue>, IADMap<TKey, TValue>, IADIterableMap<TKey, TValue>)
  private
    // Getters
    { IADMapReader<TKey, TValue> }
    function GetItem(const AKey: TKey): TValue;
    function GetIterator: IADIterableMap<TKey, TValue>;
    function GetPair(const AIndex: Integer): IADKeyValuePair<TKey, TValue>;
    { IADMap<TKey, TValue> }
    function GetReader: IADMapReader<TKey, TValue>;
    { IADIterableMap<TKey, TValue> }

    // Setters
    { IADMapReader<TKey, TValue> }
    { IADMap<TKey, TValue> }
    procedure SetItem(const AKey: TKey; const AValue: TValue);
    { IADIterableMap<TKey, TValue> }
  public
    // Management Methods
    { IADMapReader<TKey, TValue> }
    function Contains(const AKey: TKey): Boolean;
    function ContainsAll(const AKeys: Array of TKey): Boolean;
    function ContainsAny(const AKeys: Array of TKey): Boolean;
    function ContainsNone(const AKeys: Array of TKey): Boolean;
    function EqualItems(const AList: IADMapReader<TKey, TValue>): Boolean;
    function IndexOf(const AKey: TKey): Integer;
    { IADMap<TKey, TValue> }
    function Add(const AItem: IADKeyValuePair<TKey, TValue>): Integer; overload;
    function Add(const AKey: TKey; const AValue: TValue): Integer; overload;
    procedure AddItems(const AItems: Array of IADKeyValuePair<TKey, TValue>); overload;
    procedure AddItems(const AMap: IADMapReader<TKey, TValue>); overload;
    procedure Compact;
    procedure Delete(const AIndex: Integer); overload;
    procedure DeleteRange(const AFromIndex, ACount: Integer); overload;
    procedure Remove(const AKey: TKey);
    procedure RemoveItems(const AKeys: Array of TKey);
    { IADIterableMap<TKey, TValue> }
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure Iterate(const ACallback: TADListMapCallbackAnon<TKey, TValue>; const ADirection: TADIterateDirection = idRight); overload;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure Iterate(const ACallback: TADListMapCallbackOfObject<TKey, TValue>; const ADirection: TADIterateDirection = idRight); overload;
    procedure Iterate(const ACallback: TADListMapCallbackUnbound<TKey, TValue>; const ADirection: TADIterateDirection = idRight); overload;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateBackward(const ACallback: TADListMapCallbackAnon<TKey, TValue>); overload;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateBackward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>); overload;
    procedure IterateBackward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>); overload;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateForward(const ACallback: TADListMapCallbackAnon<TKey, TValue>); overload;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateForward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>); overload;
    procedure IterateForward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>); overload;

    // Properties
    { IADMapReader<TKey, TValue> }
    property Items[const AKey: TKey]: TValue read GetItem; default;
    property Iterator: IADIterableMap<TKey, TValue> read GetIterator;
    property Pairs[const AIndex: Integer]: IADKeyValuePair<TKey, TValue> read GetPair;
    { IADMap<TKey, TValue> }
    property Items[const AKey: TKey]: TValue read GetItem write SetItem; default;
    property Reader: IADMapReader<TKey, TValue> read GetReader;
    { IADIterableMap<TKey, TValue> }
  end;

  ///  <summary><c>Generic Map Collection.</c></summary>
  ///  <remarks>
  ///    <para><c>Use IADMapReader for Read-Only access.</c></para>
  ///    <para><c>Use IADMap for Read/Write access.</c></para>
  ///    <para><c>Use IADIterableMap for Iterators.</c></para>
  ///    <para><c>Call .Iterator against IADMapReader to return the IADIterableMap interface reference.</c></para>
  ///  </remarks>
  TADMap<TKey, TValue> = class(TADMapBase<TKey, TValue>)

  end;

  ///  <summary><c>A Generic Fixed-Capacity Revolving List</c></summary>
  ///  <remarks>
  ///    <para><c>When the current Index is equal to the Capacity, the Index resets to 0, and Items are subsequently Replaced by new ones.</c></para>
  ///    <para><c>Use IADListReader for Read-Only List access.</c></para>
  ///    <para><c>Use IADList for Read/Write List access.</c></para>
  ///    <para><c>Use IADIterableList for Iterators.</c></para>
  ///    <para><c>Call .Iterator against IADListReader to return the IADIterableList interface reference.</c></para>
  ///    <para><c>Use IADCircularListReader for Read-Only Circular List access.</c></para>
  ///    <para><c>Use IADCircularList for Read/Write Circular List access.</c></para>  ///
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADCircularList<T> = class(TADListBase<T>, IADCircularListReader<T>, IADCircularList<T>)
  private
    // Getters
    { IADCircularListReader<T> }
    function GetNewestIndex: Integer;
    function GetNewest: T;
    function GetOldestIndex: Integer;
    function GetOldest: T;
    { IADCircularList<T> }
    function GetReader: IADCircularListReader<T>;

    // Setters
    { IADCircularListReader<T> }
    { IADCircularList<T> }
  public
    // Properties
    { IADCircularListReader<T> }
    property NewestIndex: Integer read GetNewestIndex;
    property Newest: T read GetNewest;
    property OldestIndex: Integer read GetOldestIndex;
    property Oldest: T read GetOldest;
    { IADCircularList<T> }
    property Reader: IADCircularListReader<T> read GetReader;
  end;

implementation

uses
  ADAPT.Comparers;

type
  ///  <summary><c>The Default Allocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>By default, the Array will grow by 1 each time it becomes full</c></remarks>
  TADExpanderDefault = class(TADExpander)
  public
    function CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer; override;
  end;

  ///  <summary><c>The Default Deallocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>By default, the Array will shrink by 1 each time an Item is removed.</c></remarks>
  TADCompactorDefault = class(TADCompactor)
  public
    function CheckCompact(const ACapacity, ACurrentCount, AVacating: Integer): Integer; override;
  end;

var
  GCollectionExpanderDefault: IADExpander;
  GCollectionCompactorDefault: IADCompactor;

function ADCollectionExpanderDefault: IADExpander;
begin
  Result := GCollectionExpanderDefault;
end;

function ADCollectionExpanderGeometric: IADExpanderGeometric;
begin
  Result := TADExpanderGeometric.Create;
end;

function ADCollectionCompactorDefault: IADCompactor;
begin
  Result := GCollectionCompactorDefault;
end;

{ TADExpanderDefault }

function TADExpanderDefault.CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer;
begin
  if ACurrentCount + AAdditionalRequired > ACapacity then
    Result := (ACapacity - ACurrentCount) + AAdditionalRequired
  else
    Result := 0;
end;

{ TADCompactorDefault }

function TADCompactorDefault.CheckCompact(const ACapacity, ACurrentCount, AVacating: Integer): Integer;
begin
  Result := AVacating;
end;

{ TADArray<T> }

procedure TADArray<T>.Clear;
begin
  SetLength(FArray, FCapacityInitial);
  if FCapacityInitial > 0 then
    Finalize(0, FCapacityInitial);
end;

procedure TADArray<T>.Delete(const AIndex: Integer);
var
  I: Integer;
begin
  FArray[AIndex] := nil;
//  System.FillChar(FArray[AIndex], SizeOf(IADValueHolder<T>), 0);
  if AIndex < Length(FArray) - 1 then
  begin
//    System.Move(FArray[AIndex + 1],
//                FArray[AIndex],
//                ((Length(FArray) - 1) - AIndex) * SizeOf(IADValueHolder<T>));
    for I := AIndex to Length(FArray) - 2 do
      FArray[I] := FArray[I + 1];
  end;
end;

constructor TADArray<T>.Create(const ACapacity: Integer);
begin
  inherited Create;
  FCapacityInitial := ACapacity;
  SetLength(FArray, ACapacity);
end;

procedure TADArray<T>.Delete(const AFirstIndex, ACount: Integer);
var
  I: Integer;
begin
  for I := AFirstIndex + (ACount - 1) downto AFirstIndex do
    Delete(I);
end;

destructor TADArray<T>.Destroy;
begin

  inherited;
end;

procedure TADArray<T>.Finalize(const AIndex, ACount: Integer);
begin
  System.Finalize(FArray[AIndex], ACount);
  System.FillChar(FArray[AIndex], ACount * SizeOf(T), 0);
end;

function TADArray<T>.GetCapacity: Integer;
begin
  Result := Length(FArray);
end;

function TADArray<T>.GetItem(const AIndex: Integer): T;
begin
  if (AIndex < Low(FArray)) or (AIndex > High(FArray)) then
    raise EADGenericsRangeException.CreateFmt('Index [%d] Out Of Range', [AIndex]);
  Result := FArray[AIndex].Value;
end;

function TADArray<T>.GetReader: IADArrayReader<T>;
begin
  Result := IADArrayReader<T>(Self);
end;

procedure TADArray<T>.Insert(const AItem: T; const AIndex: Integer);
begin
  Move(AIndex, AIndex + 1, (Capacity - AIndex) - 1);
  Finalize(AIndex, 1);
  FArray[AIndex] := TADValueHolder<T>.Create(AItem);
end;

procedure TADArray<T>.Move(const AFromIndex, AToIndex, ACount: Integer);
var
  LItem: T;
  I: Integer;
begin
  if AFromIndex < AToIndex then
  begin
    for I := AFromIndex + ACount downto AFromIndex + 1 do
      FArray[I] := FArray[I - (AToIndex - AFromIndex)];
  end else
    System.Move(FArray[AFromIndex], FArray[AToIndex], ACount * SizeOf(T));
end;

procedure TADArray<T>.SetCapacity(const ACapacity: Integer);
begin
  SetLength(FArray, ACapacity);
end;

procedure TADArray<T>.SetItem(const AIndex: Integer; const AItem: T);
begin
  FArray[AIndex] := TADValueHolder<T>.Create(AItem);
end;

{ TADExpanderGeometric }

function TADExpanderGeometric.CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer;
begin
  if (AAdditionalRequired < FThreshold) then
  begin
    if (Round(ACapacity * FMultiplier)) > (FMultiplier + FThreshold) then
      Result :=  Round(ACapacity * FMultiplier)
    else
      Result := ACapacity + AAdditionalRequired + FThreshold; // Expand to ensure everything fits
  end else
    Result := 0;
end;

function TADExpanderGeometric.GetCapacityMultiplier: Single;
begin
  Result := FMultiplier;
end;

function TADExpanderGeometric.GetCapacityThreshold: Integer;
begin
  Result := FThreshold;
end;

procedure TADExpanderGeometric.SetCapacityMultiplier(const AMultiplier: Single);
begin
  FMultiplier := AMultiplier;
end;

procedure TADExpanderGeometric.SetCapacityThreshold(const AThreshold: Integer);
begin
  FThreshold := AThreshold;
end;

{ TADCollection }

procedure TADCollection.Clear;
begin

end;

function TADCollection.GetCapacity: Integer;
begin

end;

function TADCollection.GetCount: Integer;
begin

end;

function TADCollection.GetInitialCapacity: Integer;
begin

end;

function TADCollection.GetIsCompact: Boolean;
begin

end;

function TADCollection.GetIsEmpty: Boolean;
begin

end;

function TADCollection.GetReader: IADCollectionReader;
begin

end;

function TADCollection.GetSortedState: TADSortedState;
begin

end;

procedure TADCollection.SetCapacity(const ACapacity: Integer);
begin

end;

{ TADListBase<T> }

function TADListBase<T>.Add(const AItem: T): Integer;
begin

end;

procedure TADListBase<T>.Add(const AItems: IADListReader<T>);
begin

end;

procedure TADListBase<T>.AddItems(const AItems: array of T);
begin

end;

procedure TADListBase<T>.Delete(const AIndex: Integer);
begin

end;

procedure TADListBase<T>.DeleteRange(const AFirst, ACount: Integer);
begin

end;

function TADListBase<T>.GetItem(const AIndex: Integer): T;
begin

end;

function TADListBase<T>.GetIterator: IADIterableList<T>;
begin
  Result := IADIterableList<T>(Self);
end;

function TADListBase<T>.GetReader: IADListReader<T>;
begin
  Result := IADListReader<T>(Self);
end;

procedure TADListBase<T>.Insert(const AItem: T; const AIndex: Integer);
begin

end;

procedure TADListBase<T>.InsertItems(const AItems: Array of T; const AIndex: Integer);
begin

end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADListBase<T>.Iterate(const ACallback: TADListItemCallbackAnon<T>; const ADirection: TADIterateDirection = idRight);
  begin

  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADListBase<T>.Iterate(const ACallback: TADListItemCallbackOfObject<T>; const ADirection: TADIterateDirection);
begin

end;

procedure TADListBase<T>.Iterate(const ACallback: TADListItemCallbackUnbound<T>; const ADirection: TADIterateDirection);
begin

end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADListBase<T>.IterateBackward(const ACallback: TADListItemCallbackAnon<T>);
  begin

  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADListBase<T>.IterateBackward(const ACallback: TADListItemCallbackOfObject<T>);
begin

end;

procedure TADListBase<T>.IterateBackward(const ACallback: TADListItemCallbackUnbound<T>);
begin

end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
procedure TADListBase<T>.IterateForward(const ACallback: TADListItemCallbackAnon<T>);
begin

end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADListBase<T>.IterateForward(const ACallback: TADListItemCallbackOfObject<T>);
begin

end;

procedure TADListBase<T>.IterateForward(const ACallback: TADListItemCallbackUnbound<T>);
begin

end;

procedure TADListBase<T>.SetItem(const AIndex: Integer; const AItem: T);
begin

end;

{ TADList<T> }

procedure TADList<T>.Compact;
begin

end;

function TADList<T>.Contains(const AItem: T): Boolean;
begin

end;

function TADList<T>.ContainsAll(const AItems: array of T): Boolean;
begin

end;

function TADList<T>.ContainsAny(const AItems: array of T): Boolean;
begin

end;

function TADList<T>.ContainsNone(const AItems: array of T): Boolean;
begin

end;

function TADList<T>.EqualItems(const AList: IADSortableList<T>): Boolean;
begin

end;

function TADList<T>.GetCompactor: IADCompactor;
begin

end;

function TADList<T>.GetExpander: IADExpander;
begin

end;

function TADList<T>.GetSorter: IADListSorter<T>;
begin

end;

function TADList<T>.IndexOf(const AItem: T): Integer;
begin

end;

procedure TADList<T>.Remove(const AItem: T);
begin

end;

procedure TADList<T>.RemoveItems(const AItems: array of T);
begin

end;

procedure TADList<T>.SetCompactor(const ACompactor: IADCompactor);
begin

end;

procedure TADList<T>.SetExpander(const AExpander: IADExpander);
begin

end;

procedure TADList<T>.SetSorter(const ASorter: IADListSorter<T>);
begin

end;

procedure TADList<T>.Sort(const AComparer: IADComparer<T>);
begin

end;

{ TADMapBase<TKey, TValue> }

function TADMapBase<TKey, TValue>.Add(const AKey: TKey; const AValue: TValue): Integer;
begin

end;

function TADMapBase<TKey, TValue>.Add(const AItem: IADKeyValuePair<TKey, TValue>): Integer;
begin

end;

procedure TADMapBase<TKey, TValue>.AddItems(const AItems: array of IADKeyValuePair<TKey, TValue>);
begin

end;

procedure TADMapBase<TKey, TValue>.AddItems(const AMap: IADMapReader<TKey, TValue>);
begin

end;

procedure TADMapBase<TKey, TValue>.Compact;
begin

end;

function TADMapBase<TKey, TValue>.Contains(const AKey: TKey): Boolean;
begin

end;

function TADMapBase<TKey, TValue>.ContainsAll(const AKeys: array of TKey): Boolean;
begin

end;

function TADMapBase<TKey, TValue>.ContainsAny(const AKeys: array of TKey): Boolean;
begin

end;

function TADMapBase<TKey, TValue>.ContainsNone(const AKeys: array of TKey): Boolean;
begin

end;

procedure TADMapBase<TKey, TValue>.Delete(const AIndex: Integer);
begin

end;

procedure TADMapBase<TKey, TValue>.DeleteRange(const AFromIndex, ACount: Integer);
begin

end;

function TADMapBase<TKey, TValue>.EqualItems(const AList: IADMapReader<TKey, TValue>): Boolean;
begin

end;

function TADMapBase<TKey, TValue>.GetItem(const AKey: TKey): TValue;
begin

end;

function TADMapBase<TKey, TValue>.GetIterator: IADIterableMap<TKey, TValue>;
begin
  Result := IADIterableMap<TKey, TValue>(Self);
end;

function TADMapBase<TKey, TValue>.GetPair(const AIndex: Integer): IADKeyValuePair<TKey, TValue>;
begin

end;

function TADMapBase<TKey, TValue>.GetReader: IADMapReader<TKey, TValue>;
begin
  Result := IADMapReader<TKey, TValue>(Self);
end;

function TADMapBase<TKey, TValue>.IndexOf(const AKey: TKey): Integer;
begin

end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADMapBase<TKey, TValue>.Iterate(const ACallback: TADListMapCallbackAnon<TKey, TValue>; const ADirection: TADIterateDirection = idRight);
  begin

  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADMapBase<TKey, TValue>.Iterate(const ACallback: TADListMapCallbackUnbound<TKey, TValue>; const ADirection: TADIterateDirection);
begin

end;

procedure TADMapBase<TKey, TValue>.Iterate(const ACallback: TADListMapCallbackOfObject<TKey, TValue>; const ADirection: TADIterateDirection);
begin

end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADMapBase<TKey, TValue>.IterateBackward(const ACallback: TADListMapCallbackAnon<TKey, TValue>);
  begin

  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADMapBase<TKey, TValue>.IterateBackward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>);
begin

end;

procedure TADMapBase<TKey, TValue>.IterateBackward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>);
begin

end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADMapBase<TKey, TValue>.IterateForward(const ACallback: TADListMapCallbackAnon<TKey, TValue>);
  begin

  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADMapBase<TKey, TValue>.IterateForward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>);
begin

end;

procedure TADMapBase<TKey, TValue>.IterateForward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>);
begin

end;

procedure TADMapBase<TKey, TValue>.Remove(const AKey: TKey);
begin

end;

procedure TADMapBase<TKey, TValue>.RemoveItems(const AKeys: array of TKey);
begin

end;

procedure TADMapBase<TKey, TValue>.SetItem(const AKey: TKey; const AValue: TValue);
begin

end;

{ TADCircularList<T> }

function TADCircularList<T>.GetNewest: T;
begin

end;

function TADCircularList<T>.GetNewestIndex: Integer;
begin

end;

function TADCircularList<T>.GetOldest: T;
begin

end;

function TADCircularList<T>.GetOldestIndex: Integer;
begin

end;

function TADCircularList<T>.GetReader: IADCircularListReader<T>;
begin
  Result := IADCircularListReader<T>(Self);
end;

initialization
  GCollectionExpanderDefault := TADExpanderDefault.Create;
  GCollectionCompactorDefault := TADCompactorDefault.Create;

end.
