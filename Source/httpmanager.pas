unit httpmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpserver, fphttpclient, RegexPr;

type
  //======================================
  // Server
  TThreadServer = class(TThread)
  protected
    procedure Execute; override;
  public
    FPHttpServer1: TFPHttpServer;
    constructor Create(Port: Integer; OnQuery: THTTPServerRequestHandler);
    destructor Destroy; override;
  end;

  //======================================
  // Client
  TThreadClient = class(TThread)
    type
      TClientResponseFunction = procedure (ThreadClient: TThreadClient) of object;Register;
      TClientErrorFunction = procedure (ThreadClient: TThreadClient; E: Exception) of object;Register;
    var
      url:String;
      isResponse:Boolean;
      isError:Boolean;
      Response: String;
      Error: Exception;
      PClientResponseFunction: TClientResponseFunction;
      PClientErrorFunction: TClientErrorFunction;
      PThreadMethod: TThreadMethod;
  protected
    procedure Execute; override;
    procedure OnClientResponse;
    procedure OnClientError;
  public
    constructor Create(link: String; PClient: TClientResponseFunction; PError: TClientErrorFunction);  
    function get(http_url:String):String;
  end;




implementation



// =========== Server ===========

constructor TThreadServer.Create(Port: Integer; OnQuery: THTTPServerRequestHandler);
begin
  Self.FreeOnTerminate := true;
  FPHttpServer1 := TFPHttpServer.Create(nil);
  FPHttpServer1.Port := Port;
  FPHttpServer1.OnRequest := OnQuery;
  FPHttpServer1.LookupHostNames:=False;
  inherited Create(False);
end;

destructor TThreadServer.Destroy;
begin
  FPHttpServer1.Free;
end;

procedure TThreadServer.Execute;
begin
  try
    FPHttpServer1.Active := True;
  except
    on E: Exception do
    begin
      Exit;
    end;
  end;
end;




// =========== Client ===========

constructor TThreadClient.Create(link: String; PClient: TClientResponseFunction; PError: TClientErrorFunction);
begin
  PClientResponseFunction := PClient;
  PClientErrorFunction := PError;
  isResponse := False;
  isError := False;
  url := link;
  FreeOnTerminate := True;
  inherited Create(False);
end;


procedure TThreadClient.Execute;
begin //while not Application.Terminated do begin
  Response := get(url);
  Synchronize(@OnClientResponse);
  DoTerminate;
end;


procedure TThreadClient.OnClientResponse;
begin
  PClientResponseFunction(Self);
end;


procedure TThreadClient.OnClientError;
begin
  PClientErrorFunction(Self, Error);
end;


function TThreadClient.get(http_url:String):String;
var
  Client: TFPHTTPClient;
begin
  result := '';
  try
    Client := TFPHTTPClient.Create(nil);
    try
      result := Client.Get(http_url).Trim;
      isResponse := result <> '';
    except
      on E: Exception do
      begin
        isError := True;
        Error := E;
        Synchronize(@OnClientError);
        //result := E.Message;
      end;
    end;
  finally
    Client.Free;
  end;
end;




end.

