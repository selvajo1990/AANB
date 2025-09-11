tableextension 66001 "User Setup" extends "User Setup"
{
    fields
    {
        field(66000; "Super Admin"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    procedure CallSuperAdminSilent(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId());
        exit(UserSetup."Super Admin");
    end;

    procedure IsSuperAdmin()
    var
        UserSetup: Record "User Setup";
        AdminErr: Label 'You need super admin permission to perform this acitivity';
    begin
        UserSetup.Get(UserId());
        if not UserSetup."Super Admin" then
            Error(AdminErr);
    end;
}
