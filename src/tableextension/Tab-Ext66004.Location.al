tableextension 66004 Location extends Location
{
    fields
    {
        field(66000; " Shipping Address"; Text[100])
        {
            Caption = ' Shipping Address';
        }

        field(66001; "Shipping Address 2"; Text[100])
        {
            Caption = 'Shipping Address 2';
        }
        field(66002; "Shipping City"; Text[30])
        {
            Caption = 'Shipping City';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code".City
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;
            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;

            trigger OnValidate()

            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(66003; "Shipping post Code"; Code[20])
        {
            Caption = 'Shipping post Code';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code"
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;

            trigger OnValidate()

            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(66004; "Shipping Country/Region Code"; Code[10])
        {
            Caption = 'Shipping Country/Region Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                PostCode.CheckClearPostCodeCityCounty(City, "Post Code", County, "Country/Region Code", xRec."Country/Region Code");
            end;
        }
        field(66005; "VAT Registration Number"; Text[20])
        {

        }
    }
    var
        PostCode: Record "Post Code";
}
