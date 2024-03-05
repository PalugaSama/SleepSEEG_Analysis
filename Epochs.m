

function [h, statsMatrix, time, Timestamps, EpochInfo] = Epochs(SC, theta)

    indices = (1:size(SC, 1))';
    SC(:, 5) = indices;

    % Ajouter une colonne 6 initialement remplie de zéros
    SC(:, 6) = 0;

    %Calculer les minutes depuis temps 0 
    SC(1:end, 6) = 0.5 * SC(1:end, 5);

    %% Calcul des heures depuis le temps 0 %% 
    SC(:, 7) = SC(:, 6) / 60;
    


    % Output 1: Histogramme de la distribution des époques catégorisées avec un niveau theta.
    h = Distribution(SC, theta);

    % Output 2: Matrice de résumé des statistiques.
    statsMatrix = Stats(SC, theta);

    % Output 3: Graphique en courbe de la répartition des époques en fonction du temps.
    time = Time(SC, theta);

    % Output 4: Matrice 'Epochs' avec les époques catégorisées avec une confiance > theta.
    [Timestamps, EpochInfo] = ExtractEpochs(SC, theta)
end


%% ------ Histogramme de distribution ----- %%

function h = Distribution(SC, theta)
    % Filtrer les données en fonction de la confiance (colonne 4)
    filteredData = SC(SC(:, 4) > theta, :);

    % Créer un histogramme du nombre d'époques par catégorie
    h = histogram(filteredData(:, 3), 'BinWidth', 1, 'BinLimits', [0.5, 5.5], 'EdgeColor', 'black');

    % Ajouter des étiquettes et un titre
    xlabel('Catégorie');
    ylabel('Nombre d''époques');
    title(['Nombre d''époques par catégorie (Confiance > ' num2str(theta) ')']);

    % Remplacer les étiquettes d'axe par les noms des catégories
    xticks(1:5);
    xticklabels({'R', 'W', 'N1', 'N2', 'N3'});

    % Afficher le nombre précis d'époques au-dessus de chaque barre
    counts = h.Values;  % Récupérer les valeurs de l'histogramme
    for i = 1:numel(counts)
        text(i, counts(i), num2str(counts(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end

    % Ajouter la dernière colonne en pourcentage par rapport au nombre d'époques retenues par theta
    totalEpochs = 1555;  % Nombre total d'époques
    filteredEpochs = size(filteredData, 1);  % Nombre d'époques après filtrage
    percentage = (filteredEpochs / totalEpochs) * 100;  % Calculer le pourcentage

    % Ajouter la barre en pourcentage à l'histogramme
    hold on;
    bar(6, filteredEpochs, 'BarWidth', 0.7, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'black');  % Barre grise
    text(6, filteredEpochs, [num2str(filteredEpochs) ' (' num2str(percentage) '%)'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

    % Afficher une légende si vous le souhaitez
    legend('Nombre d''époques', 'Total en pourcentage');

    % Afficher la grille pour une meilleure lisibilité
    grid on;
    hold off;
end




%% ---------------------------------------------- Matrice de stats ------------------------------------------ %%

function StatsMatrix = Stats(SC, theta)
    % Filtrer les données en fonction de la confiance (colonne 4)
    filteredData = SC(SC(:, 4) > theta, :);

    % Initialiser la matrice pour stocker les statistiques
    statsMatrix = zeros(4, 5);

    % Calculer la moyenne, la médiane et l'écart type pour chaque catégorie
    categories = unique(filteredData(:, 3));
    for i = 1:numel(categories)
        categoryData = filteredData(filteredData(:, 3) == categories(i), :);
        statsMatrix(1, i) = mean(categoryData(:, 4));  % Moyenne
        statsMatrix(2, i) = median(categoryData(:, 4));  % Médiane
        statsMatrix(3, i) = std(categoryData(:, 4));  % Écart type
    end

    % Ajouter la dernière ligne avec le nombre d'époques par catégorie
    for i = 1:numel(categories)
        statsMatrix(4, i) = sum(filteredData(:, 3) == categories(i));
    end

    % Noms des catégories (colonnes)
    catLabels = {'R', 'W', 'N1', 'N2', 'N3'};

    % Noms des statistiques (lignes)
    statLabels = {'Moyenne', 'Médiane', 'Écart type', 'Total'};

    % Créer la matrice finale avec les labels
    StatsMatrix = cell(5, 6);

    % Ajouter les labels de catégorie (colonnes)
    for j = 1:5
        StatsMatrix{1, j+1} = catLabels{j};
    end

    % Ajouter les labels de statistiques (lignes)
    for i = 1:4
        StatsMatrix{i+1, 1} = statLabels{i};
    end

    % Remplir la matrice avec les statistiques
    for i = 1:4
        for j = 1:5
            StatsMatrix{i+1, j+1} = statsMatrix(i, j);
        end
    end

    % Ajouter la dernière ligne avec le total
    StatsMatrix{5, 1} = 'Total';
    for j = 1:5
        StatsMatrix{5, j+1} = sum(statsMatrix(4, j));
    end

    % Afficher la matrice de statistiques
    disp('Matrice de statistiques :');
    disp(StatsMatrix);
end



%% ------------------------- Night graph --------------------------

function time = Time(SC, theta)
    filteredData = SC(SC(:, 4) > theta, :);

    % Nouvel ordre des indices
    nouvelOrdre = [3, 5, 4, 2, 1];

    % Ajouter une nouvelle colonne (colonne 7) avec les nouveaux indices
    filteredData(:, 8) = nouvelOrdre(filteredData(:, 3));

    % Afficher la matrice résultante
    disp('Matrice filteredData avec la colonne 7 ajoutée :');
    disp(filteredData);


    % Extraction des données pertinentes
    timestamp = filteredData(:, 7);
    sleepStage = filteredData(:, 8);

    
    % Création de la courbe
    figure;
    plot(timestamp, sleepStage, '-o', 'LineWidth', 2);

    % Ajout des étiquettes de légende pour l'axe des ordonnées
    categories_labels = {'N3', 'N2', 'R', 'N1', 'W'};
    set(gca, 'YTick', 1:5, 'YTickLabel', categories_labels);
    
    % Définir les limites de l'axe y pour éviter que les catégories soient à l'extrémité du graphique
    ylim([0.5 5.5]);

    % Ajout des labels pour les axes
    xlabel('Heures depuis le début de l''enregistrement');
    ylabel('Catégorie de sommeil');

    % Affichage de la grille
    grid on;

    % Affichage du titre
    title('Évolution des catégories de sommeil au fil du temps');

    % Assigner le graphique en courbe à la sortie
    time = gcf;
end





%% --- Recuperer timestamps ----- 

function [Timestamps, EpochInfo] = ExtractEpochs(SC, theta)
    % Filtrer les données en fonction de la confiance (colonne 4)
    filteredData = SC(SC(:, 4) > theta, :);

    % Mapping des indices de catégorie aux étiquettes
    categoryLabels = {'REM', 'W', 'N1', 'N2', 'N3'};
    categoryMapping = containers.Map(1:5, categoryLabels);

    % Création de la matrice 'Timestamps'
    temps_matlab = filteredData(:, 2);

    % temps en datetime
    Timestamps = datetime(temps_matlab, 'ConvertFrom', 'datenum');
    disp(Timestamps)


    % Création de la matrice 'EpochInfo'
    EpochInfo = zeros(size(filteredData, 1), 4);

    % Remplissage de la matrice avec les informations pertinentes
    EpochInfo(:, 1) = filteredData(:, 1);  % Numéro de fichier
    EpochInfo(:, 2) = filteredData(:, 2);  % Timestamp
    EpochInfo(:, 3) = filteredData(:, 3);  % Stade de sommeil
    EpochInfo(:, 4) = filteredData(:, 4);  % Confiance

    % Affichage de la matrice 'EpochInfo'
    disp('Matrice ''EpochInfo'':');
    disp(EpochInfo);
end
