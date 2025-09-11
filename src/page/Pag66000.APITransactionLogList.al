page 66000 "API Transaction Log List"
{
    Caption = 'API Transaction Log';
    PageType = List;
    SourceTable = "API Transaction Log";
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("Entry No") order(descending);
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry No.';
                }
                field("Reply to Entry No."; Rec."Reply to Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Reply to Entry No..';
                    BlankZero = true;
                }
                field("API Template"; Rec."API Template")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the API Template.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry Type.';
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
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Status.';
                }
                field("Free Text 1"; Rec."Free Text 1")
                {
                    ApplicationArea = All;
                    Caption = 'Reference No.';
                    Visible = false;
                    Tooltip = 'Specifies the Free Text 1.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Error Message.';
                }
                field("Processed By"; Rec."Processed By")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Processed By.';
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Download Log")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Download Log.';
                Image = MoveDown;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.OpenDocument();
                end;
            }
            action("Clear API Transaction Log")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Clear API Transaction Log.';
                Image = ClearLog;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = report "Clear API Transaction Log";
            }
            action("Integration Data Log")
            {
                ApplicationArea = All;
                Image = LedgerBook;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Integration Data Log";
                RunPageLink = "Document No." = field("Free Text 1");
                ToolTip = 'Executes the Integration Data Log action.';
            }
        }
    }

}