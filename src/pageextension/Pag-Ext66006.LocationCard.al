pageextension 66006 "Location Card" extends "Location Card"
{
    layout
    {
        addafter("Address & Contact")
        {
            group("Shipping Address")
            {
                field("Shipping Address_"; Rec." Shipping Address")
                {
                    ApplicationArea = All;
                    Caption = 'Address';
                    ToolTip = 'Specifies the value of the Address field.';
                }
                field("Shipping Address 2"; Rec."Shipping Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Address 2';
                    ToolTip = 'Specifies the value of the Address 2 field.';
                }
                field("Shipping City"; Rec."Shipping City")
                {
                    ApplicationArea = All;
                    Caption = 'City';
                    ToolTip = 'Specifies the value of the City field.';
                }
                field("Shipping post Code"; Rec."Shipping post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Post Code';
                    ToolTip = 'Specifies the value of the Post Code field.';
                }
                field("Shipping Country/Region Code"; Rec."Shipping Country/Region Code")
                {
                    ApplicationArea = All;
                    Caption = 'Country/Region Code';
                    ToolTip = 'Specifies the value of the Country/Region Code field.';
                }

            }

        }
        addafter(City)
        {
            field("VAT Registration Number"; Rec."VAT Registration Number")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the VAT Registration Number field.';
            }
        }
    }
}
