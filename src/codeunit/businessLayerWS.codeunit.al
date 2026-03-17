codeunit 75101 "Business Layer"
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
                            'TypeClient="1" ' +
                            'Nom="' + Cust."Name" + '" ' +
                            'Prenom="' + Cust."Name 2" + '" ' +
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
                    'VEHICULE_DMS_ID="' + Vehicle.VIN + '" ' +
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
                LZRC23T09(Vehicle.VIN, RqType);                // Ici on pourrait appeler LZRC23T09(Vin, ...)

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
                    'VEHICULE_DMS_ID="' + Vehicle.Vin + '" ' +
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
                LZRC23T09(Vehicle.VIN, RqType);                // Ici on pourrait appeler LZRC23T09(Vin, ...)
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


    procedure LZRC23T09(
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
        Vehicle.SetFilter(VIN, '%1', VehiculeDmsId);
        if Vehicle.FindFirst() then begin
            CodeResult := '0';
            TexteDMS := '';

            XmlBody +=
                '    <VEHICULE ' +
                'VEHICULE_DMS_ID="' + Vehicle.VIN + '" ' + // ID interne
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
                XmlBody += LZRC02T02(Vehicle.VIN, Vehicle.VIN, Vehicle."Registration No.", RqType);
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
                                        'VEHICULE_DMS_ID="' + RecVehicle.Vin + '" ' +
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
                            TYPEFORFAIT := 'Labor';
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

    procedure LZRF51T51FV1(var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement; DOSSIER_DMS_ID: Text[30])
    var
        RecSalesInvoiceHeader: Record "Sales Invoice Header";
        RecSalesInvoiceLine: Record "Sales Invoice Line";
        RecVehiculeLedgerEntry: Record "DLT Shared History VIN";
        RecVehicle: Record Vehicle;
        RecCustomer: Record Customer;
        ArchServiceHeader: Record "Service Header Archive EDMS";

        XMLRoot: XmlElement;
        XMLDossier: XmlElement;
        XMLClient: XmlElement;
        XMLVehicule: XmlElement;
        XMLLDT: XmlElement;
        XMLNode: XmlElement;
    begin
        // 1. Création du nœud racine LZRF51
        XMLRoot := XmlElement.Create('LZRF51');

        RecSalesInvoiceHeader.Reset();
        RecSalesInvoiceHeader.SetRange("No.", DOSSIER_DMS_ID);

        if RecSalesInvoiceHeader.FindFirst() then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');

            // 2. Nœud DOSSIER
            XMLDossier := XmlElement.Create('DOSSIER');
            XMLDossier.SetAttribute('Code', '0');
            XMLDossier.SetAttribute('DOSSIER_DMS_ID', RecSalesInvoiceHeader."No.");
            XMLDossier.SetAttribute('TexteDMS', '');
            XMLDossier.SetAttribute('ETATDOSSIERDMS', '2'); // Facturé
                                                            // Attributs vides requis par le schéma PSA
            XMLDossier.SetAttribute('RDV_DMS_ID', '');
            XMLDossier.SetAttribute('ANNEERDV', '');
            XMLDossier.SetAttribute('MOISRDV', '');
            XMLDossier.SetAttribute('JOURRDV', '');
            XMLDossier.SetAttribute('HEURESRDV', '');
            XMLDossier.SetAttribute('MINUTESRDV', '');

            // 3. Nœud CLIENT
            if RecCustomer.Get(RecSalesInvoiceHeader."Sell-to Customer No.") then begin
                XMLClient := XmlElement.Create('CLIENT');
                XMLClient.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");
                XMLClient.SetAttribute('Nom', RecCustomer.Name);
                XMLClient.SetAttribute('Prenom', RecCustomer."Name 2");
                XMLClient.SetAttribute('PhoneMobile', RecCustomer."Mobile Phone No.");
                XMLClient.SetAttribute('Email', RecCustomer."E-Mail");
                XMLClient.SetAttribute('RaisonSociale', RecCustomer.Name);
                XMLClient.SetAttribute('Adresse1', RecCustomer.Address);
                XMLClient.SetAttribute('Ville', RecCustomer.City);
                XMLClient.SetAttribute('CodePostal', RecCustomer."Post Code");
                XMLClient.SetAttribute('Pays', 'TN');
                XMLClient.SetAttribute('SoldeClient', Format(RecCustomer."Balance (LCY)", 0, 9));
                XMLDossier.Add(XMLClient);
            end;

            // 4. Nœud VEHICULE
            RecVehiculeLedgerEntry.Reset();
            RecVehiculeLedgerEntry.SetRange("No.", RecSalesInvoiceHeader."No.");
            if RecVehiculeLedgerEntry.FindFirst() then begin
                if RecVehicle.Get(RecVehiculeLedgerEntry.VIN) then begin
                    XMLVehicule := XmlElement.Create('VEHICULE');
                    XMLVehicule.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
                    XMLVehicule.SetAttribute('LibelleMarque', RecVehicle."Make Code");
                    XMLVehicule.SetAttribute('LibelleModele', RecVehicle."Model Code");
                    XMLVehicule.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                    XMLVehicule.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                    XMLVehicule.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                    XMLVehicule.SetAttribute('Immatriculation', RecVehicle."Registration No.");

                    if RecVehicle."First Registration Date" <> 0D then begin
                        XMLVehicule.SetAttribute('AnneeMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 3)));
                        XMLVehicule.SetAttribute('MoisMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 2)));
                        XMLVehicule.SetAttribute('JourMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 1)));
                    end;

                    // Récupération KM
                    ArchServiceHeader.Reset();
                    ArchServiceHeader.SetRange("No.", RecSalesInvoiceHeader."Service Order No.");
                    if ArchServiceHeader.FindFirst() then
                        XMLVehicule.SetAttribute('DernierKilometrage', Format(ArchServiceHeader."Variable Field Run 1", 0, 9))
                    else
                        XMLVehicule.SetAttribute('DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, 9));

                    XMLDossier.Add(XMLVehicule);
                end;
            end;

            // 5. Nœud LDT (Lignes)
            XMLLDT := XmlElement.Create('LDT');
            XMLLDT.SetAttribute(TypeXX + '_LDT', '1');
            XMLLDT.SetAttribute('LIBELLE_LIGNE_TRAVAIL', 'Détail Facture');

            RecSalesInvoiceLine.Reset();
            RecSalesInvoiceLine.SetRange("Document No.", RecSalesInvoiceHeader."No.");
            if RecSalesInvoiceLine.FindSet() then
                repeat
                    if RecSalesInvoiceLine.Type = RecSalesInvoiceLine.Type::Item then begin
                        XMLNode := XmlElement.Create('PR');
                        XMLNode.SetAttribute('REFERENCE_PR', RecSalesInvoiceLine."No.");
                        XMLNode.SetAttribute('LIBELLE_PR', RecSalesInvoiceLine.Description);
                        XMLNode.SetAttribute('QuantiteServie', Format(RecSalesInvoiceLine.Quantity, 0, 9));
                        XMLNode.SetAttribute('PRIXHT', Format(RecSalesInvoiceLine."Unit Price", 0, 9));
                        XMLLDT.Add(XMLNode);
                    end else if RecSalesInvoiceLine.Type = RecSalesInvoiceLine.Type::"G/L Account" then begin
                        XMLNode := XmlElement.Create('MO');
                        XMLNode.SetAttribute('LIBELLEOPERATION', RecSalesInvoiceLine.Description);
                        XMLNode.SetAttribute('TEMPSGLOBAL', Format(RecSalesInvoiceLine.Quantity, 0, 9));
                        XMLNode.SetAttribute('PRIXHT_MO', Format(RecSalesInvoiceLine.Amount, 0, 9));
                        XMLLDT.Add(XMLNode);
                    end;
                until RecSalesInvoiceLine.Next() = 0;

            XMLDossier.Add(XMLLDT);
            XMLRoot.Add(XMLDossier);

        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Dossier non trouvé');
            XMLRoot.Add(XmlElement.Create('DOSSIER'));
        end;

        // 6. Ajout final à la racine DMS
        XMLRootDMS.Add(XMLRoot);
    end;
    /*************INTERROGATION DE LA LISTE DES OR EN COURS*/
    procedure LZRF53T53(XmlRequest: Text) ResultXml: Text
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


    procedure LZRF52T52(CLIENT_DMS_ID: Text; VEHICULE_DMS_ID: Text) ResultXml: Text
    var
        RecCustomerLedgerEntry: Record "Cust. Ledger Entry";
        RecSalesInvoiceHeader: Record "Sales Invoice Header";
        XmlBody: Text;
        CodeResult: Text;
        TexteDMS: Text;
        XmlNodeValue: Text;
    begin
        XmlBody := '';

        // 🔹 Vérification des paramètres CLIENT_DMS_ID et VEHICULE_DMS_ID
        if (CLIENT_DMS_ID <> '') and
         (VEHICULE_DMS_ID <> '') then begin

            // 🔹 Filtrage des factures du client
            RecSalesInvoiceHeader.Reset();
            RecSalesInvoiceHeader.SetFilter("Sell-to Customer No.", '%1', CLIENT_DMS_ID);
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
                                'LibelleFacture="' + RecSalesInvoiceHeader."Service Order No." + '" ' +//to fix 'Service Order No.'
                                'JourFacture="' + Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 1)) + '" ' +
                                'MoisFacture="' + Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 2)) + '" ' +
                                'AnneeFacture="' + Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 3)) + '" ' +
                                'Nom="' + RecSalesInvoiceHeader."Sell-to Customer Name" + '" ';

                            // Montants
                            if RecCustomerLedgerEntry."Customer No." = RecSalesInvoiceHeader."Sell-to Customer No." then
                                XmlBody += 'MontantClient="0.0"';

                            if RecCustomerLedgerEntry."Customer No." = 'GARANTIE' then
                                XmlBody += 'MontantGarantie="0.0"';

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


    procedure LZRF46T23V1(var TempRoot: XmlElement; CurrentDMS: XmlElement; RqType: Text)
    var
        RecItem: Record Item;
        RecCustomer: Record Customer;
        SBManagement: Codeunit "STF Service Box Mgt";
        TempSalesLine: Record "Sales Line" temporary;

        XmlNodesPR: XmlNodeList;
        XmlNodePR: XmlNode;

        XMLRoot: XmlElement;
        NodePR: XmlElement;

        ReferencePR: Code[30];
        CodeImputationDMS_PR: Code[30];
        LigneDTId: Text[30];

        Remise: Decimal;
        PrixUnitaireHT: Decimal;
        PrixUnitaireTTC: Decimal;
        ErrorTxt: Text;
        i: Integer;
    begin

        Remise := 0;
        PrixUnitaireHT := 0;
        PrixUnitaireTTC := 0;

        // récupérer les PR
        if not CurrentDMS.SelectNodes('PR', XmlNodesPR) then
            exit;

        // créer racine LZRF46
        XMLRoot := XmlElement.Create('LZRF46');
        TempRoot.Add(XMLRoot);

        XMLRoot.SetAttribute('Code', '0');
        XMLRoot.SetAttribute('TexteDMS', '');

        CodeImputationDMS_PR := GetAttributeValue(CurrentDMS, 'CLIENT_DMS_ID');

        for i := 1 to XmlNodesPR.Count do begin

            XmlNodesPR.Get(i, XmlNodePR);

            ReferencePR := GetAttributeValue(XmlNodePR.AsXmlElement(), 'REFERENCE_PR');
            LigneDTId := GetAttributeValue(XmlNodePR.AsXmlElement(), 'LIGNE_DT_ID');

            RecItem.Reset();
            RecItem.SetRange("No.", ReferencePR);
            RecItem.SetRange(Blocked, false);

            if RecItem.FindFirst() then begin

                if (CodeImputationDMS_PR <> '') and RecCustomer.Get(CodeImputationDMS_PR) then begin

                    SBManagement.FindPriceDiscountItem(
                        RecItem."No.",
                        RecCustomer."No.",
                        ErrorTxt,
                        TempSalesLine);

                    if TempSalesLine.Count() > 0 then begin
                        Remise := TempSalesLine."Line Discount %";
                        PrixUnitaireHT := TempSalesLine."Unit Price";
                        PrixUnitaireTTC := PrixUnitaireHT * 1.19;
                    end else begin
                        PrixUnitaireHT := RecItem."Unit Price";
                        PrixUnitaireTTC := RecItem."Unit Price" * 1.19;
                    end;

                end else begin
                    PrixUnitaireHT := RecItem."Unit Price";
                    PrixUnitaireTTC := RecItem."Unit Price" * 1.19;
                end;

                NodePR := XmlElement.Create('PR');

                NodePR.SetAttribute('LIGNE_DT_ID', LigneDTId);
                NodePR.SetAttribute('ReferencePR', ReferencePR);
                NodePR.SetAttribute('LibellePR', RecItem.Description);
                NodePR.SetAttribute('PrixUnitaireHT', Format(PrixUnitaireHT));
                NodePR.SetAttribute('PrixUnitaireTTC', Format(PrixUnitaireTTC));
                NodePR.SetAttribute('PrixUV_HT', '');
                NodePR.SetAttribute('PrixUV_TTC', '');
                NodePR.SetAttribute('REMISE_DMS', Format(Remise));

                XMLRoot.Add(NodePR);

            end else begin

                NodePR := XmlElement.Create('PR');

                NodePR.SetAttribute('CODE_PR', '99');
                NodePR.SetAttribute('ReferencePR', ReferencePR);
                NodePR.SetAttribute('LibellePR', '');
                NodePR.SetAttribute('PrixUnitaireHT', '');
                NodePR.SetAttribute('PrixUnitaireTTC', '');
                NodePR.SetAttribute('Remise', '');

                XMLRoot.Add(NodePR);

            end;

        end;

    end;

    procedure LZRF45T22V1(var TempRoot: XmlElement; CurrentDMS: XmlElement; RqType: Text)
    var
        XmlNodeLDT: XmlNodeList;
        XmlNodesMO: XmlNodeList;
        XmlNodeMO: XmlNode;
        SBManagement: Codeunit "STF Service Box Mgt";

        XMLRoot: XmlElement;
        NodeMO: XmlElement;

        CODEIMPUTATIONDMS_MO: Code[30];
        CODEOPERATION: Code[20];
        LIGNE_DT_ID: Text[30];
        TEMPSGLOBAL: Decimal;

        PrixUnitHT: Decimal;
        PrixUnitTTC: Decimal;
        ErrorMsg: Text;

        i, j : Integer;
    begin
        // Récupérer les LDT
        if not CurrentDMS.SelectNodes('LDT', XmlNodeLDT) then
            exit;

        if XmlNodeLDT.Count = 0 then
            exit;

        // Créer la racine LZRF45
        XMLRoot := XmlElement.Create('LZRF45');
        TempRoot.Add(XMLRoot);

        XMLRoot.SetAttribute('Code', '0');
        XMLRoot.SetAttribute('TexteDMS', '');

        // Parcourir toutes les LDT
        for j := 1 to XmlNodeLDT.Count do begin
            XmlNodeLDT.Get(j, XmlNodeMO);

            // Récupérer toutes les MO de cette LDT
            if not XmlNodeMO.SelectNodes('MO', XmlNodesMO) then
                continue;

            for i := 1 to XmlNodesMO.Count do begin
                XmlNodesMO.Get(i, XmlNodeMO);

                // Récupérer les attributs
                CODEOPERATION := GetAttributeValue(XmlNodeMO.AsXmlElement(), 'CODEOPERATION');
                CODEIMPUTATIONDMS_MO := GetAttributeValue(XmlNodeMO.AsXmlElement(), 'CODEIMPUTATIONDMS_MO');
                LIGNE_DT_ID := GetAttributeValue(XmlNodeMO.AsXmlElement(), 'LIGNE_DT_ID');

                // Récupérer TEMPSGLOBAL
                TEMPSGLOBAL := 0;
                EVALUATE(TEMPSGLOBAL, CONVERTSTR(GetAttributeValue(XmlNodeMO.AsXmlElement(), 'TEMPSGLOBAL'), '.', ','));

                // Vérifier le client
                //CheckCustomerByTypeImputation(GetAttributeValue(XmlNodeMO.AsXmlElement(), TypeXX + '_MO'), CODEIMPUTATIONDMS_MO);

                // Créer le noeud MO
                NodeMO := XmlElement.Create('MO');
                XMLRoot.Add(NodeMO);

                NodeMO.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);
                NodeMO.SetAttribute('WR_CODE_OPERATION', CODEOPERATION);

                // Calculer les prix via FindPriceMO
                if SBManagement.FindPriceMO(CODEIMPUTATIONDMS_MO, CODEOPERATION, PrixUnitHT, PrixUnitTTC, ErrorMsg) then begin
                    NodeMO.SetAttribute('PrixUnitaireHT', Format(PrixUnitHT * TEMPSGLOBAL, 0, '<Precision,2:2><Standard Format,2>'));
                    NodeMO.SetAttribute('PrixUnitaireTTC', Format(PrixUnitTTC * TEMPSGLOBAL, 0, '<Precision,2:2><Standard Format,2>'));
                    NodeMO.SetAttribute('REMISE_DMS', '0'); // À adapter si remise spécifique
                    NodeMO.SetAttribute('TexteErreur', '');
                end else begin
                    NodeMO.SetAttribute('PrixUnitaireHT', '');
                    NodeMO.SetAttribute('PrixUnitaireTTC', '');
                    NodeMO.SetAttribute('REMISE_DMS', '');
                    NodeMO.SetAttribute('TexteErreur', ErrorMsg);
                end;
            end;
        end;
    end;

    procedure LZRF08T11(var XMLDom: XmlDocument; XMLNodeReq: XmlNode)
    var
        XmlNodesPR: XmlNodeList;
        XMLDms: XmlNode;
        XMLRoot: XmlElement;
        XMLNodeItem: XmlNode;
        ORIGINEVENTE_Attribute: XmlAttribute;
        DOSSIER_DMS_ID_Attribute: XmlAttribute;

        CODEIMPUTATIONDMS_PR: Text[30];
        LIGNE_DT_ID: Text[30];
        TYPEFACTURATION_PR: Code[2];
        i: Integer;

        // Records
        RecSalesLine: Record "Sales Line";
        RecServiceLine: Record "Service Line EDMS"; // Note: Vérifiez l'ID si c'est une table personnalisée

        // Variables de helper (assumées existantes ou à créer)
        XmlDocOut: XmlDocument;
    begin
        // --- Initialisation ---
        // En AL, selectSingleNode retourne un booléen et remplit une variable par référence
        if not XMLDom.SelectSingleNode('DMS', XMLDms) then
            exit;

        if not XMLNodeReq.SelectNodes('PR', XmlNodesPR) then
            exit;

        // --- Traitement Principal ---
        if XmlNodesPR.Count > 0 then begin

            // Recherche ou création du nœud racine LZRF08
            if not XMLDms.SelectSingleNode('LZRF08', XMLNodeItem) then begin
                XMLRoot := XmlElement.Create('LZRF08');
                XMLDms.AsXmlElement().Add(XMLRoot);
            end else
                XMLRoot := XMLNodeItem.AsXmlElement();

            // Récupération des attributs de XMLNodeReq
            ORIGINEVENTE_Attribute := GetXmlAttribute(XMLNodeReq, 'ORIGINEVENTE');
            DOSSIER_DMS_ID_Attribute := GetXmlAttribute(XMLNodeReq, 'DOSSIER_DMS_ID');

            // Ajout des attributs par défaut
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');

            // --- Boucle sur les éléments PR ---
            for i := 1 to XmlNodesPR.Count do begin
                XmlNodesPR.Get(i, XMLNodeItem);

                // Extraction des valeurs d'attributs
                CODEIMPUTATIONDMS_PR := GetAttributeValue(XMLDms, 'CLIENT_DMS_ID');

                // Note: TypeXX semble être une variable non définie dans votre snippet, 
                // je l'ai gardée telle quelle par rapport à votre logique.
                //CheckCustomerByTypeImputation(GetAttributeValue(XMLNodeItem, TypeXX + '_PR'), CODEIMPUTATIONDMS_PR);

                LIGNE_DT_ID := GetAttributeValue(XMLNodeItem, 'LIGNE_DT_ID');
                //TYPEFACTURATION_PR := CopyStr(GetAttributeValue(XMLNodeItem, TypeXX + '_PR'), 1, 2);

                // Appel de la procédure de traitement unitaire
                // "LZRF08--PR"(XMLDom, XMLRoot, GetAttributeValue(XMLNodeItem, 'REFERENCE_PR'), CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
            end;
        end;

        // Note: XMLDom.Validate() n'est généralement pas nécessaire en AL 
        // sauf si vous utilisez un schéma XML spécifique.
    end;

    local procedure GetAttributeValue(Node: XmlNode; Name: Text): Text
    var
        Attr: XmlAttribute;
    begin
        if Node.AsXmlElement().Attributes().Get(Name, Attr) then
            exit(Attr.Value);
        exit('');
    end;

    local procedure GetXmlAttribute(Node: XmlNode; Name: Text): XmlAttribute
    var
        Attr: XmlAttribute;
    begin
        Node.AsXmlElement().Attributes().Get(Name, Attr);
        exit(Attr);
    end;


    /* procedure CheckCustomerByTypeImputation(lTypeImputation: Text[30]; var lClient: Text[30])
    var
        SBOXSetup: Record "STF Servicebox Setup"; // Remplacez par le nom réel de la table 60209
    begin
        if not SBOXSetup.Get() then
            exit;

        case lTypeImputation of
            Format(SBOXSetup."Customer Imputation Code"):
                if lClient = '' then
                    lClient := SBOXSetup."Customer Imputation Code";

            Format(SBOXSetup."Warranty Imputation Code"):
                lClient := SBOXSetup."Warranty Imputation Code";

            Format(SBOXSetup."Insurance Imputation Code"):
                lClient := SBOXSetup."Insurance Imputation Code";

            Format(SBOXSetup."Campaign Imputation Code"):
                lClient := SBOXSetup."Campaign Imputation Code";

            Format(SBOXSetup."Contract Imputation Code"):
                lClient := SBOXSetup."Contract Imputation Code";

            Format(SBOXSetup."Internal Imputation Code"):
                lClient := SBOXSetup."Internal Imputation Code";
            else
                exit;
        end;
    end;


    procedure LZRC01T01V1(var XMLDom: XmlDocument; XMLNodeReq: XmlElement; RqType: Text[30])
    var
        RecCustomer: Record Customer;
        XMLDms: XmlElement;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        CodeInterrogation: Text;
        ChampsCmpl: Text;
        Count: Integer;
        TypeCust: Integer;
        TotalCount: Integer;
    begin
        // Récupération du nœud racine DMS
        if not XMLDom.GetRoot(XMLDms) then exit;

        // Création ou récupération du nœud LZRC01
        XMLRoot := XmlElement.Create('LZRC01');

        // Extraction des attributs de la requête (XMLNodeReq)
        CodeInterrogation := GetAttributeValue(XMLNodeReq, 'CODE_INTERROGATION');
        ChampsCmpl := GetAttributeValue(XMLNodeReq, 'CHAMPS_CMPL');

        // Préparation des filtres
        RecCustomer.Reset();
        //RecCustomer.SetRange(Blocked, false);

        case CodeInterrogation of
            '1': // Nom
                RecCustomer.SetFilter(Name, '%1', '*' + ChampsCmpl + '*');
            '2': // Téléphone
                RecCustomer.SetFilter("Phone No.", '%1', ChampsCmpl + '*');
            /* '3': // Téléphone Domicile
                RecCustomer.SetFilter("Home Phone No.", '%1', ChampsCmpl + '*');
            * /***  '4': // N° Client
                begin
                    RecCustomer.SetCurrentKey("No.");
                    RecCustomer.SetFilter("No.", '%1', ChampsCmpl + '*');
                end;
            '5': // Email
                RecCustomer.SetFilter("E-Mail", '%1', ChampsCmpl + '*');
            '6': // Mobile
                RecCustomer.SetFilter("Mobile Phone No.", '%1', ChampsCmpl + '*');
        end;

        Count := 0;
        TotalCount := RecCustomer.Count();

        if RecCustomer.FindSet() then
            repeat
                XMLNode := XmlElement.Create('CLIENT');
                XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");

                TypeCust :=1;// RecCustomer."Customer Type"; // Assumé Integer ou Option

                case TypeCust of
                    0: // Particulier ?
                        begin
                            XMLNode.SetAttribute('TypeClient', '1');
                            XMLNode.SetAttribute('Nom', RecCustomer."Name");
                            XMLNode.SetAttribute('Prenom', RecCustomer."Name 2");
                        end;
                    1: // Autre ?
                        begin
                            XMLNode.SetAttribute('TypeClient', '2');
                            XMLNode.SetAttribute('Nom', RecCustomer."Name");
                            //XMLNode.SetAttribute('Prenom', RecCustomer."First Name");
                        end;
                    /* 2: // Entreprise ?
                        begin
                            XMLNode.SetAttribute('TypeClient', '4');
                            XMLNode.SetAttribute('TypeEntreprise', RecCustomer."Title Code");
                            XMLNode.SetAttribute('RaisonSociale', RecCustomer.Name);
                        end; *** /
                end;

                // Champs communs
                XMLNode.SetAttribute('NumeroVoie', '');
                XMLNode.SetAttribute('TypeVoie', '');
                XMLNode.SetAttribute('Adresse1', RecCustomer.Address);
                XMLNode.SetAttribute('Ville', RecCustomer.City);
                XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");
                XMLNode.SetAttribute('NumeroCompte', RecCustomer."No.");

                XMLRoot.Add(XMLNode);
                Count += 1;
            until (RecCustomer.Next() = 0) or (Count = 30);

        // Gestion des attributs de résultat sur LZRC01
        if TotalCount = 1 then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');
            // Appel de la procédure de détail (à adapter selon votre conversion AL de LZRC03T03)
            LZRC03T03V1(RecCustomer."No.", XMLDom, RqType);
        end else if (TotalCount > 1) and (TotalCount < 30) then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', Format(Count) + ' Clients trouvés.');
        end else if TotalCount >= 30 then begin
            XMLRoot.SetAttribute('Code', '95');
            XMLRoot.SetAttribute('TexteDMS', 'Nombre de reponses trop grand. Precisez les parametres de recherche.');
        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Aucun Client trouve avec ces criteres !');
            XMLRoot.Add(XmlElement.Create('CLIENT'));
        end;

        XMLDms.Add(XMLRoot);
    end;
     */


    procedure LZRC01T01V1(var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement; RqType: Text[30])
    var
        RecCustomer: Record Customer;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        CodeInterrogation: Text;
        ChampsCmpl: Text;
        Count: Integer;
        TotalCount: Integer;
    begin
        // 1️⃣ Création de l'élément LZRC01 (qui sera un enfant de DMS)
        XMLRoot := XmlElement.Create('LZRC01');

        CodeInterrogation := GetAttributeValue(XMLNodeReq, 'CODE_INTERROGATION');
        ChampsCmpl := GetAttributeValue(XMLNodeReq, 'CHAMPS_CMPL');

        RecCustomer.Reset();

        // 2️⃣ Logique de filtrage
        case CodeInterrogation of
            '1':
                RecCustomer.SetFilter(Name, '@*' + ChampsCmpl + '*');
            '2':
                RecCustomer.SetFilter("Phone No.", '%1*', ChampsCmpl);
            '4':
                RecCustomer.SetFilter("No.", '%1*', ChampsCmpl);
            '5':
                RecCustomer.SetFilter("E-Mail", '%1*', ChampsCmpl);
            '6':
                RecCustomer.SetFilter("Mobile Phone No.", '%1*', ChampsCmpl);
        end;

        TotalCount := RecCustomer.Count();
        Count := 0;

        // 3️⃣ Boucle sur les clients
        if RecCustomer.FindSet() then
            repeat
                XMLNode := XmlElement.Create('CLIENT');
                XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");

                // TypeClient: 1 = Particulier, 2 = Société
                if RecCustomer."Partner Type" = RecCustomer."Partner Type"::Company then
                    XMLNode.SetAttribute('TypeClient', '2')
                else
                    XMLNode.SetAttribute('TypeClient', '1');

                XMLNode.SetAttribute('Nom', RecCustomer.Name);
                XMLNode.SetAttribute('Prenom', RecCustomer."Name 2");
                XMLNode.SetAttribute('NumeroVoie', '');
                XMLNode.SetAttribute('TypeVoie', '');
                XMLNode.SetAttribute('Adresse1', RecCustomer.Address);
                XMLNode.SetAttribute('Ville', RecCustomer.City);
                XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");
                XMLNode.SetAttribute('NumeroCompte', RecCustomer."No.");

                XMLRoot.Add(XMLNode); // Ajout du client à LZRC01
                Count += 1;
            until (RecCustomer.Next() = 0) or (Count = 30);

        // 4️⃣ Finalisation des attributs de statut
        if TotalCount = 0 then begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Aucun Client trouvé !');
        end else if TotalCount >= 30 then begin
            XMLRoot.SetAttribute('Code', '95');
            XMLRoot.SetAttribute('TexteDMS', 'Trop de réponses. Précisez les paramètres.');
        end else begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', Format(TotalCount) + ' Clients trouvés.');
        end;

        // 5️⃣ CRITIQUE : On ajoute LZRC01 comme ENFANT de DMS
        // Cela évite l'erreur "operation cannot be performed in this context"
        XMLRootDMS.Add(XMLRoot);
    end;

    local procedure GetAttributeValue(Node: XmlElement; AttribName: Text): Text
    var
        Attrib: XmlAttribute;
    begin
        if Node.Attributes().Get(AttribName, Attrib) then
            exit(Attrib.Value);
        exit('');
    end;

    procedure LZRF10T13V1(TempRoot: XmlElement; XMLNodeReq: XmlElement; RqType: Text)
    var
        XMLRoot, XMLNode, XMLNodeCustomer, XMLNodeVehicle : XmlElement;
        XmlNodesLDT, XMLNodesPR : XmlNodeList;
        RecSalesHeader: Record "Sales Header";
        RecServiceHeader: Record "Service Header EDMS";
        RecCustomer: Record Customer;
        RecVehicle: Record Vehicle;
        RecLocation: Record Location;
        Kilometrage: Decimal;
        i, j : Integer;
        NumPost: Code[10];
        lREMISEDOSSIER, lPRIXDOSSIER_TTC, lREMISELDT, lREMISELDTTOT, lPRIXLDTTTC, lPRIXLDTTTCTOT : Decimal;
        lTYPEREMISE: Integer;
        eDMSSetup: Record "STF Servicebox Setup";
        TmpNode: XmlElement;
        XMLNodeLDT_Temp: XmlNode;
        XMLNodePR_Temp: XmlNode;
        LigneDT_ID: Text;
        Text0003: Label 'Transfert du dossier réussi.';
        Text0004: Label 'Mise à jour du dossier réussi.';
        Text0007: Label 'Merci de renseigner le client de Passage PR dans le paramétrage eDMS.';
    begin
        XMLRoot := XmlElement.Create('LZRF10');
        TempRoot.Add(XMLRoot);

        XMLNodeCustomer := GetChildElement(XMLNodeReq, 'CLIENT');
        XMLNodeVehicle := GetChildElement(XMLNodeReq, 'VEHICULE');
        XMLNodeVehicle.SelectNodes('LDT', XmlNodesLDT);
        AddAttribute(XMLRoot, 'LDTcount', Format(XmlNodesLDT.Count()));

        NumPost := GetAttributeValue(XMLNodeReq, 'NumeroPoste');
        if CheckUserSetup(GetAttributeValue(XMLNodeReq, 'ID_UTILISATEUR'), '001') then begin

            eDMSSetup.Get();
            if eDMSSetup.accountCustomerUpdate then
                UpdateCustomer(XMLNodeCustomer);

            // Remise dossier
            if (GetAttributeValue(XMLNodeVehicle, 'REMISECLIENT') = '1') and
               (eDMSSetup.interfaceVersion = '13') then begin
                Evaluate(lREMISEDOSSIER,
                    ConvertStr(GetAttributeValue(XMLNodeVehicle, 'REMISEDOSSIER'), '.', ','));
                Evaluate(lTYPEREMISE,
                    GetAttributeValue(XMLNodeVehicle, 'TYPEREMISE'));
                Evaluate(lPRIXDOSSIER_TTC,
                    ConvertStr(GetAttributeValue(XMLNodeVehicle, 'PRIXDOSSIER_TTC'), '.', ','));
            end;

            // =========================================================
            // ORIGINEVENTE = 1 → Sales Order PR
            // =========================================================
            if GetAttributeValue(XMLNodeReq, 'ORIGINEVENTE') = '1' then begin

                if (GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '') or
                   (eDMSSetup.PRPassingAccount <> '') then begin

                    if RecLocation.FindFirst() then; // garde silencieux — Location vide gérée ci-dessous

                    RecSalesHeader.Init();
                    RecSalesHeader."Document Type" := RecSalesHeader."Document Type"::Order;
                    RecSalesHeader."Document Profile" := RecSalesHeader."Document Profile"::"Spare Parts Trade";

                    if RecLocation.Code <> '' then
                        RecSalesHeader.Validate("Location Code", RecLocation.Code);
                    RecSalesHeader.SetHideValidationDialog(true);

                    if GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '' then
                        RecSalesHeader.Validate(
                            "Sell-to Customer No.",
                            GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID'))
                    else
                        RecSalesHeader.Validate(
                            "Sell-to Customer No.",
                            eDMSSetup.PRPassingAccount);

                    RecSalesHeader.Validate("VIN SBOX", GetAttributeValue(XMLNodeVehicle, 'VIN'));
                    RecSalesHeader."Dossier SBOX" := true;
                    RecSalesHeader.Insert(true);

                    // Remise dossier
                    if eDMSSetup."Discount allowed" then begin
                        if lTYPEREMISE = 1 then
                            RecSalesHeader.Validate("Payment Discount %", lREMISEDOSSIER)
                        else
                            if (lPRIXDOSSIER_TTC + lREMISEDOSSIER) > 0 then
                                RecSalesHeader.Validate(
                                    "Payment Discount %",
                                    (lREMISEDOSSIER / (lPRIXDOSSIER_TTC + lREMISEDOSSIER)) * 100);
                        RecSalesHeader.Modify(true);
                    end;

                    lREMISELDTTOT := 0;
                    lPRIXLDTTTCTOT := 0;

                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'TexteDMS', Text0003);
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecSalesHeader."No.");

                    // ── Boucle LDT (1-based) ──────────────────────────
                    for i := 1 to XmlNodesLDT.Count() do begin

                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        LigneDT_ID := GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID');

                        XMLNodeLDT_Temp.AsXmlElement().SelectNodes('PR', XMLNodesPR);

                        // ── Boucle PR (1-based) ───────────────────────
                        for j := 1 to XMLNodesPR.Count() do begin
                            XMLNodesPR.Get(j, XMLNodePR_Temp);
                            if j = 1 then
                                InsertPRSalesLineLDT(
                                    RecSalesHeader,
                                    XMLNodePR_Temp.AsXmlElement(),
                                    CopyStr(LigneDT_ID, 1, 20))
                            else
                                InsertPRSalesLine(
                                    RecSalesHeader,
                                    XMLNodePR_Temp.AsXmlElement(),
                                    CopyStr(LigneDT_ID, 1, 20));
                        end;

                        // Remise LDT
                        if eDMSSetup."Discount allowed LDT" then begin
                            Evaluate(lREMISELDT,
                                ConvertStr(
                                    GetAttributeValue(
                                        XMLNodeLDT_Temp.AsXmlElement(), 'REMISE_PRICING_LDT'),
                                    '.', ','));
                            Evaluate(lPRIXLDTTTC,
                                ConvertStr(
                                    GetAttributeValue(
                                        XMLNodeLDT_Temp.AsXmlElement(), 'PRIXTTC_LDT'),
                                    '.', ','));
                            lREMISELDTTOT += lREMISELDT;
                            lPRIXLDTTTCTOT += lPRIXLDTTTC;
                        end;

                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID', LigneDT_ID);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', LigneDT_ID);

                    end; // fin boucle LDT

                    // Remise LDT totale
                    if eDMSSetup."Discount allowed LDT" then begin
                        if (lREMISELDTTOT + lPRIXLDTTTCTOT) > 0 then
                            RecSalesHeader.Validate(
                                "Payment Discount %",
                                RecSalesHeader."Payment Discount %" +
                                ((lREMISELDTTOT / (lREMISELDTTOT + lPRIXLDTTTCTOT)) * 100));
                        RecSalesHeader.Modify(true);
                    end;

                end else begin

                    // Pas de client ni de compte de passage → erreur
                    ErrorResponse(XMLRoot, Text0007);

                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(
                            TmpNode, 'LIGNE_DT_ID',
                            GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                    end;

                end;

                // =========================================================
                // ORIGINEVENTE = 2 → Service Order EDMS
                // =========================================================
            end else if GetAttributeValue(XMLNodeReq, 'ORIGINEVENTE') = '2' then begin

                RecServiceHeader.Init();
                RecServiceHeader."Document Type" := RecServiceHeader."Document Type"::Order;
                RecServiceHeader.Validate("Posting Date", WorkDate());
                RecServiceHeader.Validate("Document Date", WorkDate());
                RecServiceHeader.Validate("Deal Type", 'SR_LB');

                // Validate client et VIN AVANT Insert
                if RecCustomer.Get(GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID')) then
                    RecServiceHeader.Validate("Sell-to Customer No.", RecCustomer."No.")
                else
                    RecServiceHeader.Validate("Sell-to Customer No.", eDMSSetup.PRPassingAccount);

                RecServiceHeader.Validate("VIN", GetAttributeValue(XMLNodeVehicle, 'VIN'));
                RecServiceHeader.Insert(true); // Insert en dernier

                XMLNode := XmlElement.Create('DOSSIER');
                AddAttribute(XMLNode, 'Code', '0');
                AddAttribute(XMLNode, 'TexteDMS', 'Nouvelle Service Order EDMS créée.');
                AddAttribute(XMLNode, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                XMLRoot.Add(XMLNode);

                // =========================================================
                // ORIGINEVENTE autre → APV / mise à jour dossier
                // =========================================================
            end else begin

                if GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage') <> '' then
                    Evaluate(Kilometrage,
                        DelChr(GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage'), '=', ' '));

                if RecVehicle.Get(GetAttributeValue(XMLNodeVehicle, 'VIN')) then
                    if Kilometrage > RecVehicle."Variable Field Run 1" then begin
                        RecVehicle."Variable Field Run 1" := Kilometrage;
                        RecVehicle.Modify(true);
                    end;

                if GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID') <> '' then begin
                    RecServiceHeader.Reset();
                    RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                    RecServiceHeader.SetRange("No.", GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID'));
                    if RecServiceHeader.FindFirst() then begin
                        AddAttribute(XMLRoot, 'Code', '0');
                        AddAttribute(XMLRoot, 'TexteDMS', Text0004);
                        AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                    end;
                end;

            end;
        end else begin
            //     // Erreur Utilisateur
            ErrorResponse(XMLRoot, 'L''utilisateur utilisé n''est pas paramétré dans Business Central.');
        end;
    end;

    procedure LZRF10T13V111(TempRoot: XmlElement; XMLNodeReq: XmlElement; RqType: Text)
    var
        XMLDms, XMLRoot, XMLNode, XMLNodeCustomer, XMLNodeVehicle, XMLNodeServicePAD : XmlElement;
        XmlNodesLDT, XMLNodesPR, XMLNodesPADANOMALIE, XMLNodesPADCATEGORIECV, XMLNodesPADCONTROLEVISUEL, XMLNodesPADCHOIX : XmlNodeList;
        XMLNodeItem: XmlNode;
        RecSalesHeader: Record "Sales Header";
        RecServiceHeader: Record "Service Header EDMS"; // Assurez-vous que l'ID table correspond à votre extension
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        RecCustomer: Record Customer;
        RecVehicle: Record Vehicle;
        RecLocation: Record Location;
        Kilometrage: Decimal;
        i, j, PADi, PADj, PADk, JobLineNo : Integer;
        lDAY, lMonth, lYEAR : Integer;
        NumPost: Code[10];
        lREMISEDOSSIER, lPRIXDOSSIER_TTC, lREMISELDT, lREMISELDTTOT, lPRIXLDTTTC, lPRIXLDTTTCTOT : Decimal;
        lTYPEREMISE: Integer;
        lCodeUpdateDelete: Text[30];
        //RqType: Text[30];
        eDMSSetup: Record "STF Servicebox Setup";

        // variable manquante
        TmpNode: XmlElement;
        XMLNodeLDT_Temp: XmlNode;
        XMLNodePR_Temp: XmlNode;
        LigneDT_ID: Text;
        // TextConstants
        Text0001: Label 'L''utilisateur utilisé n''est pas paramétré dans INCADEA.';
        Text0002: Label 'Merci de renseigner la limite de crédit dans le champ Observation.';
        Text0003: Label 'Transfert du dossier réussi.';
        Text0004: Label 'Mise à jour du dossier réussi.';
        Text0007: Label 'Merci de renseigner le client de Passage PR dans le paramétrage eDMS.';
    begin

        // Création du nœud de réponse LZRF10
        XMLRoot := XmlElement.Create('LZRF10');
        TempRoot.Add(XMLRoot);

        // 2. Extraction des données de la requête
        XMLNodeCustomer := GetChildElement(XMLNodeReq, 'CLIENT');
        XMLNodeVehicle := GetChildElement(XMLNodeReq, 'VEHICULE');
        XMLNodeVehicle.SelectNodes('LDT', XmlNodesLDT);
        //AddAttribute(XMLRoot, 'LDTcount', Format(XMLNodesLDT.Count()));


        //XMLNodeReq.SelectNodes('//PR', XMLNodesPR);
        //AddAttribute(XMLRoot, 'PRcount', Format(XMLNodesPR.Count()));



        NumPost := GetAttributeValue(XMLNodeReq, 'NumeroPoste');

        // 3. Vérification Utilisateur
        // Vérification Utilisateur
        //if CheckUserSetup(GetAttributeValue(XMLNodeReq, 'ID_UTILISATEUR'), '001') then begin
        eDMSSetup.Get();
        if eDMSSetup.accountCustomerUpdate then
            UpdateCustomer(XMLNodeCustomer);

        // --- Logique Remise Dossier ---
        if (GetAttributeValue(XMLNodeVehicle, 'REMISECLIENT') = '1') and (eDMSSetup.interfaceVersion = '13') then begin
            Evaluate(lREMISEDOSSIER, ConvertStr(GetAttributeValue(XMLNodeVehicle, 'REMISEDOSSIER'), '.', ','));
            Evaluate(lTYPEREMISE, GetAttributeValue(XMLNodeVehicle, 'TYPEREMISE'));
            Evaluate(lPRIXDOSSIER_TTC, ConvertStr(GetAttributeValue(XMLNodeVehicle, 'PRIXDOSSIER_TTC'), '.', ','));
        end;

        // --- Gestion selon ORIGINEVENTE ---
        /*  if (GetAttributeValue(XMLNodeReq, 'ORIGINEVENTE') = '1') then begin

             if (GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') = '') and
                (eDMSSetup.PRPassingAccount = '') then begin

                 ErrorResponse(XMLRoot, Text0007);
                 exit;

             end;

             // Create Sales Header
             RecSalesHeader.Init();
             RecSalesHeader."Document Type" := RecSalesHeader."Document Type"::Order;
             RecSalesHeader."Document Profile" := RecSalesHeader."Document Profile"::"Spare Parts Trade";

             if RecLocation.FindFirst() then
                 RecSalesHeader.Validate("Location Code", RecLocation.Code);

             if GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '' then
                 RecSalesHeader.Validate("Sell-to Customer No.",
                     GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID'))
             else
                 RecSalesHeader.Validate("Sell-to Customer No.",
                     eDMSSetup.PRPassingAccount);

             RecSalesHeader.Validate("VIN SBOX",
                 GetAttributeValue(XMLNodeVehicle, 'VIN'));

             RecSalesHeader.Insert(true);

             // SUCCESS RESPONSE
             AddAttribute(XMLRoot, 'Code', '0');
             AddAttribute(XMLRoot, 'TexteDMS', Text0003);
             AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecSalesHeader."No.");

             //================================================
             // LDT LOOP
             //================================================
             for i := 1 to XmlNodesLDT.Count() do begin

                 XmlNodesLDT.Get(i, XMLNodeLDT_Temp);

                 LigneDT_ID :=
                 GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID');

                 XMLNodeLDT_Temp.AsXmlElement().SelectNodes('PR', XMLNodesPR);

                 for j := 1 to XMLNodesPR.Count() do begin

                     XMLNodesPR.Get(j, XMLNodePR_Temp);

                     if j = 1 then
                         InsertPRSalesLineLDT(
                             RecSalesHeader,
                             XMLNodePR_Temp.AsXmlElement(),
                             LigneDT_ID)
                     else
                         InsertPRSalesLine(
                             RecSalesHeader,
                             XMLNodePR_Temp.AsXmlElement(),
                             LigneDT_ID);

                 end;

                 XMLNode := XmlElement.Create('LDT');
                 AddAttribute(XMLNode, 'LIGNE_DT_ID', LigneDT_ID);
                 AddAttribute(XMLNode, 'LIGNE_DT_ID_DMS', LigneDT_ID);

                 XMLRoot.Add(XMLNode);

             end;

        */




        if GetAttributeValue(XMLNodeReq, 'ORIGINEVENTE') = '1' then begin
            if (GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '') or (eDMSSetup.PRPassingAccount <> '') then begin

                RecLocation.FindFirst();

                RecSalesHeader.Init();
                RecSalesHeader."Document Type" := RecSalesHeader."Document Type"::Order;
                RecSalesHeader."Document Profile" := RecSalesHeader."Document Profile"::"Spare Parts Trade";
                RecSalesHeader.Validate("Location Code", RecLocation.Code);
                RecSalesHeader.SetHideValidationDialog(true);

                if GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '' then
                    RecSalesHeader.Validate("Sell-to Customer No.", GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID'))
                else
                    RecSalesHeader.Validate("Sell-to Customer No.", eDMSSetup.PRPassingAccount);
                RecSalesHeader.Validate("VIN SBOX", GetAttributeValue(XMLNodeVehicle, 'VIN'));
                RecSalesHeader."Dossier SBOX" := true;

                RecSalesHeader.Insert(true);

                if eDMSSetup."Discount allowed" then begin // and CheckUserPermissionAPV(Text0102, RecUserSetup) then begin
                    if lTYPEREMISE = 1 then
                        RecSalesHeader.Validate("Payment Discount %", lREMISEDOSSIER)
                    else
                        if (lPRIXDOSSIER_TTC + lREMISEDOSSIER) > 0 then
                            RecSalesHeader.Validate("Payment Discount %",
                                (lREMISEDOSSIER / (lPRIXDOSSIER_TTC + lREMISEDOSSIER)) * 100);

                    RecSalesHeader.Modify(true);
                end;

                lREMISELDTTOT := 0;
                lPRIXLDTTTCTOT := 0;

                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'TexteDMS', Text0003);
                AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecSalesHeader."No.");

                for i := 0 to XMLNodesLDT.Count() - 1 do begin

                    XMLNodesLDT.Get(i, XMLNodeLDT_Temp);

                    LigneDT_ID :=
                        GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID');

                    XMLNodeLDT_Temp.AsXmlElement().SelectNodes('PR', XMLNodesPR);
                    for j := 0 to XMLNodesPR.Count() - 1 do begin

                        XMLNodesPR.Get(j, XMLNodePR_Temp);

                        if j = 0 then
                            InsertPRSalesLineLDT(
                                RecSalesHeader,
                                XMLNodePR_Temp.AsXmlElement(),
                                CopyStr(LigneDT_ID, 1, 20))
                        else
                            InsertPRSalesLine(
                                RecSalesHeader,
                                XMLNodePR_Temp.AsXmlElement(),
                                CopyStr(LigneDT_ID, 1, 20));
                    end;

                    if eDMSSetup."Discount allowed LDT" then begin  // and CheckUserPermissionAPV(Text0102, RecUserSetup) then begin

                        Evaluate(lREMISELDT,
                            ConvertStr(
                                GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'REMISE_PRICING_LDT'),
                                '.', ','));

                        Evaluate(lPRIXLDTTTC,
                            ConvertStr(
                                GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'PRIXTTC_LDT'),
                                '.', ','));

                        lREMISELDTTOT += lREMISELDT;
                        lPRIXLDTTTCTOT += lPRIXLDTTTC;
                    end;

                    AddElement(XMLRoot, 'LDT', TmpNode);

                    AddAttribute(TmpNode, 'LIGNE_DT_ID', LigneDT_ID);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', LigneDT_ID);

                end;

                if eDMSSetup."Discount allowed LDT" then begin
                    if (lREMISELDTTOT + lPRIXLDTTTCTOT) > 0 then
                        RecSalesHeader.Validate(
                            "Payment Discount %",
                            RecSalesHeader."Payment Discount %" +
                            ((lREMISELDTTOT / (lREMISELDTTOT + lPRIXLDTTTCTOT)) * 100));

                    RecSalesHeader.Modify(true);
                end;

            end else begin

                ErrorResponse(XMLRoot, Text0007);

                for i := 0 to XMLNodesLDT.Count() - 1 do begin
                    XMLNodesLDT.Get(i, XMLNodeLDT_Temp);

                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(
                        TmpNode,
                        'LIGNE_DT_ID',
                        GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                end;
            end;








            // Votre code de création Sales Order ici...
        end else if GetAttributeValue(XMLNodeReq, 'ORIGINEVENTE') = '2' then begin
            // --- Bloc nouvelle Service Order EDMS ---
            RecServiceHeader.Init();
            RecServiceHeader."Document Type" := RecServiceHeader."Document Type"::Order;
            RecServiceHeader.Validate("Posting Date", WorkDate());
            RecServiceHeader.Validate("Document Date", WorkDate());

            RecServiceHeader.Validate("Deal Type", 'SR_LB');
            RecServiceHeader.Insert(true);

            if RecCustomer.Get(GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID')) then
                RecServiceHeader.Validate("Sell-to Customer No.", RecCustomer."No.")
            else
                RecServiceHeader.Validate("Sell-to Customer No.", eDMSSetup.PRPassingAccount);

            RecServiceHeader.Validate("VIN", GetAttributeValue(XMLNodeVehicle, 'VIN'));
            RecServiceHeader.Modify();
            // Réponse XML
            XMLNode := XmlElement.Create('DOSSIER');
            AddAttribute(XMLNode, 'Code', '0');
            AddAttribute(XMLNode, 'TexteDMS', 'Nouvelle Service Order EDMS créée.');
            AddAttribute(XMLNode, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
            XMLRoot.Add(XMLNode);
        end else begin
            // --- Bloc APV ou autres cas ---
            Evaluate(Kilometrage, DelChr(GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage'), '=', ' '));

            if RecVehicle.Get(GetAttributeValue(XMLNodeVehicle, 'VIN')) then
                if Kilometrage > RecVehicle."Variable Field Run 1" then begin
                    RecVehicle."Variable Field Run 1" := Kilometrage;
                    RecVehicle.Modify(true);
                end;

            // Logique mise à jour ou création dossier service
            if GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID') <> '' then begin
                RecServiceHeader.Reset();
                RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                RecServiceHeader.SetRange("No.", GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID'));
                if RecServiceHeader.FindFirst() then begin
                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'TexteDMS', Text0004);
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                end;
            end;
        end;

    end;
    // else begin
    //     // Erreur Utilisateur
    //     ErrorResponse(XMLRoot, Text0001);
    // end;
    //end;

    procedure AddElement(var Parent: XmlElement; NodeName: Text; var NewNode: XmlElement)
    begin
        NewNode := XmlElement.Create(NodeName);
        Parent.Add(NewNode);
    end;

    local procedure GetChildElement(Parent: XmlElement; Name: Text): XmlElement
    var
        Node: XmlNode;
        Elem: XmlElement;
    begin
        if Parent.SelectSingleNode(Name, Node) then
            exit(Node.AsXmlElement());
        exit(Elem); // Retourne un élément vide si non trouvé
    end;

    local procedure AddAttribute(var XMLNode: XmlElement; Name: Text[250]; NodeValue: Text[250])
    begin
        if NodeValue <> '' then begin
            XMLNode.SetAttribute(Name, NodeValue);
        end;
    end;




    /// <summary>Insère une ligne de vente pour une pièce (PR) – ligne standard.</summary>
    procedure InsertPRSalesLine(RecSalesHeader: Record "Sales Header"; XMLNodePR: XmlElement; LigneDT: Code[20])
    var
        RecSalesLine: Record "Sales Line";
        qte: Decimal;
        item: Record Item;
    begin
        if not item.Get(GetItemNo(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'))) then
            exit;
        RecSalesLine.Init();
        RecSalesLine."Document Type" := RecSalesHeader."Document Type";
        RecSalesLine."Document No." := RecSalesHeader."No.";
        RecSalesLine."Line No." := GetNextSalesLineNo(RecSalesHeader);
        RecSalesLine.Validate(Type, RecSalesLine.Type::Item);
        RecSalesLine.Validate("No.", item."No.");
        if Evaluate(qte, ConvertStr(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'), '.', ',')) then;
        RecSalesLine.Validate(Quantity, qte);
        RecSalesLine."Line LDT" := LigneDT;
        RecSalesLine.Insert(true);
    end;

    /// <summary>Insère une ligne de vente pour une pièce (PR) – avec filtre LDT.</summary>
    procedure InsertPRSalesLineLDT(RecSalesHeader: Record "Sales Header"; XMLNodePR: XmlElement; LigneDT: Code[20])
    var
        RecSalesLine: Record "Sales Line";
        qte: Decimal;
        item: Record Item;
    begin
        if not item.Get(GetItemNo(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'))) then
            exit;
        RecSalesLine.Init();
        RecSalesLine."Document Type" := RecSalesHeader."Document Type";
        RecSalesLine."Document No." := RecSalesHeader."No.";
        RecSalesLine."Line No." := GetNextSalesLineNo(RecSalesHeader);
        RecSalesLine.Validate(Type, RecSalesLine.Type::Item);
        RecSalesLine.Validate("No.", item."No.");
        RecSalesLine."Line LDT" := LigneDT;
        RecSalesLine."Line LDT Filter" := LigneDT;
        if Evaluate(qte, ConvertStr(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'), '.', ',')) then;
        RecSalesLine.Validate(Quantity, qte);
        RecSalesLine.Insert(true);
    end;


    procedure GetNextSalesLineNo(RecSalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", RecSalesHeader."Document Type");
        SalesLine.SetRange("Document No.", RecSalesHeader."No.");
        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure GetNextServiceLineNo(RecServiceJobLine: Record "Service Order Symptome  EDMS"): Integer
    var
        ServiceLine: Record "Service Line EDMS";
    begin
        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", RecServiceJobLine."Document Type");
        ServiceLine.SetRange("Document No.", RecServiceJobLine."Document No.");
        if ServiceLine.FindLast() then
            exit(ServiceLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure GetItemNo(REFERENCE_PR: Text[30]): Code[20]
    begin
        // Si la référence fait 10 caractères et commence par 0000, on supprime les 4 premiers
        if (StrLen(REFERENCE_PR) = 10) and (StrPos(REFERENCE_PR, '0000') = 1) then
            exit(DelStr(REFERENCE_PR, 1, 4))
        else
            exit(REFERENCE_PR);
    end;

    procedure SetItemNo(REFERENCE_PR: Text[30]): Code[20]
    begin
        // Si la référence fait 6 caractères, on ajoute 0000 au début pour PSA
        if (StrLen(REFERENCE_PR) = 6) then
            exit(InsStr(REFERENCE_PR, '0000', 1))
        else
            exit(REFERENCE_PR);
    end;


    procedure CheckUserSetup(Utilisateur: Text[30]; PostCode: Code[10]) userOK: Boolean

    var
        RecLocation: Record Location;
        RecUserSetup: Record "User Setup";
        RecWarehouseEmployee: Record "Warehouse Employee";
    begin
        userOK := false;
        Clear(RecUserSetup);
        RecUserSetup.Reset();

        // On cherche l'utilisateur via son code ServiceBOX (SBOX)
        RecUserSetup.SetRange("ServiceBOX Code", Utilisateur);

        if RecUserSetup.FindFirst() then begin
            RecWarehouseEmployee.Reset();
            RecWarehouseEmployee.SetRange("User ID", RecUserSetup."User ID");
            RecWarehouseEmployee.SetRange("Service BOX Location", true);

            // Gestion multi-magasins basée sur le code poste
            if RecWarehouseEmployee.Count > 1 then begin
                if PostCode <> '' then
                    RecWarehouseEmployee.SetRange("Service BOX Post", PostCode);
            end;

            if RecWarehouseEmployee.FindFirst() then begin
                RecLocation.Reset();
                if RecLocation.Get(RecWarehouseEmployee."Location Code") then begin
                    userOK := true;
                end;
            end
            else begin
                // Logique de repli (Fallback) : on cherche la première localisation SBOX sans filtre de poste
                RecWarehouseEmployee.Reset();
                RecWarehouseEmployee.SetRange("User ID", RecUserSetup."User ID");
                RecWarehouseEmployee.SetRange("Service BOX Location", true);
                if RecWarehouseEmployee.FindFirst() then begin
                    RecLocation.Reset();
                    if RecLocation.Get(RecWarehouseEmployee."Location Code") then begin
                        userOK := true;
                    end;
                end;
            end;
        end;
    end;

    procedure UpdateCustomer(XMLNodeClient: XmlElement)
    var
        RecCustomer: Record Customer;
        // Note: Le Codeunit 5029101 est spécifique à Incadea pour la gestion des adresses
        // AddressManagement: Codeunit "Address Management"; 
        ClientDmsId: Code[20];
    begin
        ClientDmsId := GetAttributeValue(XMLNodeClient, 'CLIENT_DMS_ID');

        // On ne tente la mise à jour que si l'ID client est fourni et existe
        if (ClientDmsId <> '') and RecCustomer.Get(ClientDmsId) then begin
            //To fix
            // Désactivation temporaire de la validation pour permettre la modification
            //RecCustomer."Validate Customer" := false;
            RecCustomer.Modify();

            // --- Mapping des champs ---
            // Les lignes suivantes étaient commentées dans votre code original, 
            // je les ai laissées en commentaire AL au cas où vous souhaiteriez les réactiver.
            /*
            case GetAttributeValue(XMLNodeClient, 'TypeClient') of
                '1': RecCustomer."Customer Type" := 0;
                '2': RecCustomer."Customer Type" := 1;
                '4': RecCustomer."Customer Type" := 2;
            end;
            RecCustomer.Validate("First Name", GetAttributeValue(XMLNodeClient, 'Nom'));
            RecCustomer.Validate("Last Name", GetAttributeValue(XMLNodeClient, 'Prenom'));
            */

            // Informations de contact
            RecCustomer."Mobile Phone No." := GetAttributeValue(XMLNodeClient, 'PhoneMobile');
            RecCustomer."E-Mail" := GetAttributeValue(XMLNodeClient, 'Email');
            //RecCustomer."Title Code" := GetAttributeValue(XMLNodeClient, 'TypeEntreprise');

            // Adresse
            RecCustomer.Address := GetAttributeValue(XMLNodeClient, 'Adresse1');
            RecCustomer."Address 2" := GetAttributeValue(XMLNodeClient, 'Adresse2');
            RecCustomer.City := GetAttributeValue(XMLNodeClient, 'Ville');
            RecCustomer."Post Code" := GetAttributeValue(XMLNodeClient, 'CodePostal');
            RecCustomer."Country/Region Code" := GetAttributeValue(XMLNodeClient, 'Pays');

            // Téléphones et Fax
            // RecCustomer."Home Phone No." := GetAttributeValue(XMLNodeClient, 'PhoneDomicile');
            RecCustomer."Fax No." := GetAttributeValue(XMLNodeClient, 'Fax');
            RecCustomer."Phone No." := GetAttributeValue(XMLNodeClient, 'PhoneBureau');

            // Finalisation de la mise à jour

            //To fix 
            /*  if not RecCustomer."Validate Customer" then begin
                 RecCustomer."Validate Customer" := true;
                 RecCustomer."Last Date Modified" := Today;
             end; */

            RecCustomer.Modify();
        end;
    end;

    procedure ErrorResponse(var xmlRoot: XmlElement; message: Text[100])
    begin
        // Le code -2 indique généralement une erreur métier ou d'authentification à PSA
        AddAttribute(xmlRoot, 'Code', '-2');
        AddAttribute(xmlRoot, 'TexteDMS', message);
    end;

    procedure CheckStatus(var XMLDom: XmlDocument)
    var
        XMLDms: XmlElement;
        XMLRootNode: XmlNode;
        eDMSSetup: Record "STF Servicebox Setup"; // Vérifiez le nom exact de votre table de paramétrage
    begin
        // En AL, on récupère l'élément racine (DMS)
        if not XMLDom.GetRoot(XMLDms) then
            exit;

        eDMSSetup.Get();

        // Utilisation de FORMAT(..., 0, 9) pour les booléens (donne 'true'/'false' en minuscule pour XML)
        // Contrairement à l'Automation, on passe le XmlElement à AddAttribute

        AddAttribute(XMLDms, 'poolInitialised', Format(eDMSSetup.poolInitialised, 0, 9));
        AddAttribute(XMLDms, 'poolConnected', Format(eDMSSetup.poolConnected, 0, 9));
        AddAttribute(XMLDms, 'interfaceVersion', Format(eDMSSetup.interfaceVersion));
        AddAttribute(XMLDms, 'transfertMode', Format(eDMSSetup.transfertMode));

        // Informations DMS (Incadea / PSA)
        AddAttribute(XMLDms, 'dmsCompany', Format(eDMSSetup.dmsCompany));
        AddAttribute(XMLDms, 'dmsName', Format(eDMSSetup.dmsName));
        AddAttribute(XMLDms, 'dmsVersion', Format(eDMSSetup.dmsVersion));

        // Comptes de passage et identification
        AddAttribute(XMLDms, 'APVPassingAccount', eDMSSetup.APVPassingAccount);
        AddAttribute(XMLDms, 'PRPassingAccount', eDMSSetup.PRPassingAccount);
        AddAttribute(XMLDms, 'LDTIdentification', Format(eDMSSetup.LDTIdentification));
        AddAttribute(XMLDms, 'addressPattern', Format(eDMSSetup.addressPattern));

        // Paramètres de création/mise à jour
        AddAttribute(XMLDms, 'accountCustomerUpdate', Format(eDMSSetup.accountCustomerUpdate, 0, 9));
        AddAttribute(XMLDms, 'knownCustomerUpdate', Format(eDMSSetup.knownCustomerUpdate, 0, 9));
        AddAttribute(XMLDms, 'vehicleCreation', Format(eDMSSetup.vehicleCreation, 0, 9));
        AddAttribute(XMLDms, 'customerCreation', Format(eDMSSetup.customerCreation, 0, 9));

        // Note : XMLDom.validate() n'existe pas en natif AL de la même manière.
        // La validation se fait généralement au moment du chargement (Load) ou via un schéma XSD si nécessaire.
    end;

    procedure LZRC03T03V1(CLIENT_DMS_ID: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
    var
        RecCustomer: Record Customer;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
    begin
        // 1. Création du nœud racine LZRC03 (Enfant de DMS)
        XMLRoot := XmlElement.Create('LZRC03');

        RecCustomer.Reset();
        RecCustomer.SetRange("No.", CLIENT_DMS_ID);

        if RecCustomer.FindFirst() then begin
            // ✅ Code 0 : Client trouvé
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');

            XMLNode := XmlElement.Create('CLIENT');
            XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");

            // Mapping du "Partner Type" (BC) vers "TypeClient" (PSA)
            case RecCustomer."Partner Type" of
                RecCustomer."Partner Type"::Person:
                    begin
                        XMLNode.SetAttribute('TypeClient', '1'); // Particulier
                        XMLNode.SetAttribute('Nom', RecCustomer.Name);
                        XMLNode.SetAttribute('Prenom', RecCustomer."Name 2");
                    end;
                RecCustomer."Partner Type"::Company:
                    begin
                        XMLNode.SetAttribute('TypeClient', '4'); // Entreprise / Flotte
                        XMLNode.SetAttribute('RaisonSociale', RecCustomer.Name);
                        XMLNode.SetAttribute('Nom', RecCustomer.Name);
                    end;
                else begin
                    XMLNode.SetAttribute('TypeClient', '2'); // Autre / Défaut
                    XMLNode.SetAttribute('Nom', RecCustomer.Name);
                end;
            end;

            // Informations de contact et adresse
            XMLNode.SetAttribute('PhoneMobile', RecCustomer."Mobile Phone No.");
            XMLNode.SetAttribute('Email', RecCustomer."E-Mail");
            XMLNode.SetAttribute('NumeroVoie', '');
            XMLNode.SetAttribute('TypeVoie', '');
            XMLNode.SetAttribute('Adresse1', RecCustomer.Address);
            XMLNode.SetAttribute('Adresse2', RecCustomer."Address 2");
            XMLNode.SetAttribute('Ville', RecCustomer.City);
            XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");

            if RecCustomer."Country/Region Code" <> '' then
                XMLNode.SetAttribute('Pays', RecCustomer."Country/Region Code")
            else
                XMLNode.SetAttribute('Pays', 'TN');

            XMLNode.SetAttribute('PhoneDomicile', '');
            XMLNode.SetAttribute('Fax', RecCustomer."Fax No.");
            XMLNode.SetAttribute('PhoneBureau', RecCustomer."Phone No.");
            XMLNode.SetAttribute('NumeroCompte', RecCustomer."No.");

            // Calcul du solde
            RecCustomer.CalcFields("Balance (LCY)");
            XMLNode.SetAttribute('SoldeClient', Format(RecCustomer."Balance (LCY)", 0, 9));

            XMLNode.SetAttribute('Observations', '');
            XMLNode.SetAttribute('TEXTE_LIBRE', '');

            XMLRoot.Add(XMLNode);

        end else begin
            // ❌ Code 99 : Client non trouvé
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Client ' + CLIENT_DMS_ID + ' inconnu');
        end;

        // 3. AJOUT au nœud parent <DMS> au lieu du Document
        XMLRootDMS.Add(XMLRoot);
    end;

    procedure LZRC02T02V1(VEHICULE_DMS_ID: Text[30]; VIN: Text[30]; IMMATRICULATION: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle"; // Table 5025400
        RecCustomer: Record Customer;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        Count: Integer;
    begin
        // 1. Création de l'élément LZRC02
        XMLRoot := XmlElement.Create('LZRC02');

        // 2. Recherche du véhicule
        RecVehicle.Reset();
        if (VEHICULE_DMS_ID <> '') then
            RecVehicle.SetRange(VIN, VEHICULE_DMS_ID)
        else if (VIN <> '') then
            RecVehicle.SetRange(VIN, VIN)
        else if (IMMATRICULATION <> '') then
            RecVehicle.SetRange("Registration No.", IMMATRICULATION);

        Count := 0;

        // 3. Logique de décision
        if (VEHICULE_DMS_ID = '') and (VIN = '') and (IMMATRICULATION = '') then begin
            XMLRoot.SetAttribute('Code', '1');
            XMLRoot.SetAttribute('TexteDMS', 'La recherche par véhicule est impossible. Veuillez indiquer le VIN.');
        end else if RecVehicle.FindFirst() then begin

            if RecVehicle."Customer No." <> '' then begin
                RecCustomer.Reset();
                RecCustomer.SetRange("No.", RecVehicle."Customer No.");
                RecCustomer.SetRange(Blocked, RecCustomer.Blocked::" ");

                if RecCustomer.FindSet() then begin
                    repeat
                        Count += 1;
                        XMLNode := XmlElement.Create('CLIENT');
                        XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");

                        case RecCustomer."Partner Type" of
                            RecCustomer."Partner Type"::Person:
                                begin
                                    XMLNode.SetAttribute('TypeClient', '1');
                                    XMLNode.SetAttribute('Nom', RecCustomer.Name);
                                    XMLNode.SetAttribute('Prenom', RecCustomer."Name 2");
                                end;
                            RecCustomer."Partner Type"::Company:
                                begin
                                    XMLNode.SetAttribute('TypeClient', '4');
                                    XMLNode.SetAttribute('RaisonSociale', RecCustomer.Name);
                                end;
                            else begin
                                XMLNode.SetAttribute('TypeClient', '2');
                                XMLNode.SetAttribute('Nom', RecCustomer.Name);
                            end;
                        end;

                        XMLNode.SetAttribute('NumeroVoie', '');
                        XMLNode.SetAttribute('TypeVoie', '');
                        XMLNode.SetAttribute('Adresse1', RecCustomer.Address);
                        XMLNode.SetAttribute('Ville', RecCustomer.City);
                        XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");
                        XMLNode.SetAttribute('NumeroCompte', RecCustomer."No.");

                        XMLRoot.Add(XMLNode);
                    until (RecCustomer.Next() = 0) or (Count = 30);
                end;
            end else begin
                XMLRoot.SetAttribute('Code', '98');
                XMLRoot.SetAttribute('TexteDMS', 'Aucun client n''est associé à ce véhicule.');
            end;
        end;

        // 4. Finalisation du statut
        if (Count = 1) then begin
            // ATTENTION : Si tu appelles LZRC03 ici, assure-toi qu'elle accepte aussi XmlElement
            LZRC03T03V1(RecVehicle."Customer No.", XMLRootDMS, RqType);
            exit;
        end;

        if (Count > 1) and (Count < 30) then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');
        end else if (Count >= 30) then begin
            XMLRoot.SetAttribute('Code', '95');
            XMLRoot.SetAttribute('TexteDMS', 'Nombre de réponses trop grand. Précisez les paramètres.');
        end else if (XMLRoot.Attributes().Count() = 0) then begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Véhicule ou Client non trouvé.');
        end;

        // 5. AJOUT à la racine DMS (L'étape qui corrige l'erreur)
        XMLRootDMS.Add(XMLRoot);
    end;

    procedure LZRC07T05V1(CLIENT_DMS_ID: Text[30]; var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle"; // Table 5025400
        RecCustomer: Record Customer;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        Count: Integer;
        TotalVehicles: Integer;
    begin
        // 1. Création du nœud de réponse LZRC07
        XMLRoot := XmlElement.Create('LZRC07');

        // 2. Vérification de l'existence du client
        if (CLIENT_DMS_ID = '') or (not RecCustomer.Get(CLIENT_DMS_ID)) then begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Compte client inexistant ou ID vide');
        end else begin
            // 3. Recherche des véhicules associés au client
            RecVehicle.Reset();
            RecVehicle.SetRange("Customer No.", CLIENT_DMS_ID);
            TotalVehicles := RecVehicle.Count();
            Count := 0;

            if RecVehicle.FindSet() then begin
                repeat
                    Count += 1;
                    XMLNode := XmlElement.Create('VEHICULE');
                    XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);

                    // Décomposition standard du VIN PSA
                    XMLNode.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                    XMLNode.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                    XMLNode.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));

                    XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");
                    XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
                    XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");

                    XMLRoot.Add(XMLNode);
                until (RecVehicle.Next() = 0) or (Count = 30);

                // 4. Logique de retour selon le volume de résultats
                if TotalVehicles = 1 then begin
                    XMLRoot.SetAttribute('Code', '0');
                    XMLRoot.SetAttribute('TexteDMS', 'Un seul véhicule trouvé.');

                    // ✅ CORRECTION : Appel des détails techniques (T09) avec XMLRootDMS
                    LZRC23T09V1(RecVehicle.VIN, XMLRootDMS, RqType);
                end else if (TotalVehicles > 1) and (TotalVehicles <= 30) then begin
                    XMLRoot.SetAttribute('Code', '0');
                    XMLRoot.SetAttribute('TexteDMS', Format(TotalVehicles) + ' véhicules trouvés.');
                end else if (TotalVehicles > 30) then begin
                    XMLRoot.SetAttribute('Code', '95');
                    XMLRoot.SetAttribute('TexteDMS', 'Trop de résultats. Précisez la recherche.');
                end;

            end else begin
                // Cas où le client existe mais n'a pas de véhicule rattaché
                XMLRoot.SetAttribute('Code', '98');
                XMLRoot.SetAttribute('TexteDMS', 'Aucun véhicule associé à ce client.');
                XMLRoot.Add(XmlElement.Create('VEHICULE')); // Nœud vide pour respecter le schéma
            end;
        end;

        // 5. AJOUT de LZRC07 à la racine DMS
        XMLRootDMS.Add(XMLRoot);
    end;

    procedure LZRC08T06V1(var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle";
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        CODE_INTERROGATION: Text[30];
        CHAMPS_CMPL: Text[30];
        Count, TotalVehicles : Integer;
    begin
        CODE_INTERROGATION := GetAttributeValue(XMLNodeReq, 'CODE_INTERROGATION');
        CHAMPS_CMPL := GetAttributeValue(XMLNodeReq, 'CHAMPS_CMPL');

        // 1. Crée le bloc racine LZRC08
        XMLRoot := XmlElement.Create('LZRC08');

        RecVehicle.Reset();
        case CODE_INTERROGATION of
            '1':
                RecVehicle.SetFilter(VIN, '*' + CHAMPS_CMPL);
            '2':
                if StrLen(CHAMPS_CMPL) <= 11 then
                    RecVehicle.SetFilter("Registration No.", '*' + CHAMPS_CMPL + '*')
                else begin
                    XMLRoot.SetAttribute('Code', '99');
                    XMLRoot.SetAttribute('TexteDMS', 'L''immatriculation introduite n''est pas valide !');
                    XMLRootDMS.Add(XMLRoot);
                    exit;
                end;
        end;

        TotalVehicles := RecVehicle.Count();
        Count := 0;

        if RecVehicle.FindSet() then begin
            repeat
                Count += 1;
                XMLNode := XmlElement.Create('VEHICULE');
                XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
                XMLNode.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                XMLNode.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                XMLNode.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");
                XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
                XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");
                XMLRoot.Add(XMLNode);
            until (RecVehicle.Next() = 0) or (Count = 30);

            if TotalVehicles >= 30 then begin
                XMLRoot.SetAttribute('Code', '95');
                XMLRoot.SetAttribute('TexteDMS', 'Trop de réponses.');
            end else begin
                XMLRoot.SetAttribute('Code', '0');
                XMLRoot.SetAttribute('TexteDMS', '');
            end;
        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Aucun véhicule trouvé avec ces critères !');
        end;

        // 2. AJOUT FINAL AU PARENT UNIQUE
        XMLRootDMS.Add(XMLRoot);
    end;

    procedure LZRC23T09V1(var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle"; // Table 5025400
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        VEHICULE_DMS_ID: Text[30];
        DateToUse: Date;
    begin
        // 1. Extraction de l'ID Véhicule (priorité à VEHICULE_DMS_ID, sinon VIN)
        VEHICULE_DMS_ID := GetAttributeValue(XMLNodeReq, 'VEHICULE_DMS_ID');
        if VEHICULE_DMS_ID = '' then
            VEHICULE_DMS_ID := GetAttributeValue(XMLNodeReq, 'VIN');

        // 2. Création du nœud de réponse LZRC23
        XMLRoot := XmlElement.Create('LZRC23');

        RecVehicle.Reset();
        RecVehicle.SetRange(VIN, VEHICULE_DMS_ID);

        if RecVehicle.FindFirst() then begin
            // ✅ Code 0 : Véhicule trouvé
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');

            XMLNode := XmlElement.Create('VEHICULE');
            XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
            XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
            XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");

            // Décomposition du VIN pour le catalogue PSA (WMI=3, VDS=6, VIS=8)
            XMLNode.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
            XMLNode.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
            XMLNode.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));

            XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");

            // Gestion de la date de mise en circulation
            if (RecVehicle."First Registration Date" <> 0D) then
                DateToUse := RecVehicle."First Registration Date"
            else
                DateToUse := RecVehicle."Creation Date";

            if DateToUse <> 0D then begin
                XMLNode.SetAttribute('AnneeMiseCirculation', Format(Date2DMY(DateToUse, 3)));
                XMLNode.SetAttribute('MoisMiseCirculation', Format(Date2DMY(DateToUse, 2)));
                XMLNode.SetAttribute('JourMiseCirculation', Format(Date2DMY(DateToUse, 1)));
            end;

            // Kilométrage (Format 0, 9 pour éviter les espaces de milliers)
            XMLNode.SetAttribute('DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, 9));

            XMLNode.SetAttribute('CodeOPB', '');
            XMLNode.SetAttribute('TypeEntretien', '');

            XMLRoot.Add(XMLNode);

            // 3. Appel en cascade vers la liste des clients (T02) 
            // Note : On passe XMLRootDMS (le nœud <DMS>) conformément à la nouvelle signature de T02
            if RqType in ['05', '06', '09'] then
                LZRC02T02V1(RecVehicle.VIN, RecVehicle.VIN, RecVehicle."Registration No.", XMLRootDMS, RqType);

        end else begin
            // ❌ Code 99 : Véhicule introuvable
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Véhicule introuvable');
        end;

        // 4. AJOUT de LZRC23 au nœud parent <DMS>
        XMLRootDMS.Add(XMLRoot);
    end;


    procedure LZRF51T51V1LVV(var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement)
    var
        RecServiceHeader: Record "Service Header EDMS";
        RecSaleHeader: Record "Sales Header";
        RecSaleLine: Record "Sales Line";
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        XMLNodeLDT: XmlElement;
        XMLNodePR: XmlElement;
        CodeInterr: Text;
        DossierDmsId: Text;
        Hours: Integer;
        Minutes: Integer;
        Count: Integer;
        TypeXX: Text;
    begin
        TypeXX := 'SBOX';

        // 1. Création directe du nœud LZRF51 (plus besoin de SingleSelect ou GetRoot)
        XMLRoot := XmlElement.Create('LZRF51');

        CodeInterr := GetAttributeValue(XMLNodeReq, 'CODE_INTERROGATION_DMS');
        DossierDmsId := GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID');

        case CodeInterr of
            '1', '2':
                begin
                    RecServiceHeader.Reset();
                    RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                    RecServiceHeader.SetRange("No.", DossierDmsId);
                    if RecServiceHeader.FindSet() then begin
                        XMLRoot.SetAttribute('Code', '0');
                        XMLRoot.SetAttribute('TexteDMS', '');
                        repeat
                            // Assure-toi que cette fonction prend XMLRoot en XmlElement
                            FillBasicAttributes(XMLRoot, RecServiceHeader."No.", '1');
                        until RecServiceHeader.Next() = 0;
                    end;
                end;

            '3':
                begin
                    if DossierDmsId.StartsWith('F') then
                        // ✅ CORRECTION : Passer XMLRootDMS (ou XMLRoot selon ta fonction historique)
                        LZRF51T51FV1(XMLRootDMS, XMLNodeReq, DossierDmsId)
                    else if DossierDmsId.StartsWith('CV') then begin
                        // --- TRAITEMENT VENTE PR ---
                        RecSaleHeader.Reset();
                        RecSaleHeader.SetRange("Document Type", RecSaleHeader."Document Type"::Order);
                        RecSaleHeader.SetRange("No.", DossierDmsId);
                        if RecSaleHeader.FindFirst() then begin
                            XMLRoot.SetAttribute('Code', '0');
                            XMLRoot.SetAttribute('DOSSIER_DMS_ID', RecSaleHeader."No.");
                            XMLRoot.SetAttribute('TexteDMS', '');
                            XMLRoot.SetAttribute('ETATDOSSIERDMS', '1');
                            XMLRoot.SetAttribute('RDV_DMS_ID', RecSaleHeader."No.");
                            XMLRoot.SetAttribute('ANNEERDV', Format(Date2DMY(RecSaleHeader."Order Date", 3)));
                            XMLRoot.SetAttribute('MOISRDV', Format(Date2DMY(RecSaleHeader."Order Date", 2)));
                            XMLRoot.SetAttribute('JOURRDV', Format(Date2DMY(RecSaleHeader."Order Date", 1)));

                            // Assure-toi que ces helpers prennent XMLRoot en XmlElement
                            AddClientNode(XMLRoot, RecSaleHeader."Sell-to Customer No.");
                            AddVehicleNode(XMLRoot, RecSaleHeader."VIN SBOX");

                            RecSaleLine.SetRange("Document Type", RecSaleHeader."Document Type");
                            RecSaleLine.SetRange("Document No.", RecSaleHeader."No.");
                            if RecSaleLine.FindSet() then begin
                                XMLNodeLDT := XmlElement.Create('LDT');
                                XMLNodeLDT.SetAttribute(TypeXX + '_LDT', '1');
                                XMLNodeLDT.SetAttribute('CODEIMPUTATION_LDT', RecSaleHeader."Sell-to Customer No.");
                                XMLNodeLDT.SetAttribute('LIGNE_DT_ID', RecSaleLine."Line LDT");
                                repeat
                                    XMLNodePR := XmlElement.Create('PR');
                                    XMLNodePR.SetAttribute('LIGNE_DT_ID', RecSaleLine."Line LDT");
                                    XMLNodePR.SetAttribute('LIGNE_DT_ID_DMS', Format(RecSaleLine."Line No."));
                                    XMLNodePR.SetAttribute('REFERENCE_PR', RecSaleLine."No.");
                                    XMLNodePR.SetAttribute('LIBELLE_PR', RecSaleLine.Description);
                                    XMLNodePR.SetAttribute('QuantiteEnCommande', Format(RecSaleLine.Quantity, 0, 9));
                                    XMLNodePR.SetAttribute('PRIXHT', Format(RecSaleLine."Unit Price" * (1 - RecSaleLine."Line Discount %" / 100), 0, 9));
                                    XMLNodeLDT.Add(XMLNodePR);
                                until RecSaleLine.Next() = 0;
                                XMLRoot.Add(XMLNodeLDT);
                            end;
                        end else begin
                            XMLRoot.SetAttribute('Code', '99');
                            XMLRoot.SetAttribute('TexteDMS', 'Dossier non trouvé');
                        end;
                    end else begin
                        // --- TRAITEMENT SERVICE HEADER ---
                        RecServiceHeader.Reset();
                        RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                        RecServiceHeader.SetRange("No.", DossierDmsId);
                        if RecServiceHeader.FindFirst() then begin
                            Hours := (RecServiceHeader."Order Time" - 000000T) div 3600000;
                            Minutes := ((RecServiceHeader."Order Time" - 000000T) mod 3600000) div 60000;

                            XMLRoot.SetAttribute('Code', '0');
                            XMLRoot.SetAttribute('DOSSIER_DMS_ID', RecServiceHeader."No.");
                            XMLRoot.SetAttribute('ETATDOSSIERDMS', '1');
                            XMLRoot.SetAttribute('HEURESRDV', Format(Hours));
                            XMLRoot.SetAttribute('MINUTESRDV', Format(Minutes));
                            XMLRoot.SetAttribute('TPSIMMO', '');

                            AddClientNode(XMLRoot, RecServiceHeader."Sell-to Customer No.");
                            AddVehicleNode(XMLRoot, RecServiceHeader.VIN);
                        end else begin
                            XMLRoot.SetAttribute('Code', '99');
                            XMLRoot.SetAttribute('TexteDMS', 'Dossier non trouvé');
                            XMLRoot.SetAttribute('DOSSIER_DMS_ID', DossierDmsId);
                        end;
                    end;
                end;

            '4':
                begin
                    RecServiceHeader.Reset();
                    RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                    if RecServiceHeader.FindSet() then
                        repeat
                            Count += 1;
                            XMLNode := XmlElement.Create('LZRF51_ITEM'); // Utilise un nom différent pour éviter la confusion avec le parent si nécessaire
                            XMLNode.SetAttribute('Code', '0');
                            XMLNode.SetAttribute('DOSSIER_DMS_ID', RecServiceHeader."No.");
                            XMLNode.SetAttribute('ETATDOSSIERDMS', '1');
                            XMLRoot.Add(XMLNode);
                        until (RecServiceHeader.Next() = 0) or (Count = 30);
                end;
            else begin
                XMLRoot.SetAttribute('Code', '99');
                XMLRoot.SetAttribute('TexteDMS', 'Code interrogation inconnu');
            end;
        end;

        // 2. AJOUT de LZRF51 à la racine DMS
        XMLRootDMS.Add(XMLRoot);
    end;


    procedure LZRF53T53V1(var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement)
    var
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        RecServiceHeader: Record "Service Header EDMS";
        ClientDmsId: Text[30];
        VehiculeDmsId: Text[30];
    begin
        // Récupération des filtres depuis la requête
        ClientDmsId := GetAttributeValue(XMLNodeReq, 'CLIENT_DMS_ID');
        VehiculeDmsId := GetAttributeValue(XMLNodeReq, 'VEHICULE_DMS_ID');


        XMLRoot := XmlElement.Create('LZRF53');
        XMLRootDMS.Add(XMLRoot);


        // Préparation du filtre sur Service Header
        RecServiceHeader.Reset();
        RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);

        if ClientDmsId <> '' then
            RecServiceHeader.SetRange("Sell-to Customer No.", ClientDmsId);

        if VehiculeDmsId <> '' then
            RecServiceHeader.SetRange(VIN, VehiculeDmsId);

        // Extraction des données
        if RecServiceHeader.FindSet() then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', 'OR en cours');

            repeat
                XMLNode := XmlElement.Create('OR');
                XMLNode.SetAttribute('DOSSIER_DMS_ID', RecServiceHeader."No.");
                XMLNode.SetAttribute('JOUROUVERTURE', Format(Date2DMY(RecServiceHeader."Order Date", 1)));
                XMLNode.SetAttribute('MOISOUVERTURE', Format(Date2DMY(RecServiceHeader."Order Date", 2)));
                XMLNode.SetAttribute('ANNEEOUVERTURE', Format(Date2DMY(RecServiceHeader."Order Date", 3)));
                XMLNode.SetAttribute('Nom', RecServiceHeader."Sell-to Customer Name");
                XMLNode.SetAttribute('LibelleMarque', RecServiceHeader."Make Code");
                XMLNode.SetAttribute('LibelleModele', RecServiceHeader."Model Code");
                XMLNode.SetAttribute('VIN', RecServiceHeader.VIN);
                XMLNode.SetAttribute('Immatriculation', '');//To fix later

                XMLRoot.Add(XMLNode);
            until RecServiceHeader.Next() = 0;
        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Recherche inconnue');
        end;
    end;

    procedure LZRF53T53V1LVV(var XMLDom: XmlDocument; XMLNodeReq: XmlElement)
    var
        RecServiceHeader: Record "Service Header EDMS"; // Table 5025624 dans votre C/AL
        XMLDms: XmlElement;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        XMLRootNode: XmlNode;
        ClientDmsId: Text;
        VehiculeDmsId: Text;
    begin
        // Récupération de la racine DMS
        if not XMLDom.GetRoot(XMLDms) then exit;

        // Gestion du nœud LZRF53 (Correction AL0133 avec AsXmlElement)
        if XMLDms.SelectSingleNode('LZRF53', XMLRootNode) then
            XMLRoot := XMLRootNode.AsXmlElement()
        else begin
            XMLRoot := XmlElement.Create('LZRF53');
            XMLDms.Add(XMLRoot);
        end;

        // Récupération des filtres depuis la requête
        ClientDmsId := GetAttributeValue(XMLNodeReq, 'CLIENT_DMS_ID');
        VehiculeDmsId := GetAttributeValue(XMLNodeReq, 'VEHICULE_DMS_ID');

        // Préparation des filtres sur le Service Header
        RecServiceHeader.Reset();
        RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);

        if ClientDmsId <> '' then
            RecServiceHeader.SetRange("Sell-to Customer No.", ClientDmsId);

        if VehiculeDmsId <> '' then
            RecServiceHeader.SetRange(VIN, VehiculeDmsId);

        // Extraction des données
        if RecServiceHeader.FindSet() then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', 'OR en cours');

            repeat
                XMLNode := XmlElement.Create('OR');

                XMLNode.SetAttribute('DOSSIER_DMS_ID', RecServiceHeader."No.");

                // Gestion des dates d'ouverture
                if RecServiceHeader."Order Date" <> 0D then begin
                    XMLNode.SetAttribute('JOUROUVERTURE', Format(Date2DMY(RecServiceHeader."Order Date", 1)));
                    XMLNode.SetAttribute('MOISOUVERTURE', Format(Date2DMY(RecServiceHeader."Order Date", 2)));
                    XMLNode.SetAttribute('ANNEEOUVERTURE', Format(Date2DMY(RecServiceHeader."Order Date", 3)));
                end;

                XMLNode.SetAttribute('Nom', RecServiceHeader."Sell-to Customer Name");
                XMLNode.SetAttribute('LibelleMarque', RecServiceHeader."Make Code");
                XMLNode.SetAttribute('LibelleModele', RecServiceHeader."Model Code");
                XMLNode.SetAttribute('VIN', RecServiceHeader.VIN);
                XMLNode.SetAttribute('Immatriculation', '');//FIXv1 RecServiceHeader."Registration No.");

                XMLRoot.Add(XMLNode);
            until RecServiceHeader.Next() = 0;
        end else begin
            // Aucune donnée trouvée
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Recherche inconnue');
        end;
    end;

    local procedure AddClientNode(var ParentNode: XmlElement; CustomerNo: Code[20])
    var
        RecCustomer: Record Customer;
        XMLNode: XmlElement;
    begin
        if RecCustomer.Get(CustomerNo) then begin
            RecCustomer.CalcFields("Balance (LCY)");
            XMLNode := XmlElement.Create('CLIENT');
            XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");
            XMLNode.SetAttribute('Nom', RecCustomer."Name");
            XMLNode.SetAttribute('Prenom', RecCustomer."Name 2");
            XMLNode.SetAttribute('Email', RecCustomer."E-Mail");
            XMLNode.SetAttribute('RaisonSociale', RecCustomer.Name);
            XMLNode.SetAttribute('Ville', RecCustomer.City);
            XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");
            XMLNode.SetAttribute('SoldeClient', Format(RecCustomer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
            ParentNode.Add(XMLNode);
        end;
    end;

    local procedure AddVehicleNode(var ParentNode: XmlElement; VIN: Code[20])
    var
        RecVehicle: Record "Vehicle"; // Table 5025400
        XMLNode: XmlElement;
    begin
        RecVehicle.SetRange(VIN, VIN);
        if RecVehicle.FindFirst() then begin
            XMLNode := XmlElement.Create('VEHICULE');
            XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
            XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
            XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");
            XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");
            XMLNode.SetAttribute('DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));
            ParentNode.Add(XMLNode);
        end;
    end;

    local procedure FillBasicAttributes(var Node: XmlElement; DocNo: Code[20]; Status: Text)
    begin
        Node.SetAttribute('DOSSIER_DMS_ID', DocNo);
        Node.SetAttribute('ETATDOSSIERDMS', Status);
        Node.SetAttribute('RDV_DMS_ID', '');
        // ... (Ajouter les autres attributs vides requis ici)
    end;

    procedure LZRF51T51F(var XMLDom: XmlDocument; XMLNodeReq: XmlElement)
    var
        RecSalesInvoiceHeader: Record "Sales Invoice Header";
        RecSalesInvoiceLine: Record "Sales Invoice Line";
        //RecVehiculeLedgerEntry: Record "Vehicle Ledger Entry"; // Table 5025405
        RecVehicle: Record "Vehicle"; // Table 5025400
        RecCustomer: Record Customer;
        ArchServiceHeader: Record "Service Header Archive EDMS"; // Table 5025636 (Vérifier le nom exact)
        XMLDms: XmlElement;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        XMLNodeLDT: XmlElement;
        XMLNodeMO: XmlElement;
        XMLNodePR: XmlElement;
        XMLRootNode: XmlNode;
        XMLDmsNode: XmlNode;
        DossierDmsId: Text;
        TypeXX: Text;
    begin
        TypeXX := 'SBOX';

        if not XMLDom.GetRoot(XMLDms) then exit;

        // Gestion du nœud LZRF51 avec correction AL0133
        if XMLDms.SelectSingleNode('LZRF51', XMLRootNode) then
            XMLRoot := XMLRootNode.AsXmlElement()
        else begin
            XMLRoot := XmlElement.Create('LZRF51');
            XMLDms.Add(XMLRoot);
        end;

        DossierDmsId := GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID');

        RecSalesInvoiceHeader.Reset();
        RecSalesInvoiceHeader.SetRange("No.", DossierDmsId);

        if RecSalesInvoiceHeader.FindFirst() then begin
            // --- ENTETE FACTURE ---
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('DOSSIER_DMS_ID', RecSalesInvoiceHeader."No.");
            XMLRoot.SetAttribute('TexteDMS', '');
            XMLRoot.SetAttribute('ETATDOSSIERDMS', '2');
            XMLRoot.SetAttribute('RDV_DMS_ID', '');
            // Initialisation des attributs vides requis par le schéma
            XMLRoot.SetAttribute('ANNEERDV', '');
            XMLRoot.SetAttribute('MOISRDV', '');
            XMLRoot.SetAttribute('JOURRDV', '');
            XMLRoot.SetAttribute('HEURESRDV', '');
            XMLRoot.SetAttribute('MINUTESRDV', '');
            XMLRoot.SetAttribute('TPSIMMO', '');
            XMLRoot.SetAttribute('EQUIPE', '');
            XMLRoot.SetAttribute('RETOURATELIER', '');

            // --- CLIENT ---
            if RecCustomer.Get(RecSalesInvoiceHeader."Sell-to Customer No.") then begin
                XMLNode := XmlElement.Create('CLIENT');
                XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");
                XMLNode.SetAttribute('TypeClient', Format(RecCustomer."Partner Type"));
                XMLNode.SetAttribute('Nom', RecCustomer."Name");
                XMLNode.SetAttribute('Prenom', RecCustomer."Name 2");
                XMLNode.SetAttribute('PhoneMobile', RecCustomer."Mobile Phone No.");
                XMLNode.SetAttribute('Email', RecCustomer."E-Mail");
                XMLNode.SetAttribute('RaisonSociale', RecCustomer.Name);
                XMLNode.SetAttribute('Adresse1', RecCustomer.Address);
                XMLNode.SetAttribute('Ville', RecCustomer.City);
                XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");

                if RecCustomer.County <> '' then
                    XMLNode.SetAttribute('Pays', RecCustomer.County)
                else
                    XMLNode.SetAttribute('Pays', 'TN');

                RecCustomer.CalcFields("Balance (LCY)");
                XMLNode.SetAttribute('SoldeClient', Format(RecCustomer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
                XMLNode.SetAttribute('PhoneBureau', RecCustomer."Phone No.");
                XMLRoot.Add(XMLNode);
            end;

            // --- VEHICULE ET KILOMETRAGE ---
            RecSalesInvoiceHeader.Reset();
            RecSalesInvoiceHeader.SetRange("No.", RecSalesInvoiceHeader."No.");
            if RecSalesInvoiceHeader.FindFirst() then begin
                if RecVehicle.Get(RecSalesInvoiceHeader.VIN) then begin
                    XMLNode := XmlElement.Create('VEHICULE');
                    XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
                    XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
                    XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");
                    XMLNode.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                    XMLNode.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                    XMLNode.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                    XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");

                    // Recherche du kilométrage dans l'archive Service ou sur la fiche véhicule
                    ArchServiceHeader.Reset();
                    ArchServiceHeader.SetRange("No.", RecSalesInvoiceHeader."Service Order No.");
                    if ArchServiceHeader.FindFirst() then
                        XMLNode.SetAttribute('DernierKilometrage', Format(ArchServiceHeader."Variable Field Run 1", 0, '<Standard Format,2>'))
                    else
                        XMLNode.SetAttribute('DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));

                    XMLRoot.Add(XMLNode);

                    // --- LIGNES DE TRAVAIL (LDT) ---
                    XMLNodeLDT := XmlElement.Create('LDT');
                    XMLNodeLDT.SetAttribute(TypeXX + '_LDT', '');
                    XMLNodeLDT.SetAttribute('LIBELLE_LIGNE_TRAVAIL', 'Détail Facture');

                    RecSalesInvoiceLine.Reset();
                    RecSalesInvoiceLine.SetRange("Document No.", RecSalesInvoiceHeader."No.");
                    if RecSalesInvoiceLine.FindSet() then begin
                        repeat
                            // Gestion Main d'œuvre (Compte G/L dans votre logique)
                            if RecSalesInvoiceLine.Type = RecSalesInvoiceLine.Type::"G/L Account" then begin
                                XMLNodeMO := XmlElement.Create('MO');
                                XMLNodeMO.SetAttribute('LIGNE_DT_ID_DMS', Format(RecSalesInvoiceLine."Line No."));
                                XMLNodeMO.SetAttribute(TypeXX + '_MO', '');
                                XMLNodeMO.SetAttribute('CODEIMPUTATION_MO', RecSalesInvoiceHeader."Bill-to Customer No.");
                                XMLNodeMO.SetAttribute('CODEOPERATION', '');//FIXV1 RecSalesInvoiceLine."Labor No.");
                                XMLNodeMO.SetAttribute('LIBELLEOPERATION', RecSalesInvoiceLine.Description);
                                XMLNodeMO.SetAttribute('TEMPSGLOBAL', Format(RecSalesInvoiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                XMLNodeMO.SetAttribute('PRIXHT_MO', Format(RecSalesInvoiceLine.Amount, 0, '<Precision,2:2><Standard Format,2>'));
                                XMLNodeMO.SetAttribute('PRIXTTC_MO', Format(RecSalesInvoiceLine."Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>'));
                                XMLNodeLDT.Add(XMLNodeMO);
                            end;

                            // Gestion Pièces (Item)
                            if RecSalesInvoiceLine.Type = RecSalesInvoiceLine.Type::Item then begin
                                XMLNodePR := XmlElement.Create('PR');
                                XMLNodePR.SetAttribute('LIGNE_DT_ID_DMS', Format(RecSalesInvoiceLine."Line No."));
                                XMLNodePR.SetAttribute(TypeXX + '_PR', '');
                                XMLNodePR.SetAttribute('REFERENCE_PR', RecSalesInvoiceLine."No.");
                                XMLNodePR.SetAttribute('LIBELLE_PR', RecSalesInvoiceLine.Description);
                                XMLNodePR.SetAttribute('TYPE_PR', '2');
                                XMLNodePR.SetAttribute('QuantiteEnCommande', Format(RecSalesInvoiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                XMLNodePR.SetAttribute('PRIXHT', Format(RecSalesInvoiceLine."Unit Price" * (1 - RecSalesInvoiceLine."Line Discount %" / 100), 0, '<Precision,2:2><Standard Format,2>'));
                                XMLNodePR.SetAttribute('PRIXTTC', Format((RecSalesInvoiceLine."Unit Price" * (1 - RecSalesInvoiceLine."Line Discount %" / 100)) * (1 + RecSalesInvoiceLine."VAT %" / 100), 0, '<Precision,2:2><Standard Format,2>'));
                                XMLNodeLDT.Add(XMLNodePR);
                            end;
                        until RecSalesInvoiceLine.Next() = 0;
                    end;
                    XMLRoot.Add(XMLNodeLDT);
                end;
            end;
        end;
    end;


    procedure LZRF52T52V1(var XMLDom: XmlElement; XMLNodeReq: XmlElement)
    var
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        RecCustomerLedgerEntry: Record "Cust. Ledger Entry";
        RecSalesInvoiceHeader: Record "Sales Invoice Header";
        ClientDmsId: Text;
        VehiculeDmsId: Text;
        FoundAny: Boolean;
    begin
        // Récupération du nœud racine <DMS>
        XMLRoot := XmlElement.Create('LZRF52');
        XMLDom.Add(XMLRoot);

        ClientDmsId := GetAttributeValue(XMLNodeReq, 'CLIENT_DMS_ID');
        VehiculeDmsId := GetAttributeValue(XMLNodeReq, 'VEHICULE_DMS_ID');

        if (ClientDmsId = '') or (VehiculeDmsId = '') then begin
            XMLRoot.SetAttribute('Code', '95');
            XMLRoot.SetAttribute('TexteDMS', 'Recherche facturation inconnue !');
            exit;
        end;

        RecSalesInvoiceHeader.Reset();
        RecSalesInvoiceHeader.SetRange("Sell-to Customer No.", ClientDmsId);
        RecSalesInvoiceHeader.SetRange("Document Profile", RecSalesInvoiceHeader."Document Profile"::Service);

        if RecSalesInvoiceHeader.FindSet() then begin
            FoundAny := false;
            repeat
                RecCustomerLedgerEntry.Reset();
                RecCustomerLedgerEntry.SetRange("Document No.", RecSalesInvoiceHeader."No.");

                if RecCustomerLedgerEntry.FindSet() then begin
                    if not FoundAny then begin
                        XMLRoot.SetAttribute('Code', '0');
                        XMLRoot.SetAttribute('TexteDMS', '');
                        FoundAny := true;
                    end;

                    repeat
                        XMLNode := XmlElement.Create('FAC');

                        XMLNode.SetAttribute('CLIENT_DMS_ID', RecSalesInvoiceHeader."Sell-to Customer No.");
                        XMLNode.SetAttribute('DOSSIER_DMS_ID', RecCustomerLedgerEntry."Document No.");
                        XMLNode.SetAttribute('LibelleFacture', RecSalesInvoiceHeader."Service Order No.");
                        XMLNode.SetAttribute('JourFacture', Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 1)));
                        XMLNode.SetAttribute('MoisFacture', Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 2)));
                        XMLNode.SetAttribute('AnneeFacture', Format(Date2DMY(RecCustomerLedgerEntry."Posting Date", 3)));
                        XMLNode.SetAttribute('Nom', RecSalesInvoiceHeader."Sell-to Customer Name");

                        if RecCustomerLedgerEntry."Customer No." = RecSalesInvoiceHeader."Sell-to Customer No." then
                            XMLNode.SetAttribute('MontantClient', Format(RecCustomerLedgerEntry."Amount (LCY)", 0, '<Precision,2:2><Standard Format,2>'));

                        XMLNode.SetAttribute('MontantGarantie', '0.00');
                        XMLNode.SetAttribute('MontantAssurance', '0.00');
                        XMLNode.SetAttribute('LibelleMarque', RecSalesInvoiceHeader."Make Code");
                        XMLNode.SetAttribute('LibelleModele', '');
                        XMLNode.SetAttribute('VIN', RecSalesInvoiceHeader.VIN);
                        XMLNode.SetAttribute('KilometrageFacture', '');
                        XMLNode.SetAttribute('CommentairesFacture', 'Client Facturé : ' + RecSalesInvoiceHeader."Bill-to Customer No.");

                        XMLRoot.Add(XMLNode);
                    until RecCustomerLedgerEntry.Next() = 0;
                end;
            until RecSalesInvoiceHeader.Next() = 0;

            if not FoundAny then begin
                XMLRoot.SetAttribute('Code', '99');
                XMLRoot.SetAttribute('TexteDMS', 'aucune Commande trouvée');
            end;
        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'aucune Commande trouvée');
        end;
    end;

    procedure LZRC23T09V1(VehiculeDmsId: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle"; // Table 5025400
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        DateToUse: Date;
    begin
        // ⚡ Créer le bloc racine LZRC23 (TempRoot interne)
        XMLRoot := XmlElement.Create('LZRC23');

        // Recherche du véhicule par VIN
        RecVehicle.Reset();
        RecVehicle.SetRange(VIN, VehiculeDmsId);

        if RecVehicle.FindFirst() then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');

            XMLNode := XmlElement.Create('VEHICULE');
            XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
            XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
            XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");

            // Découpage du VIN
            XMLNode.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
            XMLNode.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
            XMLNode.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));

            XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");

            // Date mise en circulation
            if RecVehicle."First Registration Date" <> 0D then
                DateToUse := RecVehicle."First Registration Date"
            else
                DateToUse := RecVehicle."Creation Date";

            if DateToUse <> 0D then begin
                XMLNode.SetAttribute('AnneeMiseCirculation', Format(Date2DMY(DateToUse, 3)));
                XMLNode.SetAttribute('MoisMiseCirculation', Format(Date2DMY(DateToUse, 2)));
                XMLNode.SetAttribute('JourMiseCirculation', Format(Date2DMY(DateToUse, 1)));
            end;

            XMLNode.SetAttribute('DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, 9));
            XMLNode.SetAttribute('CodeOPB', '');
            XMLNode.SetAttribute('TypeEntretien', '');

            XMLRoot.Add(XMLNode);

            // Appel complémentaire LZRC02T02V1 (T02)
            if RqType in ['05', '06', '09'] then
                LZRC02T02V1(RecVehicle.VIN, RecVehicle.VIN, RecVehicle."Registration No.", XMLRoot, RqType);

        end else begin
            // Véhicule non trouvé
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Véhicule introuvable');
        end;

        // ⚡ Ajout FINAL au parent XMLRootDMS (TempRoot)
        XMLRootDMS.Add(XMLRoot);
    end;

    local procedure CreateEmptyPRNode(var XMLRoot: XmlElement; ItemRef: Code[20]; CodePR: Text)
    var
        XMLNode: XmlElement;
    begin
        XMLNode := XmlElement.Create('PR');
        XMLNode.SetAttribute('ReferencePR', ItemRef);
        XMLNode.SetAttribute('CODE_PR', CodePR);
        XMLNode.SetAttribute('idStockDMS', 'MAG_LB');
        XMLNode.SetAttribute('QuantiteDisponible', '0.00');
        XMLNode.SetAttribute('ReferencePRInitial', '');
        XMLRoot.Add(XMLNode);
    end;


    local procedure GetOrCreateElement(var ParentNode: XmlElement; ElementName: Text; var FoundElement: XmlElement): Boolean
    var
        XNode: XmlNode;
    begin
        // On cherche si le nœud existe déjà
        if ParentNode.SelectSingleNode(ElementName, XNode) then begin
            FoundElement := XNode.AsXmlElement();
            exit(false); // Retourne false car il n'a pas été "créé" à l'instant
        end else begin
            // Sinon on le crée et on l'ajoute au parent
            FoundElement := XmlElement.Create(ElementName);
            ParentNode.Add(FoundElement);
            exit(true); // Retourne true car on vient de le créer
        end;
    end;

    /*
    procedure LZRF47T24(var XMLDom: XmlDocument; XMLNodeReq: XmlElement; XMLNodeReqType11: XmlElement; XMLNodeReqType22: XmlElement)
    var
        XMLDms, XMLRoot, XMLNode, XMLNodePR, XMLNodeMO: XmlElement;
        XMLNodesLDT, XMLNodesPR11, XMLNodesLDT22, XMLNodesMO22: XmlNodeList;
        XNodeLDT, XNodePR11, XNodeLDT22, XNodeMO22: XmlNode;
        RecPackage: Record "Service Package"; // Table 5025610
        RecPackageVersion: Record "Service Package Version"; // Table 5025615
        //RecPackageBOM: Record ; // Table 5025611
        lRecServiceHeader: Record "Service Header"; // Table 5025624
        lRecServiceLine: Record "Service Line EDMS"; // Table 5025625
        lRecServiceJobLine: Record "Service Package Version"; // Table 5025627 (Custom)
        lRecServicePackPrice: Record "Service Package Version Line"; // Table 5025635 (Custom)
        DMS_ID_Value: Code[20];
        IDFORFAIT_Value: Code[20];
        LIGNE_DT_ID: Text;
        ErrorInFF: Boolean;
        i, j, k, l: Integer;
        TypeXX: Text;
    begin
        if not XMLDom.GetRoot(XMLDms) then exit;
        GetOrCreateElement(XMLDms, 'LZRF47', XMLRoot);

        TypeXX := 'PRIXHT'; // À adapter
        DMS_ID_Value := GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID');

        // --- MODE 1 : LECTURE DEPUIS UN DOSSIER EXISTANT ---
        if (DMS_ID_Value <> '') and lRecServiceHeader.Get(lRecServiceHeader."Document Type"::Order, DMS_ID_Value) then begin
            lRecServiceJobLine.SetRange("Document Type", lRecServiceHeader."Document Type");
            lRecServiceJobLine.SetRange("Document No.", DMS_ID_Value);
            lRecServiceJobLine.SetFilter("Package No.", '<>%1', '');

            if lRecServiceJobLine.FindSet() then begin
                repeat
                    XMLNode := XmlElement.Create('FF');
                    XMLRoot.Add(XMLNode);
                    XMLNode.SetAttribute('CODE_FF', '2');
                    XMLNode.SetAttribute('LIGNE_DT_ID', lRecServiceJobLine."Complaint 2"); // Mapping original
                    XMLNode.SetAttribute('LIGNE_DT_ID_DMS', Format(lRecServiceJobLine."Line No."));
                    XMLNode.SetAttribute('IDFORFAIT', lRecServiceJobLine."Package No." + lRecServiceJobLine."SBOX CodeTypeVehicule");

                    // Recherche du prix du forfait dans le dossier
                    if lRecServicePackPrice.Get(lRecServiceHeader."Document Type"::Order, DMS_ID_Value, 
                        lRecServiceJobLine."Package No.", lRecServiceJobLine."Package Version No.") then begin
                        XMLNode.SetAttribute('PrixUnitaireHT', Format(lRecServicePackPrice."Unit Price", 0, '<Precision,2:2><Standard Format,2>'));
                        XMLNode.SetAttribute('PrixUnitaireTTC', Format(lRecServicePackPrice."Unit Price Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
                    end;

                    // Détails du forfait (PR et MO)
                    lRecServiceLine.SetRange("Document Type", lRecServiceLine."Document Type"::Order);
                    lRecServiceLine.SetRange("Document No.", DMS_ID_Value);
                    lRecServiceLine.SetRange("Package No.", lRecServiceJobLine."Package No.");
                    if lRecServiceLine.FindSet() then
                        repeat
                            case lRecServiceLine.Type of
                                lRecServiceLine.Type::Item: begin
                                    XMLNodePR := XmlElement.Create('PR');
                                    XMLNode.Add(XMLNodePR);
                                    XMLNodePR.SetAttribute('REFERENCE_PR', lRecServiceLine."No.");
                                    XMLNodePR.SetAttribute('LIBELLE_PR', lRecServiceLine.Description);
                                    XMLNodePR.SetAttribute('TYPE_PR', '2');
                                end;
                                lRecServiceLine.Type::: begin
                                    XMLNodeMO := XmlElement.Create('MO');
                                    XMLNode.Add(XMLNodeMO);
                                    XMLNodeMO.SetAttribute('CODEOPERATION', lRecServiceLine."No.");
                                    XMLNodeMO.SetAttribute('TEMPSGLOBAL', Format(lRecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                    XMLNodeMO.SetAttribute('LIBELLEOPERATION', lRecServiceLine.Description);
                                end;
                            end;
                        until lRecServiceLine.Next() = 0;
                until lRecServiceJobLine.Next() = 0;
            end;
        end else begin
            // --- MODE 2 : CONSULTATION DU CATALOGUE THÉORIQUE ---
            if not XMLNodeReq.SelectNodes('LDT', XMLNodesLDT) then exit;

            for i := 0 to XMLNodesLDT.Count() - 1 do begin
                XMLNodesLDT.Get(i, XNodeLDT);
                IDFORFAIT_Value := GetAttributeValue(XNodeLDT.AsXmlElement().SelectSingleNode('FF').AsXmlElement(), 'IDFORFAIT');
                LIGNE_DT_ID := GetAttributeValue(XNodeLDT.AsXmlElement().SelectSingleNode('FF').AsXmlElement(), 'LIGNE_DT_ID');

                RecPackage.Reset();
                if RecPackage.Get(IDFORFAIT_Value) then begin
                    RecPackageVersion.SetRange("Package No.", IDFORFAIT_Value);
                    if RecPackageVersion.FindLast() then begin
                        XMLNode := XmlElement.Create('FF');
                        XMLRoot.Add(XMLNode);
                        XMLNode.SetAttribute('CODE_FF', '2');
                        XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);
                        XMLNode.SetAttribute('PrixUnitaireHT', Format(RecPackageVersion."Unit Price", 0, '<Precision,2:2><Standard Format,2>'));

                        // Lecture de la BOM du forfait
                        RecPackageBOM.SetRange("Package No.", RecPackageVersion."Package No.");
                        RecPackageBOM.SetRange("Package Version No.", RecPackageVersion."Package Version");
                        if RecPackageBOM.FindSet() then
                            repeat
                                if RecPackageBOM.Type = RecPackageBOM.Type::Item then begin
                                    XMLNodePR := XmlElement.Create('PR');
                                    XMLNode.Add(XMLNodePR);
                                    XMLNodePR.SetAttribute('REFERENCE_PR', RecPackageBOM."No.");
                                    XMLNodePR.SetAttribute('QuantiteEnCommande', Format(RecPackageBOM.Quantity));
                                end else begin
                                    XMLNodeMO := XmlElement.Create('MO');
                                    XMLNode.Add(XMLNodeMO);
                                    XMLNodeMO.SetAttribute('CODEOPERATION', RecPackageBOM."No.");
                                    XMLNodeMO.SetAttribute('TEMPSGLOBAL', '1');
                                end;
                            until RecPackageBOM.Next() = 0;
                    end;
                end else
                    ErrorInFF := true;
            end;
        end;

        // Finalisation du statut global
        if ErrorInFF then begin
            XMLRoot.SetAttribute('Code', '52');
            XMLRoot.SetAttribute('TexteDMS', 'forfait inexistant');
        end else begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');
        end;
    end;
    */

    procedure SetNumeroPostePARAMDMS(VNumeroPoste: Text[30]; VPARAMDMS: Text[50])
    var
        lSBOXSetting: Record "STF Servicebox Setup"; // Remplacer par le nom réel de votre table 60209
    begin
        // Affectation des variables globales (Assurez-vous qu'elles sont déclarées en haut du Codeunit)
        PARAMDMS := VPARAMDMS;
        NumeroPoste := VNumeroPoste;

        if lSBOXSetting.Get() then begin
            // Vérification de la version d'interface
            if lSBOXSetting.interfaceVersion = '13' then //lSBOXSetting.InterfaceVersion::"13" then
                TypeXX := 'TYPEFACTURATION'
            else
                TypeXX := 'TYPEIMPUTATION';
        end;
    end;



    /// <summary>
    /// Migration C/AL -> AL : Procédure LZRF51T51
    /// Récupération d'un dossier DMS
    /// </summary>
    procedure LZRF51T51V1(TempRoot: XmlElement; XMLNodeReq: XmlElement)
    var
        XMLDms: XmlElement;
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        XMLNodeLDT: XmlElement;
        XMLNodeMO: XmlElement;
        XMLNodePR: XmlElement;
        CODE_INTERR_DMS_Attribute: XmlAttribute;
        DOSSIER_DMS_ID_Attribute: XmlAttribute;
        RDV_DMS_ID_Attribute: XmlAttribute;
        TYPEFORFAIT: Text[30];
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        RecServiceHeader: Record "Service Header EDMS";
        RecServiceLine: Record "Service Line EDMS";
        RecVehicle: Record Vehicle;
        RecCustomer: Record Customer;
        RecSaleHeader: Record "Sales Header";
        RecSaleLine: Record "Sales Line";
        RecSaleLine2: Record "Sales Line";
        Milliseconds: Integer;
        Hours: Integer;
        Minutes: Integer;
        Seconds: Integer;
        Count: Integer;
        TempAttr: XmlAttribute;
        AttrList: XmlAttributeCollection;
    begin
        // Création du nœud racine LZRF51 et ajout à TempRoot
        XMLRoot := XmlElement.Create('LZRF51');
        TempRoot.Add(XMLRoot);

        // Lecture des attributs de la requête
        AttrList := XMLNodeReq.Attributes();
        AttrList.Get('CODE_INTERROGATION_DMS', CODE_INTERR_DMS_Attribute);
        AttrList.Get('DOSSIER_DMS_ID', DOSSIER_DMS_ID_Attribute);
        AttrList.Get('RDV_DMS_ID', RDV_DMS_ID_Attribute);


        if Format(CODE_INTERR_DMS_Attribute.Value()) = '1' then begin
            // Seule la récupération du dossier
            RecServiceHeader.Reset();
            RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
            RecServiceHeader.SetRange("No.", Format(DOSSIER_DMS_ID_Attribute.Value()));

            if RecServiceHeader.FindSet() then begin
                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'TexteDMS', '');
                repeat
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                    AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1');
                    AddAttribute(XMLRoot, 'RDV_DMS_ID', '');
                    AddAttribute(XMLRoot, 'ANNEERDV', '');
                    AddAttribute(XMLRoot, 'MOISRDV', '');
                    AddAttribute(XMLRoot, 'JOURRDV', '');
                    AddAttribute(XMLRoot, 'HEURESRDV', '');
                    AddAttribute(XMLRoot, 'MINUTESRDV', '');
                    AddAttribute(XMLRoot, 'TPSIMMO', '');
                    AddAttribute(XMLRoot, 'EQUIPE', '');
                    AddAttribute(XMLRoot, 'ANNEERDV_RESTIT', '');
                    AddAttribute(XMLRoot, 'MOISRDV_RESTIT', '');
                    AddAttribute(XMLRoot, 'JOURRDV_RESTIT', '');
                    AddAttribute(XMLRoot, 'HEURESRDV_RESTIT', '');
                    AddAttribute(XMLRoot, 'MINUTESRDV_RESTIT', '');
                    AddAttribute(XMLRoot, 'RETOURATELIER', '');
                until RecServiceHeader.Next() = 0;
            end else begin
                AddAttribute(XMLRoot, 'Code', '99');
                AddAttribute(XMLRoot, 'TexteDMS', 'Dossier non trouvé');
            end;
        end else if Format(CODE_INTERR_DMS_Attribute.Value()) = '2' then begin
            // Récupération dossier + client + véhicule + lignes
            RecServiceHeader.Reset();
            RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
            RecServiceHeader.SetRange("No.", Format(DOSSIER_DMS_ID_Attribute.Value()));

            if RecServiceHeader.FindSet() then begin
                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'TexteDMS', '');
                repeat
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                    AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1');

                    // --- CLIENT ---
                    RecCustomer.Reset();
                    RecCustomer.SetRange("No.", RecServiceHeader."Sell-to Customer No.");
                    if RecCustomer.FindSet() then
                        repeat
                            AddElement(XMLRoot, 'CLIENT', XMLNode);
                            AddAttribute(XMLNode, 'CLIENT_DMS_ID', RecCustomer."No.");
                            AddAttribute(XMLNode, 'TypeClient', Format(RecCustomer."Partner Type"));
                            AddAttribute(XMLNode, 'Nom', RecCustomer."Name");
                            AddAttribute(XMLNode, 'Prenom', RecCustomer."Name 2");
                            AddAttribute(XMLNode, 'TypeEntreprise', RecCustomer."DLT function code");
                            AddAttribute(XMLNode, 'RaisonSociale', RecCustomer.Name);
                            AddAttribute(XMLNode, 'NumeroVoie', '');
                            AddAttribute(XMLNode, 'TypeVoie', '');
                            AddAttribute(XMLNode, 'Adresse1', RecCustomer.Address);
                            AddAttribute(XMLNode, 'Ville', RecCustomer.City);
                            AddAttribute(XMLNode, 'CodePostal', RecCustomer."Post Code");
                            AddAttribute(XMLNode, 'NumeroCompte', RecCustomer."No.");
                        until RecCustomer.Next() = 0;

                    // --- VEHICULE ---
                    RecVehicle.Reset();
                    RecVehicle.SetRange(VIN, RecServiceHeader.VIN);
                    if RecVehicle.FindSet() then
                        repeat
                            AddElement(XMLRoot, 'VEHICULE', XMLNode);
                            AddAttribute(XMLNode, 'VEHICULE_DMS_ID', RecVehicle.VIN);
                            AddAttribute(XMLNode, 'VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                            AddAttribute(XMLNode, 'VIN_VDS', CopyStr(RecVehicle.VIN, 4, 2));
                            AddAttribute(XMLNode, 'VIN_VIS', CopyStr(RecVehicle.VIN, 6, 3));
                            AddAttribute(XMLNode, 'Immatriculation', RecVehicle."Registration No.");
                            AddAttribute(XMLNode, 'LibelleMarque', RecVehicle."Make Code");
                            AddAttribute(XMLNode, 'LibelleModele', RecVehicle."Model Code");
                        until RecVehicle.Next() = 0;

                    // --- LDT / PR ---
                    TYPEFORFAIT := 'Labor';
                    RecServiceLine.Reset();
                    RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
                    RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
                    RecServiceLine.SetFilter(Type, TYPEFORFAIT);
                    if RecServiceLine.FindSet() then
                        repeat
                            AddElement(XMLRoot, 'LDT', XMLNodeLDT);
                            AddAttribute(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL', Format(RecServiceLine.Description));
                            AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID_DMS', '');
                            AddAttribute(XMLNodeLDT, 'PrixUnitaireHT', Format(RecServiceLine."Unit Price"));
                            AddAttribute(XMLNodeLDT, 'PrixUnitaireTTC', Format(RecServiceLine."Amount Including VAT"));
                            AddAttribute(XMLNodeLDT, 'REMISE', Format(RecServiceLine."Line Discount %"));
                            AddAttribute(XMLNodeLDT, 'ReferenceFF', Format(RecServiceLine."No."));
                        until RecServiceLine.Next() = 0;

                until RecServiceHeader.Next() = 0;
            end else begin
                AddAttribute(XMLRoot, 'Code', '99');
                AddAttribute(XMLRoot, 'TexteDMS', 'Dossier non trouvé');
            end;

        end else if Format(CODE_INTERR_DMS_Attribute.Value()) = '3' then begin
            if StrPos(Format(DOSSIER_DMS_ID_Attribute.Value()), 'F') = 1 then
                LZRF51T51FV1(XMLRoot, XMLNodeReq, Format(DOSSIER_DMS_ID_Attribute.Value()));
            // Commande de vente (CVP)
            RecSaleHeader.Reset();
            RecSaleHeader.SetRange("Document Type", RecSaleHeader."Document Type"::Order);
            RecSaleHeader.SetRange("No.", Format(DOSSIER_DMS_ID_Attribute.Value()));
            if RecSaleHeader.FindFirst() then begin
                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecSaleHeader."No.");
                AddAttribute(XMLRoot, 'TexteDMS', '');

                /*  if RecSaleHeader.Status < RecSaleHeader.Status::"Partly Invoiced" then
                     AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1')
                 else */
                AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '2');

                AddAttribute(XMLRoot, 'RDV_DMS_ID', RecSaleHeader."No.");
                AddAttribute(XMLRoot, 'ANNEERDV', Format(Date2DMY(RecSaleHeader."Order Date", 3)));
                AddAttribute(XMLRoot, 'MOISRDV', Format(Date2DMY(RecSaleHeader."Order Date", 2)));
                AddAttribute(XMLRoot, 'JOURRDV', Format(Date2DMY(RecSaleHeader."Order Date", 1)));
                AddAttribute(XMLRoot, 'HEURESRDV', '');
                AddAttribute(XMLRoot, 'MINUTESRDV', '');
                AddAttribute(XMLRoot, 'EQUIPE', '');
                AddAttribute(XMLRoot, 'RETOURATELIER', '');

                // Client
                RecCustomer.Reset();
                RecCustomer.SetRange("No.", RecSaleHeader."Sell-to Customer No.");
                if RecCustomer.FindFirst() then begin
                    AddElement(XMLRoot, 'CLIENT', XMLNode);
                    AddAttribute(XMLNode, 'CLIENT_DMS_ID', RecCustomer."No.");
                    AddAttribute(XMLNode, 'TypeClient', Format(RecCustomer."Partner Type"));
                    AddAttribute(XMLNode, 'Nom', RecCustomer."Name");
                    AddAttribute(XMLNode, 'Prenom', RecCustomer."Name 2");
                    AddAttribute(XMLNode, 'PhoneMobile', RecCustomer."Mobile Phone No.");
                    AddAttribute(XMLNode, 'Email', RecCustomer."E-Mail");
                    AddAttribute(XMLNode, 'TypeEntreprise', RecCustomer."DLT function code");
                    AddAttribute(XMLNode, 'RaisonSociale', RecCustomer.Name);
                    AddAttribute(XMLNode, 'NumeroVoie', '');
                    AddAttribute(XMLNode, 'TypeVoie', '');
                    AddAttribute(XMLNode, 'Adresse1', RecCustomer.Address);
                    AddAttribute(XMLNode, 'Adresse2', RecCustomer."Address 2");
                    AddAttribute(XMLNode, 'Ville', RecCustomer.City);
                    AddAttribute(XMLNode, 'CodePostal', RecCustomer."Post Code");
                    if RecCustomer.County <> '' then
                        AddAttribute(XMLNode, 'Pays', RecCustomer.County)
                    else
                        AddAttribute(XMLNode, 'Pays', '');
                    AddAttribute(XMLNode, 'NumeroCompte', RecCustomer."No.");
                    AddAttribute(XMLNode, 'SoldeClient', Format(RecCustomer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
                    AddAttribute(XMLNode, 'PhoneDomicile', '');
                    AddAttribute(XMLNode, 'PhoneBureau', RecCustomer."Phone No.");
                    AddAttribute(XMLNode, 'NumeroPoste', '');
                    AddAttribute(XMLNode, 'Fax', RecCustomer."Fax No.");
                    AddAttribute(XMLNode, 'TEXTE_LIBRE', '');
                    AddAttribute(XMLNode, 'Observations', '');
                end;

                // Véhicule
                RecVehicle.Reset();
                RecVehicle.SetRange(VIN, RecSaleHeader."VIN SBOX");
                if RecVehicle.FindFirst() then begin
                    AddElement(XMLRoot, 'VEHICULE', XMLNode);
                    AddAttribute(XMLNode, 'VEHICULE_DMS_ID', RecVehicle.VIN);
                    AddAttribute(XMLNode, 'LibelleMarque', RecVehicle."Make Code");
                    AddAttribute(XMLNode, 'LibelleModele', RecVehicle."Model Code");
                    AddAttribute(XMLNode, 'VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                    AddAttribute(XMLNode, 'VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                    AddAttribute(XMLNode, 'VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                    AddAttribute(XMLNode, 'Immatriculation', RecVehicle."Registration No.");
                    if RecVehicle."First Registration Date" <> 0D then begin
                        AddAttribute(XMLNode, 'AnneeMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 3)));
                        AddAttribute(XMLNode, 'MoisMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 2)));
                        AddAttribute(XMLNode, 'JourMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 1)));
                    end;
                    AddAttribute(XMLNode, 'DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));
                    AddAttribute(XMLNode, 'CodeOPB', '');
                    AddAttribute(XMLNode, 'TypeEntretien', '');
                end;

                // Lignes de vente (PR)
                RecSaleLine.SetRange("Document Type", RecSaleLine."Document Type"::Order);
                RecSaleLine.SetRange("Document No.", RecSaleHeader."No.");
                if RecSaleLine.FindSet() then begin
                    AddElement(XMLNode, 'LDT', XMLNodeLDT);
                    AddAttribute(XMLNodeLDT, TypeXX + '_LDT', '1');
                    AddAttribute(XMLNodeLDT, 'CODEIMPUTATION_LDT', RecSaleHeader."Sell-to Customer No.");
                    AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID', RecSaleLine."Line LDT");
                    repeat
                        AddElement(XMLNodeLDT, 'PR', XMLNodePR);
                        AddAttribute(XMLNodePR, 'LIGNE_DT_ID', RecSaleLine."Line LDT");
                        AddAttribute(XMLNodePR, 'LIGNE_DT_ID_DMS', Format(RecSaleLine."Line No."));
                        AddAttribute(XMLNodePR, TypeXX + '_PR', '');
                        AddAttribute(XMLNodePR, 'CODEIMPUTATION_PR', RecSaleHeader."Bill-to Customer No.");
                        AddAttribute(XMLNodePR, 'REFERENCE_PR', SetItemNo(RecSaleLine."No."));
                        AddAttribute(XMLNodePR, 'LIBELLE_PR', RecSaleLine.Description);
                        AddAttribute(XMLNodePR, 'TYPE_PR', '2');
                        AddAttribute(XMLNodePR, 'QuantiteEnCommande',
                            Format(RecSaleLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                        AddAttribute(XMLNodePR, 'QuantiteServie',
                            Format(RecSaleLine."Quantity Shipped", 0, '<Precision,2:2><Standard Format,2>'));
                        AddAttribute(XMLNodePR, 'PRIXHT',
                            Format(RecSaleLine."Unit Price" * (1 - RecSaleLine2."Line Discount %" / 100),
                                0, '<Precision,2:2><Standard Format,2>'));
                        AddAttribute(XMLNodePR, 'PRIXTTC',
                            Format(RecSaleLine."Unit Price" * (1 - RecSaleLine2."Line Discount %" / 100)
                                * (1 + RecSaleLine."VAT %" / 100), 0, '<Precision,2:2><Standard Format,2>'));
                    until RecSaleLine.Next() = 0;
                end;
            end else begin
                AddAttribute(XMLRoot, 'Code', '99');
                AddAttribute(XMLRoot, 'TexteDMS', 'Dossier non trouvé');
            end;
        end else begin
            // APV - Ordre de réparation
            RecServiceHeader.Reset();
            RecServiceHeader.SetFilter("Document Type", '%1', RecServiceHeader."Document Type"::Order);
            RecServiceHeader.SetFilter("No.", Format(DOSSIER_DMS_ID_Attribute.Value()));
            if RecServiceHeader.FindFirst() then begin
                // Calcul heure de prise en charge
                /*  Milliseconds := RecServiceHeader."Time of Order" - 000000T;
                 Hours := Milliseconds div 1000 div 60 div 60;
                 Milliseconds -= Hours * 1000 * 60 * 60;
                 Minutes := Milliseconds div 1000 div 60;
                 Milliseconds -= Minutes * 1000 * 60;
                 Seconds := Milliseconds div 1000;
*/
                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                AddAttribute(XMLRoot, 'TexteDMS', '');

                /*  if RecServiceHeader.Status < RecServiceHeader.Status::"Partly Invoiced" then
                     AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1')
                 else */
                AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '2');

                AddAttribute(XMLRoot, 'RDV_DMS_ID', RecServiceHeader."No.");
                AddAttribute(XMLRoot, 'ANNEERDV', Format(Date2DMY(RecServiceHeader."Order Date", 3)));
                AddAttribute(XMLRoot, 'MOISRDV', Format(Date2DMY(RecServiceHeader."Order Date", 2)));
                AddAttribute(XMLRoot, 'JOURRDV', Format(Date2DMY(RecServiceHeader."Order Date", 1)));
                AddAttribute(XMLRoot, 'HEURESRDV', Format(Hours));
                AddAttribute(XMLRoot, 'MINUTESRDV', Format(Minutes));

                // Calcul heure de restitution
                /*  if RecServiceHeader."Pickup Time" <> 0T then begin
                     Milliseconds := RecServiceHeader."Pickup Time" - 000000T;
                     Hours := Milliseconds div 1000 div 60 div 60;
                     Milliseconds -= Hours * 1000 * 60 * 60;
                     Minutes := Milliseconds div 1000 div 60;
                     Milliseconds -= Minutes * 1000 * 60;
                     Seconds := Milliseconds div 1000;
                 end; */

                AddAttribute(XMLRoot, 'TPSIMMO', '');//Format(RecServiceHeader.TPSIMMO));
                AddAttribute(XMLRoot, 'EQUIPE', '');

                /*                  if RecServiceHeader."Pickup Date" <> 0D then begin
                                     AddAttribute(XMLRoot, 'ANNEERDV_RESTIT', Format(Date2DMY(RecServiceHeader."Pickup Date", 3)));
                                     AddAttribute(XMLRoot, 'MOISRDV_RESTIT', Format(Date2DMY(RecServiceHeader."Pickup Date", 2)));
                                     AddAttribute(XMLRoot, 'JOURRDV_RESTIT', Format(Date2DMY(RecServiceHeader."Pickup Date", 1)));
                                 end;

                                 AddAttribute(XMLRoot, 'HEURESRDV_RESTIT', Format(Hours));
                                 AddAttribute(XMLRoot, 'MINUTESRDV_RESTIT', Format(Minutes));
                                 AddAttribute(XMLRoot, 'RETOURATELIER', ''); */

                // Client
                RecCustomer.Reset();
                RecCustomer.SetFilter("No.", '%1', RecServiceHeader."Sell-to Customer No.");
                if RecCustomer.FindFirst() then begin
                    AddElement(XMLRoot, 'CLIENT', XMLNode);
                    AddAttribute(XMLNode, 'CLIENT_DMS_ID', RecCustomer."No.");
                    AddAttribute(XMLNode, 'TypeClient', Format(RecCustomer."Partner Type"));
                    AddAttribute(XMLNode, 'Nom', RecCustomer."Name");
                    AddAttribute(XMLNode, 'Prenom', RecCustomer."Name 2");
                    AddAttribute(XMLNode, 'PhoneMobile', RecCustomer."Mobile Phone No.");
                    AddAttribute(XMLNode, 'Email', RecCustomer."E-Mail");
                    AddAttribute(XMLNode, 'TypeEntreprise', RecCustomer."DLT function code");
                    AddAttribute(XMLNode, 'RaisonSociale', RecCustomer.Name);
                    AddAttribute(XMLNode, 'NumeroVoie', '');
                    AddAttribute(XMLNode, 'TypeVoie', '');
                    AddAttribute(XMLNode, 'Adresse1', RecCustomer.Address);
                    AddAttribute(XMLNode, 'Adresse2', RecCustomer."Address 2");
                    AddAttribute(XMLNode, 'Ville', RecCustomer.City);
                    AddAttribute(XMLNode, 'CodePostal', RecCustomer."Post Code");
                    if RecCustomer.County <> '' then
                        AddAttribute(XMLNode, 'Pays', RecCustomer.County)
                    else
                        AddAttribute(XMLNode, 'Pays', 'TN');
                    AddAttribute(XMLNode, 'NumeroCompte', RecCustomer."No.");
                    RecCustomer.CalcFields("Balance (LCY)");
                    AddAttribute(XMLNode, 'SoldeClient', Format(RecCustomer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
                    AddAttribute(XMLNode, 'PhoneDomicile', '');
                    AddAttribute(XMLNode, 'PhoneBureau', RecCustomer."Phone No.");
                    AddAttribute(XMLNode, 'NumeroPoste', '');
                    AddAttribute(XMLNode, 'Fax', RecCustomer."Fax No.");
                    AddAttribute(XMLNode, 'TEXTE_LIBRE', '');
                    AddAttribute(XMLNode, 'Observations', '');
                end;

                // Véhicule
                RecVehicle.Reset();
                RecVehicle.SetFilter(VIN, '%1', RecServiceHeader.VIN);
                if RecVehicle.FindFirst() then begin
                    AddElement(XMLRoot, 'VEHICULE', XMLNode);
                    AddAttribute(XMLNode, 'VEHICULE_DMS_ID', RecVehicle.VIN);
                    AddAttribute(XMLNode, 'LibelleMarque', RecVehicle."Make Code");
                    AddAttribute(XMLNode, 'LibelleModele', RecVehicle."Model Code");
                    AddAttribute(XMLNode, 'VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                    AddAttribute(XMLNode, 'VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                    AddAttribute(XMLNode, 'VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                    AddAttribute(XMLNode, 'Immatriculation', RecVehicle."Registration No.");
                    if RecVehicle."First Registration Date" <> 0D then begin
                        AddAttribute(XMLNode, 'AnneeMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 3)));
                        AddAttribute(XMLNode, 'MoisMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 2)));
                        AddAttribute(XMLNode, 'JourMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 1)));
                    end;
                    AddAttribute(XMLNode, 'DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));
                    AddAttribute(XMLNode, 'CodeOPB', '');
                    AddAttribute(XMLNode, 'TypeEntretien', '');

                    // Lignes de travaux (Job Lines)
                    RecServiceJobLine.Reset();
                    RecServiceJobLine.SetFilter("Document Type", '%1', RecServiceHeader."Document Type");
                    RecServiceJobLine.SetFilter("Document No.", '%1', RecServiceHeader."No.");
                    if RecServiceJobLine.FindFirst() then
                        repeat
                            AddElement(XMLNode, 'LDT', XMLNodeLDT);
                            AddAttribute(XMLNodeLDT, TypeXX + '_LDT',
                                Format(CheckTypeImputationByCustomer(RecServiceJobLine."Bill-to Customer No.")));
                            AddAttribute(XMLNodeLDT, 'CODEIMPUTATION_LDT', RecServiceJobLine."Bill-to Customer No.");
                            AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID', RecServiceJobLine."Instruction Description");
                            AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));

                            if RecServiceJobLine."Package No." <> '' then
                                AddAttribute(XMLNodeLDT, 'ReferenceFF', RecServiceJobLine."Package No.")
                            else
                                AddAttribute(XMLNodeLDT, 'ReferenceFF', '');

                            if RecServiceJobLine."Instruction Description" <> '' then
                                AddAttribute(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL', RecServiceJobLine."Instruction Description")
                            else
                                AddAttribute(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL', 'Vide');

                            AddAttribute(XMLNodeLDT, 'COMMENTAIRES_LDT', '');
                            AddAttribute(XMLNodeLDT, 'ACCORD_CLIENT', '');

                            /*   if RecServiceJobLine."Package No." <> '' then begin
                                  if RecServiceJobLine."Type Forfait" = RecServiceJobLine."Type Forfait"::SBOX then
                                      AddAttribute(XMLNodeLDT, 'TYPEFORFAIT', '1')
                                  else
                                      AddAttribute(XMLNodeLDT, 'TYPEFORFAIT', '2');
                              end else  */
                            AddAttribute(XMLNodeLDT, 'TYPEFORFAIT', '');

                            // Lignes de service (MO + Pièces)
                            RecServiceLine.Reset();
                            RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
                            RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
                            //RecServiceLine.SetRange("Service Job No.", RecServiceJobLine."Task No.");
                            if RecServiceLine.FindFirst() then
                                repeat
                                    if RecServiceLine.Type = RecServiceLine.Type::Labor then begin
                                        // Main d'œuvre
                                        AddElement(XMLNodeLDT, 'MO', XMLNodeMO);
                                        AddAttribute(XMLNodeMO, 'LIGNE_DT_ID', RecServiceJobLine."Instruction Code");
                                        AddAttribute(XMLNodeMO, 'LIGNE_DT_ID_DMS', Format(RecServiceLine."Line No."));
                                        AddAttribute(XMLNodeMO, TypeXX + '_MO', '');
                                        AddAttribute(XMLNodeMO, 'CODEIMPUTATION_MO', RecServiceLine."Bill-to Customer No.");
                                        /* if RecServiceLine."SBOX MO" <> '' then
                                            AddAttribute(XMLNodeMO, 'CODEOPERATION', RecServiceLine."SBOX MO")
                                        else */
                                        AddAttribute(XMLNodeMO, 'CODEOPERATION', RecServiceLine."No.");
                                        AddAttribute(XMLNodeMO, 'TYPEOPERATION', '2');
                                        AddAttribute(XMLNodeMO, 'CODETYPEVEHICULE', '');
                                        AddAttribute(XMLNodeMO, 'TEMPSGLOBAL',
                                            Format(RecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                        AddAttribute(XMLNodeMO, 'TECHNICITE', '1');
                                        AddAttribute(XMLNodeMO, 'METIER', 'T');
                                        AddAttribute(XMLNodeMO, 'LIBELLEOPERATION', RecServiceLine.Description);
                                        AddAttribute(XMLNodeMO, 'PRIXHT_MO',
                                            Format(RecServiceLine.Amount, 0, '<Precision,2:2><Standard Format,2>'));
                                        AddAttribute(XMLNodeMO, 'PRIXTTC_MO',
                                            Format(RecServiceLine."Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>'));
                                        AddAttribute(XMLNodeMO, 'CODEVENTILATION', '');
                                        AddAttribute(XMLNodeMO, 'QUANTITE',
                                            Format(RecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                    end;

                                    if RecServiceLine.Type = RecServiceLine.Type::Item then begin
                                        // Pièce de rechange
                                        AddElement(XMLNodeLDT, 'PR', XMLNodePR);
                                        AddAttribute(XMLNodePR, 'LIGNE_DT_ID', RecServiceJobLine."Instruction Code");
                                        AddAttribute(XMLNodePR, 'LIGNE_DT_ID_DMS', Format(RecServiceLine."Line No."));
                                        AddAttribute(XMLNodePR, TypeXX + '_PR', '');
                                        AddAttribute(XMLNodePR, 'CODEIMPUTATION_PR', RecServiceLine."Bill-to Customer No.");
                                        AddAttribute(XMLNodePR, 'REFERENCE_PR', SetItemNo(RecServiceLine."No."));
                                        AddAttribute(XMLNodePR, 'LIBELLE_PR', RecServiceLine.Description);
                                        AddAttribute(XMLNodePR, 'TYPE_PR', '2');
                                        AddAttribute(XMLNodePR, 'QuantiteEnCommande',
                                            Format(RecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                        AddAttribute(XMLNodePR, 'QuantiteServie',
                                            Format(RecServiceLine."Quantity Consumed", 0, '<Precision,2:2><Standard Format,2>'));
                                        AddAttribute(XMLNodePR, 'PRIXHT',
                                            Format(RecServiceLine."Unit Price" * (1 - RecServiceLine."Line Discount %" / 100),
                                                0, '<Precision,2:2><Standard Format,2>'));
                                        AddAttribute(XMLNodePR, 'PRIXTTC',
                                            Format(RecServiceLine."Unit Price" * (1 - RecServiceLine."Line Discount %" / 100)
                                                * (1 + RecServiceLine."VAT %" / 100),
                                                0, '<Precision,2:2><Standard Format,2>'));
                                    end;
                                until RecServiceLine.Next() = 0;
                        until RecServiceJobLine.Next() = 0;

                    // Lignes non affectées à un Job (Service Job No. = 0)
                    AddElement(XMLNode, 'LDT', XMLNodeLDT);
                    AddAttribute(XMLNodeLDT, TypeXX + '_LDT',
                        Format(CheckTypeImputationByCustomer(RecServiceLine."Bill-to Customer No.")));
                    AddAttribute(XMLNodeLDT, 'CODEIMPUTATION_LDT', RecServiceLine."Bill-to Customer No.");
                    AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID', '');
                    AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID_DMS', '');
                    AddAttribute(XMLNodeLDT, 'ReferenceFF', '');
                    AddAttribute(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL', 'A Classer');
                    AddAttribute(XMLNodeLDT, 'COMMENTAIRES_LDT', '');
                    AddAttribute(XMLNodeLDT, 'ACCORD_CLIENT', '');

                    RecServiceLine.Reset();
                    RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
                    RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
                    // RecServiceLine.SetFilter("Service Job No.", '%1', 0);
                    if RecServiceLine.FindFirst() then
                        repeat
                            if RecServiceLine.Type = RecServiceLine.Type::Labor then begin
                                AddElement(XMLNodeLDT, 'MO', XMLNodeMO);
                                AddAttribute(XMLNodeMO, 'LIGNE_DT_ID', '');
                                AddAttribute(XMLNodeMO, 'LIGNE_DT_ID_DMS', '');
                                AddAttribute(XMLNodeMO, TypeXX + '_MO',
                                    Format(CheckTypeImputationByCustomer(RecServiceLine."Bill-to Customer No.")));
                                AddAttribute(XMLNodeMO, 'CODEIMPUTATION_MO', RecServiceLine."Bill-to Customer No.");
                                AddAttribute(XMLNodeMO, 'CODEOPERATION', RecServiceLine."No.");
                                AddAttribute(XMLNodeMO, 'TYPEOPERATION', '');
                                AddAttribute(XMLNodeMO, 'CODETYPEVEHICULE', '');
                                AddAttribute(XMLNodeMO, 'TEMPSGLOBAL',
                                    Format(RecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                AddAttribute(XMLNodeMO, 'TECHNICITE', '1');
                                AddAttribute(XMLNodeMO, 'METIER', 'T');
                                AddAttribute(XMLNodeMO, 'LIBELLEOPERATION', RecServiceLine.Description);
                                AddAttribute(XMLNodeMO, 'PRIXHT_MO',
                                    Format(RecServiceLine.Amount, 0, '<Precision,2:2><Standard Format,2>'));
                                AddAttribute(XMLNodeMO, 'PRIXTTC_MO',
                                    Format(RecServiceLine."Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>'));
                                AddAttribute(XMLNodeMO, 'CODEVENTILATION', '');
                                AddAttribute(XMLNodeMO, 'QUANTITE',
                                    Format(RecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                            end;

                            if RecServiceLine.Type = RecServiceLine.Type::Item then begin
                                AddElement(XMLNodeLDT, 'PR', XMLNodePR);
                                AddAttribute(XMLNodePR, 'LIGNE_DT_ID', '');
                                AddAttribute(XMLNodePR, 'LIGNE_DT_ID_DMS', '');
                                AddAttribute(XMLNodePR, TypeXX + '_PR', '');
                                AddAttribute(XMLNodePR, 'CODEIMPUTATION_PR', RecServiceLine."Bill-to Customer No.");
                                AddAttribute(XMLNodePR, 'REFERENCE_PR', RecServiceLine."No.");
                                AddAttribute(XMLNodePR, 'LIBELLE_PR', RecServiceLine.Description);
                                AddAttribute(XMLNodePR, 'TYPE_PR', '2');
                                AddAttribute(XMLNodePR, 'QuantiteEnCommande',
                                    Format(RecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                AddAttribute(XMLNodePR, 'QuantiteServie',
                                    Format(RecServiceLine."Quantity Consumed", 0, '<Precision,2:2><Standard Format,2>'));
                                AddAttribute(XMLNodePR, 'PRIXHT',
                                    Format(RecServiceLine."Unit Price" * (1 - RecServiceLine."Line Discount %" / 100),
                                        0, '<Precision,2:2><Standard Format,2>'));
                                AddAttribute(XMLNodePR, 'PRIXTTC',
                                    Format(RecServiceLine."Unit Price" * (1 - RecServiceLine."Line Discount %" / 100)
                                        * (1 + RecServiceLine."VAT %" / 100),
                                        0, '<Precision,2:2><Standard Format,2>'));
                            end;
                        until RecServiceLine.Next() = 0;
                end;


            end else
                if Format(CODE_INTERR_DMS_Attribute.Value()) = '4' then begin

                    begin
                        Count := 0;
                        RecServiceHeader.Reset();
                        RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                        if RecServiceHeader.FindSet() then
                            repeat
                                AddElement(XMLRoot, 'LZRF51', XMLNode);
                                AddAttribute(XMLNode, 'Code', '0');
                                AddAttribute(XMLNode, 'TexteDMS', '');
                                AddAttribute(XMLNode, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                                AddAttribute(XMLNode, 'ETATDOSSIERDMS', '1');
                                Count += 1;
                            until (RecServiceHeader.Next() = 0) or (Count = 30);
                    end;
                end
                else begin
                    AddAttribute(XMLRoot, 'Code', '99');
                    AddAttribute(XMLRoot, 'TexteDMS', 'Code interrogation inconnu');
                end;
        end;
    end;


    procedure CheckTypeImputationByCustomer(lClient: Code[20]): Integer
    var
        SBOXSetup: Record "STF Servicebox Setup";
    begin
        if not SBOXSetup.Get() then
            Error('Le paramétrage SBOX est manquant.');

        case lClient of
            SBOXSetup."Warranty Imputation Code":
                exit(1);

        /*  SBOXSetup."Client d'imputation ASSURANCE":
             exit(SBOXSetup."Code d'imputation ASSURANCE");

         SBOXSetup."Client d'imputation CAMPAGNE":
             exit(SBOXSetup."Code d'imputation CAMPAGNE");

         SBOXSetup."Client d'imputation CONTRAT":
             exit(SBOXSetup."Code d'imputation CONTRAT");

         SBOXSetup."Client d'imputation INTERNE":
             exit(SBOXSetup."Code d'imputation INTERNE");

         else
             exit(SBOXSetup."Code d'imputation CLIENT"); */
        end;
    end;

    procedure LZRF08T11(var TempRoot: XmlElement; CurrentDMS: XmlElement; RqType: Text)
    var
        XmlNodesPR: XmlNodeList;
        XmlNodePR: XmlNode;
        XMLRoot: XmlElement;
        RecItem: Record Item;
        CODEIMPUTATIONDMS_PR: Text[30];
        LIGNE_DT_ID: Text[30];
        TYPEFACTURATION_PR: Code[2];
        i: Integer;
    begin

        // récupérer les PR dans la requête
        if not CurrentDMS.SelectNodes('PR', XmlNodesPR) then
            exit;

        if XmlNodesPR.Count = 0 then
            exit;

        // créer noeud LZRF08 dans la réponse
        XMLRoot := XmlElement.Create('LZRF08');
        TempRoot.Add(XMLRoot);

        XMLRoot.SetAttribute('Code', '0');
        XMLRoot.SetAttribute('TexteDMS', '');

        CODEIMPUTATIONDMS_PR := GetAttributeValue(CurrentDMS, 'CLIENT_DMS_ID');

        for i := 1 to XmlNodesPR.Count do begin

            XmlNodesPR.Get(i, XmlNodePR);

            LIGNE_DT_ID := GetAttributeValue(XmlNodePR.AsXmlElement(), 'LIGNE_DT_ID');
            TYPEFACTURATION_PR := GetAttributeValue(XmlNodePR.AsXmlElement(), TypeXX + '_PR');

            //to fix CheckCustomerByTypeImputation(TYPEFACTURATION_PR, CODEIMPUTATIONDMS_PR);

            HandlePR(
                TempRoot,
                XMLRoot,
                GetAttributeValue(XmlNodePR.AsXmlElement(), 'REFERENCE_PR'),
                CODEIMPUTATIONDMS_PR,
                LIGNE_DT_ID
            );

        end;

    end;

    procedure HandlePR(
        var TempRoot: XmlElement;
        var XMLRoot: XmlElement;
        ItemNo: Code[20];
        CustomerNo: Code[20];
        LigneId: Text)
    var
        Item: Record Item;
        NodePR: XmlElement;
        AvailableInventory: Decimal;
    begin

        if not Item.Get(ItemNo) then
            exit;

        Item.CalcFields(Inventory);
        AvailableInventory := Item.Inventory;

        NodePR := XmlElement.Create('PR');

        NodePR.SetAttribute('REFERENCE_PR', ItemNo);
        NodePR.SetAttribute('STOCK', Format(AvailableInventory));
        NodePR.SetAttribute('LIGNE_DT_ID', LigneId);

        XMLRoot.Add(NodePR);

    end;

    var
        NumeroPoste: Text[30];
        PARAMDMS: Text[50];
        TypeXX: Text[30];
        eDMSSetup: Record "STF Servicebox Setup";

}

