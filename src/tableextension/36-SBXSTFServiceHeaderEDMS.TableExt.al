tableextension 75108 "SBX Service Header EDMS" extends "Service Header EDMS"//36
{
    fields
    {
        field(75100; "SBX VIN SBOX"; Code[20]) { Caption = 'VIN SBOX'; DataClassification = CustomerContent; }

        field(75101; "SBX Dossier SBOX"; Boolean) { Caption = 'Dossier SBOX'; DataClassification = CustomerContent; }
        field(75102; "SBX Order Limit"; Decimal) { Caption = 'Order Limit'; DataClassification = CustomerContent; }

    }
}