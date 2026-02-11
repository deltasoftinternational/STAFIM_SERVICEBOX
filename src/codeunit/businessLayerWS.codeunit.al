codeunit 50100 "Business Layer"
{

    local procedure MapTypeClient(TypeCust: Integer): Integer
    begin
        case TypeCust of
            0:
                exit(1);
            1:
                exit(2);
            2:
                exit(4);
        end;
    end;



    procedure GetClientsDMSOLD(CodeInterrogation: Integer; ChampsCmpl: Text) ResultXml: Text
    var
        Cust: Record Customer;
        XmlBody: Text;
        Count: Integer;
    begin
        XmlBody := '';
        Count := 0;

        Cust.Reset();
        case CodeInterrogation of
            1:
                Cust.SetFilter(Name, '@*' + ChampsCmpl + '*');
            2:
                Cust.SetFilter("Phone No.", '@*' + ChampsCmpl + '*');
            4:
                Cust.SetFilter("No.", '@*' + ChampsCmpl + '*');
            5:
                Cust.SetFilter("E-Mail", '@*' + ChampsCmpl + '*');
            6:
                Cust.SetFilter("Mobile Phone No.", '@*' + ChampsCmpl + '*');
        end;

        if Cust.FindSet() then
            repeat
                XmlBody +=
                    '    <CLIENT ' +
                    'CLIENT_DMS_ID="' + Cust."No." + '" ' +
                    'TypeClient="2" ' +
                    'Nom="' + Cust.Name + '" ' +
                    'Prenom="' + Cust."Name 2" + '" ' +
                    'Adresse1="' + Cust.Address + '" ' +
                    'Ville="' + Cust.City + '" ' +
                    'CodePostal="' + Cust."Post Code" + '" ' +
                    'NumeroCompte="' + Cust."No." + '" ' +
                    '/>' + '\r\n';

                Count += 1;
                if Count = 30 then
                    break;
            until Cust.Next() = 0;

        ResultXml :=
            '<LZRC01 Code="0" TexteDMS="' +
            Format(Count) + ' Clients trouvés.">' + '\r\n' +
            XmlBody +
            '</LZRC01>';

        exit(ResultXml);
    end;


    /************* INTERROGATION LISTE CLIENTS DEPUIS CRITERES SAISIS ****************/
    procedure LZRC01T01(CodeInterrogation: Integer; ChampsCmpl: Text) ResultXml: Text
    var
        Cust: Record Customer;
        XmlBody: Text;
        Count: Integer;
        CodeResult: Text;
        TexteDMS: Text;
        TypeCust: Integer;
    begin
        XmlBody := '';
        Count := 0;

        Cust.Reset();
        //tofix
        //Cust.SetRange(Blocked, false);

        case CodeInterrogation of
            1:
                Cust.SetFilter(Name, '@*' + ChampsCmpl + '*');
            2:
                Cust.SetFilter("Phone No.", '@*' + ChampsCmpl + '*');
            //3:
            // Cust.SetFilter(, '@*' + ChampsCmpl + '*');
            4:
                Cust.SetFilter("No.", '@*' + ChampsCmpl + '*');
            5:
                Cust.SetFilter("E-Mail", '@*' + ChampsCmpl + '*');
            6:
                Cust.SetFilter("Mobile Phone No.", '@*' + ChampsCmpl + '*');
        end;

        if Cust.FindSet() then
            repeat
                //tofix
                //TypeCust := Cust."Customer Type";

                XmlBody += '    <CLIENT ' +
                           'CLIENT_DMS_ID="' + Cust."No." + '" ';

                // 🔹 Mapping TypeClient + champs associés
                /* case TypeCust of
                    0:
                        begin
                            XmlBody +=
                                'TypeClient="1" ' +
                                'Nom="' + Cust."Last Name" + '" ' +
                                'Prenom="' + Cust."First Name" + '" ';
                        end;
                    1:
                        begin
                            XmlBody +=
                                'TypeClient="2" ' +
                                'Nom="' + Cust."Last Name" + '" ' +
                                'Prenom="' + Cust."First Name" + '" ';
                        end;
                    2:
                        begin
                            XmlBody +=
                                'TypeClient="4" ' +
                                'TypeEntreprise="' + Cust."Title Code" + '" ' +
                                'RaisonSociale="' + Cust.Name + '" ';
                        end;
                end; */

                // 🔹 Champs communs
                XmlBody +=
                    'NumeroVoie="" ' +
                    'TypeVoie="" ' +
                    'TypeClient="2" ' +
                    'Nom="' + Cust.Name + '" ' +
                    'Prenom="' + Cust."Name 2" + '" ' +
                    'Adresse1="' + Cust.Address + '" ' +
                    'Ville="' + Cust.City + '" ' +
                    'CodePostal="' + Cust."Post Code" + '" ' +
                    'NumeroCompte="' + Cust."No." + '" />' + '\r\n';





                Count += 1;
                if Count = 30 then
                    break;
            until Cust.Next() = 0;

        // 🔹 Gestion Code / TexteDMS
        if Cust.Count = 1 then begin
            CodeResult := '0';
            TexteDMS := '';
            // ici tu peux appeler une autre procédure équivalente à LZRC03T03 si nécessaire
        end else
            if (Cust.Count > 1) and (Cust.Count < 30) then begin
                CodeResult := '0';
                TexteDMS := Format(Count) + ' Clients trouvés.';
            end else
                if Cust.Count >= 30 then begin
                    CodeResult := '95';
                    TexteDMS := 'Nombre de réponses trop grand. Précisez les paramètres de recherche.';
                end else begin
                    CodeResult := '99';
                    TexteDMS := 'Aucun Client trouvé avec ces critères !';
                    XmlBody := '    <CLIENT />' + '\r\n';
                end;

        ResultXml :=
            '<LZRC01 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRC01>';

        exit(ResultXml);
    end;
    /*********************INTERROGATION DES DONNEES D'UN CLIENT CONNU*************/
    procedure LZRC03T03(ClientDmsId: Code[20]; RqType: Text[30]) ResultXml: Text
    var
        Cust: Record Customer;
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;

        // TypeCust contient la valeur du champ "Customer Type" du client
        // 0 = Particulier
        // 1 = Professionnel
        // 2 = Entreprise
        TypeCust: Integer;

        Pays: Text;
    begin
        XmlBody := '';

        Cust.Reset();
        Cust.SetFilter("No.", '%1', ClientDmsId);

        if Cust.FindSet() then begin
            CodeResult := '0';
            TexteDMS := '';

            repeat
                // Lecture du type de client depuis la fiche client
                //tofix
                //TypeCust := Cust."Customer Type";
                TypeCust := 0;
                XmlBody += '    <CLIENT ' +
                           'CLIENT_DMS_ID="' + Cust."No." + '" ';

                // ---------------------------------------------------------
                // Mapping Business Central → DMS
                // ---------------------------------------------------------
                // Customer Type = 0 (Particulier)
                // → TypeClient DMS = 1
                // → Nom + Prenom obligatoires
                if TypeCust = 0 then begin
                    XmlBody +=
                        'TypeClient="1" ' +
                        'Nom="' + Cust."Name" + '" ' +
                        'Prenom="' + Cust."Name 2" + '" ';
                end

                // Customer Type = 1 (Professionnel)
                // → TypeClient DMS = 2
                // → Nom + Prenom obligatoires
                else if TypeCust = 1 then begin
                    XmlBody +=
                        'TypeClient="2" ' +
                        'Nom="' + Cust."Name" + '" ' +
                        'Prenom="' + Cust."Name 2" + '" ';
                end

                // Customer Type = 2 (Entreprise / Personne morale)
                // → TypeClient DMS = 4
                // → Raison sociale + Type d’entreprise
                else if TypeCust = 2 then begin
                    XmlBody +=
                        'TypeClient="4" ' +
                        // 'TypeEntreprise="' + Cust."Title Code" + '" ' +
                        'RaisonSociale="' + Cust.Name + '" ';
                end;

                // ---------------------------------------------------------
                // Fin gestion TypeCust
                // ---------------------------------------------------------

                if Cust."Country/Region Code" <> '' then
                    Pays := Cust."Country/Region Code"
                else
                    Pays := 'TN';

                XmlBody +=
                    'PhoneMobile="' + Cust."Mobile Phone No." + '" ' +
                    'Email="' + Cust."E-Mail" + '" ' +
                    'Adresse1="' + Cust.Address + '" ' +
                    'Ville="' + Cust.City + '" ' +
                    'CodePostal="' + Cust."Post Code" + '" ' +
                    'Pays="' + Pays + '" ' +
                    'NumeroCompte="' + Cust."No." + '" ' +
                      'SoldeClient="0"/>' + '\r\n';
            until Cust.Next() = 0;

        end else begin
            CodeResult := '99';
            TexteDMS := '';
        end;

        ResultXml :=
            '<LZRC03 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRC03>';

        exit(ResultXml);
    end;
    /*********************INTERROGATION LISTE CLIENTS DEPUIS VEHICULE CONNU**************/
    procedure LZRC02T02(
        VehiculeDmsId: Text[30];
        Vin: Text[30];
        Immatriculation: Text[30];
        RqType: Text[30]
    ) ResultXml: Text
    var
        Vehicle: Record Vehicle; // Table véhicule
        Cust: Record Customer;
        XmlBody: Text;
        Count: Integer;
        CodeResult: Text;
        TexteDMS: Text;
        CustomerNo: Code[20];
    begin
        XmlBody := '';
        Count := 0;

        // ---------------------------------
        // Recherche du véhicule
        // ---------------------------------
        Vehicle.Reset();

        if VehiculeDmsId <> '' then
            Vehicle.SetFilter(VIN, '%1', VehiculeDmsId)
        else if Vin <> '' then
            Vehicle.SetFilter(VIN, '%1', Vin)
        else if Immatriculation <> '' then
            Vehicle.SetFilter("Registration No.", '%1', Immatriculation)
        else begin
            ResultXml :=
                '<LZRC02 Code="1" TexteDMS="La recherche par véhicule est impossible. Veuillez indiquer le VIN." />';
            exit(ResultXml);
        end;

        // ---------------------------------
        // Véhicule trouvé
        // ---------------------------------
        if Vehicle.FindFirst() then begin
            CustomerNo := Vehicle."Customer No.";

            if CustomerNo <> '' then begin
                Cust.Reset();
                Cust.SetFilter("No.", '%1', CustomerNo);
                //Cust.SetRange(Blocked, false);

                if Cust.FindSet() then
                    repeat
                        XmlBody +=
                            '    <CLIENT ' +
                            'CLIENT_DMS_ID="' + Cust."No." + '" ' +
                            'NumeroVoie="" ' +
                            'TypeVoie="" ' +
                            'Adresse1="' + Cust.Address + '" ' +
                            'Ville="' + Cust.City + '" ' +
                            'CodePostal="' + Cust."Post Code" + '" ' +
                            'NumeroCompte="' + Cust."No." + '" />' + '\r\n';

                        Count += 1;
                        if Count = 30 then
                            break;
                    until Cust.Next() = 0;

            end else begin
                CodeResult := '98';
                TexteDMS := 'Aucun client n’est associé à ce véhicule.';
            end;

        end else begin
            CodeResult := '99';
            TexteDMS := '';
        end;

        // ---------------------------------
        // Gestion des codes retour
        // ---------------------------------
        if Count = 1 then begin
            CodeResult := '0';
            TexteDMS := '';
            // appel futur possible vers LZRC03
        end else if (Count > 1) and (Count < 30) then begin
            CodeResult := '0';
            TexteDMS := '';
        end else if Count >= 30 then begin
            CodeResult := '95';
            TexteDMS := 'Nombre de réponses trop grand. Précisez les paramètres de recherche.';
        end else if CodeResult = '' then begin
            CodeResult := '99';
            TexteDMS := '';
        end;

        ResultXml :=
            '<LZRC02 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRC02>';

        exit(ResultXml);
    end;
    /***************** INTERROGATION LISTE VEHICULES DEPUIS CLIENT CONNU******************/
    procedure LZRC07T05(
        ClientDmsId: Code[20];
        RqType: Text[30]
    ) ResultXml: Text
    var
        Vehicle: Record Vehicle; // Table véhicule
        Cust: Record Customer;
        XmlBody: Text;
        Count: Integer;
        CodeResult: Text;
        TexteDMS: Text;
        Vin: Text[30];
    begin
        XmlBody := '';
        Count := 0;

        // ---------------------------------
        // Vérification client
        // ---------------------------------
        Cust.Reset();
        Cust.SetFilter("No.", '%1', ClientDmsId);

        if not Cust.FindFirst() then begin
            ResultXml :=
                '<LZRC07 Code="99" TexteDMS="Compte client inexistant" />';
            exit(ResultXml);
        end;

        // ---------------------------------
        // Recherche des véhicules du client
        // ---------------------------------
        Vehicle.Reset();
        Vehicle.SetFilter("Customer No.", '%1', ClientDmsId);

        if Vehicle.FindSet() then begin
            repeat
                Vin := Vehicle.VIN;

                XmlBody +=
                    '    <VEHICULE ' +
                    'VEHICULE_DMS_ID="' + Vin + '" ' +
                    'VIN_WMI="' + CopyStr(Vin, 1, 3) + '" ' +
                    'VIN_VDS="' + CopyStr(Vin, 4, 6) + '" ' +
                    'VIN_VIS="' + CopyStr(Vin, 10, 8) + '" ' +
                    'Immatriculation="' + Vehicle."Registration No." + '" ' +
                    'LibelleMarque="' + Vehicle."Make Code" + '" ' +
                    'LibelleModele="' + Vehicle."Model Code" + '" />' + '\r\n';

                Count += 1;
                if Count = 30 then
                    break;

            until Vehicle.Next() = 0;

            // ---------------------------------
            // Gestion des codes retour
            // ---------------------------------
            if Count = 1 then begin
                CodeResult := '0';
                TexteDMS := 'Un seul véhicule trouvé pour ce client.';
                // appel futur possible vers LZRC23T09
            end else if (Count > 1) and (Count <= 30) then begin
                CodeResult := '0';
                TexteDMS := Format(Count) + ' véhicules trouvés pour ce client.';
            end else if Count > 30 then begin
                CodeResult := '95';
                TexteDMS := 'Nombre de réponses trop grand. Précisez les paramètres de recherche.';
            end;

        end else begin
            CodeResult := '98';
            TexteDMS := 'Aucun véhicule n’est associé à ce client.';
            XmlBody += '    <VEHICULE />' + '\r\n';
        end;

        ResultXml :=
            '<LZRC07 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRC07>';

        exit(ResultXml);
    end;


    procedure LZRC08T06(
        CodeInterrogation: Text[30];
        ChampsCmpl: Text[30];
        RqType: Text[30]
    ) ResultXml: Text
    var
        Vehicle: Record Vehicle; // Table véhicule
        XmlBody: Text;
        Count: Integer;
        CodeResult: Text;
        TexteDMS: Text;
        Vin: Text[30];
    begin
        XmlBody := '';
        Count := 0;

        // ---------------------------------
        // Détermination du filtre selon le type de recherche
        // ---------------------------------
        Vehicle.Reset();
        case CodeInterrogation of
            '1':
                Vehicle.SetFilter(VIN, '@*' + ChampsCmpl + '*');
            '2':
                begin
                    if StrLen(ChampsCmpl) <= 11 then
                        Vehicle.SetFilter("Registration No.", '@*' + ChampsCmpl + '*')
                    else begin
                        CodeResult := '99';
                        TexteDMS := 'L''immatriculation introduite n''est pas valide !';
                        ResultXml :=
                            '<LZRC08 Code="' + CodeResult +
                            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
                            '    <VEHICULE />' + '\r\n' +
                            '</LZRC08>';
                        exit(ResultXml);
                    end;
                end;
        end;

        // ---------------------------------
        // Lecture des véhicules correspondant aux critères
        // ---------------------------------
        if Vehicle.FindSet() then begin
            repeat
                Vin := Vehicle.VIN;

                XmlBody +=
                    '    <VEHICULE ' +
                    'VEHICULE_DMS_ID="' + Vin + '" ' +
                    'VIN_WMI="' + CopyStr(Vin, 1, 3) + '" ' +
                    'VIN_VDS="' + CopyStr(Vin, 4, 6) + '" ' +
                    'VIN_VIS="' + CopyStr(Vin, 10, 8) + '" ' +
                    'Immatriculation="' + Vehicle."Registration No." + '" ' +
                    'LibelleMarque="' + Vehicle."Make Code" + '" ' +
                    'LibelleModele="' + Vehicle."Model Code" + '" />' + '\r\n';

                Count += 1;
                if Count = 30 then
                    break;

            until Vehicle.Next() = 0;

            // ---------------------------------
            // Gestion des codes retour
            // ---------------------------------
            if Count = 1 then begin
                CodeResult := '0';
                TexteDMS := '';
                // Ici on pourrait appeler LZRC23T09(Vin, ...)
            end else if (Count > 1) and (Count <= 30) then begin
                CodeResult := '0';
                TexteDMS := Format(Count) + ' enregistrements trouvés.';
            end else if Count > 30 then begin
                CodeResult := '95';
                TexteDMS := 'Nombre de réponses trop grand. Précisez les paramètres de recherche.';
            end;

        end else begin
            CodeResult := '98';
            TexteDMS := 'Aucun véhicule trouvé avec ces critères !';
            XmlBody += '    <VEHICULE />' + '\r\n';
        end;

        ResultXml :=
            '<LZRC08 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRC08>';

        exit(ResultXml);
    end;


    procedure GetVehicleDetails(
        VehiculeDmsId: Text[30];
        RqType: Text[30]
    ) ResultXml: Text
    var
        Vehicle: Record Vehicle; // Table véhicule
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;
    begin
        XmlBody := '';

        // ---------------------------------
        // Recherche du véhicule par VIN
        // ---------------------------------
        Vehicle.Reset();
        //Vehicle.SetFilter(VIN, '%1', VehiculeDmsId);
        Vehicle.SetFilter(VIN, '@*' + VehiculeDmsId + '*');
        if Vehicle.FindFirst() then begin
            CodeResult := '0';
            TexteDMS := '';

            XmlBody +=
                '    <VEHICULE ' +
                'VIN="' + Vehicle.VIN + '" ' +
                'LibelleMarque="' + Vehicle."Make Code" + '" ' +
                'LibelleModele="' + Vehicle."Model Code" + '" ' +
                'VIN_WMI="' + CopyStr(Vehicle.VIN, 1, 3) + '" ' +
                'VIN_VDS="' + CopyStr(Vehicle.VIN, 4, 6) + '" ' +
                'VIN_VIS="' + CopyStr(Vehicle.VIN, 10, 8) + '" ' +
                'Immatriculation="' + Vehicle."Registration No." + '" ';

            // Date de mise en circulation
            if Vehicle."First Registration Date" <> 0D then
                XmlBody +=
                    'AnneeMiseCirculation="' + Format(Date2DMY(Vehicle."First Registration Date", 3)) + '" ' +
                    'MoisMiseCirculation="' + Format(Date2DMY(Vehicle."First Registration Date", 2)) + '" ' +
                    'JourMiseCirculation="' + Format(Date2DMY(Vehicle."First Registration Date", 1)) + '" '
            else
                XmlBody +=
                    'AnneeMiseCirculation="' + Format(Date2DMY(Vehicle."Creation Date", 3)) + '" ' +
                    'MoisMiseCirculation="' + Format(Date2DMY(Vehicle."Creation Date", 2)) + '" ' +
                    'JourMiseCirculation="' + Format(Date2DMY(Vehicle."Creation Date", 1)) + '" ';

            XmlBody +=
                'DernierKilometrage="' + Format(Vehicle."Variable Field Run 1", 0, '<Standard Format,2>') + '" ' +
                'CodeOPB="" ' +
                'TypeEntretien="" />' + '\r\n'; // to fix ' + Vehicle."Labor Type" + '

            if (RqType = '05') or (RqType = '06') or (RqType = '09') then begin
                XmlBody += LZRC02T02(VehiculeDmsId, Vehicle.VIN, Vehicle."Registration No.", RqType);
            end;

        end else begin
            CodeResult := '99';
            TexteDMS := '';
            XmlBody += '    <VEHICULE />' + '\r\n';
        end;

        // Construction finale du XML
        ResultXml :=
            '<LZRC23 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRC23>';

        exit(ResultXml);
    end;


    procedure GetItemDetails(
        ReferencePR: Code[30];
        CodeImputationDMS_PR: Code[30];
        LigneDTId: Text[30]
    ) ResultXml: Text
    var
        RecItem: Record Item;
        RecCustomer: Record Customer;
        //RecItemSalesPriceCalculation: Record "Item Sales Price Calculation";
        Remise: Decimal;
    begin
        ResultXml := '';
        Remise := 0;


        RecItem.Reset();
        RecItem.SetFilter("No.", '%1', ReferencePR);
        RecItem.SetFilter(Blocked, '%1', false);

        if RecItem.FindFirst() then begin

            if CodeImputationDMS_PR <> '' then begin
                if RecCustomer.Get(CodeImputationDMS_PR) then begin
                    /*  RecItemSalesPriceCalculation.Reset();
                     RecItemSalesPriceCalculation.SetFilter("Item Sales Price Group", '%1', RecCustomer."Item Sales Price Group");
                     RecItemSalesPriceCalculation.SetFilter("Item Group", '%1', RecItem."Item Group Code");
                     if RecItemSalesPriceCalculation.FindFirst() then
                         Remise := RecItemSalesPriceCalculation."Discount %";
                  */
                end;
            end;
            ResultXml :=
                '<LZRF46 Code="0" TexteDMS="">' + '\r\n' +
                '  <PR ' +
                'LIGNE_DT_ID="' + LigneDTId + '" ' +
                'ReferencePR="' + ReferencePR + '" ' +
                'LibellePR="' + RecItem.Description + '" ' +
                'PrixUnitaireHT="' + Format(RecItem."Unit Price", 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                'PrixUnitaireTTC="' + Format(RecItem."Unit Price" * 1.19, 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                'PrixUV_HT="" ' +
                'PrixUV_TTC="" ' +
                'REMISE_DMS="' + Format(Remise, 0, '<Precision,2:2><Standard Format,2>') + '" />' + '\r\n' +
                '</LZRF46>';

        end else begin
            // ---------------------------------
            // Article non trouvé
            // ---------------------------------
            ResultXml :=
                '<LZRF46 Code="0" TexteDMS="No gérée">' + '\r\n' +
                '  <PR ' +
                'CODE_PR="99" ' +
                'ReferencePR="' + ReferencePR + '" ' +
                'LibellePR="" ' +
                'PrixUnitaireHT="" ' +
                'PrixUnitaireTTC="" ' +
                'Remise="" />' + '\r\n' +
                '</LZRF46>';
        end;

        exit(ResultXml);
    end;

    procedure LZRF51T51(DOSSIER_DMS_ID: Text[30]; RDV_DMS_ID: Text[30]; CODE_INTERR_DMS: Text[30]) ResultXml: Text
    var
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;

        RecServiceHeader: Record "Service Header EDMS";
        RecServiceLine: Record "Service Line EDMS";
        RecCustomer: Record Customer;
        RecVehicle: Record Vehicle;

        XMLNode: Text;
        TYPEFORFAIT: Text;
    begin
        XmlBody := '';

        // ---------------------------------
        // Branching selon CODE_INTERR_DMS
        // ---------------------------------
        case CODE_INTERR_DMS of
            '1', '2':
                begin
                    // Recherche du dossier ServiceHeader
                    RecServiceHeader.Reset();
                    RecServiceHeader.SetFilter("No.", '%1', DOSSIER_DMS_ID);

                    if RecServiceHeader.FindFirst() then begin
                        CodeResult := '0';
                        TexteDMS := '';

                        repeat
                            XmlBody +=
                                '    <DOSSIER ' +
                                'DOSSIER_DMS_ID="' + RecServiceHeader."No." + '" ' +
                                'ETATDOSSIERDMS="1" ' +
                                'RDV_DMS_ID="" ' +
                                'ANNEERDV="" ' +
                                'MOISRDV="" ' +
                                'JOURRDV="" ' +
                                'HEURESRDV="" ' +
                                'MINUTESRDV="" ' +
                                'TPSIMMO="" ' +
                                'EQUIPE="" ' +
                                'ANNEERDV_RESTIT="" ' +
                                'MOISRDV_RESTIT="" ' +
                                'JOURRDV_RESTIT="" ' +
                                'HEURESRDV_RESTIT="" ' +
                                'MINUTESRDV_RESTIT="" ' +
                                'RETOURATELIER="" />' + '\r\n';

                            // Clients
                            RecCustomer.Reset();
                            RecCustomer.SetFilter("No.", '%1', RecServiceHeader."Sell-to Customer No.");
                            if RecCustomer.FindFirst() then
                                repeat
                                    XmlBody +=
                                        '    <CLIENT ' +
                                        'CLIENT_DMS_ID="' + RecCustomer."No." + '" ' +
                                        'TypeClient="2" ' +//' + FORMAT(RecCustomer."Customer Type") + '
                                        'Nom="' + RecCustomer."Name" + '" ' +
                                        'Prenom="' + RecCustomer."Name 2" + '" ' +
                                        'TypeEntreprise="" ' +//' + RecCustomer."Title Code" + '
                                        'RaisonSociale="' + RecCustomer.Name + '" ' +
                                        'NumeroVoie="" TypeVoie="" Adresse1="' + RecCustomer.Address + '" ' +
                                        'Ville="' + RecCustomer.City + '" ' +
                                        'CodePostal="' + RecCustomer."Post Code" + '" ' +
                                        'NumeroCompte="' + RecCustomer."No." + '" />' + '\r\n';
                                until RecCustomer.Next() = 0;

                            // Véhicules
                            RecVehicle.Reset();
                            RecVehicle.SetFilter(VIN, '%1', RecServiceHeader.VIN);
                            if RecVehicle.FindFirst() then
                                repeat
                                    XmlBody +=
                                        '    <VEHICULE ' +
                                        'VEHICULE_DMS_ID="' + RecVehicle.VIN + '" ' +
                                        'LibelleMarque="' + RecVehicle."Make Code" + '" ' +
                                        'LibelleModele="' + RecVehicle."Model Code" + '" ' +
                                        'VIN_WMI="' + CopyStr(RecVehicle.VIN, 1, 3) + '" ' +
                                        'VIN_VDS="' + CopyStr(RecVehicle.VIN, 4, 6) + '" ' +
                                        'VIN_VIS="' + CopyStr(RecVehicle.VIN, 10, 8) + '" ' +
                                        'Immatriculation="' + RecVehicle."Registration No." + '" ';

                                    if RecVehicle."First Registration Date" <> 0D then
                                        XmlBody +=
                                            'AnneeMiseCirculation="' + Format(Date2DMY(RecVehicle."First Registration Date", 3)) + '" ' +
                                            'MoisMiseCirculation="' + Format(Date2DMY(RecVehicle."First Registration Date", 2)) + '" ' +
                                            'JourMiseCirculation="' + Format(Date2DMY(RecVehicle."First Registration Date", 1)) + '" '
                                    else
                                        XmlBody +=
                                            'AnneeMiseCirculation="' + Format(Date2DMY(RecVehicle."Creation Date", 3)) + '" ' +
                                            'MoisMiseCirculation="' + Format(Date2DMY(RecVehicle."Creation Date", 2)) + '" ' +
                                            'JourMiseCirculation="' + Format(Date2DMY(RecVehicle."Creation Date", 1)) + '" ';

                                    XmlBody +=
                                        'DernierKilometrage="' + FORMAT(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>') + '" ' +
                                        'CodeOPB="" TypeEntretien="" />' + '\r\n';
                                until RecVehicle.Next() = 0;

                            // Lignes MO/PR
                            TYPEFORFAIT := 'Trav. ext';
                            RecServiceLine.Reset();
                            RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
                            RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
                            RecServiceLine.SetFilter(Type, TYPEFORFAIT);

                            if RecServiceLine.FindFirst() then
                                repeat
                                    XmlBody +=
                                        '    <LDT ' +
                                        'LIBELLE_LIGNE_TRAVAIL="' + RecServiceLine.Description + '" ' +
                                        'PrixUnitaireHT="' + FORMAT(RecServiceLine."Unit Price") + '" ' +
                                        'PrixUnitaireTTC="' + FORMAT(RecServiceLine."Amount Including VAT") + '" ' +
                                        'REMISE="' + FORMAT(RecServiceLine."Line Discount %") + '" ' +
                                        'ReferenceFF="' + RecServiceLine."No." + '" />' + '\r\n';
                                until RecServiceLine.Next() = 0;

                        until RecServiceHeader.Next() = 0;
                    end else begin
                        CodeResult := '99';
                        TexteDMS := '';
                    end;
                end;

            '3':
                begin
                    // À implémenter selon ton ancienne logique '3'
                    // Exemple : brancher vers LZRF51T51F ou générer XML vide si pas trouvé
                    XmlBody := '    <DOSSIER />' + '\r\n';
                    CodeResult := '0';
                    TexteDMS := '';
                end;
        end;

        // ---------------------------------
        // Construction finale du XML
        // ---------------------------------
        ResultXml :=
            '<LZRF51 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRF51>';
    end;

    procedure LZRF51T51F(
        DOSSIER_DMS_ID: Text[30];
        TypeXX: Text[10]
    ) ResultXml: Text
    var
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;

        RecSalesInvoiceHeader: Record "Sales Invoice Header";
        RecSalesInvoiceLine: Record "Sales Invoice Line";
        RecVehiculeLedgerEntry: Record "DLT Shared History VIN";
        RecVehicle: Record Vehicle;
        RecCustomer: Record Customer;
        ArchServiceHeader: Record "Service Header Archive EDMS";

        XmlNode: Text;
        XmlNodeLDT: Text;
        XmlNodeMO: Text;
        XmlNodePR: Text;
    begin
        XmlBody := '';

        // ---------------------------------
        // Recherche du dossier facture
        // ---------------------------------
        RecSalesInvoiceHeader.Reset();
        RecSalesInvoiceHeader.SetFilter("No.", '%1', DOSSIER_DMS_ID);

        if RecSalesInvoiceHeader.FindFirst() then begin
            CodeResult := '0';
            TexteDMS := '';

            // Dossier
            XmlBody +=
                '    <DOSSIER ' +
                'Code="' + CodeResult + '" ' +
                'DOSSIER_DMS_ID="' + RecSalesInvoiceHeader."No." + '" ' +
                'TexteDMS="' + TexteDMS + '" ' +
                'ETATDOSSIERDMS="2" ' +
                'RDV_DMS_ID="" ' +
                'ANNEERDV="" ' +
                'MOISRDV="" ' +
                'JOURRDV="" ' +
                'HEURESRDV="" ' +
                'MINUTESRDV="" ' +
                'TPSIMMO="" ' +
                'EQUIPE="" ' +
                'ANNEERDV_RESTIT="" ' +
                'MOISRDV_RESTIT="" ' +
                'JOURRDV_RESTIT="" ' +
                'HEURESRDV_RESTIT="" ' +
                'MINUTESRDV_RESTIT="" ' +
                'RETOURATELIER="">' + '\r\n';

            // ---------------------------------
            // Client
            // ---------------------------------
            RecCustomer.Reset();
            RecCustomer.SetFilter("No.", '%1', RecSalesInvoiceHeader."Sell-to Customer No.");
            if RecCustomer.FindFirst() then begin
                XmlNode :=
                    '    <CLIENT ' +
                    'CLIENT_DMS_ID="' + RecCustomer."No." + '" ' +
                    'TypeClient="" ' +//' + FORMAT(RecCustomer."Customer Type") + '
                    'Nom="' + RecCustomer."Name" + '" ' +
                    'Prenom="' + RecCustomer."Name 2" + '" ' +
                    'PhoneMobile="' + RecCustomer."Mobile Phone No." + '" ' +
                    'Email="' + RecCustomer."E-Mail" + '" ' +
                    'TypeEntreprise="" ' +//' + RecCustomer."Title Code" + '
                    'RaisonSociale="' + RecCustomer.Name + '" ' +
                    'NumeroVoie="" ' +
                    'TypeVoie="" ' +
                    'Adresse1="' + RecCustomer.Address + '" ' +
                    'Adresse2="' + RecCustomer."Address 2" + '" ' +
                    'Ville="' + RecCustomer.City + '" ' +
                    'CodePostal="' + RecCustomer."Post Code" + '" ' +
                    'Pays="' + (RecCustomer.County <> '' ? RecCustomer.County : 'TN') + '" ' +
                    'NumeroCompte="' + RecCustomer."No." + '" ' +
                    'SoldeClient="' + FORMAT(RecCustomer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                    'PhoneDomicile="" ' +
                    'PhoneBureau="' + RecCustomer."Phone No." + '" ' +
                    'NumeroPoste="" ' +
                    'Fax="' + RecCustomer."Fax No." + '" ' +
                    'TEXTE_LIBRE="" ' +
                    'Observations=""/>' + '\r\n';

                XmlBody += XmlNode;
            end;

            // ---------------------------------
            // Véhicule
            // ---------------------------------
            RecVehiculeLedgerEntry.Reset();
            RecVehiculeLedgerEntry.SetFilter("No.", '%1', RecSalesInvoiceHeader."No.");
            if RecVehiculeLedgerEntry.FindFirst() then begin
                if RecVehicle.Get(RecVehiculeLedgerEntry.VIN) then begin
                    XmlNode :=
                        '    <VEHICULE ' +
                        'VEHICULE_DMS_ID="' + RecVehicle.VIN + '" ' +
                        'LibelleMarque="' + RecVehicle."Make Code" + '" ' +
                        'LibelleModele="' + RecVehicle."Model Code" + '" ' +
                        'VIN_WMI="' + CopyStr(RecVehicle.VIN, 1, 3) + '" ' +
                        'VIN_VDS="' + CopyStr(RecVehicle.VIN, 4, 6) + '" ' +
                        'VIN_VIS="' + CopyStr(RecVehicle.VIN, 10, 8) + '" ' +
                        'Immatriculation="' + RecVehicle."Registration No." + '" ';

                    if RecVehicle."First Registration Date" <> 0D then
                        XmlNode +=
                            'AnneeMiseCirculation="' + FORMAT(DATE2DMY(RecVehicle."First Registration Date", 3)) + '" ' +
                            'MoisMiseCirculation="' + FORMAT(DATE2DMY(RecVehicle."First Registration Date", 2)) + '" ' +
                            'JourMiseCirculation="' + FORMAT(DATE2DMY(RecVehicle."First Registration Date", 1)) + '" ';

                    // Kilométrage
                    ArchServiceHeader.Reset();
                    ArchServiceHeader.SetFilter("No.", RecSalesInvoiceHeader."Service Order No.");
                    if ArchServiceHeader.FindFirst() then
                        XmlNode += 'DernierKilometrage="' + FORMAT(ArchServiceHeader."Variable Field Run 1", 0, '<Standard Format,2>') + '" '
                    else
                        XmlNode += 'DernierKilometrage="' + FORMAT(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>') + '" ';

                    XmlNode += 'CodeOPB="" TypeEntretien="">' + '\r\n';

                    XmlBody += XmlNode;

                    // ---------------------------------
                    // Lignes MO/PR
                    // ---------------------------------
                    XmlNodeLDT := '        <LDT ' + TypeXX + '_LDT="" CODEIMPUTATION_LDT="" LIGNE_DT_ID="" LIGNE_DT_ID_DMS="" ReferenceFF="" LIBELLE_LIGNE_TRAVAIL="Détaille Facture" COMMENTAIRES_LDT="" ACCORD_CLIENT="">' + '\r\n';
                    RecSalesInvoiceLine.Reset();
                    RecSalesInvoiceLine.SetRange("Document No.", RecSalesInvoiceHeader."No.");

                    if RecSalesInvoiceLine.FindFirst() then
                        repeat
                            // MO
                            if RecSalesInvoiceLine.Type = RecSalesInvoiceLine.Type::"G/L Account" then begin
                                XmlNodeMO :=
                                    '            <MO ' + TypeXX + '_MO="" ' +
                                    'LIGNE_DT_ID="" LIGNE_DT_ID_DMS="' + FORMAT(RecSalesInvoiceLine."Line No.") + '" ' +
                                    'CODEIMPUTATION_MO="' + RecSalesInvoiceHeader."Bill-to Customer No." + '" ' +
                                    'CODEOPERATION="" ' +//' + RecSalesInvoiceLine."Labor No." + ' to fix
                                    'TYPEOPERATION="2" ' +
                                    'CODETYPEVEHICULE="" ' +
                                    'TEMPSGLOBAL="' + FORMAT(RecSalesInvoiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                                    'TECHNICITE="1" METIER="T" ' +
                                    'LIBELLEOPERATION="' + RecSalesInvoiceLine.Description + '" ' +
                                    'PRIXHT_MO="' + FORMAT(RecSalesInvoiceLine.Amount, 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                                    'PRIXTTC_MO="' + FORMAT(RecSalesInvoiceLine."Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                                    'CODEVENTILATION="" ' +
                                    'QUANTITE="' + FORMAT(RecSalesInvoiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>') + '"/>' + '\r\n';

                                XmlNodeLDT += XmlNodeMO;
                            end;

                            // PR
                            if RecSalesInvoiceLine.Type = RecSalesInvoiceLine.Type::Item then begin
                                XmlNodePR :=
                                    '            <PR ' + TypeXX + '_PR="" ' +
                                    'LIGNE_DT_ID="" LIGNE_DT_ID_DMS="' + FORMAT(RecSalesInvoiceLine."Line No.") + '" ' +
                                    'CODEIMPUTATION_PR="' + RecSalesInvoiceHeader."Bill-to Customer No." + '" ' +
                                    'REFERENCE_PR="' + RecSalesInvoiceLine."No." + '" ' +
                                    'LIBELLE_PR="' + RecSalesInvoiceLine.Description + '" ' +
                                    'TYPE_PR="2" ' +
                                    'QuantiteEnCommande="' + FORMAT(RecSalesInvoiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                                    'QuantiteServie="' + FORMAT(RecSalesInvoiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                                    'PRIXHT="' + FORMAT(RecSalesInvoiceLine."Unit Price" * (1 - RecSalesInvoiceLine."Line Discount %" / 100), 0, '<Precision,2:2><Standard Format,2>') + '" ' +
                                    'PRIXTTC="' + FORMAT(RecSalesInvoiceLine."Unit Price" * (1 - RecSalesInvoiceLine."Line Discount %" / 100) * (1 + RecSalesInvoiceLine."VAT %" / 100), 0, '<Precision,2:2><Standard Format,2>') + '"/>' + '\r\n';

                                XmlNodeLDT += XmlNodePR;
                            end;
                        until RecSalesInvoiceLine.Next() = 0;

                    XmlNodeLDT += '        </LDT>' + '\r\n';
                    XmlBody += XmlNodeLDT;
                end;
            end;

            XmlBody += '    </DOSSIER>' + '\r\n';
        end else begin
            CodeResult := '99';
            TexteDMS := '';
            XmlBody := '    <DOSSIER />' + '\r\n';
        end;

        // ---------------------------------
        // Construction finale du XML
        // ---------------------------------
        ResultXml :=
            '<LZRF51 Code="' + CodeResult + '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRF51>';
    end;


    procedure GetServiceOrdersDMS(XmlRequest: Text) ResultXml: Text
    var
        RecServiceHeader: Record "Service Header EDMS"; // Remplace par le bon nom de table
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;
        XmlNodeValue: Text;
    begin
        XmlBody := '';

        // 🔹 Lecture des paramètres du XML
        XmlNodeValue := GetAttributeValue(XmlRequest, 'CLIENT_DMS_ID');
        if XmlNodeValue <> '' then
            RecServiceHeader.SetFilter("Sell-to Customer No.", '%1', XmlNodeValue);

        XmlNodeValue := GetAttributeValue(XmlRequest, 'VEHICULE_DMS_ID');
        if XmlNodeValue <> '' then
            RecServiceHeader.SetFilter(VIN, '%1', XmlNodeValue);

        // Filtrer uniquement les OR (Order) en cours
        RecServiceHeader.SetFilter("Document Type", '%1', RecServiceHeader."Document Type"::Order);

        if RecServiceHeader.FindSet() then begin
            CodeResult := '0';
            TexteDMS := 'OR en cours';
            repeat
                XmlBody +=
                    '    <OR ' +
                    'DOSSIER_DMS_ID="' + RecServiceHeader."No." + '" ' +
                    'JOUROUVERTURE="' + Format(Date2DMY(RecServiceHeader."Order Date", 1)) + '" ' +
                    'MOISOUVERTURE="' + Format(Date2DMY(RecServiceHeader."Order Date", 2)) + '" ' +
                    'ANNEEOUVERTURE="' + Format(Date2DMY(RecServiceHeader."Order Date", 3)) + '" ' +
                    'Nom="' + RecServiceHeader."Sell-to Customer Name" + '" ' +
                    'LibelleMarque="' + RecServiceHeader."Make Code" + '" ' +
                    'LibelleModele="' + RecServiceHeader."Model Code" + '" ' +
                    'VIN="' + RecServiceHeader.VIN + '" ' +
                    'Immatriculation="' + RecServiceHeader."Vehicle Registration No." + '" />' + '\r\n';
            until RecServiceHeader.Next() = 0;
        end else begin
            CodeResult := '99';
            TexteDMS := 'Recherche inconnue';
            XmlBody += '    <OR />' + '\r\n';
        end;

        // Construction finale du XML
        ResultXml :=
            '<LZRF53 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRF53>';

        exit(ResultXml);
    end;

    procedure GetInvoicesDMS(XmlRequest: Text) ResultXml: Text
    var
        RecCustomerLedgerEntry: Record "Cust. Ledger Entry";
        RecSalesInvoiceHeader: Record "Sales Header";
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;
        XmlNodeValue: Text;
    begin
        XmlBody := '';

        // 🔹 Vérification des paramètres CLIENT_DMS_ID et VEHICULE_DMS_ID
        if (GetAttributeValue(XmlRequest, 'CLIENT_DMS_ID') <> '') and
           (GetAttributeValue(XmlRequest, 'VEHICULE_DMS_ID') <> '') then begin

            // 🔹 Filtrage des factures du client
            RecSalesInvoiceHeader.Reset();
            RecSalesInvoiceHeader.SetFilter("Sell-to Customer No.", '%1', GetAttributeValue(XmlRequest, 'CLIENT_DMS_ID'));
            RecSalesInvoiceHeader.SetFilter("Document Profile", '%1', RecSalesInvoiceHeader."Document Profile"::Service);

            if RecSalesInvoiceHeader.FindSet() then begin
                CodeResult := '0';
                TexteDMS := '';
                repeat
                    // 🔹 Filtrer les lignes correspondant au véhicule demandé
                    RecCustomerLedgerEntry.Reset();
                    RecCustomerLedgerEntry.SetFilter("Document No.", RecSalesInvoiceHeader."No.");
                    //RecCustomerLedgerEntry.SetFilter(VIN, GetAttributeValue(XmlRequest, 'VEHICULE_DMS_ID'));

                    if RecCustomerLedgerEntry.FindSet() then
                        repeat
                            XmlBody +=
                                '    <FAC ' +
                                'CLIENT_DMS_ID="' + RecSalesInvoiceHeader."Sell-to Customer No." + '" ' +
                                'DOSSIER_DMS_ID="' + RecCustomerLedgerEntry."Document No." + '" ' +
                                'LibelleFacture="' + RecSalesInvoiceHeader."Service Document No." + '" ' +//to fix 'Service Order No.'
                                'JourFacture="' + Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 1)) + '" ' +
                                'MoisFacture="' + Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 2)) + '" ' +
                                'AnneeFacture="' + Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 3)) + '" ' +
                                'Nom="' + RecSalesInvoiceHeader."Sell-to Customer Name" + '" ';

                            // Montants
                            if RecCustomerLedgerEntry."Customer No." = RecSalesInvoiceHeader."Sell-to Customer No." then
                                XmlBody += 'MontantClient="' + Format(RecCustomerLedgerEntry."Amount (LCY)", 0, '<Precision,2:2><Standard Format,2>') + '" ';

                            if RecCustomerLedgerEntry."Customer No." = 'GARANTIE' then
                                XmlBody += 'MontantGarantie="' + Format(RecCustomerLedgerEntry."Amount (LCY)", 0, '<Precision,2:2><Standard Format,2>') + '" ';

                            XmlBody +=
                                'MontantAssurance="0.00" ' +
                                'LibelleMarque="" ' +//to fix ' + RecCustomerLedgerEntry."Make Code" + '
                                'LibelleModele="" ' +
                                'VIN="" ' +//to fix ' + RecCustomerLedgerEntry.VIN + '
                                'KilometrageFacture="" ' +
                                'CommentairesFacture="Client Facturé : ' + RecSalesInvoiceHeader."Bill-to Customer No." + '" />' + '\r\n';
                        until RecCustomerLedgerEntry.Next() = 0;

                until RecSalesInvoiceHeader.Next() = 0;

            end else begin
                CodeResult := '99';
                TexteDMS := 'Aucune Commande trouvée';
                XmlBody += '    <FAC />' + '\r\n';
            end;

        end else begin
            CodeResult := '95';
            TexteDMS := 'Recherche facturation inconnue !';
            XmlBody += '    <FAC />' + '\r\n';
        end;

        // 🔹 Construction finale du XML
        ResultXml :=
            '<LZRF52 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRF52>';

        exit(ResultXml);
    end;
    // -------------------------------
    // Helper pour récupérer un attribut depuis du XML texte
    procedure GetAttributeValue(XmlText: Text; AttributeName: Text) Result: Text
    var
        StartPos: Integer;
        EndPos: Integer;
    begin
        StartPos := StrPos(XmlText, AttributeName + '="');
        if StartPos = 0 then
            exit('');

        StartPos += StrLen(AttributeName + '="');
        EndPos := StrPos(CopyStr(XmlText, StartPos, StrLen(XmlText) - StartPos + 1), '"');
        if EndPos = 0 then
            exit('');

        exit(CopyStr(XmlText, StartPos, EndPos - 1));
    end;

    procedure GetVehicleDMS(VIN_DMS: Text[30]; RqType: Text[30]) ResultXml: Text
    var
        RecVehicle: Record Vehicle;
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;
    begin
        XmlBody := '';

        // 🔹 Recherche du véhicule
        RecVehicle.Reset();
        RecVehicle.SetFilter(VIN, '%1', VIN_DMS);

        if RecVehicle.Find('-') then begin
            CodeResult := '0';
            TexteDMS := '';

            XmlBody +=
                '    <VEHICULE ' +
                'VEHICULE_DMS_ID="' + RecVehicle."Serial No." + '" ' +
                'LibelleMarque="' + RecVehicle."Make Code" + '" ' +
                'LibelleModele="' + RecVehicle."Model Code" + '" ' +
                'VIN_WMI="' + CopyStr(RecVehicle.VIN, 1, 3) + '" ' +
                'VIN_VDS="' + CopyStr(RecVehicle.VIN, 4, 6) + '" ' +
                'VIN_VIS="' + CopyStr(RecVehicle.VIN, 10, 8) + '" ' +
                'Immatriculation="' + RecVehicle."Registration No." + '" ';

            if RecVehicle."First Registration Date" <> 0D then begin
                XmlBody +=
                    'AnneeMiseCirculation="' + Format(Date2DMY(RecVehicle."First Registration Date", 3)) + '" ' +
                    'MoisMiseCirculation="' + Format(Date2DMY(RecVehicle."First Registration Date", 2)) + '" ' +
                    'JourMiseCirculation="' + Format(Date2DMY(RecVehicle."First Registration Date", 1)) + '" ';
            end else begin
                XmlBody +=
                    'AnneeMiseCirculation="' + Format(Date2DMY(RecVehicle."Creation Date", 3)) + '" ' +
                    'MoisMiseCirculation="' + Format(Date2DMY(RecVehicle."Creation Date", 2)) + '" ' +
                    'JourMiseCirculation="' + Format(Date2DMY(RecVehicle."Creation Date", 1)) + '" ';
            end;

            XmlBody +=
                'DernierKilometrage="' + Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>') + '" ' +
                'CodeOPB="" ' +
                'TypeEntretien="" />' + '\r\n';//' + RecVehicle."Labor Type" + ' //to fix

            // 🔹 Appel à LZRC02T02 si nécessaire
            if (RqType = '05') or (RqType = '06') or (RqType = '09') then begin
                XmlBody += LZRC02T02(VIN_DMS, VIN_DMS, RecVehicle."Registration No.", RqType);
            end;

        end else begin
            CodeResult := '99';
            TexteDMS := '';
            XmlBody := '    <VEHICULE />' + '\r\n';
        end;

        // 🔹 Construction du XML final
        ResultXml :=
            '<LZRC23 Code="' + CodeResult +
            '" TexteDMS="' + TexteDMS + '">' + '\r\n' +
            XmlBody +
            '</LZRC23>';

        exit(ResultXml);
    end;




}

