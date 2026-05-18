codeunit 75500  "SBX Business Layer"
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

        // 🔹 G"SBX "SBX est""ion Code / TexteDMS
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
            XMLDossier.SetAttribute('ETATDOSSIERDMS', '1'); // Facturé
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

    procedure LZRF46T23V1(
     var TempRoot: XmlElement;
     CurrentDMS: XmlElement;
     CodeImputationDMS_PR: Code[20])
    var
        RecItem: Record Item;
        RecCustomer: Record Customer;
        XmlNodesPR: XmlNodeList;
        XmlNodePR: XmlNode;
        XMLRoot: XmlElement;
        ReferencePR: Code[30];
        LigneDTId: Text[30];
        CodePR: Code[10];
        i: Integer;
        ProcessedRefs: Dictionary of [Text, Boolean]; // ajouter cette variable

    begin
        if not CurrentDMS.SelectNodes('PR', XmlNodesPR) then
            exit;
        if XmlNodesPR.Count = 0 then
            exit;

        // ── Créer LZRF46 temporairement ─────────────────────────────
        XMLRoot := XmlElement.Create('LZRF46');
        XMLRoot.SetAttribute('Code', '0');

        for i := 1 to XmlNodesPR.Count do begin
            XmlNodesPR.Get(i, XmlNodePR);
            ReferencePR := GetAttributeValue(XmlNodePR.AsXmlElement(), 'ReferencePR');
            LigneDTId := GetAttributeValue(XmlNodePR.AsXmlElement(), 'LIGNE_DT_ID');
            CodePR := GetAttributeValue(XmlNodePR.AsXmlElement(), 'CODE_PR');

            if ReferencePR = '' then
                continue;

            // ✅ Dédupliquer : une seule ligne prix par ReferencePR
            if ProcessedRefs.ContainsKey(ReferencePR) then
                continue;
            ProcessedRefs.Add(ReferencePR, true);

            if (CodePR = '0') or (CodePR = '2') then
                AddPRPrix(XMLRoot, ReferencePR, LigneDTId,
                          CodeImputationDMS_PR, RecItem, RecCustomer);
        end;  // ── N'ajouter LZRF46 que s'il contient au moins un PR prix ──
        if XMLRoot.GetChildNodes().Count > 0 then
            TempRoot.Add(XMLRoot);
        // ✅ sinon LZRF46 est abandonné silencieusement
    end;

    local procedure AddPRPrixVide(
        var XMLRoot: XmlElement;
        ReferencePR: Code[30])
    var
        XMLNode: XmlElement;
    begin
        AddElement(XMLRoot, 'PR', XMLNode);
        XMLNode.SetAttribute('CODE_PR', '99');
        XMLNode.SetAttribute('ReferencePR', SetItemNo(ReferencePR));

        XMLNode.SetAttribute('LibellePR', '');
        XMLNode.SetAttribute('PrixUnitaireHT', '');
        XMLNode.SetAttribute('PrixUnitaireTTC', '');
        XMLNode.SetAttribute('Remise', '');
    end;

    procedure LZRF45T22V1(var TempRoot: XmlElement; CurrentDMS: XmlElement; RqType: Text)
    var
        SBManagement: Codeunit "STF Service Box Mgt";

        XmlNodeLDT: XmlNodeList;
        XmlNodesMO: XmlNodeList;
        XmlNodeLDTItem: XmlNode;
        XmlNodeMO: XmlNode;
        XMLRoot: XmlElement;
        NodeMO: XmlElement;

        CODEIMPUTATIONDMS_MO: Code[30];
        CODEOPERATION: Code[20];
        LIGNE_DT_ID: Text[30];
        TEMPSGLOBAL: Decimal;

        UnitPrice: Decimal;
        UnitPriceTTC: Decimal;
        ErrorMsg: Text;
        ErrorMO: Boolean;
        i, j : Integer;
    begin
        // Initialisation
        ErrorMO := false;

        if not CurrentDMS.SelectNodes('LDT', XmlNodeLDT) then
            exit;

        // Création du noeud racine LZRF45
        XMLRoot := XmlElement.Create('LZRF45');
        TempRoot.Add(XMLRoot);

        for j := 1 to XmlNodeLDT.Count do begin
            XmlNodeLDT.Get(j, XmlNodeLDTItem);

            if not XmlNodeLDTItem.SelectNodes('MO', XmlNodesMO) then
                continue;

            for i := 1 to XmlNodesMO.Count do begin
                XmlNodesMO.Get(i, XmlNodeMO);

                // Extraction des données du XML source
                CODEOPERATION := GetAttributeValue(XmlNodeMO.AsXmlElement(), 'CODEOPERATION');
                CODEIMPUTATIONDMS_MO := GetAttributeValue(XmlNodeMO.AsXmlElement(), 'CODEIMPUTATIONDMS_MO');
                LIGNE_DT_ID := GetAttributeValue(XmlNodeMO.AsXmlElement(), 'LIGNE_DT_ID');

                if not Evaluate(TEMPSGLOBAL, ConvertStr(GetAttributeValue(XmlNodeMO.AsXmlElement(), 'TEMPSGLOBAL'), '.', ',')) then
                    TEMPSGLOBAL := 0;

                // Création du noeud MO de sortie
                NodeMO := XmlElement.Create('MO');
                XMLRoot.Add(NodeMO);
                NodeMO.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);
                NodeMO.SetAttribute('LIGNE_DT_ID_DMS', '');
                NodeMO.SetAttribute('WR_CODE_OPERATION', CODEOPERATION);

                // Appel de votre fonction de recherche de prix
                if FindPriceMO(CODEIMPUTATIONDMS_MO, CODEOPERATION, UnitPrice, UnitPriceTTC, ErrorMsg) then begin
                    // Succès : On multiplie le prix unitaire par le temps
                    NodeMO.SetAttribute('PrixUnitaireHT', Format(UnitPrice, 0, '<Precision,2:2><Standard Format,2>'));
                    NodeMO.SetAttribute('PrixUnitaireTTC', Format(UnitPriceTTC, 0, '<Precision,2:2><Standard Format,2>'));
                    NodeMO.SetAttribute('REMISE_DMS', '0.00'); // À gérer dans FindPriceMO si nécessaire
                    NodeMO.SetAttribute('TexteErreur', '');
                end else begin
                    // Échec : Récupération des valeurs originales du XML (Fallback)
                    NodeMO.SetAttribute('PrixUnitaireHT', GetAttributeValue(XmlNodeMO.AsXmlElement(), 'PRIXHT_MO'));
                    NodeMO.SetAttribute('PrixUnitaireTTC', GetAttributeValue(XmlNodeMO.AsXmlElement(), 'PRIXTTC_MO'));
                    NodeMO.SetAttribute('REMISE_DMS', '0.00');
                    NodeMO.SetAttribute('TexteErreur', CODEOPERATION + ' ' + ErrorMsg);
                    ErrorMO := true;
                end;
            end;
        end;

        // Finalisation du statut global
        if ErrorMO then begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Erreur de valorisation MO');
        end else begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');
        end;
    end;



    local procedure GetSTFOperation(DMSCode: Code[20]): Code[20]
    var
        UnderscorePos: Integer;
    begin
        // 01490910_C → 01490910
        // 22540210_CTR → 22540210
        UnderscorePos := StrPos(DMSCode, '_');
        if UnderscorePos > 1 then
            exit(CopyStr(DMSCode, 1, UnderscorePos - 1));
        exit(DMSCode); // pas de suffixe → retourne tel quel
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
                RecCustomer.SetFilter(Name, '%1', '*' + ChampsCmpl + '*');
            //RecCustomer.SetFilter(Name, '@*' + ChampsCmpl + '*');
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
        end
        else
            if TotalCount = 1 then begin
                XMLRoot.SetAttribute('Code', '0');
                XMLRoot.SetAttribute('TexteDMS', '');
                LZRC03T03V1(RecCustomer."No.", XMLNodeReq, RqType);
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
            //  CreateItem(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'), GetAttributeValue(XMLNodePR, 'LibellePR'), '');
            exit;
        RecSalesLine.Init();
        RecSalesLine."Document Type" := RecSalesHeader."Document Type";
        RecSalesLine."Document No." := RecSalesHeader."No.";
        RecSalesLine."Line No." := GetNextSalesLineNo(RecSalesHeader);
        RecSalesLine.Validate(Type, RecSalesLine.Type::Item);
        RecSalesLine.Validate("No.", item."No.");
        // if Evaluate(qte, ConvertStr(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'), '.', ',')) then;

        qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteCommandee'));
        if qte = 0 then
            qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'));

        RecSalesLine.Validate(Quantity, qte);
        RecSalesLine."SBX Line LDT" := LigneDT;
        RecSalesLine.Insert(true);
    end;

    /// <summary>Insère une ligne de vente pour une pièce (PR) – avec filtre LDT.</summary>
    procedure InsertPRSalesLineLDT(RecSalesHeader: Record "Sales Header"; XMLNodePR: XmlElement; LigneDT: Code[20])
    var
        RecSalesLine: Record "Sales Line";
        qte: Decimal;
        item: Record Item;
    begin
        if not item.Get(GetItemNo(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'))) then begin
            /*  CreateItem(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'), GetAttributeValue(XMLNodePR, 'LibellePR'), '');
             item.Get(GetItemNo(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'))); */
            exit;
        end;
        RecSalesLine.Init();
        RecSalesLine."Document Type" := RecSalesHeader."Document Type";
        RecSalesLine."Document No." := RecSalesHeader."No.";
        RecSalesLine."Line No." := GetNextSalesLineNo(RecSalesHeader);
        RecSalesLine.Validate(Type, RecSalesLine.Type::Item);
        RecSalesLine.Validate("No.", item."No.");
        RecSalesLine."SBX Line LDT" := LigneDT;
        RecSalesLine."SBX Line LDT Filter" := LigneDT;
        //if Evaluate(qte, ConvertStr(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'), '.', ',')) then;

        qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteCommandee'));
        if qte = 0 then
            qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'));

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


    procedure CheckUserSetup(Utilisateur: Text[30]; PostCode: Code[10]; var RecLocation: Record Location; var RecServiceLocation: Record Location): Boolean
    var
        userOK: Boolean;
    begin
        userOK := false;
        Clear(RecUserSetup);
        RecUserSetup.Reset();

        RecUserSetup.SetRange("SBX ServiceBOX Code", Utilisateur);

        if RecUserSetup.FindFirst() then begin
            RecWarehouseEmployee.Reset();
            RecWarehouseEmployee.SetRange("User ID", RecUserSetup."User ID");
            RecWarehouseEmployee.SetRange("SBX Service BOX Location", true);

            if RecWarehouseEmployee.Count > 1 then begin
                if PostCode <> '' then
                    RecWarehouseEmployee.SetRange("SBX Service BOX Post", PostCode);
            end;

            if RecWarehouseEmployee.FindFirst() then begin

                // 🔹 Location standard (inchangée)
                if RecLocation.Get(RecWarehouseEmployee."Location Code") then begin

                    // 🔹 Nouvelle Service Location
                    if RecWarehouseEmployee."SBX Service Location Code" <> '' then
                        RecServiceLocation.Get(RecWarehouseEmployee."SBX Service Location Code");

                    exit(true);
                end;

            end else begin
                // fallback
                RecWarehouseEmployee.Reset();
                RecWarehouseEmployee.SetRange("User ID", RecUserSetup."User ID");
                RecWarehouseEmployee.SetRange("SBX Service BOX Location", true);

                if RecWarehouseEmployee.FindFirst() then
                    if RecLocation.Get(RecWarehouseEmployee."Location Code") then begin

                        // 🔹 Nouvelle Service Location (fallback aussi)
                        if RecWarehouseEmployee."SBX Service Location Code" <> '' then
                            RecServiceLocation.Get(RecWarehouseEmployee."SBX Service Location Code");

                        exit(true);
                    end;
            end;
        end;

        exit(false);
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

    procedure LZRC03T03V1ll(CLIENT_DMS_ID: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
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
        /*   IF (RqType='01') OR (RqType='02') OR (RqType='03') THEN
         LZRC07T05V1(RecCustomer."No.", XMLRootDMS, XMLNodeReq, RqType); */
        // 3. AJOUT au nœud parent <DMS> au lieu du Document
        XMLRootDMS.Add(XMLRoot);
    end;

    // ============================================================
    // 1. LZRC23 — Données techniques du véhicule
    // ============================================================
    procedure LZRC23T09V1(VEHICULE_DMS_ID: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle";
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        ExistingNode: XmlNode;
        DateToUse: Date;
    begin
        // Sécurité anti-récursion
        if XMLRootDMS.SelectSingleNode('LZRC23', ExistingNode) then exit;

        XMLRoot := XmlElement.Create('LZRC23');

        RecVehicle.Reset();
        RecVehicle.SetRange(VIN, VEHICULE_DMS_ID);

        if RecVehicle.FindFirst() then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');

            XMLNode := XmlElement.Create('VEHICULE');
            XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
            XMLNode.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
            XMLNode.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
            XMLNode.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
            XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");
            XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
            XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");

            // Gestion de la date de mise en circulation
            if RecVehicle."First Registration Date" <> 0D then
                DateToUse := RecVehicle."First Registration Date"
            else
                DateToUse := RecVehicle."Creation Date";

            if DateToUse <> 0D then begin
                XMLNode.SetAttribute('AnneeMiseCirculation', Format(Date2DMY(DateToUse, 3)));
                XMLNode.SetAttribute('MoisMiseCirculation', Format(Date2DMY(DateToUse, 2)));
                XMLNode.SetAttribute('JourMiseCirculation', Format(Date2DMY(DateToUse, 1)));
            end;

            // Format 9 = XML Standard (pas d'espaces dans les milliers)
            XMLNode.SetAttribute('DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, 9));
            XMLNode.SetAttribute('TypeEntretien', RecVehicle.VIN);

            XMLRoot.Add(XMLNode);
            XMLRootDMS.Add(XMLRoot); // Ajout immédiat au document principal

            // CASCADE vers LZRC02 (Identification Client)
            if RecVehicle."Customer No." <> '' then
                LZRC02T02V1(RecVehicle.VIN, RecVehicle.VIN, RecVehicle."Registration No.", XMLRootDMS, RqType);

        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Véhicule introuvable');
            XMLRootDMS.Add(XMLRoot);
        end;
    end;

    // ============================================================
    // 2. LZRC02 — Identification rapide du propriétaire
    // ============================================================
    procedure LZRC02T02V1(VEHICULE_DMS_ID: Text[30]; VIN: Text[30]; IMMATRICULATION: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle";
        RecCustomer: Record Customer;
        XMLRoot, XMLNode : XmlElement;
        ExistingNode: XmlNode;
        Count: Integer;
    begin
        if XMLRootDMS.SelectSingleNode('LZRC02', ExistingNode) then exit;

        XMLRoot := XmlElement.Create('LZRC02');
        RecVehicle.Reset();
        if (VEHICULE_DMS_ID <> '') then
            RecVehicle.SetRange(VIN, VEHICULE_DMS_ID)
        else if (VIN <> '') then
            RecVehicle.SetRange(VIN, VIN)
        else if (IMMATRICULATION <> '') then RecVehicle.SetRange("Registration No.", IMMATRICULATION);

        if RecVehicle.FindFirst() and (RecVehicle."Customer No." <> '') then begin
            RecCustomer.Reset();
            RecCustomer.SetRange("No.", RecVehicle."Customer No.");
            RecCustomer.SetRange(Blocked, RecCustomer.Blocked::" ");

            if RecCustomer.FindSet() then begin
                repeat
                    Count += 1;
                    XMLNode := XmlElement.Create('CLIENT');
                    XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");

                    // Mapping conforme au Flux B (Type 4 = RaisonSociale)
                    if RecCustomer."Partner Type" = RecCustomer."Partner Type"::Company then begin
                        XMLNode.SetAttribute('TypeClient', '4');
                        XMLNode.SetAttribute('RaisonSociale', RecCustomer.Name);
                    end else begin
                        XMLNode.SetAttribute('TypeClient', '1');
                        XMLNode.SetAttribute('Nom', RecCustomer.Name);
                    end;

                    XMLNode.SetAttribute('Adresse1', RecCustomer.Address);
                    XMLNode.SetAttribute('Ville', RecCustomer.City);
                    XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");
                    XMLNode.SetAttribute('NumeroCompte', RecCustomer."No.");
                    XMLRoot.Add(XMLNode);
                until (RecCustomer.Next() = 0) or (Count = 30);
            end;
        end;

        XMLRootDMS.Add(XMLRoot); // Ajout systématique au document

        // CASCADE vers LZRC03 (Détails complets) si client unique
        if (Count = 1) then
            LZRC03T03V1(RecVehicle."Customer No.", XMLRootDMS, RqType);
    end;

    // ============================================================
    // 3. LZRC03 — Fiche Client complète (Contacts & Solde)
    // ============================================================
    procedure LZRC03T03V1(CLIENT_DMS_ID: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
    var
        RecCustomer: Record Customer;
        XMLRoot, XMLNode : XmlElement;
        ExistingNode: XmlNode;
    begin
        if XMLRootDMS.SelectSingleNode('LZRC03', ExistingNode) then exit;

        XMLRoot := XmlElement.Create('LZRC03');
        RecCustomer.Reset();
        if RecCustomer.Get(CLIENT_DMS_ID) then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');
            RecCustomer.CalcFields(Balance);

            XMLNode := XmlElement.Create('CLIENT');
            XMLNode.SetAttribute('CLIENT_DMS_ID', RecCustomer."No.");

            // Mapping Société vs Particulier
            if RecCustomer."Partner Type" = RecCustomer."Partner Type"::Company then begin
                XMLNode.SetAttribute('TypeClient', '4');
                XMLNode.SetAttribute('RaisonSociale', RecCustomer.Name);
            end else begin
                XMLNode.SetAttribute('TypeClient', '1');
                XMLNode.SetAttribute('Nom', RecCustomer.Name);
            end;

            XMLNode.SetAttribute('PhoneMobile', RecCustomer."Mobile Phone No.");
            XMLNode.SetAttribute('PhoneBureau', RecCustomer."Phone No.");
            XMLNode.SetAttribute('Adresse1', RecCustomer.Address);
            XMLNode.SetAttribute('Ville', RecCustomer.City);
            XMLNode.SetAttribute('CodePostal', RecCustomer."Post Code");
            XMLNode.SetAttribute('Pays', (RecCustomer."Country/Region Code" <> '') ? RecCustomer."Country/Region Code" : 'TN');
            XMLNode.SetAttribute('SoldeClient', Format(RecCustomer.Balance, 0, 9));
            XMLNode.SetAttribute('NumeroCompte', RecCustomer."No.");

            XMLRoot.Add(XMLNode);
        end;
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

    // ============================================================
    // LZRC08T06V1 — Interrogation liste de véhicules
    // ============================================================
    procedure LZRC08T06V1(var XMLRootDMS: XmlElement; XMLNodeReq: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle";
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        CODE_INTERROGATION: Text[30];
        CHAMPS_CMPL: Text[30];
        Count, TotalVehicles : Integer;
        ExistingNode: XmlNode;
    begin
        // 1. Safety Check: If LZRC08 already exists in the response, don't run again (prevents recursion)
        if XMLRootDMS.SelectSingleNode('LZRC08', ExistingNode) then
            exit;

        CODE_INTERROGATION := GetAttributeValue(XMLNodeReq, 'CODE_INTERROGATION');
        CHAMPS_CMPL := GetAttributeValue(XMLNodeReq, 'CHAMPS_CMPL');

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

            if TotalVehicles = 1 then begin
                // 1 seul véhicule found -> Success
                XMLRoot.SetAttribute('Code', '0');
                XMLRoot.SetAttribute('TexteDMS', '');
                XMLRootDMS.Add(XMLRoot); // Add LZRC08 to the document BEFORE calling next step

                // Cascade call
                LZRC23T09V1(RecVehicle.VIN, XMLRootDMS, RqType);
                exit;
            end else if (TotalVehicles > 1) and (TotalVehicles < 30) then begin
                XMLRoot.SetAttribute('Code', '0');
                XMLRoot.SetAttribute('TexteDMS', Format(Count) + ' enregistrements trouvés.');
            end else if TotalVehicles >= 30 then begin
                XMLRoot.SetAttribute('Code', '95');
                XMLRoot.SetAttribute('TexteDMS', 'Nombre de réponses trop grand. Précisez les paramètres de recherche.');
            end;
        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Aucun véhicule trouvé avec ces critères !');
        end;

        XMLRootDMS.Add(XMLRoot);
    end;

    // ============================================================
    // LZRC23T09V1 — Interrogation données commerciales
    // ============================================================
    procedure LZRC23T09V1lll(VEHICULE_DMS_ID: Text[30]; var XMLRootDMS: XmlElement; RqType: Text[30])
    var
        RecVehicle: Record "Vehicle";
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        DateToUse: Date;
        ExistingNode: XmlNode;
        XMLNodeReqCascade: XmlElement;
    begin
        // 1. Safety Check: If LZRC23 already exists, don't run again
        if XMLRootDMS.SelectSingleNode('LZRC23', ExistingNode) then
            exit;

        XMLRoot := XmlElement.Create('LZRC23');

        RecVehicle.Reset();
        RecVehicle.SetRange(VIN, VEHICULE_DMS_ID);

        if RecVehicle.FindFirst() then begin
            XMLRoot.SetAttribute('Code', '0');
            XMLRoot.SetAttribute('TexteDMS', '');

            XMLNode := XmlElement.Create('VEHICULE');
            XMLNode.SetAttribute('VEHICULE_DMS_ID', RecVehicle.VIN);
            XMLNode.SetAttribute('LibelleMarque', RecVehicle."Make Code");
            XMLNode.SetAttribute('LibelleModele', RecVehicle."Model Code");
            XMLNode.SetAttribute('VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
            XMLNode.SetAttribute('VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
            XMLNode.SetAttribute('VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
            XMLNode.SetAttribute('Immatriculation', RecVehicle."Registration No.");

            // Missing Circulation Date Logic
            if RecVehicle."First Registration Date" <> 0D then
                DateToUse := RecVehicle."First Registration Date"
            else
                DateToUse := RecVehicle."Creation Date";

            if DateToUse <> 0D then begin
                XMLNode.SetAttribute('AnneeMiseCirculation', Format(Date2DMY(DateToUse, 3)));
                XMLNode.SetAttribute('MoisMiseCirculation', Format(Date2DMY(DateToUse, 2)));
                XMLNode.SetAttribute('JourMiseCirculation', Format(Date2DMY(DateToUse, 1)));
            end;

            // Missing Mileage & Labor Type
            XMLNode.SetAttribute('DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));
            XMLNode.SetAttribute('CodeOPB', '');
            XMLNode.SetAttribute('TypeEntretien', RecVehicle.VIN); // Following your decoded example logic

            XMLRoot.Add(XMLNode);
            XMLRootDMS.Add(XMLRoot); // Add to document

            // Cascade back to LZRC08 ONLY if needed by RqType
            if RqType in ['05', '06', '09'] then begin
                XMLNodeReqCascade := XmlElement.Create('Request');
                XMLNodeReqCascade.SetAttribute('CODE_INTERROGATION', '1');
                XMLNodeReqCascade.SetAttribute('CHAMPS_CMPL', RecVehicle.VIN);
                LZRC02T02V1(RecVehicle.vin, RecVehicle.VIN, RecVehicle."Registration No.", XMLRootDMS, RqType);
            end;

        end else begin
            XMLRoot.SetAttribute('Code', '99');
            XMLRoot.SetAttribute('TexteDMS', 'Véhicule introuvable');
            XMLRootDMS.Add(XMLRoot);
        end;
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
    begin

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
            XMLRoot.SetAttribute('ETATDOSSIERDMS', '1');
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





    procedure LZRF51T51V1(TempRoot: XmlElement; XMLNodeReq: XmlElement)
    var
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        XMLNodeVehicule: XmlElement;
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
        RecServiceLabor: Record "Service Labor";
        RecVehicle: Record Vehicle;
        RecCustomer: Record Customer;
        RecSaleHeader: Record "Sales Header";
        RecSaleLine: Record "Sales Line";
        Milliseconds: Integer;
        Hours: Integer;
        Minutes: Integer;
        Seconds: Integer;
        HoursRestit: Integer;
        MinutesRestit: Integer;
        Count: Integer;
        AttrList: XmlAttributeCollection;
    begin
        XMLRoot := XmlElement.Create('LZRF51');
        TempRoot.Add(XMLRoot);

        AttrList := XMLNodeReq.Attributes();
        AttrList.Get('CODE_INTERROGATION_DMS', CODE_INTERR_DMS_Attribute);
        AttrList.Get('DOSSIER_DMS_ID', DOSSIER_DMS_ID_Attribute);
        AttrList.Get('RDV_DMS_ID', RDV_DMS_ID_Attribute);

        // ─────────────────────────────────────────────────────────
        // CAS 1 — Existence dossier service
        // ─────────────────────────────────────────────────────────
        if Format(CODE_INTERR_DMS_Attribute.Value()) = '1' then begin
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
                    AddAttribute(XMLRoot, 'RemiseDossier', '');
                    AddAttribute(XMLRoot, 'MotifRemise', '');
                    AddAttribute(XMLRoot, 'NUMEROCARTEDEREPERAGE', '');
                    AddAttribute(XMLRoot, 'MARQUE_RECEP', '');
                    AddAttribute(XMLRoot, 'SIGNATURE_NUMERIQUE', '');
                until RecServiceHeader.Next() = 0;
            end else begin
                AddAttribute(XMLRoot, 'Code', '99');
                AddAttribute(XMLRoot, 'TexteDMS', 'Dossier non trouve');
            end;

            // ─────────────────────────────────────────────────────────
            // CAS 2 — Header + Client + Vehicule + LDT service
            // ─────────────────────────────────────────────────────────
        end else if Format(CODE_INTERR_DMS_Attribute.Value()) = '2' then begin
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
                    AddAttribute(XMLRoot, 'RemiseDossier', '');
                    AddAttribute(XMLRoot, 'MotifRemise', '');
                    AddAttribute(XMLRoot, 'NUMEROCARTEDEREPERAGE', '');
                    AddAttribute(XMLRoot, 'MARQUE_RECEP', '');
                    AddAttribute(XMLRoot, 'SIGNATURE_NUMERIQUE', '');

                    RecCustomer.Reset();
                    RecCustomer.SetRange("No.", RecServiceHeader."Sell-to Customer No.");
                    if RecCustomer.FindSet() then
                        repeat
                            AddElement(XMLRoot, 'CLIENT', XMLNode);
                            AddAttribute(XMLNode, 'CLIENT_DMS_ID', RecCustomer."No.");
                            AddAttribute(XMLNode, 'TypeClient', Format(RecCustomer."Partner Type"));
                            AddAttribute(XMLNode, 'Nom', RecCustomer.Name);
                            AddAttribute(XMLNode, 'Prenom', RecCustomer."Name 2");           // [ADD-2]
                            AddAttribute(XMLNode, 'PhoneMobile', RecCustomer."Mobile Phone No.");
                            AddAttribute(XMLNode, 'Email', RecCustomer."E-Mail");            // [ADD-2]
                            AddAttribute(XMLNode, 'TypeEntreprise', RecCustomer."DLT function code"); // [ADD-2]
                            AddAttribute(XMLNode, 'RaisonSociale', RecCustomer.Name);
                            AddAttribute(XMLNode, 'NumeroVoie', '');
                            AddAttribute(XMLNode, 'TypeVoie', '');
                            AddAttribute(XMLNode, 'Adresse1', RecCustomer.Address);
                            AddAttribute(XMLNode, 'Adresse2', RecCustomer."Address 2");      // [ADD-2]
                            AddAttribute(XMLNode, 'Adresse3', '');                           // [ADD-2]
                            AddAttribute(XMLNode, 'Ville', RecCustomer.City);
                            AddAttribute(XMLNode, 'CodePostal', RecCustomer."Post Code");
                            if RecCustomer.County <> '' then
                                AddAttribute(XMLNode, 'Pays', RecCustomer.County)
                            else
                                AddAttribute(XMLNode, 'Pays', 'TN');                         // [ADD-2]
                            AddAttribute(XMLNode, 'NumeroCompte', RecCustomer."No.");
                            RecCustomer.CalcFields("Balance (LCY)");
                            AddAttribute(XMLNode, 'SoldeClient', Format(RecCustomer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
                            AddAttribute(XMLNode, 'PhoneDomicile', '');                      // [ADD-2]
                            AddAttribute(XMLNode, 'PhoneBureau', RecCustomer."Phone No.");   // [ADD-2]
                            AddAttribute(XMLNode, 'NumeroPoste', '');                        // [ADD-2]
                            AddAttribute(XMLNode, 'Fax', RecCustomer."Fax No.");             // [ADD-2]
                            AddAttribute(XMLNode, 'TEXTE_LIBRE', '');                        // [ADD-2]
                            AddAttribute(XMLNode, 'Observations', '');                       // [ADD-2]
                        until RecCustomer.Next() = 0;

                    RecVehicle.Reset();
                    RecVehicle.SetRange(VIN, RecServiceHeader.VIN);
                    if RecVehicle.FindSet() then
                        repeat
                            AddElement(XMLRoot, 'VEHICULE', XMLNodeVehicule);
                            AddAttribute(XMLNodeVehicule, 'VEHICULE_DMS_ID', RecVehicle.VIN);
                            AddAttribute(XMLNodeVehicule, 'LibelleMarque', RecVehicle."Make Code");
                            AddAttribute(XMLNodeVehicule, 'LibelleModele', RecVehicle."Model Code");
                            AddAttribute(XMLNodeVehicule, 'VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                            AddAttribute(XMLNodeVehicule, 'VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                            AddAttribute(XMLNodeVehicule, 'VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                            AddAttribute(XMLNodeVehicule, 'Immatriculation', RecVehicle."Registration No.");
                            if RecVehicle."First Registration Date" <> 0D then begin        // [ADD-3]
                                AddAttribute(XMLNodeVehicule, 'AnneeMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 3)));
                                AddAttribute(XMLNodeVehicule, 'MoisMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 2)));
                                AddAttribute(XMLNodeVehicule, 'JourMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 1)));
                            end else begin
                                AddAttribute(XMLNodeVehicule, 'AnneeMiseCirculation', '');
                                AddAttribute(XMLNodeVehicule, 'MoisMiseCirculation', '');
                                AddAttribute(XMLNodeVehicule, 'JourMiseCirculation', '');
                            end;
                            AddAttribute(XMLNodeVehicule, 'DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));
                            AddAttribute(XMLNodeVehicule, 'CodeOPB', '');                    // [ADD-3]
                            AddAttribute(XMLNodeVehicule, 'TypeEntretien', '');              // [ADD-3]
                        until RecVehicle.Next() = 0;

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
                AddAttribute(XMLRoot, 'TexteDMS', 'Dossier non trouve');
            end;

            // ─────────────────────────────────────────────────────────
            // CAS 3 — Détail complet dossier
            // ─────────────────────────────────────────────────────────
        end else if Format(CODE_INTERR_DMS_Attribute.Value()) = '3' then begin

            if StrPos(Format(DOSSIER_DMS_ID_Attribute.Value()), 'F') = 1 then
                LZRF51T51FV1(XMLRoot, XMLNodeReq, Format(DOSSIER_DMS_ID_Attribute.Value()))

            // ── Commande de vente PR (préfixe CV) ────────────────
            else if StrPos(Format(DOSSIER_DMS_ID_Attribute.Value()), 'CV') = 1 then begin
                RecSaleHeader.Reset();
                RecSaleHeader.SetRange("Document Type", RecSaleHeader."Document Type"::Order);
                RecSaleHeader.SetRange("No.", Format(DOSSIER_DMS_ID_Attribute.Value()));
                if RecSaleHeader.FindFirst() then begin

                    // LZRF51
                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecSaleHeader."No.");
                    AddAttribute(XMLRoot, 'TexteDMS', '');
                    /*  if RecSaleHeader.Status < RecSaleHeader.Status::"Partly Invoiced" then
                         AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1')
                     else */
                    AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1');
                    AddAttribute(XMLRoot, 'RDV_DMS_ID', RecSaleHeader."No.");
                    AddAttribute(XMLRoot, 'ANNEERDV', Format(Date2DMY(RecSaleHeader."Order Date", 3)));
                    AddAttribute(XMLRoot, 'MOISRDV', Format(Date2DMY(RecSaleHeader."Order Date", 2)));
                    AddAttribute(XMLRoot, 'JOURRDV', Format(Date2DMY(RecSaleHeader."Order Date", 1)));
                    AddAttribute(XMLRoot, 'HEURESRDV', '');
                    AddAttribute(XMLRoot, 'MINUTESRDV', '');
                    AddAttribute(XMLRoot, 'EQUIPE', '');
                    AddAttribute(XMLRoot, 'RETOURATELIER', '');

                    // CLIENT
                    RecCustomer.Reset();
                    RecCustomer.SetRange("No.", RecSaleHeader."Sell-to Customer No.");
                    if RecCustomer.FindFirst() then begin
                        AddElement(XMLRoot, 'CLIENT', XMLNode);
                        AddAttribute(XMLNode, 'CLIENT_DMS_ID', RecCustomer."No.");
                        AddAttribute(XMLNode, 'TypeClient', Format(RecCustomer."Partner Type"));
                        AddAttribute(XMLNode, 'Nom', RecCustomer.Name);
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
                        RecCustomer.CalcFields("Balance (LCY)");
                        AddAttribute(XMLNode, 'SoldeClient', Format(RecCustomer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
                        AddAttribute(XMLNode, 'PhoneDomicile', '');
                        AddAttribute(XMLNode, 'PhoneBureau', RecCustomer."Phone No.");
                        AddAttribute(XMLNode, 'NumeroPoste', '');
                        AddAttribute(XMLNode, 'Fax', RecCustomer."Fax No.");
                        AddAttribute(XMLNode, 'TEXTE_LIBRE', '');
                        AddAttribute(XMLNode, 'Observations', '');
                    end;

                    // VEHICULE — XMLNodeVehicule dédié [FIX-4]
                    RecVehicle.Reset();
                    RecVehicle.SetRange(VIN, RecSaleHeader."SBX VIN SBOX");
                    if RecVehicle.FindFirst() then begin
                        AddElement(XMLRoot, 'VEHICULE', XMLNodeVehicule);
                        AddAttribute(XMLNodeVehicule, 'VEHICULE_DMS_ID', RecVehicle.VIN);
                        AddAttribute(XMLNodeVehicule, 'LibelleMarque', RecVehicle."Make Code");
                        AddAttribute(XMLNodeVehicule, 'LibelleModele', RecVehicle."Model Code");
                        AddAttribute(XMLNodeVehicule, 'VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                        AddAttribute(XMLNodeVehicule, 'VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                        AddAttribute(XMLNodeVehicule, 'VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                        AddAttribute(XMLNodeVehicule, 'Immatriculation', RecVehicle."Registration No.");
                        if RecVehicle."First Registration Date" <> 0D then begin
                            AddAttribute(XMLNodeVehicule, 'AnneeMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 3)));
                            AddAttribute(XMLNodeVehicule, 'MoisMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 2)));
                            AddAttribute(XMLNodeVehicule, 'JourMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 1)));
                        end;
                        AddAttribute(XMLNodeVehicule, 'DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));
                        AddAttribute(XMLNodeVehicule, 'CodeOPB', '');
                        AddAttribute(XMLNodeVehicule, 'TypeEntretien', '');

                        // LDT enfant de VEHICULE [FIX-6]
                        RecSaleLine.Reset();
                        RecSaleLine.SetRange("Document Type", RecSaleLine."Document Type"::Order);
                        RecSaleLine.SetRange("Document No.", RecSaleHeader."No.");
                        if RecSaleLine.FindSet() then begin
                            AddElement(XMLNodeVehicule, 'LDT', XMLNodeLDT);  // LDT enfant de VEHICULE ✅
                            AddAttribute(XMLNodeLDT, TypeXX + '_LDT', '1');
                            AddAttribute(XMLNodeLDT, 'CODEIMPUTATION_LDT', RecSaleHeader."Sell-to Customer No.");
                            AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID', RecSaleLine."SBX Line LDT");
                            repeat
                                AddElement(XMLNodeLDT, 'PR', XMLNodePR);
                                AddAttribute(XMLNodePR, 'LIGNE_DT_ID', RecSaleLine."SBX Line LDT");
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
                                // [FIX-1] RecSaleLine2 remplacé par RecSaleLine
                                AddAttribute(XMLNodePR, 'PRIXHT',
                                    Format(RecSaleLine."Unit Price" * (1 - RecSaleLine."Line Discount %" / 100),
                                        0, '<Precision,2:2><Standard Format,2>'));
                                AddAttribute(XMLNodePR, 'PRIXTTC',
                                    Format(RecSaleLine."Unit Price" * (1 - RecSaleLine."Line Discount %" / 100)
                                        * (1 + RecSaleLine."VAT %" / 100),
                                        0, '<Precision,2:2><Standard Format,2>'));
                            until RecSaleLine.Next() = 0;
                        end;
                        // VEHICULE se ferme ici → après LDT/PR ✅
                    end;

                end else begin
                    AddAttribute(XMLRoot, 'Code', '99');
                    AddAttribute(XMLRoot, 'TexteDMS', 'Dossier non trouve');
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', Format(DOSSIER_DMS_ID_Attribute.Value()));
                end;


                // ── APV : Ordre de réparation ─────────────────────────
            end else begin
                RecServiceHeader.Reset();
                RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                RecServiceHeader.SetRange("No.", Format(DOSSIER_DMS_ID_Attribute.Value()));
                if RecServiceHeader.FindFirst() then begin

                    // Calcul heure RDV depuis Order Time
                    Milliseconds := RecServiceHeader."Order Time" - 000000T;
                    Hours := Milliseconds div 1000 div 60 div 60;
                    Milliseconds -= Hours * 1000 * 60 * 60;
                    Minutes := Milliseconds div 1000 div 60;
                    Milliseconds -= Minutes * 1000 * 60;
                    Seconds := Milliseconds div 1000;

                    // [FIX-2] Heure restitution depuis Pickup Time
                    HoursRestit := Hours;
                    MinutesRestit := Minutes;
                    if RecServiceHeader."Order Time" <> 0T then begin
                        Milliseconds := RecServiceHeader."Order Time" - 000000T;
                        HoursRestit := Milliseconds div 1000 div 60 div 60;
                        Milliseconds -= HoursRestit * 1000 * 60 * 60;
                        MinutesRestit := Milliseconds div 1000 div 60;
                    end;

                    // ── LZRF51 attributs complets [ADD-1] ────────
                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");
                    AddAttribute(XMLRoot, 'TexteDMS', '');
                    // [FIX-5] Statut dynamique
                    /* if RecServiceHeader.Status < RecServiceHeader.Status::"Partly Invoiced" then
                        AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1')
                    else */
                    AddAttribute(XMLRoot, 'ETATDOSSIERDMS', '1');
                    AddAttribute(XMLRoot, 'RDV_DMS_ID', RecServiceHeader."No.");
                    AddAttribute(XMLRoot, 'ANNEERDV', Format(Date2DMY(RecServiceHeader."Order Date", 3)));
                    AddAttribute(XMLRoot, 'MOISRDV', Format(Date2DMY(RecServiceHeader."Order Date", 2)));
                    AddAttribute(XMLRoot, 'JOURRDV', Format(Date2DMY(RecServiceHeader."Order Date", 1)));
                    AddAttribute(XMLRoot, 'HEURESRDV', Format(Hours));
                    AddAttribute(XMLRoot, 'MINUTESRDV', Format(Minutes));
                    AddAttribute(XMLRoot, 'TPSIMMO', '');//Format(RecServiceHeader.TPSIMMO));      // [ADD-1]
                    AddAttribute(XMLRoot, 'EQUIPE', '');
                    // [FIX-3] Date restitution depuis Pickup Date
                    if RecServiceHeader."Order Date" <> 0D then begin
                        AddAttribute(XMLRoot, 'ANNEERDV_RESTIT', Format(Date2DMY(RecServiceHeader."Order Date", 3)));
                        AddAttribute(XMLRoot, 'MOISRDV_RESTIT', Format(Date2DMY(RecServiceHeader."Order Date", 2)));
                        AddAttribute(XMLRoot, 'JOURRDV_RESTIT', Format(Date2DMY(RecServiceHeader."Order Date", 1)));
                    end else begin
                        AddAttribute(XMLRoot, 'ANNEERDV_RESTIT', '');
                        AddAttribute(XMLRoot, 'MOISRDV_RESTIT', '');
                        AddAttribute(XMLRoot, 'JOURRDV_RESTIT', '');
                    end;
                    AddAttribute(XMLRoot, 'HEURESRDV_RESTIT', Format(HoursRestit));
                    AddAttribute(XMLRoot, 'MINUTESRDV_RESTIT', Format(MinutesRestit));
                    AddAttribute(XMLRoot, 'RETOURATELIER', '');                              // [ADD-1]
                    AddAttribute(XMLRoot, 'RemiseDossier', '');                              // [ADD-1]
                    AddAttribute(XMLRoot, 'MotifRemise', '');                                // [ADD-1]
                    AddAttribute(XMLRoot, 'NUMEROCARTEDEREPERAGE', '');                      // [ADD-1] V14
                    AddAttribute(XMLRoot, 'MARQUE_RECEP', '');                               // [ADD-1] V14
                    AddAttribute(XMLRoot, 'SIGNATURE_NUMERIQUE', '');                        // [ADD-1] V14

                    // ── CLIENT complet [ADD-2] ────────────────────
                    RecCustomer.Reset();
                    RecCustomer.SetFilter("No.", '%1', RecServiceHeader."Sell-to Customer No.");
                    if RecCustomer.FindFirst() then begin
                        AddElement(XMLRoot, 'CLIENT', XMLNode);
                        AddAttribute(XMLNode, 'CLIENT_DMS_ID', RecCustomer."No.");
                        AddAttribute(XMLNode, 'TypeClient', Format(RecCustomer."Partner Type"));
                        AddAttribute(XMLNode, 'Nom', RecCustomer.Name);
                        AddAttribute(XMLNode, 'Prenom', RecCustomer."Name 2");
                        AddAttribute(XMLNode, 'PhoneMobile', RecCustomer."Mobile Phone No.");
                        AddAttribute(XMLNode, 'Email', RecCustomer."E-Mail");
                        AddAttribute(XMLNode, 'TypeEntreprise', RecCustomer."DLT function code");
                        AddAttribute(XMLNode, 'RaisonSociale', RecCustomer.Name);
                        AddAttribute(XMLNode, 'NumeroVoie', '');
                        AddAttribute(XMLNode, 'TypeVoie', '');
                        AddAttribute(XMLNode, 'Adresse1', RecCustomer.Address);
                        AddAttribute(XMLNode, 'Adresse2', RecCustomer."Address 2");
                        AddAttribute(XMLNode, 'Adresse3', '');
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

                    // ── VEHICULE complet [ADD-3] + LDT enfants [FIX-6] ──
                    RecVehicle.Reset();
                    RecVehicle.SetFilter(VIN, '%1', RecServiceHeader.VIN);
                    if RecVehicle.FindFirst() then begin
                        AddElement(XMLRoot, 'VEHICULE', XMLNodeVehicule);
                        AddAttribute(XMLNodeVehicule, 'VEHICULE_DMS_ID', RecVehicle.VIN);
                        AddAttribute(XMLNodeVehicule, 'LibelleMarque', RecVehicle."Make Code");
                        AddAttribute(XMLNodeVehicule, 'LibelleModele', RecVehicle."Model Code");
                        AddAttribute(XMLNodeVehicule, 'VIN_WMI', CopyStr(RecVehicle.VIN, 1, 3));
                        AddAttribute(XMLNodeVehicule, 'VIN_VDS', CopyStr(RecVehicle.VIN, 4, 6));
                        AddAttribute(XMLNodeVehicule, 'VIN_VIS', CopyStr(RecVehicle.VIN, 10, 8));
                        AddAttribute(XMLNodeVehicule, 'Immatriculation', RecVehicle."Registration No.");
                        if RecVehicle."First Registration Date" <> 0D then begin
                            AddAttribute(XMLNodeVehicule, 'AnneeMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 3)));
                            AddAttribute(XMLNodeVehicule, 'MoisMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 2)));
                            AddAttribute(XMLNodeVehicule, 'JourMiseCirculation', Format(Date2DMY(RecVehicle."First Registration Date", 1)));
                        end else begin
                            AddAttribute(XMLNodeVehicule, 'AnneeMiseCirculation', '');
                            AddAttribute(XMLNodeVehicule, 'MoisMiseCirculation', '');
                            AddAttribute(XMLNodeVehicule, 'JourMiseCirculation', '');
                        end;
                        AddAttribute(XMLNodeVehicule, 'DernierKilometrage', Format(RecVehicle."Variable Field Run 1", 0, '<Standard Format,2>'));
                        AddAttribute(XMLNodeVehicule, 'CodeOPB', '');
                        AddAttribute(XMLNodeVehicule, 'TypeEntretien', '');

                        // LDT : Lignes affectées à un Job — enfant de VEHICULE
                        RecServiceJobLine.Reset();
                        RecServiceJobLine.SetFilter("Document Type", '%1', RecServiceHeader."Document Type");
                        RecServiceJobLine.SetFilter("Document No.", '%1', RecServiceHeader."No.");
                        if RecServiceJobLine.FindFirst() then
                            repeat
                                AddElement(XMLNodeVehicule, 'LDT', XMLNodeLDT);
                                AddAttribute(XMLNodeLDT, TypeXX + '_LDT',
                                    Format(CheckTypeImputationByCustomer(RecServiceJobLine."Bill-to Customer No.")));
                                AddAttribute(XMLNodeLDT, 'CODEIMPUTATION_LDT', RecServiceJobLine."Bill-to Customer No.");
                                AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID', RecServiceJobLine.Commentaire);
                                AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));
                                if RecServiceJobLine."Package No." <> '' then
                                    AddAttribute(XMLNodeLDT, 'ReferenceFF', RecServiceJobLine."Package No.")
                                else
                                    AddAttribute(XMLNodeLDT, 'ReferenceFF', '');
                                if RecServiceJobLine."Package No." <> '' then begin
                                    if RecServiceJobLine."Package Type" = RecServiceJobLine."Package Type"::SBOX then
                                        AddAttribute(XMLNodeLDT, 'TYPEFORFAIT', '1')
                                    else
                                        AddAttribute(XMLNodeLDT, 'TYPEFORFAIT', '2');
                                end else
                                    AddAttribute(XMLNodeLDT, 'TYPEFORFAIT', '');
                                if RecServiceJobLine.Commentaire <> '' then
                                    AddAttribute(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL', RecServiceJobLine.Commentaire)
                                else
                                    AddAttribute(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL', 'Vide');
                                AddAttribute(XMLNodeLDT, 'COMMENTAIRES_LDT', '');
                                AddAttribute(XMLNodeLDT, 'ACCORD_CLIENT', '');
                                AddAttribute(XMLNodeLDT, 'PRIXHT_LDT', '');                  // [ADD-4]
                                AddAttribute(XMLNodeLDT, 'PRIXTTC_LDT', '');                 // [ADD-4]
                                AddAttribute(XMLNodeLDT, 'RemisePreFac', '');                // [ADD-4]
                                AddAttribute(XMLNodeLDT, 'DOSSIER_SAGAI', '');              // [ADD-4]
                                AddAttribute(XMLNodeLDT, 'Taux_TVA', '');                   // [ADD-4] V14

                                RecServiceLine.Reset();
                                RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
                                RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
                                RecServiceLine.SetRange("DLT Instruction Line", RecServiceJobLine."Task No.");
                                if RecServiceLine.FindFirst() then
                                    repeat
                                        if RecServiceLine.Type = RecServiceLine.Type::Labor then begin
                                            AddElement(XMLNodeLDT, 'MO', XMLNodeMO);
                                            AddAttribute(XMLNodeMO, 'LIGNE_DT_ID', RecServiceJobLine."Instruction Code");
                                            AddAttribute(XMLNodeMO, 'LIGNE_DT_ID_DMS', Format(RecServiceLine."Line No."));
                                            AddAttribute(XMLNodeMO, TypeXX + '_MO', '');
                                            AddAttribute(XMLNodeMO, 'CODEIMPUTATION_MO', RecServiceLine."Bill-to Customer No.");
                                            if RecServiceLine."SBX SBOX MO" <> '' then
                                                AddAttribute(XMLNodeMO, 'CODEOPERATION', RecServiceLine."SBX SBOX MO")
                                            else begin
                                                if RecServiceLabor.Get(RecServiceLine."No.") then
                                                    AddAttribute(XMLNodeMO, 'CODEOPERATION', RecServiceLabor."STF No.")
                                                else
                                                    AddAttribute(XMLNodeMO, 'CODEOPERATION', RecServiceLine."No.");
                                            end;
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
                                            AddAttribute(XMLNodeMO, 'SOLD_SAGAI', '');
                                            AddAttribute(XMLNodeMO, 'Taux_TVA', '');        // V14
                                        end;
                                        if RecServiceLine.Type = RecServiceLine.Type::Item then begin
                                            AddElement(XMLNodeLDT, 'PR', XMLNodePR);
                                            AddAttribute(XMLNodePR, 'LIGNE_DT_ID', RecServiceJobLine."Instruction Code");
                                            AddAttribute(XMLNodePR, 'LIGNE_DT_ID_DMS', Format(RecServiceLine."Line No."));
                                            AddAttribute(XMLNodePR, TypeXX + '_PR', '');
                                            AddAttribute(XMLNodePR, 'CODEIMPUTATIONDMS_PR', RecServiceLine."Bill-to Customer No."); // [ADD-5]
                                            AddAttribute(XMLNodePR, 'TYPEFACTURATION_PR', '1');  // [ADD-5]
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
                                            AddAttribute(XMLNodePR, 'SOMME_SAGAI', '');     // [ADD-5]
                                            AddAttribute(XMLNodePR, 'Taux_TVA',
                                                Format(RecServiceLine."VAT %", 0, '<Precision,2:2><Standard Format,2>')); // [ADD-5] V14
                                        end;
                                    until RecServiceLine.Next() = 0;
                            until RecServiceJobLine.Next() = 0;

                        // LDT "A Classer" — enfant de VEHICULE
                        AddElement(XMLNodeVehicule, 'LDT', XMLNodeLDT);
                        AddAttribute(XMLNodeLDT, TypeXX + '_LDT',
                            Format(CheckTypeImputationByCustomer(RecServiceLine."Bill-to Customer No.")));
                        AddAttribute(XMLNodeLDT, 'CODEIMPUTATION_LDT', RecServiceLine."Bill-to Customer No.");
                        AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID', '');
                        AddAttribute(XMLNodeLDT, 'LIGNE_DT_ID_DMS', '');
                        AddAttribute(XMLNodeLDT, 'ReferenceFF', '');
                        AddAttribute(XMLNodeLDT, 'TYPEFORFAIT', '');
                        AddAttribute(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL', 'A Classer');
                        AddAttribute(XMLNodeLDT, 'COMMENTAIRES_LDT', '');
                        AddAttribute(XMLNodeLDT, 'ACCORD_CLIENT', '');
                        AddAttribute(XMLNodeLDT, 'PRIXHT_LDT', '');
                        AddAttribute(XMLNodeLDT, 'PRIXTTC_LDT', '');
                        AddAttribute(XMLNodeLDT, 'RemisePreFac', '');
                        AddAttribute(XMLNodeLDT, 'DOSSIER_SAGAI', '');
                        AddAttribute(XMLNodeLDT, 'Taux_TVA', '');

                        RecServiceLine.Reset();
                        RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
                        RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
                        RecServiceLine.SetRange("DLT Instruction Line", 0);
                        if RecServiceLine.FindFirst() then
                            repeat
                                if RecServiceLine.Type = RecServiceLine.Type::Labor then begin
                                    AddElement(XMLNodeLDT, 'MO', XMLNodeMO);
                                    AddAttribute(XMLNodeMO, 'LIGNE_DT_ID', '');
                                    AddAttribute(XMLNodeMO, 'LIGNE_DT_ID_DMS', '');
                                    AddAttribute(XMLNodeMO, TypeXX + '_MO',
                                        Format(CheckTypeImputationByCustomer(RecServiceLine."Bill-to Customer No.")));
                                    AddAttribute(XMLNodeMO, 'CODEIMPUTATION_MO', RecServiceLine."Bill-to Customer No.");
                                    if RecServiceLabor.Get(RecServiceLine."No.") then
                                        AddAttribute(XMLNodeMO, 'CODEOPERATION', RecServiceLabor."STF No.")
                                    else
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
                                    AddAttribute(XMLNodeMO, 'SOLD_SAGAI', '');
                                    AddAttribute(XMLNodeMO, 'Taux_TVA', '');
                                end;
                                if RecServiceLine.Type = RecServiceLine.Type::Item then begin
                                    AddElement(XMLNodeLDT, 'PR', XMLNodePR);
                                    AddAttribute(XMLNodePR, 'LIGNE_DT_ID', '');
                                    AddAttribute(XMLNodePR, 'LIGNE_DT_ID_DMS', '');
                                    AddAttribute(XMLNodePR, TypeXX + '_PR', '');
                                    AddAttribute(XMLNodePR, 'CODEIMPUTATIONDMS_PR', RecServiceLine."Bill-to Customer No."); // [ADD-5]
                                    AddAttribute(XMLNodePR, 'TYPEFACTURATION_PR', '1');      // [ADD-5]
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
                                    AddAttribute(XMLNodePR, 'SOMME_SAGAI', '');              // [ADD-5]
                                    AddAttribute(XMLNodePR, 'Taux_TVA',
                                        Format(RecServiceLine."VAT %", 0, '<Precision,2:2><Standard Format,2>')); // [ADD-5] V14
                                end;
                            until RecServiceLine.Next() = 0;

                        // VEHICULE se ferme ici → après tous les LDT ✅
                    end;

                end else begin
                    AddAttribute(XMLRoot, 'Code', '99');
                    AddAttribute(XMLRoot, 'TexteDMS', 'Dossier non trouve');
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', Format(DOSSIER_DMS_ID_Attribute.Value()));
                end;
            end; // fin else APV

            // ─────────────────────────────────────────────────────────
            // CAS 4 — Liste des dossiers (30 max)
            // ─────────────────────────────────────────────────────────
        end else if Format(CODE_INTERR_DMS_Attribute.Value()) = '4' then begin
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
                    AddAttribute(XMLNode, 'RDV_DMS_ID', '');
                    Count += 1;
                until (RecServiceHeader.Next() = 0) or (Count = 30);

            // ─────────────────────────────────────────────────────────
            // CAS INCONNU
            // ─────────────────────────────────────────────────────────
        end else begin
            AddAttribute(XMLRoot, 'Code', '99');
            AddAttribute(XMLRoot, 'TexteDMS', 'Code interrogation inconnu');
        end;
    end;

    procedure CheckTypeImputationByCustomer(lClient: Code[20]): Integer
    var
        SBOXSetup: Record "STF Servicebox Setup";
    begin
        if not SBOXSetup.Get() then
            Error('Le paramétrage SBOX est manquant.');

        case lClient of
            SBOXSetup."SBX Warranty Imputation Account":
                exit(SBOXSetup."SBX Warranty Imputation Code");

            SBOXSetup."SBX Insurance Imputation Account":
                exit(SBOXSetup."SBX Insurance Imputation Code");

            SBOXSetup."SBX Campaign Imputation Account":
                exit(SBOXSetup."SBX Campaign Imputation Code");

            SBOXSetup."SBX Contract Imputation Account":
                exit(SBOXSetup."SBX Contract Imputation Code");

            SBOXSetup."SBX Internal Imputation Account":
                exit(SBOXSetup."SBX Internal Imputation Code");

            else
                exit(SBOXSetup."SBX Customer Imputation Code");
        end;
    end;


    procedure LZRF08T11V1(
        XMLNodeReq: XmlElement;
        var XMLDms: XmlElement;
        DMSRoot: XmlElement)
    var
        XmlNodesPR: XmlNodeList;
        XmlNodePR: XmlNode;
        CODEIMPUTATIONDMS_PR: Code[20];
        LIGNE_DT_ID: Code[20];
        XMLRoot08: XmlElement;
        XMLRoot46: XmlElement;
        ProcessedItems: Dictionary of [Text, Boolean];
        ItemKey: Text;
        i: Integer;
    begin
        if not XMLNodeReq.SelectNodes('PR', XmlNodesPR) then
            exit;
        if XmlNodesPR.Count = 0 then
            exit;

        XMLRoot08 := XmlElement.Create('LZRF08');
        XMLRoot08.SetAttribute('Code', '0');
        XMLRoot08.SetAttribute('TexteDMS', '');

        XMLRoot46 := XmlElement.Create('LZRF46');
        XMLRoot46.SetAttribute('Code', '0');
        XMLRoot46.SetAttribute('TexteDMS', '');

        CODEIMPUTATIONDMS_PR := GetAttributeValue(DMSRoot, 'CLIENT_DMS_ID');

        for i := 1 to XmlNodesPR.Count do begin
            XmlNodesPR.Get(i, XmlNodePR);

            LIGNE_DT_ID := GetAttributeValue(XmlNodePR.AsXmlElement(), 'LIGNE_DT_ID');

            // ✅ Clé de dédup : une seule fois par référence + LIGNE_DT_ID
            ItemKey := GetAttributeValue(XmlNodePR.AsXmlElement(), 'REFERENCE_PR') + '|' + LIGNE_DT_ID;

            if not ProcessedItems.ContainsKey(ItemKey) then begin
                ProcessedItems.Add(ItemKey, true);

                LZRF08_PR(
                    XMLRoot08,
                    XMLRoot46,
                    GetAttributeValue(XmlNodePR.AsXmlElement(), 'REFERENCE_PR'),
                    CODEIMPUTATIONDMS_PR,
                    LIGNE_DT_ID,
                    ProcessedItems);
            end;
        end;

        XMLDms.Add(XMLRoot08);
        XMLDms.Add(XMLRoot46);
    end;

    // ============================================================

    procedure LZRF08_PR(
        var XMLRoot08: XmlElement;
        var XMLRoot46: XmlElement;
        Item_Ref: Code[20];
        CODEIMPUTATIONDMS_PR: Code[20];
        LIGNE_DT_ID: Code[20];
        var ProcessedItems: Dictionary of [Text, Boolean])
    var
        RecItem: Record Item;
        RecNewItem: Record Item;
        ItemSubstitution: Record "Item Substitution";
        ItemKey: Text;
    begin
        RecItem.Reset();
        RecItem.SetRange("No.", GetItemNo(Item_Ref));
        RecItem.SetRange(Blocked, false);

        if not RecItem.FindFirst() then begin
            HandleBlockedOrMissingItem(
                XMLRoot08,
                XMLRoot46,
                Item_Ref,
                CODEIMPUTATIONDMS_PR,
                LIGNE_DT_ID);
            exit;
        end;

        // ── Article original : stock par LIGNE_DT_ID ──────────────────
        ItemKey := RecItem."No." + '|ORIGINAL';

        if not ProcessedItems.ContainsKey(ItemKey) then begin
            ProcessedItems.Add(ItemKey, true);

            AddPRLineAllLocations(
                XMLRoot08,
                RecItem,
                Item_Ref,
                '0',
                '',
                0,
                LIGNE_DT_ID);
        end;

        // ── Prix article original : une seule fois toutes lignes confondues ──
        if not ProcessedItems.ContainsKey(RecItem."No." + '|PRIX') then begin
            ProcessedItems.Add(RecItem."No." + '|PRIX', true);
            AddPRPriceLine(
                XMLRoot46,
                RecItem,
                CODEIMPUTATIONDMS_PR,
                LIGNE_DT_ID);
        end;

        // ── Substitutions ─────────────────────────────────────────────
        ItemSubstitution.Reset();
        ItemSubstitution.SetRange(Type, ItemSubstitution.Type::"Nonstock Item");
        ItemSubstitution.SetRange("No.", RecItem."No.");

        if ItemSubstitution.FindSet() then
            repeat
                if RecNewItem.Get(ItemSubstitution."Substitute No.") then begin

                    if RecNewItem."No." <> RecItem."No." then begin

                        // ── Stock substitut par LIGNE_DT_ID ───────────
                        ItemKey := RecNewItem."No." + '|SUB';
                        if not ProcessedItems.ContainsKey(ItemKey) then begin
                            ProcessedItems.Add(ItemKey, true);

                            AddPRLineAllLocations(
                                XMLRoot08,
                                RecNewItem,
                                Item_Ref,
                                '2',
                                RecItem."No.",
                                1,
                                LIGNE_DT_ID);
                        end;

                        // ── Prix substitut : une seule fois ───────────
                        if not ProcessedItems.ContainsKey(RecNewItem."No." + '|PRIX') then begin
                            ProcessedItems.Add(RecNewItem."No." + '|PRIX', true);

                            AddPRPriceLine(
                                XMLRoot46,
                                RecNewItem,
                                CODEIMPUTATIONDMS_PR,
                                LIGNE_DT_ID);
                        end;

                    end;
                end;
            until ItemSubstitution.Next() = 0;
    end;

    // ============================================================

    local procedure AddPRLineAllLocations1(
        var XMLRoot: XmlElement;
        RecItem: Record Item;
        Item_Ref: Code[20];
        CodePR: Code[10];
        ReferenceInitial: Code[20];
        Coefficient: Decimal;
        LIGNE_DT_ID: Code[20])
    var
        Location: Record Location;
        ItemPerLoc: Record Item;
        XMLNode: XmlElement;
        QtyLocation: Decimal;
    begin
        RecItem.CalcFields("Qty. on Sales Order", "Reserved Qty. on Inventory");

        Location.Reset();
        Location.SetRange("DLT Exclude From Inventory", false);
        Location.SetRange("Use As Parts Location Code", true);
        Location.SetRange("SBX Display in Service BOX", true);
        if Location.FindSet() then
            repeat
                ItemPerLoc.Reset();
                ItemPerLoc.SetRange("No.", RecItem."No.");
                ItemPerLoc.SetRange("Location Filter", Location.Code);
                ItemPerLoc.CalcFields(Inventory, "STF Available Inventory");

                QtyLocation := ItemPerLoc."STF Available Inventory";

                AddElement(XMLRoot, 'PR', XMLNode);

                XMLNode.SetAttribute('ReferencePR', SetItemNo(RecItem."No."));
                XMLNode.SetAttribute('CODE_PR', CodePR);
                XMLNode.SetAttribute('idStockDMS', Location.Code);
                XMLNode.SetAttribute('QuantiteDisponible',
                    Format(QtyLocation, 0, '<Precision,2:2><Standard Format,2>'));
                XMLNode.SetAttribute('LibellePR', RecItem.Description);
                XMLNode.SetAttribute('LieuDeStockage', RecItem."Shelf No.");
                XMLNode.SetAttribute('QuantiteEnCommande',
                    Format(RecItem."Qty. on Sales Order",
                        0, '<Precision,2:2><Standard Format,2>'));
                XMLNode.SetAttribute('QuantiteReserveeSurLeStock',
                    Format(RecItem."Reserved Qty. on Inventory",
                        0, '<Precision,2:2><Standard Format,2>'));
                XMLNode.SetAttribute('QuantiteUV', '');
                XMLNode.SetAttribute('ReferencePRInitial', ReferenceInitial);
                XMLNode.SetAttribute('WR_STOCK_PLACE', RecItem."Shelf No.");
                XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);

                if Coefficient <> 0 then
                    XMLNode.SetAttribute('CoefficientDeRemplacement',
                        Format(Coefficient, 0, '<Precision,2:2><Standard Format,2>'));

            until Location.Next() = 0;
    end;


    local procedure AddPRLineAllLocationsLV(
        var XMLRoot: XmlElement;
        RecItem: Record Item;
        Item_Ref: Code[20];
        CodePR: Code[10];
        ReferenceInitial: Code[20];
        Coefficient: Decimal;
        LIGNE_DT_ID: Code[20])
    var
        Location: Record Location;
        LocationParent: Record Location;
        ItemPerLoc: Record Item;
        ItemParentPerLoc: Record Item;
        XMLNode: XmlElement;
        CompanyInformation: Record "Company Information";
        QtyLocation: Decimal;
        ParentCompany: Text[30];
    begin
        // Calcul des FlowFields globaux
        RecItem.CalcFields("Qty. on Sales Order", "Reserved Qty. on Inventory");

        // Société parente
        CompanyInformation.Get();
        ParentCompany := CompanyInformation."DLT Parent Company";

        // ============================================================
        // Société courante
        // ============================================================
        Location.Reset();
        Location.SetRange("DLT Exclude From Inventory", false);
        Location.SetRange("Use As Parts Location Code", true);
        Location.SetRange("SBX Display in Service BOX", true);

        if Location.FindSet() then
            repeat

                QtyLocation := 0;

                ItemPerLoc.Reset();
                ItemPerLoc.SetRange("No.", RecItem."No.");

                if ItemPerLoc.FindFirst() then begin

                    // FlowFilters
                    ItemPerLoc.SetRange("Location Filter", Location.Code);
                    ItemPerLoc.SetRange("Date Filter", 0D, Today);

                    // Calcul du FlowField
                    ItemPerLoc.CalcFields("STF Available Inventory");

                    QtyLocation := ItemPerLoc."STF Available Inventory";
                end;

                AddElement(XMLRoot, 'PR', XMLNode);

                XMLNode.SetAttribute('ReferencePR', SetItemNo(RecItem."No."));
                XMLNode.SetAttribute('CODE_PR', CodePR);
                XMLNode.SetAttribute('idStockDMS', Location.Code);

                XMLNode.SetAttribute(
                    'QuantiteDisponible',
                    Format(QtyLocation, 0, '<Precision,2:2><Standard Format,2>')
                );

                XMLNode.SetAttribute('LibellePR', RecItem.Description);
                XMLNode.SetAttribute('LieuDeStockage', RecItem."Shelf No.");

                XMLNode.SetAttribute(
                    'QuantiteEnCommande',
                    Format(
                        RecItem."Qty. on Sales Order",
                        0,
                        '<Precision,2:2><Standard Format,2>'
                    )
                );

                XMLNode.SetAttribute(
                    'QuantiteReserveeSurLeStock',
                    Format(
                        RecItem."Reserved Qty. on Inventory",
                        0,
                        '<Precision,2:2><Standard Format,2>'
                    )
                );

                XMLNode.SetAttribute('QuantiteUV', '');
                XMLNode.SetAttribute('ReferencePRInitial', ReferenceInitial);
                XMLNode.SetAttribute('WR_STOCK_PLACE', 'j');
                XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);

                if Coefficient <> 0 then
                    XMLNode.SetAttribute(
                        'CoefficientDeRemplacement',
                        Format(
                            Coefficient,
                            0,
                            '<Precision,2:2><Standard Format,2>'
                        )
                    );

            until Location.Next() = 0;

        // ============================================================
        // Société parente
        // ============================================================
        if ParentCompany <> '' then begin

            LocationParent.ChangeCompany(ParentCompany);

            LocationParent.Reset();
            LocationParent.SetRange("DLT Exclude From Inventory", false);
            LocationParent.SetRange("Use As Parts Location Code", true);
            LocationParent.SetRange("SBX Display in Service BOX", true);

            if LocationParent.FindSet() then
                repeat

                    QtyLocation := 0;

                    ItemParentPerLoc.ChangeCompany(ParentCompany);
                    ItemParentPerLoc.Reset();
                    ItemParentPerLoc.SetRange("No.", RecItem."No.");

                    if ItemParentPerLoc.FindFirst() then begin

                        // FlowFilters
                        ItemParentPerLoc.SetRange("Location Filter", LocationParent.Code);
                        ItemParentPerLoc.SetRange("Date Filter", 0D, Today);

                        // Calcul FlowField
                        ItemParentPerLoc.CalcFields("STF Available Inventory");

                        QtyLocation := ItemParentPerLoc."STF Available Inventory";
                    end;

                    AddElement(XMLRoot, 'PR', XMLNode);

                    XMLNode.SetAttribute('ReferencePR', SetItemNo(RecItem."No."));
                    XMLNode.SetAttribute('CODE_PR', CodePR);
                    XMLNode.SetAttribute('idStockDMS', LocationParent.Code);

                    XMLNode.SetAttribute(
                        'QuantiteDisponible',
                        Format(QtyLocation, 0, '<Precision,2:2><Standard Format,2>')
                    );

                    XMLNode.SetAttribute('LibellePR', RecItem.Description);
                    XMLNode.SetAttribute('LieuDeStockage', RecItem."Shelf No.");

                    XMLNode.SetAttribute(
                        'QuantiteEnCommande',
                        Format(
                            RecItem."Qty. on Sales Order",
                            0,
                            '<Precision,2:2><Standard Format,2>'
                        )
                    );

                    XMLNode.SetAttribute(
                        'QuantiteReserveeSurLeStock',
                        Format(
                            RecItem."Reserved Qty. on Inventory",
                            0,
                            '<Precision,2:2><Standard Format,2>'
                        )
                    );

                    XMLNode.SetAttribute('QuantiteUV', '');
                    XMLNode.SetAttribute('ReferencePRInitial', ReferenceInitial);
                    XMLNode.SetAttribute('WR_STOCK_PLACE', RecItem."Shelf No.");
                    XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);

                    if Coefficient <> 0 then
                        XMLNode.SetAttribute(
                            'CoefficientDeRemplacement',
                            Format(
                                Coefficient,
                                0,
                                '<Precision,2:2><Standard Format,2>'
                            )
                        );

                until LocationParent.Next() = 0;
        end;
    end;

    local procedure AddPRLineAllLocations(
            var XMLRoot: XmlElement;
            RecItem: Record Item;
            Item_Ref: Code[20];
            CodePR: Code[10];
            ReferenceInitial: Code[20];
            Coefficient: Decimal;
            LIGNE_DT_ID: Code[20])
    var
        Location: Record Location;
        LocationParent: Record Location;
        ItemPerLoc: Record Item;
        ItemParentPerLoc: Record Item;
        XMLNode: XmlElement;
        CompanyInformation: Record "Company Information";
        QtyLocation: Decimal;
        ParentCompany: Text[30];
        BinCode: Code[20];          // ✅ ajout
    begin
        RecItem.CalcFields("Qty. on Sales Order", "Reserved Qty. on Inventory");

        CompanyInformation.Get();
        ParentCompany := CompanyInformation."DLT Parent Company";

        // ============================================================
        // Société courante
        // ============================================================
        Location.Reset();
        Location.SetRange("DLT Exclude From Inventory", false);
        Location.SetRange("Use As Parts Location Code", true);
        Location.SetRange("SBX Display in Service BOX", true);

        if Location.FindSet() then
            repeat
                QtyLocation := 0;

                ItemPerLoc.Reset();
                ItemPerLoc.SetRange("No.", RecItem."No.");

                if ItemPerLoc.FindFirst() then begin
                    ItemPerLoc.SetRange("Location Filter", Location.Code);
                    ItemPerLoc.SetRange("Date Filter", 0D, Today);
                    ItemPerLoc.CalcFields("STF Available Inventory");
                    QtyLocation := ItemPerLoc."STF Available Inventory";
                end;

                // ✅ Bin Code société courante (pas de ChangeCompany)
                BinCode := GetBinCode(RecItem."No.", Location.Code, '');

                AddElement(XMLRoot, 'PR', XMLNode);

                XMLNode.SetAttribute('ReferencePR', SetItemNo(RecItem."No."));
                XMLNode.SetAttribute('CODE_PR', CodePR);
                XMLNode.SetAttribute('idStockDMS', Location.Code);
                XMLNode.SetAttribute(
                    'QuantiteDisponible',
                    Format(QtyLocation, 0, '<Precision,2:2><Standard Format,2>'));
                XMLNode.SetAttribute('LibellePR', RecItem.Description);

                // ✅ Bin Content au lieu de Shelf No.
                XMLNode.SetAttribute('LieuDeStockage', BinCode);

                XMLNode.SetAttribute(
                    'QuantiteEnCommande',
                    Format(RecItem."Qty. on Sales Order",
                        0, '<Precision,2:2><Standard Format,2>'));
                XMLNode.SetAttribute(
                    'QuantiteReserveeSurLeStock',
                    Format(RecItem."Reserved Qty. on Inventory",
                        0, '<Precision,2:2><Standard Format,2>'));
                XMLNode.SetAttribute('QuantiteUV', '');
                XMLNode.SetAttribute('ReferencePRInitial', ReferenceInitial);
                XMLNode.SetAttribute('WR_STOCK_PLACE', 'j');
                XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);

                if Coefficient <> 0 then
                    XMLNode.SetAttribute(
                        'CoefficientDeRemplacement',
                        Format(Coefficient, 0, '<Precision,2:2><Standard Format,2>'));

            until Location.Next() = 0;

        // ============================================================
        // Société parente
        // ============================================================
        if ParentCompany <> '' then begin

            LocationParent.ChangeCompany(ParentCompany);
            LocationParent.Reset();
            LocationParent.SetRange("DLT Exclude From Inventory", false);
            LocationParent.SetRange("Use As Parts Location Code", true);
            LocationParent.SetRange("SBX Display in Service BOX", true);

            if LocationParent.FindSet() then
                repeat
                    QtyLocation := 0;

                    ItemParentPerLoc.ChangeCompany(ParentCompany);
                    ItemParentPerLoc.Reset();
                    ItemParentPerLoc.SetRange("No.", RecItem."No.");

                    if ItemParentPerLoc.FindFirst() then begin
                        ItemParentPerLoc.SetRange("Location Filter", LocationParent.Code);
                        ItemParentPerLoc.SetRange("Date Filter", 0D, Today);
                        ItemParentPerLoc.CalcFields("STF Available Inventory");
                        QtyLocation := ItemParentPerLoc."STF Available Inventory";
                    end;

                    // ✅ Bin Code société parente (avec ChangeCompany)
                    BinCode := GetBinCode(RecItem."No.", LocationParent.Code, ParentCompany);

                    AddElement(XMLRoot, 'PR', XMLNode);

                    XMLNode.SetAttribute('ReferencePR', SetItemNo(RecItem."No."));
                    XMLNode.SetAttribute('CODE_PR', CodePR);
                    XMLNode.SetAttribute('idStockDMS', LocationParent.Code);
                    XMLNode.SetAttribute(
                        'QuantiteDisponible',
                        Format(QtyLocation, 0, '<Precision,2:2><Standard Format,2>'));
                    XMLNode.SetAttribute('LibellePR', RecItem.Description);

                    // ✅ Bin Content au lieu de Shelf No.
                    XMLNode.SetAttribute('LieuDeStockage', BinCode);

                    XMLNode.SetAttribute(
                        'QuantiteEnCommande',
                        Format(RecItem."Qty. on Sales Order",
                            0, '<Precision,2:2><Standard Format,2>'));
                    XMLNode.SetAttribute(
                        'QuantiteReserveeSurLeStock',
                        Format(RecItem."Reserved Qty. on Inventory",
                            0, '<Precision,2:2><Standard Format,2>'));
                    XMLNode.SetAttribute('QuantiteUV', '');
                    XMLNode.SetAttribute('ReferencePRInitial', ReferenceInitial);

                    // ✅ Bin Content au lieu de Shelf No.
                    XMLNode.SetAttribute('WR_STOCK_PLACE', BinCode);

                    XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);

                    if Coefficient <> 0 then
                        XMLNode.SetAttribute(
                            'CoefficientDeRemplacement',
                            Format(Coefficient, 0, '<Precision,2:2><Standard Format,2>'));

                until LocationParent.Next() = 0;
        end;
    end;

    local procedure GetBinCode(
    ItemNo: Code[20];
    LocationCode: Code[10];
    CompanyName: Text[30]): Code[20]
    var
        BinContent: Record "Bin Content";
    begin
        if CompanyName <> '' then
            BinContent.ChangeCompany(CompanyName);

        BinContent.SetRange("Item No.", ItemNo);
        BinContent.SetRange("Location Code", LocationCode);
        BinContent.SetRange(Default, true); // Bin par défaut en premier

        if BinContent.FindFirst() then
            exit(BinContent."Bin Code");

        // Fallback : premier bin trouvé sans filtre Default
        BinContent.SetRange(Default);
        if BinContent.FindFirst() then
            exit(BinContent."Bin Code");

        exit(''); // Aucun bin trouvé
    end;
    // ============================================================
    // LZRF08_PR
    // Paramètres :
    //   XMLRoot08 → reçoit les lignes <PR stock>
    //   XMLRoot46 → reçoit les lignes <PR prix>
    // ============================================================
    procedure LZRF08_PRLV(
        var XMLRoot08: XmlElement;
        var XMLRoot46: XmlElement;
        Item_Ref: Code[20];
        CODEIMPUTATIONDMS_PR: Code[20];
        LIGNE_DT_ID: Code[20])
    var
        RecItem: Record Item;
        RecNewItem: Record Item;
        DLTReplenishment: Codeunit "DLT Replenishment";
        NewItemNo: Code[20];
        ReplacementChain: Text[250];
        Coefficient: Decimal;
    begin
        RecItem.Reset();
        RecItem.SetRange("No.", GetItemNo(Item_Ref));
        RecItem.SetRange(Blocked, false);

        if RecItem.FindFirst() then begin

            case RecItem."Replacement Status" of

                // ── Article normal ─────────────────────────────────────────
                RecItem."Replacement Status"::" ":
                    begin
                        // Stock → dans LZRF08
                        AddPRLineAllLocations(
                            XMLRoot08, RecItem, Item_Ref, '0', '', 0, LIGNE_DT_ID);
                        // Prix → dans LZRF46
                        AddPRPriceLine(
                            XMLRoot46, RecItem, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
                    end;

                // ── Article remplacé ───────────────────────────────────────
                RecItem."Replacement Status"::Replaced:
                    begin
                        // Ancien article : stock + prix
                        AddPRLineAllLocations(
                            XMLRoot08, RecItem, Item_Ref, '0', '', 0, LIGNE_DT_ID);
                        AddPRPriceLine(
                            XMLRoot46, RecItem, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);

                        // Article de remplacement : stock + prix
                        ReplacementChain := '';
                        NewItemNo := DLTReplenishment.GetLastReplacement(
                            0, RecItem."No.", '', ReplacementChain, false);

                        if (NewItemNo <> '') and RecNewItem.Get(NewItemNo) then begin
                            Coefficient := GetReplacementCoefficient(
                                DLTReplenishment, RecItem."No.", NewItemNo);

                            AddPRLineAllLocations(
                                XMLRoot08, RecNewItem, Item_Ref,
                                '2', RecItem."No.", Coefficient, LIGNE_DT_ID);
                            AddPRPriceLine(
                                XMLRoot46, RecNewItem, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
                        end;
                    end;

            end;

        end else
            HandleBlockedOrMissingItem(
                XMLRoot08, XMLRoot46, Item_Ref, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
    end;


    procedure LZRF08_PRWorks(
       var XMLRoot08: XmlElement;
       var XMLRoot46: XmlElement;
       Item_Ref: Code[20];
       CODEIMPUTATIONDMS_PR: Code[20];
       LIGNE_DT_ID: Code[20])
    var
        RecItem: Record Item;
        RecNewItem: Record Item;
        DLTReplenishment: Codeunit "DLT Replenishment";
        NewItemNo: Code[20];
        ReplacementChain: Text[250];
        Coefficient: Decimal;
    begin
        RecItem.Reset();
        RecItem.SetRange("No.", GetItemNo(Item_Ref));
        RecItem.SetRange(Blocked, false);

        if RecItem.FindFirst() then begin

            if RecItem."DLT Item Replacement No." = '' then begin
                // ── Article normal ─────────────────────────────────────────
                // Stock → dans LZRF08
                AddPRLineAllLocations(
                    XMLRoot08, RecItem, Item_Ref, '0', '', 0, LIGNE_DT_ID);
                // Prix → dans LZRF46
                AddPRPriceLine(
                    XMLRoot46, RecItem, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
            end else begin
                // ── Article remplacé ───────────────────────────────────────
                // Ancien article : stock + prix
                AddPRLineAllLocations(
                    XMLRoot08, RecItem, Item_Ref, '0', '', 0, LIGNE_DT_ID);
                AddPRPriceLine(
                    XMLRoot46, RecItem, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);

                // Article de remplacement : stock + prix
                ReplacementChain := '';
                NewItemNo := RecItem."DLT Item Replacement No.";/* DLTReplenishment.GetLastReplacement(
                    0, RecItem."No.", '', ReplacementChain, false); */

                if (NewItemNo <> '') and RecNewItem.Get(NewItemNo) then begin
                    Coefficient := GetReplacementCoefficient(
                        DLTReplenishment, RecItem."No.", NewItemNo);

                    AddPRLineAllLocations(
                        XMLRoot08, RecNewItem, Item_Ref,
                        '2', RecItem."No.", Coefficient, LIGNE_DT_ID);
                    AddPRPriceLine(
                        XMLRoot46, RecNewItem, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
                end;
            end;

        end else
            HandleBlockedOrMissingItem(
                XMLRoot08, XMLRoot46, Item_Ref, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
    end;


    // ============================================================
    // AddPRPriceLine
    // Construit les lignes prix dans LZRF46 pour un article
    //
    // LZRF46T23V1 signature : (var TempRoot, CurrentDMS, CodeImputationDMS_PR)
    // CurrentDMS doit contenir des noeuds <PR ReferencePR=... LIGNE_DT_ID=...>
    // On construit un DMS temporaire avec un <PR> puis on appelle LZRF46T23V1
    // ============================================================
    local procedure AddPRPriceLine(
     var XMLRoot46: XmlElement;
     RecItem: Record Item;
     CODEIMPUTATIONDMS_PR: Code[20];
     LIGNE_DT_ID: Code[20])
    var
        TempDMS: XmlElement;
        TempPR: XmlElement;
        TempContainer: XmlElement;    // ← conteneur neutre
        InnerLZRF46Node: XmlNode;
        ChildNode: XmlNode;
        ChildList: XmlNodeList;
        InnerChildList: XmlNodeList;
        i, j : Integer;
    begin
        // 1. Construire le <DMS> avec le <PR> à pricer
        TempDMS := XmlElement.Create('DMS');
        TempPR := XmlElement.Create('PR');
        TempPR.SetAttribute('ReferencePR', SetItemNo(RecItem."No."));
        TempPR.SetAttribute('CODE_PR', '0');
        TempPR.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);
        TempDMS.Add(TempPR);

        // 2. LZRF46T23V1 va créer un <LZRF46> et l'ajouter dans TempContainer
        TempContainer := XmlElement.Create('ROOT');
        LZRF46T23V1(TempContainer, TempDMS, CODEIMPUTATIONDMS_PR);

        // 3. Extraire les <PR> de l'intérieur du <LZRF46> créé
        //    et les déplacer directement dans XMLRoot46
        ChildList := TempContainer.GetChildNodes();
        for i := 1 to ChildList.Count do begin
            ChildList.Get(i, InnerLZRF46Node);           // c'est le <LZRF46> créé par LZRF46T23V1
            InnerChildList := InnerLZRF46Node.AsXmlElement().GetChildNodes();
            for j := 1 to InnerChildList.Count do begin
                InnerChildList.Get(j, ChildNode);
                ChildNode.Remove();
                XMLRoot46.Add(ChildNode);                // <PR> directement dans XMLRoot46
            end;
        end;
    end;
    // ============================================================
    // HandleBlockedOrMissingItem
    // Article bloqué ou inexistant → CODE_PR = '99' dans LZRF08
    // Pas de ligne prix dans LZRF46 pour les articles introuvables
    // ============================================================
    local procedure HandleBlockedOrMissingItem(
        var XMLRoot08: XmlElement;
        var XMLRoot46: XmlElement;
        Item_Ref: Code[20];
        CODEIMPUTATIONDMS_PR: Code[20];
        LIGNE_DT_ID: Code[20])
    var
        RecItem: Record Item;
        RecNewItem: Record Item;
        DLTReplenishment: Codeunit "DLT Replenishment";
        NewItemNo: Code[20];
        ReplacementChain: Text[250];
        Coefficient: Decimal;
        XMLNode: XmlElement;
    begin
        RecItem.Reset();
        RecItem.SetRange("No.", GetItemNo(Item_Ref));
        RecItem.SetRange(Blocked, true);

        if RecItem.FindFirst() and
           (RecItem."Replacement Status" = RecItem."Replacement Status"::Replaced) then begin

            // Ancien article bloqué → CODE_PR = '99'
            AddElement(XMLRoot08, 'PR', XMLNode);
            XMLNode.SetAttribute('ReferencePR', Item_Ref);
            XMLNode.SetAttribute('CODE_PR', '99');
            XMLNode.SetAttribute('idStockDMS', 'MAG_LB');
            XMLNode.SetAttribute('LibellePR', '');
            XMLNode.SetAttribute('LieuDeStockage', '');
            XMLNode.SetAttribute('QuantiteDisponible', '0.00');
            XMLNode.SetAttribute('QuantiteEnCommande', '0.00');
            XMLNode.SetAttribute('QuantiteReserveeSurLeStock', '0.00');
            XMLNode.SetAttribute('ReferencePRInitial', '');
            XMLNode.SetAttribute('WR_STOCK_PLACE', '');
            XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);

            // Remplaçant → CODE_PR = '2' + prix dans LZRF46
            ReplacementChain := '';
            NewItemNo := DLTReplenishment.GetLastReplacement(
                0, RecItem."No.", '', ReplacementChain, false);

            if (NewItemNo <> '') and RecNewItem.Get(NewItemNo) then begin
                Coefficient := GetReplacementCoefficient(
                    DLTReplenishment, RecItem."No.", NewItemNo);

                AddPRLineAllLocations(
                    XMLRoot08, RecNewItem, Item_Ref,
                    '2', RecItem."No.", Coefficient, LIGNE_DT_ID);
                AddPRPriceLine(
                    XMLRoot46, RecNewItem, CODEIMPUTATIONDMS_PR, LIGNE_DT_ID);
            end;

        end else begin
            // Article inexistant ou bloqué sans remplacement → CODE_PR = '99'
            AddElement(XMLRoot08, 'PR', XMLNode);
            XMLNode.SetAttribute('ReferencePR', Item_Ref);
            XMLNode.SetAttribute('CODE_PR', '99');
            XMLNode.SetAttribute('idStockDMS', 'MAG_LB');
            XMLNode.SetAttribute('LibellePR', '');
            XMLNode.SetAttribute('LieuDeStockage', '');
            XMLNode.SetAttribute('QuantiteDisponible', '0.00');
            XMLNode.SetAttribute('QuantiteEnCommande', '0.00');
            XMLNode.SetAttribute('QuantiteReserveeSurLeStock', '0.00');
            XMLNode.SetAttribute('ReferencePRInitial', '');
            XMLNode.SetAttribute('WR_STOCK_PLACE', '');
            XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);
        end;
    end;

    // ============================================================
    // MoveChildrenTo
    // ============================================================
    local procedure MoveChildrenTo(var Src: XmlElement; var Dst: XmlElement)
    var
        ChildNode: XmlNode;
        ChildList: XmlNodeList;
        i: Integer;
    begin
        ChildList := Src.GetChildNodes();
        for i := 1 to ChildList.Count do begin
            ChildList.Get(i, ChildNode);
            ChildNode.Remove();
            Dst.Add(ChildNode);
        end;
    end;




    // ============================================================
    // HandleBlockedOrMissingItem
    // Article introuvable (bloqué ou inexistant) → CODE_PR = '99'
    // Equivalent de la branche ELSE de l'original
    // ============================================================
    local procedure HandleBlockedOrMissingItem(
        var XMLRoot: XmlElement;
        Item_Ref: Code[20];
        CODEIMPUTATIONDMS_PR: Code[20];
        LIGNE_DT_ID: Code[20])
    var
        RecItem: Record Item;
        RecNewItem: Record Item;
        DLTReplenishment: Codeunit "DLT Replenishment";
        NewItemNo: Code[20];
        ReplacementChain: Text[250];
        Coefficient: Decimal;
        XMLNode: XmlElement;
        SavedTempDMS: XmlElement;
    begin
        // Vérifier si l'article existe mais est bloqué
        RecItem.Reset();
        RecItem.SetRange("No.", GetItemNo(Item_Ref));
        RecItem.SetRange(Blocked, true);

        if RecItem.FindFirst() then begin

            // Article bloqué ET remplacé → CODE_PR='99' + remplaçant CODE_PR='2'
            if RecItem."Replacement Status" = RecItem."Replacement Status"::Replaced then begin

                // Ligne de l'ancien article bloqué → CODE_PR = '99'
                AddElement(XMLRoot, 'PR', XMLNode);
                XMLNode.SetAttribute('ReferencePR', Item_Ref);
                XMLNode.SetAttribute('CODE_PR', '99');
                XMLNode.SetAttribute('idStockDMS', 'MAG_LB');
                XMLNode.SetAttribute('LibellePR', '');
                XMLNode.SetAttribute('LieuDeStockage', '');
                XMLNode.SetAttribute('QuantiteDisponible', '0.00');
                XMLNode.SetAttribute('QuantiteEnCommande', '0.00');
                XMLNode.SetAttribute('QuantiteReserveeSurLeStock', '0.00');
                XMLNode.SetAttribute('ReferencePRInitial', '');
                XMLNode.SetAttribute('WR_STOCK_PLACE', '');
                XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);

                // Chercher le remplaçant → CODE_PR = '2'
                ReplacementChain := '';
                NewItemNo := DLTReplenishment.GetLastReplacement(
                    0, RecItem."No.", '', ReplacementChain, false);

                if (NewItemNo <> '') and RecNewItem.Get(NewItemNo) then begin
                    Coefficient := GetReplacementCoefficient(
                        DLTReplenishment, RecItem."No.", NewItemNo);

                    SavedTempDMS := XmlElement.Create('DMS');
                    AddPRLineAllLocations(
                        SavedTempDMS, RecNewItem, Item_Ref,
                        '2', RecItem."No.", Coefficient, LIGNE_DT_ID);
                    MoveChildrenTo(SavedTempDMS, XMLRoot);

                    SavedTempDMS := XmlElement.Create('DMS');
                    AddPRLineAllLocations(
                        SavedTempDMS, RecNewItem, Item_Ref,
                        '2', RecItem."No.", Coefficient, LIGNE_DT_ID);
                    LZRF46T23V1(XMLRoot, SavedTempDMS, CODEIMPUTATIONDMS_PR);
                end;

            end else begin
                // Article bloqué sans remplacement → CODE_PR = '99'
                AddElement(XMLRoot, 'PR', XMLNode);
                XMLNode.SetAttribute('ReferencePR', Item_Ref);
                XMLNode.SetAttribute('CODE_PR', '99');
                XMLNode.SetAttribute('idStockDMS', 'MAG_LB');
                XMLNode.SetAttribute('LibellePR', '');
                XMLNode.SetAttribute('LieuDeStockage', '');
                XMLNode.SetAttribute('QuantiteDisponible', '0.00');
                XMLNode.SetAttribute('QuantiteEnCommande', '0.00');
                XMLNode.SetAttribute('QuantiteReserveeSurLeStock', '0.00');
                XMLNode.SetAttribute('ReferencePRInitial', '');
                XMLNode.SetAttribute('WR_STOCK_PLACE', '');
                XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);
            end;

        end else begin
            // Article inexistant → CODE_PR = '99'
            AddElement(XMLRoot, 'PR', XMLNode);
            XMLNode.SetAttribute('ReferencePR', Item_Ref);
            XMLNode.SetAttribute('CODE_PR', '99');
            XMLNode.SetAttribute('idStockDMS', 'MAG_LB');
            XMLNode.SetAttribute('LibellePR', '');
            XMLNode.SetAttribute('LieuDeStockage', '');
            XMLNode.SetAttribute('QuantiteDisponible', '0.00');
            XMLNode.SetAttribute('QuantiteEnCommande', '0.00');
            XMLNode.SetAttribute('QuantiteReserveeSurLeStock', '0.00');
            XMLNode.SetAttribute('ReferencePRInitial', '');
            XMLNode.SetAttribute('WR_STOCK_PLACE', '');
            XMLNode.SetAttribute('LIGNE_DT_ID', LIGNE_DT_ID);
        end;
    end;


    // ────────────────────────────────────────────────────────────
    //  AddPRLine  –  Nœud PR avec stock par location
    //  idStockDMS = code location réel  |  fallback 'MAG_LB'
    // ────────────────────────────────────────────────────────────
    local procedure AddPRLine(
        var XMLRoot: XmlElement;
        RecItem: Record Item;
        Item_Ref: Code[20];
        CodePR: Code[10];
        ReferenceInitial: Code[20];
        Coefficient: Decimal): XmlElement // retourne le node créé
    var
        RecItemLedger: Record "Item Ledger Entry";
        XMLNodeLocal: XmlElement;
    begin
        RecItemLedger.Reset();
        RecItemLedger.SetRange("Item No.", RecItem."No.");
        //RecItemLedger.SetFilter("Remaining Quantity", '<>0');
        RecItemLedger.SetRange("DLT Exclude From Inventory", false);
        if RecItemLedger.FindSet() then begin
            repeat
                AddElement(XMLRoot, 'PR', XMLNodeLocal);
                FillPRAttributes(
                    XMLNodeLocal,
                    RecItem,
                    RecItemLedger."Location Code",
                    RecItemLedger."Remaining Quantity",
                    CodePR,
                    ReferenceInitial,
                    Coefficient);
            until RecItemLedger.Next() = 0;
        end else begin
            AddElement(XMLRoot, 'PR', XMLNodeLocal);
            FillPRAttributes(
                XMLNodeLocal,
                RecItem,
                'MAG_LB',
                0,
                CodePR,
                ReferenceInitial,
                Coefficient);
        end;

        exit(XMLNodeLocal); // retourne le dernier node créé
    end;

    local procedure FillPRAttributes(var XMLNode: XmlElement; RecItem: Record Item; Location: Code[20]; Qty: Decimal; CodePR: Code[10]; RefInit: Code[20]; Coeff: Decimal)
    begin
        XMLNode.SetAttribute('ReferencePR', SetItemNo(RecItem."No."));
        XMLNode.SetAttribute('CODE_PR', CodePR);
        XMLNode.SetAttribute('idStockDMS', Location);
        XMLNode.SetAttribute('LibellePR', RecItem.Description);
        XMLNode.SetAttribute('LieuDeStockage', Location);
        XMLNode.SetAttribute('QuantiteDisponible', Format(Qty, 0, '<Precision,2:2><Standard Format,2>'));
        XMLNode.SetAttribute('QuantiteEnCommande', Format(RecItem."Qty. on Sales Order", 0, '<Precision,2:2><Standard Format,2>'));
        XMLNode.SetAttribute('QuantiteReserveeSurLeStock', Format(RecItem."Reserved Qty. on Inventory", 0, '<Precision,2:2><Standard Format,2>'));
        XMLNode.SetAttribute('ReferencePRInitial', RefInit);

        if Coeff <> 0 then
            XMLNode.SetAttribute('CoefficientDeRemplacement', Format(Coeff, 0, '<Precision,2:2><Standard Format,2>'));
    end;
    // ────────────────────────────────────────────────────────────
    //  AddGhostLine  –  Nœud PR vide CODE_PR = '99'
    // ────────────────────────────────────────────────────────────
    local procedure AddGhostLine(
        var XMLRoot: XmlElement;
        var XMLNode: XmlElement;
        Item_Ref: Code[20])
    begin
        AddElement(XMLRoot, 'PR', XMLNode);
        XMLNode.SetAttribute('ReferencePR', Item_Ref);
        XMLNode.SetAttribute('CODE_PR', '99');
        XMLNode.SetAttribute('idStockDMS', 'MAG_LB');
        XMLNode.SetAttribute('LibellePR', '');
        XMLNode.SetAttribute('LieuDeStockage', '');
        XMLNode.SetAttribute('QuantiteDisponible', '0.00');
        XMLNode.SetAttribute('QuantiteEnCommande', '0.00');
        XMLNode.SetAttribute('QuantiteUV', '');
        XMLNode.SetAttribute('QuantiteReserveeSurLeStock', '0.00');
        XMLNode.SetAttribute('ReferencePRInitial', '');
        XMLNode.SetAttribute('WR_STOCK_PLACE', '');
    end;


    // ────────────────────────────────────────────────────────────
    //  GetReplacementCoefficient  –  via DLT Replenishment
    //  Adapter selon les méthodes exposées par votre codeunit
    // ────────────────────────────────────────────────────────────
    local procedure GetReplacementCoefficient(
        var DLTReplenishment: Codeunit "DLT Replenishment";
        OldItemNo: Code[20];
        NewItemNo: Code[20]): Decimal
    var
        Coefficient: Decimal;
    begin
        // Adapter selon la signature de votre codeunit.
        // Si le codeunit expose GetCoefficient(OldNo, NewNo) :
        //Coefficient := DLTReplenishment.GetCoefficient(OldItemNo, NewItemNo);
        if Coefficient = 0 then
            Coefficient := 1;
        exit(Coefficient);
    end;

    local procedure AddPRPrix(
        var XMLRoot: XmlElement;
        ReferencePR: Code[30];
        LigneDTId: Text[30];
        CodeImputationDMS_PR: Code[20];
        var RecItem: Record Item;
        var RecCustomer: Record Customer)
    var
        SBManagement: Codeunit "STF Service Box Mgt";
        TempSalesLine: Record "Sales Line" temporary;
        NodePR: XmlElement;
        Remise: Decimal;
        PrixUnitaireHT: Decimal;
        PrixUnitaireTTC: Decimal;
        ErrorTxt: Text;
        ItemFound: Boolean;
    begin
        ItemFound := false;

        RecItem.Reset();
        RecItem.SetFilter("No.", '%1', GetItemNo(ReferencePR));
        RecItem.SetFilter(Blocked, '%1', false);

        if RecItem.FindFirst() then begin
            ItemFound := true;
            PrixUnitaireHT := RecItem."Unit Price";
        end else
            PrixUnitaireHT := 0;

        Remise := 0;

        // 🔹 Gestion remise client même si article trouvé
        if (CodeImputationDMS_PR <> '') and ItemFound then
            if RecCustomer.Get(CodeImputationDMS_PR) then begin
                TempSalesLine.Reset();
                TempSalesLine.DeleteAll();

                SBManagement.FindPriceDiscountItem(
                    RecItem."No.", RecCustomer."No.", ErrorTxt, TempSalesLine);

                if TempSalesLine.FindFirst() then begin
                    Remise := TempSalesLine."Line Discount %";

                    if TempSalesLine."Unit Price" > 0 then
                        PrixUnitaireHT := TempSalesLine."Unit Price";
                end;
            end;

        PrixUnitaireTTC := PrixUnitaireHT * 1.19;

        // ✅ TOUJOURS créer le node
        NodePR := XmlElement.Create('PR');

        NodePR.SetAttribute('LIGNE_DT_ID', LigneDTId);
        NodePR.SetAttribute('ReferencePR', SetItemNo(ReferencePR));

        if ItemFound then
            NodePR.SetAttribute('LibellePR', RecItem.Description)
        else
            NodePR.SetAttribute('LibellePR', '');

        NodePR.SetAttribute('PrixUnitaireHT',
            Format(PrixUnitaireHT, 0, '<Precision,2:2><Standard Format,2>'));

        NodePR.SetAttribute('PrixUnitaireTTC',
            Format(PrixUnitaireTTC, 0, '<Precision,2:2><Standard Format,2>'));

        // ✅ IMPORTANT : TOUJOURS présents
        NodePR.SetAttribute('PrixUV_HT', '');
        NodePR.SetAttribute('PrixUV_TTC', '');

        NodePR.SetAttribute('REMISE_DMS',
            Format(Remise, 0, '<Precision,2:2><Standard Format,2>'));

        XMLRoot.Add(NodePR);
    end;

    local procedure AddPRPrixLV(
      var XMLRoot: XmlElement;
      ReferencePR: Code[30];
      LigneDTId: Text[30];
      CodeImputationDMS_PR: Code[20];
      var RecItem: Record Item;
      var RecCustomer: Record Customer)
    var
        SBManagement: Codeunit "STF Service Box Mgt";
        TempSalesLine: Record "Sales Line" temporary;
        NodePR: XmlElement;
        Remise: Decimal;
        PrixUnitaireHT: Decimal;
        PrixUnitaireTTC: Decimal;
        ErrorTxt: Text;
    begin
        RecItem.Reset();
        RecItem.SetFilter("No.", '%1', GetItemNo(ReferencePR));
        RecItem.SetFilter(Blocked, '%1', false);

        // ✅ Si article non trouvé → ne rien émettre, LZRF46 ne sera pas ajouté
        if not RecItem.FindFirst() then
            exit;

        Remise := 0;
        PrixUnitaireHT := RecItem."Unit Price";

        if CodeImputationDMS_PR <> '' then
            if RecCustomer.Get(CodeImputationDMS_PR) then begin
                TempSalesLine.Reset();
                TempSalesLine.DeleteAll();
                SBManagement.FindPriceDiscountItem(
                    RecItem."No.", RecCustomer."No.", ErrorTxt, TempSalesLine);
                if TempSalesLine.FindFirst() then begin
                    Remise := TempSalesLine."Line Discount %";
                    if TempSalesLine."Unit Price" > 0 then
                        PrixUnitaireHT := TempSalesLine."Unit Price";
                end;
            end;

        PrixUnitaireTTC := PrixUnitaireHT * 1.19;

        NodePR := XmlElement.Create('PR');
        NodePR.SetAttribute('LIGNE_DT_ID', LigneDTId);
        NodePR.SetAttribute('ReferencePR', SetItemNo(ReferencePR));
        NodePR.SetAttribute('LibellePR', RecItem.Description);
        NodePR.SetAttribute('PrixUnitaireHT',
            Format(PrixUnitaireHT, 0, '<Precision,2:2><Standard Format,2>'));
        NodePR.SetAttribute('PrixUnitaireTTC',
            Format(PrixUnitaireTTC, 0, '<Precision,2:2><Standard Format,2>'));
        NodePR.SetAttribute('PrixUV_HT', '');
        NodePR.SetAttribute('PrixUV_TTC', '');
        NodePR.SetAttribute('REMISE_DMS',
            Format(Remise, 0, '<Precision,2:2><Standard Format,2>'));
        XMLRoot.Add(NodePR);
    end;


    // ────────────────────────────────────────────────────────────
    //  CheckCustomerByTypeImputation
    // ────────────────────────────────────────────────────────────
    local procedure CheckCustomerByTypeImputation(lTypeImputation: Text[30]; var lClient: Code[20])
    var
        SBOXSetup: Record "STF Servicebox Setup";
    begin
        if not SBOXSetup.Get() then exit;

        case lTypeImputation of
            Format(SBOXSetup."SBX Customer Imputation Code"):
                begin
                    // Pour le client standard, on ne remplace que s'il n'y a rien
                    if lClient = '' then
                        lClient := SBOXSetup."SBX Customer Imputation Account";
                end;

            Format(SBOXSetup."SBX Warranty Imputation Code"):
                lClient := SBOXSetup."SBX Warranty Imputation Account";

            Format(SBOXSetup."SBX Insurance Imputation Code"):
                lClient := SBOXSetup."SBX Insurance Imputation Account";

            Format(SBOXSetup."SBX Campaign Imputation Code"):
                lClient := SBOXSetup."SBX Campaign Imputation Account";

            Format(SBOXSetup."SBX Contract Imputation Code"):
                lClient := SBOXSetup."SBX Contract Imputation Account";

            Format(SBOXSetup."SBX Internal Imputation Code"):
                lClient := SBOXSetup."SBX Internal Imputation Account";
            else
                // Si le code du XML ne correspond à aucun paramétrage, on ne fait rien (exit)
                // lClient gardera sa valeur initiale (le client du dossier).
                exit;
        end;
    end;


    procedure DeleteLDT(RecServiceHeader: Record "Service Header EDMS"; XMLNodeLDT: XmlElement)
    var
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        RecServiceLine: Record "Service Line EDMS";
        RecServicePackageLine: Record "Service Package Version Line";
        SBOXPackageLine: Record "SBX Package Line";
        JobLineNo: Integer;
    begin
        // Récupérer ID ligne
        Evaluate(JobLineNo, GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID_DMS'));

        // Filtrer Job Line
        RecServiceJobLine.Reset();
        RecServiceJobLine.SetRange("Document Type", RecServiceHeader."Document Type");
        RecServiceJobLine.SetRange("Document No.", RecServiceHeader."No.");
        RecServiceJobLine.SetRange("Task No.", JobLineNo);

        if not RecServiceJobLine.FindFirst() then
            exit;

        // ================================
        // CAS 1 : LDT DE TYPE FORFAIT
        // ================================
        if RecServiceJobLine."Package No." <> '' then begin

            // ⚠️ IMPORTANT :
            // ❌ On NE SUPPRIME PLUS Service Package Version Line
            // RecServicePackageLine.Delete(true);  <-- supprimé volontairement

            /*
            RecServicePackageLine.Reset();
            RecServicePackageLine.SetRange("Document Type", RecServiceHeader."Document Type");
            RecServicePackageLine.SetRange("Document No.", RecServiceHeader."No.");
            RecServicePackageLine.SetRange("Make Code", RecServiceJobLine."Package Make Code");
            RecServicePackageLine.SetRange("Package No.", RecServiceJobLine."Package No.");
            RecServicePackageLine.SetRange("Package Version No.", RecServiceJobLine."Package Version No.");

            if RecServicePackageLine.FindFirst() then
                RecServicePackageLine.Delete(true);
            */

            // 🔹 Cas SBOX : on garde suppression ici (si métier nécessaire)
            if RecServiceJobLine."Package Type" = RecServiceJobLine."Package Type"::SBOX then begin
                SBOXPackageLine.Reset();
                SBOXPackageLine.SetRange("Document Type", RecServiceHeader."Document Type");
                SBOXPackageLine.SetRange("Document No.", RecServiceHeader."No.");
                SBOXPackageLine.SetRange("Package No.", RecServiceJobLine."Package No.");
                SBOXPackageLine.SetRange("Package Version No.", RecServiceJobLine."Package Version No.");
                SBOXPackageLine.SetRange("Code Type Veh", RecServiceJobLine."SBX SBOX CodeTypeVehicule");

                if SBOXPackageLine.FindSet() then
                    SBOXPackageLine.DeleteAll();
            end;

            // 🔹 Supprimer Job Line uniquement
            RecServiceJobLine.Delete(true);

        end else begin

            // ================================
            // CAS 2 : LDT STANDARD
            // ================================
            RecServiceLine.Reset();
            RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
            RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
            RecServiceLine.SetRange("Line No.", JobLineNo);

            if RecServiceLine.FindSet() then
                RecServiceLine.DeleteAll();

            // 🔹 Supprimer Job Line
            RecServiceJobLine.Delete(true);
        end;
    end;

    procedure DeleteServiceLinesFromLDT(RecServiceHeader: Record "Service Header EDMS"; JobLineNo: Integer)
    var
        RecServiceLine: Record "Service Line EDMS";
    begin
        RecServiceLine.Reset();
        RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
        RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
        RecServiceLine.SetRange("Line No.", JobLineNo);

        if RecServiceLine.FindSet() then
            RecServiceLine.DeleteAll(true);
    end;

    local procedure InsertPRServiceLineLV(
        var RecServiceJobLine: Record "Service Order Symptome  EDMS";
        XMLNodePR: XmlElement)
    var
        RecServiceLine: Record "Service Line EDMS";
        RecItem: Record Item;
        qte: Decimal;
    begin
        if not RecItem.Get(
            GetItemNo(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'))) then
            exit;

        if RecItem."Inventory Posting Group" = '' then
            exit;
        if RecItem.Blocked then exit;

        RecServiceLine.Init();
        RecServiceLine."Document Type" := RecServiceJobLine."Document Type";
        RecServiceLine."Document No." := RecServiceJobLine."Document No.";
        // RecServiceLine."DLT Instruction Line" := RecServiceJobLine."Task No.";
        RecServiceLine."Line No." := GetNextServiceLineNo(RecServiceJobLine);

        RecServiceLine.Validate(Type, RecServiceLine.Type::Item);
        RecServiceLine.Validate("No.", RecItem."No.");
        // --- LA CORRECTION EST ICI ---
        RecServiceLine."DLT Instruction Line" := RecServiceJobLine."Task No.";
        // -----------------------------

        /*  if Evaluate(qte,
             ConvertStr(GetAttributeValue(XMLNodePR, 'QuantiteCommandee'), '.', ',')) then;
         if qte = 0 then
             if Evaluate(qte,
                 ConvertStr(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'), '.', ',')) then;
  */

        qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteCommandee'));
        if qte = 0 then
            qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'));
        RecServiceLine.Validate(Quantity, qte);
        RecServiceLine.Insert(true);
    end;

    local procedure InsertPRServiceLine(
        var RecServiceJobLine: Record "Service Order Symptome  EDMS";
        XMLNodePR: XmlElement)
    var
        RecServiceLine: Record "Service Line EDMS";
        RecItem: Record Item;
        qte: Decimal;
    begin
        if not RecItem.Get(
            GetItemNo(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'))) then
            exit;

        if RecItem."Inventory Posting Group" = '' then
            exit;

        if RecItem.Blocked then
            exit;

        RecServiceLine.Init();
        RecServiceLine."Document Type" := RecServiceJobLine."Document Type";
        RecServiceLine."Document No." := RecServiceJobLine."Document No.";
        RecServiceLine."Line No." := GetNextServiceLineNo(RecServiceJobLine);

        RecServiceLine.Validate(Type, RecServiceLine.Type::Item);
        RecServiceLine.Validate("No.", RecItem."No.");

        // [C1] Assigner AVANT Validate(Quantity) pour ne pas être écrasé
        RecServiceLine."DLT Instruction Line" := RecServiceJobLine."Task No.";
        RecServiceLine."Package No." := RecServiceJobLine."Package No.";
        RecServiceLine."Package Version No." := RecServiceJobLine."Package Version No.";
        qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteCommandee'));
        if qte = 0 then
            qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'));

        RecServiceLine.Validate(Quantity, qte);
        RecServiceLine.Insert(true);
    end;

    procedure EnterServLineCustomer(var ServLine2: Record "Service Line EDMS")
    begin
        // EnterServLinesCustomer
        if (ServLine2."Line No." = 0) or (ServLine2."Bill-to Customer No." = '') then
            exit;

        ServLine2.Validate("Bill-to Customer No.", ServLine2."Bill-to Customer No.");
    end;
    // ────────────────────────────────────────────────────────────
    //  GetNextJobLineNo
    //  Numéro de ligne suivant pour Service Order Symptome EDMS
    // ────────────────────────────────────────────────────────────
    local procedure GetNextJobLineNo(
        RecServiceHeader: Record "Service Header EDMS"): Integer
    var
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
    begin
        RecServiceJobLine.Reset();
        RecServiceJobLine.SetRange("Document Type", RecServiceHeader."Document Type");
        RecServiceJobLine.SetRange("Document No.", RecServiceHeader."No.");
        if RecServiceJobLine.FindLast() then
            exit(RecServiceJobLine."Task No." + 10000)
        else
            exit(10000);
    end;

    /*********************************************************************/
    local procedure InsertMOServiceLine(
        var RecServiceJobLine: Record "Service Order Symptome  EDMS";
        XMLNodeMO: XmlElement)
    var
        RecServiceLine: Record "Service Line EDMS";
        RecLabor: Record "Service Labor";
        RecServiceHeader: Record "Service Header EDMS";
        qte: Decimal;
        QteText: Text;
        CodeOp: Text;
    begin
        CodeOp := GetAttributeValue(XMLNodeMO, 'CODEOPERATION');

        if not RecServiceHeader.Get(
            RecServiceJobLine."Document Type",
            RecServiceJobLine."Document No.") then
            exit;

        // [C3] Quantité protégée : vide, espace, ou non-parseable → 1
        QteText := DelChr(GetAttributeValue(XMLNodeMO, 'TEMPSGLOBAL'), '=', ' ');
        if (QteText = '') or (not Evaluate(qte, QteText)) then
            qte := 0;
        if qte = 0 then
            qte := 1;

        RecLabor.Reset();
        RecLabor.SetRange("STF No.", CodeOp);
        RecLabor.SetRange("Make Code", RecServiceHeader."Make Code");

        if RecLabor.FindFirst() then begin

            RecServiceLine.Init();
            RecServiceLine."Document Type" := RecServiceJobLine."Document Type";
            RecServiceLine."Document No." := RecServiceJobLine."Document No.";
            RecServiceLine."Line No." := GetNextServiceLineNo(RecServiceJobLine);

            // [C2] Remplir tous les champs AVANT Insert(true)
            RecServiceLine.Type := RecServiceLine.Type::Labor;
            RecServiceLine."No." := RecLabor."No.";
            RecServiceLine.Validate(Type, RecServiceLine.Type::Labor);
            RecServiceLine.Validate("No.", RecLabor."No.");
            RecServiceLine.Validate(Quantity, qte);
            RecServiceLine.Validate("Unit Price",
                ParseDecimal(GetAttributeValue(XMLNodeMO, 'PRIXHT_MO')));
            RecServiceLine."DLT Instruction Line" := RecServiceJobLine."Task No.";
            RecServiceLine."Package No." := RecServiceJobLine."Package No.";
            RecServiceLine."Package Version No." := RecServiceJobLine."Package Version No.";

            RecServiceLine.Insert(true);  // [C2] Insert en DERNIER
            RecServiceLine.Modify(true);

        end else begin

            eDMSSetup.Get();
            if eDMSSetup."SBX Default MO" = '' then
                exit;

            RecServiceLine.Init();
            RecServiceLine."Document Type" := RecServiceJobLine."Document Type";
            RecServiceLine."Document No." := RecServiceJobLine."Document No.";
            RecServiceLine."Line No." := GetNextServiceLineNo(RecServiceJobLine);

            // [C2] Idem : tout remplir AVANT Insert(true)
            RecServiceLine.Validate(Type, RecServiceLine.Type::Labor);
            RecServiceLine.Validate("No.", eDMSSetup."SBX Default MO");
            RecServiceLine.Validate(Quantity, qte);
            RecServiceLine.Validate("Unit Price",
                ParseDecimal(GetAttributeValue(XMLNodeMO, 'PRIXHT_MO')));
            RecServiceLine."DLT Instruction Line" := RecServiceJobLine."Task No.";
            RecServiceLine."SBX SBOX MO" := CodeOp;
            RecServiceLine."Package No." := RecServiceJobLine."Package No.";
            RecServiceLine."Package Version No." := RecServiceJobLine."Package Version No.";

            RecServiceLine.Insert(true);  // [C2] Insert en DERNIER
            RecServiceLine.Modify(true);
        end;
    end;


    local procedure InsertMOServiceLineLV(
           var RecServiceJobLine: Record "Service Order Symptome  EDMS";
           XMLNodeMO: XmlElement)
    var
        RecServiceLine: Record "Service Line EDMS";
        RecLabor: Record "Service Labor";
        RecServiceHeader: Record "Service Header EDMS";
        qte: Decimal;
        Montant: Decimal;
        CodeOp: Text;
        QteText: Text;
    begin
        CodeOp := GetAttributeValue(XMLNodeMO, 'CODEOPERATION');

        // 1. Récupérer l'entête pour avoir le "Make Code" (Marque)
        if not RecServiceHeader.Get(RecServiceJobLine."Document Type", RecServiceJobLine."Document No.") then
            exit;

        // 2. Préparation de la quantité (Correction du bug 0.10 -> 10)
        QteText := GetAttributeValue(XMLNodeMO, 'TEMPSGLOBAL');
        QteText := DelChr(QteText, '=', ' ');

        if not Evaluate(qte, QteText) then
            qte := 0;

        if qte = 0 then
            qte := 1;

        // 3. Recherche de la MO par "STF No." ET "Make Code"
        RecLabor.Reset();
        RecLabor.SetRange("STF No.", CodeOp);
        RecLabor.SetRange("Make Code", RecServiceHeader."Make Code");

        if RecLabor.FindFirst() then begin
            RecServiceLine.Init();
            RecServiceLine.Validate("Document Type", RecServiceJobLine."Document Type");
            RecServiceLine.Validate("Document No.", RecServiceJobLine."Document No.");
            RecServiceLine.Validate("Line No.", GetNextServiceLineNo(RecServiceJobLine));
            RecServiceLine.Insert(true);

            RecServiceLine.Validate(Type, RecServiceLine.Type::Labor);
            RecServiceLine.Validate("No.", RecLabor."No."); // Utilise le No. interne BC

            // On applique la quantité corrigée
            /*   if Evaluate(qte,
         ConvertStr(GetAttributeValue(XMLNodeMO, 'QuantiteCommandee'), '.', ',')) then;
     if qte = 0 then
         if Evaluate(qte,
             ConvertStr(GetAttributeValue(XMLNodeMO, 'QuantiteEnCommande'), '.', ',')) then;
*/
            RecServiceLine.Validate(Quantity, qte);

            /*  if Evaluate(Montant, ConvertStr(GetAttributeValue(XMLNodeMO, 'PRIXHT_MO'), '.', ',')) then
                 RecServiceLine.Validate("Unit Price", Montant); */
            RecServiceLine.Validate("Unit Price", ParseDecimal(GetAttributeValue(XMLNodeMO, 'PRIXHT_MO')));


            RecServiceLine.Validate("DLT Instruction Line", RecServiceJobLine."Task No.");
            RecServiceLine.Modify(true);

        end else begin
            // Fallback : MO par défaut si pas trouvé pour cette marque
            eDMSSetup.Get();
            if eDMSSetup."SBX Default MO" <> '' then begin
                RecServiceLine.Init();
                RecServiceLine.Validate("Document Type", RecServiceJobLine."Document Type");
                RecServiceLine.Validate("Document No.", RecServiceJobLine."Document No.");
                RecServiceLine.Validate("Line No.", GetNextServiceLineNo(RecServiceJobLine));
                RecServiceLine.Insert(true);

                RecServiceLine.Validate(Type, RecServiceLine.Type::Labor);
                RecServiceLine.Validate("No.", eDMSSetup."SBX Default MO");

                RecServiceLine.Validate(Quantity, qte);
                /* if Evaluate(Montant, ConvertStr(GetAttributeValue(XMLNodeMO, 'PRIXHT_MO'), '.', ',')) then
                    RecServiceLine.Validate("Unit Price", Montant);
 */
                RecServiceLine.Validate("Unit Price", ParseDecimal(GetAttributeValue(XMLNodeMO, 'PRIXHT_MO')));

                RecServiceLine.Validate("DLT Instruction Line", RecServiceJobLine."Task No.");
                RecServiceLine."SBX SBOX MO" := CodeOp;
                RecServiceLine.Modify(true);
            end;
        end;
    end;



    // ✅ Remplace ta ligne par ceci :
    local procedure ParseDecimal(RawValue: Text): Decimal
    var
        Montant: Decimal;
        CleanValue: Text;
    begin
        CleanValue := RawValue;
        // Normalise : remplace toujours la virgule par rien (séparateur milliers)
        // et le point par le séparateur décimal système
        CleanValue := ConvertStr(CleanValue, ',', '.');  // force le point comme décimal
        if Evaluate(Montant, CleanValue, 9) then  // format 9 = invariant culture (point décimal)
            exit(Montant);
        exit(0);
    end;


    local procedure FormatDecimalXML(Value: Decimal): Text
    var
        TxtValue: Text;
    begin
        // Format décimal avec 2 chiffres après la virgule
        TxtValue := Format(Value, 0, '<Precision,2:2><Standard Format,0>');

        // Remplacer la virgule par un point
        TxtValue := ConvertStr(TxtValue, ',', '.');

        exit(TxtValue);
    end;

    procedure UpdateLDT(
       var RecServiceHeader: Record "Service Header EDMS";
       XMLNodeLDT: XmlElement;
       var XMLRoot: XmlElement)
    var
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        RecServiceLine: Record "Service Line EDMS";
        XMLNodesPR: XmlNodeList;
        XMLNodesMO: XmlNodeList;
        XMLNodePR_Temp: XmlNode;
        XMLNodeMO_Temp: XmlNode;
        TmpNode: XmlElement;

        LigneDT_ID: Text;
        LigneDT_ID_DMS: Text;
        IDFORFAIT: Code[20];
        TypeForfait: Text;
        JobLineNo: Integer;
        //qte: Decimal;
        j: Integer;
    begin
        // =========================
        // 1. Lecture XML
        // =========================
        LigneDT_ID := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');
        LigneDT_ID_DMS := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID_DMS');
        IDFORFAIT := CopyStr(GetAttributeValue(XMLNodeLDT, 'IDFORFAIT'), 1, 20);
        TypeForfait := GetAttributeValue(XMLNodeLDT, 'TYPEFORFAIT');

        if not Evaluate(JobLineNo, LigneDT_ID_DMS) then begin
            InsertLDT(RecServiceHeader, XMLNodeLDT, XMLRoot);
            exit;
        end;

        // =========================
        // 2. Recherche LDT existante
        // =========================
        RecServiceJobLine.Reset();
        RecServiceJobLine.SetRange("Document Type", RecServiceHeader."Document Type");
        RecServiceJobLine.SetRange("Document No.", RecServiceHeader."No.");
        RecServiceJobLine.SetRange("Task No.", JobLineNo);

        if not RecServiceJobLine.FindFirst() then begin
            InsertLDT(RecServiceHeader, XMLNodeLDT, XMLRoot);
            exit;
        end;

        // =========================
        // 3. CAS 1 : SUPPRESSION FORFAIT
        // =========================
        if (RecServiceJobLine."Package No." <> '') and (IDFORFAIT = '') then begin

            ClearServiceLines(RecServiceHeader, JobLineNo);

            RecServiceJobLine.Validate("Package No.", '');
            RecServiceJobLine.Modify(true);

            HandlePRMO(RecServiceJobLine, XMLNodeLDT);
        end

        // =========================
        // 4. CAS 2 : AJOUT FORFAIT
        // =========================
        else if (RecServiceJobLine."Package No." = '') and (IDFORFAIT <> '') then begin

            ClearServiceLines(RecServiceHeader, JobLineNo);

            RecServiceJobLine.Validate("Package No.", IDFORFAIT);
            RecServiceJobLine.Validate("Package Version No.", 10000);
            RecServiceJobLine.Modify(true);

            RecServiceJobLine.InsertSPLineNew();
        end

        // =========================
        // 5. CAS 3 : CHANGEMENT FORFAIT
        // =========================
        else if (RecServiceJobLine."Package No." <> '') and (IDFORFAIT <> '') and
                (RecServiceJobLine."Package No." <> IDFORFAIT) then begin

            ClearServiceLines(RecServiceHeader, JobLineNo);

            RecServiceJobLine.Validate("Package No.", IDFORFAIT);
            RecServiceJobLine.Validate("Package Version No.", 10000);
            RecServiceJobLine.Modify(true);

            RecServiceJobLine.InsertSPLineNew();
        end

        // =========================
        // 6. CAS 4 : FORFAIT SBOX
        // =========================
        else if (TypeForfait = '1') and (IDFORFAIT <> '') then begin

            ClearServiceLines(RecServiceHeader, JobLineNo);

            UpdateSBoxPackageLines(IDFORFAIT, 10000, XMLNodeLDT);

            RecServiceJobLine.Validate("Package No.", IDFORFAIT);
            RecServiceJobLine.Validate("Package Version No.", 10000);
            RecServiceJobLine.Modify(true);

            RecServiceJobLine.InsertSPLineNew();
        end

        // =========================
        // 7. CAS 5 : SANS FORFAIT
        // =========================
        else begin
            HandlePRMO(RecServiceJobLine, XMLNodeLDT);
        end;

        // =========================
        // 8. Réponse XML
        // =========================
        AddElement(XMLRoot, 'LDT', TmpNode);
        AddAttribute(TmpNode, 'LIGNE_DT_ID', LigneDT_ID);
        AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));
    end;

    local procedure ClearServiceLines(RecServiceHeader: Record "Service Header EDMS"; JobLineNo: Integer)
    var
        RecServiceLine: Record "Service Line EDMS";
    begin
        RecServiceLine.Reset();
        RecServiceLine.SetRange("Document Type", RecServiceHeader."Document Type");
        RecServiceLine.SetRange("Document No.", RecServiceHeader."No.");
        RecServiceLine.SetRange("DLT Instruction Line", JobLineNo);

        if not RecServiceLine.IsEmpty then
            RecServiceLine.DeleteAll(true);
    end;

    local procedure HandlePRMO(
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        XMLNodeLDT: XmlElement)
    var
        XMLNodesPR: XmlNodeList;
        XMLNodesMO: XmlNodeList;
        XMLNodePR_Temp: XmlNode;
        XMLNodeMO_Temp: XmlNode;
        j: Integer;
    begin
        if XMLNodeLDT.SelectNodes('PR', XMLNodesPR) then
            for j := 1 to XMLNodesPR.Count() do begin
                XMLNodesPR.Get(j, XMLNodePR_Temp);
                UpdateOrInsertPRLine(RecServiceJobLine, XMLNodePR_Temp.AsXmlElement());
            end;

        if XMLNodeLDT.SelectNodes('MO', XMLNodesMO) then
            for j := 1 to XMLNodesMO.Count() do begin
                XMLNodesMO.Get(j, XMLNodeMO_Temp);
                UpdateOrInsertMOLine(RecServiceJobLine, XMLNodeMO_Temp.AsXmlElement());
            end;
    end;

    local procedure UpdateOrInsertPRLine(
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        XMLNodePR: XmlElement)
    var
        RecServiceLine: Record "Service Line EDMS";
        ItemNo: Code[20];
        qte: Decimal;
    begin
        ItemNo := GetItemNo(GetAttributeValue(XMLNodePR, 'REFERENCE_PR'));
        if ItemNo = '' then exit;

        // 1. Chercher si cette pièce existe déjà sous ce symptôme (Task No.)
        RecServiceLine.Reset();
        RecServiceLine.SetRange("Document Type", RecServiceJobLine."Document Type");
        RecServiceLine.SetRange("Document No.", RecServiceJobLine."Document No.");
        RecServiceLine.SetRange(Type, RecServiceLine.Type::Item);
        RecServiceLine.SetRange("No.", ItemNo);
        RecServiceLine.SetRange("DLT Instruction Line", RecServiceJobLine."Task No.");

        if RecServiceLine.FindFirst() then begin
            // 2. MISE À JOUR : On récupère la quantité du XML
            //if Evaluate(qte, ConvertStr(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'), '.', ',')) then begin
            // Option A : Remplacer la quantité (Standard SBox) */

            // qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteCommandee'));
            //if qte = 0 then
            qte := ParseDecimal(GetAttributeValue(XMLNodePR, 'QuantiteEnCommande'));
            RecServiceLine.Validate(Quantity, qte);

            // Option B : Accumuler (Si vous voulez additionner au lieu de remplacer, utilisez :)
            // RecServiceLine.Validate(Quantity, RecServiceLine.Quantity + qte);

            RecServiceLine.Modify(true);
            //end;
        end else begin
            // 3. INSERTION : La pièce n'existe pas encore pour cette tâche
            InsertPRServiceLine(RecServiceJobLine, XMLNodePR);
        end;
    end;

    local procedure UpdateOrInsertMOLine(
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        XMLNodeMO: XmlElement)
    var
        RecServiceLine: Record "Service Line EDMS";
        OpCode: Code[20];
        qte: Decimal;
    begin
        OpCode := CopyStr(GetAttributeValue(XMLNodeMO, 'CODEOPERATION'), 1, 20);
        if OpCode = '' then exit;

        // 1. Chercher si cette opération de MO existe déjà pour ce symptôme précis
        RecServiceLine.Reset();
        RecServiceLine.SetRange("Document Type", RecServiceJobLine."Document Type");
        RecServiceLine.SetRange("Document No.", RecServiceJobLine."Document No.");
        RecServiceLine.SetRange(Type, RecServiceLine.Type::Labor);
        RecServiceLine.SetRange("No.", OpCode);
        RecServiceLine.SetRange("DLT Instruction Line", RecServiceJobLine."Task No.");

        if RecServiceLine.FindFirst() then begin
            // 2. MISE À JOUR : On remplace la quantité par celle du XML
            if Evaluate(qte, ConvertStr(GetAttributeValue(XMLNodeMO, 'QUANTITE'), '.', ',')) then begin
                RecServiceLine.Validate(Quantity, qte);
                RecServiceLine.Modify(true);
            end;
        end else begin
            // 3. INSERTION : L'opération n'existe pas, on l'ajoute
            InsertMOServiceLine(RecServiceJobLine, XMLNodeMO);
        end;
    end;


    local procedure UpdateSBoxPackageLines(
        PackageNo: Code[20];
        VersionNo: Integer;
        XMLNodeLDT: XmlElement)
    var
        PkgLine: Record "Service Package Version Line"; // Table 25006136
        XMLNodesPR: XmlNodeList;
        XMLNodesMO: XmlNodeList;
        XMLNode_Temp: XmlNode;
        j: Integer;
        NextLineNo: Integer;
    begin
        // 1. Supprimer l'ancienne recette pour cette version spécifique Peugeot
        PkgLine.SetRange("Package No.", PackageNo);
        PkgLine.SetRange("Version No.", VersionNo);
        if not PkgLine.IsEmpty then
            PkgLine.DeleteAll(true);

        NextLineNo := 10000;

        // 2. Insérer les Pièces (PR) du XML
        if XMLNodeLDT.SelectNodes('PR', XMLNodesPR) then
            for j := 1 to XMLNodesPR.Count() do begin
                XMLNodesPR.Get(j, XMLNode_Temp);
                PkgLine.Init();
                PkgLine."Package No." := CopyStr(PackageNo, 1, 14);
                ;
                PkgLine."Version No." := VersionNo;
                PkgLine."Line No." := NextLineNo;
                PkgLine.Type := PkgLine.Type::Item;
                PkgLine.Validate("No.", GetItemNo(GetAttributeValue(XMLNode_Temp.AsXmlElement(), 'REFERENCE_PR')));

                // Gestion quantité
                EvaluateQuantity(PkgLine, GetAttributeValue(XMLNode_Temp.AsXmlElement(), 'QuantiteEnCommande'));

                PkgLine.Insert(true);
                NextLineNo += 10000;
            end;

        // 3. Insérer la Main d'œuvre (MO) du XML
        if XMLNodeLDT.SelectNodes('MO', XMLNodesMO) then
            for j := 1 to XMLNodesMO.Count() do begin
                XMLNodesMO.Get(j, XMLNode_Temp);
                PkgLine.Init();
                PkgLine."Package No." := CopyStr(PackageNo, 1, 14);
                PkgLine."Version No." := VersionNo;
                PkgLine."Line No." := NextLineNo;
                PkgLine.Type := PkgLine.Type::Labor;
                PkgLine.Validate("No.", GetAttributeValue(XMLNode_Temp.AsXmlElement(), 'CODEOPERATION'));

                // Gestion quantité
                EvaluateQuantity(PkgLine, GetAttributeValue(XMLNode_Temp.AsXmlElement(), 'QUANTITE'));

                PkgLine.Insert(true);
                NextLineNo += 10000;
            end;
    end;

    local procedure EvaluateQuantity(var PkgLine: Record "Service Package Version Line"; QtyString: Text)
    var
        DecValue: Decimal;
    begin
        if QtyString = '' then begin
            PkgLine.Validate(Quantity, 0);
            exit;
        end;

        // Remplace le point par la virgule (ou vice versa selon la configuration régionale du serveur)
        // pour s'assurer que EVALUATE ne provoque pas d'erreur de format.
        if Evaluate(DecValue, ConvertStr(QtyString, '.', ',')) then
            PkgLine.Validate(Quantity, DecValue)
        else
            // Si l'évaluation échoue avec la virgule, on tente sans conversion (format anglo-saxon)
            if Evaluate(DecValue, QtyString) then
                PkgLine.Validate(Quantity, DecValue)
            else
                PkgLine.Validate(Quantity, 0); // Valeur par défaut en cas d'erreur totale
    end;
    //////////////////////

    procedure LZRF10T13V1LV(TempRoot: XmlElement; XMLNodeReq: XmlElement; RqType: Text)
    var
        XMLRoot, XMLNodeCustomer, XMLNodeVehicle : XmlElement;
        XMLNodeServicePAD: XmlElement;
        XmlNodesLDT, XMLNodesPR : XmlNodeList;
        XMLNodesPADANOMALIE, XMLNodesPADCATEGORIECV : XmlNodeList;
        XMLNodesPADCONTROLEVISUEL, XMLNodesPADCHOIX : XmlNodeList;
        RecSalesHeader: Record "Sales Header";
        RecServiceHeader: Record "Service Header EDMS";
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        RecCustomer: Record Customer;
        RecVehicle: Record Vehicle;
        RecLocation: Record Location;
        RecServiceLocation: Record Location;
        eDMSSetup: Record "STF Servicebox Setup";
        Kilometrage: Decimal;
        i, j, PADi, PADj, PADk : Integer;
        JobLineNo: Integer;
        NumPost: Code[10];
        lREMISEDOSSIER, lPRIXDOSSIER_TTC : Decimal;
        lREMISELDT, lREMISELDTTOT, lPRIXLDTTTC, lPRIXLDTTTCTOT : Decimal;
        lTYPEREMISE: Integer;
        lCodeUpdateDelete: Text[30];
        lDAY, lMonth, lYEAR : Integer;
        TmpNode: XmlElement;
        XMLNodeLDT_Temp: XmlNode;
        XMLNodePR_Temp: XmlNode;
        XMLNodePAD_Temp: XmlNode;
        XMLNodeCV_Temp: XmlNode;
        XMLNodeCH_Temp: XmlNode;
        XMLNodeServicePAD_Node: XmlNode;
        LigneDT_ID: Text;
        Text0001: Label 'L''utilisateur utilisé n''est pas paramétré dans Business Central.';
        Text0002: Label 'Merci de renseigner la limite de crédit dans le champ Observation.';
        Text0003: Label 'Transfert du dossier réussi.';
        Text0004: Label 'Mise à jour du dossier réussi.';
        Text0005: Label 'L''utilisateur utilisé n''a pas les droits pour modifier les tâches atelier.';
        Text0006: Label 'L''utilisateur utilisé n''a pas les droits pour créer un OR.';
        Text0007: Label 'Merci de renseigner le client de Passage PR dans le paramétrage eDMS.';
    begin
        XMLRoot := XmlElement.Create('LZRF10');
        TempRoot.Add(XMLRoot);

        XMLNodeCustomer := GetChildElement(XMLNodeReq, 'CLIENT');
        XMLNodeVehicle := GetChildElement(XMLNodeReq, 'VEHICULE');
        XMLNodeVehicle.SelectNodes('LDT', XmlNodesLDT);
        AddAttribute(XMLRoot, 'LDTcount', Format(XmlNodesLDT.Count()));

        NumPost := GetAttributeValue(XMLNodeReq, 'NumeroPoste');

        if not CheckUserSetup(GetAttributeValue(XMLNodeReq, 'ID_UTILISATEUR'), NumPost, RecLocation, RecServiceLocation) then begin
            ErrorResponse(XMLRoot, Text0001);
            for i := 1 to XmlNodesLDT.Count() do begin
                XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID',
                    GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
            end;
            exit;
        end;

        eDMSSetup.Get();
        if eDMSSetup.accountCustomerUpdate then
            UpdateCustomer(XMLNodeCustomer);

        // ── Remise dossier (Menu Pricing) ──────────────────────────────────────
        if (GetAttributeValue(XMLNodeVehicle, 'REMISECLIENT') = '1') and
            (eDMSSetup.interfaceVersion = '13') then begin
            Evaluate(lREMISEDOSSIER,
                ConvertStr(GetAttributeValue(XMLNodeVehicle, 'REMISEDOSSIER'), '.', ','));
            Evaluate(lTYPEREMISE,
                GetAttributeValue(XMLNodeVehicle, 'TYPEREMISE'));
            Evaluate(lPRIXDOSSIER_TTC,
                ConvertStr(GetAttributeValue(XMLNodeVehicle, 'PRIXDOSSIER_TTC'), '.', ','));
        end;

        // ── Service PAD ────────────────────────────────────────────────────────
        if eDMSSetup."sbx ServicePAD" and (eDMSSetup.interfaceVersion = '13') then
            if XMLNodeReq.SelectSingleNode('SERVICEPAD', XMLNodeServicePAD_Node) then begin
                XMLNodeServicePAD := XMLNodeServicePAD_Node.AsXmlElement();

                GetAttributeValue(XMLNodeServicePAD, 'NOTE');

                XMLNodeServicePAD.SelectNodes('ANOMALIE', XMLNodesPADANOMALIE);
                for PADi := 1 to XMLNodesPADANOMALIE.Count() do begin
                    XMLNodesPADANOMALIE.Get(PADi, XMLNodePAD_Temp);
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Image');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'X');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Y');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Libelle');
                end;

                XMLNodeServicePAD.SelectNodes('CATEGORIECV', XMLNodesPADCATEGORIECV);
                for PADi := 1 to XMLNodesPADCATEGORIECV.Count() do begin
                    XMLNodesPADCATEGORIECV.Get(PADi, XMLNodePAD_Temp);
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Num');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Libelle');

                    XMLNodePAD_Temp.AsXmlElement().SelectNodes('CONTROLEVISUEL', XMLNodesPADCONTROLEVISUEL);
                    for PADj := 1 to XMLNodesPADCONTROLEVISUEL.Count() do begin
                        XMLNodesPADCONTROLEVISUEL.Get(PADj, XMLNodeCV_Temp);
                        GetAttributeValue(XMLNodeCV_Temp.AsXmlElement(), 'Libelle');
                        GetAttributeValue(XMLNodeCV_Temp.AsXmlElement(), 'Texte');

                        XMLNodeCV_Temp.AsXmlElement().SelectNodes('CHOIX', XMLNodesPADCHOIX);
                        for PADk := 1 to XMLNodesPADCHOIX.Count() do begin
                            XMLNodesPADCHOIX.Get(PADk, XMLNodeCH_Temp);
                            GetAttributeValue(XMLNodeCH_Temp.AsXmlElement(), 'Libelle');
                            GetAttributeValue(XMLNodeCH_Temp.AsXmlElement(), 'Selection');
                        end;
                    end;
                end;
            end;

        // ======================================================================
        // ORIGINEVENTE = '1' → Commande vente PR
        // ======================================================================
        if GetAttributeValue(XMLNodeReq, 'ORIGINEVENTE') = '1' then begin

            if (GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '') or
               (eDMSSetup.PRPassingAccount <> '') then begin

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

                RecSalesHeader.Validate("sbx VIN SBOX", GetAttributeValue(XMLNodeVehicle, 'VIN'));
                RecSalesHeader."sbx Dossier SBOX" := true;
                RecSalesHeader.Insert(true);

                if eDMSSetup."sbx Discount allowed" and CheckUserPermissionAPV('APV_MODIFY', RecUserSetup) then begin
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

                for i := 1 to XmlNodesLDT.Count() do begin
                    XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                    LigneDT_ID := GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID');
                    XMLNodeLDT_Temp.AsXmlElement().SelectNodes('PR', XMLNodesPR);

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

                    if eDMSSetup."sbx Discount allowed LDT" and
                       CheckUserPermissionAPV('APV_MODIFY', RecUserSetup) then begin
                        Evaluate(lREMISELDT,
                            ConvertStr(GetAttributeValue(
                                XMLNodeLDT_Temp.AsXmlElement(), 'REMISE_PRICING_LDT'), '.', ','));
                        Evaluate(lPRIXLDTTTC,
                            ConvertStr(GetAttributeValue(
                                XMLNodeLDT_Temp.AsXmlElement(), 'PRIXTTC_LDT'), '.', ','));
                        lREMISELDTTOT += lREMISELDT;
                        lPRIXLDTTTCTOT += lPRIXLDTTTC;
                    end;

                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', LigneDT_ID);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', LigneDT_ID);
                end;

                if eDMSSetup."sbx Discount allowed LDT" then begin
                    if (lREMISELDTTOT + lPRIXLDTTTCTOT) > 0 then
                        RecSalesHeader.Validate(
                            "Payment Discount %",
                            RecSalesHeader."Payment Discount %" +
                            ((lREMISELDTTOT / (lREMISELDTTOT + lPRIXLDTTTCTOT)) * 100));
                    RecSalesHeader.Modify(true);
                end;

            end else begin
                ErrorResponse(XMLRoot, Text0007);
                for i := 1 to XmlNodesLDT.Count() do begin
                    XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID',
                        GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                end;
            end;

            // ======================================================================
            // ORIGINEVENTE APV → Dossier service
            // ======================================================================
        end else begin

            if GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage') <> '' then
                Evaluate(Kilometrage,
                    DelChr(GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage'), '=', ' '));
            RecVehicle.Reset();
            RecVehicle.SetRange("VIN", GetAttributeValue(XMLNodeVehicle, 'VIN'));

            if RecVehicle.FindFirst() then
                //if RecVehicle.Get(GetAttributeValue(XMLNodeVehicle, 'VIN')) then
                if Kilometrage > RecVehicle."Variable Field Run 1" then begin
                    RecVehicle."Variable Field Run 1" := Kilometrage;
                    RecVehicle.Modify(true);
                end;

            // ==================================================================
            // Nième transfert → Mise à jour dossier existant
            // ==================================================================
            if GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID') <> '' then begin

                if not CheckUserPermissionAPV('APV_MODIFY', RecUserSetup) then begin
                    ErrorResponse(XMLRoot, Text0005);
                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID',
                            GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                    end;
                    exit;
                end;

                RecServiceHeader.Reset();
                RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                RecServiceHeader.SetRange("No.", GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID'));

                if RecServiceHeader.FindFirst() then begin

                    if (GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT') <> '') and
                       (GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT') <> '') and
                       (GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT') <> '') then begin
                        Evaluate(lDAY, GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT'));
                        Evaluate(lMonth, GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT'));
                        Evaluate(lYEAR, GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT'));
                        RecServiceHeader."Order Date" := DMY2Date(lDAY, lMonth, lYEAR);
                    end;
                    RecServiceHeader.Modify(true);

                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'TexteDMS', Text0004);
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");

                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);

                        eDMSSetup.Get();
                        if eDMSSetup.interfaceVersion = '13' then
                            lCodeUpdateDelete := 'CODEVENTILATION_LDT'
                        else
                            lCodeUpdateDelete := 'TYPEIMPUTATION_LDT';

                        if GetAttributeValue(
                            XMLNodeLDT_Temp.AsXmlElement(), lCodeUpdateDelete) = '99' then
                            DeleteLDT(RecServiceHeader, XMLNodeLDT_Temp.AsXmlElement())

                        else begin
                            if GetAttributeValue(
                                XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID_DMS') <> '' then begin

                                Evaluate(JobLineNo,
                                    GetAttributeValue(
                                        XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID_DMS'));

                                RecServiceJobLine.Reset();
                                RecServiceJobLine.SetRange("Document Type", RecServiceHeader."Document Type");
                                RecServiceJobLine.SetRange("Document No.", RecServiceHeader."No.");
                                RecServiceJobLine.SetRange("Task No.", JobLineNo);

                                if RecServiceJobLine.FindFirst() then
                                    UpdateLDT(RecServiceHeader,
                                        XMLNodeLDT_Temp.AsXmlElement(), XMLRoot)
                                else
                                    InsertLDT(RecServiceHeader,
                                        XMLNodeLDT_Temp.AsXmlElement(), XMLRoot);

                            end else
                                InsertLDT(RecServiceHeader,
                                    XMLNodeLDT_Temp.AsXmlElement(), XMLRoot);
                        end;
                    end;
                end;

                // ==================================================================
                // 1er transfert → Création d'un nouveau dossier APV
                // ==================================================================
            end else begin

                if not CheckUserPermissionAPV('APV_CREATE', RecUserSetup) then begin
                    ErrorResponse(XMLRoot, Text0006);
                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID',
                            GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                    end;
                    exit;
                end;

                if GetAttributeValue(XMLNodeCustomer, 'Observations') = '' then begin
                    ErrorResponse(XMLRoot, Text0002);
                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID',
                            GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                    end;
                    exit;
                end;

                RecServiceHeader.Init();
                RecServiceHeader."Document Type" := RecServiceHeader."Document Type"::Order;
                RecServiceHeader."Location Code" := RecServiceLocation.Code;
                RecServiceHeader.Insert(true);
                RecServiceHeader.SetHideValidationDialog(true);

                if GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '' then begin
                    if RecCustomer.Get(GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID')) then
                        RecServiceHeader.Validate(
                            "Sell-to Customer No.",
                            GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID'))
                    else
                        RecServiceHeader.Validate(
                            "Sell-to Customer No.",
                            eDMSSetup."sbx Customer Imputation Account");
                end else
                    RecServiceHeader.Validate(
                        "Sell-to Customer No.",
                        eDMSSetup."sbx Customer Imputation Account");

                RecServiceHeader.Validate(VIN, GetAttributeValue(XMLNodeVehicle, 'VIN'));
                Evaluate(RecServiceHeader."Variable Field Run 1",
                    DelChr(GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage'), '=', ' '));

                if (GetAttributeValue(XMLNodeReq, 'JOURRDV') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'MOISRDV') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'ANNEERDV') <> '') then begin
                    Evaluate(lDAY, GetAttributeValue(XMLNodeReq, 'JOURRDV'));
                    Evaluate(lMonth, GetAttributeValue(XMLNodeReq, 'MOISRDV'));
                    Evaluate(lYEAR, GetAttributeValue(XMLNodeReq, 'ANNEERDV'));
                    RecServiceHeader."Order Date" := DMY2Date(lDAY, lMonth, lYEAR);
                end;

                if (GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT') <> '') then begin
                    Evaluate(lDAY, GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT'));
                    Evaluate(lMonth, GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT'));
                    Evaluate(lYEAR, GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT'));
                    // RecServiceHeader."Pickup Date" := DMY2Date(lDAY, lMonth, lYEAR);
                end;

                RecServiceHeader.Modify(true);

                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'TexteDMS', Text0003);
                AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");

                for i := 1 to XmlNodesLDT.Count() do begin
                    XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                    InsertLDT(RecServiceHeader, XMLNodeLDT_Temp.AsXmlElement(), XMLRoot);
                end;
            end;
        end;
    end;


    procedure LZRF10T13V1(TempRoot: XmlElement; XMLNodeReq: XmlElement; RqType: Text)
    var
        XMLRoot, XMLNodeCustomer, XMLNodeVehicle : XmlElement;
        XMLNodeServicePAD: XmlElement;
        XmlNodesLDT, XMLNodesPR : XmlNodeList;
        XMLNodesPADANOMALIE, XMLNodesPADCATEGORIECV : XmlNodeList;
        XMLNodesPADCONTROLEVISUEL, XMLNodesPADCHOIX : XmlNodeList;
        RecSalesHeader: Record "Sales Header";
        RecServiceHeader: Record "Service Header EDMS";
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        RecCustomer: Record Customer;
        RecVehicle: Record Vehicle;
        RecLocation: Record Location;
        RecServiceLocation: Record Location;
        eDMSSetup: Record "STF Servicebox Setup";
        Kilometrage: Decimal;
        i, j, PADi, PADj, PADk : Integer;
        JobLineNo: Integer;
        NumPost: Code[10];
        lREMISEDOSSIER, lPRIXDOSSIER_TTC : Decimal;
        lREMISELDT, lREMISELDTTOT, lPRIXLDTTTC, lPRIXLDTTTCTOT : Decimal;
        lTYPEREMISE: Integer;
        lCodeUpdateDelete: Text[30];
        lDAY, lMonth, lYEAR : Integer;
        TmpNode: XmlElement;
        XMLNodeLDT_Temp: XmlNode;
        XMLNodePR_Temp: XmlNode;
        XMLNodePAD_Temp: XmlNode;
        XMLNodeCV_Temp: XmlNode;
        XMLNodeCH_Temp: XmlNode;
        XMLNodeServicePAD_Node: XmlNode;
        LigneDT_ID: Text;

        // ── Libellés (à valider : Text0100/0101/0102 = valeurs originales C/AL) ──
        Text0001: Label 'L''utilisateur utilisé n''est pas paramétré dans Business Central.';
        Text0002: Label 'Merci de renseigner la limite de crédit dans le champ Observation.';
        Text0003: Label 'Transfert du dossier réussi.';
        Text0004: Label 'Mise à jour du dossier réussi.';
        Text0005: Label 'L''utilisateur utilisé n''a pas les droits pour modifier les tâches atelier.';
        Text0006: Label 'L''utilisateur utilisé n''a pas les droits pour créer un OR.';
        Text0007: Label 'Merci de renseigner le client de Passage PR dans le paramétrage eDMS.';
    // [FIX-7] Vérifier que Text0100/0101/0102 dans l'original correspondent bien à :
    //   Text0100 = permission de création APV   → 'APV_CREATE'
    //   Text0101 = permission de modification APV → 'APV_MODIFY'
    //   Text0102 = permission discount          → 'APV_MODIFY'  (idem ou distincte ?)
    begin
        XMLRoot := XmlElement.Create('LZRF10');
        TempRoot.Add(XMLRoot);

        XMLNodeCustomer := GetChildElement(XMLNodeReq, 'CLIENT');
        XMLNodeVehicle := GetChildElement(XMLNodeReq, 'VEHICULE');
        XMLNodeVehicle.SelectNodes('LDT', XmlNodesLDT);
        AddAttribute(XMLRoot, 'LDTcount', Format(XmlNodesLDT.Count()));

        NumPost := GetAttributeValue(XMLNodeReq, 'NumeroPoste');

        // ── Vérification utilisateur ───────────────────────────────────────────
        if not CheckUserSetup(
            GetAttributeValue(XMLNodeReq, 'ID_UTILISATEUR'),
            NumPost, RecLocation, RecServiceLocation) then begin

            ErrorResponse(XMLRoot, Text0001);
            for i := 1 to XmlNodesLDT.Count() do begin
                XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID',
                    GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
            end;
            exit;
        end;

        eDMSSetup.Get();
        if eDMSSetup.accountCustomerUpdate then
            UpdateCustomer(XMLNodeCustomer);

        // ── Remise dossier (Menu Pricing) ──────────────────────────────────────
        if (GetAttributeValue(XMLNodeVehicle, 'REMISECLIENT') = '1') and
           (eDMSSetup.interfaceVersion = '13') then begin
            Evaluate(lREMISEDOSSIER,
                ConvertStr(GetAttributeValue(XMLNodeVehicle, 'REMISEDOSSIER'), '.', ','));
            Evaluate(lTYPEREMISE,
                GetAttributeValue(XMLNodeVehicle, 'TYPEREMISE'));
            Evaluate(lPRIXDOSSIER_TTC,
                ConvertStr(GetAttributeValue(XMLNodeVehicle, 'PRIXDOSSIER_TTC'), '.', ','));
        end;

        // ── Service PAD ────────────────────────────────────────────────────────
        if eDMSSetup."SBX ServicePAD" and (eDMSSetup.interfaceVersion = '13') then
            if XMLNodeReq.SelectSingleNode('SERVICEPAD', XMLNodeServicePAD_Node) then begin
                XMLNodeServicePAD := XMLNodeServicePAD_Node.AsXmlElement();
                GetAttributeValue(XMLNodeServicePAD, 'NOTE');

                XMLNodeServicePAD.SelectNodes('ANOMALIE', XMLNodesPADANOMALIE);
                for PADi := 1 to XMLNodesPADANOMALIE.Count() do begin
                    XMLNodesPADANOMALIE.Get(PADi, XMLNodePAD_Temp);
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Image');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'X');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Y');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Libelle');
                end;

                XMLNodeServicePAD.SelectNodes('CATEGORIECV', XMLNodesPADCATEGORIECV);
                for PADi := 1 to XMLNodesPADCATEGORIECV.Count() do begin
                    XMLNodesPADCATEGORIECV.Get(PADi, XMLNodePAD_Temp);
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Num');
                    GetAttributeValue(XMLNodePAD_Temp.AsXmlElement(), 'Libelle');

                    XMLNodePAD_Temp.AsXmlElement().SelectNodes('CONTROLEVISUEL', XMLNodesPADCONTROLEVISUEL);
                    for PADj := 1 to XMLNodesPADCONTROLEVISUEL.Count() do begin
                        XMLNodesPADCONTROLEVISUEL.Get(PADj, XMLNodeCV_Temp);
                        GetAttributeValue(XMLNodeCV_Temp.AsXmlElement(), 'Libelle');
                        GetAttributeValue(XMLNodeCV_Temp.AsXmlElement(), 'Texte');

                        XMLNodeCV_Temp.AsXmlElement().SelectNodes('CHOIX', XMLNodesPADCHOIX);
                        for PADk := 1 to XMLNodesPADCHOIX.Count() do begin
                            XMLNodesPADCHOIX.Get(PADk, XMLNodeCH_Temp);
                            GetAttributeValue(XMLNodeCH_Temp.AsXmlElement(), 'Libelle');
                            GetAttributeValue(XMLNodeCH_Temp.AsXmlElement(), 'Selection');
                        end;
                    end;
                end;
            end;

        // ======================================================================
        // ORIGINEVENTE = '1' → Commande vente PR
        // ======================================================================
        if GetAttributeValue(XMLNodeReq, 'ORIGINEVENTE') = '1' then begin

            if (GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '') or
               (eDMSSetup.PRPassingAccount <> '') then begin

                RecSalesHeader.Init();
                RecSalesHeader."Document Type" := RecSalesHeader."Document Type"::Order;
                RecSalesHeader."Document Profile" := RecSalesHeader."Document Profile"::"Spare Parts Trade";

                // [FIX-2] Branch Code et Department Code (présents dans l'original C/AL)
                if RecLocation.Code <> '' then begin
                    RecSalesHeader.Validate("Location Code", RecLocation.Code);
                    // TODO: Vérifier le nom exact du champ Branch Code en BC
                    // RecSalesHeader.Validate("Branch Code", RecLocation."Branch Code");
                end;

                RecSalesHeader.SetHideValidationDialog(true);

                // [FIX-2] Department Code depuis RecUserSetup
                // RecSalesHeader.Validate("Department Code", RecUserSetup."Department Code");

                if GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '' then
                    RecSalesHeader.Validate(
                        "Sell-to Customer No.",
                        GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID'))
                else
                    RecSalesHeader.Validate(
                        "Sell-to Customer No.",
                        eDMSSetup.PRPassingAccount);

                RecSalesHeader.Validate("sbx VIN SBOX", GetAttributeValue(XMLNodeVehicle, 'VIN'));
                RecSalesHeader."sbx Dossier SBOX" := true;
                RecSalesHeader.Insert(true);

                // [FIX-6] "Inv. Discount %" → CalcInvDiscountAmount / "Invoice Discount Value"
                //         NB : "Payment Discount %" = escompte de règlement, sémantique différente.
                //         Utiliser CalcInvDiscountAmount ou le champ "Invoice Discount Value" selon la table.
                if eDMSSetup."SBX Discount allowed" and CheckUserPermissionAPV('APV_MODIFY', RecUserSetup) then begin
                    if lTYPEREMISE = 1 then
                        RecSalesHeader.Validate("Invoice Discount Value", lREMISEDOSSIER)
                    else
                        if (lPRIXDOSSIER_TTC + lREMISEDOSSIER) > 0 then
                            RecSalesHeader.Validate(
                                "Invoice Discount Value",
                                (lREMISEDOSSIER / (lPRIXDOSSIER_TTC + lREMISEDOSSIER)) * 100);
                    RecSalesHeader.Modify(true);
                end;

                lREMISELDTTOT := 0;
                lPRIXLDTTTCTOT := 0;

                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'TexteDMS', Text0003);
                AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecSalesHeader."No.");

                for i := 1 to XmlNodesLDT.Count() do begin
                    XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                    LigneDT_ID := GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID');
                    XMLNodeLDT_Temp.AsXmlElement().SelectNodes('PR', XMLNodesPR);

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

                    if eDMSSetup."SBX Discount allowed LDT" and
                       CheckUserPermissionAPV('APV_MODIFY', RecUserSetup) then begin
                        Evaluate(lREMISELDT,
                            ConvertStr(GetAttributeValue(
                                XMLNodeLDT_Temp.AsXmlElement(), 'REMISE_PRICING_LDT'), '.', ','));
                        Evaluate(lPRIXLDTTTC,
                            ConvertStr(GetAttributeValue(
                                XMLNodeLDT_Temp.AsXmlElement(), 'PRIXTTC_LDT'), '.', ','));
                        lREMISELDTTOT += lREMISELDT;
                        lPRIXLDTTTCTOT += lPRIXLDTTTC;
                    end;

                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', LigneDT_ID);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', LigneDT_ID);
                end;

                // [FIX-6] Même correction que ci-dessus pour le discount LDT
                if eDMSSetup."SBX Discount allowed LDT" then begin
                    if (lREMISELDTTOT + lPRIXLDTTTCTOT) > 0 then
                        RecSalesHeader.Validate(
                            "Invoice Discount Value",
                            RecSalesHeader."Invoice Discount Value" +
                            ((lREMISELDTTOT / (lREMISELDTTOT + lPRIXLDTTTCTOT)) * 100));
                    RecSalesHeader.Modify(true);
                end;

            end else begin
                ErrorResponse(XMLRoot, Text0007);
                for i := 1 to XmlNodesLDT.Count() do begin
                    XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID',
                        GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                end;
            end;

            // ======================================================================
            // ORIGINEVENTE ≠ '1' → Dossier service APV
            // ======================================================================
        end else begin

            if GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage') <> '' then
                Evaluate(Kilometrage,
                    DelChr(GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage'), '=', ' '));

            RecVehicle.Reset();
            RecVehicle.SetRange("VIN", GetAttributeValue(XMLNodeVehicle, 'VIN'));
            if RecVehicle.FindFirst() then
                if Kilometrage > RecVehicle."Variable Field Run 1" then begin
                    RecVehicle."Variable Field Run 1" := Kilometrage;
                    RecVehicle.Modify(true);
                end;

            // ==================================================================
            // Nième transfert → Mise à jour dossier existant
            // ==================================================================
            if GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID') <> '' then begin

                if not CheckUserPermissionAPV('APV_MODIFY', RecUserSetup) then begin
                    ErrorResponse(XMLRoot, Text0005);
                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID',
                            GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                    end;
                    exit;
                end;

                RecServiceHeader.Reset();
                RecServiceHeader.SetRange("Document Type", RecServiceHeader."Document Type"::Order);
                RecServiceHeader.SetRange("No.", GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID'));

                if RecServiceHeader.FindFirst() then begin

                    // [FIX-4] Pickup Date (et non Order Date) dans le Nième transfert
                    if (GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT') <> '') and
                       (GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT') <> '') and
                       (GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT') <> '') then begin
                        Evaluate(lDAY, GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT'));
                        Evaluate(lMonth, GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT'));
                        Evaluate(lYEAR, GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT'));
                        // TODO: Vérifier le nom exact du champ "Pickup Date" dans la table Service Header EDMS
                        //RecServiceHeader."Pickup Date" := DMY2Date(lDAY, lMonth, lYEAR);
                        RecServiceHeader."Order Date" := DMY2Date(lDAY, lMonth, lYEAR); // à remplacer par Pickup Date
                    end;

                    // [FIX-3] Pickup Time et TPSIMMO — champs à localiser dans la table BC
                    // TODO: RecServiceHeader."Pickup Time" :=
                    //           GetAttributeValue(XMLNodeReq,'HEURESRDV_RESTIT') + ':' +
                    //           GetAttributeValue(XMLNodeReq,'MINUTESRDV_RESTIT');
                    // TODO: Evaluate(RecServiceHeader.TPSIMMO, GetAttributeValue(XMLNodeReq,'TPSIMMO'));

                    RecServiceHeader.Modify(true);

                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'TexteDMS', Text0004);
                    AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");

                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);

                        eDMSSetup.Get();
                        if eDMSSetup.interfaceVersion = '13' then
                            lCodeUpdateDelete := 'CODEVENTILATION_LDT'
                        else
                            lCodeUpdateDelete := 'TYPEIMPUTATION_LDT';

                        if GetAttributeValue(
                            XMLNodeLDT_Temp.AsXmlElement(), lCodeUpdateDelete) = '99' then
                            DeleteLDT(RecServiceHeader, XMLNodeLDT_Temp.AsXmlElement())

                        else begin
                            if GetAttributeValue(
                                XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID_DMS') <> '' then begin

                                Evaluate(JobLineNo,
                                    GetAttributeValue(
                                        XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID_DMS'));

                                RecServiceJobLine.Reset();
                                RecServiceJobLine.SetRange("Document Type", RecServiceHeader."Document Type");
                                RecServiceJobLine.SetRange("Document No.", RecServiceHeader."No.");
                                // [FIX-9] Original C/AL utilise "Line No." — à confirmer vs "Task No." en BC
                                RecServiceJobLine.SetRange("Task No.", JobLineNo);
                                // RecServiceJobLine.SetRange("Task No.", JobLineNo); // Alternative BC

                                if RecServiceJobLine.FindFirst() then begin
                                    UpdateLDT(RecServiceHeader,
                                        XMLNodeLDT_Temp.AsXmlElement(), XMLRoot);
                                    // Bloc AddElement/AddAttribute géré dans UpdateLDT (identique à l'original)
                                end else
                                    InsertLDT(RecServiceHeader,
                                        XMLNodeLDT_Temp.AsXmlElement(), XMLRoot);

                            end else
                                InsertLDT(RecServiceHeader,
                                    XMLNodeLDT_Temp.AsXmlElement(), XMLRoot);
                        end;
                    end;
                end;

                // ==================================================================
                // 1er transfert → Création d'un nouveau dossier APV
                // ==================================================================
            end else begin

                if not CheckUserPermissionAPV('APV_CREATE', RecUserSetup) then begin
                    ErrorResponse(XMLRoot, Text0006);
                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID',
                            GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                    end;
                    exit;
                end;

                if GetAttributeValue(XMLNodeCustomer, 'Observations') = '' then begin
                    ErrorResponse(XMLRoot, Text0002);
                    for i := 1 to XmlNodesLDT.Count() do begin
                        XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                        AddElement(XMLRoot, 'LDT', TmpNode);
                        AddAttribute(TmpNode, 'LIGNE_DT_ID',
                            GetAttributeValue(XMLNodeLDT_Temp.AsXmlElement(), 'LIGNE_DT_ID'));
                    end;
                    exit;
                end;

                RecServiceHeader.Init();
                RecServiceHeader."Document Type" := RecServiceHeader."Document Type"::Order;

                // [FIX-1] Champs présents dans l'original C/AL
                RecServiceHeader."Location Code" := RecServiceLocation.Code;
                // TODO: Vérifier le nom exact du champ Branch Code en BC
                // RecServiceHeader."Branch Code"   := RecLocation."Branch Code";

                // [FIX-1] Réceptionnaire = utilisateur connecté
                //RecServiceHeader.Réceptionnaire := RecUserSetup."User ID";
                // TODO: Si le champ s'appelle différemment en BC :
                // RecServiceHeader."Receptionist Code" := RecUserSetup."User ID";

                // [FIX-1] Dossier SBOX
                RecServiceHeader."SBX Dossier SBOX" := true;

                // [FIX-1] Order Limit depuis Observations
                Evaluate(RecServiceHeader."SBX Order Limit",
                    GetAttributeValue(XMLNodeCustomer, 'Observations'));

                RecServiceHeader.Insert(true);
                RecServiceHeader.SetHideValidationDialog(true);

                if GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID') <> '' then begin
                    if RecCustomer.Get(GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID')) then
                        RecServiceHeader.Validate(
                            "Sell-to Customer No.",
                            GetAttributeValue(XMLNodeCustomer, 'CLIENT_DMS_ID'))
                    else
                        RecServiceHeader.Validate(
                            "Sell-to Customer No.",
                            eDMSSetup."SBX Customer Imputation Account");
                end else
                    RecServiceHeader.Validate(
                        "Sell-to Customer No.",
                        eDMSSetup."SBX Customer Imputation Account");

                RecServiceHeader.Validate(VIN, GetAttributeValue(XMLNodeVehicle, 'VIN'));

                // [FIX-1] Kilométrage
                Evaluate(RecServiceHeader."Variable Field Run 1",
                    DelChr(GetAttributeValue(XMLNodeVehicle, 'DernierKilometrage'), '=', ' '));

                // [FIX-1] Department Code depuis RecUserSetup
                // RecServiceHeader.Validate("Department Code", RecUserSetup."Department Code");

                // Date RDV (Order Date)
                if (GetAttributeValue(XMLNodeReq, 'JOURRDV') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'MOISRDV') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'ANNEERDV') <> '') then begin
                    Evaluate(lDAY, GetAttributeValue(XMLNodeReq, 'JOURRDV'));
                    Evaluate(lMonth, GetAttributeValue(XMLNodeReq, 'MOISRDV'));
                    Evaluate(lYEAR, GetAttributeValue(XMLNodeReq, 'ANNEERDV'));
                    RecServiceHeader."Order Date" := DMY2Date(lDAY, lMonth, lYEAR);
                end;

                // [FIX-3] Time of Order — champ à localiser dans la table BC
                // TODO: if Evaluate(RecServiceHeader."Time of Order",
                //           GetAttributeValue(XMLNodeReq,'HEURESRDV') + ':' +
                //           GetAttributeValue(XMLNodeReq,'MINUTESRDV')) then ;

                // Date restitution (Pickup Date)
                if (GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT') <> '') and
                   (GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT') <> '') then begin
                    Evaluate(lDAY, GetAttributeValue(XMLNodeReq, 'JOURRDV_RESTIT'));
                    Evaluate(lMonth, GetAttributeValue(XMLNodeReq, 'MOISRDV_RESTIT'));
                    Evaluate(lYEAR, GetAttributeValue(XMLNodeReq, 'ANNEERDV_RESTIT'));
                    // TODO: Vérifier le nom exact du champ "Pickup Date" dans la table BC
                    // RecServiceHeader."Pickup Date" := DMY2Date(lDAY, lMonth, lYEAR);
                end;

                // [FIX-3] Pickup Time et TPSIMMO — champs à localiser dans la table BC
                // TODO: if Evaluate(RecServiceHeader."Pickup Time",
                //           GetAttributeValue(XMLNodeReq,'HEURESRDV_RESTIT') + ':' +
                //           GetAttributeValue(XMLNodeReq,'MINUTESRDV_RESTIT')) then ;
                // TODO: if Evaluate(RecServiceHeader.TPSIMMO, GetAttributeValue(XMLNodeReq,'TPSIMMO')) then ;

                RecServiceHeader.Modify(true);

                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'TexteDMS', Text0003);
                AddAttribute(XMLRoot, 'DOSSIER_DMS_ID', RecServiceHeader."No.");

                for i := 1 to XmlNodesLDT.Count() do begin
                    XmlNodesLDT.Get(i, XMLNodeLDT_Temp);
                    InsertLDT(RecServiceHeader, XMLNodeLDT_Temp.AsXmlElement(), XMLRoot);
                end;

                // [FIX-5] Impression du dossier — réintégrée depuis l'original C/AL
                if GetAttributeValue(XMLNodeCustomer, 'IMPRIM') = '1' then
                    PrintOrder(RecServiceHeader, GetAttributeValue(XMLNodeReq, 'NumeroPoste'));

            end;
        end;


    end;

    procedure PrintOrder(ServiceHeader: Record "Service Header EDMS"; NumeroPoste: Text[30])
    var
        ServHdr: Record "Service Header EDMS";
    begin
        ServHdr.SetRange("Document Type", ServiceHeader."Document Type");
        ServHdr.SetRange("No.", ServiceHeader."No.");
        if ServHdr.FindFirst() then
            Report.Run(5025619, false, true, ServHdr);
    end;

    procedure InsertLDTInsertLineSboxForfait(
           RecServiceHeader: Record "Service Header EDMS";
           XMLNodeLDT: XmlElement;
           var XMLRoot: XmlElement)
    var
        XMLNodesPR, XMLNodesMO : XmlNodeList;
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        Package: Record "Service Package";
        Vehicle: Record Vehicle;
        eDMSSetup: Record "STF Servicebox Setup";
        TmpNode: XmlElement;
        XMLNodePR_Temp: XmlNode;
        XMLNodeMO_Temp: XmlNode;
        i: Integer;
        version: Integer;
        IDFORFAIT_Attribute_value: Text[30];
        CODEIMPUTATION_LDT_value: Code[20];
        Text0001: Label 'Aucune version active pour le forfait indiqué !';
        Text0002: Label 'Véhicule introuvable dans Business Central.';
    begin

        // =========================================================
        // CAS 1 : LDT avec un FORFAIT (IDFORFAIT rempli)
        // =========================================================
        if GetAttributeValue(XMLNodeLDT, 'IDFORFAIT') <> '' then begin

            IDFORFAIT_Attribute_value := GetAttributeValue(XMLNodeLDT, 'IDFORFAIT');

            Vehicle.Reset();
            Vehicle.SetRange("VIN", RecServiceHeader.VIN);
            if not Vehicle.FindFirst() then begin
                ErrorResponse(XMLRoot, Text0002);
                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                exit;
            end;

            Package.Reset();
            Package.SetRange("Make Code", RecServiceHeader."Make Code");
            Package.SetRange("No.", IDFORFAIT_Attribute_value);

            // ── A. Forfait existant dans le DMS (Standard) ────────────────
            if Package.FindFirst() and not Package.Blocked then begin
                version := GetPackageVersion(Package."Make Code", Package."No.");

                if version <> 0 then begin
                    RecServiceJobLine.Init();
                    RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
                    RecServiceJobLine."Document No." := RecServiceHeader."No.";
                    RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);
                    RecServiceJobLine.Commentaire := GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL');
                    RecServiceJobLine."Symptome Code" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

                    CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
                    CheckCustomerByTypeImputation(GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT'), CODEIMPUTATION_LDT_value);
                    RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

                    Evaluate(RecServiceJobLine."Symptome Description", GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT'));

                    RecServiceJobLine.Validate("Package No.", IDFORFAIT_Attribute_value);
                    RecServiceJobLine.Validate("Package Version No.", version);

                    eDMSSetup.Get();
                    if GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT') = Format(eDMSSetup."SBX Insurance Imputation Code") then
                        RecServiceJobLine.Validate("SBX Assurance", true);

                    RecServiceJobLine.Insert(true);
                    CleanServCustSplitUp(RecServiceJobLine, CODEIMPUTATION_LDT_value);

                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                    AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));
                end else begin
                    ErrorResponse(XMLRoot, Text0001);
                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                end;

                // ── B. Forfait SBOX (Non créé dans le DMS) ───────────────────
            end else begin
                // 1. On crée la ligne de Job d'abord
                RecServiceJobLine.Init();
                RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
                RecServiceJobLine."Document No." := RecServiceHeader."No.";
                RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);
                RecServiceJobLine.Commentaire := GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL');
                RecServiceJobLine."Symptome Code" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

                CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
                CheckCustomerByTypeImputation(GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT'), CODEIMPUTATION_LDT_value);
                RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

                RecServiceJobLine."Package Type" := RecServiceJobLine."Package Type"::SBOX;
                RecServiceJobLine."Package No." := CopyStr(IDFORFAIT_Attribute_value, 1, 14);
                RecServiceJobLine."Package Version No." := 10000;
                RecServiceJobLine."sbx SBOX Forfait" := CopyStr(IDFORFAIT_Attribute_value, 1, 14);
                RecServiceJobLine."SBX SBOX CodeTypeVehicule" := CopyStr(IDFORFAIT_Attribute_value, 15);
                RecServiceJobLine."SBX SBOX LDT" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

                // Gestion des prix forfait SBOX
                if Evaluate(RecServiceJobLine."SBX SBOX PrixHT Forfait", ConvertStr(GetAttributeValue(XMLNodeLDT, 'PRIXHT_LDT'), '.', ',')) then;
                if Evaluate(RecServiceJobLine."SBX SBOX PrixTTC Forfait", ConvertStr(GetAttributeValue(XMLNodeLDT, 'PRIXTTC_LDT'), '.', ',')) then;

                RecServiceJobLine.Insert(true); // INSERTION ICI pour permettre aux lignes PR/MO de se lier

                // 2. Insertion des PR et MO (On utilise les vraies fonctions InsertPR/MO)
                XMLNodeLDT.SelectNodes('PR', XMLNodesPR);
                XMLNodeLDT.SelectNodes('MO', XMLNodesMO);

                for i := 1 to XMLNodesPR.Count() do begin
                    XMLNodesPR.Get(i, XMLNodePR_Temp);
                    InsertPRServiceLine(RecServiceJobLine, XMLNodePR_Temp.AsXmlElement());
                end;

                for i := 1 to XMLNodesMO.Count() do begin
                    XMLNodesMO.Get(i, XMLNodeMO_Temp);
                    InsertMOServiceLine(RecServiceJobLine, XMLNodeMO_Temp.AsXmlElement());
                end;

                RecServiceJobLine.Modify(true);

                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));
            end;

            // =========================================================
            // CAS 2 : LDT STANDARD (Sans forfait)
            // =========================================================
        end else begin
            RecServiceJobLine.Init();
            RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
            RecServiceJobLine."Document No." := RecServiceHeader."No.";
            RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);
            RecServiceJobLine.Commentaire := GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL');

            CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
            CheckCustomerByTypeImputation(GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT'), CODEIMPUTATION_LDT_value);
            RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

            Evaluate(RecServiceJobLine."Symptome Description", GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT'));
            RecServiceJobLine."SBX SBOX LDT" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

            RecServiceJobLine.Insert(true);

            XMLNodeLDT.SelectNodes('PR', XMLNodesPR);
            XMLNodeLDT.SelectNodes('MO', XMLNodesMO);

            for i := 1 to XMLNodesPR.Count() do begin
                XMLNodesPR.Get(i, XMLNodePR_Temp);
                InsertPRServiceLine(RecServiceJobLine, XMLNodePR_Temp.AsXmlElement());
            end;

            for i := 1 to XMLNodesMO.Count() do begin
                XMLNodesMO.Get(i, XMLNodeMO_Temp);
                InsertMOServiceLine(RecServiceJobLine, XMLNodeMO_Temp.AsXmlElement());
            end;

            AddElement(XMLRoot, 'LDT', TmpNode);
            AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
            AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));
        end;
    end;


    procedure InsertLDT(
          RecServiceHeader: Record "Service Header EDMS";
          XMLNodeLDT: XmlElement;
          var XMLRoot: XmlElement)
    var
        XMLNodesPR, XMLNodesMO : XmlNodeList;
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        Package: Record "Service Package";
        Vehicle: Record Vehicle;
        eDMSSetup: Record "STF Servicebox Setup";
        TmpNode: XmlElement;
        XMLNodePR_Temp: XmlNode;
        XMLNodeMO_Temp: XmlNode;
        i: Integer;
        version: Integer;
        IDFORFAIT_Attribute_value: Text[30];
        CODEIMPUTATION_LDT_value: Code[20];
        LocalCodeMarkSBOX: Code[20];
        Text0001: Label 'Aucune version active pour le forfait indiqué !';
        Text0002: Label 'Véhicule introuvable dans Business Central.';
    begin

        // =========================================================
        // CAS 1 : LDT de type FORFAIT (IDFORFAIT renseigné)
        // =========================================================
        if GetAttributeValue(XMLNodeLDT, 'IDFORFAIT') <> '' then begin

            IDFORFAIT_Attribute_value := GetAttributeValue(XMLNodeLDT, 'IDFORFAIT');

            // Recherche du véhicule — comportement identique à vehicle.GET de l'original
            Vehicle.Reset();
            Vehicle.SetRange("VIN", RecServiceHeader.VIN);
            if not Vehicle.FindFirst() then begin
                ErrorResponse(XMLRoot, Text0002);
                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                exit;
            end;

            Package.Reset();
            Package.SetRange("Make Code", RecServiceHeader."Make Code");
            Package.SetRange("No.", IDFORFAIT_Attribute_value);

            // ── A. Forfait DMS standard (Package trouvé et non bloqué) ────────────
            if Package.FindFirst() and not Package.Blocked then begin

                version := GetPackageVersion(Package."Make Code", Package."No.");

                if version <> 0 then begin

                    RecServiceJobLine.Init();
                    RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
                    RecServiceJobLine."Document No." := RecServiceHeader."No.";
                    RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);

                    // [IFIX-4] CopyStr limité à 50 car = Complaint Text[50] dans l'original
                    RecServiceJobLine.Commentaire := CopyStr(GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL'), 1, 50);
                    RecServiceJobLine."Symptome Code" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

                    CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
                    CheckCustomerByTypeImputation(
                        GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'),
                        CODEIMPUTATION_LDT_value);
                    RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

                    Evaluate(RecServiceJobLine."Symptome Description",
                        GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'));

                    RecServiceJobLine.Validate("Package No.", IDFORFAIT_Attribute_value);
                    RecServiceJobLine.Validate("Package Version No.", version);

                    eDMSSetup.Get();
                    if GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT') =
                       Format(eDMSSetup."SBX Insurance Imputation Code") then
                        RecServiceJobLine.Validate("SBX Assurance", true);

                    RecServiceJobLine.Insert(true);
                    CleanServCustSplitUp(RecServiceJobLine, CODEIMPUTATION_LDT_value);

                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                    AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));

                end else begin
                    // Aucune version active pour ce forfait
                    ErrorResponse(XMLRoot, Text0001);
                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                end;

                // ── B. Forfait SBOX (Package introuvable dans le DMS) ─────────────────
            end else begin

                // Ordre original C/AL : InsertTempPR/MO EN PREMIER, puis Init/Insert de JobLine
                XMLNodeLDT.SelectNodes('PR', XMLNodesPR);
                XMLNodeLDT.SelectNodes('MO', XMLNodesMO);



                RecServiceJobLine.Init();
                RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
                RecServiceJobLine."Document No." := RecServiceHeader."No.";
                RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);

                // [IFIX-4] CopyStr limité à 50
                RecServiceJobLine.Commentaire := CopyStr(GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL'), 1, 50);
                RecServiceJobLine."Symptome Code" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

                CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
                CheckCustomerByTypeImputation(
                    GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'),
                    CODEIMPUTATION_LDT_value);
                RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

                Evaluate(RecServiceJobLine."Symptome Description",
                    GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'));

                // Champs spécifiques forfait SBOX
                RecServiceJobLine."Package Type" := RecServiceJobLine."Package Type"::SBOX;
                RecServiceJobLine."Package No." := CopyStr(IDFORFAIT_Attribute_value, 1, 14);
                // [IFIX-1] Valeur 1000 conforme à l'original C/AL (InsertLDTLV avait 10000 — erreur)
                RecServiceJobLine."Package Version No." := 1000;
                RecServiceJobLine."SBX SBOX Forfait" := CopyStr(IDFORFAIT_Attribute_value, 1, 14);
                RecServiceJobLine."SBX SBOX CodeTypeVehicule" := CopyStr(IDFORFAIT_Attribute_value, 15);
                RecServiceJobLine."SBX SBOX LDT" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');
                RecServiceJobLine."SBX SBOX TYPE IMPUTATION" := GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT');

                // [IFIX-2] ConvertStr('.', ',') — sens correct pour Evaluate en locale FR
                //          InsertLDTLV avait inversé en (',', '.') ce qui est faux
                if Evaluate(RecServiceJobLine."SBX SBOX PrixHT Forfait",
                    ConvertStr(GetAttributeValue(XMLNodeLDT, 'PRIXHT_LDT'), '.', ',')) then;
                if Evaluate(RecServiceJobLine."SBX SBOX PrixTTC Forfait",
                    ConvertStr(GetAttributeValue(XMLNodeLDT, 'PRIXTTC_LDT'), '.', ',')) then;


                LocalCodeMarkSBOX := CodeMarkSBOX;   // variable globale du codeunit
                if LocalCodeMarkSBOX = '' then
                    LocalCodeMarkSBOX := 'PEUGEOT';
                RecServiceJobLine."Make Code" := LocalCodeMarkSBOX;

                eDMSSetup.Get();
                if GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT') =
                   Format(eDMSSetup."SBX Insurance Imputation Code") then
                    RecServiceJobLine.Validate("SBX Assurance", true);

                RecServiceJobLine.Insert(true);
                CleanServCustSplitUp(RecServiceJobLine, CODEIMPUTATION_LDT_value);

                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));
            end;

            // =========================================================
            // CAS 2 : LDT standard (sans forfait)
            // =========================================================
        end else begin

            RecServiceJobLine.Init();
            RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
            RecServiceJobLine."Document No." := RecServiceHeader."No.";
            RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);

            // [IFIX-4] CopyStr limité à 50
            RecServiceJobLine.Commentaire := CopyStr(GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL'), 1, 50);

            CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
            CheckCustomerByTypeImputation(
                GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'),
                CODEIMPUTATION_LDT_value);
            RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

            Evaluate(RecServiceJobLine."Symptome Description",
                GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'));

            RecServiceJobLine."SBX SBOX LDT" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

            eDMSSetup.Get();
            if GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT') =
               Format(eDMSSetup."SBX Insurance Imputation Code") then
                RecServiceJobLine.Validate("SBX Assurance", true);

            RecServiceJobLine.Insert(true);
            CleanServCustSplitUp(RecServiceJobLine, CODEIMPUTATION_LDT_value);

            AddElement(XMLRoot, 'LDT', TmpNode);
            AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
            AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));

            // Insertion des lignes PR et MO (après AddElement — identique à l'original)
            XMLNodeLDT.SelectNodes('PR', XMLNodesPR);
            XMLNodeLDT.SelectNodes('MO', XMLNodesMO);

            for i := 1 to XMLNodesPR.Count() do begin
                XMLNodesPR.Get(i, XMLNodePR_Temp);
                InsertPRServiceLine(RecServiceJobLine, XMLNodePR_Temp.AsXmlElement());
            end;

            for i := 1 to XMLNodesMO.Count() do begin
                XMLNodesMO.Get(i, XMLNodeMO_Temp);
                InsertMOServiceLine(RecServiceJobLine, XMLNodeMO_Temp.AsXmlElement());
            end;
        end;
        // NOTE : LDTNo := RecServiceJobLine."Line No." présent en commentaire dans l'original
        //        → non migré car déjà commenté à la source.
    end;


    procedure InsertLDTLV(RecServiceHeader: Record "Service Header EDMS"; XMLNodeLDT: XmlElement; var XMLRoot: XmlElement)
    var
        XMLNodesPR, XMLNodesMO : XmlNodeList;
        RecServiceJobLine: Record "Service Order Symptome  EDMS";
        Package: Record "Service Package";
        Vehicle: Record Vehicle;
        eDMSSetup: Record "STF Servicebox Setup";
        TmpNode: XmlElement;
        XMLNodePR_Temp: XmlNode;
        XMLNodeMO_Temp: XmlNode;
        i: Integer;
        version: Integer;
        IDFORFAIT_Attribute_value: Text[30];
        CODEIMPUTATION_LDT_value: Code[20];
        Text0001: Label 'Aucune version active pour le forfait indiqué !';
        Text0002: Label 'Véhicule introuvable dans Business Central.';
    begin

        // =========================================================
        // CAS 1 : LDT de type FORFAIT (IDFORFAIT renseigné)
        // =========================================================
        if GetAttributeValue(XMLNodeLDT, 'IDFORFAIT') <> '' then begin

            IDFORFAIT_Attribute_value := GetAttributeValue(XMLNodeLDT, 'IDFORFAIT');

            // [5] CORRIGÉ : GET → erreur explicite si VIN inexistant
            //     (l'original faisait vehicle.GET qui plantait proprement)
            //     On reproduit ce comportement : si pas trouvé, on sort avec erreur

            Vehicle.Reset();
            Vehicle.SetRange("VIN", RecServiceHeader.VIN);

            if not Vehicle.FindFirst() then begin

                ErrorResponse(XMLRoot, Text0002);
                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                exit;
            end;

            Package.Reset();
            Package.SetRange("Make Code", RecServiceHeader."Make Code");
            Package.SetRange("No.", IDFORFAIT_Attribute_value);

            // ── Forfait DMS (Package trouvé et non bloqué) ─────────────────────
            if Package.FindFirst() and not Package.Blocked then begin

                version := GetPackageVersion(Package."Make Code", Package."No.");

                if version <> 0 then begin

                    RecServiceJobLine.Init();
                    RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
                    RecServiceJobLine."Document No." := RecServiceHeader."No.";
                    RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);

                    // [1] Champs dans le bon sens (identique à l'original)
                    //     Complaint  = LIBELLE_LIGNE_TRAVAIL  → Commentaire
                    //     Complaint 2 = LIGNE_DT_ID           → Symptome Code
                    RecServiceJobLine.Commentaire := GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL');//CopyStr(GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL'), 1, 50);
                    RecServiceJobLine."Symptome Code" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

                    CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
                    CheckCustomerByTypeImputation(
                        GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'),
                        CODEIMPUTATION_LDT_value);
                    RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

                    // Code d'imputation (TypeXX = 'TYPEFACTURATION' ou 'TYPEIMPUTATION')
                    Evaluate(RecServiceJobLine."Symptome Description",
                        GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'));

                    RecServiceJobLine.Validate("Package No.", IDFORFAIT_Attribute_value);
                    RecServiceJobLine.Validate("Package Version No.", version);

                    eDMSSetup.Get();
                    if GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT') =
                       Format(eDMSSetup."SBX Insurance Imputation Code") then
                        RecServiceJobLine.Validate("SBX Assurance", true);

                    RecServiceJobLine.Insert(true);

                    // [4] CORRIGÉ : nettoyage ServCustSplitUp après Insert (branche forfait DMS)
                    CleanServCustSplitUp(RecServiceJobLine, CODEIMPUTATION_LDT_value);

                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                    AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));

                end else begin
                    // Aucune version active pour ce forfait
                    ErrorResponse(XMLRoot, Text0001);
                    AddElement(XMLRoot, 'LDT', TmpNode);
                    AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                end;

                // ── Forfait SBOX (Package introuvable dans le DMS) ─────────────────
            end else begin


                XMLNodeLDT.SelectNodes('PR', XMLNodesPR);
                XMLNodeLDT.SelectNodes('MO', XMLNodesMO);


                RecServiceJobLine.Init();
                RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
                RecServiceJobLine."Document No." := RecServiceHeader."No.";
                RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);

                // [2] CORRIGÉ : champs dans le bon sens (étaient inversés)
                //     Complaint  = LIBELLE_LIGNE_TRAVAIL  → Commentaire
                //     Complaint 2 = LIGNE_DT_ID           → Symptome Code
                RecServiceJobLine.Commentaire := GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL');// CopyStr(GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL'), 1, 50);
                RecServiceJobLine."Symptome Code" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

                CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
                CheckCustomerByTypeImputation(
                    GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'),
                    CODEIMPUTATION_LDT_value);
                RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

                // Champs spécifiques forfait SBOX
                RecServiceJobLine."Package Type" := RecServiceJobLine."Package Type"::SBOX;

                RecServiceJobLine."Package No." := CopyStr(IDFORFAIT_Attribute_value, 1, 14);
                RecServiceJobLine."Package Version No." := 10000;
                RecServiceJobLine."SBX SBOX Forfait" := CopyStr(IDFORFAIT_Attribute_value, 1, 14);
                RecServiceJobLine."SBX SBOX CodeTypeVehicule" := CopyStr(IDFORFAIT_Attribute_value, 15);
                RecServiceJobLine."SBX SBOX LDT" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');
                RecServiceJobLine."SBX SBOX TYPE IMPUTATION" := GetAttributeValue(XMLNodeLDT, 'CODEIMPUTATION_LDT');

                if Evaluate(RecServiceJobLine."SBX SBOX PrixHT Forfait",
     ConvertStr(GetAttributeValue(XMLNodeLDT, 'PRIXHT_LDT'), ',', '.'), 9) then;
                if Evaluate(RecServiceJobLine."SBX SBOX PrixTTC Forfait",
                    ConvertStr(GetAttributeValue(XMLNodeLDT, 'PRIXTTC_LDT'), ',', '.'), 9) then;
                eDMSSetup.Get();
                if GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT') =
                   Format(eDMSSetup."SBX Insurance Imputation Code") then
                    RecServiceJobLine.Validate("SBX Assurance", true);

                RecServiceJobLine.Insert(true);

                // [4] CORRIGÉ : nettoyage ServCustSplitUp après Insert (branche forfait SBOX)
                CleanServCustSplitUp(RecServiceJobLine, CODEIMPUTATION_LDT_value);

                AddElement(XMLRoot, 'LDT', TmpNode);
                AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
                AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));
            end;

            // =========================================================
            // CAS 2 : LDT standard (sans forfait)
            // =========================================================
        end else begin

            RecServiceJobLine.Init();
            RecServiceJobLine."Document Type" := RecServiceHeader."Document Type";
            RecServiceJobLine."Document No." := RecServiceHeader."No.";
            RecServiceJobLine."Task No." := GetNextJobLineNo(RecServiceHeader);
            RecServiceJobLine.Commentaire := GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL');//CopyStr(GetAttributeValue(XMLNodeLDT, 'LIBELLE_LIGNE_TRAVAIL'), 1, 50);

            // [3] CORRIGÉ : CheckCustomerByTypeImputation réactivée (était commentée)
            CODEIMPUTATION_LDT_value := RecServiceHeader."Sell-to Customer No.";
            CheckCustomerByTypeImputation(
                GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'),
                CODEIMPUTATION_LDT_value);
            RecServiceJobLine.Validate("Bill-to Customer No.", CODEIMPUTATION_LDT_value);

            // Code d'imputation
            Evaluate(RecServiceJobLine."Symptome Description",
                GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT'));

            RecServiceJobLine."SBX SBOX LDT" := GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID');

            eDMSSetup.Get();
            if GetAttributeValue(XMLNodeLDT, TypeXX + '_LDT') =
               Format(eDMSSetup."SBX Insurance Imputation Code") then
                RecServiceJobLine.Validate("SBX Assurance", true);

            RecServiceJobLine.Insert(true);

            // [4] CORRIGÉ : nettoyage ServCustSplitUp après Insert (branche LDT standard)
            CleanServCustSplitUp(RecServiceJobLine, CODEIMPUTATION_LDT_value);

            AddElement(XMLRoot, 'LDT', TmpNode);
            AddAttribute(TmpNode, 'LIGNE_DT_ID', GetAttributeValue(XMLNodeLDT, 'LIGNE_DT_ID'));
            AddAttribute(TmpNode, 'LIGNE_DT_ID_DMS', Format(RecServiceJobLine."Task No."));

            // Insérer les lignes PR et MO
            XMLNodeLDT.SelectNodes('PR', XMLNodesPR);
            XMLNodeLDT.SelectNodes('MO', XMLNodesMO);

            for i := 1 to XMLNodesPR.Count() do begin
                XMLNodesPR.Get(i, XMLNodePR_Temp);
                InsertPRServiceLine(RecServiceJobLine, XMLNodePR_Temp.AsXmlElement());
            end;

            for i := 1 to XMLNodesMO.Count() do begin
                XMLNodesMO.Get(i, XMLNodeMO_Temp);
                InsertMOServiceLine(RecServiceJobLine, XMLNodeMO_Temp.AsXmlElement());
            end;
        end;
    end;

    local procedure CleanServCustSplitUp(
           RecServiceJobLine: Record "Service Order Symptome  EDMS";
           CODEIMPUTATION_LDT_value: Code[20])
    var
        ServSplittingLine: Record "Service Splitting Line";
    begin
        ServSplittingLine.Reset();
        ServSplittingLine.SetRange("Document Type", RecServiceJobLine."Document Type");
        ServSplittingLine.SetRange("Document No.", RecServiceJobLine."Document No.");
        ServSplittingLine.SetRange("DLT Instruction Line", RecServiceJobLine."Task No.");
        ServSplittingLine.SetFilter("Bill-to Customer No.", '<>%1', CODEIMPUTATION_LDT_value);
        if ServSplittingLine.FindSet() then
            repeat
                ServSplittingLine.Delete(true);
            until ServSplittingLine.Next() = 0;
    end;

    procedure CheckUserPermissionAPV(Permission: Text[30]; User: Record "User Setup"): Boolean
    var
        Text0100: Label 'APV_CREATE';
        Text0101: Label 'APV_MODIFY';
        Text0102: Label 'APV_DISCOUNT';
    begin
        case Permission of
            Text0100:
                exit(true);
            Text0101:
                exit(true);
            Text0102:
                exit(true);
            else
                exit(false);
        end;
    end;




    procedure GetPackageVersion(MakeCode: Code[10]; PackageNo: Code[20]): Integer
    var
        PkgVers: Record "Service Package Version";
    begin
        PkgVers.Reset();
        PkgVers.SetRange("Make Code", MakeCode);
        PkgVers.SetRange("Package No.", PackageNo);

        if PkgVers.FindLast() then
            exit(PkgVers."Version No.");

        exit(0);
    end;


    /// <summary>
    /// Valoriser un forfait (LZRF47T24)
    /// Migré depuis C/AL vers AL (Business Central)
    /// Tables : "Service Package" (5025615 → RecPackageVersion),
    ///          "Service Package Version Line" (5025611 → RecPackageBOM)
    /// </summary>
    procedure LZRF47T24V1OLD(var XMLDom: XmlElement; XMLNodeReq: XmlElement)
    var
        RecPackageVersion: Record "Service Package Version";
        RecPackageBOM: Record "Service Package Version Line";
        XMLRoot: XmlElement;
        XMLNodeFF: XmlElement;
        XMLNode: XmlElement;
        XMLNodeMO: XmlElement;
        XMLNodePR: XmlElement;
        XMLNodesLDT: XmlNodeList;
        XMLNodeLDT: XmlNode;
        XMLNodeLDTElem: XmlElement;
        TmpNode: XmlNode;
        IDForfait: Text;
        LigneDtId: Text;
        TotalHT: Decimal;
        RootFound: Boolean;
        NodesFound: Boolean;
    begin
        // VALORISER UN FORFAIT
        // XMLDom est le nœud DMS (XmlElement) — plus de XmlDocument

        // Recherche du nœud LZRF47 sous DMS
        RootFound := XMLDom.SelectSingleNode('LZRF47', TmpNode);
        if RootFound then
            XMLRoot := TmpNode.AsXmlElement();

        // SelectNodes : (XPath: Text; var Result: XmlNodeList) : Boolean
        NodesFound := XMLNodeReq.SelectNodes('LDT', XMLNodesLDT);
        if NodesFound and (XMLNodesLDT.Count > 0) then begin

            if not RootFound then
                AddElement(XMLDom, 'LZRF47', XMLRoot);

            foreach XMLNodeLDT in XMLNodesLDT do begin

                XMLNodeLDTElem := XMLNodeLDT.AsXmlElement();
                GetChildElement(XMLNodeLDTElem, 'FF', XMLNodeFF);

                IDForfait := GetAttributeValue(XMLNodeFF, 'IDFORFAIT');
                LigneDtId := GetAttributeValue(XMLNodeFF, 'LIGNE_DT_ID');

                // Recherche de l'en-tête forfait
                RecPackageVersion.Reset();
                RecPackageVersion.SetFilter("Package No.", IDForfait);
                if RecPackageVersion.FindLast() then begin

                    // ── Calcul du prix HT total depuis les lignes ──────────────────
                    // "Unit Price" est sur "Service Package Version Line", pas sur l'en-tête.
                    // On somme toutes les lignes du forfait pour obtenir le prix global HT.
                    // Pas de champ TTC natif → on utilise la même valeur (TVA gérée côté DMS)
                    TotalHT := 0;
                    RecPackageBOM.Reset();
                    RecPackageBOM.SetFilter("Package No.", RecPackageVersion."Package No.");
                    RecPackageBOM.SetFilter("Version No.", '%1', RecPackageVersion."Version No.");
                    if RecPackageBOM.FindSet() then
                        repeat
                            TotalHT += RecPackageBOM."Unit Price" * RecPackageBOM.Quantity;
                        until RecPackageBOM.Next() = 0;

                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'TexteDMS', '');
                    AddElement(XMLRoot, 'FF', XMLNode);
                    AddAttribute(XMLNode, 'CODE_FF', '2');
                    AddAttribute(XMLNode, 'LIGNE_DT_ID', LigneDtId);
                    AddAttribute(XMLNode, 'LIGNE_DT_ID_DMS', '');
                    AddAttribute(XMLNode, 'IDFORFAIT', RecPackageVersion."Package No.");
                    AddAttribute(XMLNode, 'ReferenceFF', RecPackageVersion."Package No.");
                    AddAttribute(XMLNode, 'LibelleFF', RecPackageVersion.Description);
                    AddAttribute(XMLNode, 'PrixUnitaireHT',
                        Format(TotalHT, 0, '<Precision,2:2><Standard Format,2>'));
                    AddAttribute(XMLNode, 'PrixUnitaireTTC',
                        Format(TotalHT, 0, '<Precision,2:2><Standard Format,2>'));  // ⚠️ adapter si TTC ≠ HT
                    AddAttribute(XMLNode, 'REMISE', '');
                    AddAttribute(XMLNode, 'TexteErreur', '');

                    // ── Parcours des lignes BOM ────────────────────────────────────
                    RecPackageBOM.Reset();
                    RecPackageBOM.SetFilter("Package No.", RecPackageVersion."Package No.");
                    RecPackageBOM.SetFilter("Version No.", '%1', RecPackageVersion."Version No.");
                    if RecPackageBOM.FindFirst() then
                        repeat
                            case RecPackageBOM.Type of

                                RecPackageBOM.Type::Item:
                                    begin
                                        // Pièce (PR)
                                        AddElement(XMLNode, 'PR', XMLNodePR);
                                        AddAttribute(XMLNodePR, 'CODEIMPUTATIONDMS_PR', '');
                                        AddAttribute(XMLNodePR, 'TYPEIMPUTATION_PR', '');
                                        AddAttribute(XMLNodePR, 'REFERENCE_PR', SetItemNo(RecPackageBOM."No."));
                                        AddAttribute(XMLNodePR, 'LIBELLE_PR', RecPackageBOM.Description);
                                        AddAttribute(XMLNodePR, 'TYPE_PR', '2');
                                        AddAttribute(XMLNodePR, 'QuantiteEnCommande',
                                            Format(RecPackageBOM.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                    end;

                                RecPackageBOM.Type::Labor:
                                    begin
                                        // Main d'œuvre (MO)
                                        AddElement(XMLNode, 'MO', XMLNodeMO);
                                        AddAttribute(XMLNodeMO, 'CODEIMPUTATIONDMS_MO', '');
                                        AddAttribute(XMLNodeMO, 'TYPEIMPUTATION_MO', '');
                                        AddAttribute(XMLNodeMO, 'CODEOPERATION', RecPackageBOM."No.");
                                        AddAttribute(XMLNodeMO, 'TYPEOPERATION', '2');
                                        AddAttribute(XMLNodeMO, 'CODETYPEVEHICULE', '');
                                        AddAttribute(XMLNodeMO, 'TEMPSGLOBAL', '1');
                                        AddAttribute(XMLNodeMO, 'TECHNICITE', '1');
                                        AddAttribute(XMLNodeMO, 'METIER', 'T');
                                        AddAttribute(XMLNodeMO, 'LIBELLEOPERATION', RecPackageBOM.Description);
                                    end;

                            // Autres types (Comment, G/L Account, Ext. Service, Resource) : ignorés
                            end;
                        until RecPackageBOM.Next() = 0;

                    // TempRoot   = XMLDom  : nœud DMS où LZRF08T11V1 ajoute le nœud LZRF08
                    // CurrentDMS = XMLNode : nœud FF courant qui contient les PR/MO
                    // RqType     = 'LZRF47'
                    //LZRF08T11V1(XMLNodeReq, XMLDom, XMLDom);
                    LZRF08T11V1(XMLNodeFF, XMLDom, XMLNodeReq);  // ← corrigé

                end else begin

                    // Forfait non trouvé → CODE_FF = '99'
                    AddAttribute(XMLRoot, 'Code', '0');
                    AddAttribute(XMLRoot, 'TexteDMS', '');
                    AddElement(XMLRoot, 'FF', XMLNode);
                    AddAttribute(XMLNode, 'CODE_FF', '99');
                    AddAttribute(XMLNode, 'LIGNE_DT_ID', LigneDtId);
                    AddAttribute(XMLNode, 'LIGNE_DT_ID_DMS', '');
                    AddAttribute(XMLNode, 'IDFORFAIT', IDForfait);
                    AddAttribute(XMLNode, 'ReferenceFF', '');
                    AddAttribute(XMLNode, 'LibelleFF', '');
                    AddAttribute(XMLNode, 'PrixUnitaireHT', '0.00');
                    AddAttribute(XMLNode, 'PrixUnitaireTTC', '0.00');
                    AddAttribute(XMLNode, 'REMISE', '0.00');
                    AddAttribute(XMLNode, 'TexteErreur', '');
                end;
            end;
        end;
    end;

    procedure LZRF47T24V1(var XMLDom: XmlElement; XMLNodeReq: XmlElement; XMLNodeReqType11: XmlElement; XMLNodeReqType22: XmlElement)
    var
        // Attributs XML
        IDFORFAIT_Attribute: Text;
        TYPEFORFAIT_Attribute: Text;
        LIGNE_DT_ID_Attribute: Text;
        LIGNE_DT_ID_DMS_Attribute: Text;
        DMS_ID_Value: Code[20];

        // Records
        RecPackageVersion: Record "Service Package Version";
        RecPackageBOM: Record "Service Package Version Line";
        RecPackage: Record "Service Package";
        lRecServiceHeader: Record "Service Header EDMS";
        lRecServiceLine: Record "Service Line EDMS";
        lRecServiceJobLine: Record "Service Order Symptome  EDMS";

        // Nœuds XML principaux
        XMLRoot: XmlElement;
        XMLNode: XmlElement;
        XMLNodeFF: XmlElement;
        XMLNodeMO: XmlElement;
        XMLNodePR: XmlElement;

        // NodeLists
        XMLNodesLDT: XmlNodeList;
        XMLNodesPR11: XmlNodeList;
        XMLNodesLDT22: XmlNodeList;
        XMLNodesMO22: XmlNodeList;

        // Nœuds de travail
        XMLNodeLDT: XmlNode;
        XMLNodeLDTElem: XmlElement;
        XMLNodeLDTElem22: XmlElement;
        XMLNodePR11Item: XmlNode;
        XMLNodeLDT22Item: XmlNode;
        XMLNodeMO22Item: XmlNode;
        TmpNode: XmlNode;

        // Variables scalaires
        IDFORFAIT_Attribute_value: Text[30];
        ErrorInFF: Boolean;
        RootFound: Boolean;
        NodesFound: Boolean;
        HasType11: Boolean;
        HasType22: Boolean;
    begin
        // VALORISER UN FORFAIT

        // Recherche du nœud LZRF47 dans XMLDom (qui est le nœud DMS TYPE=24)
        RootFound := XMLDom.SelectSingleNode('LZRF47', TmpNode);
        if RootFound then
            XMLRoot := TmpNode.AsXmlElement();

        // Récupération des LDT de la requête principale (DMS TYPE=24)
        NodesFound := XMLNodeReq.SelectNodes('LDT', XMLNodesLDT);

        // Récupération des PR du type 11
        HasType11 := not XMLNodeReqType11.IsEmpty() and XMLNodeReqType11.SelectNodes('PR', XMLNodesPR11);

        // Récupération des LDT du type 22
        HasType22 := not XMLNodeReqType22.IsEmpty() and XMLNodeReqType22.SelectNodes('LDT', XMLNodesLDT22);

        // Récupération du DOSSIER_DMS_ID
        DMS_ID_Value := CopyStr(GetAttributeValue(XMLNodeReq, 'DOSSIER_DMS_ID'), 1, MaxStrLen(DMS_ID_Value));

        if NodesFound and (XMLNodesLDT.Count > 0) then begin

            if not RootFound then
                AddElement(XMLDom, 'LZRF47', XMLRoot);

            ErrorInFF := false;

            // ── Branche 1 : dossier DMS existant ────────────────────────────────────
            if (DMS_ID_Value <> '') and lRecServiceHeader.Get(lRecServiceHeader."Document Type"::Order, DMS_ID_Value) then begin

                lRecServiceJobLine.SetRange("Document Type", lRecServiceHeader."Document Type");
                lRecServiceJobLine.SetRange("Document No.", DMS_ID_Value);
                lRecServiceJobLine.SetFilter("Package No.", '<>%1', '');

                if lRecServiceJobLine.FindSet() then
                    repeat
                        AddElement(XMLRoot, 'FF', XMLNode);
                        AddAttribute(XMLNode, 'CODE_FF', '2');
                        AddAttribute(XMLNode, 'LIGNE_DT_ID', lRecServiceJobLine."Symptome Code");
                        AddAttribute(XMLNode, 'LIGNE_DT_ID_DMS', Format(lRecServiceJobLine."Task No."));
                        AddAttribute(XMLNode, 'IDFORFAIT',
                            lRecServiceJobLine."Package No." + lRecServiceJobLine."SBX SBOX CodeTypeVehicule");
                        AddAttribute(XMLNode, 'ReferenceFF',
                            lRecServiceJobLine."Package No." + lRecServiceJobLine."SBX SBOX CodeTypeVehicule");
                        AddAttribute(XMLNode, 'LibelleFF', lRecServiceJobLine.Commentaire);

                        // Prix directement depuis Service Job Line
                        AddAttribute(XMLNode, 'PrixUnitaireHT',
                           FormatDecimalXML(lRecServiceJobLine."SBX SBOX PrixHT Forfait"));//, 0, '<Precision,2:2><Standard Format,2>'));
                        AddAttribute(XMLNode, 'PrixUnitaireTTC',
                            FormatDecimalXML(lRecServiceJobLine."SBX SBOX PrixTTC Forfait"));//, 0, '<Precision,2:2><Standard Format,2>'));

                        AddAttribute(XMLNode, 'TexteErreur', '');

                        // PR / MO depuis Service Line
                        lRecServiceLine.SetRange("Document Type", lRecServiceLine."Document Type"::Order);
                        lRecServiceLine.SetRange("Document No.", DMS_ID_Value);
                        lRecServiceLine.SetRange("Package No.", lRecServiceJobLine."Package No.");

                        if lRecServiceLine.FindSet() then
                            repeat
                                if lRecServiceLine.Type = lRecServiceLine.Type::Item then begin
                                    AddElement(XMLNode, 'PR', XMLNodePR);
                                    AddAttribute(XMLNodePR, 'CODEIMPUTATIONDMS_PR', lRecServiceLine."Sell-to Customer No.");
                                    AddAttribute(XMLNodePR, TypeXX + '_PR',
                                        Format(CheckTypeImputationByCustomer(lRecServiceLine."Sell-to Customer No.")));
                                    AddAttribute(XMLNodePR, 'REFERENCE_PR', SetItemNo(lRecServiceLine."No."));
                                    AddAttribute(XMLNodePR, 'LIBELLE_PR', lRecServiceLine.Description);
                                    AddAttribute(XMLNodePR, 'TYPE_PR', '2');
                                end else begin
                                    AddElement(XMLNode, 'MO', XMLNodeMO);
                                    AddAttribute(XMLNodeMO, 'CODEIMPUTATIONDMS_MO', lRecServiceLine."Sell-to Customer No.");
                                    AddAttribute(XMLNodeMO, TypeXX + '_MO',
                                        Format(CheckTypeImputationByCustomer(lRecServiceLine."Sell-to Customer No.")));
                                    AddAttribute(XMLNodeMO, 'CODEOPERATION', lRecServiceLine."No.");
                                    AddAttribute(XMLNodeMO, 'TYPEOPERATION', '2');
                                    AddAttribute(XMLNodeMO, 'CODETYPEVEHICULE', '');
                                    AddAttribute(XMLNodeMO, 'TEMPSGLOBAL',
                                        Format(lRecServiceLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                    AddAttribute(XMLNodeMO, 'TECHNICITE', '1');
                                    AddAttribute(XMLNodeMO, 'METIER', 'M');
                                    AddAttribute(XMLNodeMO, 'LIBELLEOPERATION', lRecServiceLine.Description);
                                end;
                            until lRecServiceLine.Next() = 0;

                    until lRecServiceJobLine.Next() = 0;

            end else begin

                // ── Branche 2 : traitement depuis le XML entrant ─────────────────────
                foreach XMLNodeLDT in XMLNodesLDT do begin

                    XMLNodeLDTElem := XMLNodeLDT.AsXmlElement();

                    if not XMLNodeLDTElem.SelectSingleNode('FF', TmpNode) then
                        continue;
                    XMLNodeFF := TmpNode.AsXmlElement();

                    IDFORFAIT_Attribute_value := CopyStr(GetAttributeValue(XMLNodeFF, 'IDFORFAIT'), 1, MaxStrLen(IDFORFAIT_Attribute_value));
                    LIGNE_DT_ID_Attribute := GetAttributeValue(XMLNodeFF, 'LIGNE_DT_ID');
                    LIGNE_DT_ID_DMS_Attribute := GetAttributeValue(XMLNodeFF, 'LIGNE_DT_ID_DMS');
                    TYPEFORFAIT_Attribute := GetAttributeValue(XMLNodeFF, 'TYPEFORFAIT');

                    RecPackage.Reset();
                    RecPackage.SetRange("No.", IDFORFAIT_Attribute_value);

                    // ── Cas A : forfait SBOX inconnu (type 1) ───────────────────────────
                    if (not RecPackage.FindSet()) and (TYPEFORFAIT_Attribute = '1') and (IDFORFAIT_Attribute_value <> '') then begin

                        AddElement(XMLRoot, 'FF', XMLNode);
                        AddAttribute(XMLNode, 'CODE_FF', '2');
                        AddAttribute(XMLNode, 'LIGNE_DT_ID', LIGNE_DT_ID_Attribute);
                        AddAttribute(XMLNode, 'LIGNE_DT_ID_DMS', '');
                        AddAttribute(XMLNode, 'IDFORFAIT', GetAttributeValue(XMLNodeFF, 'IDFORFAIT'));
                        AddAttribute(XMLNode, 'ReferenceFF', GetAttributeValue(XMLNodeFF, 'IDFORFAIT'));
                        AddAttribute(XMLNode, 'LibelleFF', GetAttributeValue(XMLNodeFF, 'LIBELLEFORFAIT'));
                        AddAttribute(XMLNode, 'PrixUnitaireHT', GetAttributeValue(XMLNodeFF, 'PRIXHT_FORFAIT'));
                        AddAttribute(XMLNode, 'PrixUnitaireTTC', GetAttributeValue(XMLNodeFF, 'PRIXTTC_FORFAIT'));
                        AddAttribute(XMLNode, 'TexteErreur', '');

                        // Type 11 – PR
                        if HasType11 then
                            foreach XMLNodePR11Item in XMLNodesPR11 do
                                if GetAttributeValue(XMLNodePR11Item.AsXmlElement(), 'LIGNE_DT_ID') = LIGNE_DT_ID_Attribute then begin
                                    AddElement(XMLNode, 'PR', XMLNodePR);
                                    AddAttribute(XMLNodePR, 'CODEIMPUTATIONDMS_PR',
                                        GetAttributeValue(XMLNodePR11Item.AsXmlElement(), 'CODEIMPUTATIONDMS_PR'));
                                    AddAttribute(XMLNodePR, TypeXX + '_PR',
                                        GetAttributeValue(XMLNodePR11Item.AsXmlElement(), TypeXX + '_PR'));
                                    AddAttribute(XMLNodePR, 'REFERENCE_PR',
                                        GetAttributeValue(XMLNodePR11Item.AsXmlElement(), 'REFERENCE_PR'));
                                    AddAttribute(XMLNodePR, 'LIBELLE_PR',
                                        GetAttributeValue(XMLNodePR11Item.AsXmlElement(), 'LIBELLE_PR'));
                                    AddAttribute(XMLNodePR, 'TYPE_PR', '2');
                                end;

                        // Type 22 – MO
                        if HasType22 then
                            foreach XMLNodeLDT22Item in XMLNodesLDT22 do begin
                                XMLNodeLDTElem22 := XMLNodeLDT22Item.AsXmlElement();
                                XMLNodeLDTElem22.SelectNodes('MO', XMLNodesMO22);
                                foreach XMLNodeMO22Item in XMLNodesMO22 do
                                    if GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'LIGNE_DT_ID') = LIGNE_DT_ID_Attribute then begin
                                        AddElement(XMLNode, 'MO', XMLNodeMO);
                                        AddAttribute(XMLNodeMO, 'CODEIMPUTATIONDMS_MO',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'CODEIMPUTATIONDMS_MO'));
                                        AddAttribute(XMLNodeMO, TypeXX + '_MO',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), TypeXX + '_MO'));
                                        AddAttribute(XMLNodeMO, 'CODEOPERATION',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'CODEOPERATION'));
                                        AddAttribute(XMLNodeMO, 'TYPEOPERATION', '2');
                                        AddAttribute(XMLNodeMO, 'CODETYPEVEHICULE',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'CODETYPEVEHICULE'));
                                        AddAttribute(XMLNodeMO, 'TEMPSGLOBAL',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'TEMPSGLOBAL'));
                                        AddAttribute(XMLNodeMO, 'TECHNICITE',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'TECHNICITE'));
                                        AddAttribute(XMLNodeMO, 'METIER',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'METIER'));
                                        AddAttribute(XMLNodeMO, 'LIBELLEOPERATION',
                                            GetAttributeValue(XMLNodeMO22Item.AsXmlElement(), 'LIBELLEOPERATION'));
                                    end;
                            end;

                        LZRF08T11V1(XMLNodeFF, XMLDom, XMLNodeReq);

                        // ── Cas B : forfait trouvé dans RecPackage ───────────────────────────
                    end else if RecPackage.FindSet() then begin

                        RecPackageVersion.Reset();
                        RecPackageVersion.SetFilter("Package No.", IDFORFAIT_Attribute_value);

                        if RecPackageVersion.FindLast() then begin

                            AddElement(XMLRoot, 'FF', XMLNode);
                            AddAttribute(XMLNode, 'CODE_FF', '2');
                            AddAttribute(XMLNode, 'LIGNE_DT_ID', LIGNE_DT_ID_Attribute);
                            AddAttribute(XMLNode, 'LIGNE_DT_ID_DMS', '');
                            AddAttribute(XMLNode, 'IDFORFAIT', RecPackageVersion."Package No.");
                            AddAttribute(XMLNode, 'ReferenceFF', RecPackageVersion."Package No.");
                            AddAttribute(XMLNode, 'LibelleFF', RecPackageVersion.Description);
                            AddAttribute(XMLNode, 'PrixUnitaireHT',
                                Format(RecPackageVersion."Amount", 0, '<Precision,2:2><Standard Format,2>'));
                            AddAttribute(XMLNode, 'PrixUnitaireTTC',
                                Format(RecPackageVersion."Amount", 0, '<Precision,2:2><Standard Format,2>'));
                            AddAttribute(XMLNode, 'TexteErreur', '');

                            RecPackageBOM.Reset();
                            RecPackageBOM.SetFilter("Package No.", RecPackageVersion."Package No.");
                            RecPackageBOM.SetFilter("Version No.", '%1', RecPackageVersion."Version No.");

                            if RecPackageBOM.FindFirst() then
                                repeat
                                    if RecPackageBOM.Type = RecPackageBOM.Type::Item then begin
                                        AddElement(XMLNode, 'PR', XMLNodePR);
                                        AddAttribute(XMLNodePR, 'CODEIMPUTATIONDMS_PR', '');
                                        AddAttribute(XMLNodePR, TypeXX + '_PR', '');
                                        AddAttribute(XMLNodePR, 'REFERENCE_PR', SetItemNo(RecPackageBOM."No."));
                                        AddAttribute(XMLNodePR, 'LIBELLE_PR', RecPackageBOM.Description);
                                        AddAttribute(XMLNodePR, 'TYPE_PR', '2');
                                        AddAttribute(XMLNodePR, 'QuantiteEnCommande',
                                            Format(RecPackageBOM.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                    end else begin
                                        AddElement(XMLNode, 'MO', XMLNodeMO);
                                        AddAttribute(XMLNodeMO, 'CODEIMPUTATIONDMS_MO', '');
                                        AddAttribute(XMLNodeMO, TypeXX + '_MO', '');
                                        AddAttribute(XMLNodeMO, 'CODEOPERATION', RecPackageBOM."No.");
                                        AddAttribute(XMLNodeMO, 'TYPEOPERATION', '2');
                                        AddAttribute(XMLNodeMO, 'CODETYPEVEHICULE', '');
                                        AddAttribute(XMLNodeMO, 'TEMPSGLOBAL', '1');
                                        AddAttribute(XMLNodeMO, 'TECHNICITE', '1');
                                        AddAttribute(XMLNodeMO, 'METIER', 'T');
                                        AddAttribute(XMLNodeMO, 'LIBELLEOPERATION', RecPackageBOM.Description);
                                    end;
                                until RecPackageBOM.Next() = 0;

                            LZRF08T11V1(XMLNodeFF, XMLDom, XMLNodeReq);
                        end;

                        // ── Cas C : forfait introuvable ──────────────────────────────────────
                    end else begin
                        ErrorInFF := true;
                        AddElement(XMLRoot, 'FF', XMLNode);
                        AddAttribute(XMLNode, 'CODE_FF', '99');
                        AddAttribute(XMLNode, 'LIGNE_DT_ID', LIGNE_DT_ID_Attribute);
                        AddAttribute(XMLNode, 'LIGNE_DT_ID_DMS', '');
                        AddAttribute(XMLNode, 'IDFORFAIT', IDFORFAIT_Attribute_value);
                        AddAttribute(XMLNode, 'ReferenceFF', '');
                        AddAttribute(XMLNode, 'LibelleFF', '');
                        AddAttribute(XMLNode, 'PrixUnitaireHT', '0.00');
                        AddAttribute(XMLNode, 'PrixUnitaireTTC', '0.00');
                        AddAttribute(XMLNode, 'REMISE', '0.00');
                        AddAttribute(XMLNode, 'TexteErreur', '');
                    end;

                end; // foreach LDT
            end; // branche 2

            // ── Gestion du code retour racine ────────────────────────────────────────
            if ErrorInFF then begin
                AddAttribute(XMLRoot, 'Code', '52');
                AddAttribute(XMLRoot, 'TexteDMS', 'forfait inexistent');
            end else begin
                AddAttribute(XMLRoot, 'Code', '0');
                AddAttribute(XMLRoot, 'TexteDMS', '');
            end;

        end; // if NodesFound
    end;

    // Récupère un élément enfant par nom.
    /// SelectSingleNode est disponible sur XmlNode (pas directement sur XmlElement),
    /// donc on passe par XmlNode intermédiaire.
    local procedure GetChildElement(ParentElem: XmlElement; ChildName: Text; var ChildElem: XmlElement): Boolean
    var
        TmpNode: XmlNode;
    begin
        if ParentElem.SelectSingleNode(ChildName, TmpNode) then begin
            ChildElem := TmpNode.AsXmlElement();
            exit(true);
        end;
        exit(false);
    end;

    procedure onConfirmInsertSPVersion(var SPVersion: Record "Service Package Version"; quote: Record "Service Header EDMS") result: Text
    var
        SPVersionSpec: Record "Service Package Version Line";
        ServicePackage: Record "Service Package";
        VehicleServicePlanStageTmp_CS: Record "Vehicle Service Plan Stage";
    begin
        if SPVersion."Package No." = '' then
            exit('Error: SPVersion "Package No." is empty.');

        if not ServicePackage.Get(SPVersion."Package No.") then
            exit('Error: Service Package not found.');

        if ServicePackage.Blocked then
            exit('Error: Service Package is blocked.');

        SPVersionSpec.Reset();
        SPVersionSpec.SetRange("Package No.", SPVersion."Package No.");
        SPVersionSpec.SetRange("Version No.", SPVersion."Version No.");

        if not SPVersionSpec.FindSet() then
            exit('Error: No records found in SPVersionSpec.');

        repeat
            SPVersionSpec.SetCurrPlanStage(VehicleServicePlanStageTmp_CS);
            SPVersionSpec.CreateServLine(quote."Document Type", quote."No.");
        until SPVersionSpec.Next() = 0;

        exit('Success: onConfirmInsertSPVersion executed successfully.');
    end;

    /*   local procedure CreateItem(ItemNo: Code[20]; ldescription: Text[100]; lDescription2: Text[50])
      Var
          PurchasesPayablesSetup: Record "Purchases & Payables Setup";
          ItemTempl: Record "Item Templ.";
          NewItem: Record Item;
          ItemUnitofMeasure: Record "Item Unit of Measure";
      begin
          PurchasesPayablesSetup.get();
          if ItemTempl.get(PurchasesPayablesSetup."STF Templ. Item") then begin
              NewItem.INIT();
              NewItem."No." := ItemNo;
              NewItem.INSERT();
              NewItem.Description := ldescription;
              NewItem."Description 2" := ldescription2;
              //---Ajout ItemUnitOfMeasure
              IF NOT ItemUnitofMeasure.GET(ItemNo, ItemTempl."Base Unit of Measure") THEN BEGIN
                  ItemUnitofMeasure.INIT();
                  ItemUnitofMeasure."Item No." := ItemNo;
                  ItemUnitofMeasure.Code := ItemTempl."Base Unit of Measure";
                  ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
                  ItemUnitofMeasure.INSERT();
              END;

              //---
              NewItem.VALIDATE("Base Unit of Measure", ItemTempl."Base Unit of Measure");
              NewItem."Inventory Posting Group" := ItemTempl."Inventory Posting Group";
              //  Gitem_New."Sales Profit group" := 'ACH_PR';
              NewItem."Costing Method" := ItemTempl."Costing Method";
              //NewItem."Cost is Adjusted" := TRUE;
              NewItem."Gen. Prod. Posting Group" := ItemTempl."Gen. Prod. Posting Group";
              NewItem."VAT Prod. Posting Group" := ItemTempl."VAT Prod. Posting Group";
              //Gitem_New."Global Dimension 2 Code":=Gvendor."Phone No. 2";
              NewItem.VALIDATE("Sales Unit of Measure", ItemTempl."Base Unit of Measure");
              NewItem.VALIDATE("Purch. Unit of Measure", ItemTempl."Base Unit of Measure");
              NewItem."Item Category Code" := ItemTempl."Item Category Code";
              NewItem."Manufacturer Code" := ItemTempl."Manufacturer Code";


              //Gitem_New."Make Code":=Gvendor."Phone No. 2";
              NewItem."Item Type" := NewItem."Item Type"::Item;
              NewItem."DLT Status" := NewItem."DLT Status"::Approved;
              //Gitem_New.Equipementier:=TRUE;


              NewItem.MODIFY(TRUE)
          end;
      end;

    */
    procedure FindPriceMO(CODEIMPUTATIONDMS: code[20]; CODEOPERATION_attribute: code[20]; var UnitPrice: Decimal; var UnitPriceTTC: Decimal; var ErrorMsg: Text): Boolean
    var
        Vcustomer: Record Customer;
        VLabor: Record "Service Labor";
        VATPostingSetup: Record "VAT Posting Setup";
        TempServicePrice: Record "Service Price" temporary;
        TempSalesPrice: Record "Sales Price DMS" temporary;
        "SalesPriceCalcMgtEDMS": Codeunit "Sales Price Calc. Mgt. EDMS";
        SBManagement: Codeunit "STF Service Box Mgt";
    begin
        ErrorMsg := '';
        UnitPrice := 0;
        UnitPriceTTC := 0;
        Clear(VLabor);
        Clear(Vcustomer);
        Clear(VATPostingSetup);
        if not SBManagement.CheckLaborNo(CODEOPERATION_attribute, VLabor, ErrorMsg) then
            exit(false);
        if not SBManagement.CheckCustomerNo(CODEIMPUTATIONDMS, Vcustomer, ErrorMsg) then
            exit(false);
        TempServicePrice.Reset();
        TempServicePrice.DeleteAll();
        SalesPriceCalcMgtEDMS.SetUoM(1, 1);
        SalesPriceCalcMgtEDMS.FindServLaborPrice(TempServicePrice, Vcustomer."No.", '', Vcustomer."Customer Price Group", '', VLabor."No.", '',
                      WorkDate(), false, VLabor."Price Group Code", VLabor."Unit of Measure Code",
                      '', '', '');
        SalesPriceCalcMgtEDMS.CopyServicePriceToSalesPrice(TempServicePrice, TempSalesPrice);
        SalesPriceCalcMgtEDMS.CalcBestUnitPrice(TempSalesPrice);

        UnitPrice := TempSalesPrice."Unit Price";

        if VATPostingSetup.Get(Vcustomer."VAT Bus. Posting Group", VLabor."VAT Prod. Posting Group") then
            //UnitPriceTTC := UnitPrice * ((1 + VATPostingSetup."VAT %") / 100);
            UnitPriceTTC := UnitPrice * (1 + (VATPostingSetup."VAT %" / 100));
        exit(true);
    end;

    var
        NumeroPoste: Text[30];
        PARAMDMS: Text[50];
        TypeXX: Text[30];
        eDMSSetup: Record "STF Servicebox Setup";
        RecLocation: Record Location;
        RecServiceLocation: Record Location;
        RecUserSetup: Record "User Setup";
        RecWarehouseEmployee: Record "Warehouse Employee";
        CodeMarkSBOX: Code[10];

}

