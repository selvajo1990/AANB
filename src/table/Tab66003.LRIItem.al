table 66003 "LRI Item"
{
    Caption = 'LRI Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Product Id"; Code[20])
        {
        }
        field(500; Description; Text[100])
        {
        }
        field(520; Type; Text[100])
        {
        }
        field(540; "Is Active"; Boolean)
        {
        }
        field(1000; Processed; Boolean)
        {
        }
        field(1500; "Processed Date"; Date)
        {
        }
        field(2000; "Processed Time"; Time)
        {
        }
        field(2500; "Error Info"; Text[2048])
        {
        }

    }
    keys
    {
        key(PK; "Product Id")
        {
            Clustered = true;
        }
    }
}
