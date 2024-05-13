
%%
% Chemin du fichier 
chemin_fichier = '/home/localadmin/Documents/AnalyseHEP/DATA_Clean/N2_2_clean.mat';

% Charger les données
Data = load(chemin_fichier);

% Chemin du dossier de sauvegarde
chemin_sauvegarde = '/home/localadmin/Documents/AnalyseHEP/DATA_Clean/';

% Durée avant et après chaque battement cardiaque (en secondes)
avant_HB = 0.3; % 300 ms avant
apres_HB = 0.6; % 600 ms après

% Initialiser des compteurs pour chaque catégorie
nb_W = 0;
nb_N2 = 0;
nb_N3 = 0;
nb_REM = 0;
nb_outside = 0;

% Nombre total de battements cardiaques à extraire
nb_HB = length(Data.Events(3).times); % Accéder au troisième champ 'HB'

% Boucle sur les battements cardiaques
for i = 1:nb_HB
    % Obtenir le timing du battement cardiaque
    timing_HB = Data.Events(3).times(i); % Accéder au troisième champ 'HB'
    
    % Initialiser une variable pour stocker l'événement correspondant au battement cardiaque
    event_label = '';
    
    % Boucle sur tous les événements
    for k = 1:numel(Data.Events)-1
        % Boucle sur les intervalles de temps de chaque événement
        for j = 1:size(Data.Events(k).times, 2)
            event_start = Data.Events(k).times(1, j); % Début de l'événement
            event_end = Data.Events(k).times(2, j);   % Fin de l'événement
            
            % Vérifier si le timing_HB est dans l'intervalle de l'événement
            if timing_HB > event_start && timing_HB < event_end
                event_label = Data.Events(k).label;
                break;
            end
        end
        % Sortir de la boucle interne si l'événement correspondant a été trouvé
        if ~isempty(event_label)
            break;
        end
    end

    % Si aucun événement n'a été trouvé pour le battement cardiaque
    if isempty(event_label)
        % Incrémenter le compteur pour les battements cardiaques en dehors des événements
        nb_outside = nb_outside + 1;
        % Afficher un message d'erreur
        disp(['ERREUR : Aucun événement long trouvé pour le battement cardiaque ' num2str(i)]);
    else
        % Incrémenter le compteur approprié pour la catégorie trouvée
        switch event_label
            case 'W'
                nb_W = nb_W + 1;
            case 'N2'
                nb_N2 = nb_N2 + 1;
            case 'N3'
                nb_N3 = nb_N3 + 1;
            case 'REM'
                nb_REM = nb_REM + 1;
        end

        % Déterminer l'indice du début et de la fin du segment
        start_index = round((timing_HB - avant_HB) * 128); % Convertir le temps en indice
        end_index = round((timing_HB + apres_HB) * 128); % Convertir le temps en indice

        % Extraire le segment de signal
        segment_data = Data.raw_data_clean(:, start_index:end_index);

        % Enregistrer le segment dans le dossier correspondant à l'état de conscience
        chemin_segment = fullfile(chemin_sauvegarde, event_label, ['HB_' event_label '_' num2str(i) '.mat']);
        save(chemin_segment, 'segment_data');

        % Afficher un message de succès
        disp(['Segment HB_' event_label '_' num2str(i) ' extrait et sauvegardé avec succès dans ' chemin_segment]);
    end
end

% Afficher le bilan
disp(['Nombre de HB pendant W = ' num2str(nb_W)]);
disp(['Nombre de HB pendant N2 = ' num2str(nb_N2)]);
disp(['Nombre de HB pendant N3 = ' num2str(nb_N3)]);
disp(['Nombre de HB pendant REM = ' num2str(nb_REM)]);
disp(['Nombre de HB en dehors des événements d interet = ' num2str(nb_outside)]);
