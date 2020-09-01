unit uPrevInstance;

 interface

 uses
 StrUtils,
 Forms,
 WinProcs,
 WinTypes,
 SysUtils;

 const cIndApplicationName = 'Ruler';

 {ѕроверка на запуск второго экземпл€ра приложени€}

 //—пособ проверки с помощью Mutex (не активизирует первый экземпл€р)
 const cIndMutex = '299FB9FC-4C8D-4694-849F-8382F3F8DFCF' + cIndApplicationName; //”никальна€ строка Mutex дл€ идентификации, запущен ли экземпл€р этого приложени€
 function IsActiveMutex:boolean;

 //—пособ проверки с помощью файлов в пам€ти (им€ файла = полный путь до файла приложени€ RunMode = 0) или cIndMutex RunMode = 1
 function FirstHinstanceRunning(RunMode: Integer = 0): boolean;


 implementation


 function IsActiveMutex:boolean;
 var hMutex : THandle;
 begin
   Result := False;
   hMutex := CreateMutex(0, true , cIndMutex);
   if GetLastError = ERROR_ALREADY_EXISTS then
   begin
    CloseHandle(hMutex);
    Result := True;
   end;
 end;


 function FirstHinstanceRunning(RunMode: Integer = 0): boolean;
 const
 MemFileSize = 127;

 var
 MemHnd: HWND;
 MemFileName: string;
 lpBaseAddress: ^HWND;
 FirstAppHandle: HWND;

 begin
 Result := False;
 MemFileName := Application.ExeName;
 case RunMode of
  0:
  MemFileName := AnsiReplaceText(MemFileName, '\', '/') + '299FB9FC-4C8D-4694-849F-8382F3F8DFCF' + cIndApplicationName;
  1:
  MemFileName := cIndMutex; //ExtractFileName(MemFileName) + '299FB9FC-4C8D-4694-849F-8382F3F8DFCF' + cRvApplicationName;
 else
  Exit;
 end;
 //если FileMapping есть - то происходит OpenFileMapping
 MemHnd := CreateFileMapping(HWND($FFFFFFFF), nil,
  PAGE_READWRITE, 0, MemFileSize, PChar(MemFileName)); 
 if GetLastError <> ERROR_ALREADY_EXISTS then 
 begin 
  if MemHnd <> 0 then 
  begin 
  lpBaseAddress := MapViewOfFile(MemHnd, FILE_MAP_WRITE, 0, 0, 0); 
  if lpBaseAddress <> nil then 
  lpBaseAddress^ := Application.Handle; 
  end; 
 end 
 else 
 begin 
  // MemFileHnd := OpenFileMapping(FILE_MAP_READ, False, PChar(MemFileName)); 
  Result := True; 
  if MemHnd <> 0 then 
  begin
  lpBaseAddress := MapViewOfFile(MemHnd, FILE_MAP_READ, 0, 0, 0);
  if lpBaseAddress <> nil then
  begin
  FirstAppHandle := lpBaseAddress^;
  ShowWindow(FirstAppHandle, SW_restore);
  SetForegroundWindow(FirstAppHandle);
  end;
  end;
 end;
 if lpBaseAddress <> nil then
  UnMapViewOfFile(lpBaseAddress);
 end;

 end.
