pageextension 75102 "STF Location" extends "Location Card"
{

    layout
    {
        addlast(General)
        {
            field("Display in Service Box"; Rec."Display in Service BOX")
            {
                ApplicationArea = All;
            }
        }
    }
}