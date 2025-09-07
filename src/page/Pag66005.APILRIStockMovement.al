page 66005 APILRIStockMovement
{
    APIGroup = 'apiGroup';
    APIPublisher = 'Quantum';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'apiv2LRIStockMovement';
    DelayedInsert = true;
    EntityName = 'syncStockTransaction';
    EntitySetName = 'syncStockTransactions';
    PageType = API;
    SourceTable = "LRI Stock Movement";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(productId; Rec."Product Id")
                {
                    Caption = 'Product Id';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(qty; Rec.Qty)
                {
                    Caption = 'Qty';
                }
                field(price; Rec.Price)
                {
                    Caption = 'Price';
                }
                field(totalAmount; Rec."Total Amount")
                {
                    Caption = 'Total Amount';
                }
                field(totalVATAmount; Rec."Total VAT Amount")
                {
                    Caption = 'Total VAT Amount';
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type';
                }
                field(entryDate; Rec."Entry Date")
                {
                    Caption = 'Entry Date';
                }
                field(entryTime; Rec."Entry Time")
                {
                    Caption = 'Entry Time';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }

                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code';
                }
                field(reasonDescription; Rec."Reason Description")
                {
                    Caption = 'Reason Description';
                }
                field(processed; Rec.Processed)
                {
                    Caption = 'Processed';
                }
                field(processedDate; Rec."Processed Date")
                {
                    Caption = 'Processed Date';
                }
                field(processedTime; Rec."Processed Time")
                {
                    Caption = 'Processed Time';
                }
            }
        }
    }
}
