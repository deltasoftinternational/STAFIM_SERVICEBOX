tableextension 75506 "SBX ServiceJobLineExt" extends "Service Order Symptome  EDMS" //25006819
{
    fields
    {
        /*  field(75500; "SBX Package Version No."; Integer)
         {
             Caption = 'Version forfait';
             TableRelation = "Service Package Version"."Version No."
                                 where("Package No." = field("Package No."));
             DataClassification = CustomerContent;
         }
         field(75509; "SBX Package Type"; Enum "STF Package Type")
         {
             Caption = 'Package Type';
             DataClassification = CustomerContent;
         } */
        field(75501; "SBX Assurance"; Boolean)
        {
            Caption = 'Assurance';
            DataClassification = CustomerContent;
        }
        field(75502; "SBX SBOX LDT"; Code[30])
        {
            Caption = 'SBOX LDT';
            DataClassification = CustomerContent;
        }
        field(75503; "SBX SBOX CodeTypeVehicule"; Code[30])
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75505; "SBX SBOX TYPE IMPUTATION"; Code[30])
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75506; "SBX SBOX Forfait"; Code[30])
        {
            Caption = 'SBOX Forfait';
            DataClassification = CustomerContent;
        }
        field(75507; "SBX SBOX PrixHT Forfait"; Decimal)
        {
            Caption = 'SBOX CodeTypeVehicule';
            DataClassification = CustomerContent;
        }
        field(75508; "SBX SBOX PrixTTC Forfait"; Decimal)
        {
            Caption = 'SBOX PrixTTC Forfait';
            DataClassification = CustomerContent;
        }
    }
}