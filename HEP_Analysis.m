
%% Formatage FieldTrip 1 fichier 
% Chemin du fichier texte contenant les noms des canaux
chemin_fichier_noms = '/home/localadmin/Documents/AnalyseHEP/Electrodes_Names_Bip_Clean.txt';

% Charger les noms des canaux à partir du fichier texte
noms_canaux = importdata(chemin_fichier_noms);

% Chemin du fichier à mettre à jour
file_path = '/home/localadmin/Documents/AnalyseHEP/HEP/W/HB_W_6759-1.mat';

% Charger le fichier
data = load(file_path);

% Créer la structure FieldTrip
ft_data = struct();
ft_data.hdr = struct()
ft_data.label = noms_canaux; % Noms des canaux
ft_data.trial = data.segment_data; % Données du signal (segment_data)
ft_data.time = data.segment_time; % Temps correspondant aux données du signal (segment_time)
ft_data.fsample = 128; % Fréquence d'échantillonnage

save(file_path, 'ft_data');

%% Formatage fieldtrip tous les fichiers. 

% Chemin du dossier principal
chemin_dossier_principal = '/home/localadmin/Documents/AnalyseHEP/HEP';

% Liste des dossiers à parcourir
dossiers = {'W', 'N2', 'N3', 'REM'};

% Chemin du fichier texte contenant les noms des canaux
chemin_fichier_noms = '/home/localadmin/Documents/AnalyseHEP/Electrodes_Names_Bip_Clean.txt';

% Charger les noms des canaux à partir du fichier texte
noms_canaux = importdata(chemin_fichier_noms);

% Parcourir les dossiers
for i = 1:numel(dossiers)
    dossier = dossiers{i};
    chemin_dossier = fullfile(chemin_dossier_principal, dossier);
    
    % Liste des fichiers .mat dans le dossier
    fichiers_mat = dir(fullfile(chemin_dossier, '*.mat'));
    
    % Parcourir les fichiers .mat
    for j = 1:numel(fichiers_mat)
        file_path = fullfile(chemin_dossier, fichiers_mat(j).name);
        
        % Charger le fichier
        data = load(file_path);
        
        % Créer la structure FieldTrip
        ft_data = struct();
        ft_data.hdr = struct(); % Création de la sous-structure hdr
        ft_data.label = noms_canaux; % Assignation des noms des canaux
        ft_data.trial = data.segment_data; % Assignation des données du signal (segment_data)
        ft_data.time = data.segment_time; % Assignation des temps correspondants aux données du signal (segment_time)
        ft_data.fsample = 128; %Frequence 
        % Sauvegarde de la structure FieldTrip dans le même fichier .mat
        save(file_path, 'ft_data');
        
        % Affichage d'un message de confirmation
        disp(['Fichier ' file_path ' mis à jour au format FieldTrip avec succès.']);
    end
end

% Affichage d'un message de fin
disp('Mise à jour terminée avec succès.');

%% Filtre bandpass 1 fichier
% Fréquence d'échantillonnage
Fs = 128; % Hz

% Fréquence de coupure
low_cutoff = 4; % Hz

% Chemin du fichier FieldTrip à charger
file_path = '/home/localadmin/Documents/AnalyseHEP/HEP/HB_W_6768-1.mat';

% Charger le fichier
loaded_data = load(file_path);

% Accéder à la structure ft_data
ft_data = loaded_data.ft_data;

% Configuration du filtre passe-haut
cfg = [];
cfg.hpfilter = 'yes'; % Filtrage passe-haut
cfg.hpfreq = low_cutoff; % Fréquence de coupure basse
cfg.hpfilttype = 'firws'; % Type de filtre

% Appliquer le filtre
filtered_data = ft_preprocessing(cfg, ft_data);

% Afficher un message de succès
disp('Filtre passe-haut appliqué avec succès.');

save(file_path, 'filtered_data')

% Vérifier le contenu de la structure filtrée
disp(filtered_data);


%% Analyse de frequence
% Paramètres pour l'analyse de fréquence
cfg = [];
cfg.method = 'mtmfft';  % Méthode de l'estimation de puissance
cfg.output = 'pow';     % Type de sortie : puissance spectrale
cfg.taper = 'hanning';   % Fenêtrage
cfg.foi = 0:1:64;       % Fréquences d'intérêt (de 0 à 64 Hz avec un pas de 1 Hz)
cfg.pad = 'nextpow2';   % Padding pour une puissance de 2
cfg.keeptrials = 'yes'; % Conserver les essais

% Effectuer l'analyse de fréquence
freq_data = ft_freqanalysis(cfg, ft_data);

% Tracer le spectre de puissance
figure;
plot(freq_data.freq, 10*log10(squeeze(freq_data.powspctrm)));
xlabel('Fréquence (Hz)');
ylabel('Puissance (dB)');
title('Raw Power of 1 trial');

%% Filtrage tous les fichiers 

% Chemin du répertoire contenant les dossiers W, N2, N3 et REM
directory_path = '/home/localadmin/Documents/AnalyseHEP/HEP/';

% Liste des dossiers à parcourir
folders = {'W', 'N2', 'N3', 'REM'};

% Configuration du filtre passe-haut
low_cutoff = 4; % Hz
cfg = [];
cfg.hpfilter = 'yes'; % Filtrage passe-haut
cfg.hpfreq = low_cutoff; % Fréquence de coupure basse
cfg.hpfilttype = 'firws'; % Type de filtre

% Parcourir chaque dossier
for i = 1:length(folders)
    folder = folders{i};
    folder_path = fullfile(directory_path, folder);
    
    % Obtenir la liste des fichiers MAT dans le dossier
    file_list = dir(fullfile(folder_path, '*.mat'));
    
    % Afficher un message de début de traitement du dossier
    disp(['Début du traitement du dossier ' folder '...']);
    
    % Parcourir chaque fichier
    for j = 1:length(file_list)
        file_name = file_list(j).name;
        file_path = fullfile(folder_path, file_name);
        
        % Charger le fichier
        loaded_data = load(file_path);
        ft_data = loaded_data.ft_data;
        
        % Appliquer le filtre
        filtered_data = ft_preprocessing(cfg, ft_data);
        
        % Sauvegarder le fichier filtré
        save(file_path, 'filtered_data');
        
        % Afficher un message de succès pour chaque trial
        disp(['Filtre appliqué avec succès au fichier ' file_name '.']);
    end
    
    % Afficher un message de fin de traitement du dossier
    disp(['Fin du traitement du dossier ' folder '.']);
end

% Afficher un message de fin de traitement de tous les dossiers
disp('Tous les fichiers ont été traités avec succès.');




%% Trials Noisy 

% Chemin vers les dossiers W, N2, N3 et REM
folders = {'W', 'N2', 'N3', 'REM'};
base_path = '/home/localadmin/Documents/AnalyseHEP/HEP/';

% Matrice pour stocker les moyennes et SD de chaque dossier
noise_stats = zeros(numel(folders), 2); % Colonne 1 pour la moyenne, Colonne 2 pour l'écart type

% Boucle sur les dossiers
for i = 1:numel(folders)
    folder = folders{i};
    folder_path = fullfile(base_path, folder);
    
    % Initialiser les valeurs pour stocker le bruit moyen et SD
    mean_noise = [];
    std_noise = [];
    
    % Charger chaque fichier et calculer le bruit moyen
    files = dir(fullfile(folder_path, '*.mat'));
    for j = 1:numel(files)
        file_path = fullfile(folder_path, files(j).name);
        data = load(file_path);
        
        % Calculer la moyenne et l'écart type de chaque essai
        trial_means = mean(data.ft_data.trial, 2); % Moyenne de chaque essai
        mean_noise(end+1) = mean(trial_means(:)); % Calculer la moyenne du bruit
        std_noise(end+1) = std(trial_means(:)); % Calculer l'écart type du bruit
    end
    
    % Stocker la moyenne et l'écart type dans la matrice noise_stats
    noise_stats(i, 1) = mean(mean_noise); % Moyenne du bruit pour ce dossier
    noise_stats(i, 2) = mean(std_noise); % Écart type du bruit pour ce dossier
end

% Afficher les statistiques de bruit pour chaque dossier
disp('Statistiques de bruit pour chaque dossier :');
disp(noise_stats);

% Seuil pour le bruit (par exemple, 3 fois l'écart type)
thresholds = noise_stats(:, 1) + 3 * noise_stats(:, 2); % Seuil pour chaque dossier

% Créer le dossier HB_Noisy s'il n'existe pas
hb_noisy_folder = fullfile(base_path, 'HB_Noisy');
if ~exist(hb_noisy_folder, 'dir')
    mkdir(hb_noisy_folder);
end

% Boucle sur les dossiers pour trier les fichiers
total_noisy_trials = 0; % Initialiser le compteur total

for i = 1:numel(folders)
    folder = folders{i};
    folder_path = fullfile(base_path, folder);
    
    % Initialiser le compteur pour le dossier actuel
    noisy_trials_in_folder = 0;
    
    % Charger chaque fichier et déplacer les fichiers bruyants
    files = dir(fullfile(folder_path, '*.mat'));
    for j = 1:numel(files)
        file_path = fullfile(folder_path, files(j).name);
        data = load(file_path);
        
        % Calculer la moyenne et l'écart type de chaque essai
        trial_means = mean(data.ft_data.trial, 2); % Moyenne de chaque essai
        mean_noise = mean(trial_means(:)); % Moyenne du bruit
        
        % Déplacer le fichier si le bruit est supérieur au seuil
        if mean_noise > thresholds(i)
            % Déplacer le fichier vers HB_Noisy
            movefile(file_path, hb_noisy_folder);
            disp(['Fichier ' files(j).name ' déplacé vers HB_Noisy.']);
            noisy_trials_in_folder = noisy_trials_in_folder + 1; % Incrémenter le compteur du dossier
            total_noisy_trials = total_noisy_trials + 1; % Incrémenter le compteur total
        end
    end
    
    % Afficher un message de fin de traitement du dossier
    disp(['Fin du traitement du dossier ' folder '. Trials noisy déplacés : ' num2str(noisy_trials_in_folder)]);
end

% Afficher un message de fin de traitement de tous les dossiers
disp(['Tous les dossiers ont été traités. Total des trials noisy déplacés : ' num2str(total_noisy_trials)]); 

