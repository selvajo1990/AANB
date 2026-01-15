report 66001 "Pforma Invoice"
{
    ApplicationArea = All;
    Caption = 'Pforma Invoice';
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Layouts/Pforma Invoice.rdl';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem("Transfer Shipment Header"; "Transfer Shipment Header")
        {
            RequestFilterFields = "No.";
            column(No_; "No.")
            {
            }
            column(Transfer_from_Code; "Transfer-from Code")
            {
            }
            column(Transfer_from_Name; "Transfer-from Name")
            {
            }
            column(Transfer_from_Address; "Transfer-from Address")
            {
            }
            column(Transfer_from_Address_2; "Transfer-from Address 2")
            {
            }
            column(Transfer_from_City; "Transfer-from City")
            {
            }
            column(Transfer_from_Post_Code; "Transfer-from Post Code")
            {
            }
            column(Transfer_to_Code; "Transfer-to Code")
            {
            }
            column(Transfer_to_Name; "Transfer-to Name")
            {
            }
            column(Transfer_to_Address; "Transfer-to Address")
            {
            }
            column(Transfer_to_Address_2; "Transfer-to Address 2")
            {
            }
            column(Transfer_to_City; "Transfer-to City")
            {
            }
            column(From_country; "Trsf.-from Country/Region Code")
            {
            }
            column(Transfer_to_Post_Code; "Transfer-to Post Code")
            {
            }
            column(To_country; "Trsf.-to Country/Region Code")
            {
            }
            column(Posting_Date; Format("Posting Date"))
            {
            }
            column(Currency; this.GeneralLedgerSetup."LCY Code")
            {
            }
            column(Shipping_Address; this.Location." Shipping Address")
            {
            }
            column(Shipping_Address2; this.Location."Shipping Address 2")
            {
            }
            column(Shipping_city; this.Location."Shipping City")
            {
            }
            column(Shipping_postcode; this.Location."Shipping post Code")
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
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Item: Record Item;
        Location: Record Location;
        Total: Decimal;
}
