
function Channel_file(listeFichiers, Matrix_Coordinates_M_SCS, Channels)

    % Chemin d'accès au répertoire courant
    repertoireCourant = pwd;

    % Initialiser la variable pour stocker les noms d'électrode et les indices
    Electrode = {};
    Indices = {};

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

        % Nombre de points de contrôle pour ce fichier JSON
        numControlPoints = numel(data.markups.controlPoints);

        % Ajouter le nom de l'électrode et les indices à la liste
        indices = num2cell(1:numControlPoints)';
        Electrode = [Electrode; strcat(nomElectrode, cellfun(@num2str, indices, 'UniformOutput', false))];
        Indices = [Indices; indices];
    end

    % Vérifier que le nombre d'électrodes correspond au nombre de lignes dans Matrix_Coordinates_M_SCS
    if numel(Electrode) ~= size(Matrix_Coordinates_M_SCS, 1)
        error('Le nombre d''électrodes ne correspond pas au nombre de lignes dans Matrix_Coordinates_M_SCS.');
    end

    % Nom des fichiers texte pour les coordonnées en millimètres et en mètres
    nomFichier_mm = 'CHANNEL_FILE.txt';

    % Chemin d'accès complet aux fichiers texte
    cheminFichier_mm = fullfile(repertoireCourant, nomFichier_mm);

    % Ouvrir le fichier texte pour les coordonnées en millimètres pour l'écriture ou la création s'il n'existe pas
    fid_mm = fopen(cheminFichier_mm, 'w');

    % Vérifier si l'ouverture du fichier est réussie
    if fid_mm == -1
        error('Impossible de créer ou d''ouvrir le fichier pour l''écriture');
    else
        disp(['Fichier créé avec succès dans le répertoire ' repertoireCourant]);
    end

    % Écrire les coordonnées dans le fichier texte
    for i = 1:numel(Electrode)
        % Utiliser les coordonnées de la matrice Matrix_Coordinates_M_SCS
        position = Matrix_Coordinates_M_SCS(i, :);
        fprintf(fid_mm, '%s\t%.15f\t%.15f\t%.15f\n', Electrode{i}, position(1), position(2), position(3));
    end

    % Ajouter les canaux supplémentaires avec leurs positions spécifiées
    if exist('Channels', 'var') && ~isempty(Channels)
        for j = 1:size(Channels, 1)
            channelName = Channels{j, 1};
            % Écrire les coordonnées dans le fichier texte avec le nom du canal et la position spécifiée
            fprintf(fid_mm, '%s\t%.15f\t%.15f\t%.15f\n', channelName, 0, 0, 0);
        end
    end

    % Fermer le fichier
    fclose(fid_mm);

    disp('Conversion terminée.');

end
