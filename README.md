# Lazarus-HTTP-Simple-server-and-client

This project implemented a new class to simply use the plugin fpWeb. 

```
uses ..., httpmanager, fphttpserver;
...
implementation

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
  AResponse.Content := 'OnServerRequest from='+ARequest.RemoteAddr+' -> '+url;          
end;


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


How to install fpWeb into Lazarus ?

https://wiki.lazarus.freepascal.org/fpWeb_Tutorial

Project created on Lazarus 2.0.6

https://www.lazarus-ide.org
