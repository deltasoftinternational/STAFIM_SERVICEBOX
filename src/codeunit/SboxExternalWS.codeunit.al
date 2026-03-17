codeunit 75100 "SBox External WS"
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

            '09':
                exit(BL.LZRC23T09(Vin, RqType));

            '51':
                exit(BL.LZRF51T51(
                    DOSSIER_DMS_ID,
                    RDV_DMS_ID,
                    CODE_INTERR_DMS
                ));
            '52':
                exit(BL.LZRF52T52(ClientDmsId, VehiculeDmsId));

            '53':
                exit(BL.LZRF53T53(VehiculeDmsId));


            else begin
                exit(
                    '<ERROR Code="99" TexteDMS="RqType non supporté : ' + RqType + '" />'
                );
            end;
        end;
    end;


    procedure GetDmsResponseXmlLV(InStreamXml: Text; var OutResponseXml: Text)
    var
        XMLDomReq: XmlDocument;
        XMLDomResp: XmlDocument;
        RootResp: XmlElement;
        RootReq: XmlElement;
        RqType: Text[30];
    begin

        // 1️⃣ Lecture du XML entrant
        if not XmlDocument.ReadFrom(InStreamXml, XMLDomReq) then begin
            OutResponseXml := '<DMS CODE="-2" TexteDMS="Erreur lecture XML entrant"/>';
            exit;
        end;

        // 2️⃣ récupérer la racine directement
        XMLDomReq.GetRoot(RootReq);

        if not XMLDomReq.GetRoot(RootReq) then begin
            OutResponseXml := '<DMS CODE="-3" TexteDMS="Racine XML absente"/>';
            exit;
        end;

        // 3️⃣ créer le document réponse
        XMLDomResp := XmlDocument.Create();

        RootResp := XmlElement.Create('DMS');
        XMLDomResp.Add(RootResp);

        // 4️⃣ lire les attributs
        ParseRequeste(RootReq);

        RqType := GetAttributeValue(RootReq, 'TYPE');
        RootResp.SetAttribute('RqType', RqType);
        // 5️⃣ router vers le Business Layer
        case RqType of

            '01':
                BizLayer.LZRC01T01V1(RootResp, RootReq, RqType); // On passe RootResp (XmlElement)
            '02':
                BizLayer.LZRC02T02V1(VEHICULE_DMS_ID, VIN, IMMATRICULATION, RootReq, RqType);

            '03':
                BizLayer.LZRC03T03V1(CLIENT_DMS_ID, RootReq, RqType);

            '05':
                BizLayer.LZRC07T05V1(CLIENT_DMS_ID, RootReq, RootReq, RqType);

            /* '06':
                BizLayer.LZRC08T06V1(XMLDomResp, RootReq, RqType);

            '09':
                BizLayer.LZRC23T09V1(VEHICULE_DMS_ID, RootReq, RqType);

            '13':
                BizLayer.LZRF10T13(XMLDomResp, RootReq);

            '22':
                BizLayer.LZRF45T22V1(XMLDomResp, RootReq);

            '51':
                BizLayer.LZRF51T51V1(RootReq, RootReq);

            '52':
                BizLayer.LZRF52T52V1(XMLDomResp, RootReq);

            '53':
                BizLayer.LZRF53T53V1(XMLDomResp, RootReq); */

            else begin
                RootResp.SetAttribute('CODE', '-4');
                RootResp.SetAttribute('TexteDMS', 'Type inconnu');
            end;
        end;

        // 6️⃣ transformer en texte
        XMLDomResp.WriteTo(OutResponseXml);

    end;

    procedure GetAttributeValue(CurrentElement: XmlElement; AttributeName: Text): Text
    var
        XAttr: XmlAttribute;
    begin
        if CurrentElement.Attributes().Get(AttributeName, XAttr) then
            exit(XAttr.Value());

        exit('');
    end;

    procedure CheckStatus(var XMLText: Text)
    var
        BL: Codeunit "Business Layer";
        XMLDom: XmlDocument;
        XMLRoot: XmlElement;
    begin
        // 1. Initialiser le document XML
        XMLDom := XmlDocument.Create();

        // 2. Créer l'élément racine <DMS>
        XMLRoot := XmlElement.Create('DMS');
        XMLDom.Add(XMLRoot);

        // 3. Appeler la logique métier dans le Business Layer
        // Note : BL.CheckStatus doit accepter un XmlDocument en 'var'
        BL.CheckStatus(XMLDom);

        // 4. Transformer le DOM en texte pour le renvoyer au .NET
        // C'est ce paramètre XMLText qui sera récupéré par votre relais
        XMLDom.WriteTo(XMLText);
    end;

    procedure ParseRequeste(XmlNode: XmlElement)
    begin

        RqType := GetAttributeValue(XmlNode, 'TYPE');

        NumeroPoste := GetAttributeValue(XmlNode, 'NumeroPoste');
        PARAMDMS := GetAttributeValue(XmlNode, 'PARAMDMS');

        case RqType of

            '02':
                begin
                    VEHICULE_DMS_ID := GetAttributeValue(XmlNode, 'VEHICULE_DMS_ID');
                    VIN := GetAttributeValue(XmlNode, 'VIN');
                    IMMATRICULATION := GetAttributeValue(XmlNode, 'IMMATRICULATION');
                end;

            '03', '05':
                begin
                    CLIENT_DMS_ID := GetAttributeValue(XmlNode, 'CLIENT_DMS_ID');
                end;

            '06':
                begin
                    CODE_INTERROGATION := GetAttributeValue(XmlNode, 'CODE_INTERROGATION');
                    CHAMPS_CMPL := GetAttributeValue(XmlNode, 'CHAMPS_CMPL');
                end;

            '09':
                begin
                    VEHICULE_DMS_ID := GetAttributeValue(XmlNode, 'VEHICULE_DMS_ID');
                end;

            '11':
                begin
                    VEHICULE_DMS_ID := GetAttributeValue(XmlNode, 'VEHICULE_DMS_ID');
                    CLIENT_DMS_ID := GetAttributeValue(XmlNode, 'CLIENT_DMS_ID');
                    ORIGINEVENTE := GetAttributeValue(XmlNode, 'ORIGINEVENTE');
                end;

        end;

    end;


    procedure GetDmsResponseXmlLVVVV(InStreamXml: Text; var OutResponseXml: Text)
    var
        XMLDomReq: XmlDocument;
        XMLDomResp: XmlDocument;
        RootResp: XmlElement;
        DMSNodeList: XmlNodeList;
        DMSNode: XmlNode;
        CurrentDMS: XmlElement;
        RqType: Text[30];
        FinalResponseText: Text;
        SingleResponseText: Text;
    begin
        // 1️⃣ Lecture du XML entrant (contenant <ROOT>)
        if not XmlDocument.ReadFrom(InStreamXml, XMLDomReq) then begin
            OutResponseXml := '<DMS CODE="-2" TexteDMS="Erreur lecture XML entrant"/>';
            exit;
        end;

        // 2️⃣ Récupérer tous les éléments <DMS> sous la racine <ROOT>
        // Cela remplace la logique de lecture directe de la racine pour gérer le multi-DMS
        if not XMLDomReq.SelectNodes('//DMS', DMSNodeList) then begin
            OutResponseXml := '<DMS CODE="-3" TexteDMS="Aucune balise DMS trouvée dans ROOT"/>';
            exit;
        end;

        FinalResponseText := '';

        // 3️⃣ Boucle sur chaque bloc DMS (Logique équivalente au traitement par message)
        foreach DMSNode in DMSNodeList do begin
            CurrentDMS := DMSNode.AsXmlElement();

            // Initialisation des variables de travail pour ce message (important pour BizLayer)
            ClearVariables();

            // Créer le document réponse pour ce bloc précis
            XMLDomResp := XmlDocument.Create();
            RootResp := XmlElement.Create('DMS');
            XMLDomResp.Add(RootResp);

            // 4️⃣ Extraire les attributs (Comme dans l'ancienne procédure ParseRequest)
            // On récupère les valeurs directement depuis CurrentDMS (le bloc <DMS> en cours)
            RqType := GetAttributeValue(CurrentDMS, 'TYPE');
            CLIENT_DMS_ID := GetAttributeValue(CurrentDMS, 'CLIENT_DMS_ID');
            VEHICULE_DMS_ID := GetAttributeValue(CurrentDMS, 'VEHICULE_DMS_ID');
            VIN := GetAttributeValue(CurrentDMS, 'VIN');

            RootResp.SetAttribute('RqType', RqType);

            // 5️⃣ Routage vers le Business Layer (Même logique que Codeunit 50004)
            case RqType of
                '01':
                    BizLayer.LZRC01T01V1(RootResp, CurrentDMS, RqType);
                '02':
                    BizLayer.LZRC02T02V1(VEHICULE_DMS_ID, VIN, '', CurrentDMS, RqType);
                '03':
                    BizLayer.LZRC03T03V1(CLIENT_DMS_ID, RootResp, RqType);

                //BizLayer.LZRC03T03V1(CLIENT_DMS_ID, CurrentDMS, RqType);
                '05':
                    BizLayer.LZRC07T05V1(CLIENT_DMS_ID, RootResp, CurrentDMS, RqType);
                /* '06':
                    BizLayer.LZRC08T06V1(XMLDomResp, CurrentDMS, RqType);
                */
                '09':
                    BizLayer.LZRC23T09V1(VEHICULE_DMS_ID, CurrentDMS, RqType);
                /* '13':
                    BizLayer.LZRF10T13(XMLDomResp, CurrentDMS);
                '22':
                    BizLayer.LZRF45T22V1(XMLDomResp, CurrentDMS);
                '51':
                    BizLayer.LZRF51T51V1(CurrentDMS, CurrentDMS);
                '52':
                    BizLayer.LZRF52T52V1(XMLDomResp, CurrentDMS);
                    
                '53':
                    BizLayer.LZRF53T53V1(XMLDomResp, CurrentDMS); */
                else begin
                    RootResp.SetAttribute('CODE', '-4');
                    RootResp.SetAttribute('TexteDMS', 'Type inconnu');
                end;
            end;

            // 6️⃣ Conversion de la réponse courante en texte
            XMLDomResp.WriteTo(SingleResponseText);

            // On nettoie la déclaration XML (<?xml...?>) pour la concaténation si nécessaire
            SingleResponseText := SingleResponseText.Replace('<?xml version="1.0" encoding="utf-16"?>', '').Trim();

            // Accumulation avec le séparateur || attendu par Peugeot
            if FinalResponseText <> '' then
                FinalResponseText += '||';

            FinalResponseText += SingleResponseText;
        end;

        // 7️⃣ Retour final au proxy .NET
        OutResponseXml := FinalResponseText;
    end;

    local procedure ClearVariables()
    begin
        Clear(RqType);
        Clear(CLIENT_DMS_ID);
        Clear(VEHICULE_DMS_ID);
        Clear(VIN);
        // Ajoutez ici toutes les variables globales utilisées par votre BizLayer
    end;

    procedure GetDmsResponseXml(InStreamXml: Text; var OutResponseXml: Text)
    var
        XMLDomReq: XmlDocument;
        DMSNodeList: XmlNodeList;
        DMSNode: XmlNode;
        CurrentDMS: XmlElement;
        ResponseDMS: XmlElement;  // Le <DMS> sortant
        RqType: Text[30];
        FinalResponseText: Text;
        SingleResponseText: Text;
        TempRoot: XmlElement;
        TempDom: XmlDocument;
    begin
        // Lecture du XML entrant
        if not XmlDocument.ReadFrom(InStreamXml, XMLDomReq) then begin
            OutResponseXml := '<DMS CODE="-2" TexteDMS="Erreur lecture XML entrant"/>';
            exit;
        end;

        if not XMLDomReq.SelectNodes('//DMS', DMSNodeList) then begin
            OutResponseXml := '<DMS CODE="-3" TexteDMS="Aucune balise DMS trouvée dans ROOT"/>';
            exit;
        end;
        BizLayer.SetNumeroPostePARAMDMS(NumeroPoste, PARAMDMS);

        FinalResponseText := '';

        foreach DMSNode in DMSNodeList do begin
            CurrentDMS := DMSNode.AsXmlElement();
            ClearVariables();

            RqType := GetAttributeValue(CurrentDMS, 'TYPE');
            CLIENT_DMS_ID := GetAttributeValue(CurrentDMS, 'CLIENT_DMS_ID');
            VEHICULE_DMS_ID := GetAttributeValue(CurrentDMS, 'VEHICULE_DMS_ID');
            VIN := GetAttributeValue(CurrentDMS, 'VIN');

            // ⚡ Créer un XmlElement temporaire comme racine pour le résultat
            TempRoot := XmlElement.Create('Temp');

            case RqType of


                '01':
                    BizLayer.LZRC01T01V1(TempRoot, CurrentDMS, RqType);
                '02':
                    BizLayer.LZRC02T02V1(VEHICULE_DMS_ID, VIN, '', CurrentDMS, RqType);
                '03':
                    BizLayer.LZRC03T03V1(CLIENT_DMS_ID, TempRoot, RqType);

                //BizLayer.LZRC03T03V1(CLIENT_DMS_ID, CurrentDMS, RqType);
                '05':
                    BizLayer.LZRC07T05V1(CLIENT_DMS_ID, TempRoot, CurrentDMS, RqType);
                '06':
                    BizLayer.LZRC08T06V1(TempRoot, CurrentDMS, RqType);
                '09':
                    BizLayer.LZRC23T09V1(VEHICULE_DMS_ID, TempRoot, RqType); // <-- nouvel appel
                '13':
                    BizLayer.LZRF10T13V1(TempRoot, CurrentDMS, RqType);
                /*'22':
                    BizLayer.LZRF45T22V1(XMLDomResp, CurrentDMS);*/
                '51':
                    BizLayer.LZRF51T51V1(TempRoot, CurrentDMS);
                '52':
                    BizLayer.LZRF52T52V1(TempRoot, CurrentDMS);
                '53':
                    BizLayer.LZRF53T53V1(TempRoot, CurrentDMS);
                '11':
                    BizLayer.LZRF08T11(TempRoot, CurrentDMS, RqType);
                '23':
                    BizLayer.LZRF46T23V1(TempRoot, CurrentDMS, RqType);
                '22':
                    BizLayer.LZRF45T22V1(TempRoot, CurrentDMS, RqType);

            /* else begin
                 RootResp.SetAttribute('CODE', '-4');
                 RootResp.SetAttribute('TexteDMS', 'Type inconnu');

             end;  */



            end;

            // Conversion en texte
            TempRoot.WriteTo(SingleResponseText);
            SingleResponseText := SingleResponseText.Replace('<?xml version="1.0" encoding="utf-16"?>', '').Trim();

            // Concaténation sans balises <DMS> ni ||
            FinalResponseText += SingleResponseText;
        end;

        OutResponseXml := FinalResponseText;
    end;

    var
        CODE_INTERROGATION: Text[30];
        RqType: Text[30];
        CHAMPS_CMPL: Text[30];
        BizLayer: Codeunit "Business Layer";
        CLIENT_DMS_ID: Text[30];
        VEHICULE_DMS_ID: Text[30];
        VIN: Text[30];
        IMMATRICULATION: Text[30];
        REFERENCE_PR: Text[30];
        i: Integer;
        eDMSSetup: Record "STF Servicebox Setup";
        MQToNavision: Text[50];
        MQFromNavision: Text[50];
        PARAMDMS: Text[50];
        NumeroPoste: Text[30];
        ORIGINEVENTE: Code[1];
        Line: Text[500];
        OutStr: OutStream;

}