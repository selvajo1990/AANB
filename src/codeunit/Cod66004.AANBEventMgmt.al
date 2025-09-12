// codeunit 66004 "AANB Event Mgmt."
// {
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
//     local procedure ReleaseSalesDocument_OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
//     begin
//         Message('Order released for LRI validation');
//     end;

// }
