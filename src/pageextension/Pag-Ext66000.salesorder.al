pageextension 66000 "Sales Order" extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("Order Type"; Rec."Order Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Type field.';
            }
            field("Sent To LRI"; Rec."Sent To LRI")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sent To LRI field.';
            }
        }
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sell-to Customer Name 2', Comment = '%';
            }
        }
    }
    actions
    {
        addafter("S&hipments_Promoted")
        {
            actionref(PushSalesOrder_; "Push Sales Order")
            {
            }
            actionref(DataLog; "Integration Data Log")
            {
            }
        }
        addafter("S&hipments")
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
            action("Integration Data Log")
            {
                ApplicationArea = All;
                Image = LedgerBook;
                RunObject = page "Integration Data Log";
                RunPageLink = "Document No." = field("No.");
                ToolTip = 'Executes the Integration Data Log action.';
            }
        }
    }

}
