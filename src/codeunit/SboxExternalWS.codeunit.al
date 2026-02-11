codeunit 50101 "SBox External WS"
{
    [ServiceEnabled]
    procedure SearchCustomers(
        CodeInterrogation: Integer;
        ChampsCmpl: Text
    ): Text
    var
        BL: Codeunit "Business Layer";
    begin

        exit(BL.LZRC01T01(CodeInterrogation, ChampsCmpl))
    end;

    procedure DispatchDMSRequest(
    RqType: Text[30];
    CodeInterrogation: Integer;
    ChampsCmpl: Text;
    ClientDmsId: Code[20];
    VehiculeDmsId: Text[30];
    Vin: Text[30];
    Immatriculation: Text[30];
    DOSSIER_DMS_ID: Text[30];
    RDV_DMS_ID: Text[30];
    CODE_INTERR_DMS: Text[30]
) ResultXml: Text
    var
        BL: Codeunit "Business Layer";
    begin
        case RqType of
            '01':
                exit(BL.LZRC01T01(CodeInterrogation, ChampsCmpl));
            '02':
                exit(BL.LZRC02T02(
                   VehiculeDmsId,
                   Vin,
                   Immatriculation,
                   RqType
               ));
            '03':
                exit(BL.LZRC03T03(ClientDmsId, RqType));

            '05':
                exit(BL.LZRC07T05(ClientDmsId, RqType));
            '06':
                exit(BL.LZRC08T06(
                    Format(CodeInterrogation),
                    ChampsCmpl,
                    RqType
                ));
            '08':
                exit(BL.LZRC08T06(
                    Format(CodeInterrogation),
                    ChampsCmpl,
                    RqType
                ));

            '09':
                exit(BL.GetVehicleDetails(Vin, RqType));

            '51':
                exit(BL.LZRF51T51(
                    DOSSIER_DMS_ID,
                    RDV_DMS_ID,
                    CODE_INTERR_DMS
                ));

            else begin
                exit(
                    '<ERROR Code="99" TexteDMS="RqType non supporté : ' + RqType + '" />'
                );
            end;
        end;
    end;

}