page 66005 "Woo Commerce Order Details"
{
    ApplicationArea = All;
    Caption = 'Woo Commerce Order Details';
    PageType = List;
    SourceTable = "Woo Commerce Order Detail";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Order Type"; Rec."Order Type")
                {
                    ToolTip = 'Specifies the value of the Order Type field.', Comment = '%';
                }
                field("Order No."; Rec."Order No.")
                {
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ToolTip = 'Specifies the value of the Order Date field.', Comment = '%';
                }
                field("Order Time"; Rec."Order Time")
                {
                    ToolTip = 'Specifies the value of the Order Time field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ToolTip = 'Specifies the value of the VAT Amount field.', Comment = '%';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ToolTip = 'Specifies the value of the VAT % field.', Comment = '%';
                }
                field("Amount Incl VAT"; Rec."Amount Incl VAT")
                {
                    ToolTip = 'Specifies the value of the Amount Incl VAT field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Amount field.', Comment = '%';
                }
                field("Discount Amount Tax"; Rec."Discount Amount Tax")
                {
                    ToolTip = 'Specifies the value of the Discount Amount Tax field.', Comment = '%';
                }
                field("Delivery Fee"; Rec."Delivery Fee")
                {
                    ToolTip = 'Specifies the value of the Delivery Fee field.', Comment = '%';
                }
                field("Delivery Fee Tax"; Rec."Delivery Fee Tax")
                {
                    ToolTip = 'Specifies the value of the Delivery Fee Tax field.', Comment = '%';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code', Comment = '%';
                }
                field(Currency; Rec.Currency)
                {
                    ToolTip = 'Specifies the value of the Currency field.', Comment = '%';
                }
                field("No. Of Items"; Rec."No. Of Items")
                {
                    ToolTip = 'Specifies the value of the No. Of Items field.', Comment = '%';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ToolTip = 'Specifies the value of the Invoice No. field.';
                }
                field("Invoice Date"; Rec."Invoice Date")
                {
                    ToolTip = 'Specifies the value of the Invoice Date field.';
                }
                field("Refund No."; Rec."Refund No.")
                {
                    ToolTip = 'Specifies the value of the Credit Note No. field.';
                }
                field("Credit Note No."; Rec."Credit Note No.")
                {
                    ToolTip = 'Specifies the value of the Credit Note No.', Comment = '%';
                }
                field("Credit Note Date"; Rec."Credit Note Date")
                {
                    ToolTip = 'Specifies the value of the Credit Note Date field.';
                }
                field("Credit Note Amount"; Rec."Credit Note Amount")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Credit Note Amount', Comment = '%';
                }
                field("Order Processed"; Rec."Order Processed")
                {
                    ToolTip = 'Specifies the value of the Order Processed', Comment = '%';
                }
                field("Order Processed Date"; Rec."Order Processed Date")
                {
                    ToolTip = 'Specifies the value of the Order Processed Date', Comment = '%';
                }
                field("Order Processed Time"; Rec."Order Processed Time")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Order Processed Time', Comment = '%';
                }
                field("Return Processed"; Rec."Return Processed")
                {
                    ToolTip = 'Specifies the value of the Return Processed', Comment = '%';
                }
                field("Return Processed Date"; Rec."Return Processed Date")
                {
                    ToolTip = 'Specifies the value of the Return Processed Date', Comment = '%';
                }
                field("Return Processed Time"; Rec."Return Processed Time")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Processed Time', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Admin)
            {
                Visible = this.IsEditable;
                actionref(FetchOrders; "Fetch Orders from Woo Commerce")
                {
                }
                actionref(PostJournal; "Post Selected Order(s)")
                {
                }
                actionref(Delete; "Delete Order")
                {
                }
                actionref(Test; "Reset Posting - Test")
                {
                }
            }

            group(Related)
            {
                actionref(DataLog; "Integration Data Log")
                {
                }
                actionref(APILog; "API Transaction Log")
                {
                }
            }
        }
        area(Processing)
        {
            action("Fetch Orders from Woo Commerce")
            {
                ApplicationArea = All;
                Image = GetEntries;
                ToolTip = 'Executes the Fetch Item from LRI action.';
                Visible = true;
                trigger OnAction()
                var
                    FetchWoocommerceOrders: Codeunit "Fetch Woo Commerce Orders";
                    ConfirmMsg: Label 'This action fetch Orders from Woo Commerce. Do you want to continue?';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;
                    FetchWoocommerceOrders.FetchOrderFromWoocommerce();
                end;
            }
            action("Post Selected Order(s)")
            {
                ApplicationArea = All;
                Image = GetEntries;
                ToolTip = 'Executes the Post Selected Order(s) action.';
                Visible = true;
                trigger OnAction()
                var
                    WooCommerceOrderDetail: Record "Woo Commerce Order Detail";
                    CronJobMgmt: Codeunit "Cron Job Mgmt.";
                    ConfirmationQst: Label 'Do you want to post the sales journal for selected order(s)?';
                begin
                    if not Confirm(ConfirmationQst) then
                        exit;

                    CurrPage.SetSelectionFilter(WooCommerceOrderDetail);
                    CronJobMgmt.ProcessSelectedSalesJournal(WooCommerceOrderDetail);
                end;
            }
            action("Integration Data Log")
            {
                ApplicationArea = All;
                Image = LedgerBook;
                RunObject = page "Integration Data Log";
                RunPageLink = "Document No." = field("Order No.");
                ToolTip = 'Executes the Integration Data Log action.';
            }
            action("Delete Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the delete order action';
                Image = DeleteRow;
                Enabled = this.IsEditable;
                trigger OnAction()
                var
                    WooCommerceOrderDetail: Record "Woo Commerce Order Detail";
                    DeleteConfirmationQst: Label 'Do you want to delete the selected orders?';
                begin
                    if not Confirm(DeleteConfirmationQst) then
                        exit;

                    CurrPage.SetSelectionFilter(WooCommerceOrderDetail);
                    WooCommerceOrderDetail.DeleteAll(true)
                end;
            }
            action("API Transaction Log")
            {
                ApplicationArea = All;
                Image = Log;
                RunObject = page "API Transaction Log List";
                ToolTip = 'Executes the API Transaction Log action.';
            }
            action("Reset Posting - Test")
            {
                ApplicationArea = All;
                Image = TestFile;
                ToolTip = 'Executes the Reset Posting - Test action.';
                trigger OnAction()
                var
                    WooCommerceOrderDetail: Record "Woo Commerce Order Detail";
                begin

                    CurrPage.SetSelectionFilter(WooCommerceOrderDetail);
                    WooCommerceOrderDetail.SetRange("Order Processed", true);
                    if WooCommerceOrderDetail.FindSet() then
                        repeat
                            WooCommerceOrderDetail."Invoice No." := Format(Random(10000));
                            WooCommerceOrderDetail.Validate("Order Processed", false);
                            WooCommerceOrderDetail.Modify();
                        until WooCommerceOrderDetail.Next() = 0;


                    WooCommerceOrderDetail.SetRange("Order Processed", false);
                    WooCommerceOrderDetail.SetRange("Return Processed", true);
                    if WooCommerceOrderDetail.FindSet() then
                        repeat
                            WooCommerceOrderDetail."Credit Note No." := Format(Random(10000));
                            WooCommerceOrderDetail.Validate("Return Processed", false);
                            WooCommerceOrderDetail.Modify();
                        until WooCommerceOrderDetail.Next() = 0
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        this.IsEditable := this.UserSetup.CallSuperAdminSilent();
    end;

    var
        UserSetup: Record "User Setup";
        IsEditable: Boolean;
}
