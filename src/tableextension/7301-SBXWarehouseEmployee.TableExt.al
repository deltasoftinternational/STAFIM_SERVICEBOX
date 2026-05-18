tableextension 75103 "SBX Warehouse Employee" extends "Warehouse Employee"//7301
{
    fields
    {
        field(75100; "SBX Service BOX Location"; Boolean) { Caption = 'Service BOX Location'; DataClassification = CustomerContent; }
        field(75101; "SBX Service BOX Post"; Code[20]) { Caption = 'Service BOX Post'; DataClassification = CustomerContent; }
        field(75103; "SBX Service Location Code"; Code[10])
        {
            Caption = 'Service Location Code';
            TableRelation = Location;
        }
    }
}