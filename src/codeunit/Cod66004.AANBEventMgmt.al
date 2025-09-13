codeunit 66004 "AANB Event Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure ReleaseSalesDocument_OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
    begin
        if SalesHeader."Order Type" <> SalesHeader."Order Type"::B2B then
            exit;
        this.CronJobMgmt.PushSingleSalesOrderToLRI(SalesHeader);
        this.SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        this.SalesLine.SetRange("Document No.", SalesHeader."No.");
        if this.SalesLine.FindSet() then
            repeat
                if this.Item.Get(this.SalesLine."No.") then
                    if this.SalesLine.Quantity <> this.Item."Qty. on Sales Order" then begin
                        this.Temperrors.ID := this.Temperrors.ID + 1;
                        this.Temperrors.Message := GetLastErrorText();
                        this.Temperrors.Insert();
                    end;
                if HasCollectedErrors then
                    foreach error in system.GetCollectedErrors() do begin
                        this.Temperrors.ID := this.Temperrors.ID + 1;
                        this.Temperrors.Message := this.error.Message;
                        this.Temperrors.Validate("Record ID", this.error.RecordId);
                        this.Temperrors.Insert();
                    end;
                ClearCollectedErrors();

                page.RunModal(page::"Error Messages", this.Temperrors);
            until this.SalesLine.Next() = 0;

    end;

    // [ErrorBehavior(ErrorBehavior::Collect)]
    // procedure PostWithErrorCollectCustomUI()

    // begin
    //     if not Codeunit.Run(Codeunit::"AANB Event Mgmt.") then begin

    //         this.Temperrors.ID := this.Temperrors.ID + 1;
    //         this.Temperrors.Message := GetLastErrorText();
    //         this.Temperrors.Insert();
    //     end;
    //     if HasCollectedErrors then
    //         foreach error in system.GetCollectedErrors() do begin
    //             this.Temperrors.ID := this.Temperrors.ID + 1;
    //             this.Temperrors.Message := this.error.Message;
    //             this.Temperrors.Validate("Record ID", this.error.RecordId);
    //             this.Temperrors.Insert();
    //         end;
    //     ClearCollectedErrors();

    //     page.RunModal(page::"Error Messages", this.Temperrors);
    // end;

    var
        SalesLine: Record "Sales Line";
        Temperrors: Record "Error Message" temporary;
        Item: Record Item;
        CronJobMgmt: Codeunit "Cron Job Mgmt.";
        error: ErrorInfo;


}
