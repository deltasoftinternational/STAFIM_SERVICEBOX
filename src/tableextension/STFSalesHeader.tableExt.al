tableextension 75101 "STF Sales Header SB" extends "Sales Header"//36
{
    fields
    {
        field(75100; "VIN SBOX"; Code[20]) { Caption = 'VIN SBOX'; DataClassification = CustomerContent; }

        field(75101; "Dossier SBOX"; Boolean) { Caption = 'Dossier SBOX'; DataClassification = CustomerContent; }

    }
}