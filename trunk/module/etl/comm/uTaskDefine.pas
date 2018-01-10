unit uTaskDefine;

interface

type
  TTaskRunStatus = (trsUnknown, trsRunning, trsStop, trsSuspend);

  TTaskCongfigRec = record
    FileName: string;
    TaskName: string;
    Description: string;
    Version: string;
    Auth: string;

    StepsStr: string;

    //������������jobmgr����ʱ����
    RunBasePath: string;
    DBsConfigFile: string;
  end;


implementation

end.