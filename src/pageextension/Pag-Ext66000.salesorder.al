pageextension 66000 "Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Order Type"; Rec."Order Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Type field.';
            }
        }
    }
    // actions
    // {
    //     addafter(Invoices)
    //     {
    //         action("Create LRI Order")
    //         {
    //             ApplicationArea = All;
    //             Image = MakeOrder;

    //         }
    //     }
    // }
}
