report 66000 "Clear API Transaction Log"
{
    UsageCategory = None;
    ProcessingOnly = true;
    UseRequestPage = true;
    AdditionalSearchTerms = 'Log,Web Service Delete,Clear Log,Integration Log';
    dataset
    {
        dataitem("API Transaction Log"; "API Transaction Log")
        {
            RequestFilterFields = "Entry Date", "Entry Time";
            trigger OnPreDataItem()
            begin
                if GetFilters() = '' then
                    Error(this.FilterErr);
                if not Confirm('Do you want to continue ?') then
                    CurrReport.Quit();
                DeleteAll(true);
            end;
        }
    }

    var
        FilterErr: Label 'You have to apply filter to continue';
}