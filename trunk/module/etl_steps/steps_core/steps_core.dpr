library steps_core;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.Forms,
  System.Contnrs,
  ModuleMgrClass in '..\..\..\common\ModuleMgrClass.pas',
  PublicInfoClass in '..\..\..\common\PublicInfoClass.pas',
  uBasicForm in '..\..\..\core\basic\uBasicForm.pas' {BasicForm},
  uBasicDlgForm in '..\..\..\core\basic\uBasicDlgForm.pas' {BasicDlgForm},
  uFunctions in '..\..\..\common\uFunctions.pas',
  uStepBasic in '..\..\..\etl\basic\uStepBasic.pas',
  uStepBasicForm in '..\..\..\etl\basic\uStepBasicForm.pas' {StepBasicForm},
  uTask in '..\..\..\etl\comm\uTask.pas',
  uTaskDefine in '..\..\..\etl\comm\uTaskDefine.pas',
  uTaskResult in '..\..\..\etl\comm\uTaskResult.pas',
  uTaskVar in '..\..\..\etl\comm\uTaskVar.pas',
  uStepDefines in '..\..\..\etl\steps\uStepDefines.pas',
  uStepFactory in '..\..\..\etl\steps\uStepFactory.pas',
  uStepFormFactory in '..\..\..\etl\steps\uStepFormFactory.pas',
  uStepFormSettings in '..\..\..\etl\steps\uStepFormSettings.pas',
  uDbConMgr in '..\..\..\etl\comm\uDbConMgr.pas',
  uFileLogger in '..\..\..\core\lib\uFileLogger.pas',
  uThreadQueueUtil in '..\..\..\core\lib\uThreadQueueUtil.pas',
  uDefines in '..\..\..\etl\comm\uDefines.pas',
  uThreadSafeFile in '..\..\..\etl\comm\uThreadSafeFile.pas',
  uFileUtil in '..\..\..\core\lib\uFileUtil.pas',
  uNetUtil in '..\..\..\core\lib\uNetUtil.pas',
  uGlobalVar in '..\..\..\etl\comm\uGlobalVar.pas',
  uExceptions in '..\..\..\etl\comm\uExceptions.pas',
  uStepCondition in 'steps\common\uStepCondition.pas',
  uStepConditionForm in 'steps\common\uStepConditionForm.pas' {StepConditionForm},
  uStepNullForm in 'steps\common\uStepNullForm.pas' {StepNullForm},
  uStepSubTask in 'steps\common\uStepSubTask.pas',
  uStepSubTaskForm in 'steps\common\uStepSubTaskForm.pas' {StepSubTaskForm},
  uStepTaskResult in 'steps\common\uStepTaskResult.pas',
  uStepTaskResultForm in 'steps\common\uStepTaskResultForm.pas' {StepTaskResultForm},
  uStepVarDefine in 'steps\common\uStepVarDefine.pas',
  uStepVarDefineForm in 'steps\common\uStepVarDefineForm.pas' {StepVarDefineForm},
  uStepExceptionCatch in 'steps\control\uStepExceptionCatch.pas',
  uStepExceptionCatchForm in 'steps\control\uStepExceptionCatchForm.pas' {StepExceptionCatchForm},
  uStepDatasetSpliter in 'steps\data\uStepDatasetSpliter.pas',
  uStepDatasetSpliterForm in 'steps\data\uStepDatasetSpliterForm.pas' {StepDatasetSpliterForm},
  uStepFieldsMap in 'steps\data\uStepFieldsMap.pas',
  uStepFieldsMapForm in 'steps\data\uStepFieldsMapForm.pas' {StepFieldsMapForm},
  uStepFieldsOper in 'steps\data\uStepFieldsOper.pas',
  uStepFieldsOperForm in 'steps\data\uStepFieldsOperForm.pas' {StepFieldsOperForm},
  uStepJson2DataSet in 'steps\data\uStepJson2DataSet.pas',
  uStepJson2DataSetForm in 'steps\data\uStepJson2DataSetForm.pas' {StepJsonDataSetForm},
  uDBQueryResultForm in 'steps\database\uDBQueryResultForm.pas' {DBQueryResultForm},
  uStepJson2Table in 'steps\database\uStepJson2Table.pas',
  uStepJson2TableForm in 'steps\database\uStepJson2TableForm.pas' {StepJson2TableForm},
  uStepQuery in 'steps\database\uStepQuery.pas',
  uStepQueryForm in 'steps\database\uStepQueryForm.pas' {StepQueryForm},
  uStepSQL in 'steps\database\uStepSQL.pas',
  uStepSQLForm in 'steps\database\uStepSQLForm.pas' {StepSQLForm},
  uStepFileDelete in 'steps\file\uStepFileDelete.pas',
  uStepFileDeleteForm in 'steps\file\uStepFileDeleteForm.pas' {StepFileDeleteForm},
  uStepFolderCtrl in 'steps\file\uStepFolderCtrl.pas',
  uStepFolderCtrlForm in 'steps\file\uStepFolderCtrlForm.pas' {StepFolderCtrlForm},
  uStepIniRead in 'steps\file\uStepIniRead.pas',
  uStepIniReadForm in 'steps\file\uStepIniReadForm.pas' {StepIniReadForm},
  uStepIniWrite in 'steps\file\uStepIniWrite.pas',
  uStepIniWriteForm in 'steps\file\uStepIniWriteForm.pas' {StepIniWriteForm},
  uStepTxtFileReader in 'steps\file\uStepTxtFileReader.pas',
  uStepTxtFileReaderForm in 'steps\file\uStepTxtFileReaderForm.pas' {StepTxtFileReaderForm},
  uStepTxtFileWriter in 'steps\file\uStepTxtFileWriter.pas',
  uStepTxtFileWriterForm in 'steps\file\uStepTxtFileWriterForm.pas' {StepTxtFileWriterForm},
  uStepUnzip in 'steps\file\uStepUnzip.pas',
  uStepUnzipForm in 'steps\file\uStepUnzipForm.pas' {StepUnzipForm},
  uStepDownloadFile in 'steps\network\uStepDownloadFile.pas',
  uStepDownloadFileForm in 'steps\network\uStepDownloadFileForm.pas' {StepDownloadFileForm},
  uStepHttpRequest in 'steps\network\uStepHttpRequest.pas',
  uStepHttpRequestForm in 'steps\network\uStepHttpRequestForm.pas' {StepHttpRequestForm},
  uStepFastReport in 'steps\report\uStepFastReport.pas',
  uStepFastReportForm in 'steps\report\uStepFastReportForm.pas' {StepFastReportForm},
  uStepReportMachine in 'steps\report\uStepReportMachine.pas',
  uStepReportMachineForm in 'steps\report\uStepReportMachineForm.pas' {StepReportMachineForm},
  CVRDLL in 'steps\tools\CVRDLL.pas',
  uStepIdCardHS100UC in 'steps\tools\uStepIdCardHS100UC.pas',
  uStepIdCardHS100UCForm in 'steps\tools\uStepIdCardHS100UCForm.pas' {StepIdCardHS100UCForm},
  uStepExeCtrl in 'steps\util\uStepExeCtrl.pas',
  uStepExeCtrlForm in 'steps\util\uStepExeCtrlForm.pas' {StepExeCtrlForm},
  uStepServiceCtrl in 'steps\util\uStepServiceCtrl.pas',
  uStepServiceCtrlForm in 'steps\util\uStepServiceCtrlForm.pas' {StepServiceCtrlForm},
  uStepWaitTime in 'steps\util\uStepWaitTime.pas',
  uStepWaitTimeForm in 'steps\util\uStepWaitTimeForm.pas' {StepWaitTimeForm},
  uFileFinder in '..\..\..\core\lib\uFileFinder.pas',
  uServiceUtil in '..\..\..\core\lib\uServiceUtil.pas',
  uDesignTimeDefines in '..\..\..\etl\comm\uDesignTimeDefines.pas',
  uProject in '..\..\..\etl\comm\uProject.pas',
  uDatabaseConnectTestForm in '..\..\..\etl\forms\uDatabaseConnectTestForm.pas' {DatabaseConnectTestForm},
  uDatabasesForm in '..\..\..\etl\forms\uDatabasesForm.pas' {DatabasesForm},
  uTaskEditForm in '..\..\..\etl\forms\uTaskEditForm.pas' {TaskEditForm},
  uBasicLogForm in '..\..\..\core\basic\uBasicLogForm.pas' {BasicLogForm},
  uStepTypeSelectForm in '..\..\..\etl\forms\uStepTypeSelectForm.pas' {StepTypeSelectForm},
  uTaskStepSourceForm in '..\..\..\etl\forms\uTaskStepSourceForm.pas' {TaskStepSourceForm},
  uSelectFolderForm in '..\..\..\common\uSelectFolderForm.pas' {SelectFolderForm};

{$R *.res}

var
  OldApplication: TApplication;
  OldMainForm: TForm;
  OldScreen: TScreen;


//需要能够打开form
function ModuleStepDesignForm(DllRunInfo: TRunInfo; DllModuleStepRec: TPCharModuleStepRec): TForm; stdcall;
begin
  if RunInfo = nil then
  begin
    RunInfo := DllRunInfo;
    OldMainForm := Application.MainForm;
    Application := TApplication(RunInfo.Application);
    OldScreen := Screen;
    Screen := TScreen(RunInfo.MainScreen);
  end;
  Result := nil;
end;



//需要能够运行steps，但是具体的steps也有可能是最终呈现一个form，比如报表类，当然，报表类也可以通过文件的方式进行处理
//需要能够打开form
function ModuleStep(DllRunInfo: TRunInfo; DllModuleStepRec: TPCharModuleStepRec): TForm; stdcall;
begin
  if RunInfo = nil then
  begin
    RunInfo := DllRunInfo;
    OldMainForm := Application.MainForm;
    Application := TApplication(RunInfo.Application);
    OldScreen := Screen;
    Screen := TScreen(RunInfo.MainScreen);
  end;

  //接下来，可以根据传入的module的那个step来进行具体的运行

  Result := nil;
end;

procedure ModulesRegister(DllModuleList: TObjectList); stdcall;
var
  DllModule: TPCharModuleInfo;
begin
  if (DllModuleList <> nil) then
  begin
    //common
    DllModule:=TPCharModuleInfo.Create('common', '通用', '');
    DllModule.Add('null', 'Null空组件', '');
    DllModule.Add('var_define', '变量定义', '');
    DllModule.Add('condition', '条件判断', '');
    DllModule.Add('sub_task', '子任务', '');
    DllModule.Add('task_result', '任务结果', '');
    DllModuleList.Add(DllModule);

    //control
    DllModule:=TPCharModuleInfo.Create('control', '控制组件', '');
    DllModule.Add('exception', '异常捕捉', '');
    DllModuleList.Add(DllModule);

    //data
    DllModule:=TPCharModuleInfo.Create('data', '数据组件', '');
    DllModule.Add('dataset_spliter', '数据集切割', '');
    DllModule.Add('fields_map', '字段映射', '');
    DllModule.Add('fields_oper', '字段操作', '');
    DllModule.Add('json_2_dataset', 'Json转Dataset', '');
    DllModuleList.Add(DllModule);

    //database
    DllModule:=TPCharModuleInfo.Create('database', '数据库组件', '');
    DllModule.Add('json_2_table', 'Json转Table', '');
    DllModule.Add('query', 'Query数据库查询', '');
    DllModule.Add('sql_execute', 'SQL执行', '');
    DllModuleList.Add(DllModule);

    //file
    DllModule:=TPCharModuleInfo.Create('file', '文件操作组件', '');
    DllModule.Add('file_delete', '文件删除', '');
    DllModule.Add('folder_ctrl', '文件夹控制', '');
    DllModule.Add('ini_read', 'Ini文件读取', '');
    DllModule.Add('ini_write', 'Ini文件保存', '');
    DllModule.Add('txt_read', 'Text文件读取', '');
    DllModule.Add('txt_write', 'Text文件保存', '');
    DllModule.Add('unzip', 'Zip文件解压', '');
    DllModuleList.Add(DllModule);

    //network
    DllModule:=TPCharModuleInfo.Create('network', '网络操作组件', '');
    DllModule.Add('download_file', '下载文件', '');
    DllModule.Add('http_request', 'Http请求', '');
    DllModuleList.Add(DllModule);

    //report
    DllModule:=TPCharModuleInfo.Create('report', '报表组件', '');
    DllModule.Add('fast_report', 'FastReport组件', '');
    DllModule.Add('report_machine', 'RM组件', '');
    DllModuleList.Add(DllModule);

    //tools


    //util
    DllModule:=TPCharModuleInfo.Create('util', '实用组件', '');
    DllModule.Add('exe_ctrl', 'Exe可执行文件控制组件', '');
    DllModule.Add('service_ctrl', '系统服务控制组件', '');
    DllModule.Add('wait_time', 'TimeWait组件', '');
    DllModuleList.Add(DllModule);

  end;
end;

procedure NewDllProc(dwReason: DWORD);
begin
  if dwReason = DLL_PROCESS_ATTACH then
    OldApplication := application
  else if dwReason = DLL_PROCESS_DETACH then
  begin
    Application := OldApplication;
    if OldScreen <> nil then
      Screen := OldScreen;
  end;
end;

exports
  ModuleStepDesignForm,
  ModuleStep,
  ModulesRegister;

begin
  DllProc := @NewDllProc;
  DllProc(DLL_PROCESS_ATTACH);
end.

