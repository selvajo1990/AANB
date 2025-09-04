table 66000 "API Transaction Log"
{
    DataClassification = CustomerContent;
    LookupPageId = "API Transaction Log List";
    DrillDownPageId = "API Transaction Log List";
    Permissions = tabledata "API Transaction Log" = RIM;
    fields
    {
        field(1; "Entry No"; BigInteger)
        {
            AutoIncrement = true;
        }
        field(20; "Entry Type"; Enum "API Transaction Entry Type")
        {

        }
        field(40; "Entry Date"; Date)
        {
        }
        field(60; "Entry Time"; Time)
        {
        }
        field(80; "Reply to Entry No."; BigInteger)
        {
            TableRelation = "API Transaction Log";
        }
        field(100; Document; Media)
        {
        }
        field(120; Status; Enum "API Transaction Status")
        {
        }
        field(140; "Free Text 1"; Text[250])
        {
        }
        field(160; "Free Text 2"; Text[250])
        {
        }
        field(180; "Transaction Sequence"; Integer)
        {
        }
        field(200; "Parent Entry No."; BigInteger)
        {
        }
        field(220; "API Template"; Code[20])
        {
            TableRelation = "API Template Setup";
        }
        field(240; "Error Message"; Text[2048])
        {
        }
        field(260; "Processed By"; Code[50])
        {
        }
    }
    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No", "Entry Type", "API Template")
        {

        }
    }

    trigger OnInsert()
    begin
        "Entry Date" := Today();
        "Entry Time" := Time();
        "Processed By" := CopyStr(UserId(), 1, 50);
    end;

    procedure TransactionLog(EntryTypeP: Enum "API Transaction Entry Type"; ReplyEntryNo: BigInteger; StatusP: Enum "API Transaction Status"; FreeText1: Text[150];
                             ApiTemplateSetup: Record "API Template Setup"; ErrorMessage: Text[2048]; DocumentP: Text): BigInteger
    var
        TempBlob: Codeunit "Temp Blob";
        OutStreamL: OutStream;
        InStreamL: InStream;
    begin
        if not ApiTemplateSetup."Capture Log" then
            exit;
        this.Init();
        "Entry No" := 0;
        "Entry Type" := EntryTypeP;
        if "Entry Type" in ["Entry Type"::"Incoming Response", "Entry Type"::"Outgoing Response"] then
            "Reply to Entry No." := ReplyEntryNo;
        Status := StatusP;
        "Free Text 1" := FreeText1;
        "API Template" := ApiTemplateSetup."Template Code";
        "Error Message" := ErrorMessage;
        if (DocumentP > '') and (ApiTemplateSetup."Capture Transaction Document") then begin
            TempBlob.CreateOutStream(OutStreamL, TextEncoding::UTF8);
            OutStreamL.WriteText(DocumentP);
            TempBlob.CreateInStream(InStreamL, TextEncoding::UTF8);
            Document.ImportStream(InStreamL, "API Template");
        end;
        this.Insert(true);
        exit("Entry No");
    end;

    procedure OpenDocument(): Text
    var
        ApiTemplateSetup: Record "API Template Setup";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        OutStreamL: OutStream;
        NoDataErr: Label 'Entry No.: %1 doesn''t have any document.', Comment = '%1';
        FileNameLbl: Label '%1-%2-%3-%4', Comment = '%1,%2,%3,%4';
        FileName2Lbl: Label '%1-%2', Comment = '%1,%2';
        RequestLbl: Label 'Request';
        ResponseLbl: Label 'Response';
        FileName: Text;
    begin
        TempBlob.CreateOutStream(OutStreamL);
        Document.ExportStream(OutStreamL);
        if not TempBlob.HasValue() then
            Error(NoDataErr, Rec."Entry No");
        ApiTemplateSetup.Get("API Template");

        if Rec."Entry Type" = Rec."Entry Type"::"Outgoing Request" then
            if Rec."Free Text 1" > '' then
                FileName := StrSubstNo(FileNameLbl, Rec."Free Text 1", Rec."API Template", RequestLbl, Rec."Entry No")
            else
                FileName := StrSubstNo(FileName2Lbl, Rec."API Template", RequestLbl)
        else
            if Rec."Free Text 1" > '' then
                FileName := StrSubstNo(FileNameLbl, Rec."Free Text 1", Rec."API Template", ResponseLbl, Rec."Entry No")
            else
                FileName := StrSubstNo(FileName2Lbl, Rec."API Template", ResponseLbl);

        FileManagement.BLOBExportWithEncoding(TempBlob, FileName + Format(ApiTemplateSetup."Transaction Document Format"), true, TextEncoding::UTF8);
    end;
}