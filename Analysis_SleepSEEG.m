

%% -------------ANALYSE SLEEP CONFIDENCE ---------------------

%  RUN  [SleepStage]=SleepSEEG(FileList,ExtraFiles)
% 'SAVE AS' the output 'ans' in a variable 'Sleep_Confidence' 
% in a file Patient X > Output_SleepSEEG > Sleep_Confidence_SX  

%  --- Create a clone SC_SX

% SC = Sleep_Confidence

%  --- Ajouter un indice

% Créer une séquence d'indices
indices = (1:size(SC, 1))';
SC(:, 6) = indices;
disp(SC);


% 4) save SC_SX dans Analysis

%% Visualisation %%%% 

%--- Confidence threshold
theta = 0.50

% ------- Histogramme de distribution --- OK
% [h] = Distribution(SC, theta);


% -------- Basic Stats ---------- OK
% StatsMatrix = Stats(SC, theta);

% --- Extract matrice with epochs of interest

%% CREATE MATRIX WITH HIGH CONFIDENCE EPOCHS %%

% High_confidence = SC(SC(:, 4) > theta, :);

%% Suppress useless column
% High_confidence(:, [5, 6, 7]) = [];

%% Recuperer timestamps des epochs %%

%% temps MATLAB
% temps_matlab = High_confidence(:, 2);
% 
%% temps en datetime
% temps_normal = datetime(temps_matlab, 'ConvertFrom', 'datenum');
% 
%% Matrice avec heure
% date_heure_vec = datevec(temps_normal);

%% Ajouter les colonnes 4, 5 et 6 de date_heure_vec à High_confidence
% High_confidence(:, end + 1:end + 3) = date_heure_vec(:, 4:6);
% 
%% Afficher la matrice mise à jour
% disp(High_confidence);
%
%% Save High_confidence as High_confidence_Sx










