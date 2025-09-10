codeunit 66002 "Cron Job Mgmt."
{
    procedure CreateItemFromLRIProduct()
    var
        IntegrationDataLog: Record "Integration Data Log";
        LRIItem: Record "LRI Item";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '%1 item created', Comment = '%1';
        FailedCommentTxt: Label '%1 item not created. ', Comment = '%1';
    begin
        LRIItem.SetRange("Is Active", true);
        LRIItem.SetRange("Processed", false);
        if LRIItem.FindSet() then
            repeat
                Clear(IntegrationDataMgmt);
                IntegrationDataMgmt.SetItemData(LRIItem, Format(IntegrationDataType::"Create Item"));
                if not IntegrationDataMgmt.Run() then begin
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Create Item"), LRIItem."Product Id", IntegrationDataLog."Record ID", StrSubstNo(FailedCommentTxt, 1) + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Create Item");
                    if GuiAllowed then
                        Message(GetLastErrorText());
                end else begin
                    LRIItem.Validate(Processed, true);
                    LRIItem.Modify();
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Create Item"), LRIItem."Product Id", IntegrationDataLog."Record ID", StrSubstNo(SuccessCommentTxt, 1), IntegrationDataLog."Integration Data Type"::Information);
                end;
                Commit();
            until LRIItem.Next() = 0;
    end;

    procedure PushSingleSalesOrderToLRI(var SalesHeader: Record "Sales Header")
    var
        IntegrationDataLog: Record "Integration Data Log";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '%1 Order pushed to LRI', Comment = '%1';
        FailedCommentTxt: Label '%1 Order not pushed to LRI. ', Comment = '%1';
    begin
        IntegrationDataMgmt.SetSalesOrderData(SalesHeader, Format(IntegrationDataType::"Push Order"));
        if not IntegrationDataMgmt.Run() then begin
            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Push Order"), SalesHeader."No.", IntegrationDataLog."Record ID", StrSubstNo(FailedCommentTxt, 1) + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Push Order");
            if GuiAllowed then
                Message(GetLastErrorText());
        end else begin
            SalesHeader."Sent To LRI" := true;
            SalesHeader.Modify();
            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Push Order"), SalesHeader."No.", IntegrationDataLog."Record ID", StrSubstNo(SuccessCommentTxt, 1), IntegrationDataLog."Integration Data Type"::Information);
        end;
    end;
}
