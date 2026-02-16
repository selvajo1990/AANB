report 66004 "Posted Sales Invoice v1"
{
    ApplicationArea = All;
    Caption = 'Posted Sales Invoice v1';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Layouts/POsted Sales Invoice1.rdl';
    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            RequestFilterFields = "No.";
            column(CompanyInformation_Name; this.CompanyInformation.Name)
            {
            }
            column(CompanyInformation_Address; this.CompanyInformation.Address)
            {
            }
            column(CompanyInformation_Address2; this.CompanyInformation."Address 2")
            {
            }
            column(CompanyInformation_city; this.CompanyInformation.City)
            {
            }
            column(CompanyInformation_VAT; this.CompanyInformation."VAT Registration No.")
            {
            }
            column(CountryRegion_code; this.Companycountry)
            {
            }
            column(CompanyInformation_picture; this.CompanyInformation.Picture)
            {
            }
            column(Bank_name; this.CompanyInformation."Bank Name")
            {
            }
            column(IBAN; this.CompanyInformation.IBAN)
            {
            }
            column(SwiftCode; this.CompanyInformation."SWIFT Code")
            {
            }
            column(InvoiceNo_; "No.")
            {
            }
            column(Invoice_Date; Format("Document Date"))
            {
            }
            column(Order_No_; "Order No.")
            {
            }
            column(Order_Date; Format("Order Date"))
            {
            }
            column(Bill_to_Name; "Bill-to Name")
            {
            }
            column(Bill_to_Address; "Bill-to Address")
            {
            }
            column(Bill_to_Address_2; "Bill-to Address 2")
            {
            }
            column(Bill_to_Country_Region_Code; this.BillCountry)
            {
            }
            column(VAT_Registration_No_; "VAT Registration No.")
            {
            }
            column(Ship_to_Name; "Ship-to Name")
            {
            }
            column(Ship_to_Address; "Ship-to Address")
            {
            }
            column(Ship_to_Address_2; "Ship-to Address 2")
            {
            }
            column(Ship_to_Country_Region_Code; this.ShipCountry)
            {
            }
            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(ItemNo_; "No.")
                {
                }
                column(Description; Description)
                {
                }
                column(Quantity; Quantity)
                {
                }
                column(Unit_Price; "Unit Price")
                {
                }
                column(VAT__; "VAT %")
                {
                }
                column(Line_Amount; "Line Amount")
                {
                }
                column(Line_Discount_Amount; ("Line Discount Amount" + "Inv. Discount Amount"))
                {
                }
                column(VatAmount; this.VatAmount)
                {
                }
                column(Amount_Including_VAT; "Amount Including VAT")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    this.VatAmount := "Amount Including VAT" - "Line Amount";
                end;

            }
            trigger OnAfterGetRecord()
            begin
                if this.CountryRegion.Get(this.CompanyInformation."Country/Region Code") then
                    this.Companycountry := this.CountryRegion.Name;
                if this.CountryRegion.Get("Bill-to Country/Region Code") then
                    this.BillCountry := this.CountryRegion.Name;
                if this.CountryRegion.Get("Ship-to Country/Region Code") then
                    this.ShipCountry := this.CountryRegion.Name;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    trigger OnInitReport()
    begin
        this.CompanyInformation.Get();
        this.CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
        Companycountry, BillCountry, ShipCountry : Text[100];
        VatAmount: Decimal;



}
