tableextension 75501 "SBX Sales Header SB" extends "Sales Header"//36
{
    fields
    {
        field(75500; "SBX VIN SBOX"; Code[20]) { Caption = 'VIN SBOX'; DataClassification = CustomerContent; }

        field(75501; "SBX Dossier SBOX"; Boolean) { Caption = 'Dossier SBOX'; DataClassification = CustomerContent; }

    }
}