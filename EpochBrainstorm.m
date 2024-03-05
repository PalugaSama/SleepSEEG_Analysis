

%% Importer epochs sur Brainstorm 

% Load Sleep_Confidence == Output Sleep_seeg 

%% Extraire Premier timestamp de chaque fichier

% Nombre de fichiers
nb_fichiers = 8;

% Initialisation de Premier_Timestamp
Premier_Timestamp = zeros(1, nb_fichiers);

% Parcourir les fichiers
for fichier = 1:nb_fichiers
    % Extraire les données du fichier courant
    fichier_indices = (Sleep_Confidence(:,1) == fichier);
    fichier_data = Sleep_Confidence(fichier_indices, :);
    
    % Identifier et stocker le premier timestamp
    Premier_Timestamp(fichier) = min(fichier_data(:, 2));
end

%% Creer matrice avec 120 epochs w, n2, n3 + significative R

% Extraire les lignes correspondant aux stades de sommeil 2, 4 et 5
W_index = find(Sleep_Confidence(:,3) == 2); % Wakefulness
N2_index = find(Sleep_Confidence(:,3) == 4); % N2
N3_index = find(Sleep_Confidence(:,3) == 5); % N3
R_index = find(Sleep_Confidence(:,3) == 1); % REM

% Trier les indices en fonction du score de confiance (colonne 4)
[~, W_sorted_indices] = sort(Sleep_Confidence(W_index, 4), 'descend');
[~, N2_sorted_indices] = sort(Sleep_Confidence(N2_index, 4), 'descend');
[~, N3_sorted_indices] = sort(Sleep_Confidence(N3_index, 4), 'descend');
[~, R_sorted_indices] = sort(Sleep_Confidence(R_index, 4), 'descend');

% Sélectionner les 120 meilleures epochs pour chaque stade de sommeil
selected_epochs_W = W_index(W_sorted_indices(1:min(120, length(W_sorted_indices))));
selected_epochs_N2 = N2_index(N2_sorted_indices(1:min(120, length(N2_sorted_indices))));
selected_epochs_N3 = N3_index(N3_sorted_indices(1:min(120, length(N3_sorted_indices))));
selected_epochs_R = R_index(R_sorted_indices(1:min(35, length(R_sorted_indices))));

% Concaténer les indices sélectionnés
selected_epochs_indices = [selected_epochs_W; selected_epochs_N2; selected_epochs_N3; selected_epochs_R];

% Créer Epochs_analyse en fonction des indices sélectionnés
Epochs_analyse = Sleep_Confidence(selected_epochs_indices, :);

clearvars -except Sleep_Confidence Epochs_analyse Premier_Timestamp

%% Seconde depuis debut fichier
% Nombre de fichiers
nb_fichiers = 8;

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

clearvars -except Sleep_Confidence Epochs_analyse Premier_Timestamp

%% CSV FILE 

% Nombre de fichiers
nb_fichiers = 8;

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







