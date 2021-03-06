unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, httpmanager, fphttpserver;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonRequest: TButton;
    Memo1: TMemo;
    procedure ButtonRequestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnClientResponse(ThreadClient: TThreadClient);
    procedure OnClientError(ThreadClient: TThreadClient; E: Exception);
    procedure OnServerRequest(Sender: TObject;var ARequest: TFPHTTPConnectionRequest;var AResponse: TFPHTTPConnectionResponse);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

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


end.

