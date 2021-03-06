program CgtEtlDesigner;

uses
  ShareMem,
  Vcl.Forms,
  MidasLib,
  System.SysUtils,
  Vcl.Controls,
  System.SyncObjs,
  uBasicForm in '..\..\core\basic\uBasicForm.pas' {BasicForm},
  uBasicDlgForm in '..\..\core\basic\uBasicDlgForm.pas' {BasicDlgForm},
  uFunctions in '..\..\common\uFunctions.pas',
  uAlertSound in '..\..\core\lib\uAlertSound.pas',
  uFileLogger in '..\..\core\lib\uFileLogger.pas',
  uThreadQueueUtil in '..\..\core\lib\uThreadQueueUtil.pas',
  uJob in 'comm\uJob.pas',
  uJobsMgrForm in 'forms\uJobsMgrForm.pas' {JobsForm},
  uSettingForm in 'forms\uSettingForm.pas' {SettingsForm},
  uFileUtil in '..\..\core\lib\uFileUtil.pas',
  uProjectForm in 'forms\uProjectForm.pas' {ProjectForm},
  uNetUtil in '..\..\core\lib\uNetUtil.pas',
  uServiceUtil in '..\..\core\lib\uServiceUtil.pas',
  uJobScheduleForm in 'forms\uJobScheduleForm.pas' {JobScheduleForm},
  uEnterForm in 'forms\uEnterForm.pas' {EnterForm},
  uServiceControlForm in 'ctrl_forms\uServiceControlForm.pas' {ServiceControlForm},
  uMakeDirForm in 'forms\uMakeDirForm.pas' {MakeDirForm},
  uFileFinder in '..\..\core\lib\uFileFinder.pas',
  uFileCleaner in '..\..\core\lib\uFileCleaner.pas',
  uScheduleConfig in 'runners\uScheduleConfig.pas',
  uScheduleRunner in 'runners\uScheduleRunner.pas',
  uGlobalVarSettingForm in 'forms\uGlobalVarSettingForm.pas' {GlobalVarSettingForm},
  uBasicLogForm in '..\..\core\basic\uBasicLogForm.pas' {BasicLogForm},
  uHttpServerControlForm in 'ctrl_forms\uHttpServerControlForm.pas' {HttpServerControlForm},
  uHttpServerRunner in 'runners\uHttpServerRunner.pas',
  uHttpServerConfig in 'runners\uHttpServerConfig.pas',
  uSelectFolderForm in '..\..\common\uSelectFolderForm.pas' {SelectFolderForm},
  uJobDispatcher in 'comm\uJobDispatcher.pas',
  uUserNotify in '..\..\common\uUserNotify.pas',
  uUserNotifyMsgForm in '..\..\common\uUserNotifyMsgForm.pas' {UserNotifyMsgForm},
  uJobStarter in 'comm\uJobStarter.pas',
  uPackageHelperForm in 'forms\uPackageHelperForm.pas' {PackageHelperForm},
  uStepDefines in '..\..\etl\steps\uStepDefines.pas',
  uTask in '..\..\etl\comm\uTask.pas',
  uTaskDefine in '..\..\etl\comm\uTaskDefine.pas',
  uTaskResult in '..\..\etl\comm\uTaskResult.pas',
  uTaskVar in '..\..\etl\comm\uTaskVar.pas',
  uDbConMgr in '..\..\etl\comm\uDbConMgr.pas',
  uDefines in '..\..\etl\comm\uDefines.pas',
  uDesignTimeDefines in '..\..\etl\comm\uDesignTimeDefines.pas',
  uGlobalVar in '..\..\etl\comm\uGlobalVar.pas',
  uProject in '..\..\etl\comm\uProject.pas',
  uThreadSafeFile in '..\..\etl\comm\uThreadSafeFile.pas',
  uExceptions in '..\..\etl\comm\uExceptions.pas',
  uDatabaseConnectTestForm in '..\..\etl\forms\uDatabaseConnectTestForm.pas' {DatabaseConnectTestForm},
  uDatabasesForm in '..\..\etl\forms\uDatabasesForm.pas' {DatabasesForm},
  uStepTypeSelectForm in '..\..\etl\forms\uStepTypeSelectForm.pas' {StepTypeSelectForm},
  uTaskEditForm in '..\..\etl\forms\uTaskEditForm.pas' {TaskEditForm},
  uTaskStepSourceForm in '..\..\etl\forms\uTaskStepSourceForm.pas' {TaskStepSourceForm},
  uRunInfo in '..\..\common\uRunInfo.pas',
  uStepMgrClass in '..\..\common\uStepMgrClass.pas',
  uAppDefines in 'comm\uAppDefines.pas',
  uStepBasic in '..\..\etl\basic\uStepBasic.pas',
  uStepBasicForm in '..\..\etl\basic\uStepBasicForm.pas' {StepBasicForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  ExePath := ExtractFilePath(Application.ExeName);
  AppLogger := TThreadFileLog.Create(1,  ExePath + 'log\app\', 'yyyymmdd\hh');
  FileCritical := TCriticalSection.Create;
  StepMgr := TStepMgr.Create;


  if (FormatDateTime('yyyymmdd', Now) < '20191231') then
  begin
    Application.CreateForm(TProjectForm, ProjectForm);
    ProjectForm.WindowState := wsMaximized;
  end;
  //创建RunInfo
  RunInfo := TRunInfo.Create(Integer(Application),Integer(Screen),
                   Integer(ProjectForm), ProjectForm.Handle);
  RunInfo.SetCurrentProject(Integer(CurrentProject));
  Application.Run;

  //全局单实例判断释放
  if HttpServerRunner <> nil then
  begin
    FreeAndNil(HttpServerRunner);
  end;


  StepMgr.Free;
  FileCritical.Free;
  AppLogger.Free;
  RunInfo.Free;
end.
