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
        field(1310; "Invoice Date"; Date)
        {
        }
        field(1320; "Invoice No."; Code[20])
        {
        }
        field(1330; "Credit Note Date"; Date)
        {
        }
        field(1340; "Refund No."; Code[20])
        {
        }
        field(1345; "Credit Note No."; Code[20])
        {
        }
        field(1350; "Credit Note Amount"; Decimal)
        {
        }
        field(1360; "Country Code"; Code[10])
        {
        }
        field(1400; "Order Processed"; Boolean)
        {
            trigger OnValidate()
            begin
                if Rec."Order Processed" then begin
                    "Order Processed Date" := Today;
                    "Order Processed Time" := Time;
                end else begin
                    "Order Processed Date" := 0D;
                    "Order Processed Time" := 0T;
                end;
            end;
        }
        field(1500; "Order Processed Date"; Date)
        {
        }
        field(1600; "Order Processed Time"; Time)
        {
        }
        field(1700; "Return Processed"; Boolean)
        {
            trigger OnValidate()
            begin
                if Rec."Return Processed" then begin
                    "Return Processed Date" := Today;
                    "Return Processed Time" := Time;
                end else begin
                    "Return Processed Date" := 0D;
                    "Return Processed Time" := 0T;
                end;
            end;
        }
        field(1800; "Return Processed Date"; Date)
        {
        }
        field(1900; "Return Processed Time"; Time)
        {
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
