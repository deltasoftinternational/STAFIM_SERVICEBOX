tableextension 75108 "STF Service Header EDMS" extends "Service Header EDMS"//36
{
    fields
    {
        field(75100; "VIN SBOX"; Code[20]) { Caption = 'VIN SBOX'; DataClassification = CustomerContent; }

        field(75101; "Dossier SBOX"; Boolean) { Caption = 'Dossier SBOX'; DataClassification = CustomerContent; }
        field(75102; "Order Limit"; Decimal) { Caption = 'Order Limit'; DataClassification = CustomerContent; }

    }
}