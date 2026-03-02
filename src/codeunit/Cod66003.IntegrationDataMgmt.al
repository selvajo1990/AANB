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
            Format(IntegrationDataTypeL::"Post Movement"):
                this.PostMovementJournal();
            Format(IntegrationDataTypeL::"Post Sales"):
                this.PostSalesJournal();

        end;
    end;

    procedure CreateItemFromStaging()
    var
        ItemL: Record Item;
        ItemRef: RecordRef;
    begin
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

    procedure PushSalesOrderToLRI()
    var
        SalesLine: Record "Sales Line";
        APITemplateSetup: Record "API Template Setup";
        SalesHeaderObject: JsonObject;
        SalesLineObject: JsonObject;
        DeliveryAddressObject: JsonObject;
        BillingAddressObject: JsonObject;
        JArray: JsonArray;
        CommentsArray: JsonArray;
        JToken: JsonToken;
        JObject: JsonObject;
        OrderObject: JsonObject;
        OrderToken: JsonToken;
        OrderId: Text[35];
    begin
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
        SalesHeaderObject.Add('carrier_code', this.SalesHeader."Shipping Agent Code");
        SalesHeaderObject.Add('priority', this.SalesHeader.Priority.AsInteger());
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

        Clear(CommentsArray);
        CommentsArray.Add(this.SalesHeader.GetWorkDescription());
        SalesHeaderObject.Add('comments', CommentsArray);

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

            Clear(OrderObject);
            OrderObject.ReadFrom(this.Response);

            if OrderObject.Get('orderId', OrderToken) then begin
                OrderId := CopyStr(OrderToken.AsValue().AsText(), 1, MaxStrLen(OrderId));

                this.SalesHeader.Validate("External Document No.", OrderId);
                this.SalesHeader.Modify();
            end;

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
    var
        LastItemJournalLine: Record "Item Journal Line";
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalEntryType: Enum "Item Journal Entry Type";
        TemplateName: Code[10];
        BatchName: Code[10];
    begin
        case this.LRIStockMovement."Entry Type" of
            this.LRIStockMovement."Entry Type"::Purchase:
                begin
                    this.AANBSetup.TestField("Purchase Template Name");
                    this.AANBSetup.TestField("Purchase Batch Name");

                    ItemJournalEntryType := "Item Ledger Entry Type"::Purchase;

                    TemplateName := this.AANBSetup."Purchase Template Name";
                    BatchName := this.AANBSetup."Purchase Batch Name";
                end;
            this.LRIStockMovement."Entry Type"::"Purchase Return":
                begin
                    this.AANBSetup.TestField("Purchase Return Template Name");
                    this.AANBSetup.TestField("Purchase Return Batch Name");

                    ItemJournalEntryType := "Item Ledger Entry Type"::"Negative Adjmt.";

                    TemplateName := this.AANBSetup."Purchase Return Template Name";
                    BatchName := this.AANBSetup."Purchase Return Batch Name";
                end;
            this.LRIStockMovement."Entry Type"::Sales:
                begin
                    this.AANBSetup.TestField("Sales Template Name");
                    this.AANBSetup.TestField("Sales Batch Name");

                    ItemJournalEntryType := "Item Ledger Entry Type"::Sale;

                    TemplateName := this.AANBSetup."Sales Template Name";
                    BatchName := this.AANBSetup."Sales Batch Name";
                end;
            this.LRIStockMovement."Entry Type"::"Sales Return":
                begin
                    this.AANBSetup.TestField("Sales Return Template Name");
                    this.AANBSetup.TestField("Sales Return Batch Name");

                    ItemJournalEntryType := "Item Ledger Entry Type"::"Positive Adjmt.";

                    TemplateName := this.AANBSetup."Sales Return Template Name";
                    BatchName := this.AANBSetup."Sales Return Batch Name";
                end;
        end;

        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.DeleteAll();

        LastItemJournalLine."Journal Template Name" := TemplateName;
        LastItemJournalLine."Journal Batch Name" := BatchName;
        LastItemJournalLine."Entry Type" := ItemJournalEntryType;

        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", TemplateName);
        ItemJournalLine.Validate("Journal Batch Name", BatchName);
        ItemJournalLine.SetUpNewLine(LastItemJournalLine);
        ItemJournalLine."Line No." := 10000;
        ItemJournalLine.Validate("Entry Type", ItemJournalEntryType);
        ItemJournalLine."Document No." := CopyStr(this.LRIStockMovement."Document No.", 1, MaxStrLen(ItemJournalLine."Document No."));
        ItemJournalLine."External Document No." := CopyStr(this.LRIStockMovement."Document No.", 1, MaxStrLen(ItemJournalLine."External Document No."));
        ItemJournalLine.Validate("Posting Date", this.LRIStockMovement."Entry Date");
        ItemJournalLine.Validate("Item No.", this.LRIStockMovement."Product Id");

        if ItemJournalLine.Description = '' then
            ItemJournalLine.Description := this.LRIStockMovement.Description;
        ItemJournalLine.Validate("Location Code", this.LRIStockMovement."Location Code");
        ItemJournalLine.Validate(Quantity, this.LRIStockMovement.Qty);

        this.LRIStockMovement.TestField(Price);
        ItemJournalLine.Validate("Unit Amount", this.LRIStockMovement.Price);
        ItemJournalLine.Insert();

        ItemJnlPostBatch.SetSuppressCommit(true);
        ItemJnlPostBatch.Run(ItemJournalLine);

        if GetLastErrorText() > '' then
            Error(GetLastErrorText());
    end;

    procedure PostSalesJournal()
    var
        LastGenJournalLine: Record "Gen. Journal Line";
        LastGenJournalLinePayment: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        TemplateName: Code[10];
        BatchName: Code[10];
        OrderOrRefundNo: Code[20];
        PostingDate: Date;
    begin
        this.AANBSetup.TestField("D Bal. VAT Prod. Posting Group");
        VATPostingSetup.Get(this.WooCommerceOrderDetail."Country Code", this.AANBSetup."D Bal. VAT Prod. Posting Group");

        if this.IsReturn then begin
            this.AANBSetup.TestField("Woo-Sales Return Template Name");
            this.AANBSetup.TestField("Woo-Sales Return Batch Name");
            TemplateName := this.AANBSetup."Woo-Sales Return Template Name";
            BatchName := this.AANBSetup."Woo-Sales Return Batch Name";
        end else begin
            this.AANBSetup.TestField("Woo-Sales Template Name");
            this.AANBSetup.TestField("Woo-Sales Batch Name");
            TemplateName := this.AANBSetup."Woo-Sales Template Name";
            BatchName := this.AANBSetup."Woo-Sales Batch Name";
        end;

        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        GenJournalLine.DeleteAll();

        LastGenJournalLine."Journal Template Name" := TemplateName;
        LastGenJournalLine."Journal Batch Name" := BatchName;
        if this.IsReturn then begin
            LastGenJournalLine."Document Type" := "Gen. Journal Document Type"::"Credit Memo";
            PostingDate := this.WooCommerceOrderDetail."Credit Note Date";
            OrderOrRefundNo := this.WooCommerceOrderDetail."Credit Note No.";
        end else begin
            LastGenJournalLine."Document Type" := "Gen. Journal Document Type"::Invoice;
            PostingDate := this.WooCommerceOrderDetail."Invoice Date";
            OrderOrRefundNo := this.WooCommerceOrderDetail."Invoice No.";
        end;

        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", TemplateName);
        GenJournalLine.Validate("Journal Batch Name", BatchName);
        GenJournalLine.SetUpNewLine(LastGenJournalLine, 0, true);
        GenJournalLine."Line No." := 10000;

        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine."Document No." := OrderOrRefundNo;
        GenJournalLine."External Document No." := OrderOrRefundNo;
        GenJournalLine.Validate("Account Type", "Gen. Journal Account Type"::Customer);
        GenJournalLine.Validate("Account No.", this.AANBSetup."Default B2C Customer");
        GenJournalLine.Description := this.Customer.Name;
        if this.IsReturn then
            GenJournalLine.Amount := -this.WooCommerceOrderDetail."Amount Incl VAT"
        else
            GenJournalLine.Amount := this.WooCommerceOrderDetail."Amount Incl VAT";
        GenJournalLine.Validate("Bal. Account Type", "Gen. Journal Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", this.AANBSetup."B2C Cust. Bal. Account No.");
        GenJournalLine.Validate("Posting Group", this.Customer."Customer Posting Group");
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", this.WooCommerceOrderDetail."Country Code");
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", this.AANBSetup."D Bal. VAT Prod. Posting Group");
        GenJournalLine.Insert();

        LastGenJournalLinePayment."Journal Template Name" := TemplateName;
        LastGenJournalLinePayment."Journal Batch Name" := BatchName;
        if this.IsReturn then
            LastGenJournalLinePayment."Document Type" := "Gen. Journal Document Type"::Refund
        else
            LastGenJournalLinePayment."Document Type" := "Gen. Journal Document Type"::Payment;

        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", TemplateName);
        GenJournalLine.Validate("Journal Batch Name", BatchName);
        GenJournalLine.SetUpNewLine(LastGenJournalLinePayment, 0, true);
        GenJournalLine."Line No." := 20000;
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine."Document No." := OrderOrRefundNo;
        GenJournalLine."External Document No." := OrderOrRefundNo;
        GenJournalLine.Validate("Account Type", "Gen. Journal Account Type"::Customer);
        GenJournalLine.Validate("Account No.", this.AANBSetup."Default B2C Customer");
        GenJournalLine.Description := this.Customer.Name;
        if this.IsReturn then
            GenJournalLine.Amount := this.WooCommerceOrderDetail."Amount Incl VAT"
        else
            GenJournalLine.Amount := -this.WooCommerceOrderDetail."Amount Incl VAT";
        GenJournalLine.Validate("Bal. Account Type", "Gen. Journal Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", this.AANBSetup."B2C Cust. Pay Bal.Acct No.");
        GenJournalLine.Validate("Posting Group", this.Customer."Customer Posting Group");
        GenJournalLine.Insert();

        if not this.AANBSetup."Skip Sales Journal Posting" then begin
            GenJnlPostBatch.SetSuppressCommit(true);
            GenJnlPostBatch.Run(GenJournalLine);
        end;

        if GetLastErrorText() > '' then
            Error(GetLastErrorText());
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

    procedure SetItemData(LRIItemP: Record "LRI Item"; JobTypeP: Code[20]; AANBSetupP: Record "AANB Setup")
    begin
        this.JobType := JobTypeP;
        this.LRIItem := LRIItemP;
        this.AANBSetup := AANBSetupP;
    end;

    procedure SetSalesOrderData(SalesHeaderP: Record "Sales Header"; JobTypeP: Code[20]; AANBSetupP: Record "AANB Setup")
    begin
        this.JobType := JobTypeP;
        this.SalesHeader := SalesHeaderP;
        this.AANBSetup := AANBSetupP;
    end;

    procedure SetJournalData(LRIStockMovementp: Record "LRI Stock Movement"; JobTypeP: Code[20]; AANBSetupP: Record "AANB Setup")
    begin
        this.JobType := JobTypeP;
        this.LRIStockMovement := LRIStockMovementp;
        this.AANBSetup := AANBSetupP;
    end;

    procedure SetFetchAllProductData(JobTypeP: Code[20]; AANBSetupP: Record "AANB Setup")
    begin
        this.JobType := JobTypeP;
        this.AANBSetup := AANBSetupP;
    end;

    procedure SetSalesJournalData(WooCommerceOrderDetailP: Record "Woo Commerce Order Detail"; JobTypeP: Code[20]; AANBSetupP: Record "AANB Setup"; CustomerP: Record Customer; IsReturnP: Boolean)
    begin
        this.JobType := JobTypeP;
        this.WooCommerceOrderDetail := WooCommerceOrderDetailP;
        this.AANBSetup := AANBSetupP;
        this.Customer := CustomerP;
        this.IsReturn := IsReturnP;
    end;

    var
        ConfigTemplateHeader: Record "Config. Template Header";
        AANBSetup: Record "AANB Setup";
        LRIItem: Record "LRI Item";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        LRIStockMovement: Record "LRI Stock Movement";
        TransactionLog: Record "API Transaction Log";
        WooCommerceOrderDetail: Record "Woo Commerce Order Detail";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        AANBIntegationMgmt: Codeunit "AANB Integation Mgmt.";
        EntryNo: BigInteger;
        Request, Response : Text;
        IsReturn: Boolean;
        Content: HttpContent;
        Client: HttpClient;
        Header: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        JobType: Code[20];
}
