function MatrixCoordinates_M = Matrix_Coordinates_Meters(listeFichiers, Systeme)

    % Vérifier si le système de coordonnées est spécifié correctement
    if ~(Systeme == 1 || Systeme == 2)
        error('Le système de coordonnées spécifié doit être 1 pour LPS ou 2 pour RAS.');
    end

    % Variable pour stocker les coordonnées en mètres
    MatrixCoordinates = [];

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

        % Transformation des coordonnées selon le système spécifié
        for i = 1:numel(data.markups.controlPoints)
            position = data.markups.controlPoints(i).position;
            if Systeme == 2
                % Transformation en RAS
                position(1:2) = -position(1:2);
            end
            % Convertir les coordonnées en mètres (division par 1000)
            position_m = position / 1000;
            % Ajouter les coordonnées à la matrice des coordonnées en mètres
            MatrixCoordinates = [MatrixCoordinates; position_m']; % Transpose position_m pour obtenir une ligne
        end
    end
    
    % Enregistrer la variable MatrixCoordinates_M dans le répertoire courant
    MatrixCoordinates_M = MatrixCoordinates;
    save('MatrixCoordinates_M.mat', 'MatrixCoordinates_M');

end
