codeunit 66005 "Fetch Woo Commerce Orders"
{
    procedure OrderFetchFromWoocommerce()
    var
        APITransactionLog: Record "API Transaction Log";
        APITemplateSetup: Record "API Template Setup";
        WooCommerceOrderDetail: Record "Woo Commerce Order Detail";
        OrderArray, ItemLineArray, TaxArray : JsonArray;
        ResultToken, OrderToken, TaxToken, ItemLineToken : JsonToken;
        Amount: Decimal;
        LastRunTimeStamp, FetchUrl : Text;
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Order Fetch");
        LastRunTimeStamp := this.GetLastRunTimeStamp();
        this.FetchApiTemplateSetup(this.AANBSetup."Order Fetch", APITemplateSetup);
        APITemplateSetup.TestField("User ID");
        ApiTemplateSetup.TestField(EndPoint);
        ApiTemplateSetup.TestField(Password);
        FetchUrl := StrSubstNo(APITemplateSetup.EndPoint, LastRunTimeStamp);
        this.InitPostRequest();
        this.Content.GetHeaders(this.Header);
        this.Header.Clear();
        this.Client.DefaultRequestHeaders().Add('Authorization', this.BasicAuthorization(APITemplateSetup."User ID", APITemplateSetup.Password));
        this.Client.Get(FetchUrl, this.HttpResponse);
        this.EntryNo := APITransactionLog.TransactionLog(APITransactionLog."Entry Type"::"Outgoing Request", 0, APITransactionLog.Status::Processed, '', APITemplateSetup, '', APITemplateSetup.EndPoint);
        if this.HttpResponse.HttpStatusCode <> 200 then begin
            if this.HttpResponse.IsSuccessStatusCode then
                this.HttpResponse.Content.ReadAs(this.Response);
            APITransactionLog.TransactionLog(APITransactionLog."Entry Type"::"Outgoing Response", this.EntryNo, APITransactionLog.Status::Failed, '', APITemplateSetup, CopyStr(this.HttpResponse.ReasonPhrase(), 1, 2048), this.Response);
            Commit();
            Error(this.HttpResponse.ReasonPhrase());
        end;
        this.HttpResponse.Content.ReadAs(this.Response);
        this.EntryNo := APITransactionLog.TransactionLog(APITransactionLog."Entry Type"::"Outgoing Response", this.EntryNo, APITransactionLog.Status::Processed, '', APITemplateSetup, CopyStr(this.HttpResponse.ReasonPhrase(), 1, 2048), this.Response);
        Commit();

        this.AANBSetup."Last Modified Order TimeStamp" := CurrentDateTime;
        this.AANBSetup.Modify();

        ResultToken.ReadFrom(this.Response);
        OrderArray := ResultToken.AsArray();

        foreach OrderToken in OrderArray do
            if not WooCommerceOrderDetail.Get(WooCommerceOrderDetail."Order Type"::Order, this.TextValue('order_key', OrderToken)) then begin
                WooCommerceOrderDetail.Init();
                WooCommerceOrderDetail."Order Type" := WooCommerceOrderDetail."Order Type"::Order;
                WooCommerceOrderDetail."Order No." := this.TextValue('order_key', OrderToken);
                WooCommerceOrderDetail."Order Date Time" := this.DateTimeValue('date_created', OrderToken);
                WooCommerceOrderDetail."Order Date" := DT2Date(WooCommerceOrderDetail."Order Date Time");
                WooCommerceOrderDetail."Order Time" := DT2Time(WooCommerceOrderDetail."Order Date Time");
                WooCommerceOrderDetail."Amount Incl VAT" := this.DecimalValue('total', OrderToken);
                WooCommerceOrderDetail."VAT Amount" := this.DecimalValue('total_tax', OrderToken);
                WooCommerceOrderDetail."Discount Amount" := this.DecimalValue('discount_total', OrderToken);
                WooCommerceOrderDetail."Discount Amount Tax" := this.DecimalValue('discount_tax', OrderToken);
                WooCommerceOrderDetail."Delivery Fee" := this.DecimalValue('shipping_total', OrderToken);
                WooCommerceOrderDetail."Delivery Fee Tax" := this.DecimalValue('shipping_tax', OrderToken);
                WooCommerceOrderDetail.Currency := this.TextValue('currency', OrderToken);
                WooCommerceOrderDetail.Status := this.TextValue('status', OrderToken);
                Amount := this.DecimalValue('total', OrderToken) - this.DecimalValue('total_tax', OrderToken);
                WooCommerceOrderDetail.Amount := Amount;

                OrderToken.SelectToken('line_items', ItemLineToken);
                ItemLineArray := ItemLineToken.AsArray();
                WooCommerceOrderDetail."No. Of Items" := ItemLineArray.Count;

                OrderToken.SelectToken('tax_lines', TaxToken);
                TaxArray := TaxToken.AsArray();
                foreach TaxToken in TaxArray do
                    WooCommerceOrderDetail."VAT %" := this.DecimalValue('rate_percent', TaxToken);

                WooCommerceOrderDetail.Insert();
            end;
    end;

    procedure GetLastRunTimeStamp(): Text
    var
        WooCommerceOrderDetailL: Record "Woo Commerce Order Detail";
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Order Fetch");

        if this.AANBSetup."Fetch All Order" then begin
            this.AANBSetup.TestField("Fetch All Order Interval");
            WooCommerceOrderDetailL."Order Date Time" := CreateDateTime(WorkDate(), Time) - this.AANBSetup."Fetch All Order Interval";
            exit(Format(WooCommerceOrderDetailL."Order Date Time", 0, 9));
        end;

        this.AANBSetup.TestField("Recurring Order Fetch Interval");
        WooCommerceOrderDetailL.FindLast();
        WooCommerceOrderDetailL."Order Date Time" := WooCommerceOrderDetailL."Order Date Time" - this.AANBSetup."Recurring Order Fetch Interval";
        exit(Format(WooCommerceOrderDetailL."Order Date Time", 0, 9));
    end;

    procedure BasicAuthorization(Username: Text[250]; Password: Text[250]): Text
    var
        Base64: Codeunit "Base64 Convert";
        ApiKey: Text;
        BasicAuthTxt: Label 'Basic %1', Comment = '%1';
        CredentialsTxt: Label '%1:%2', Comment = '%1,%2';
    begin
        ApiKey := StrSubstNo(BasicAuthTxt, Base64.ToBase64(StrSubstNo(CredentialsTxt, Username, Password)));
        exit(ApiKey);
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

    procedure FetchApiTemplateSetup(TemplateCode: Code[20]; var APITemplateSetupP: Record "API Template Setup")
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSandbox() then
            APITemplateSetupP.Get(TemplateCode, APITemplateSetupP."Environment Type"::Sandbox)
        else
            APITemplateSetupP.Get(TemplateCode, APITemplateSetupP."Environment Type"::Production)
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

    procedure DateTimeValue(Path: Text[100]; JTokenIn: JsonToken): DateTime
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit(0DT);

        if JTokenOut.AsValue().IsNull() then
            exit(0DT);
        exit(JTokenOut.AsValue().AsDateTime());
    end;

    procedure TextValueMaximum(Path: Text[100]; JTokenIn: JsonToken): Text
    var
        JTokenOut: JsonToken;
    begin
        JTokenIn.SelectToken(Path, JTokenOut);
        if JTokenOut.AsValue().IsNull() then
            exit('');
        exit(JTokenOut.AsValue().AsText());
    end;

    procedure CodeValue(Path: Text[100]; JTokenIn: JsonToken): Code[100]
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit('');

        if JTokenOut.AsValue().IsNull() then
            exit('');
        exit(CopyStr(JTokenOut.AsValue().AsCode(), 1, 100));
    end;

    procedure EntryTypeEnum(Path: Text[100]; JTokenIn: JsonToken) LRIStockMovementType: Enum "LRI Stock Movement Type"
    var
        JTokenOut: JsonToken;
    begin
        JTokenIn.SelectToken(Path, JTokenOut);
        case JTokenOut.AsValue().AsText().ToUpper() of
            'Purchase':
                exit(LRIStockMovementType::Purchase);
            'Purchase Return':
                exit(LRIStockMovementType::"Purchase Return");
            'Sales':
                exit(LRIStockMovementType::Sales);
            'Sales Return':
                exit(LRIStockMovementType::"Sales Return");

        end
    end;

    procedure DecimalValue(Path: Text[100]; JTokenIn: JsonToken): Decimal
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit(0);

        if JTokenOut.AsValue().IsNull() then
            exit(0);
        exit(JTokenOut.AsValue().AsDecimal());
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

    procedure DateValue(Path: Text[100]; JTokenIn: JsonToken): Date
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit(0D);

        if JTokenOut.AsValue().IsNull() then
            exit(0D);
        exit(JTokenOut.AsValue().AsDate());
    end;

    procedure TimeValue(Path: Text[100]; JTokenIn: JsonToken): Time
    var
        JTokenOut: JsonToken;
    begin
        if not JTokenIn.SelectToken(Path, JTokenOut) then
            exit(0T);

        if JTokenOut.AsValue().IsNull() then
            exit(0T);
        exit(JTokenOut.AsValue().AsTime());
    end;


    var
        AANBSetup: Record "AANB Setup";
        EntryNo: BigInteger;
        Request: Text;
        Response: Text;
        Content: HttpContent;
        Client: HttpClient;
        Header: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
}
