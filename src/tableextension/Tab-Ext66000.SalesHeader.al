tableextension 66000 "Sales Header" extends "Sales Header"
{
    fields
    {
        field(66000; "Order Type"; Enum "sales order type")
        {
        }
        field(66100; "Sent To LRI"; Boolean)
        {
        }
        field(66150; Priority; Enum Priority)
        {
        }
    }
}
