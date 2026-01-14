report 66001 "Pforma Invoice"
{
    ApplicationArea = All;
    Caption = 'Pforma Invoice';
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Layouts/Pforma Invoice.rdl';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem("G/L Register"; "G/L Register")
        {
            DataItemTableView = sorting("No.");
            dataitem("G/L Entry"; "G/L Entry")
            {

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
}
