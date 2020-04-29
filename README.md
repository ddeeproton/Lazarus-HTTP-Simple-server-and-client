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
begin
  AResponse.Content := 'OnServerRequest from='+ARequest.RemoteAddr+' -> http://'+ARequest.Host+'/'+ARequest.GetNextPathInfo+'?myvariable='+ARequest.QueryFields.Values['myvariable'];
end;


//=========================
//=========================
// Client - start

procedure TForm1.ButtonRequestClick(Sender: TObject);
begin
  TThreadClient.Create('http://192.168.1.30:8080/page.php?myvariable=test', @OnClientResponse, @OnClientError);
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

Lazarus 

https://www.lazarus-ide.org
