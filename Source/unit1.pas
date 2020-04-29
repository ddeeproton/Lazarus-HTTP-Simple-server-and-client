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
// Server

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.Lines.Add('Auto start listening on port 8080');
  TThreadServer.Create(8080, @OnServerRequest);
end;


procedure TForm1.OnServerRequest(Sender: TObject;var ARequest: TFPHTTPConnectionRequest;var AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.Content := 'OnServerRequest from='+ARequest.RemoteAddr+' -> http://'+ARequest.Host+'/'+ARequest.GetNextPathInfo+'?myvariable='+ARequest.QueryFields.Values['myvariable'];
end;


//=========================
// Client

procedure TForm1.ButtonRequestClick(Sender: TObject);
begin
  TThreadClient.Create('http://192.168.1.30:8080/page.php?myvariable=test', @OnClientResponse, @OnClientError);
end;


procedure TForm1.OnClientResponse(ThreadClient: TThreadClient);
begin
  Memo1.lines.Add('OnClientResponse='+ThreadClient.Response);
end;


procedure TForm1.OnClientError(ThreadClient: TThreadClient; E: Exception);
begin
  Memo1.lines.Add('URL:'+ThreadClient.url+' Error:'+ E.Message);
end;



end.

