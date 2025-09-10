pageextension 66001 "Sales Order List" extends "Sales Order List"
{
    layout
    {
        addbefore("Sell-to Customer No.")
        {
            field("Order Type"; Rec."Order Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Type field.';
            }
        }
        addafter(Status)
        {
            field("Sent To LRI"; Rec."Sent To LRI")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sent To LRI field.';
                Editable = false;
            }
        }
    }
    actions
    {
        addafter(PostedSalesInvoices_Promoted)
        {
            actionref(PushSalesOrder_; "Push Sales Order")
            {
            }
        }
        addafter(PostedSalesInvoices)
        {
            action("Push Sales Order")
            {
                ApplicationArea = All;
                Image = PostOrder;
                ToolTip = 'Executes the Push Sales Order action.';
                trigger OnAction()
                var
                    CronJobMgmt: Codeunit "Cron Job Mgmt.";
                    ConfirmationQst: Label 'Do you want to push order no.: %1 to LRI ?', Comment = '%1';
                begin
                    if not Confirm(StrSubstNo(ConfirmationQst, Rec."No."), true) then
                        exit;
                    CronJobMgmt.PushSingleSalesOrderToLRI(Rec);
                end;
            }
        }
    }
}
