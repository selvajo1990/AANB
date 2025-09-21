codeunit 66002 "Cron Job Mgmt."
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        case Rec."Parameter String" of
            'CreateAllItemFromLRIProduct':
                this.CreateAllItemFromLRIProduct();
            'FetchAllProductFromLRI':
                this.FetchAllProductFromLRI();
            'ProcessAllMovmentJournal':
                this.ProcessAllMovmentJournal();
        end;
    end;

    procedure CreateAllItemFromLRIProduct()
    var
        AANBSetup: Record "AANB Setup";
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
                IntegrationDataMgmt.SetItemData(LRIItem, Format(IntegrationDataType::"Create Item"), AANBSetup);
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

    procedure CreateSelectedItemFromLRIProduct(var LRIItem: Record "LRI Item")
    var
        AANBSetup: Record "AANB Setup";
        IntegrationDataLog: Record "Integration Data Log";
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
                IntegrationDataMgmt.SetItemData(LRIItem, Format(IntegrationDataType::"Create Item"), AANBSetup);
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
        AANBSetup: Record "AANB Setup";
        IntegrationDataLog: Record "Integration Data Log";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '%1 order pushed', Comment = '%1';
        FailedCommentTxt: Label '%1 order not pushed. ', Comment = '%1';
    begin
        AANBSetup.Get();
        IntegrationDataMgmt.SetSalesOrderData(SalesHeader, Format(IntegrationDataType::"Push Order"), AANBSetup);
        if not IntegrationDataMgmt.Run() then begin
            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Push Order"), SalesHeader."No.", IntegrationDataLog."Record ID", StrSubstNo(FailedCommentTxt, 1) + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Push Order");
            Commit();
            if GuiAllowed then
                Error(GetLastErrorText());
        end else begin
            SalesHeader."Sent To LRI" := true;
            SalesHeader.Modify();
            Commit();
            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Push Order"), SalesHeader."No.", IntegrationDataLog."Record ID", StrSubstNo(SuccessCommentTxt, 1), IntegrationDataLog."Integration Data Type"::Information);
            Commit();
        end;
    end;

    procedure FetchAllProductFromLRI()
    var
        AANBSetup: Record "AANB Setup";
        IntegrationDataLog: Record "Integration Data Log";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '%1 order pushed', Comment = '%1';
        FailedCommentTxt: Label '%1 order not pushed. ', Comment = '%1';
    begin
        AANBSetup.Get();
        IntegrationDataMgmt.SetFetchAllProductData(Format(IntegrationDataType::"Fetch Item"), AANBSetup);
        if not IntegrationDataMgmt.Run() then begin
            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Fetch Item"), '', IntegrationDataLog."Record ID", StrSubstNo(FailedCommentTxt, 1) + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Fetch Item");
            if GuiAllowed then
                Message(GetLastErrorText());
        end else
            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Fetch Item"), '', IntegrationDataLog."Record ID", StrSubstNo(SuccessCommentTxt, 1), IntegrationDataLog."Integration Data Type"::Information);
    end;

    procedure ProcessSelectedMovmentJournal(var LRIStockMovement: Record "LRI Stock Movement")
    var
        IntegrationDataLog: Record "Integration Data Log";
        AANBSetup: Record "AANB Setup";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '1 item posted';
        FailedCommentTxt: Label '1 item not posted. ';
    begin
        AANBSetup.Get();
        LRIStockMovement.SetRange("Processed", false);
        if LRIStockMovement.FindSet() then
            repeat
                ClearLastError();
                Clear(IntegrationDataMgmt);
                IntegrationDataMgmt.SetJournalData(LRIStockMovement, Format(IntegrationDataType::"Post Movement"), AANBSetup);
                if not IntegrationDataMgmt.Run() then begin
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), LRIStockMovement."Product Id", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Movement");
                    if GuiAllowed then
                        Message(GetLastErrorText());
                end else begin
                    LRIStockMovement.Validate(Processed, true);
                    LRIStockMovement.Modify();
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), LRIStockMovement."Product Id", IntegrationDataLog."Record ID", SuccessCommentTxt, IntegrationDataLog."Integration Data Type"::Information);
                end;
                Commit();
            until LRIStockMovement.Next() = 0;
    end;

    procedure ProcessAllMovmentJournal()
    var
        AANBSetup: Record "AANB Setup";
        LRIStockMovement: Record "LRI Stock Movement";
        IntegrationDataLog: Record "Integration Data Log";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '1 item posted';
        FailedCommentTxt: Label '1 item not posted. ';
    begin
        AANBSetup.Get();
        LRIStockMovement.SetRange("Processed", false);
        if LRIStockMovement.FindSet() then
            repeat
                ClearLastError();
                Clear(IntegrationDataMgmt);
                IntegrationDataMgmt.SetJournalData(LRIStockMovement, Format(IntegrationDataType::"Post Movement"), AANBSetup);
                if not IntegrationDataMgmt.Run() then begin
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), LRIStockMovement."Product Id", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Movement");
                    if GuiAllowed then
                        Message(GetLastErrorText());
                end else begin
                    LRIStockMovement.Validate(Processed, true);
                    LRIStockMovement.Modify();
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), LRIStockMovement."Product Id", IntegrationDataLog."Record ID", SuccessCommentTxt, IntegrationDataLog."Integration Data Type"::Information);
                end;
                Commit();
            until LRIStockMovement.Next() = 0;
    end;
}
