table 75100 "SBX Package Line"
{
    Caption = 'SBOX Package Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Enum "Service Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Service Header EDMS"."No." where("Document Type" = field("Document Type"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = " ",Item,Labor;
            OptionCaption = ' ,Item,Labor';
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if Quantity < 0 then
                    FieldError(Quantity);
            end;
        }
        field(7; "Package No."; Code[14])
        {
            Caption = 'Package No.';
        }
        field(8; "Package Version No."; Integer)
        {
            Caption = 'Package Version No.';
        }
        field(9; "Code Type Veh"; Code[20])
        {
            Caption = 'Code Type Veh';
            // Extrait des caractères 15+ du IDFORFAIT SBOX
        }
        field(10; "SBOX MO"; Code[20])
        {
            Caption = 'SBOX MO';
            // Conserve le code MO original quand fallback sur Default MO
        }
        field(11; "Service Job No."; Integer)
        {
            Caption = 'Service Job No.';
            // Lien optionnel vers Service Order Symptome (Task No.)
        }
        field(12; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 5;
        }

        field(13; "Unit Price Incl. VAT"; Decimal)
        {
            Caption = 'Unit Price Incl. VAT';
            DecimalPlaces = 0 : 5;
        }

    }

    keys
    {
        key(PK; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(K2; "Document Type", "Document No.", "Package No.", "Package Version No.", "Code Type Veh")
        {
            // Utilisé dans DeleteLDT pour filtrer et supprimer les lignes SBOX
        }
    }
}
