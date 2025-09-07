page 66006 "Integration Data Log"
{
    PageType = List;
    SourceTable = "Integration Data Log";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document Type.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document No..';
                }
                field("Dispatcher Type"; Rec."Integration Data Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Process ID.';
                }
                field("Error Description"; Rec."Error Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Error Description.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry Date.';
                }
                field("Entry Time"; Rec."Entry Time")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry Time.';
                }
            }
        }
    }
}