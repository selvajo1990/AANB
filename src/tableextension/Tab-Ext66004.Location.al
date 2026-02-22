tableextension 66004 Location extends Location
{
    fields
    {
        field(66000; "Shipping Address"; Text[100])
        {
        }

        field(66001; "Shipping Address 2"; Text[100])
        {
        }
        field(66002; "Shipping City"; Text[30])
        {
            TableRelation = if ("Shipping Country/Region Code" = const('')) "Post Code".City
            else
            if ("Shipping Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Shipping Country/Region Code"));
            ValidateTableRelation = false;
            trigger OnLookup()
            begin
                PostCode.LookupPostCode("Shipping City", "Shipping Post Code", County, "Shipping Country/Region Code");
            end;

            trigger OnValidate()

            begin
                PostCode.ValidateCity("Shipping City", "Shipping Post Code", County, "Shipping Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(66003; "Shipping Post Code"; Code[20])
        {
            TableRelation = if ("Shipping Country/Region Code" = const('')) "Post Code"
            else
            if ("Shipping Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Shipping Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode("Shipping City", "Shipping Post Code", County, "Shipping Country/Region Code");
            end;

            trigger OnValidate()

            begin
                PostCode.LookupPostCode("Shipping City", "Shipping Post Code", County, "Shipping Country/Region Code");
            end;
        }
        field(66004; "Shipping Country/Region Code"; Code[10])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                PostCode.CheckClearPostCodeCityCounty("Shipping City", "Shipping Post Code", County, "Shipping Country/Region Code", xRec."Shipping Country/Region Code");
            end;
        }
        field(66005; "VAT Registration Number"; Text[20])
        {

        }
    }
    var
        PostCode: Record "Post Code";
}
