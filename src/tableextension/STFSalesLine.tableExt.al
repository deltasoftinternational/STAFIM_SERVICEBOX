tableextension 75102 "STF Sales Line SB" extends "Sales Line"//36
{
    fields
    {
        field(75100; "Line LDT"; Code[20]) { Caption = 'Ligne LDT'; DataClassification = CustomerContent; }
        field(75101; "Line LDT Filter"; Code[20]) { Caption = 'Ligne LDT Filter'; DataClassification = CustomerContent; }


    }
}