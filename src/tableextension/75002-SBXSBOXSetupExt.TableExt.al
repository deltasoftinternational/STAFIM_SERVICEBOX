tableextension 75100 "SBX SBOX Setup Ext" extends "STF Servicebox Setup" //75002
{
    fields
    {
        // Imputation Codes
        field(75100; "SBX Customer Imputation Code"; Integer) { Caption = 'Code d''imputation CLIENT'; DataClassification = CustomerContent; }
        field(75101; "SBX Warranty Imputation Code"; Integer) { Caption = 'Code d''imputation GARANTIE'; DataClassification = CustomerContent; }
        field(75102; "SBX Insurance Imputation Code"; Integer) { Caption = 'Code d''imputation ASSURANCE'; DataClassification = CustomerContent; }
        field(75103; "SBX Campaign Imputation Code"; Integer) { Caption = 'Code d''imputation CAMPAGNE'; DataClassification = CustomerContent; }
        field(75104; "SBX Contract Imputation Code"; Integer) { Caption = 'Code d''imputation CONTRAT'; DataClassification = CustomerContent; }
        field(75105; "SBX Internal Imputation Code"; Integer) { Caption = 'Code d''imputation INTERNE'; DataClassification = CustomerContent; }

        // --- COMPTES (Les numéros de clients dans BC : "C0001", "C9999"...) ---
        field(75120; "SBX Customer Imputation Account"; Code[20]) { Caption = 'Client d''imputation CLIENT'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75121; "SBX Warranty Imputation Account"; Code[20]) { Caption = 'Client d''imputation GARANTIE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75122; "SBX Insurance Imputation Account"; Code[20]) { Caption = 'Client d''imputation ASSURANCE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75123; "SBX Campaign Imputation Account"; Code[20]) { Caption = 'Client d''imputation CAMPAGNE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75124; "SBX Contract Imputation Account"; Code[20]) { Caption = 'Client d''imputation CONTRAT'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75125; "SBX Internal Imputation Account"; Code[20]) { Caption = 'Client d''imputation INTERNE'; TableRelation = Customer; DataClassification = CustomerContent; }

        // --- Autres champs ---
        field(75107; "SBX Discount allowed"; Boolean) { Caption = 'Discount allowed'; DataClassification = CustomerContent; }
        field(75108; "SBX Discount allowed LDT"; Boolean) { Caption = 'Discount allowed LDT'; DataClassification = CustomerContent; }
        field(75109; "SBX Default MO"; Code[20]) { Caption = 'Default MO'; TableRelation = "Service Labor"; DataClassification = CustomerContent; }
        field(75110; "SBX ServicePAD"; Boolean) { Caption = 'ServicePAD'; DataClassification = CustomerContent; }
    }
}