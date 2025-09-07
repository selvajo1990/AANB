table 66005 "Integration Data Log"
{
    DataClassification = CustomerContent;
    Permissions = tabledata "Integration Data Log" = RIM;
    LookupPageId = "Integration Data Log";
    DrillDownPageId = "Integration Data Log";
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
        }
        field(20; "Document Type"; Text[100])
        {
        }
        field(40; "Document No."; Text[150])
        {
        }
        field(60; "Error Description"; Text[2048])
        {
        }
        field(80; "Entry Date"; Date)
        {
        }
        field(100; "Entry Time"; Time)
        {
        }
        field(120; "Integration Data Type"; Enum "Integration Data Type")
        {
        }
        field(140; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK; "Entry Date", "Entry Time")
        {
        }
    }

    trigger OnInsert()
    begin
        "Entry Date" := Today();
        "Entry Time" := Time();
    end;

    trigger OnModify()
    begin
        "Entry Date" := Today();
        "Entry Time" := Time();
    end;

    procedure InsertOperationError(DocType: Text[50]; DocNo: Text[150]; RecordIdP: RecordId; ErrorDescription: Text; IntegrationDataTypeP: Enum "Integration Data Type")
    begin
        this.Init();
        "Entry No." := 0;
        "Record ID" := RecordIdP;
        "Document Type" := DocType;
        "Document No." := DocNo;
        "Error Description" := CopyStr(ErrorDescription, 1, 2048);
        "Integration Data Type" := IntegrationDataTypeP;
        this.Insert(true);
    end;
}