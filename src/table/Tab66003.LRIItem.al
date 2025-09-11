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
            trigger OnValidate()
            begin
                if Rec.Processed then begin
                    "Processed Date" := Today;
                    "Processed Time" := Time;
                end else begin
                    "Processed Date" := 0D;
                    "Processed Time" := 0T;
                end;
            end;
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
    trigger OnDelete()
    var
        Item: Record Item;
        UserSetup: Record "User Setup";
        BlockDeleteErr: Label 'You are not allowed to delete the order.';
    begin
        if not UserSetup.CallSuperAdminSilent() then
            Error(BlockDeleteErr);
        if Item.Get(Rec."Product Id") then
            item.Delete(true);
    end;
}
