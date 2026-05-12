tableextension 75106 "STF ServiceJobLineExt" extends "Service Order Symptome  EDMS"
{
    fields
    {
        /*  field(75100; "Package Version No."; Integer)
         {
             Caption = 'Version forfait';
             TableRelation = "Service Package Version"."Version No."
                                 where("Package No." = field("Package No."));
             DataClassification = CustomerContent;
         }
         field(75109; "Package Type"; Enum "STF Package Type")
         {
             Caption = 'Package Type';
             DataClassification = CustomerContent;
         } */
        field(75101; Assurance; Boolean)
        {
            Caption = 'Assurance';
            DataClassification = CustomerContent;
        }
        field(75102; "SBOX LDT"; Code[30])
        {
            Caption = 'SBOX LDT';
            DataClassification = CustomerContent;
        }
        field(75103; "SBOX CodeTypeVehicule"; Code[30])
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75105; "SBOX TYPE IMPUTATION"; Code[30])
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75106; "SBOX Forfait"; Code[30])
        {
            Caption = 'SBOX Forfait';
            DataClassification = CustomerContent;
        }
        field(75107; "SBOX PrixHT Forfait"; Decimal)
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75108; "SBOX PrixTTC Forfait"; Decimal)
        {
            Caption = 'SBOX PrixTTC Forfait';
            DataClassification = CustomerContent;
        }
    }
}