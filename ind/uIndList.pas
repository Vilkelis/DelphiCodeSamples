unit uIndList;

interface
uses Classes;

type TIndList = class (TList)
public
 class function IsIndList:boolean;
end;

implementation

{ TIndList }

class function TIndList.IsIndList: boolean;
begin
 Result := True;
end;

end.
