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
                group("LRI Journal Templates")
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
                group("Woo Commerce Journal Templates")
                {
                    field("Woo-Sales Template Name "; Rec."Woo-Sales Template Name")
                    {
                        ToolTip = 'Specifies the value of the Woo-Sales Template Name field.';
                    }
                    field("Woo-Sales Batch Name "; Rec."Woo-Sales Batch Name")
                    {
                        ToolTip = 'Specifies the value of the Woo-Sales Batch Name field.';
                    }
                    field("Woo-Sales Return Template Name "; Rec."Woo-Sales Return Template Name")
                    {
                        ToolTip = 'Specifies the value of the Woo-Sales Return Template Name field.';
                    }
                    field("Woo-Sales Return Batch Name "; Rec."Woo-Sales Return Batch Name")
                    {
                        ToolTip = 'Specifies the value of the Woo-Sales Return Batch Name field.';
                    }
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
                    field("Fetch All Order"; Rec."Fetch All Order")
                    {
                        ToolTip = 'Specifies the value of the Fetch All Order', Comment = '%';
                    }
                    field("Fetch All Order Interval"; Rec."Fetch All Order Interval")
                    {
                        ToolTip = 'Specifies the value of the Fetch All Order Interval', Comment = '%';
                    }
                    field("Recurring Order Fetch Interval"; Rec."Recurring Order Fetch Interval")
                    {
                        ToolTip = 'Specifies the value of the Recurring Order Fetch Interval', Comment = '%';
                    }
                    field("Order Fetch"; Rec."Order Fetch")
                    {
                        ToolTip = 'Specifies the value of the Order Fetch field.';
                    }
                    field("Last Modified Order TimeStamp"; Rec."Last Modified Order TimeStamp")
                    {
                        ToolTip = 'Specifies the value of the Last Modified Order TimeStamp', Comment = '%';
                    }
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
    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}
