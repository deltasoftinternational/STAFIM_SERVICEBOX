pageextension 75100 "STF Warehouse Employees" extends "Warehouse Employees" //7328
{
    layout
    {
        addlast(Control1)
        {
            field("Service BOX Location"; Rec."Service BOX Location")
            {
                ApplicationArea = All;
            }
            field("Service BOX Post"; Rec."Service BOX Post")
            {
                ApplicationArea = All;
            }
        }
    }
}