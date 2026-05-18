tableextension 75101 "SBX Sales Header SB" extends "Sales Header"//36
{
    fields
    {
        field(75100; "SBX VIN SBOX"; Code[20]) { Caption = 'VIN SBOX'; DataClassification = CustomerContent; }

        field(75101; "SBX Dossier SBOX"; Boolean) { Caption = 'Dossier SBOX'; DataClassification = CustomerContent; }

    }
}