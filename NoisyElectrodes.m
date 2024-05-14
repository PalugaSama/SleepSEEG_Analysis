% Data was already downsampled in Brainstorm from 1024 to 128 hz and a
% bipolar montage was applied. HB and Sleep

%% Load Data %%
%
% File.mat = Brainstorm Matrix
chemin_fichier = '/home/localadmin/Documents/AnalyseHEP/DATA_128_BIP/N2_8.mat';

data = load(chemin_fichier);
raw_data = data.F;

%% ---------- - PRE PROCESSING :  Noisy Electrodes --------------- %% 

% Calculer l'écart-type de chaque canal dans raw_data_seeg
SD = std(raw_data, [], 2);

% Calculer la moyenne et l'écart-type global
mean_SD = mean(SD);
thr = 3 * mean_SD;

% Identifier les canaux bruyants (avec un écart-type supérieur au seuil)
%Noisy_Channels = find(SD > thr);

% Charger les noms des électrodes à partir du fichier texte
nom_fichier = 'Electrodes_Names_Bipolar.txt';
fid = fopen(nom_fichier, 'r');
Electrodes_Names = textscan(fid, '%s');
fclose(fid);
Electrodes_Names = Electrodes_Names{1};

% Electrodes Noisy identifiees grace a brainstorm PSD + > 3 SD in matlab
Noisy_Channels = [19, 20, 28, 50, 51, 52, 73, 74, 75];

% Afficher le nombre d'électrodes bruyantes identifiées et leurs indices et noms
fprintf('%d électrodes bruyantes ont été identifiées :\n', numel(Noisy_Channels));
for i = 1:numel(Noisy_Channels)
    indice = Noisy_Channels(i);
    nom = Electrodes_Names{indice};
    fprintf('Indice de l''électrode bruyante : %d, Nom de l''électrode : %s\n', indice, nom);
end

% Exclure les canaux bruyants
Good_Channels = setdiff(1:size(raw_data, 1), Noisy_Channels);
raw_data_clean = raw_data(Good_Channels, :);

% Créer une version mise à jour de Electrodes_Names
Electrodes_Names_Clean = Electrodes_Names;
Electrodes_Names_Clean(Noisy_Channels) = [];

% Afficher les informations stockées
fprintf('Electrodes_Names a été mis à jour pour correspondre à raw_data_clean.\n');

%% Save Data
% Chemin de sauvegarde du fichier
chemin_sauvegarde = '/home/localadmin/Documents/AnalyseHEP/DATA_Clean/N2_8_clean.mat';

% Créer une copie totale des données
data_clean = data;

% Remplacer la clé 'F' par 'raw_data_clean'
if isfield(data_clean, 'F')
    data_clean.raw_data_clean = raw_data_clean;
    data_clean = rmfield(data_clean, 'F');
end

% Remplacer la clé 'ChannelsFlag' par 'Electrodes_Names_Clean'
if isfield(data_clean, 'ChannelFlag')
    data_clean.Electrodes_Names_Clean = Electrodes_Names_Clean;
    data_clean = rmfield(data_clean, 'ChannelFlag');
end
% Enregistrer les données mises à jour
save(chemin_sauvegarde, '-struct', 'data_clean');

%%
fprintf('Terminé')



