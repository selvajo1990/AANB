codeunit 66002 "Cron Job Mgmt."
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        LRIStockMovement: Record "LRI Stock Movement";
        FetchWooCommerceOrders: Codeunit "Fetch Woo Commerce Orders";
    begin
        case Rec."Parameter String" of
            'OrderFetchFromWoocommerce':
                FetchWooCommerceOrders.FetchOrderFromWoocommerce();
            'CreateAllItemFromLRIProduct':
                this.CreateAllItemFromLRIProduct();
            'FetchAllProductFromLRI':
                this.FetchAllProductFromLRI();
            'ProcessAllMovmentJournal':
                this.ProcessSelectedMovmentJournal(LRIStockMovement);
            'ProcessAllSalesJournal':
                this.ProcessAllSalesJournal();

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
        AANBSetup.Get();
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
        AANBSetup.Get();
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
            SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
            SalesHeader."Sent To LRI" := true;
            SalesHeader.Modify();
            Commit();
            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Push Order"), SalesHeader."No.", IntegrationDataLog."Record ID", StrSubstNo(SuccessCommentTxt, 1), IntegrationDataLog."Integration Data Type"::Information);
            Commit();
        end;
    end;

    procedure ProcessSelectedMovmentJournal(var LRIStockMovement: Record "LRI Stock Movement")
    var
        IntegrationDataLog: Record "Integration Data Log";
        SalesandReceivablesSetup: Record "Sales & Receivables Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LRIStockMovement2: Record "LRI Stock Movement";
        LRIStockMovement3: Record "LRI Stock Movement";
        AANBSetup: Record "AANB Setup";
        CopySalesDocument: Report "Copy Sales Document";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        NoSeries: Codeunit "No. Series";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        SalesPost: Codeunit "Sales-Post";
        DocType: Enum "Sales Document Type From";
        IntegrationDataType: Enum "Integration Data Type";
        xReferenceOrderNo: Text[20];
        SuccessCommentTxt: Label '1 journal line posted';
        FailedCommentTxt: Label '1 journal line not posted. ';
        ItemToReturn: Text;
        OrderNotPostedErr: Label 'Order needs to be closed before proceeding with return.❌';
    begin
        LRIStockMovement3.SetRange("Is Validated", false);
        LRIStockMovement3.SetFilter("Entry Type", '%1|%2', LRIStockMovement3."Entry Type"::Sales, LRIStockMovement3."Entry Type"::"Sales Return");
        if LRIStockMovement3.FindSet() then
            repeat
                if SalesHeader.Get(SalesHeader."Document Type"::Order, LRIStockMovement3."Reference Order No.") then
                    LRIStockMovement3."Is B2B" := true;

                if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", LRIStockMovement3."Reference Order No.") then
                    LRIStockMovement3."Is B2B" := true;

                if LRIStockMovement3."Is B2B" then
                    LRIStockMovement3.Modify();

                LRIStockMovement3."Is Validated" := true;
                LRIStockMovement3.Modify();
            until LRIStockMovement3.Next() = 0;
        Commit();

        Clear(xReferenceOrderNo);
        AANBSetup.Get();
        LRIStockMovement.SetRange("Processed", false);
        LRIStockMovement.SetRange("Entry Type");
        LRIStockMovement.SetRange("Is B2B", false);
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

        LRIStockMovement.SetCurrentKey("Reference Order No.");
        LRIStockMovement.SetRange("Is B2B", true);
        LRIStockMovement.SetRange("Entry Type", LRIStockMovement."Entry Type"::Sales);
        if LRIStockMovement.FindSet() then
            repeat
                if LRIStockMovement."Reference Order No." <> xReferenceOrderNo then
                    if SalesHeader.Get(SalesHeader."Document Type"::Order, LRIStockMovement."Reference Order No.") then begin
                        SalesHeader.SetHideValidationDialog(true);
                        SalesHeader.Ship := true;
                        SalesHeader.Invoice := true;
                        SalesHeader.Validate("Posting Date", LRIStockMovement."Entry Date");
                        SalesHeader.Modify();
                        Commit();
                        Clear(SalesPost);
                        SalesPost.SetPostingFlags(SalesHeader);
                        SalesPost.SetSuppressCommit(true);
                        if not SalesPost.Run(SalesHeader) then begin
                            IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), SalesHeader."No.", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Movement");
                            if GuiAllowed then
                                Message(GetLastErrorText());
                        end else begin
                            // Processed - OnValidate
                            LRIStockMovement2.SetRange("Reference Order No.", LRIStockMovement."Reference Order No.");
                            if LRIStockMovement2.FindSet() then
                                repeat
                                    LRIStockMovement2.Validate(Processed, true);
                                    LRIStockMovement2.Modify();
                                until LRIStockMovement2.Next() = 0;
                        end;
                        Commit();
                    end;
                xReferenceOrderNo := LRIStockMovement."Reference Order No.";
            until LRIStockMovement.Next() = 0;

        Clear(xReferenceOrderNo);
        Clear(SalesHeader);
        Clear(LRIStockMovement3);
        LRIStockMovement.SetCurrentKey("Reference Order No.");
        LRIStockMovement.SetRange("Is B2B", true);
        LRIStockMovement.SetRange("Entry Type", LRIStockMovement."Entry Type"::"Sales Return");
        if LRIStockMovement.FindSet() then
            repeat
                if LRIStockMovement."Reference Order No." <> xReferenceOrderNo then begin
                    SalesInvoiceHeader.SetCurrentKey("Order No.");
                    SalesInvoiceHeader.SetRange("Order No.", LRIStockMovement."Reference Order No.");
                    if not SalesInvoiceHeader.FindFirst() then
                        Error(OrderNotPostedErr);

                    SalesHeader.Init();
                    SalesHeader.SetHideValidationDialog(true);
                    SalesHeader.TransferFields(SalesInvoiceHeader);
                    SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
                    SalesHeader.Validate("Order Date", LRIStockMovement."Entry Date");
                    SalesHeader.Validate("Posting Date", LRIStockMovement."Entry Date");
                    SalesHeader."External Document No." := CopyStr(LRIStockMovement."Reference Order No.", 1, 35);
                    SalesHeader."No." := NoSeries.GetNextNo(SalesandReceivablesSetup."Return Order Nos.", 0D, true);
                    // SalesHeader."Posting No. Series" := NoSeries.GetNextNo(SalesandReceivablesSetup."Posted Credit Memo Nos.", 0D, true);
                    //SalesHeader."Posting No." := NoSeries.GetNextNo(SalesandReceivablesSetup."Posted Credit Memo Nos.", 0D, true);
                    SalesHeader."Your Reference" := LRIStockMovement."Reference Order No.";
                    SalesHeader.Insert(true);

                    Clear(CopySalesDocument);
                    CopySalesDocument.UseRequestPage(false);
                    CopySalesDocument.SetSalesHeader(SalesHeader);
                    CopySalesDocument.SetParameters(DocType::"Posted Invoice", SalesInvoiceHeader."No.", true, false);
                    CopySalesDocument.Run();

                    LRIStockMovement3.SetCurrentKey("Reference Order No.");
                    LRIStockMovement3.SetRange("Reference Order No.", LRIStockMovement."Reference Order No.");
                    LRIStockMovement3.FindSet();
                    repeat
                        ItemToReturn += LRIStockMovement."Product Id";
                    until LRIStockMovement3.Next() = 0;

                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    if SalesLine.FindSet() then
                        repeat
                            if ItemToReturn.Contains(SalesLine."No.") then begin
                                LRIStockMovement3.SetRange("Product Id", SalesLine."No.");
                                LRIStockMovement3.FindFirst();
                                SalesLine.Validate("Return Qty. to Receive", LRIStockMovement3.Qty);
                            end else
                                SalesLine.Validate("Return Qty. to Receive", 0);
                            SalesLine.Modify();
                        until SalesLine.Next() = 0;

                    SalesLine.SetRange("Return Qty. to Receive", 0);
                    SalesLine.DeleteAll(true);

                    ReleaseSalesDocument.PerformManualRelease(SalesHeader);

                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    if SalesLine.FindSet() then
                        repeat
                            SalesLine.TestField("Return Qty. to Receive");
                        until SalesLine.Next() = 0;

                    SalesHeader.Receive := true;
                    SalesHeader.Invoice := true;
                    Commit();
                    Clear(SalesPost);
                    SalesPost.SetPostingFlags(SalesHeader);
                    SalesPost.SetSuppressCommit(true);
                    if not SalesPost.Run(SalesHeader) then begin
                        IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), SalesHeader."No.", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Movement");
                        if GuiAllowed then
                            Message(GetLastErrorText());
                    end else begin
                        LRIStockMovement2.SetRange("Reference Order No.", LRIStockMovement."Reference Order No.");
                        if LRIStockMovement2.FindSet() then
                            repeat
                                LRIStockMovement2.Validate(Processed, true);
                                LRIStockMovement2.Modify();
                            until LRIStockMovement2.Next() = 0;
                    end;
                    Commit();

                end;
                xReferenceOrderNo := LRIStockMovement."Reference Order No.";
            until LRIStockMovement.Next() = 0;
    end;

    // procedure ProcessAllMovmentJournal()
    // var
    //     AANBSetup: Record "AANB Setup";
    //     LRIStockMovement: Record "LRI Stock Movement";
    //     IntegrationDataLog: Record "Integration Data Log";
    //     IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
    //     IntegrationDataType: Enum "Integration Data Type";
    //     SuccessCommentTxt: Label '1 journal line posted';
    //     FailedCommentTxt: Label '1 journal line not posted. ';
    // begin
    //     AANBSetup.Get();
    //     LRIStockMovement.SetRange("Processed", false);
    //     if LRIStockMovement.FindSet() then
    //         repeat
    //             ClearLastError();
    //             Clear(IntegrationDataMgmt);
    //             IntegrationDataMgmt.SetJournalData(LRIStockMovement, Format(IntegrationDataType::"Post Movement"), AANBSetup);
    //             if not IntegrationDataMgmt.Run() then begin
    //                 IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), LRIStockMovement."Product Id", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Movement");
    //                 if GuiAllowed then
    //                     Message(GetLastErrorText());
    //             end else begin
    //                 LRIStockMovement.Validate(Processed, true);
    //                 LRIStockMovement.Modify();
    //                 IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Movement"), LRIStockMovement."Product Id", IntegrationDataLog."Record ID", SuccessCommentTxt, IntegrationDataLog."Integration Data Type"::Information);
    //             end;
    //             Commit();
    //         until LRIStockMovement.Next() = 0;
    // end;

    procedure ProcessSelectedSalesJournal(var WooCommerceOrderDetail: Record "Woo Commerce Order Detail")
    var
        AANBSetup: Record "AANB Setup";
        Customer: Record Customer;
        IntegrationDataLog: Record "Integration Data Log";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '1 journal line posted';
        FailedCommentTxt: Label '1 journal line not posted. ';
    begin
        AANBSetup.Get();
        Customer.Get(AANBSetup."Default B2C Customer");
        WooCommerceOrderDetail.SetRange("Order Processed", false);
        if WooCommerceOrderDetail.FindSet() then
            repeat
                ClearLastError();
                Clear(IntegrationDataMgmt);
                IntegrationDataMgmt.SetSalesJournalData(WooCommerceOrderDetail, Format(IntegrationDataType::"Post Sales"), AANBSetup, Customer, false);
                if not IntegrationDataMgmt.Run() then begin
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Order No.", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Sales");
                    if GuiAllowed then
                        Message(GetLastErrorText());
                end else begin
                    WooCommerceOrderDetail.Validate("Order Processed", true);
                    WooCommerceOrderDetail.Modify();
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Order No.", IntegrationDataLog."Record ID", SuccessCommentTxt, IntegrationDataLog."Integration Data Type"::Information);
                end;
                Commit();
            until WooCommerceOrderDetail.Next() = 0;

        WooCommerceOrderDetail.SetRange("Order Processed", true);
        WooCommerceOrderDetail.SetFilter("Credit Note No.", '>%1', '');
        WooCommerceOrderDetail.SetRange("Return Processed", false);
        if WooCommerceOrderDetail.FindSet() then
            repeat
                ClearLastError();
                Clear(IntegrationDataMgmt);
                IntegrationDataMgmt.SetSalesJournalData(WooCommerceOrderDetail, Format(IntegrationDataType::"Post Sales"), AANBSetup, Customer, true);
                if not IntegrationDataMgmt.Run() then begin
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Refund No.", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Sales");
                    if GuiAllowed then
                        Message(GetLastErrorText());
                end else begin
                    WooCommerceOrderDetail.Validate("Return Processed", true);
                    WooCommerceOrderDetail.Modify();
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Refund No.", IntegrationDataLog."Record ID", SuccessCommentTxt, IntegrationDataLog."Integration Data Type"::Information);
                end;
                Commit();
            until WooCommerceOrderDetail.Next() = 0;
    end;

    procedure ProcessAllSalesJournal()
    var
        AANBSetup: Record "AANB Setup";
        WooCommerceOrderDetail: Record "Woo Commerce Order Detail";
        Customer: Record Customer;
        IntegrationDataLog: Record "Integration Data Log";
        IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
        IntegrationDataType: Enum "Integration Data Type";
        SuccessCommentTxt: Label '1 journal line posted';
        FailedCommentTxt: Label '1 journal line not posted. ';
    begin
        AANBSetup.Get();
        Customer.Get(AANBSetup."Default B2C Customer");
        WooCommerceOrderDetail.SetRange("Order Processed", false);
        if WooCommerceOrderDetail.FindSet() then
            repeat
                ClearLastError();
                Clear(IntegrationDataMgmt);
                IntegrationDataMgmt.SetSalesJournalData(WooCommerceOrderDetail, Format(IntegrationDataType::"Post Sales"), AANBSetup, Customer, false);
                if not IntegrationDataMgmt.Run() then begin
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Order No.", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Sales");
                    if GuiAllowed then
                        Message(GetLastErrorText());
                end else begin
                    WooCommerceOrderDetail.Validate("Order Processed", true);
                    WooCommerceOrderDetail.Modify();
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Order No.", IntegrationDataLog."Record ID", SuccessCommentTxt, IntegrationDataLog."Integration Data Type"::Information);
                end;
                Commit();
            until WooCommerceOrderDetail.Next() = 0;

        Clear(WooCommerceOrderDetail);
        WooCommerceOrderDetail.SetRange("Order Processed", true);
        WooCommerceOrderDetail.SetFilter("Credit Note No.", '>%1', '');
        WooCommerceOrderDetail.SetRange("Return Processed", false);
        if WooCommerceOrderDetail.FindSet() then
            repeat
                ClearLastError();
                Clear(IntegrationDataMgmt);
                IntegrationDataMgmt.SetSalesJournalData(WooCommerceOrderDetail, Format(IntegrationDataType::"Post Sales"), AANBSetup, Customer, true);
                if not IntegrationDataMgmt.Run() then begin
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Refund No.", IntegrationDataLog."Record ID", FailedCommentTxt + GetLastErrorText(), IntegrationDataLog."Integration Data Type"::"Post Sales");
                    if GuiAllowed then
                        Message(GetLastErrorText());
                end else begin
                    WooCommerceOrderDetail.Validate("Return Processed", true);
                    WooCommerceOrderDetail.Modify();
                    IntegrationDataLog.InsertOperationError(Format(IntegrationDataType::"Post Sales"), WooCommerceOrderDetail."Refund No.", IntegrationDataLog."Record ID", SuccessCommentTxt, IntegrationDataLog."Integration Data Type"::Information);
                end;
                Commit();
            until WooCommerceOrderDetail.Next() = 0;
    end;

    procedure CreateSalesReturnOrder(var LRIStockMovement: Record "LRI Stock Movement")
    var
        SalesandReceivablesSetup: Record "Sales & Receivables Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LRIStockMovement3: Record "LRI Stock Movement";
        CopySalesDocument: Report "Copy Sales Document";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        NoSeries: Codeunit "No. Series";
        DocType: Enum "Sales Document Type From";
        ItemToReturn: Text;
        OrderNotPostedErr: Label 'Order needs to be closed before proceeding with return.❌';
        ReturnCreatedTxt: Label 'Return order created successfully.🆕';
        ConfirmationQst: Label 'This action send refund information to finance team💵 ,Do you want to continue?👈', Comment = '%1';
    begin
        if not Confirm(ConfirmationQst) then
            exit;
        SalesInvoiceHeader.SetCurrentKey("Order No.");
        SalesInvoiceHeader.SetRange("Order No.", LRIStockMovement."Reference Order No.");
        if not SalesInvoiceHeader.IsEmpty() then
            Error(OrderNotPostedErr);

        SalesHeader.Init();
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.TransferFields(SalesInvoiceHeader);
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader.Validate("Order Date", LRIStockMovement."Entry Date");
        SalesHeader.Validate("Posting Date", LRIStockMovement."Entry Date");
        SalesHeader."External Document No." := CopyStr(LRIStockMovement."Reference Order No.", 1, 35);
        SalesHeader."No." := NoSeries.GetNextNo(SalesandReceivablesSetup."Return Order Nos.", 0D, true);
        SalesHeader."Posting No. Series" := NoSeries.GetNextNo(SalesandReceivablesSetup."Posted Credit Memo Nos.", 0D, true);
        SalesHeader."Posting No." := NoSeries.GetNextNo(SalesandReceivablesSetup."Posted Credit Memo Nos.", 0D, true);
        SalesHeader.TestField("Posting No.");
        SalesHeader.Validate("Location Code", LRIStockMovement."Location Code");
        SalesHeader."Your Reference" := LRIStockMovement."Reference Order No.";
        SalesHeader.Insert(true);

        Clear(CopySalesDocument);
        CopySalesDocument.UseRequestPage(false);
        CopySalesDocument.SetSalesHeader(SalesHeader);
        CopySalesDocument.SetParameters(DocType::"Posted Invoice", SalesInvoiceHeader."No.", true, false);
        CopySalesDocument.Run();

        LRIStockMovement3.SetCurrentKey("Reference Order No.");
        LRIStockMovement3.SetRange("Reference Order No.", LRIStockMovement."Reference Order No.");
        LRIStockMovement3.FindSet();
        repeat
            ItemToReturn += LRIStockMovement."Product Id";
        until LRIStockMovement3.Next() = 0;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                if ItemToReturn.Contains(SalesLine."No.") then
                    SalesLine.Validate("Return Qty. to Receive", 1)
                else
                    SalesLine.Validate("Return Qty. to Receive", 0);
                SalesLine.Modify();
            until SalesLine.Next() = 0;

        SalesLine.SetRange("Return Qty. to Receive", 0);
        SalesLine.DeleteAll(true);

        ReleaseSalesDocument.PerformManualRelease(SalesHeader);

        Message(ReturnCreatedTxt);
    end;

}
