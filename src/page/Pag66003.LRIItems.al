page 66003 "LRI Items"
{
    ApplicationArea = All;
    Caption = 'LRI Items';
    PageType = List;
    SourceTable = "LRI Item";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Product Id"; Rec."Product Id")
                {
                    ToolTip = 'Specifies the value of the Product Id field.', Comment = '%';
                    DrillDown = true;
                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get(Rec."Product Id") then
                            Page.Run(Page::"Item Card", Item);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ToolTip = 'Specifies the value of the Is Active field.';
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
                field("Error Info"; Rec."Error Info")
                {
                    ToolTip = 'Specifies the value of the Error Info field.', Comment = '%';
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
                Visible = IsEditable;
                actionref(CreateAllItem; "Create All Item From LRI")
                {
                }
                actionref(SeletedItem; "Create Item")
                {
                }
                actionref(Delete; "Delete All")
                {
                }
            }
            actionref(FetchLRIItem; "Fetch LRI Item")
            {
            }

            actionref(DataLog; "Integration Data Log")
            {
            }
        }
        area(Processing)
        {
            action("Create All Item From LRI")
            {
                ToolTip = 'Executes the Create Item action.';
                ApplicationArea = All;
                Image = ItemTracking;
                Enabled = this.IsEditable;
                trigger OnAction()
                var
                    ConfirmationQst: Label 'Do you want to Create Item from LRI Item?';
                begin
                    if not Confirm(ConfirmationQst, true) then
                        exit;

                    this.CronJobMgmt.CreateAllItemFromLRIProduct();
                end;
            }
            action("Create Item")
            {
                Image = ItemGroup;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Selected Item From LRI action.';
                Enabled = this.IsEditable;
                trigger OnAction()
                var
                    LRIItem: Record "LRI Item";
                    ConfirmationQst: Label 'Do you want to create only selected Item from LRI Item?';
                begin
                    if not Confirm(ConfirmationQst, true) then
                        exit;

                    CurrPage.SetSelectionFilter(LRIItem);
                    this.CronJobMgmt.CreateSelectedItemFromLRIProduct(LRIItem);
                end;
            }
            action("Delete All")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the delete all temp';
                Image = DeleteRow;
                Enabled = this.IsEditable;
                trigger OnAction()
                var
                    LRIItem: Record "LRI Item";
                    DeleteConfirmationQst: Label 'do you want to delete all the selected LRI Items?';
                begin
                    if not Confirm(DeleteConfirmationQst) then
                        exit;
                    CurrPage.SetSelectionFilter(LRIItem);
                    LRIItem.DeleteAll(true)
                end;
            }

            action("Fetch LRI Item")
            {
                Image = GetEntries;
                ApplicationArea = All;
                ToolTip = 'Executes the Fetch LRI Item action.';
                Visible = false;
                trigger OnAction()
                var
                    IntegrationDataMgmt: Codeunit "Integration Data Mgmt.";
                    ConfirmMsg: Label 'This action fetch item from LRI. Do you want to continue?';

                begin
                    if not Confirm(ConfirmMsg) then
                        exit;
                    IntegrationDataMgmt.ProductFetchFromLRI();
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
        }
    }
    trigger OnOpenPage()
    begin
        this.IsEditable := this.UserSetup.CallSuperAdminSilent();
    end;

    var
        UserSetup: Record "User Setup";
        CronJobMgmt: Codeunit "Cron Job Mgmt.";
        IsEditable: Boolean;

}
