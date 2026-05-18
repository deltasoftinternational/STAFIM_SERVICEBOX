tableextension 75508 "SBX Service Header EDMS" extends "Service Header EDMS"//36
{
    fields
    {
        field(75500; "SBX VIN SBOX"; Code[20]) { Caption = 'VIN SBOX'; DataClassification = CustomerContent; }

        field(75501; "SBX Dossier SBOX"; Boolean) { Caption = 'Dossier SBOX'; DataClassification = CustomerContent; }
        field(75502; "SBX Order Limit"; Decimal) { Caption = 'Order Limit'; DataClassification = CustomerContent; }

    }
}