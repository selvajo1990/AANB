pageextension 66002 "User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Super Admin"; Rec."Super Admin")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Super Admin', Comment = '%';
            }
        }
    }
}
