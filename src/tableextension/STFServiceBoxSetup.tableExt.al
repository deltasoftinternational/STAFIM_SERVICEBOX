tableextension 75100 "STF SBOX Setup Ext" extends "STF Servicebox Setup" //75002
{
    fields
    {
        // Imputation Codes
        field(50000; "Customer Imputation Code"; Code[20]) { Caption = 'Code d''imputation CLIENT'; DataClassification = CustomerContent; }
        field(50001; "Warranty Imputation Code"; Code[20]) { Caption = 'Code d''imputation GARANTIE'; DataClassification = CustomerContent; }
        field(50002; "Insurance Imputation Code"; Code[20]) { Caption = 'Code d''imputation ASSURANCE'; DataClassification = CustomerContent; }
        field(50003; "Campaign Imputation Code"; Code[20]) { Caption = 'Code d''imputation CAMPAGNE'; DataClassification = CustomerContent; }
        field(50004; "Contract Imputation Code"; Code[20]) { Caption = 'Code d''imputation CONTRAT'; DataClassification = CustomerContent; }
        field(50005; "Internal Imputation Code"; Code[20]) { Caption = 'Code d''imputation INTERNE'; DataClassification = CustomerContent; }
        field(50006; "Service PAD"; Boolean) { Caption = 'Code d''imputation INTERNE'; DataClassification = CustomerContent; }
        field(50007; "Discount allowed"; Boolean) { Caption = 'Discount allowed'; DataClassification = CustomerContent; }
        field(50008; "Discount allowed LDT"; Boolean) { Caption = 'Discount allowed'; DataClassification = CustomerContent; }
    }
}