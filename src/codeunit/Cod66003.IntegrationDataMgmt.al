codeunit 66003 "Integration Data Mgmt."
{
    trigger OnRun()
    var
        IntegrationDataTypeL: Enum "Integration Data Type";
    begin
        case this.JobType of
            Format(IntegrationDataTypeL::"Create Item"):
                this.CreateItemFromStaging();
            Format(IntegrationDataTypeL::"Push Order"):
                this.PushSalesOrderToLRI();
            Format(IntegrationDataTypeL::"Fetch Item"):
                this.ProductFetchFromLRI();
        end;
    end;

    procedure CreateItemFromStaging()
    var
        ItemL: Record Item;
        ItemRef: RecordRef;
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Default Item Template");
        // if ItemL.Get(this.LRIItem."Product Id") then

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

    procedure PushSalesOrderToLRI()
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
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Push Sales Order");
        this.AANBSetup.TestField("RCB No.");

        this.FetchApiTemplateSetup(this.AANBSetup."Push Sales Order", ApiTemplateSetup);
        ApiTemplateSetup.TestField(EndPoint);
        ApiTemplateSetup.TestField(Password);
        this.InitPostRequest();

        this.SalesHeader.TestField("Sell-to Customer Name");
        this.SalesHeader.TestField("Sell-to Customer Name 2");
        this.SalesHeader.TestField("Sell-to E-Mail");
        this.SalesHeader.TestField("Sell-to Phone No.");
        this.SalesHeader.TestField("Sell-to Address");

        this.SalesHeader.TestField("Ship-to Name");
        this.SalesHeader.TestField("Ship-to Name 2");
        this.SalesHeader.TestField("Ship-to Phone No.");
        this.SalesHeader.TestField("Ship-to Address");
        this.SalesHeader.TestField("Ship-to City");
        this.SalesHeader.TestField("Ship-to Country/Region Code");
        this.SalesHeader.TestField("Ship-to Post Code");

        SalesHeaderObject.Add('rcb', this.AANBSetup."RCB No.");
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

        this.Content.GetHeaders(this.Header);
        this.Content.WriteFrom(this.Request);
        this.Header.Clear();
        this.Header.Add('Content-Type', 'application/json');
        this.HttpRequest.GetHeaders(this.Header);
        this.Client.DefaultRequestHeaders.Add('X-AUTH-TOKEN', APITemplateSetup.Password);
        this.Client.Post(ApiTemplateSetup.EndPoint, this.Content, this.HttpResponse);
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
                JToken := JObject.AsToken();
                this.Response := this.AANBIntegationMgmt.TextValueMaximum('message', JToken);
                Error(this.Response);
            end;
        end;
    end;

    procedure ProductFetchFromLRI()
    var
        APITransactionLog: Record "API Transaction Log";
        APITemplateSetup: Record "API Template Setup";
        OrderToken: JsonToken;
        ItemToken: JsonToken;
        OrderArray: JsonArray;
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

        OrderToken.ReadFrom(this.Response);
        OrderArray := OrderToken.AsArray();
        foreach ItemToken in OrderArray do begin
            ProductId := this.AANBIntegationMgmt.TextValue('product_ref', ItemToken);
            if not this.LRIItem.Get(ProductId) then begin
                this.LRIItem.Init();
                this.LRIItem."Product Id" := CopyStr(ProductId, 1, MaxStrLen(this.LRIItem."Product Id"));
                this.LRIItem.Description := this.AANBIntegationMgmt.TextValue('product_name', ItemToken);
                this.LRIItem.Type := this.AANBIntegationMgmt.TextValue('type', ItemToken);
                this.LRIItem."Is Active" := this.AANBIntegationMgmt.BooleanValue('is_active', ItemToken);
                this.LRIItem.Insert();
            end;
        end;
    end;

    procedure PostMovementJournal()
    begin
        // AANB Setup  

        // CryoSetup.Get();
        // CryoSetup.TestField("Suggest Job Template Name");
        // CryoSetup.TestField("Suggest Job Journal Batch");

        // JobJnlLine.SetRange("Journal Template Name", JobJnlLine."Journal Template Name");
        // JobJnlLine.SetRange("Journal Batch Name", JobJnlLine."Journal Batch Name");
        // if JobJnlLine.FindLast() then;
        // LineNo := JobJnlLine."Line No.";

        // JobJnlLine.Init();
        // LineNo := LineNo + 10000;
        // JobJnlLine."Line No." := LineNo;
        // JobJnlLine."Time Sheet No." := TimeSheetDetail."Time Sheet No.";
        // JobJnlLine."Time Sheet Line No." := TimeSheetDetail."Time Sheet Line No.";
        // JobJnlLine."Time Sheet Date" := TimeSheetDetail.Date;
        // JobJnlLine.Validate("Job No.", TimeSheetDetail."Job No.");
        // JobJnlLine."Source Code" := JobJnlTemplate."Source Code";
        // if TimeSheetDetail."Job Task No." <> '' then
        //     JobJnlLine.Validate("Job Task No.", TimeSheetDetail."Job Task No.");
        // JobJnlLine.Validate(Type, JobJnlLine.Type::Resource);
        // JobJnlLine.Validate("No.", TimeSheetHeader."Resource No.");
        // if TempTimeSheetLine."Work Type Code" <> '' then
        //     JobJnlLine.Validate("Work Type Code", TempTimeSheetLine."Work Type Code");
        // JobJnlLine.Validate("Posting Date", TimeSheetDetail.Date);
        // JobJnlLine."Document No." := NextDocNo;
        // NextDocNo := IncStr(NextDocNo);
        // JobJnlLine."Posting No. Series" := JobJnlBatch."Posting No. Series";
        // JobJnlLine.Description := TempTimeSheetLine.Description;
        // JobJnlLine.Validate(Quantity, QtyToPost);
        // JobJnlLine.Validate(Chargeable, TempTimeSheetLine.Chargeable);
        // JobJnlLine."Reason Code" := JobJnlBatch."Reason Code";
        // OnAfterTransferTimeSheetDetailToJobJnlLine(JobJnlLine, JobJnlTemplate, TempTimeSheetLine, TimeSheetDetail, JobJnlBatch, LineNo);
        // JobJnlLine.Insert();

        //  JobJnlPostBatch: Codeunit "Job Jnl.-Post Batch";
        // JobJnlPostBatch.SetSuppressCommit(true);
        // if not JobJnlPostBatch.Run(JobJnlLine) then
        // Error();
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

    procedure SetFetchAllProductData(JobTypeP: Code[20])
    begin
        this.JobType := JobTypeP;
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
