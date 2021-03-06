# Lazarus-HTTP-Simple-server-and-client

This project show how to use fpWeb plugin with threads. 

( A starting base for others projects )

![](Preview.jpg)

### How to use ? 

```

//=========================
// SERVER HTTP
//=========================

//=========================
// Server - start
procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.Lines.Add('Auto start listening on port 8080');
  TThreadServer.Create(8080, @OnServerRequest);
end;

//=========================
// Server - Response
procedure TForm1.OnServerRequest(Sender: TObject;var ARequest: TFPHTTPConnectionRequest;var AResponse: TFPHTTPConnectionResponse);
var url: String;
begin
  url := 'http://'+ARequest.Host+'/'+ARequest.GetNextPathInfo+'?myvariable='+ARequest.QueryFields.Values['myvariable'];
  AResponse.Content := 'OnServerRequest from='+ARequest.RemoteAddr+' -> to='+url;
end;


//=========================
// CLIENT HTTP
//=========================

//=========================
// Client - start
procedure TForm1.ButtonRequestClick(Sender: TObject);
begin
  TThreadClient.Create('http://127.0.0.1:8080/page.php?myvariable=test', @OnClientResponse, @OnClientError);
end;

//=========================
// Client - client response
procedure TForm1.OnClientResponse(ThreadClient: TThreadClient);
begin
  Memo1.lines.Add('OnClientResponse='+ThreadClient.Response);
end;

//=========================
// Client - client error
procedure TForm1.OnClientError(ThreadClient: TThreadClient; E: Exception);
begin
  Memo1.lines.Add('URL:'+ThreadClient.url+' Error:'+ E.Message);
end;
  

```
### How to install ?

How to install fpWeb into Lazarus ?

https://wiki.lazarus.freepascal.org/fpWeb_Tutorial

Project created on Lazarus 2.0.6

https://www.lazarus-ide.org

### Content of unit httpmanager

This unit create the fphttpserver and the fphttpclient into threads and return results in triggers event functions 

```
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
  if Assigned(PClientResponseFunction) then
     PClientResponseFunction(Self);
end;


procedure TThreadClient.OnClientError;
begin
  if Assigned(PClientErrorFunction) then
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

```


## Bugs

The server cannot be stopped after started. 

Use Application.terminate; to kill the server. 

## Changes

### 0.0.1

First commit

### 0.0.2

Add Trim to client result
```
result := Client.Get(http_url).Trim;
```
### 0.0.3

Allow to set null in events functions
```
if Assigned(PClientResponseFunction) then
...
if Assigned(PClientErrorFunction) then 
```