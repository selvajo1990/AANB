report 66003 "POsted Credit Memo invoice"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Layouts/POsted creditmemo Invoice.rdl';
    dataset
    {
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
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