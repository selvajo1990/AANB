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
            TableRelation = "Customer";
        }
        field(1000; "Default Item Template"; Code[20])
        {
            TableRelation = "Config. Template Header";
        }
        field(1500; "Sales Template Name"; Code[20])
        {
            TableRelation = "Item Journal Template";
        }
        field(2000; "Sales Batch Name"; Code[20])
        {
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("Sales Template Name"));
        }
        field(2500; "Sales Return Template Name"; Code[20])
        {
            TableRelation = "Item Journal Template";
        }
        field(3000; "Sales Return Batch Name"; Code[20])
        {
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("Sales Return Template Name"));
        }
        field(3500; "Purchase Template Name"; Code[20])
        {
            TableRelation = "Item Journal Template";
        }
        field(4000; "Purchase Batch Name"; Code[20])
        {
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("Purchase Template Name"));
        }
        field(4500; "Purchase Return Template Name"; Code[20])
        {
            TableRelation = "Item Journal Template";
        }
        field(5000; "Purchase Return Batch Name"; Code[20])
        {
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("Purchase Return Template Name"));
        }
        field(5500; "Product Fetch"; Code[20])
        {
            TableRelation = "API Template Setup";
        }
        field(6000; "Item Nos"; Code[20])
        {

        }
        field(6500; "RCB No."; Text[100])
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
