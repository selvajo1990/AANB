table 66002 "AANB Setup"
{
    Caption = 'AANB Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(500; "Default B2C Customer"; Code[20])
        {
            TableRelation = "Config. Template Header";
        }
        field(1000; "Default Item Template"; Code[20])
        {
            TableRelation = "Config. Template Header";
        }
        field(1500; "Sales Template Name "; Code[20])
        {
        }
        field(2000; "Sales Batch Name "; Code[20])
        {
        }
        field(2500; "Sales Return Template Name "; Code[20])
        {
        }
        field(3000; "Sales Return Batch Name "; Code[20])
        {
        }
        field(3500; "Purchase Template Name "; Code[20])
        {
        }
        field(4000; "Purchase Batch Name"; Code[20])
        {
        }
        field(4500; "Purchase Return Template Name"; Code[20])
        {
        }
        field(5000; "Purchase Return Batch Name"; Code[20])
        {
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
