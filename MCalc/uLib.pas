unit uLib;

interface
uses SysUtils, uStorage,Classes;

//�������� ���� ������
function loadLib(AOwner:TComponent):TLib;

procedure calculateValues(f:TForma;plotn:double); //������ �������� � ��������� �� �������� ��� Forma

implementation

uses Math, uMain;

function loadLib(AOwner:TComponent):TLib;
var pMet :TMetal;
    pLib: TLib;
    pListAll:TMetalList;
    pListNoAll:TMetalList;
    f:TForma;
begin
 pLib := TLib.Create(AOwner);
 pListAll := pLib.AddMetalList('��� ����� �������');
 pListNoAll := pLib.AddMetalList('������');

 //������������ ������� � ����� (���������)
 pMet := pLib.AddMetal('��������');
 with pMet do
 begin
    AddBrand('�5, �6, �7, ��0',  2.850 * 0.950);
    AddBrand('���2',	2.850 *	0.940);
    AddBrand('���3',	2.850 *	0.937);
    AddBrand('���5',	2.850 *	0.930);
    AddBrand('���6',	2.850 *	0.926);
    AddBrand('��1',	  2.850 *	0.950);
    AddBrand('��31',	2.850 *	0.95);
    AddBrand('���', 	2.850 *	0.958);
    AddBrand('�16',	  2.850 *	0.976);
    //AddBrand('000',	  2.850 *	1);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������


 pMet := pLib.AddMetal('������');
 with pMet do
 begin
    AddBrand('����9-4',7.6);
    AddBrand('�����5-5-5',8.84);
    AddBrand('������10-3-1,5',7.5);
    AddBrand('�����9-2',7.6);
    AddBrand('�����3-1',8.4);
    AddBrand('���2',8.2);
    AddBrand('���1',8.9);
    AddBrand('�����10-4-4',7.5);
    AddBrand('����6,5-0,15',8.8);
    AddBrand('����7-0.2',8.6);
    AddBrand('����4-3',8.8);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('����');
 with pMet do
 begin
    AddBrand('�1, �2, �3',8.94);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������


 pMet := pLib.AddMetal('������');  //������, ����� ������� ��������
 with pMet do
 begin
    BrandAdd(	8.440, '�63');
    BrandAdd(	8.450, '��59-1');
    BrandAdd(	8.600, '�68');
    BrandAdd(	8.500, '����59-1-1');
    BrandAdd(	8.400, '���58-2');
    BrandAdd(	8.610, '�70');
    BrandAdd(	8.660, '�80');
    BrandAdd(	8.750, '�85');
    BrandAdd(	8.780, '�90');
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������


 pMet := pLib.AddMetal('������');  //������, ������ ��������
 with pMet do
 begin
    BrandAdd(	8.400, '�60, �63');
    BrandAdd(	8.450, '��59-1');
    BrandAdd(	8.500, '���58-2');
    BrandAdd(	8.200, '����59-1-1');
 end;
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('�����-��������� �����');
 with pMet do
 begin
    AddBrand('�������� ����3-12',8.400);
    AddBrand('���5-1',8.700);
    AddBrand('�������� ��19',8.900);
    AddBrand('������ ����43-0,5',8.900);
    AddBrand('���������� ����40-1,5',8.900);
    AddBrand('������� � ���6-1,5',8.500);
    AddBrand('������� � ���6-1,5',8.700);
    AddBrand('���������� ��� 15-20',8.700);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('��������� ������');
 with pMet do
 begin
    AddBrand('������� �����2-2-1',8.500);
    AddBrand('������ �����28-2,5-1,5',8.800);
    AddBrand('������� � ��9,5',8.700);
    AddBrand('���2,5',8.900);
    AddBrand('���5',8.800);
    AddBrand('�� 0,2',8.900);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('������');
 with pMet do
 begin
  AddBrand('�15�60',8.200);
  AddBrand('�20�80',8.400);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('����');
 with pMet do
 begin
  AddBrand('�0',7.130);
  AddBrand('�1',7.130);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('������');
 with pMet do
 begin
    AddBrand('�0',11.370);
    AddBrand('�1',11.370);
    AddBrand('�2',11.370);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('�����');
 with pMet do
 begin
    AddBrand('�1',7.300);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('����������� �����');
 with pMet do
 begin
    AddBrand('04�18�10�, 08�18�12�',7.900);
    AddBrand('08X17�, 08X13, 08�20�14�2',7.700);
    AddBrand('08�22�6�, 15�25�',7.600);
    AddBrand('08�18�10, 08�18�10�',7.900);
    AddBrand('08�18�12�',7.950);
    AddBrand('08�17�5���',8.100);
    AddBrand('10�17�13�2�',8.000);
    AddBrand('10�23�18',7.950);
    AddBrand('12X13, 12X17',7.700);
    AddBrand('12�18�10�, 12�18�12�',7.900);
    AddBrand('12�18�9',7.900);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 pMet := pLib.AddMetal('�����');
 with pMet do
 begin
   AddBrand('��3, ��5, ��10, ��20',7.85);
 end;
 pListAll.Metals.Add(pMet); //���������� � ������ ��� ����, ����� �������
 pListNoAll.Metals.Add(pMet); //���������� � ������ �������

 //������������ �����
 f := pLib.AddForma('����, �����, �����, ������, ����',pListAll);
 f.Name := '����, �����, �����, ������, ����';
 f.UseArea := True;
 f.Picture := fmMain.imList;
 f.AddParam('T','�������',ukMM);
 f.AddParam('W','������',ukMM);
 f.AddParam('L','�����',ukM);



 f := pLib.AddForma('����, ���������',pListNoAll);
 f.Name := '����, ���������';
 f.Picture := fmMain.imPrutok;
 f.AddParam('W','�������',ukMM);
 f.AddParam('L','�����',ukM);


 f := pLib.AddForma('������������',pListAll);
 f.Name := '������������';
 f.Picture := fmMain.imShestigran;
 f.AddParam('W','�������',ukMM,'������� ���������� ����� ("������ ��� �����")');
 f.AddParam('L','�����',ukM);

 f := pLib.AddForma('�������',pListAll);
 f.Name := '�������';
 f.Picture := fmMain.imKvadrat;
 f.AddParam('W','�������',ukMM);
 f.AddParam('L','�����',ukM);

 f := pLib.AddForma('����� �������, ������',pListAll);
 f.Name := '����� �������, ������';
 f.Picture := fmMain.imTruba;
 f.AddParam('W','�������',ukMM);
 f.AddParam('T','������� ������',ukMM);
 f.AddParam('L','�����',ukM);

 f := pLib.AddForma('����� ����������',pListAll);
 f.Name := '����� ����������';
 f.Picture := fmMain.imProfil;
 f.AddParam('H','������ �����',ukMM);
 f.AddParam('W','������ �����',ukMM);
 f.AddParam('T','������� ������',ukMM);
 f.AddParam('L','�����',ukM);

 f := pLib.AddForma('������',pListAll);
 f.Name := '������';
 f.Picture := fmMain.imUgol;
 f.AddParam('H','������ ����� 1',ukMM);
 f.AddParam('H2','������ ����� 2',ukMM);
 f.AddParam('T','������� ������',ukMM);
 f.AddParam('L','�����',ukM);

 f := pLib.AddForma('�����',pListAll);
 f.Name := '�����';
 f.Picture := fmMain.imDvutavr;
 f.AddParam('H','������ �����',ukMM);
 f.AddParam('W','������ �����',ukMM);
 f.AddParam('T','������� ������',ukMM);
 f.AddParam('Tp','������� ���������',ukMM);
 f.AddParam('L','�����',ukM);


 f := pLib.AddForma('�������',pListAll);
 f.Name := '�������';
 f.Picture := fmMain.imShveller;
 f.AddParam('H','������ ��������',ukMM);
 f.AddParam('W','������ ��������',ukMM);
 f.AddParam('T','������� ������',ukMM);
 f.AddParam('L','�����',ukM);

 f := pLib.AddForma('����',pListAll);
 f.Name := '����';
 f.Picture := fmMain.imTavr;
 f.AddParam('H','������ �����',ukMM);
 f.AddParam('W','������ �����',ukMM);
 f.AddParam('T','������� ������',ukMM);
 f.AddParam('Tp','������� ���������',ukMM);
 f.AddParam('L','�����',ukM);


 Result := pLib;
end;

procedure calculateValues(f:TForma;plotn:double); //������ �������� � ��������� �� �������� ��� Forma
var W:double;
    A:double;
begin
 W := 0;
 A := 0;
 if f.Name = '����, �����, �����, ������, ����' then
 begin
   A := f.val('L')*f.val('W')/(1000);
   W := f.val('L')*f.val('W')*f.val('T')*plotn /(1000)  ;
   //f.AddParam('L','�����',ukM);
   //f.AddParam('W','������',ukMM);
   //f.AddParam('T','�������',ukMM);
 end
 else if f.Name = '����, ���������' then
 begin
   W :=  f.val('L')*  (pi * (f.val('W')/2)*(f.val('W')/2) )  *plotn/1000;
   //f.AddParam('L','�����',ukM);
   //f.AddParam('D','�������',ukMM);
 end
 else if  f.Name = '������������' then
 begin
   W := plotn * f.val('L') * (2*sqrt(3)) * (f.val('W')/2) * (f.val('W')/2)/1000

   // W := f.val('L') * plotn * (sqrt(3)/2) * (f.val('S')/2) * (f.val('S')/2)/1000;
   //f.AddParam('L','�����',ukM);
   //f.AddParam('S','�������',ukMM,'������� ���������� ����� ("������ ��� �����")');
 end
 else if  f.Name = '�������' then
 begin
   W := f.val('L')*f.val('W')*f.val('W')*plotn/1000;
   //f.AddParam('L','�����',ukM);
   //f.AddParam('S','�������',ukMM);
 end
 else if f.Name = '����� �������, ������' then
 begin
 //  pi*R�_2 - pi*R�_2 = pi*(R�_2 - R�_2) = pi*( (D/2)*(D/2)  - ((D-T)/2)*(D-T)/2)))

   W := f.val('L')*  pi* ( (f.val('W')/2) * (f.val('W')/2)  -  ((f.val('W')-f.val('T')*2)/2) * ((f.val('W')-f.val('T')*2)/2) ) * plotn/1000;
   //f.AddParam('L','�����',ukM);
   //f.AddParam('D','�������',ukMM);
 end
 else if  f.Name = '����� ����������' then
 begin
   W := f.val('L') * plotn *  2* f.val('T')  * ( f.val('W') + f.val('H') - 2*f.val('T') )/1000;
// f.AddParam('L','�����',ukM);
// f.AddParam('T','������� ������',ukMM);
// f.AddParam('W','������ �����',ukMM);
// f.AddParam('H','������ �����',ukMM);

 end
 else if  f.Name = '������' then
 begin
  W := f.val('L') * plotn *  f.val('T')*( f.val('H') + f.val('H2') - f.val('T') )/1000;
// f.AddParam('L','�����',ukM);
// f.AddParam('T','������� ������',ukMM);
// f.AddParam('H1','������ ����� 1',ukMM);
// f.AddParam('H2','������ ����� 2',ukMM);
 end
 else if f.Name = '�������' then
 begin
  W := f.val('L') * plotn *  f.val('T')*( 2*f.val('H') + f.val('W') - 2*f.val('T') )/1000;
// f.AddParam('L','�����',ukM);
// f.AddParam('T','������� ������',ukMM);
// f.AddParam('H','������ ��������',ukMM);
// f.AddParam('W','������ ��������',ukMM);
 end
 else if f.Name = '����' then
 begin
   W := f.val('L') *( f.val('W')*f.val('T') + f.val('Tp')*f.val('H') - f.val('T')) *  plotn /1000;
// f.AddParam('H','������ �����',ukMM);
 //f.AddParam('W','������ �����',ukMM);
 //f.AddParam('Ts','������� ������',ukMM);
 //f.AddParam('Tp','������� ���������',ukMM);
 //f.AddParam('L','�����',ukM);
 end
 else if  f.Name = '�����' then
 begin
//    W := 2 * f.val('L') *( f.val('W')*f.val('Ts')/2 + f.val('Tp')*f.val('H') - f.val('Ts')) *  plotn /1000;
     W := f.val('L') *( 2* f.val('W')*f.val('T')  + f.val('Tp')*( f.val('H') - 2*f.val('T')) ) *  plotn /1000;
//   f.AddParam('L','�����',ukM);
//   f.AddParam('Ts','������� ������',ukMM);
//   f.AddParam('Tp','������� ���������',ukMM);
//   f.AddParam('H','������ �����',ukMM);
 end
 else begin
  raise Exception.Create('�� �������������� ����� �������');
 end;
 f.SetCalculated(W,A);
end;

end.
