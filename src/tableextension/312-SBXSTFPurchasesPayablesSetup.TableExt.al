/* tableextension 75507 "STF Purchases & Payables Setup" extends "Purchases & Payables Setup"//312
{
    fields
    {

        field(75000; "SBX STF Templ. Item"; Code[20])
        {
            Caption = 'Modèle article';
            TableRelation = "Item Templ.";
            DataClassification = ToBeClassified;
        }

    }
} */
