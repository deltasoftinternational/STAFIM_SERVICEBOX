tableextension 75500 "SBX SBOX Setup Ext" extends "STF Servicebox Setup" //75002
{
    fields
    {
        // Imputation Codes
        field(75500; "SBX Customer Imputation Code"; Integer) { Caption = 'Code d''imputation CLIENT'; DataClassification = CustomerContent; }
        field(75501; "SBX Warranty Imputation Code"; Integer) { Caption = 'Code d''imputation GARANTIE'; DataClassification = CustomerContent; }
        field(75502; "SBX Insurance Imputation Code"; Integer) { Caption = 'Code d''imputation ASSURANCE'; DataClassification = CustomerContent; }
        field(75503; "SBX Campaign Imputation Code"; Integer) { Caption = 'Code d''imputation CAMPAGNE'; DataClassification = CustomerContent; }
        field(75504; "SBX Contract Imputation Code"; Integer) { Caption = 'Code d''imputation CONTRAT'; DataClassification = CustomerContent; }
        field(75505; "SBX Internal Imputation Code"; Integer) { Caption = 'Code d''imputation INTERNE'; DataClassification = CustomerContent; }

        // --- COMPTES (Les numéros de clients dans BC : "C0001", "C9999"...) ---
        field(75520; "SBX Customer Imputation Account"; Code[20]) { Caption = 'Client d''imputation CLIENT'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75521; "SBX Warranty Imputation Account"; Code[20]) { Caption = 'Client d''imputation GARANTIE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75522; "SBX Insurance Imputation Account"; Code[20]) { Caption = 'Client d''imputation ASSURANCE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75523; "SBX Campaign Imputation Account"; Code[20]) { Caption = 'Client d''imputation CAMPAGNE'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75524; "SBX Contract Imputation Account"; Code[20]) { Caption = 'Client d''imputation CONTRAT'; TableRelation = Customer; DataClassification = CustomerContent; }
        field(75525; "SBX Internal Imputation Account"; Code[20]) { Caption = 'Client d''imputation INTERNE'; TableRelation = Customer; DataClassification = CustomerContent; }

        // --- Autres champs ---
        field(75507; "SBX Discount allowed"; Boolean) { Caption = 'Discount allowed'; DataClassification = CustomerContent; }
        field(75508; "SBX Discount allowed LDT"; Boolean) { Caption = 'Discount allowed LDT'; DataClassification = CustomerContent; }
        field(75509; "SBX Default MO"; Code[20]) { Caption = 'Default MO'; TableRelation = "Service Labor"; DataClassification = CustomerContent; }
        field(75510; "SBX ServicePAD"; Boolean) { Caption = 'ServicePAD'; DataClassification = CustomerContent; }
    }
}