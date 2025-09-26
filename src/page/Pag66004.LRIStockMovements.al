page 66004 "LRI Stock Movements"
{
    ApplicationArea = All;
    Caption = 'LRI Stock Movements';
    PageType = List;
    SourceTable = "LRI Stock Movement";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field.', Comment = '%';
                }
                field("Product Id"; Rec."Product Id")
                {
                    ToolTip = 'Specifies the value of the Product Id field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Qty; Rec.Qty)
                {
                    ToolTip = 'Specifies the value of the Qty field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ToolTip = 'Specifies the value of the Entry Date field.', Comment = '%';
                }
                field("Entry Time"; Rec."Entry Time")
                {
                    ToolTip = 'Specifies the value of the Entry Time field.', Comment = '%';
                }
                field(Processed; Rec.Processed)
                {
                    ToolTip = 'Specifies the value of the Processed field.', Comment = '%';
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ToolTip = 'Specifies the value of the Processed Date field.', Comment = '%';
                }
                field("Processed Time"; Rec."Processed Time")
                {
                    ToolTip = 'Specifies the value of the Processed Time field.', Comment = '%';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ToolTip = 'Specifies the value of the Reason Code field.', Comment = '%';
                }
                field("Reason Description"; Rec."Reason Description")
                {
                    ToolTip = 'Specifies the value of the Reason Description field.';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Admin)
            {
                Visible = this.IsEditable;
                actionref(SeletedItem; "Post Selected Movement")
                {
                }
            }
            group(Related)
            {
                actionref(DataLog; "Integration Data Log")
                {
                }
                actionref(ItemLedger; "Item Ledger Entries")
                {
                }
                actionref(Item_; Item)
                {
                }
            }
        }
        area(Processing)
        {
            action("Post Selected Movement")
            {
                Image = Post;
                ApplicationArea = All;
                Enabled = this.IsEditable;
                ToolTip = 'Executes the Post Selected Movement action.';
                trigger OnAction()
                var
                    LRIStockMovement: Record "LRI Stock Movement";
                    CronJobMgmt: Codeunit "Cron Job Mgmt.";
                    ConfirmationQst: Label 'Do you want to Post the selected stocks into item journal?';
                begin
                    if not Confirm(ConfirmationQst, true) then
                        exit;

                    CurrPage.SetSelectionFilter(LRIStockMovement);
                    CronJobMgmt.ProcessSelectedMovmentJournal(LRIStockMovement);
                end;
            }
            action("Integration Data Log")
            {
                ApplicationArea = All;
                Image = LedgerBook;
                RunObject = page "Integration Data Log";
                RunPageLink = "Document No." = field("Product Id");
                ToolTip = 'Executes the Integration Data Log action.';
            }
            action("Item Ledger Entries")
            {
                ApplicationArea = All;
                Image = ItemLedger;
                RunObject = page "Item Ledger Entries";
                RunPageLink = "Item No." = field("Product Id"), "Document No." = field("Document No."), "Posting Date" = field("Entry Date");
                ToolTip = 'Executes the Item Ledger Entries action.';
            }
            action(Item)
            {
                ApplicationArea = All;
                Image = Item;
                RunObject = page "Item Card";
                RunPageLink = "No." = field("Product Id");
                RunPageMode = View;
                ToolTip = 'Executes the Item action.';
            }
        }
    }
    trigger OnOpenPage()
    begin
        this.IsEditable := this.UserSetup.CallSuperAdminSilent();
    end;

    var
        UserSetup: Record "User Setup";
        IsEditable: Boolean;

}
