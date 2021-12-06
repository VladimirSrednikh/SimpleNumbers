program SimpleNumbers;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this }
  , Windows, SysUtils, StrUtils, fgl, SyncObjs,
  DateUtils
  ;

function LogNumber(ANumber: Integer): Boolean; forward;

type
  TIntList = specialize TFPGList<Integer>;
  TIntDictionary = specialize TFPGMap<Integer, Integer>;


  { TNumbersThread }

  TNumbersThread = class(TThread)
  private
    FMaxNumber: Integer;
    FFileName: string;
  public
    constructor Create(AMaxNumber: Integer; AFileName: string);
    procedure Execute; override;
    function IsSimpleNumber(ANumber: Integer; ASimpleNumbers: TIntDictionary): Boolean;
  end;

{ TNumbersThread }

constructor TNumbersThread.Create(AMaxNumber: Integer; AFileName: string);
begin
  FMaxNumber := AMaxNumber;
  FFileName := AFileName;
  inherited Create(True);
end;

procedure TNumbersThread.Execute;
var
  i: Integer;
  f: Text;
  MySimpleDict: TIntDictionary;
begin
  MySimpleDict := TIntDictionary.Create;
  AssignFile(f, FFileName);
  Try
    Rewrite(f);
  for i := 0 to FMaxNumber - 1 do
    if IsSimpleNumber(i, MySimpleDict) then
    begin
      if LogNumber(i) then
        Write(f, IntToStr(i) + ' ');
    end;
  finally
    Close(f);
    MySimpleDict.Free;
  end;
end;

function TNumbersThread.IsSimpleNumber(ANumber: Integer;
  ASimpleNumbers: TIntDictionary): Boolean;
var
  i: Integer;
begin
  //for i := 0 to ASimpleNumbers.KeySize - 1 do
  //ASimpleNumbers.Keys[i];
  Result := True;
end;

var
  //IntList: TIntList;
  LastNumber: Integer;
  CS: TCriticalSection;
  CommonFile: TEXT;

function LogNumber(ANumber: Integer): Boolean;
begin
  CS.Enter;
  try
    Result := LastNumber < ANumber;
    //Result := IntList.IndexOf(ANumber) = -1;
    if Result then
    begin
      Write(CommonFile, IfThen(LastNumber > 0, ' ', '') + IntToStr(ANumber));
      LastNumber := ANumber;
      //IntList.Add(ANumber);
    end;
  finally
    CS.Leave;
  end;
end;

var
  Th1, Th2: TNumbersThread;
  waitArr: array [1..2] of HANDLE;
  res: Cardinal;
  dtStart: TDateTime;
begin
  CS := TCriticalSection.Create;
  //IntList := TIntList.Create;
  LastNumber := 0;
  AssignFile(CommonFile, 'Result.txt');
  Rewrite(CommonFile);
  Th1 := TNumbersThread.Create(1000000, 'Thread1.txt');
  Th2 := TNumbersThread.Create(1000000, 'Thread2.txt');
  try
    waitArr[1] := Th1.Handle;
    waitArr[2] := Th2.Handle;
    dtStart := Now;
    Th1.Resume;
    Th2.Resume;
    res := WaitForMultipleObjects(2, @waitArr, True, INFINITE);
    writeln('res = ', res);
    writeln('waiting is ', MilliSecondsBetween(Now, dtStart));
    writeln('Press Return to exit');
    Readln;
  finally
    Th1.Free;
    Th2.Free;
    Close(CommonFile);
    //IntList.Free;
    CS.Free;
  end;
end.

