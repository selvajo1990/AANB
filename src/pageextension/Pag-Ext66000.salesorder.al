pageextension 66000 "sales order" extends "Sales Order"
{
    actions
    {
        addafter(Invoices)
        {
            action("Create LRI Order")
            {
                ApplicationArea = All;
                Image = MakeOrder;

            }
        }
    }
}
