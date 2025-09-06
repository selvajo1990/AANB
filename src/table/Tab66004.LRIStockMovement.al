table 66004 "LRI Stock Movement"
{
    Caption = 'LRI Stock Movement';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
        }
        field(100; "Entry Type"; Enum "LRI Stock Movement Type")
        {
        }
        field(200; "Entry Date"; Date)
        {
        }
        field(300; "Entry Time"; Time)
        {
        }
        field(400; "Product Id"; Code[20])
        {
        }
        field(500; Description; Text[100])
        {
        }
        field(600; "Location Code"; Code[20])
        {
        }
        field(700; Qty; Decimal)
        {
        }
        field(800; Price; Decimal)
        {
        }
        field(900; "Total Amount"; Decimal)
        {
        }
        field(1000; "Total VAT Amount"; Decimal)
        {
        }
        field(1100; "Reason Code"; Code[20])
        {
        }
        field(1120; "Reason Description"; Text[250])
        {
        }
        field(1200; Processed; Boolean)
        {
        }
        field(1300; "Processed Date"; Date)
        {
        }
        field(1400; "Processed Time"; Time)
        {
        }
    }
    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
    }
}
