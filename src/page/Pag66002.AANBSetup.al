page 66002 "AANB Setup"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'AANB Setup';
    PageType = Card;
    SourceTable = "AANB Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Default B2C Customer"; Rec."Default B2C Customer")
                {
                    ToolTip = 'Specifies the value of the Default B2C Customer field.', Comment = '%';
                }
                field("Default Item Template"; Rec."Default Item Template")
                {
                    ToolTip = 'Specifies the value of the Default Item Template field.', Comment = '%';
                }
            }
            group("Journal Templates")
            {
                field("Purchase Template Name "; Rec."Purchase Template Name")
                {
                    ToolTip = 'Specifies the value of the Purchase Template Name  field.', Comment = '%';
                }
                field("Purchase Batch Name"; Rec."Purchase Batch Name")
                {
                    ToolTip = 'Specifies the value of the Purchase Batch Name field.', Comment = '%';
                }
                field("Purchase Return Template Name"; Rec."Purchase Return Template Name")
                {
                    ToolTip = 'Specifies the value of the Purchase Return Template Name field.', Comment = '%';
                }
                field("Purchase Return Batch Name"; Rec."Purchase Return Batch Name")
                {
                    ToolTip = 'Specifies the value of the Purchase Return Batch Name field.', Comment = '%';
                }
                field("Sales Template Name "; Rec."Sales Template Name")
                {
                    ToolTip = 'Specifies the value of the Sales Template Name  field.', Comment = '%';
                }
                field("Sales Batch Name "; Rec."Sales Batch Name")
                {
                    ToolTip = 'Specifies the value of the Sales Batch Name  field.', Comment = '%';
                }
                field("Sales Return Template Name "; Rec."Sales Return Template Name")
                {
                    ToolTip = 'Specifies the value of the Sales Return Template Name  field.', Comment = '%';
                }
                field("Sales Return Batch Name "; Rec."Sales Return Batch Name")
                {
                    ToolTip = 'Specifies the value of the Sales Return Batch Name  field.', Comment = '%';
                }

            }
            group(Product)
            {

                field("RCB No."; Rec."RCB No.")
                {
                    ToolTip = 'Specifies the value of the RCB No. field.';
                }
            }
            group(Integration)
            {
                group(LRI)
                {
                    field("Product Fetch"; Rec."Product Fetch")
                    {
                        ToolTip = 'Specifies the value of the Product Fetch field.';
                    }
                    field("Push Order"; Rec."Push Sales Order")
                    {
                        ToolTip = 'Specifies the value of the Push Sales Order field.';

                    }

                }
                group("Woo Commerce")
                {

                }
            }
            group("No. Series")
            {
                field("Item Nos"; Rec."Item Nos")
                {
                    ToolTip = 'Specifies the value of the Item Nos', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(APITemplate; "API Template Setup")
            {
            }
            actionref(LRIItem; "LRI Items")
            {
            }
            actionref(LRIStockMovement; "LRI Stock Movements")
            {
            }
            group(Log)
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
            action("Integration Data Log")
            {
                ApplicationArea = All;
                Image = LedgerBook;
                RunObject = page "Integration Data Log";
                ToolTip = 'Executes the Integration Data Log action.';
            }
            action("API Transaction Log")
            {
                ApplicationArea = All;
                Image = Log;
                RunObject = page "API Transaction Log List";
                ToolTip = 'Executes the API Transaction Log action.';
            }
            action("LRI Items")
            {
                ApplicationArea = All;
                Image = Item;
                RunObject = page "LRI Items";
                ToolTip = 'Executes the LRI Items action.';
            }
            action("LRI Stock Movements")
            {
                ApplicationArea = All;
                Image = Transactions;
                RunObject = page "LRI Stock Movements";
                ToolTip = 'Executes the LRI Stock Movements action.';
            }
            action("API Template Setup")
            {
                ApplicationArea = All;
                Image = Setup;
                RunObject = page "API Template Setup List";
                ToolTip = 'Executes the API Template Setup action.';
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}
