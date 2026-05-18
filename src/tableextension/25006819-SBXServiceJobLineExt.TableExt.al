tableextension 75106 "SBX ServiceJobLineExt" extends "Service Order Symptome  EDMS" //25006819
{
    fields
    {
        /*  field(75100; "SBX Package Version No."; Integer)
         {
             Caption = 'Version forfait';
             TableRelation = "Service Package Version"."Version No."
                                 where("Package No." = field("Package No."));
             DataClassification = CustomerContent;
         }
         field(75109; "SBX Package Type"; Enum "STF Package Type")
         {
             Caption = 'Package Type';
             DataClassification = CustomerContent;
         } */
        field(75101; "SBX Assurance"; Boolean)
        {
            Caption = 'Assurance';
            DataClassification = CustomerContent;
        }
        field(75102; "SBX SBOX LDT"; Code[30])
        {
            Caption = 'SBOX LDT';
            DataClassification = CustomerContent;
        }
        field(75103; "SBX SBOX CodeTypeVehicule"; Code[30])
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75105; "SBX SBOX TYPE IMPUTATION"; Code[30])
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75106; "SBX SBOX Forfait"; Code[30])
        {
            Caption = 'SBOX Forfait';
            DataClassification = CustomerContent;
        }
        field(75107; "SBX SBOX PrixHT Forfait"; Decimal)
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75108; "SBX SBOX PrixTTC Forfait"; Decimal)
        {
            Caption = 'SBOX PrixTTC Forfait';
            DataClassification = CustomerContent;
        }
    }
}