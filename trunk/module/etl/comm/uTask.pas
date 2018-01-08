unit uTask;

interface

uses
  uTaskVar, System.JSON, uStepBasic, uStepDefines, System.SysUtils, System.Classes;

type
  TTaskUtil = class
  public
    class function ReadConfigFrom(ATaskFile: string): TTaskCongfigRec;
    class procedure WriteConfigTo(ATaskConfigRec: TTaskCongfigRec; ATaskFile: string);
  end;


  TTask = class
  private
  public
    TaskVar: TTaskVar;
    TaskConfigRec: TTaskCongfigRec;

    constructor Create(ATaskCongfigRec: TTaskCongfigRec);
    destructor Destroy; override;

    //����
    procedure Start;

  end;

implementation

uses uExceptions, uFunctions, uStepFactory, uDefines, uThreadSafeFile;

const
  VER: string = '1.0.0';

{ TStepUtil }


class function TTaskUtil.ReadConfigFrom(ATaskFile: string): TTaskCongfigRec;
var
  LFileText: string;
  LTaskConfigJson: TJSONObject;
begin
  if not FileExists(ATaskFile) then Exit;

  LFileText := TThreadSafeFile.ReadContentFrom(ATaskFile);
  Result.FileName := ATaskFile;
  Result.TaskName := ChangeFileExt(ExtractFileName(ATaskFile), '');
  Result.Version := VER;

  LTaskConfigJson := TJSONObject.ParseJSONValue(LFileText) as TJSONObject;
  if LTaskConfigJson = nil then Exit;

  try
    Result.Auth := GetJsonObjectValue(LTaskConfigJson, 'auth', 'Dony.ZHANG');
    Result.StepsStr := GetJsonObjectValue(LTaskConfigJson, 'steps');
  finally
    LTaskConfigJson.Free;
  end;
end;


class procedure TTaskUtil.WriteConfigTo(ATaskConfigRec: TTaskCongfigRec;
  ATaskFile: string);
var
  LTaskConfigJson: TJSONObject;
begin
  LTaskConfigJson := TJSONObject.Create;
  try
    LTaskConfigJson.AddPair(TJSONPair.Create('task_name', ATaskConfigRec.TaskName));
    LTaskConfigJson.AddPair(TJSONPair.Create('version', VER));
    LTaskConfigJson.AddPair(TJSONPair.Create('auth', 'Dony.ZHANG'));
    LTaskConfigJson.AddPair(TJSONPair.Create('steps', ATaskConfigRec.StepsStr));

    TThreadSafeFile.WriteContentTo(ATaskFile, LTaskConfigJson.ToJSON);
  finally
    LTaskConfigJson.Free;
  end;
end;


{ TTask }

constructor TTask.Create(ATaskCongfigRec: TTaskCongfigRec);
var
  LTaskVarRec: TTaskVarRec;
begin
  inherited Create;
  TaskConfigRec := ATaskCongfigRec;
  LTaskVarRec.FileName := TaskConfigRec.FileName;
  LTaskVarRec.DbsFileName := TaskConfigRec.DBsConfigFile;
  LTaskVarRec.TaskName := TaskConfigRec.TaskName;
  LTaskVarRec.RunBasePath := TaskConfigRec.RunBasePath;
  TaskVar := TTaskVar.Create(self, LTaskVarRec);
end;

destructor TTask.Destroy;
begin
  TaskVar.Free;
  inherited;
end;


procedure TTask.Start;
var
  LTaskConfigJson: TJSONObject;
  LInitInData: TStepData;
begin
  LTaskConfigJson := TJSONObject.ParseJSONValue(TaskConfigRec.StepsStr) as TJSONObject;
  if LTaskConfigJson = nil then
    raise TaskConfigException.Create('task�����ļ������쳣');

  try
    TaskVar.TaskVarRec.TaskName := TaskConfigRec.TaskName;
    TaskVar.TaskVarRec.RunBasePath := TaskConfigRec.RunBasePath;
    TaskVar.TaskStatus := trsRunning;
    try
      StartStep(LTaskConfigJson, @LInitInData, TaskVar);
    except
      on E: StepException do
      begin
        TaskVar.Logger.Error('Task.Start������StepException�쳣');
      end;
      on E: StopTaskException do
      begin
        TaskVar.Logger.Error('����ִ����ֹ');
      end;
    end;
  finally
    LTaskConfigJson.Free;
    TaskVar.TaskStatus := trsStop;
  end;
end;


end.