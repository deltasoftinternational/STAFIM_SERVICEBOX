pageextension 75503 "SBX SBOX User Setup Card" extends "User Setup Card" //25006075
{
    layout
    {
        addlast("General")
        {
            field("SBX ServiceBOX Code"; Rec."SBX ServiceBOX Code")
            {
                applicationArea = All;
                ToolTip = 'Specifies the value of the ServiceBOX Code field';
            }

        }
    }
}