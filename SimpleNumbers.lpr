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

  { TNumbersThread }

  TNumbersThread = class(TThread)
  private
    FMaxNumber: Integer;
    FFileName: string;
  public
    constructor Create(AMaxNumber: Integer; AFileName: string);
    procedure Execute; override;
    function IsSimpleNumber(ANumber: Integer; ASimpleNumbers: TIntList): Boolean;
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
  MySimpleDict: TIntList;
  FirstNum: Boolean;
begin
  MySimpleDict := TIntList.Create;
  AssignFile(f, FFileName);
  Try
    Rewrite(f);
    FirstNum := True;
    for i := 1 to FMaxNumber - 1 do
    begin
      if IsSimpleNumber(i, MySimpleDict) then
      begin
        MySimpleDict.Add(i);
        if LogNumber(i) then
        begin
          Write(f, IfThen(FirstNum, '', ' ') + IntToStr(I));
          FirstNum := False;
        end;
      end;
  end;
  finally
    Close(f);
    MySimpleDict.Free;
  end;
end;

function TNumbersThread.IsSimpleNumber(ANumber: Integer; ASimpleNumbers: TIntList): Boolean;
var
  i: Integer;
begin
  for i := 1 to ASimpleNumbers.Count - 1 do
  if not (ASimpleNumbers[i] in [0, 1]) then
    if (ANumber mod ASimpleNumbers[i]) = 0 then
      Exit(False);
  Result := True;
end;

var
  LastNumber: Integer;
  CS: TCriticalSection;
  CommonFile: TEXT;

function LogNumber(ANumber: Integer): Boolean;
begin
  Result := LastNumber < ANumber;
  CS.Enter;
  try
    Result := LastNumber < ANumber;
    if Result then
    begin
      Write(CommonFile, IfThen(LastNumber > 0, ' ', '') + IntToStr(ANumber));
      LastNumber := ANumber;
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
  finally
    Th1.Free;
    Th2.Free;
    Close(CommonFile);
    CS.Free;
    writeln('waiting is ', MilliSecondsBetween(Now, dtStart), 'ms');
    writeln('Press Return to exit');
    Readln;
  end;
end.

