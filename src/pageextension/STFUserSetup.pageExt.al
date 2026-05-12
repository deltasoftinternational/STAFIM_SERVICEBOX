pageextension 75101 "STF SBOX User Setup Card" extends "User Setup Card" //25006075
{
    layout
    {
        addlast("General")
        {
            field("ServiceBOX Code"; Rec."ServiceBOX Code")
            {
                applicationArea = All;
                ToolTip = 'Specifies the value of the ServiceBOX Code field';
            }

        }
    }
}