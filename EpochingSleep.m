% Fonction principale : Epoching
% Cette fonction prend en entrée une matrice SC, un seuil theta, ainsi que plusieurs paramètres booléens
% pour activer/désactiver différentes sorties. Elle effectue une série de traitements sur les données
% et retourne les résultats selon les paramètres spécifiés.
%
% Entrées :
%   - SC : Matrice obtenue en output de SleepSEEG renommée et save as SC, où chaque ligne représente une époque identifiée.
%   - theta : Seuil de confiance pour la catégorisation des époques.
%   - Nombre de fichier pour la nuit entiere
%
%   - enableHistogram : Booléen pour activer ou désactiver l'histogramme de distribution. (true/false)
%   - enableStatsMatrix : Booléen pour activer ou désactiver la matrice de statistiques. (true/false)
%   - enableTimeGraph : Booléen pour activer ou désactiver le graphique en courbe du temps. (true/false)
%   - enableEpochInfo : Booléen pour activer ou désactiver l'extraction des informations d'époque. (true/false)
%   - enableEpochsAnalyse : Booléen pour activer ou désactiver la création de la matrice Epochs_analyse. (true/false)
%
% Sorties :
%   - h : Histogramme de distribution des epoches par catégorie (si activé).
%   - statsMatrix : Matrice de statistiques (si activée).
%   - time : Graphique de la distribution en courbe du temps (si activé).
%   - Epochs_analyse : Matrice Epochs_analyse (si activée).


function [Epochs_analyse, h, statsMatrix, time] = EpochingSleep(SC, theta, nb_fichiers, enableEpochsAnalyse, enableHistogram, enableStatsMatrix, enableTimeGraph)
    % Initialiser toutes les variables de sortie
    Epochs_analyse = [];
    h = [];
    statsMatrix = [];
    time = [];
    
    % Activer les sorties selon les paramètres booléens
    if enableEpochsAnalyse
        Epochs_analyse = EpochsAnalyse(SC, nb_fichiers);
    end
    
    if enableHistogram
        h = Histogram(SC, theta);
    end
    
    if enableStatsMatrix
        statsMatrix = Stats(SC, theta);
    end
    
    if enableTimeGraph
        time = Time(SC, theta);
    end
end

function Epochs_analyse = EpochsAnalyse(SC, nb_fichiers)
    %% Extraire le premier timestamp de chaque fichier
    Epochs = SC;
    Premier_Timestamp = zeros(1, nb_fichiers);

    % Parcourir les fichiers
    for fichier = 1:nb_fichiers
        % Extraire les données du fichier courant
        fichier_indices = (Epochs(:, 1) == fichier);
        fichier_data = Epochs(fichier_indices, :);

        % Identifier et stocker le premier timestamp
        Premier_Timestamp(fichier) = min(fichier_data(:, 2));
    end

    %% Créer une matrice avec 120 epochs de chaque stade de sommeil + REM significative

    % Extraire les indices correspondant aux stades de sommeil
    W_index = find(Epochs(:, 3) == 2); % Wakefulness
    N2_index = find(Epochs(:, 3) == 4); % N2
    N3_index = find(Epochs(:, 3) == 5); % N3
    R_index = find(Epochs(:, 3) == 1); % REM

    % Trier les indices en fonction du score de confiance (colonne 4)
    [~, W_sorted_indices] = sort(Epochs(W_index, 4), 'descend');
    [~, N2_sorted_indices] = sort(Epochs(N2_index, 4), 'descend');
    [~, N3_sorted_indices] = sort(Epochs(N3_index, 4), 'descend');
    [~, R_sorted_indices] = sort(Epochs(R_index, 4), 'descend');

    % Sélectionner les 120 meilleures epochs pour chaque stade de sommeil
    selected_epochs_W = W_index(W_sorted_indices(1:min(120, length(W_sorted_indices))));
    selected_epochs_N2 = N2_index(N2_sorted_indices(1:min(120, length(N2_sorted_indices))));
    selected_epochs_N3 = N3_index(N3_sorted_indices(1:min(120, length(N3_sorted_indices))));
    selected_epochs_R = R_index(R_sorted_indices(1:min(35, length(R_sorted_indices))));

    % Concaténer les indices sélectionnés
    selected_epochs_indices = [selected_epochs_W; selected_epochs_N2; selected_epochs_N3; selected_epochs_R];

    % Créer Epochs_analyse en fonction des indices sélectionnés
    Epochs_analyse = Epochs(selected_epochs_indices, :);

    %% Ajouter le nombre de secondes écoulées depuis le début du fichier

    % Ajouter une sixième colonne vide à Epochs_analyse pour les secondes écoulées
    Epochs_analyse(:, 6) = zeros(size(Epochs_analyse, 1), 1);

    % Parcourir les fichiers
    for fichier = 1:nb_fichiers
        % Extraire les indices du fichier courant
        fichier_indices = (Epochs_analyse(:, 1) == fichier);

        % Obtenir le premier timestamp du fichier à partir de Premier_Timestamp
        t0 = Premier_Timestamp(fichier);

        % Calculer le nombre de secondes écoulées depuis le début du fichier
        Epochs_analyse(fichier_indices, 6) = (Epochs_analyse(fichier_indices, 2) - t0) * 24 * 3600;
    end

    Epochs_analyse = sortrows(Epochs_analyse, 2);

    %% Enregistrement des données dans des fichiers CSV
    Epochs_analyse = sortrows(Epochs_analyse, 2);
    % Parcourir les fichiers
    for fichier = 1:nb_fichiers
        % Extraire les données du fichier courant
        fichier_indices = (Epochs_analyse(:, 1) == fichier);
        fichier_data = Epochs_analyse(fichier_indices, :);

        % Créer le nom du fichier CSV
        nom_fichier = sprintf('Epochs_nuit2_%d.csv', fichier);

        % Ouvrir le fichier CSV en écriture
        fid = fopen(nom_fichier, 'w');

        % Parcourir les données et écrire dans le fichier CSV
        for i = 1:size(fichier_data, 1)
            % Déterminer le label en fonction du stade identifié
            if fichier_data(i, 3) == 1
                label = 'REM';
            elseif fichier_data(i, 3) == 2
                label = 'W';
            elseif fichier_data(i, 3) == 4
                label = 'N2';
            elseif fichier_data(i, 3) == 5
                label = 'N3';
            else
                label = 'Unknown';
            end

            % Écrire les données dans le fichier CSV
            fprintf(fid, '%s,%d,30\n', label, fichier_data(i, 6));
        end

        % Fermer le fichier CSV
        fclose(fid);
    end
end

%% Histogram de distribution 
function h = Histogram(SC, theta)
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

%% Matrix de stats
function stats = Stats(SC, theta)
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

    % Créer la matrice de statistiques avec les labels
    stats = cell(5, 6);

    % Noms des catégories (colonnes)
    catLabels = {'R', 'W', 'N1', 'N2', 'N3'};

    % Noms des statistiques (lignes)
    statLabels = {'Moyenne', 'Médiane', 'Écart type', 'Total'};

    % Ajouter les labels de catégorie (colonnes)
    for j = 1:5
        stats{1, j+1} = catLabels{j};
    end

    % Ajouter les labels de statistiques (lignes)
    for i = 1:4
        stats{i+1, 1} = statLabels{i};
    end

    % Remplir la matrice avec les statistiques
    for i = 1:4
        for j = 1:5
            stats{i+1, j+1} = statsMatrix(i, j);
        end
    end

    % Ajouter la dernière ligne avec le total
    stats{5, 1} = 'Total';
    for j = 1:5
        stats{5, j+1} = sum(statsMatrix(4, j));
    end

    % Afficher la matrice de statistiques
    disp('Matrice de statistiques :');
    disp(stats);
end


%% Graph de distribution %%
function time = Time(SC, theta)
    indices = (1:size(SC, 1))';
    SC(:, 5) = indices;

    % Ajouter une colonne 6 initialement remplie de zéros
    SC(:, 6) = 0;

    %Calculer les minutes depuis temps 0 
    SC(1:end, 6) = 0.5 * SC(1:end, 5);

    %% Calcul des heures depuis le temps 0 %% 
    SC(:, 7) = SC(:, 6) / 60;
    

    filteredData = SC(SC(:, 4) > theta, :);

    % Nouvel ordre des indices
    nouvelOrdre = [3, 5, 4, 2, 1];

    % Ajouter une nouvelle colonne (colonne 7) avec les nouveaux indices
    filteredData(:, 8) = nouvelOrdre(filteredData(:, 3));

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

    % Stocker la figure actuelle dans la sortie
    time = gcf;
end
