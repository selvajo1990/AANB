codeunit 66003 "Integration Data Mgmt."
{
    trigger OnRun()
    var
        IntegrationDataTypeL: Enum "Integration Data Type";
    begin

        case this.JobType of
            Format(IntegrationDataTypeL::"Create Item"):
                this.CreateItem();
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

    procedure CreateJSONOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AANBSetup: Record "AANB Setup";
        PaymentMethod: Record "Payment Method";
        SalesHeaderObject: JsonObject;
        SalesLineObject: JsonObject;
        DeliveryAddressObject: JsonObject;
        BillingAddressObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        JObject: JsonObject;
        InventoryUpdateTxt: Label '/%1', Comment = '%1';
    begin
        AANBSetup.Get();

        SalesHeader."Document Type" := "Sales Document Type"::Order;
        SalesHeader."No." := '101001';
        if PaymentMethod.Get(SalesHeader."Payment Method Code") then;
        SalesHeaderObject.Add('rcb', '312');
        SalesHeaderObject.Add('order_ref', SalesHeader."No.");
        SalesHeaderObject.Add('carrier_code', 'SURPLACE');
        SalesHeaderObject.Add('ttc', '29.99');
        SalesHeaderObject.Add('cash_on_delivery', PaymentMethod.Description);
        SalesHeaderObject.Add('b2b', 'true');
        SalesHeaderObject.Add('order_date', SalesHeader."Order Date");
        DeliveryAddressObject.Add('relay_point', '');
        DeliveryAddressObject.Add('delivery_firstname', SalesHeader."Ship-to Name");
        DeliveryAddressObject.Add('delivery_lastname', SalesHeader."Ship-to Name 2");
        DeliveryAddressObject.Add('delivery_company', '');
        DeliveryAddressObject.Add('delivery_address1', SalesHeader."Ship-to Address");
        DeliveryAddressObject.Add('delivery_address2', SalesHeader."Ship-to Address 2");
        DeliveryAddressObject.Add('delivery_address3', '');
        DeliveryAddressObject.Add('delivery_city', SalesHeader."Ship-to City");
        DeliveryAddressObject.Add('delivery_postcode', SalesHeader."Ship-to Post Code");
        DeliveryAddressObject.Add('delivery_region', SalesHeader."Ship-to Country/Region Code");
        DeliveryAddressObject.Add('delivery_country_iso', SalesHeader."Ship-to County");
        DeliveryAddressObject.Add('delivery_phone', SalesHeader."Ship-to Phone No.");
        DeliveryAddressObject.Add('delivery_email', SalesHeader."Sell-to E-Mail");
        SalesHeaderObject.Add('delivery_address', DeliveryAddressObject);
        BillingAddressObject.Add('relay_point', '');
        BillingAddressObject.Add('billing_firstname', SalesHeader."Sell-to Customer Name");
        BillingAddressObject.Add('billing_lastname', SalesHeader."Sell-to Customer Name 2");
        BillingAddressObject.Add('billing_company', '');
        BillingAddressObject.Add('billing_address1', SalesHeader."Sell-to Address");
        BillingAddressObject.Add('billing_address2', SalesHeader."Sell-to Address 2");
        BillingAddressObject.Add('billing_address3', '');
        BillingAddressObject.Add('billing_city', SalesHeader."Sell-to City");
        BillingAddressObject.Add('billing_postcode', SalesHeader."Sell-to Post Code");
        BillingAddressObject.Add('billing_region', SalesHeader."Sell-to Country/Region Code");
        BillingAddressObject.Add('billing_country_iso', SalesHeader."Sell-to County");
        BillingAddressObject.Add('billing_phone', SalesHeader."Sell-to Phone No.");
        BillingAddressObject.Add('billing_email', SalesHeader."Sell-to E-Mail");
        SalesHeaderObject.Add('billing_address', BillingAddressObject);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                Clear(SalesLineObject);
                SalesLineObject.Add('product_ref', SalesLine."No.");
                SalesLineObject.Add('product_name', SalesLine.Description);
                SalesLineObject.Add('quantity', SalesLine.Quantity);
                JArray.Add(SalesLineObject);
            until SalesLine.Next() = 0;
        SalesHeaderObject.Add('items', JArray);
        SalesHeaderObject.WriteTo(this.Request2);

        this.EntryNo := this.TransactionLog.TransactionLog(this.TransactionLog."Entry Type"::"Outgoing Request", 0,
                                                 this.TransactionLog.Status::Processed, SalesHeader."No.", this.ApiTemplateSetup, '', this.Request2);
        Commit();

        this.Content.GetHeaders(this.Header);
        this.Content.WriteFrom(this.Request2);
        this.Header.Clear();
        this.Header.Add('Content-Type', 'application/json');
        this.HttpRequest.GetHeaders(this.Header);
        this.Client.DefaultRequestHeaders.Add('X-AUTH-TOKEN', APITemplateSetup.Password);
        this.Client.Post(this.ApiTemplateSetup.EndPoint + StrSubstNo(InventoryUpdateTxt, SalesHeader."No."), this.Content, this.HttpResponse);
        if this.HttpResponse.HttpStatusCode() = 200 then begin
            this.HttpResponse.Content().ReadAs(this.Response);
            this.TransactionLog.TransactionLog(this.TransactionLog."Entry Type"::"Outgoing Response", this.EntryNo,
                                               this.TransactionLog.Status::Processed, SalesHeader."No.", this.ApiTemplateSetup, '', this.Response);
            Commit();
        end else begin
            this.HttpResponse.Content().ReadAs(this.Response);
            this.TransactionLog.TransactionLog(this.TransactionLog."Entry Type"::"Outgoing Response", this.EntryNo,
                                               this.TransactionLog.Status::Failed, SalesHeader."No.", this.ApiTemplateSetup, '', this.Response);
            Commit();
            if GuiAllowed then begin
                JObject.ReadFrom(this.Response);
                JObject.SelectToken('errors', JToken);
                JToken.WriteTo(this.Response);
                Error(this.Response);
            end;
        end;
    end;

    procedure SetItemSyncData(LRIItemP: Record "LRI Item"; JobTypeP: Code[20])
    begin
        this.JobType := JobTypeP;
        this.LRIItem := LRIItemP;
    end;

    var
        ConfigTemplateHeader: Record "Config. Template Header";
        AANBSetup: Record "AANB Setup";
        LRIItem: Record "LRI Item";
        TransactionLog: Record "API Transaction Log";
        APITemplateSetup: Record "API Template Setup";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        EntryNo: BigInteger;
        Request2: Text;
        Response: Text;
        Content: HttpContent;
        Client: HttpClient;
        Header: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        JobType: Code[20];
}
