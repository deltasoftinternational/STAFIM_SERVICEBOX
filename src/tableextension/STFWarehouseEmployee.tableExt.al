tableextension 75103 "STF Warehouse Employee" extends "Warehouse Employee"//7301
{
    fields
    {
        field(75100; "Service BOX Location"; Boolean) { Caption = 'Service BOX Location'; DataClassification = CustomerContent; }
        field(75101; "Service BOX Post"; Code[20]) { Caption = 'Service BOX Post'; DataClassification = CustomerContent; }

    }
}