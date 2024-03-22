% Générer des données aléatoires pour l'exemple
% Supposons que SC soit une matrice avec 1000 lignes et 4 colonnes
SC = Sleep_Confidence % Data
theta = 0.5; % Seuil de confiance
nb_fichiers = 8; % Nombre de fichiers

% Activer ou désactiver différentes sorties
enableEpochsAnalyse = true;
enableHistogram = true;
enableStatsMatrix = true;
enableTimeGraph = true;

% Appel de la fonction EpochingSleep
[Epochs_analyse, h, statsMatrix, time] = EpochingSleep(SC, theta, nb_fichiers, enableEpochsAnalyse, enableHistogram, enableStatsMatrix, enableTimeGraph);

% Affichage des sorties si elles sont activées
if enableEpochsAnalyse
    disp('Résultat de EpochsAnalyse :');
    disp(Epochs_analyse);
end

if enableHistogram
    disp('Histogramme généré :');
    disp(h);
end

if enableStatsMatrix
    disp('Matrice de statistiques générée :');
    disp(statsMatrix);
end

if enableTimeGraph
    disp('Graphique temporel généré.');
end