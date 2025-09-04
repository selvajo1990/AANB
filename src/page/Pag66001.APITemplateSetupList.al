page 66001 "API Template Setup List"
{
    Caption = 'API Template Setup';
    PageType = List;
    SourceTable = "API Template Setup";
    UsageCategory = Lists;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Code"; Rec."Template Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Template Code.';
                }
                field("Environment Type"; Rec."Environment Type")
                {
                    ToolTip = 'Specifies the value of the Environment Type', Comment = '%';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Description.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the User ID.';
                }
                field("Password"; Rec."Password")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Password.';
                }
                field("EndPoint"; Rec."EndPoint")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the EndPoint.';
                }
                field("Capture Log"; Rec."Capture Log")
                {
                    ToolTip = 'Specifies the value of the Capture Log';
                    ApplicationArea = All;
                }
                field("Capture Transaction Document"; Rec."Capture Transaction Document")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Capture Transaction Document.';
                }
                field("Transaction Document Format"; Rec."Transaction Document Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Transaction Document Format';
                }
            }
        }
    }
}