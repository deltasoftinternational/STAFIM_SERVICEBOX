pageextension 75502 "SBX Servicebox Setup EXT" extends "STF Servicebox Setup" //75006
{
    layout
    {
        addafter(General)
        {
            group("SBX Imputations")
            {
                Caption = 'Imputations';

                field("SBX Customer Imputation Code"; Rec."SBX Customer Imputation Code") { ApplicationArea = All; }
                field("SBX Warranty Imputation Code"; Rec."SBX Warranty Imputation Code") { ApplicationArea = All; }
                field("SBX Insurance Imputation Code"; Rec."SBX Insurance Imputation Code") { ApplicationArea = All; }
                field("SBX Campaign Imputation Code"; Rec."SBX Campaign Imputation Code") { ApplicationArea = All; }
                field("SBX Contract Imputation Code"; Rec."SBX Contract Imputation Code") { ApplicationArea = All; }
                field("SBX Internal Imputation Code"; Rec."SBX Internal Imputation Code") { ApplicationArea = All; }
            }

            group("Comptes d'imputation")
            {
                Caption = 'Comptes d''imputation';

                field("SBX Customer Imputation Account"; Rec."SBX Customer Imputation Account") { ApplicationArea = All; }
                field("SBX Warranty Imputation Account"; Rec."SBX Warranty Imputation Account") { ApplicationArea = All; }
                field("SBX Insurance Imputation Account"; Rec."SBX Insurance Imputation Account") { ApplicationArea = All; }
                field("SBX Campaign Imputation Account"; Rec."SBX Campaign Imputation Account") { ApplicationArea = All; }
                field("SBX Contract Imputation Account"; Rec."SBX Contract Imputation Account") { ApplicationArea = All; }
                field("SBX Internal Imputation Account"; Rec."SBX Internal Imputation Account") { ApplicationArea = All; }
            }

            group("Paramètres Service")
            {
                Caption = 'Paramètres Service';

                field("SBX Discount allowed"; Rec."SBX Discount allowed") { ApplicationArea = All; }
                field("SBX Discount allowed LDT"; Rec."SBX Discount allowed LDT") { ApplicationArea = All; }
                field("SBX Default MO"; Rec."SBX Default MO") { ApplicationArea = All; }
                field("SBX ServicePAD"; Rec."SBX ServicePAD") { ApplicationArea = All; }
            }
        }
    }
}