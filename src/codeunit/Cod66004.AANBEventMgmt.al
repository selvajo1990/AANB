codeunit 66004 "AANB Event Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure ReleaseSalesDocument_OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        CronJobMgmt: Codeunit "Cron Job Mgmt.";
        ErrorInfoL: ErrorInfo;
        InventoryNotExistErr: Label 'Inventory does''t exist for item no.: %1 (Available Inventory: %2, Expected Inventory: %3)', Comment = '%1,%2,%3';
    begin
        if SalesHeader."Order Type" <> SalesHeader."Order Type"::B2B then
            exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                Item.Get(SalesLine."No.");
                Item.CalcFields(Inventory);

                if Item.Inventory < SalesLine.Quantity then begin
                    ErrorInfoL := ErrorInfo.Create(StrSubstNo(InventoryNotExistErr, SalesLine."No.", Item.Inventory, SalesLine.Quantity));
                    ErrorInfoL.ErrorType(ErrorType::Client);
                    ErrorInfoL.Verbosity(Verbosity::Error);
                    ErrorInfoL.DetailedMessage(GetLastErrorText());
                    ErrorInfoL.DataClassification(DataClassification::CustomerContent);
                    ErrorInfoL.Collectible(true);
                    Error(ErrorInfoL);
                end;
            until SalesLine.Next() = 0;

        if HasCollectedErrors then
            Error(GetCollectedErrors().Get(1).Message);

        CronJobMgmt.PushSingleSalesOrderToLRI(SalesHeader);
    end;
}
