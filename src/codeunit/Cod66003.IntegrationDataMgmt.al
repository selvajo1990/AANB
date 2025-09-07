codeunit 66003 "Integration Data Mgmt."
{
    trigger OnRun()
    var
        IntegrationDataTypeL: Enum "Integration Data Type";
    begin

        case this.JobType of
            Format(IntegrationDataTypeL::"Create Item"):
                this.CreateItem();
        end;
    end;

    procedure CreateItem()
    var
        ItemRef: RecordRef;
        Item: Record Item;
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Default Item Template");

        Item.Init();
        Item."No." := this.LRIItem."Product Id";
        Item.Insert(true);

        this.ConfigTemplateHeader.Get(this.AANBSetup."Default Item Template");

        ItemRef.GetTable(Item);
        this.ConfigTemplateManagement.UpdateRecord(this.ConfigTemplateHeader, ItemRef);
        ItemRef.SetTable(Item);

        Item.Description := this.LRIItem.Description;
        Item.Modify(true);
    end;


    procedure SetSyncData(LRIItemP: Record "LRI Item"; JobTypeP: Code[20])
    begin
        this.JobType := JobTypeP;
        this.LRIItem := LRIItemP;
    end;

    var
        JobType, ProductId : Code[20];
        ConfigTemplateHeader: Record "Config. Template Header";
        AANBSetup: Record "AANB Setup";
        Item: Record Item;
        LRIItem: Record "LRI Item";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        NoSeries: Codeunit "No. Series";
}
