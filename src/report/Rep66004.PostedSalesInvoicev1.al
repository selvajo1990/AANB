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
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(CompanyInformation_Address; CompanyInformation.Address)
            {
            }
            column(CompanyInformation_Address2; CompanyInformation."Address 2")
            {
            }
            column(CompanyInformation_city; CompanyInformation.City)
            {
            }
            column(CompanyInformation_VAT; CompanyInformation."VAT Registration No.")
            {
            }
            column(CountryRegion_code; CountryRegion.Get(CompanyInformation."Country/Region Code"))
            {
            }
            column(CompanyInformation_picture; CompanyInformation.Picture)
            {
            }
            column(Bank_name; CompanyInformation."Bank Name")
            {
            }
            column(IBAN; CompanyInformation.IBAN)
            {
            }
            column(SwiftCode; CompanyInformation."SWIFT Code")
            {
            }
            column(InvoiceNo_; "No.")
            {
            }
            column(Invoice_Date; "Document Date")
            {
            }
            column(Order_No_; "Order No.")
            {
            }
            column(Order_Date; "Order Date")
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
            column(Bill_to_Country_Region_Code; CountryRegion.Get("Bill-to Country/Region Code"))
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
            column(Ship_to_Country_Region_Code; "Ship-to Country/Region Code")
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
                column(Line_Discount_Amount; -("Line Discount Amount" + "Inv. Discount Amount"))
                {
                }
                column(VatAmount; "Unit Price" * "VAT %")
                {
                }
                column(Amount_Including_VAT; "Amount Including VAT")
                {
                }

            }
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
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
}
