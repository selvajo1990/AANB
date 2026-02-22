report 66001 "Pforma Invoice - AANB"
{
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './res/Pro Forma Invoice.rdl';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem("Transfer Shipment Header"; "Transfer Shipment Header")
        {
            RequestFilterFields = "No.";
            column(No_; "No.")
            {
            }
            column(Name; this.CompanyInformation.Name)
            {
            }
            column(Address; this.CompanyInformation.Address)
            {
            }
            column(Address2; this.CompanyInformation."Address 2")
            {
            }
            column(city; this.CompanyInformation.City)
            {
            }
            column(FromVat; this.FromVat)
            {
            }
            column(ToVat; this.ToVat)
            {
            }
            column(Posting_Date; Format("Posting Date"))
            {
            }
            column(Currency; this.GeneralLedgerSetup."LCY Code")
            {
            }
            column(Shipping_Address; this.Location."Shipping Address")
            {
            }
            column(Shipping_Address2; this.Location."Shipping Address 2")
            {
            }
            column(Shipping_city; this.Location."Shipping City")
            {
            }
            column(Shipping_postcode; this.Location."Shipping Post Code")
            {
            }
            column(Shipping_country; this.Location."Shipping Country/Region Code")
            {
            }
            dataitem("Transfer Shipment Line"; "Transfer Shipment Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(Item_No_; "Item No.")
                {
                }
                column(Description; Description)
                {
                }
                column(Quantity; Quantity)
                {
                }
                column(UnitPrice; this.Item."Unit Price")
                {
                }
                column(unitcost; this.Item."Unit Cost")
                {
                }
                column(Total; this.Total)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    this.Item.Get("Item No.");
                    //this.Total := this.Total + (this.Item."Unit Price" * Quantity);
                    this.Total := this.Total + (this.Item."Unit Cost" * Quantity);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                this.Location.Get("Transfer-from Code");
                this.FromVat := this.Location."VAT Registration Number";
                clear(this.Location);
                this.Location.Get("Transfer-To Code");
                this.ToVat := this.Location."VAT Registration Number";
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    trigger OnPreReport()
    begin
        this.GeneralLedgerSetup.Get();
        this.CompanyInformation.Get();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        Location: Record Location;
        FromVat, ToVat : Text[20];
        Total: Decimal;
}
