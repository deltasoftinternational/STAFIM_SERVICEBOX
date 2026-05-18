pageextension 75100 "SBX Warehouse Employees" extends "Warehouse Employees" //7328
{
    layout
    {
        addlast(Control1)
        {
            field("SBX Service BOX Location"; Rec."SBX Service BOX Location")
            {
                ApplicationArea = All;
            }
            field("SBX Service BOX Post"; Rec."SBX Service BOX Post")
            {
                ApplicationArea = All;
            }

            field("SBX Service Location Code"; Rec."SBX Service Location Code")
            {
                ApplicationArea = All;
            }
        }
    }
}