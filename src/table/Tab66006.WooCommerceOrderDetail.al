table 66006 "Woo Commerce Order Detail"
{
    Caption = 'Woo Commerce Order Detail';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order Type"; Enum "Sales Document Type")
        {
            Caption = 'Order Type';
        }
        field(2; "Order No."; Text[100])
        {
            Caption = 'Order No.';
        }
        field(50; "Order Date Time"; DateTime)
        {

        }
        field(100; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(200; "Order Time"; Time)
        {
            Caption = 'Order Time';
        }
        field(300; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(400; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
        }
        field(500; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
        }
        field(600; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
        }
        field(700; "Discount Amount Tax"; Decimal)
        {
            Caption = 'Discount Amount Tax';
        }
        field(800; "Delivery Fee"; Decimal)
        {
            Caption = 'Delivery Fee';
        }
        field(900; "Delivery Fee Tax"; Decimal)
        {
            Caption = 'Delivery Fee Tax';
        }
        field(1000; "Amount Incl VAT"; Decimal)
        {
            Caption = 'Amount Incl VAT';
        }
        field(1100; Currency; Text[100])
        {
            Caption = 'Currency';
        }
        field(1200; Status; Text[100])
        {
            Caption = 'Status';
        }
        field(1300; "No. Of Items"; Integer)
        {
            Caption = 'No. Of Items';
        }
        field(1400; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(1500; "Processed Date"; Date)
        {
            Caption = 'Processed Date';
        }
        field(1600; "Processed Time"; Time)
        {
            Caption = 'Processed Time';
        }
    }
    keys
    {
        key(PK; "Order Type", "Order No.")
        {
            Clustered = true;
        }
    }
}
