program SimpleNumbers;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this }
  , Windows, SysUtils, DateUtils
  ;

type

  { TNumbersThread }

  TNumbersThread = class(TThread)
  private
    FMaxNumber: Integer;
    FFileName: string;
  public
    constructor Create(AMaxNumber: Integer; AFileName: string);
    procedure Execute; override;
  end;

{ TNumbersThread }

constructor TNumbersThread.Create(AMaxNumber: Integer; AFileName: string);
begin
  FMaxNumber := AMaxNumber;
  FFileName := AFileName;
  inherited Create(True);
end;

procedure TNumbersThread.Execute;
begin
  Sleep(5000);
end;

procedure LogNumber(ANumber: Integer);
begin


end;

var
  Th1, Th2: TNumbersThread;
  waitArr: array [1..2] of HANDLE;
  res: cardinal;
  dtStart: TDateTime;
begin
  Th1 := TNumbersThread.Create(1000000, 'Thread1.txt');
  Th2 := TNumbersThread.Create(1000000, 'Thread2.txt');
  waitArr[1] := Th1.Handle;
  waitArr[2] := Th2.Handle;
  dtStart := Now;
  Th1.Resume;
  Th2.Resume;
  res := WaitForMultipleObjects(2, @waitArr, True, INFINITE);
  writeln('res = ', res);
  writeln('waiting is ', MilliSecondsBetween(Now, dtStart));
  Readln;
  //case res of
  //     0 :
  //end;
  Th1.Free;
  Th2.Free;
end.

