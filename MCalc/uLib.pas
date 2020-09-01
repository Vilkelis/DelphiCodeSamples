unit uLib;

interface
uses SysUtils, uStorage,Classes;

//Загрузка всех данных
function loadLib(AOwner:TComponent):TLib;

procedure calculateValues(f:TForma;plotn:double); //Расчет значений и установка их текущими для Forma

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
 pListAll := pLib.AddMetalList('Все кроме прутков');
 pListNoAll := pLib.AddMetalList('Прутки');

 //ОБРАБАТЫВАЕМ МЕТАЛЛЫ И МАРКИ (ПЛОТНОСТИ)
 pMet := pLib.AddMetal('Алюминий');
 with pMet do
 begin
    AddBrand('А5, А6, А7, АД0',  2.850 * 0.950);
    AddBrand('АМг2',	2.850 *	0.940);
    AddBrand('АМг3',	2.850 *	0.937);
    AddBrand('АМг5',	2.850 *	0.930);
    AddBrand('АМг6',	2.850 *	0.926);
    AddBrand('АД1',	  2.850 *	0.950);
    AddBrand('АД31',	2.850 *	0.95);
    AddBrand('АМц', 	2.850 *	0.958);
    AddBrand('Д16',	  2.850 *	0.976);
    //AddBrand('000',	  2.850 *	1);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков


 pMet := pLib.AddMetal('Бронза');
 with pMet do
 begin
    AddBrand('БрАЖ9-4',7.6);
    AddBrand('БрОЦС5-5-5',8.84);
    AddBrand('БрАЖМц10-3-1,5',7.5);
    AddBrand('БрАМц9-2',7.6);
    AddBrand('БрКМц3-1',8.4);
    AddBrand('БрБ2',8.2);
    AddBrand('БрХ1',8.9);
    AddBrand('БрАЖН10-4-4',7.5);
    AddBrand('БрОФ6,5-0,15',8.8);
    AddBrand('БрОФ7-0.2',8.6);
    AddBrand('БрОЦ4-3',8.8);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Медь');
 with pMet do
 begin
    AddBrand('М1, М2, М3',8.94);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков


 pMet := pLib.AddMetal('Латунь');  //Латунь, кроме прутков латунных
 with pMet do
 begin
    BrandAdd(	8.440, 'Л63');
    BrandAdd(	8.450, 'ЛС59-1');
    BrandAdd(	8.600, 'Л68');
    BrandAdd(	8.500, 'ЛЖМц59-1-1');
    BrandAdd(	8.400, 'ЛМц58-2');
    BrandAdd(	8.610, 'Л70');
    BrandAdd(	8.660, 'Л80');
    BrandAdd(	8.750, 'Л85');
    BrandAdd(	8.780, 'Л90');
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков


 pMet := pLib.AddMetal('Латунь');  //Латунь, прутки латунные
 with pMet do
 begin
    BrandAdd(	8.400, 'Л60, Л63');
    BrandAdd(	8.450, 'ЛС59-1');
    BrandAdd(	8.500, 'ЛМц58-2');
    BrandAdd(	8.200, 'ЛЖМц59-1-1');
 end;
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Медно-никелевый сплав');
 with pMet do
 begin
    AddBrand('Манганин МНМц3-12',8.400);
    AddBrand('МНЖ5-1',8.700);
    AddBrand('Мельхиор МН19',8.900);
    AddBrand('Копель МНМц43-0,5',8.900);
    AddBrand('Константан МНМц40-1,5',8.900);
    AddBrand('Куниаль А МНА6-1,5',8.500);
    AddBrand('Куниаль Б МНА6-1,5',8.700);
    AddBrand('Нейзильбер МНЦ 15-20',8.700);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Никелевые сплавы');
 with pMet do
 begin
    AddBrand('Алюмель НМцАК2-2-1',8.500);
    AddBrand('Монель НМЖМц28-2,5-1,5',8.800);
    AddBrand('Хромель Т НХ9,5',8.700);
    AddBrand('НМц2,5',8.900);
    AddBrand('НМц5',8.800);
    AddBrand('НК 0,2',8.900);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Нихром');
 with pMet do
 begin
  AddBrand('Х15Н60',8.200);
  AddBrand('Х20Н80',8.400);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Цинк');
 with pMet do
 begin
  AddBrand('Ц0',7.130);
  AddBrand('Ц1',7.130);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Свинец');
 with pMet do
 begin
    AddBrand('С0',11.370);
    AddBrand('С1',11.370);
    AddBrand('С2',11.370);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Олово');
 with pMet do
 begin
    AddBrand('О1',7.300);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Нержавеющая сталь');
 with pMet do
 begin
    AddBrand('04Х18Н10Т, 08Х18Н12Б',7.900);
    AddBrand('08X17Т, 08X13, 08Х20Н14С2',7.700);
    AddBrand('08Х22Н6Т, 15Х25Т',7.600);
    AddBrand('08Х18Н10, 08Х18Н10Т',7.900);
    AddBrand('08Х18Н12Т',7.950);
    AddBrand('08Х17Ш5МЗТ',8.100);
    AddBrand('10Х17Н13М2Т',8.000);
    AddBrand('10Х23Н18',7.950);
    AddBrand('12X13, 12X17',7.700);
    AddBrand('12Х18Н10Т, 12Х18Н12Т',7.900);
    AddBrand('12Х18Н9',7.900);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 pMet := pLib.AddMetal('Сталь');
 with pMet do
 begin
   AddBrand('Ст3, Ст5, Ст10, Ст20',7.85);
 end;
 pListAll.Metals.Add(pMet); //Включается в список для всех, кроме прутков
 pListNoAll.Metals.Add(pMet); //Включается в список прутков

 //ОБРАБАТЫВАЕМ ФОРМЫ
 f := pLib.AddForma('Лист, плита, лента, полоса, шина',pListAll);
 f.Name := 'Лист, плита, лента, полоса, шина';
 f.UseArea := True;
 f.Picture := fmMain.imList;
 f.AddParam('T','Толщина',ukMM);
 f.AddParam('W','Ширина',ukMM);
 f.AddParam('L','Длина',ukM);



 f := pLib.AddForma('Круг, проволока',pListNoAll);
 f.Name := 'Круг, проволока';
 f.Picture := fmMain.imPrutok;
 f.AddParam('W','Диаметр',ukMM);
 f.AddParam('L','Длина',ukM);


 f := pLib.AddForma('Шестигранник',pListAll);
 f.Name := 'Шестигранник';
 f.Picture := fmMain.imShestigran;
 f.AddParam('W','Сечение',ukMM,'диаметр вписанного круга ("размер под ключь")');
 f.AddParam('L','Длина',ukM);

 f := pLib.AddForma('Квадрат',pListAll);
 f.Name := 'Квадрат';
 f.Picture := fmMain.imKvadrat;
 f.AddParam('W','Сечение',ukMM);
 f.AddParam('L','Длина',ukM);

 f := pLib.AddForma('Труба круглая, втулка',pListAll);
 f.Name := 'Труба круглая, втулка';
 f.Picture := fmMain.imTruba;
 f.AddParam('W','Диаметр',ukMM);
 f.AddParam('T','Толщина стенки',ukMM);
 f.AddParam('L','Длина',ukM);

 f := pLib.AddForma('Труба профильная',pListAll);
 f.Name := 'Труба профильная';
 f.Picture := fmMain.imProfil;
 f.AddParam('H','Высота трубы',ukMM);
 f.AddParam('W','Ширина трубы',ukMM);
 f.AddParam('T','Толщина стенки',ukMM);
 f.AddParam('L','Длина',ukM);

 f := pLib.AddForma('Уголок',pListAll);
 f.Name := 'Уголок';
 f.Picture := fmMain.imUgol;
 f.AddParam('H','Высота полки 1',ukMM);
 f.AddParam('H2','Высота полки 2',ukMM);
 f.AddParam('T','Толщина стенки',ukMM);
 f.AddParam('L','Длина',ukM);

 f := pLib.AddForma('Балка',pListAll);
 f.Name := 'Балка';
 f.Picture := fmMain.imDvutavr;
 f.AddParam('H','Высота балки',ukMM);
 f.AddParam('W','Ширина балки',ukMM);
 f.AddParam('T','Толщина стенки',ukMM);
 f.AddParam('Tp','Толщина перемычки',ukMM);
 f.AddParam('L','Длина',ukM);


 f := pLib.AddForma('Швеллер',pListAll);
 f.Name := 'Швеллер';
 f.Picture := fmMain.imShveller;
 f.AddParam('H','Высота швеллера',ukMM);
 f.AddParam('W','Ширина швеллера',ukMM);
 f.AddParam('T','Толщина стенки',ukMM);
 f.AddParam('L','Длина',ukM);

 f := pLib.AddForma('Тавр',pListAll);
 f.Name := 'Тавр';
 f.Picture := fmMain.imTavr;
 f.AddParam('H','Высота тавра',ukMM);
 f.AddParam('W','Ширина тавра',ukMM);
 f.AddParam('T','Толщина стенки',ukMM);
 f.AddParam('Tp','Толщина перемычки',ukMM);
 f.AddParam('L','Длина',ukM);


 Result := pLib;
end;

procedure calculateValues(f:TForma;plotn:double); //Расчет значений и установка их текущими для Forma
var W:double;
    A:double;
begin
 W := 0;
 A := 0;
 if f.Name = 'Лист, плита, лента, полоса, шина' then
 begin
   A := f.val('L')*f.val('W')/(1000);
   W := f.val('L')*f.val('W')*f.val('T')*plotn /(1000)  ;
   //f.AddParam('L','Длина',ukM);
   //f.AddParam('W','Ширина',ukMM);
   //f.AddParam('T','Толщина',ukMM);
 end
 else if f.Name = 'Круг, проволока' then
 begin
   W :=  f.val('L')*  (pi * (f.val('W')/2)*(f.val('W')/2) )  *plotn/1000;
   //f.AddParam('L','Длина',ukM);
   //f.AddParam('D','Диаметр',ukMM);
 end
 else if  f.Name = 'Шестигранник' then
 begin
   W := plotn * f.val('L') * (2*sqrt(3)) * (f.val('W')/2) * (f.val('W')/2)/1000

   // W := f.val('L') * plotn * (sqrt(3)/2) * (f.val('S')/2) * (f.val('S')/2)/1000;
   //f.AddParam('L','Длина',ukM);
   //f.AddParam('S','Сечение',ukMM,'диаметр вписанного круга ("размер под ключь")');
 end
 else if  f.Name = 'Квадрат' then
 begin
   W := f.val('L')*f.val('W')*f.val('W')*plotn/1000;
   //f.AddParam('L','Длина',ukM);
   //f.AddParam('S','Сечение',ukMM);
 end
 else if f.Name = 'Труба круглая, втулка' then
 begin
 //  pi*Rб_2 - pi*Rм_2 = pi*(Rб_2 - Rм_2) = pi*( (D/2)*(D/2)  - ((D-T)/2)*(D-T)/2)))

   W := f.val('L')*  pi* ( (f.val('W')/2) * (f.val('W')/2)  -  ((f.val('W')-f.val('T')*2)/2) * ((f.val('W')-f.val('T')*2)/2) ) * plotn/1000;
   //f.AddParam('L','Длина',ukM);
   //f.AddParam('D','Диаметр',ukMM);
 end
 else if  f.Name = 'Труба профильная' then
 begin
   W := f.val('L') * plotn *  2* f.val('T')  * ( f.val('W') + f.val('H') - 2*f.val('T') )/1000;
// f.AddParam('L','Длина',ukM);
// f.AddParam('T','Толщина стенки',ukMM);
// f.AddParam('W','Ширина трубы',ukMM);
// f.AddParam('H','Высота трубы',ukMM);

 end
 else if  f.Name = 'Уголок' then
 begin
  W := f.val('L') * plotn *  f.val('T')*( f.val('H') + f.val('H2') - f.val('T') )/1000;
// f.AddParam('L','Длина',ukM);
// f.AddParam('T','Толщина стенки',ukMM);
// f.AddParam('H1','Высота полки 1',ukMM);
// f.AddParam('H2','Высота полки 2',ukMM);
 end
 else if f.Name = 'Швеллер' then
 begin
  W := f.val('L') * plotn *  f.val('T')*( 2*f.val('H') + f.val('W') - 2*f.val('T') )/1000;
// f.AddParam('L','Длина',ukM);
// f.AddParam('T','Толщина стенки',ukMM);
// f.AddParam('H','Высота швеллера',ukMM);
// f.AddParam('W','Ширина швеллера',ukMM);
 end
 else if f.Name = 'Тавр' then
 begin
   W := f.val('L') *( f.val('W')*f.val('T') + f.val('Tp')*f.val('H') - f.val('T')) *  plotn /1000;
// f.AddParam('H','Высота тавра',ukMM);
 //f.AddParam('W','Ширина тавра',ukMM);
 //f.AddParam('Ts','Толщина стенки',ukMM);
 //f.AddParam('Tp','Толщина перемычки',ukMM);
 //f.AddParam('L','Длина',ukM);
 end
 else if  f.Name = 'Балка' then
 begin
//    W := 2 * f.val('L') *( f.val('W')*f.val('Ts')/2 + f.val('Tp')*f.val('H') - f.val('Ts')) *  plotn /1000;
     W := f.val('L') *( 2* f.val('W')*f.val('T')  + f.val('Tp')*( f.val('H') - 2*f.val('T')) ) *  plotn /1000;
//   f.AddParam('L','Длина',ukM);
//   f.AddParam('Ts','Толщина стенки',ukMM);
//   f.AddParam('Tp','Толщина перемычки',ukMM);
//   f.AddParam('H','Высота балки',ukMM);
 end
 else begin
  raise Exception.Create('Не поддерживаемая форма изделия');
 end;
 f.SetCalculated(W,A);
end;

end.
