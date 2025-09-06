codeunit 66000 "LRI Integration Mgmt."
{
    procedure ProductFetch()
    var
        APITransactionLog: Record "API Transaction Log";
        APITemplateSetup: Record "API Template Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        EntryNo, ProductCount : Integer;
        ProductObject: JsonObject;
        ProductArray: JsonArray;
        ResultToken, OrderToken : JsonToken;
        ProductId: Text[100];
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Product Fetch");

        FetchApiTemplateSetup(this.AANBSetup."Product Fetch", ApiTemplateSetup);
        ApiTemplateSetup.TestField(EndPoint);
        ApiTemplateSetup.TestField(Password);
        this.InitPostRequest();
        this.Content.GetHeaders(this.Header);
        this.Header.Clear();
        this.Client.DefaultRequestHeaders.Add('X-AUTH-TOKEN', APITemplateSetup.Password);
        this.Client.Get(APITemplateSetup.EndPoint, this.HttpResponse);
        EntryNo := APITransactionLog.TransactionLog(APITransactionLog."Entry Type"::"Outgoing Request", 0, APITransactionLog.Status::Processed, '', APITemplateSetup, '', APITemplateSetup.EndPoint);
        if this.HttpResponse.HttpStatusCode <> 200 then begin
            if this.HttpResponse.IsSuccessStatusCode then
                this.HttpResponse.Content.ReadAs(this.Response);
            APITransactionLog.TransactionLog(APITransactionLog."Entry Type"::"Outgoing Response", EntryNo, APITransactionLog.Status::Failed, '', APITemplateSetup, CopyStr(this.HttpResponse.ReasonPhrase(), 1, 2048), this.Response);
            Commit();
            Error(this.HttpResponse.ReasonPhrase());
        end;
        this.HttpResponse.Content.ReadAs(this.Response);
        EntryNo := APITransactionLog.TransactionLog(APITransactionLog."Entry Type"::"Outgoing Response", EntryNo, APITransactionLog.Status::Processed, '', APITemplateSetup, CopyStr(this.HttpResponse.ReasonPhrase(), 1, 2048), this.Response);
        Commit();

        ProductObject.ReadFrom(this.Response);
        OrderToken := ProductObject.AsToken();

        ProductId := this.TextValue('product_ref', OrderToken);

        if not LRIItem.Get(ProductId) then begin
            LRIItem.Init();
            LRIItem."Product Id" := ProductId;
            LRIItem.Description := this.TextValue('product_name', OrderToken);
            LRIItem.Type := this.TextValue('type', OrderToken);
            LRIItem."Is Active" := this.BooleanValue('is_active', OrderToken);
            LRIItem.Insert();
        end;

    end;

    procedure InitPostRequest()
    begin
        Clear(this.Request);
        Clear(this.Response);
        Clear(this.Content);
        Clear(this.Client);
        Clear(this.Header);
        Clear(this.HttpResponse);
        Clear(this.HttpRequest);
    end;

    procedure TextValue(Path: Text[100]; JTokenIn: JsonToken): Text[100]
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit('');

        if JTokenOut.AsValue().IsNull() then
            exit('');
        exit(CopyStr(JTokenOut.AsValue().AsText(), 1, 100));
    end;

    procedure FetchApiTemplateSetup(TemplateCode: Code[20]; var APITemplateSetupP: Record "API Template Setup")
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSandbox() then
            APITemplateSetupP.Get(TemplateCode, APITemplateSetupP."Environment Type"::Sandbox)
        else
            APITemplateSetupP.Get(TemplateCode, APITemplateSetupP."Environment Type"::Production)
    end;

    procedure IntegerValue(Path: Text[100]; JTokenIn: JsonToken): Integer
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit(0);

        if JTokenOut.AsValue().IsNull() then
            exit(0);
        exit(JTokenOut.AsValue().AsInteger());
    end;

    procedure BooleanValue(Path: Text[100]; JTokenIn: JsonToken): Boolean
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit(false);

        if JTokenOut.AsValue().IsNull() then
            exit(false);
        exit(JTokenOut.AsValue().AsBoolean());
    end;

    var
        AANBSetup: Record "AANB Setup";
        LRIItem: Record "LRI Item";
        Request: Text;
        Response: Text;
        Content: HttpContent;
        Client: HttpClient;
        Header: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
}
