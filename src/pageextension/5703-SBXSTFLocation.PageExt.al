pageextension 75102 "SBX STF Location" extends "Location Card" //5703
{

    layout
    {
        addlast(General)
        {
            field("SBX Display in Service Box"; Rec."SBX Display in Service BOX")
            {
                ApplicationArea = All;
            }
        }
    }
}