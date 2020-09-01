object fmLine: TfmLine
  Left = 502
  Top = 220
  AlphaBlend = True
  AlphaBlendValue = 150
  BiDiMode = bdLeftToRight
  BorderStyle = bsNone
  Caption = 'Ruler'
  ClientHeight = 23
  ClientWidth = 364
  Color = clGradientActiveCaption
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object imRotate: TImage
    Left = 201
    Top = 4
    Width = 16
    Height = 16
    Cursor = crHandPoint
    AutoSize = True
    ParentShowHint = False
    Picture.Data = {
      07544269746D6170DE020000424DDE02000000000000DE010000280000001000
      000010000000010008000000000000010000120B0000120B00006A0000006A00
      000000000000FFFFFF00FF00FF00EDF6FF00EAF3FC0066AAF70066A9F4006CB1
      FF007FBCFF008AC1FF008BC2FF008FC4FF0088B8EE009FCEFF00A3CFFF00ADD5
      FF00B7DAFF00EAF4FF00328EFF003590FF003791FF003D95FF004097FF00469A
      FF004598FB004596F600499DFF004A9DFF004592EE004592ED0050A0FF0056A4
      FF005AA6FF005CA7FF0060AAFF0065ACFF0067ADFF0069AFFF0066A3E90072B4
      FF0074B5FF007FBBFF0081BCFF000F75FF001070F2001378FF001479FF001579
      FF00197DFF001B7EFF001E80FF001F81FF002484FF002686FF002988FF002B89
      FF002880EE000167FF000268FF000369FF00056BFF00066CFF000669F600065A
      D100086EFF00096FFF000A70FF000C72FF000D73FF000064FF000063FB000062
      F8000060F600005FF300005EF000005DEE00005CEB00005BE900005AE6000059
      E3000058E1000057DE000056DC000055D9000054D7000053D4000052D1000051
      CF000050CC00004FCA00004EC700004DC500004CC200004BC0000044AF000041
      A5000040A300003A950000399200003587000033820000317E0000307B00002F
      790000296A000166FF0002020202020202020202020202020202020261626365
      67676767676767680202025D5053565A5D5D5D5D5D5D5B5F680202513A474A4C
      505454545454525B6702024B3D393E05010101263F58545D6602024A2B400A11
      19381D040C57545D6702024A352F011A46494B1C0155545D6702024A17330113
      1A01472C0651525C6602024A2136030E070101184A4D4E596402024A25122201
      010101010F494A546102024A2815341B1001010D2E69454F6002024A2A1E3735
      080116433D3B3A4B5E02024A0929231F1713352D413D3D455D02024A24090B2A
      272014324441423A580202023C3031302F443C69484A49510202020202020202
      02020202020202020202}
    ShowHint = True
    Transparent = True
    OnClick = imRotateClick
  end
  object imSettings: TImage
    Left = 153
    Top = 4
    Width = 16
    Height = 16
    Cursor = crHandPoint
    AutoSize = True
    ParentShowHint = False
    Picture.Data = {
      07544269746D6170B6020000424DB602000000000000B6010000280000001000
      000010000000010008000000000000010000120B0000120B0000600000006000
      000000000000FFFFFF00FF00FF00C1E0FF008AC1FF0088BDF8008EC4FF008FC4
      FF0088BAEF0093C7FF00C2E0FF00C1DEFE00C4E1FF00C1DEFC00C1DCF800C9E3
      FF00EEF6FF00328EFF003590FF003791FF003D95FF00469AFF0050A0FF0056A4
      FF005AA6FF005CA7FF0065ACFF0067ADFF0069AFFF0072B4FF0074B5FF007FBB
      FF0081BCFF000F75FF001176FF001277FF001377FF001378FF001579FF00187B
      FF00197DFF001B7EFF001E80FF001F81FF002484FF002686FF002988FF002B89
      FF000167FF000268FF000369FF00056BFF00066CFF000667F2000665EA00086E
      FF00096FFF000A70FF000C72FF000D73FF000064FF000062F8000060F600005F
      F300005EF000005DEE00005CEB00005BE900005AE6000059E3000058E1000057
      DE000056DC000055D9000054D7000053D4000052D1000051CF000050CC00004F
      CA00004EC700004DC500004CC200004BC0000044AF000041A5000040A300003A
      950000399200003587000033820000317E0000307B00002F790000296A000166
      FF000202020202020202020202020202020202025758595B5D5D5D5D5D5D5D5E
      0202025346494C5053535353535351555E020247313D4042464A4A4A4A4A4851
      5D0202413430304846154A4A4A4A4A535C0202402137302C460E10484D4A4A53
      5D0202402D262E0F3F11011B4B4D4A535D020240152B1301050C0112484B4852
      5C020240192E270F0101010B4348444F5A0202401C112F2F17150E010548404A
      570202401E1415152F2A2410012C3C455602024020160816142C242C17313141
      54020240041F1A1715122D253834343C530202401B0407201D18132A3B383931
      4E02020233282928263B335F3E403F4702020202020202020202020202020202
      0202}
    ShowHint = True
    Transparent = True
  end
  object imClose: TImage
    Left = 232
    Top = 4
    Width = 16
    Height = 16
    Cursor = crHandPoint
    AutoSize = True
    ParentShowHint = False
    Picture.Data = {
      07544269746D6170B6020000424DB602000000000000B6010000280000001000
      000010000000010008000000000000010000120B0000120B0000600000006000
      000000000000FFFFFF00FF00FF00C1E0FF008AC1FF0088BDF8008EC4FF008FC4
      FF0088BAEF0093C7FF00C2E0FF00C1DEFE00C4E1FF00C1DEFC00C1DCF800C9E3
      FF00EEF6FF00328EFF003590FF003791FF003D95FF00469AFF0050A0FF0056A4
      FF005AA6FF005CA7FF0065ACFF0067ADFF0069AFFF0072B4FF0074B5FF007FBB
      FF0081BCFF000F75FF001176FF001277FF001377FF001378FF001579FF00187B
      FF00197DFF001B7EFF001E80FF001F81FF002484FF002686FF002988FF002B89
      FF000167FF000268FF000369FF00056BFF00066CFF000667F2000665EA00086E
      FF00096FFF000A70FF000C72FF000D73FF000064FF000062F8000060F600005F
      F300005EF000005DEE00005CEB00005BE900005AE6000059E3000058E1000057
      DE000056DC000055D9000054D7000053D4000052D1000051CF000050CC00004F
      CA00004EC700004DC500004CC200004BC0000044AF000041A5000040A300003A
      950000399200003587000033820000317E0000307B00002F790000296A000166
      FF000202020202020202020202020202020202025758595B5D5D5D5D5D5D5D5E
      0202025346494C5053535353535351555E020247313D4042464A4A4A4A4A4851
      5D02024134303E4144484A4C4D4E4A535C020240213731010D364608014D4A53
      5D0202402D26370A010D05010E4B4A535D020240152B3B220A01010D36474852
      5C020240192E23390601010B3543444F5A0202401C112709010C0C01033F404A
      570202401E142C100F26240C015F3C455602024020162F2D2925233A34323141
      54020240041F1A1715122D253834343C530202401B0407201D18132A3B383931
      4E02020233282928263B335F3E403F4702020202020202020202020202020202
      0202}
    ShowHint = True
    Transparent = True
    OnClick = imCloseClick
  end
  object imSizeW: TImage
    Left = 177
    Top = 4
    Width = 16
    Height = 16
    Cursor = crHandPoint
    AutoSize = True
    ParentShowHint = False
    Picture.Data = {
      07544269746D617036030000424D360300000000000036000000280000001000
      000010000000010018000000000000030000120B0000120B0000000000000000
      0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF003A950039920035
      8700317E002F79002F79002F79002F79002F79002F79002F7900296AFF00FFFF
      00FFFF00FF004BC00058E10055D90052D1004EC7004BC0004BC0004BC0004BC0
      004BC0004BC0004DC50041A500296AFF00FFFF00FF0057DE0268FF0062F8005E
      F0005CEB0058E10054D70054D70054D70054D70054D70056DC004DC5002F79FF
      00FFFF00FF005DEE066CFF0167FF0060F6005DEE005AE60056DC0054D70052D1
      0051CF0050CC0054D7004BC000307BFF00FFFF00FF005EF00F75FF086EFF0268
      FF0667F20667F20665EA0058E10058E10051CF0051CF0054D7004BC0002F79FF
      00FFFF00FF005EF02686FF1579FF086EFF8AC1FF0667F20667F20667F20667F2
      8AC1FF0053D40054D7004BC0002F79FF00FFFF00FF005EF0469AFF1F81FFFFFF
      FF8AC1FF0A70FF0A70FF0A70FF0667F28AC1FFFFFFFF0056DC004CC200307BFF
      00FFFF00FF005EF05CA7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF004FCA003382FF00FFFF00FF005EF069AFFF328EFFFFFF
      FF8AC1FF187BFF187BFF0A70FF0667F28AC1FFFFFFFF005EF00054D7003A95FF
      00FFFF00FF005EF074B5FF3D95FF2484FF8AC1FF187BFF1579FF1377FF0C72FF
      8AC1FF0166FF0064FF0059E30040A3FF00FFFF00FF005EF081BCFF50A0FF2B89
      FF2686FF1B7EFF1378FF1277FF0C72FF066CFF0369FF0268FF005DEE0044AFFF
      00FFFF00FF005EF08AC1FF7FBBFF65ACFF56A4FF469AFF3590FF2686FF1378FF
      096FFF066CFF066CFF0064FF004BC0FF00FFFF00FF005EF067ADFF8AC1FF8FC4
      FF81BCFF72B4FF5AA6FF3791FF1E80FF0D73FF096FFF0A70FF0268FF0050CCFF
      00FFFF00FFFF00FF056BFF197DFF1B7EFF197DFF1579FF0D73FF056BFF0166FF
      0060F6005EF0005FF30057DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FF}
    ShowHint = True
    Transparent = True
    OnClick = imSizeWClick
  end
  object imSizeH: TImage
    Left = 129
    Top = 1
    Width = 16
    Height = 16
    Cursor = crHandPoint
    AutoSize = True
    ParentShowHint = False
    Picture.Data = {
      07544269746D617036030000424D360300000000000036000000280000001000
      000010000000010018000000000000030000120B0000120B0000000000000000
      0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF003A950039920035
      8700317E002F79002F79002F79002F79002F79002F79002F7900296AFF00FFFF
      00FFFF00FF004BC00058E10055D90052D1004EC7004BC0004BC0004BC0004BC0
      004BC0004BC0004DC50041A500296AFF00FFFF00FF0057DE0268FF0062F8005E
      F0005CEB0058E1FFFFFF0054D70054D70054D70054D70056DC004DC5002F79FF
      00FFFF00FF005DEE066CFF0167FF0060F6005DEEFFFFFFFFFFFFFFFFFF0052D1
      0051CF0050CC0054D7004BC000307BFF00FFFF00FF005EF00F75FF086EFF0268
      FF8AC1FF8AC1FFFFFFFF8AC1FF8AC1FF0051CF0051CF0054D7004BC0002F79FF
      00FFFF00FF005EF02686FF1579FF086EFF086EFF0667F2FFFFFF0667F20667F2
      0057DE0053D40054D7004BC0002F79FF00FFFF00FF005EF0469AFF1F81FF0D73
      FF1176FF0A70FFFFFFFF0A70FF0667F20057DE0057DE0056DC004CC200307BFF
      00FFFF00FF005EF05CA7FF2988FF1277FF0A70FF187BFFFFFFFF0A70FF0667F2
      0667F2005BE9005AE6004FCA003382FF00FFFF00FF005EF069AFFF328EFF187B
      FF187BFF187BFFFFFFFF0A70FF0667F2005FF3005FF3005EF00054D7003A95FF
      00FFFF00FF005EF074B5FF3D95FF2484FF8AC1FF8AC1FFFFFFFF8AC1FF8AC1FF
      0166FF0166FF0064FF0059E30040A3FF00FFFF00FF005EF081BCFF50A0FF2B89
      FF2686FFFFFFFFFFFFFFFFFFFF0C72FF066CFF0369FF0268FF005DEE0044AFFF
      00FFFF00FF005EF08AC1FF7FBBFF65ACFF56A4FF469AFFFFFFFF2686FF1378FF
      096FFF066CFF066CFF0064FF004BC0FF00FFFF00FF005EF067ADFF8AC1FF8FC4
      FF81BCFF72B4FF5AA6FF3791FF1E80FF0D73FF096FFF0A70FF0268FF0050CCFF
      00FFFF00FFFF00FF056BFF197DFF1B7EFF197DFF1579FF0D73FF056BFF0166FF
      0060F6005EF0005FF30057DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FF}
    ShowHint = True
    Transparent = True
    OnClick = imSizeHClick
  end
  object imShActive: TImage
    Left = 297
    Top = 1
    Width = 16
    Height = 16
    Cursor = crHandPoint
    AutoSize = True
    ParentShowHint = False
    Picture.Data = {
      07544269746D617036030000424D360300000000000036000000280000001000
      000010000000010018000000000000030000120B0000120B0000000000000000
      0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF003A950039920035
      8700317E002F79002F79002F79002F79002F79002F79002F7900296AFF00FFFF
      00FFFF00FF004BC00058E10055D90052D1004EC7004BC0004BC0004BC0004BC0
      004BC0004BC0004DC50041A500296AFF00FFFF00FF0057DE0268FF0062F8005E
      F0005CEB0058E1FFFFFF0054D70054D70054D70054D70056DC004DC5002F79FF
      00FFFF00FF005DEE066CFF0167FF0060F6005DEE005AE6FFFFFF0054D70052D1
      0051CF0050CC0054D7004BC000307BFF00FFFF00FF005EF00F75FF086EFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0051CF0054D7004BC0002F79FF
      00FFFF00FF005EF02686FF1579FF086EFFFFFFFF65ACFF65ACFFFFFFFFFFFFFF
      0053D40053D40054D7004BC0002F79FF00FFFF00FF005EF01F81FF1F81FF0D73
      FFFFFFFF65ACFF65ACFFFFFFFFFFFFFF0665EA0057DE0056DC004CC200307BFF
      00FFFF00FF005EF01F81FF2988FF1277FFFFFFFF65ACFF65ACFFFFFFFFFFFFFF
      0667F2005BE9005AE6004FCA003382FF00FFFF00FF005EF01F81FF3D95FF187B
      FFFFFFFF65ACFF65ACFFFFFFFFFFFFFF005FF3005FF3005EF00054D7003A95FF
      00FFFF00FF005EF074B5FF3D95FF2484FFFFFFFF65ACFF65ACFFFFFFFFFFFFFF
      1377FF0166FF0064FF0059E30040A3FF00FFFF00FF005EF081BCFF50A0FF2B89
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF066CFF0369FF0268FF005DEE0044AFFF
      00FFFF00FF005EF08AC1FF50A0FF2B89FF50A0FF469AFF3590FF2686FF1378FF
      096FFF066CFF066CFF0064FF004BC0FF00FFFF00FF005EF067ADFF8AC1FF8FC4
      FF81BCFF72B4FF5AA6FF3791FF1E80FF0D73FF096FFF0A70FF0268FF0050CCFF
      00FFFF00FFFF00FF056BFF197DFF1B7EFF197DFF1579FF0D73FF056BFF0166FF
      0060F6005EF0005FF30057DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FF}
    ShowHint = True
    Transparent = True
    OnClick = imShActiveClick
  end
  object imShNotActive: TImage
    Left = 337
    Top = 1
    Width = 16
    Height = 16
    Cursor = crHandPoint
    AutoSize = True
    ParentShowHint = False
    Picture.Data = {
      07544269746D617036030000424D360300000000000036000000280000001000
      000010000000010018000000000000030000120B0000120B0000000000000000
      0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF003A950039920035
      8700317E002F79002F79002F79002F79002F79002F79002F7900296AFF00FFFF
      00FFFF00FF004BC00058E10055D90052D1004EC7004BC0004BC0004BC0004BC0
      004BC0004BC0004DC50041A500296AFF00FFFF00FF0057DE0268FF0062F8005E
      F0005CEB0058E10054D70054D70054D70054D70054D70056DC004DC5002F79FF
      00FFFF00FF005DEE066CFF0167FF0060F6005DEE005AE60056DC0054D70052D1
      0051CF0050CC0054D7004BC000307BFF00FFFF00FF005EF00F75FF086EFF0268
      FF0268FFFFFFFF0665EA0058E10056DC0051CF0051CF0054D7004BC0002F79FF
      00FFFF00FF005EF02686FF1579FF086EFF086EFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF004BC0002F79FF00FFFF00FF005EF01F81FF1F81FF0D73
      FF086EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF004CC200307BFF
      00FFFF00FF005EF01F81FFFFFFFFFFFFFFFFFFFFFFFFFF65ACFF65ACFF65ACFF
      65ACFF65ACFFFFFFFF004FCA003382FF00FFFF00FF005EF01F81FF3D95FF187B
      FF187BFFFFFFFF65ACFF65ACFF65ACFF65ACFF65ACFFFFFFFF0054D7003A95FF
      00FFFF00FF005EF074B5FF3D95FF2484FF2686FFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF0059E30040A3FF00FFFF00FF005EF081BCFF50A0FF2B89
      FF2686FFFFFFFF1378FF1277FF0C72FF066CFF0369FF0268FF005DEE0044AFFF
      00FFFF00FF005EF08AC1FF7FBBFF65ACFF56A4FF469AFF3590FF2686FF1378FF
      096FFF066CFF066CFF0064FF004BC0FF00FFFF00FF005EF067ADFF8AC1FF8FC4
      FF81BCFF72B4FF5AA6FF3791FF1E80FF0D73FF096FFF0A70FF0268FF0050CCFF
      00FFFF00FFFF00FF056BFF197DFF1B7EFF197DFF1579FF0D73FF056BFF0166FF
      0060F6005EF0005FF30057DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FF}
    ShowHint = True
    Transparent = True
    OnClick = imShNotActiveClick
  end
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 364
    Height = 1
    Align = alTop
    BevelOuter = bvNone
    BiDiMode = bdLeftToRight
    Color = clInfoText
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentBiDiMode = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    OnMouseDown = pnTopMouseDown
    OnMouseMove = pnTopMouseMove
    OnMouseUp = pnTopMouseUp
  end
  object pnLeft: TPanel
    Left = 0
    Top = 1
    Width = 1
    Height = 21
    Align = alLeft
    BevelOuter = bvNone
    BiDiMode = bdLeftToRight
    Color = clInfoText
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentBiDiMode = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    OnMouseDown = pnLeftMouseDown
    OnMouseMove = pnLeftMouseMove
    OnMouseUp = pnLeftMouseUp
  end
  object pnRight: TPanel
    Left = 363
    Top = 1
    Width = 1
    Height = 21
    Align = alRight
    BevelOuter = bvNone
    BiDiMode = bdLeftToRight
    Color = clInfoText
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentBiDiMode = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 2
    OnMouseDown = pnRightMouseDown
    OnMouseMove = pnRightMouseMove
    OnMouseUp = pnRightMouseUp
  end
  object pnBottom: TPanel
    Left = 0
    Top = 22
    Width = 364
    Height = 1
    Align = alBottom
    BevelOuter = bvNone
    BiDiMode = bdLeftToRight
    Color = clInfoText
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentBiDiMode = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 3
    OnMouseDown = pnBottomMouseDown
    OnMouseMove = pnBottomMouseMove
    OnMouseUp = pnBottomMouseUp
  end
  object lbNum: TcxLabel
    Left = 8
    Top = 4
    Width = 12
    Height = 17
    Caption = '1'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = cl3DDkShadow
    Style.Font.Height = -11
    Style.Font.Name = 'MS Sans Serif'
    Style.Font.Style = [fsBold]
  end
  object FormStorage: TFormStorage
    Active = False
    StoredValues = <>
    Left = 32
  end
  object Localizer: TQFormLocalizer
    Dependencies.Strings = (
      'Caption=Action.Caption'
      'Hint=Action.Hint')
    Excluded.Strings = (
      'SDIActionList'
      'Localizer'
      'FormStorage'
      'fmLine'
      'imClose'
      'imRotate'
      'imSettings'
      'imShActive'
      'imShNotActive'
      'imSizeH'
      'imSizeW'
      'lbNum'
      'pnBottom'
      'pnLeft'
      'pnRight'
      'pnTop')
    PropNames.Strings = (
      'Caption'
      'Hint'
      'Text'
      'Lines'
      'Items'
      'Strings'
      'Title'
      'LeftCaption'
      'RightCaption'
      'ButtonCaptions'
      'Filter'
      'Tabs'
      'Properties'
      'Comments'
      'Description')
    SaveOptions = [soIgnoreDependencyIfEmpty, soIncludeFrames]
    Source = dmLang.LangSource
    OnLanguageChanged = LocalizerLanguageChanged
    Left = 70
    Top = 2
  end
end