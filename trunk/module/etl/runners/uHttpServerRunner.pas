unit uHttpServerRunner;

interface

uses IdContext, IdCustomHTTPServer, IdHTTPServer, System.JSON, uHttpServerConfig;

type

  TOutResult = record
    Code: Integer;
    Msg: string;
    Data: string;
  end;


  THttpServerRunner = class
  private
    FServer: TIdHttpServer;
    FServerConfigRec: THttpServerConfigRec;

    procedure OnServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure OnServerCommandOther(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleCommandRequest(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleCommandEnter(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function GetRequestParams(ARequestInfo: TIdHTTPRequestInfo): string;
    procedure OutputResult(ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo; AOutResult: TOutResult);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start(AServerConfigRec: THttpServerConfigRec);

    property Server: TIdHttpServer read FServer;
  end;

implementation

uses uDefines, System.SysUtils, uFileUtil, uJobDispatcher, System.Classes;

type
  DisParamException = class(Exception);

{ THttpServerRunner }

constructor THttpServerRunner.Create;
begin
  inherited;
  FServer := TIdHTTPServer.Create(nil);
  FServer.OnCommandGet := OnServerCommandGet;
  FServer.OnCommandOther := OnServerCommandOther;
end;



destructor THttpServerRunner.Destroy;
begin
  try
    FServer.Active := False;
    FreeAndNil(FServer);
  except

  end;
  inherited;
end;


procedure THttpServerRunner.Start(AServerConfigRec: THttpServerConfigRec);
begin
  try
    if FServer.Active then
    begin
      FServer.StopListening;
      FServer.Active := False;
    end;

    FServerConfigRec := AServerConfigRec;
    FServerConfigRec.AbsDocRoot := TFileUtil.GetAbsolutePathEx(ExePath, AServerConfigRec.DocRoot);

    FServer.Bindings.Clear;
    with FServer.Bindings.Add do
    begin
      IP := AServerConfigRec.IP;
      Port := AServerConfigRec.Port;
    end;
    FServer.DefaultPort := AServerConfigRec.Port;
    FServer.Active := True;
  except
    on E: Exception do
      AppLogger.Fatal('LocalServer����ʧ�ܣ�' + E.Message);
  end;
end;



procedure THttpServerRunner.OnServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  //log�Լ�����ͨ�õ�һЩ��¼
  HandleCommandEnter(AContext, ARequestInfo, AResponseInfo);

  //�������ҵ��
  HandleCommandRequest(AContext, ARequestInfo, AResponseInfo);

  //�������
  AResponseInfo.Server := 'CGT SERVER 1.0';
  AResponseInfo.CharSet := 'utf-8';
end;



procedure THttpServerRunner.OnServerCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  //log�Լ�����ͨ�õ�һЩ��¼
  HandleCommandEnter(AContext, ARequestInfo, AResponseInfo);

  //�������ҵ��
  AResponseInfo.ContentText := '';
  AResponseInfo.ContentType := 'text/plain;charset=utf-8';

  //�������
  AResponseInfo.Server := 'CGT SERVER 1.0';
  AResponseInfo.ContentEncoding := 'utf-8';
end;


procedure THttpServerRunner.HandleCommandEnter(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LRequest: string;
begin
  //��Ҫ�Կ�����д���
  LRequest := 'Command: ' + ARequestInfo.Command;
  LRequest := LRequest + '; GET File: ' + ARequestInfo.Document;
  LRequest := LRequest + '; Params: ' + ARequestInfo.QueryParams;
  LRequest := LRequest + '; Data: ' + ARequestInfo.FormParams;
  AppLogger.Debug('�յ�����: ' + LRequest);

  if (Trim(FServerConfigRec.AllowedAccessOrigins) <> '') then
  begin
    AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Origin'] := FServerConfigRec.AllowedAccessOrigins;
    AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Methods'] := 'GET,POST';
    AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Headers'] := 'x-requested-with,content-type';
  end;
end;



//������Ӧ�����󣬶���file��������Щ������Ҫֱ�ӵ���JobDispatcher����JobDispatcherȥ����
//�����첽��Ϣ�����͵�AsyncJobHandlerFormȥ��������AsyncJobHandlerForm�У�������һ��JobDispatcher��
//Ȼ��JobDispatcher�ٴδ��������ж�Ӧ��job����JobDispatcher�У������ж��Ƿ��첽����ͬ����Ҳ����˵��
//JobDispatcher��ֻ�ᴦ��ͬ����Ϣ�ģ����ڶ��̵߳�Session���ƣ����Ҫ��formҲ���ڶԶ���߳��з��͹�������Ϣ������Ӧ
//��ϢĬ�ϻ��Ŷӣ���˻����������������form������JobDispatcherʱ�����ټ���Ƿ����첽��Ϣ���ƣ���Ȼ��
//����Ҳ���Զ�����ͬ�����ƣ�����ֻ���ڷ�����÷�������http��Ҫ�첽��������ͬ��������http�����������������
//�Ƿ�Ҫ�����첽��Ϣ�������ƣ��Ӷ�ʹ��jobdispatcherĬ�϶���ͬ���������ƣ���job����֪����Ȼ�����ǿ���ͨ��
//����job�Ǻ�̨������ui��������������������Ӧ�ı�ʶ����������job��service������Ҳ��������Ӧ�Ľ�����
procedure THttpServerRunner.HandleCommandRequest(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LLocalDoc: string;
  LDocPath: string;
  LDisStrings: TStringList;
  LJobDispatcherRec: PJobDispatcherRec;
  LJobDispatcher: TJobDispatcher;
  LOutResult: TOutResult;
begin
  LLocalDoc := ExpandFilename(FServerConfigRec.AbsDocRoot + ARequestInfo.Document);

  //�ж��Ƿ���в���dis
  if (ARequestInfo.Params.Values['dis'].Length > 0) then
  begin
    LDocPath := ExtractFilePath(LLocalDoc);
    New(LJobDispatcherRec);

    //��������н���
    LDisStrings := TStringList.Create;
    try
      LDisStrings.Delimiter := '/';
      LDisStrings.DelimitedText := ARequestInfo.Params.Values['dis'];
      if LDisStrings.Count = 2 then
      begin
        LJobDispatcherRec^.ProjectFile := LDocPath + LDisStrings.Strings[0] + '/project.json';
        LJobDispatcherRec^.JobName := LDisStrings.Strings[1];
        LJobDispatcherRec^.InParams := GetRequestParams(ARequestInfo);
      end
      else
        Dispose(LJobDispatcherRec);
    finally
      LDisStrings.Free;
    end;

    if LJobDispatcherRec = nil then
    begin
      //���������
      LOutResult.Code := -1;
      LOutResult.Msg := 'dis�����쳣';
      LOutResult.Data := ARequestInfo.Params.Values['dis'];
    end
    else
    begin
      //ִ��jobdispatcher�������������첽��Ϣ������job����Ϣ��AsyncJobHandlerForm
      if ARequestInfo.Params.Values['vv_async'].Length > 0 then
      begin
        //����������
        //PostMessage

        LOutResult.Code := 1;
        LOutResult.Msg := '��������';
      end
      else
      begin
        //��������jobdispatcher��ֱ�ӵ���
        LJobDispatcher := TJobDispatcher.Create(FServerConfigRec.LogLevel);
        try
          LJobDispatcher.StartProjectJob(LJobDispatcherRec);

          //����������

        finally
          LJobDispatcher.Free;
        end;
      end;
    end;

    //����rsp����Ӧ����
    OutPutResult(ARequestInfo, AResponseInfo, LOutResult);
  end
  else
  begin
    //���ļ�����
    if not FileExists(LLocalDoc) and DirectoryExists(LLocalDoc) and FileExists(ExpandFilename(LLocalDoc + '/index.html '))
    then
    begin
      LLocalDoc := ExpandFilename(LLocalDoc + '/index.html ');
    end;

    AppLogger.Debug('��ȡ�ļ���' + LLocalDoc);

    if FileExists(LLocalDoc) then // File   exists
    begin
      //����web֧�ֵ��ļ���ʽ������ֱ�ӵ��ļ�����������򣬽������ش���
      if AnsiSameText(Copy(LLocalDoc, 1, length(FServerConfigRec.AbsDocRoot)), FServerConfigRec.AbsDocRoot) then // File   down   in   dir   structure
      begin
        AResponseInfo.ContentStream := TFileStream.Create(LLocalDoc, fmOpenRead + fmShareDenyWrite);
        AResponseInfo.ContentType := FServer.MIMETable.GetFileMIMEType(LLocalDoc);
      end
      else
        AResponseInfo.ResponseNo := 403;
    end
    else
    begin
      AResponseInfo.ResponseNo := 404;
    end;
  end;
end;



function THttpServerRunner.GetRequestParams(ARequestInfo: TIdHTTPRequestInfo): string;
var
  LStringStream: TStringStream;
  LParams: TJSONObject;
  i: Integer;
  LGetJson: TJSONObject;
begin
  LParams := TJSONObject.Create;

  try
    //_GET
    LGetJson := TJSONObject.Create;
    for i := 0 to ARequestInfo.Params.Count - 1 do
    begin
      LGetJson.AddPair(TJSONPair.Create(ARequestInfo.Params.Names[i], ARequestInfo.Params.ValueFromIndex[i]));
    end;
    LParams.AddPair(TJSONPair.Create('_GET', LGetJson));

    //_POST
    if UpperCase(ARequestInfo.Command) = 'POST' then
    begin
      if ARequestInfo.PostStream <> nil then
      begin
        LStringStream := TStringStream.Create;
        try
          ARequestInfo.PostStream.Seek(0, 0);
          LStringStream.LoadFromStream(ARequestInfo.PostStream);
          LParams.AddPair(TJSONPair.Create('_POST', UTF8Decode(LStringStream.DataString)));
        finally
          LStringStream.Free;
        end;
      end;
    end;

    Result := LParams.ToString;
  finally
    LParams.Free;
  end;
end;


procedure THttpServerRunner.OutputResult(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo;
  AOutResult: TOutResult);
begin

end;


end.