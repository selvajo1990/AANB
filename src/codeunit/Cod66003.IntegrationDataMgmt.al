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
        ItemL: Record Item;
        ItemRef: RecordRef;
    begin
        this.AANBSetup.Get();
        this.AANBSetup.TestField("Default Item Template");

        ItemL.Init();
        ItemL."No." := this.LRIItem."Product Id";
        ItemL.Insert(true);

        this.ConfigTemplateHeader.Get(this.AANBSetup."Default Item Template");

        ItemRef.GetTable(ItemL);
        this.ConfigTemplateManagement.UpdateRecord(this.ConfigTemplateHeader, ItemRef);
        ItemRef.SetTable(ItemL);

        ItemL.Description := this.LRIItem.Description;
        ItemL.Modify(true);
    end;


    procedure SetSyncData(LRIItemP: Record "LRI Item"; JobTypeP: Code[20])
    begin
        this.JobType := JobTypeP;
        this.LRIItem := LRIItemP;
    end;

    var
        ConfigTemplateHeader: Record "Config. Template Header";
        AANBSetup: Record "AANB Setup";
        LRIItem: Record "LRI Item";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        JobType: Code[20];
}
