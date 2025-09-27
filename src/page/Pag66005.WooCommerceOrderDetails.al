page 66005 "Woo Commerce Order Details"
{
    ApplicationArea = All;
    Caption = 'Woo Commerce Order Details';
    PageType = List;
    SourceTable = "Woo Commerce Order Detail";
    UsageCategory = Lists;

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
                field(Currency; Rec.Currency)
                {
                    ToolTip = 'Specifies the value of the Currency field.', Comment = '%';
                }
                field("No. Of Items"; Rec."No. Of Items")
                {
                    ToolTip = 'Specifies the value of the No. Of Items field.', Comment = '%';
                }
                field(Processed; Rec.Processed)
                {
                    ToolTip = 'Specifies the value of the Processed field.', Comment = '%';
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ToolTip = 'Specifies the value of the Processed Date field.', Comment = '%';
                }
                field("Processed Time"; Rec."Processed Time")
                {
                    ToolTip = 'Specifies the value of the Processed Time field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(FetchOrders; "Fetch Orders from Woo Commerce")
            {
            }
            group(Related)
            {
                actionref(DataLog; "Integration Data Log")
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
                    FetchWoocommerceOrders.OrderFetchFromWoocommerce();
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
        }
    }
}
