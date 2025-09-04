table 66001 "API Template Setup"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "API Template Setup List";
    LookupPageId = "API Template Setup List";
    fields
    {
        field(1; "Template Code"; Code[20])
        {
        }
        field(2; "Environment Type"; Enum "Environment Type")
        {
        }
        field(20; Description; Text[100])
        {
        }
        field(40; "User ID"; Text[250])
        {
        }
        field(60; Password; Text[250])
        {
        }
        // field(80; "API Key"; Text[2048])
        // {
        // }
        field(100; EndPoint; Text[1000])
        {
        }
        field(120; "Capture Log"; Boolean)
        {
        }
        field(140; "Capture Transaction Document"; Boolean)
        {
        }
        field(160; "Transaction Document Format"; Option)
        {
            OptionMembers = Xml,Json;
            OptionCaption = '.Xml,.Json';
        }

    }
    keys
    {
        key(PK; "Template Code", "Environment Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Template Code", "Environment Type", Description)
        {

        }
    }
}
