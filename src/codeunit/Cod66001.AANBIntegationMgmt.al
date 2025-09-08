codeunit 66001 "AANB Integation Mgmt."
{
    procedure stockMovementTransaction(request: Text) response: Text
    var
        LRIStockMovement: Record "LRI Stock Movement";
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        Counter: Integer;
        StocksAddedTxt: Label 'Transactions added successfully!';
        TransactionAlreadyProcessedErr: Label 'Transaction posted in ERP for %1: %2, %3: %4. You are not allowed to change.', Comment = '%1,%2,%3,%4';
    begin
        JObject.ReadFrom(request);
        JObject.SelectToken('details', JToken);

        JArray := JToken.AsArray();

        for Counter := 0 to JArray.Count() - 1 do begin
            JArray.Get(Counter, JToken);

            LRIStockMovement.Init();
            LRIStockMovement."Document No." := CopyStr(this.CodeValue('documentNo', JToken), 1, MaxStrLen(LRIStockMovement."Document No."));
            LRIStockMovement."Product Id" := CopyStr(this.CodeValue('productId', JToken), 1, MaxStrLen(LRIStockMovement."Product Id"));
            LRIStockMovement.Description := CopyStr(this.TextValueMaximum('description', JToken), 1, MaxStrLen(LRIStockMovement.Description));
            LRIStockMovement.Qty := this.DecimalValue('qty', JToken);
            LRIStockMovement.Price := this.DecimalValue('price', JToken);
            LRIStockMovement."Total Amount" := this.DecimalValue('totalAmount', JToken);
            LRIStockMovement."Total VAT Amount" := this.DecimalValue('totalVATAmount', JToken);
            LRIStockMovement."Entry Type" := this.EntryTypeEnum('entryType', JToken);
            LRIStockMovement."Entry Date" := this.DateValue('entryDate', JToken);
            LRIStockMovement."Entry Time" := this.TimeValue('entryTime', JToken);
            LRIStockMovement."Location Code" := CopyStr(this.TextValueMaximum('locationCode', JToken), 1, MaxStrLen(LRIStockMovement."Location Code"));
            LRIStockMovement."Reason Code" := CopyStr(this.TextValueMaximum('reasonCode', JToken), 1, MaxStrLen(LRIStockMovement."Reason Code"));
            LRIStockMovement."Reason Description" := CopyStr(this.TextValueMaximum('reasonDescription', JToken), 1, MaxStrLen(LRIStockMovement."Reason Description"));
            LRIStockMovement.SetRecFilter();
            if LRIStockMovement.IsEmpty() then
                LRIStockMovement.Insert(true)
            else begin
                LRIStockMovement.FindFirst();
                if not LRIStockMovement.Processed then
                    LRIStockMovement.Modify(true)
                else
                    Error(TransactionAlreadyProcessedErr, LRIStockMovement.FieldCaption("Document No."), LRIStockMovement."Document No.", LRIStockMovement.FieldCaption("Entry Type"), LRIStockMovement."Entry Type");
            end;
        end;
        exit(StocksAddedTxt);
    end;

    procedure CreateJSONOrder(salesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        AANBSetup: Record "AANB Setup";
        HeaderJsonObj: JsonObject;
        LinesJsonObj: JsonObject;
        DeliveryAddressJsonObj: JsonObject;
        BillingAddressJsonObj: JsonObject;
        JsonArray: JsonArray;
        Request: Text;
    begin
        AANBSetup.Get();
        HeaderJsonObj.Add('rcb', '312');
        HeaderJsonObj.Add('order_ref', salesHeader."No.");
        HeaderJsonObj.Add('carrier_code', '');
        HeaderJsonObj.Add('ttc', '');
        HeaderJsonObj.Add('cash_on_delivery', '');
        HeaderJsonObj.Add('b2b', '');
        HeaderJsonObj.Add('order_date', salesHeader."Order Date");
        DeliveryAddressJsonObj.Add('relay_point', '');
        DeliveryAddressJsonObj.Add('delivery_firstname', salesHeader."Ship-to Name");
        DeliveryAddressJsonObj.Add('delivery_lastname', salesHeader."Ship-to Name 2");
        DeliveryAddressJsonObj.Add('delivery_company', '');
        DeliveryAddressJsonObj.Add('delivery_address1', salesHeader."Ship-to Address");
        DeliveryAddressJsonObj.Add('delivery_address2', salesHeader."Ship-to Address 2");
        DeliveryAddressJsonObj.Add('delivery_address3', '');
        DeliveryAddressJsonObj.Add('delivery_city', salesHeader."Ship-to City");
        DeliveryAddressJsonObj.Add('delivery_postcode', salesHeader."Ship-to Post Code");
        DeliveryAddressJsonObj.Add('delivery_region', salesHeader."Ship-to Country/Region Code");
        DeliveryAddressJsonObj.Add('delivery_country_iso', salesHeader."Ship-to County");
        DeliveryAddressJsonObj.Add('delivery_phone', salesHeader."Ship-to Phone No.");
        DeliveryAddressJsonObj.Add('delivery_email', '');
        HeaderJsonObj.Add('delivery_address', DeliveryAddressJsonObj);
        BillingAddressJsonObj.Add('relay_point', '');
        BillingAddressJsonObj.Add('billing_firstname', salesHeader."Sell-to Customer Name");
        BillingAddressJsonObj.Add('billing_lastname', salesHeader."Sell-to Customer Name 2");
        BillingAddressJsonObj.Add('billing_company', '');
        BillingAddressJsonObj.Add('billing_address1', salesHeader."Sell-to Address");
        BillingAddressJsonObj.Add('billing_address2', salesHeader."Sell-to Address 2");
        BillingAddressJsonObj.Add('billing_address3', '');
        BillingAddressJsonObj.Add('billing_city', salesHeader."Sell-to City");
        BillingAddressJsonObj.Add('billing_postcode', salesHeader."Sell-to Post Code");
        BillingAddressJsonObj.Add('billing_region', salesHeader."Sell-to Country/Region Code");
        BillingAddressJsonObj.Add('billing_country_iso', salesHeader."Sell-to County");
        BillingAddressJsonObj.Add('billing_phone', salesHeader."Sell-to Phone No.");
        BillingAddressJsonObj.Add('billing_email', salesHeader."Sell-to E-Mail");
        HeaderJsonObj.Add('billing_address', BillingAddressJsonObj);
        SalesLine.SetRange("Document Type", salesHeader."Document Type");
        SalesLine.SetRange("Document No.", salesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                Clear(LinesJsonObj);
                LinesJsonObj.Add('product_ref', SalesLine."No.");
                LinesJsonObj.Add('product_name', SalesLine.Description);
                LinesJsonObj.Add('quantity', SalesLine.Quantity);
                JsonArray.Add(LinesJsonObj);
            until SalesLine.Next() = 0;
        HeaderJsonObj.Add('items', JsonArray);
        HeaderJsonObj.WriteTo(Request);
        Message(Request);
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
}
