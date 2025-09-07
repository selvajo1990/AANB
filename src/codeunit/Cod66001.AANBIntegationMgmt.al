codeunit 66001 "AANB Integation Mgmt."
{
    procedure stockMovementTransaction(request: Text) response: Text
    var
        LRIStockMovement: Record "LRI Stock Movement";
        Item: Record Item;
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        Counter: Integer;
        StocksAddedTxt: Label 'Stocks added successfully!';
    begin
        JObject.ReadFrom(request);
        JObject.SelectToken('details', JToken);

        JArray := JToken.AsArray();

        for Counter := 0 to JArray.Count() - 1 do begin
            JArray.Get(Counter, JToken);

            LRIStockMovement.Init();
            LRIStockMovement."Document No." := this.CodeValue('documentNo', JToken);
            LRIStockMovement."Product Id" := this.CodeValue('productId', JToken);
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
            else
                LRIStockMovement.Modify(true);
        end;
        exit(StocksAddedTxt);
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
