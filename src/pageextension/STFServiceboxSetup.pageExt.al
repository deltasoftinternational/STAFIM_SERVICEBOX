pageextension 75103 "STF Servicebox Setup EXT" extends "STF Servicebox Setup"
{
    layout
    {
        addafter(General)
        {
            group("Imputations")
            {
                Caption = 'Imputations';

                field("Customer Imputation Code"; Rec."Customer Imputation Code") { ApplicationArea = All; }
                field("Warranty Imputation Code"; Rec."Warranty Imputation Code") { ApplicationArea = All; }
                field("Insurance Imputation Code"; Rec."Insurance Imputation Code") { ApplicationArea = All; }
                field("Campaign Imputation Code"; Rec."Campaign Imputation Code") { ApplicationArea = All; }
                field("Contract Imputation Code"; Rec."Contract Imputation Code") { ApplicationArea = All; }
                field("Internal Imputation Code"; Rec."Internal Imputation Code") { ApplicationArea = All; }
            }

            group("Comptes d'imputation")
            {
                Caption = 'Comptes d''imputation';

                field("Customer Imputation Account"; Rec."Customer Imputation Account") { ApplicationArea = All; }
                field("Warranty Imputation Account"; Rec."Warranty Imputation Account") { ApplicationArea = All; }
                field("Insurance Imputation Account"; Rec."Insurance Imputation Account") { ApplicationArea = All; }
                field("Campaign Imputation Account"; Rec."Campaign Imputation Account") { ApplicationArea = All; }
                field("Contract Imputation Account"; Rec."Contract Imputation Account") { ApplicationArea = All; }
                field("Internal Imputation Account"; Rec."Internal Imputation Account") { ApplicationArea = All; }
            }

            group("Paramètres Service")
            {
                Caption = 'Paramètres Service';

                field("Discount allowed"; Rec."Discount allowed") { ApplicationArea = All; }
                field("Discount allowed LDT"; Rec."Discount allowed LDT") { ApplicationArea = All; }
                field("Default MO"; Rec."Default MO") { ApplicationArea = All; }
                field("ServicePAD"; Rec."ServicePAD") { ApplicationArea = All; }
            }
        }
    }
}