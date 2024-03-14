
function coordinates(listeFichiers, system, Channels)

    % Vérifier si le système de coordonnées est spécifié correctement
    if ~(system == 1 || system == 2)
        error('Le système de coordonnées spécifié doit être 1 pour LPS ou 2 pour RAS.');
    end

    % Déterminer le suffixe du nom de fichier en fonction du système de coordonnées
    if system == 1
        coordSuffix = 'LPS';
    else
        coordSuffix = 'RAS';
    end

    % Ajouter le symbole '+' au suffixe si des canaux ont été ajoutés
    if exist('Channels', 'var') && ~isempty(Channels)
        coordSuffix = [coordSuffix '+'];
    end

    % Chemin d'accès au répertoire courant
    repertoireCourant = pwd;

    % Nom des fichiers texte pour les coordonnées en millimètres et en mètres
    nomFichier_mm = ['coordonnees_' coordSuffix '_mm.txt'];
    nomFichier_m = ['coordonnees_' coordSuffix '_metres.txt'];

    % Chemin d'accès complet aux fichiers texte
    cheminFichier_mm = fullfile(repertoireCourant, nomFichier_mm);
    cheminFichier_m = fullfile(repertoireCourant, nomFichier_m);

    % Ouvrir le fichier texte pour les coordonnées en millimètres pour l'écriture ou la création s'il n'existe pas
    fid_mm = fopen(cheminFichier_mm, 'w');
    % Ouvrir le fichier texte pour les coordonnées en mètres pour l'écriture ou la création s'il n'existe pas
    fid_m = fopen(cheminFichier_m, 'w');

    % Vérifier si l'ouverture des fichiers est réussie
    if fid_mm == -1 || fid_m == -1
        error('Impossible de créer ou d''ouvrir les fichiers pour l''écriture');
    else
        disp(['Fichiers créés avec succès dans le répertoire ' repertoireCourant]);
    end

    % Parcourir chaque fichier JSON dans la liste
    for k = 1:length(listeFichiers)
        % Charger le fichier JSON
        jsonFile = listeFichiers{k};
        fidJSON = fopen(jsonFile, 'r');
        rawData = fread(fidJSON, inf);
        str = char(rawData');
        fclose(fidJSON);

        % Convertir le JSON en structure de données MATLAB
        data = jsondecode(str);

        % Extraire le nom de l'électrode à partir du nom du fichier
        nomElectrode = extractBefore(jsonFile, '.mrk.json');

        % Transformation des coordonnées selon le système spécifié
        for i = 1:numel(data.markups.controlPoints)
            position = data.markups.controlPoints(i).position;
            if system == 2
                % Transformation en RAS
                position(1:2) = -position(1:2);
            end
            % Convertir les coordonnées en mètres (division par 1000)
            position_m = position / 1000;
            % Écrire les coordonnées dans les fichiers texte avec le nom de l'électrode
            fprintf(fid_mm, '%s%d\t%.15f\t%.15f\t%.15f\n', nomElectrode, i, position(1), position(2), position(3));
            fprintf(fid_m, '%s%d\t%.15f\t%.15f\t%.15f\n', nomElectrode, i, position_m(1), position_m(2), position_m(3));
        end
    end

    % Ajouter les canaux supplémentaires avec leurs positions spécifiées
    if exist('Channels', 'var') && ~isempty(Channels)
        for j = 1:size(Channels, 1)
            channelName = Channels{j, 1};
            linePosition = Channels{j, 2};
            % Écrire les coordonnées dans les fichiers texte avec le nom du canal et la position spécifiée
            fprintf(fid_mm, '%s\t%.15f\t%.15f\t%.15f\n', channelName, 0, 0, 0);
            fprintf(fid_m, '%s\t%.15f\t%.15f\t%.15f\n', channelName, 0, 0, 0);
        end
    end

    % Fermer les fichiers
    fclose(fid_mm);
    fclose(fid_m);

    disp('Conversion terminée.');

end

