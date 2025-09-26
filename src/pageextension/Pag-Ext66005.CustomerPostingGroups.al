pageextension 66005 "Customer Posting Groups" extends "Customer Posting Groups"
{
    layout
    {
        addafter(Description)
        {
            field("Order Type"; Rec."Order Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Type', Comment = '%';
            }
        }
    }
}
