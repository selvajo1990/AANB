codeunit 66003 "Integration Data Mgmt."
{
    trigger OnRun()
    var
        IntegrationDataTypeL: Enum "Integration Data Type";
    begin
        case this.JobType of
            Format(IntegrationDataTypeL::"Create Item"):
                this.CreateItem();
            Format(IntegrationDataTypeL::"Push Order"):
                this.PushSingleSalesOrderToLRI();
        end;
    end;

    procedure CreateItem()
    var
        ItemL: Record Item;
        ItemRef: RecordRef;
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Default Item Template");

        ItemL.Init();
        ItemL."No." := this.LRIItem."Product Id";
        ItemL.Insert(true);

        this.ConfigTemplateHeader.Get(this.AANBSetup."Default Item Template");

        ItemRef.GetTable(ItemL);
        this.ConfigTemplateManagement.UpdateRecord(this.ConfigTemplateHeader, ItemRef);
        ItemRef.SetTable(ItemL);

        ItemL.Description := this.LRIItem.Description;
        ItemL.Modify(true);
    end;

    procedure PushSingleSalesOrderToLRI()
    var
        SalesLine: Record "Sales Line";
        APITemplateSetup: Record "API Template Setup";
        SalesHeaderObject: JsonObject;
        SalesLineObject: JsonObject;
        DeliveryAddressObject: JsonObject;
        BillingAddressObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        JObject: JsonObject;
        InventoryUpdateTxt: Label '/%1', Comment = '%1';
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Push Sales Order");

        SalesHeaderObject.Add('rcb', '312');
        SalesHeaderObject.Add('order_ref', this.SalesHeader."No.");
        SalesHeaderObject.Add('carrier_code', 'SURPLACE');
        SalesHeaderObject.Add('ttc', '29.99');
        SalesHeaderObject.Add('cash_on_delivery', 'false');
        SalesHeaderObject.Add('b2b', 'true');
        SalesHeaderObject.Add('order_date', this.SalesHeader."Order Date");
        DeliveryAddressObject.Add('relay_point', '');
        DeliveryAddressObject.Add('delivery_firstname', this.SalesHeader."Ship-to Name");
        DeliveryAddressObject.Add('delivery_lastname', this.SalesHeader."Ship-to Name 2");
        DeliveryAddressObject.Add('delivery_company', '');
        DeliveryAddressObject.Add('delivery_address1', this.SalesHeader."Ship-to Address");
        DeliveryAddressObject.Add('delivery_address2', this.SalesHeader."Ship-to Address 2");
        DeliveryAddressObject.Add('delivery_address3', '');
        DeliveryAddressObject.Add('delivery_city', this.SalesHeader."Ship-to City");
        DeliveryAddressObject.Add('delivery_postcode', this.SalesHeader."Ship-to Post Code");
        DeliveryAddressObject.Add('delivery_region', '');
        DeliveryAddressObject.Add('delivery_country_iso', this.SalesHeader."Ship-to Country/Region Code");
        DeliveryAddressObject.Add('delivery_phone', this.SalesHeader."Ship-to Phone No.");
        DeliveryAddressObject.Add('delivery_email', this.SalesHeader."Sell-to E-Mail");
        SalesHeaderObject.Add('delivery_address', DeliveryAddressObject);
        BillingAddressObject.Add('relay_point', '');
        BillingAddressObject.Add('billing_firstname', this.SalesHeader."Sell-to Customer Name");
        BillingAddressObject.Add('billing_lastname', this.SalesHeader."Sell-to Customer Name 2");
        BillingAddressObject.Add('billing_company', '');
        BillingAddressObject.Add('billing_address1', this.SalesHeader."Sell-to Address");
        BillingAddressObject.Add('billing_address2', this.SalesHeader."Sell-to Address 2");
        BillingAddressObject.Add('billing_address3', '');
        BillingAddressObject.Add('billing_city', this.SalesHeader."Sell-to City");
        BillingAddressObject.Add('billing_postcode', this.SalesHeader."Sell-to Post Code");
        BillingAddressObject.Add('billing_region', '');
        BillingAddressObject.Add('billing_country_iso', this.SalesHeader."Sell-to Country/Region Code");
        BillingAddressObject.Add('billing_phone', this.SalesHeader."Sell-to Phone No.");
        BillingAddressObject.Add('billing_email', this.SalesHeader."Sell-to E-Mail");
        SalesHeaderObject.Add('billing_address', BillingAddressObject);
        SalesLine.SetRange("Document Type", this.SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", this.SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                Clear(SalesLineObject);
                SalesLineObject.Add('product_ref', SalesLine."No.");
                SalesLineObject.Add('product_name', SalesLine.Description);
                SalesLineObject.Add('quantity', SalesLine.Quantity);
                JArray.Add(SalesLineObject);
            until SalesLine.Next() = 0;
        SalesHeaderObject.Add('items', JArray);
        SalesHeaderObject.WriteTo(this.Request);

        this.EntryNo := this.TransactionLog.TransactionLog(this.TransactionLog."Entry Type"::"Outgoing Request", 0,
                                                 this.TransactionLog.Status::Processed, this.SalesHeader."No.", ApiTemplateSetup, '', this.Request);
        Commit();

        this.FetchApiTemplateSetup(this.AANBSetup."Push Sales Order", ApiTemplateSetup);
        ApiTemplateSetup.TestField(EndPoint);
        ApiTemplateSetup.TestField(Password);
        this.InitPostRequest();

        this.Content.GetHeaders(this.Header);
        this.Content.WriteFrom(this.Request);
        this.Header.Clear();
        this.Header.Add('Content-Type', 'application/json');
        this.HttpRequest.GetHeaders(this.Header);
        this.Client.DefaultRequestHeaders.Add('X-AUTH-TOKEN', APITemplateSetup.Password);
        this.Client.Post(ApiTemplateSetup.EndPoint + StrSubstNo(InventoryUpdateTxt, this.SalesHeader."No."), this.Content, this.HttpResponse);
        if this.HttpResponse.HttpStatusCode() in [200, 201] then begin
            this.HttpResponse.Content().ReadAs(this.Response);
            this.TransactionLog.TransactionLog(this.TransactionLog."Entry Type"::"Outgoing Response", this.EntryNo,
                                               this.TransactionLog.Status::Processed, this.SalesHeader."No.", ApiTemplateSetup, '', this.Response);
            Commit();
        end else begin
            this.HttpResponse.Content().ReadAs(this.Response);
            this.TransactionLog.TransactionLog(this.TransactionLog."Entry Type"::"Outgoing Response", this.EntryNo,
                                               this.TransactionLog.Status::Failed, this.SalesHeader."No.", ApiTemplateSetup, '', this.Response);
            Commit();
            if GuiAllowed then begin
                JObject.ReadFrom(this.Response);
                JObject.SelectToken('errors', JToken);
                JToken.WriteTo(this.Response);
                Error(this.Response);
            end;
        end;
    end;

    procedure ProductFetch()
    var
        APITransactionLog: Record "API Transaction Log";
        APITemplateSetup: Record "API Template Setup";
        ProductObject: JsonObject;
        OrderToken: JsonToken;
        ProductId: Text[100];
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Product Fetch");

        this.FetchApiTemplateSetup(this.AANBSetup."Product Fetch", ApiTemplateSetup);
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

        ProductId := AANBIntegationMgmt.TextValue('product_ref', OrderToken);

        if not this.LRIItem.Get(ProductId) then begin
            this.LRIItem.Init();
            this.LRIItem."Product Id" := CopyStr(ProductId, 1, MaxStrLen(this.LRIItem."Product Id"));
            this.LRIItem.Description := AANBIntegationMgmt.TextValue('product_name', OrderToken);
            this.LRIItem.Type := AANBIntegationMgmt.TextValue('type', OrderToken);
            this.LRIItem."Is Active" := AANBIntegationMgmt.BooleanValue('is_active', OrderToken);
            this.LRIItem.Insert();
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

    procedure FetchApiTemplateSetup(TemplateCode: Code[20]; var APITemplateSetupP: Record "API Template Setup")
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSandbox() then
            APITemplateSetupP.Get(TemplateCode, APITemplateSetupP."Environment Type"::Sandbox)
        else
            APITemplateSetupP.Get(TemplateCode, APITemplateSetupP."Environment Type"::Production)
    end;

    procedure SetItemData(LRIItemP: Record "LRI Item"; JobTypeP: Code[20])
    begin
        this.JobType := JobTypeP;
        this.LRIItem := LRIItemP;
    end;

    procedure SetSalesOrderData(SalesHeaderP: Record "Sales Header"; JobTypeP: Code[20])
    begin
        this.JobType := JobTypeP;
        this.SalesHeader := SalesHeaderP;
    end;

    var
        ConfigTemplateHeader: Record "Config. Template Header";
        AANBSetup: Record "AANB Setup";
        LRIItem: Record "LRI Item";
        SalesHeader: Record "Sales Header";
        TransactionLog: Record "API Transaction Log";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        AANBIntegationMgmt: Codeunit "AANB Integation Mgmt.";
        EntryNo: BigInteger;
        Request: Text;
        Response: Text;
        Content: HttpContent;
        Client: HttpClient;
        Header: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        JobType: Code[20];
}
