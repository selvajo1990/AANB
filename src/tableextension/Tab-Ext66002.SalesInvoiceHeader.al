tableextension 66002 "Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(66000; "Order Type"; Enum "sales order type")
        {
        }
        field(66100; "Sent To LRI"; Boolean)
        {
        }
    }
}
