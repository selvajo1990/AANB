page 66003 "LRI Items"
{
    ApplicationArea = All;
    Caption = 'LRI Items';
    PageType = List;
    SourceTable = "LRI Item";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Product Id"; Rec."Product Id")
                {
                    ToolTip = 'Specifies the value of the Product Id field.', Comment = '%';
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
            actionref(FetchLRIItem; "Fetch LRI Item")
            {

            }
            actionref(CreateItem; "Create Item")
            {

            }

        }
        area(Processing)
        {
            action("Create Item")
            {
                ToolTip = 'Executes the Create Item action.';
                ApplicationArea = All;
                Caption = 'Create Item';
                Image = ItemTracking;
                trigger OnAction()
                var
                    ConfirmationQst: Label 'Do you want to Create all product In Item?';
                begin
                    if not Confirm(ConfirmationQst, true) then
                        exit;

                    this.CronJobMgmt.CreateItemFromLRIProduct();
                end;
            }
            action("Fetch LRI Item")
            {
                Image = GetEntries;
                ApplicationArea = All;
                ToolTip = 'Executes the Fetch LRI Item action.';
                trigger OnAction()
                var
                    LRIIntegrationMgmt: Codeunit "LRI Integration Mgmt.";
                    ConfirmMsg: Label 'This action fetch item from LRI.Do you want to continue ?';

                begin
                    if not Confirm(ConfirmMsg) then
                        exit;
                    LRIIntegrationMgmt.ProductFetch();
                end;
            }
        }
    }
    var
        CronJobMgmt: Codeunit "Cron Job Mgmt.";
}
