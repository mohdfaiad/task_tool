{
 用来管理来自js调用时，需要回调函数的列表，
 注册：在调用时进行注册
 释放：a) 对于函数的回调函数，在执行完之后进行清除；
       b) 对于事件的回调函数，在本context释放时统一进行清除
 本mgr中管理了来自不同的context中的回调，整个render进程通用
}
unit uRENDER_JsCallbackMgr;

interface

uses
  uCEFInterfaces, System.Generics.Collections;

type
  TCallerFuncType = (cftEvent, cftFunction);

  TContextCallbackRec = record
    BrowserId: Integer;
    CallerName: string;
    CallerFuncType: TCallerFuncType;
    CallbackFunc: ICefv8Value;
    Context: ICefv8Context;
  end;

  TContextCallback = class
    BrowserId: Integer;
    CallerName: string;
    CallbackFuncType: TCallerFuncType;
    CallbackFunc: ICefv8Value;
    Context: ICefV8Context;
  end;


  TRENDER_JsCallbackMgr = class
  private
    FCallbacks: TObjectList<TContextCallback>;
    function AddCallback(ACb: TContextCallback): Integer; overload;
    function RemoveCallbackByBrowserId(ABrowserId: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    //执行找到对应Browser的参数进行执行
    function AddCallback(ACb: TContextCallbackRec): Integer; overload;
    function RemoveCallback(ACb: TContextCallback): Boolean;
    function RemoveCallbackByContext(AContext: ICefV8Context): Boolean;
    function GetCallback(ABrowserId: Integer; ACallerName: string): TContextCallback;

  end;

var
  PRENDER_JsCallbackMgr: TRENDER_JsCallbackMgr;

implementation

uses System.SysUtils;

{ TRenderJsCallbackMgr }


function TRENDER_JsCallbackMgr.AddCallback(ACb: TContextCallbackRec): Integer;
var
  LContextCallback: TContextCallback;
begin
  Result := -1;
  if GetCallback(Acb.BrowserId, ACb.CallerName) <> nil then Exit;
  
  //创建类
  LContextCallback := TContextCallback.Create;
  try
    LContextCallback.BrowserId := ACb.BrowserId;
    LContextCallback.CallerName := ACb.CallerName;
    LContextCallback.CallbackFuncType := ACb.CallerFuncType;
    LContextCallback.CallbackFunc := ACb.CallbackFunc;
    LContextCAllback.Context := ACb.Context;

    if AddCallback(LContextCallback) < 0 then
      LContextCallback.Free;
  except
    on E: Exception do
    begin
      if LContextCallback <> nil then
        LContextCallback.Free;
    end;
  end;
end;


function TRENDER_JsCallbackMgr.AddCallback(ACb: TContextCallback): Integer;
var
  i: Integer;
begin
  //根据对应的id和msg_name进行匹配，还有msg_type，如果对应context的回调中已经
  //包含有这个值，则直接进行丢弃，并且释放这个Acb
  Result := -1;
  if GetCallback(ACb.BrowserId, ACb.CallerName) = nil then
    Result := FCallbacks.Add(ACb);
end;


constructor TRENDER_JsCallbackMgr.Create;
begin
  inherited;
  FCallbacks := TObjectList<TContextCallback>.Create(False);
end;


destructor TRENDER_JsCallbackMgr.Destroy;
var
  i: Integer;
begin
  for i := FCallbacks.Count - 1 downto 0 do
  begin
    if FCallbacks.Items[i] <> nil then
    begin
      FCallbacks.Items[i].Free;
    end;
  end;
  FCallbacks.Free;
  inherited;
end;


function TRENDER_JsCallbackMgr.GetCallback(ABrowserId: Integer;
  ACallerName: string): TContextCallback;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FCallbacks.Count - 1 do
  begin
    if FCallbacks.Items[i] <> nil then
    begin
      if (FCallbacks.Items[i].BrowserId = ABrowserId)
        and (FCallbacks.Items[i].CallerName = ACallerName) then
      begin
        Result := FCallbacks.Items[i];
        Break;
      end;
    end;
  end;
end;


function TRENDER_JsCallbackMgr.RemoveCallback(ACb: TContextCallback): Boolean;
begin
  if ACb <> nil then
  begin
    FCallbacks.Remove(ACb);
    ACb.Free;
  end;
end;

function TRENDER_JsCallbackMgr.RemoveCallbackByBrowserId(
  ABrowserId: Integer): Boolean;
var
  i: Integer;
begin
  for i := FCallbacks.Count - 1 downto 0 do
  begin
    if FCallbacks.Items[i] <> nil then
    begin
      if FCallbacks.Items[i].BrowserId = ABrowserId then
      begin
        FCallbacks.Items[i].Free;
        FCallbacks.Delete(i);
      end;
    end;
  end;
end;


function TRENDER_JsCallbackMgr.RemoveCallbackByContext(
  AContext: ICefV8Context): Boolean;
var
  i: Integer;
begin
  for i := FCallbacks.Count - 1 downto 0 do
  begin
    if FCallbacks.Items[i] <> nil then
    begin
      if FCallbacks.Items[i].Context.IsSame(AContext) then
      begin
        FCallbacks.Items[i].Free;
        FCallbacks.Delete(i);
      end;
    end;
  end;
end;

end.
