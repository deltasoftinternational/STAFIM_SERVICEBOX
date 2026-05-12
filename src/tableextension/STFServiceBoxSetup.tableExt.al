tableextension 75100 "STF SBOX Setup Ext" extends "STF Servicebox Setup" //75002
{
    fields
    {
        // Imputation Codes
        field(75100; "Customer Imputation Code"; Integer) { Caption = 'Code d''imputation CLIENT'; DataClassification = CustomerContent; }
        field(75101; "Warranty Imputation Code"; Integer) { Caption = 'Code d''imputation GARANTIE'; DataClassification = CustomerContent; }
        field(75102; "Insurance Imputation Code"; Integer) { Caption = 'Code d''imputation ASSURANCE'; DataClassification = CustomerContent; }
        field(75103; "Campaign Imputation Code"; Integer) { Caption = 'Code d''imputation CAMPAGNE'; DataClassification = CustomerContent; }
        field(75104; "Contract Imputation Code"; Integer) { Caption = 'Code d''imputation CONTRAT'; DataClassification = CustomerContent; }
        field(75105; "Internal Imputation Code"; Integer) { Caption = 'Code d''imputation INTERNE'; DataClassification = CustomerContent; }

        // --- COMPTES (Les numéros de clients dans BC : "C0001", "C9999"...) ---
        field(75120; "Customer Imputation Account"; Code[20]) { Caption = 'Client d''imputation CLIENT'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75121; "Warranty Imputation Account"; Code[20]) { Caption = 'Client d''imputation GARANTIE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75122; "Insurance Imputation Account"; Code[20]) { Caption = 'Client d''imputation ASSURANCE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75123; "Campaign Imputation Account"; Code[20]) { Caption = 'Client d''imputation CAMPAGNE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75124; "Contract Imputation Account"; Code[20]) { Caption = 'Client d''imputation CONTRAT'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75125; "Internal Imputation Account"; Code[20]) { Caption = 'Client d''imputation INTERNE'; TableRelation = Customer; DataClassification = CustomerContent; }

        // --- Autres champs ---
        field(75107; "Discount allowed"; Boolean) { Caption = 'Discount allowed'; DataClassification = CustomerContent; }
        field(75108; "Discount allowed LDT"; Boolean) { Caption = 'Discount allowed LDT'; DataClassification = CustomerContent; }
        field(75109; "Default MO"; Code[20]) { Caption = 'Default MO'; TableRelation = "Service Labor"; DataClassification = CustomerContent; }
        field(75110; "ServicePAD"; Boolean) { Caption = 'ServicePAD'; DataClassification = CustomerContent; }
    }
}