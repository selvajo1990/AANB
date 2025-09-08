permissionset 66000 "AANB-Super"
{
    Assignable = true;
    Permissions = tabledata "AANB Setup" = RIMD,
        tabledata "API Template Setup" = RIMD,
        tabledata "API Transaction Log" = RIMD,
        tabledata "Integration Data Log" = RIMD,
        tabledata "LRI Item" = RIMD,
        tabledata "LRI Stock Movement" = RIMD,
        table "AANB Setup" = X,
        table "API Template Setup" = X,
        table "API Transaction Log" = X,
        table "Integration Data Log" = X,
        table "LRI Item" = X,
        table "LRI Stock Movement" = X,
        report "Clear API Transaction Log" = X,
        codeunit "AANB Integation Mgmt." = X,
        codeunit "Cron Job Mgmt." = X,
        codeunit "Integration Data Mgmt." = X,
        codeunit "LRI Integration Mgmt." = X,
        page "AANB Setup" = X,
        page "API Template Setup List" = X,
        page "API Transaction Log List" = X,
        page "Integration Data Log" = X,
        page "LRI Items" = X,
        page "LRI Stock Movements" = X;
}