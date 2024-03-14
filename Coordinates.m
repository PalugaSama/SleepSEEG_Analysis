
%% ---------------- Obtain a list of coordinates from 3D slicer -----------------
% List of files from 3D Slicer in .mrk.json format with electrodes
% coordinates in LPS system. Put it in the order expected in Brainstorm (see Channel File)
listeFichiers = {'A.mrk.json', 'B.mrk.json', 'I.mrk.json','F.mrk.json', 'L.mrk.json', 
    'J.mrk.json', 'OA.mrk.json', 'OB.mrk.json', 'OC.mrk.json', 'P.mrk.json', 'R.mrk.json', 'K.mrk.json' };

Systeme = 2; % 1 pour rester en LPS, 2 pour convertir en RAS (Brainstorm attend du RAS)

Channels = {'MKR1', 49; 'MKR2', 83; 'MKR3', 132; 'ECG3', 153; 'ECG4', 154; 'MKR4', 170; 
    'PULS', 171; 'BEAT', 172; 'SpO2', 173}; % Ajouter les canaux avec leurs positions en ligne spécifiées


%% Fonction Matrix_coordinates_Meters.mat 
% - Convertion LPS to RAS
% - Convertion from mm to meters
% - Create Matrice MatrixCoordinates_M and save it in the current folder
Matrix_Coordinates_Meters( listeFichiers, Systeme)

%% Convertion Brainstorm 
% Import Matrix on Brainstorm
% sMri: MRI structure from the database: right-click on the MRI file > File > Export to Matlab > sMri
% src/dest: Source and destination coordinates systems: {'voxel', 'mri', 'scs', 'mni', 'world'}
% P: List of points [Npoints x 3]
% All the the coordinates have to be in meters (not millimeters). 

% Pdest = cs_convert(sMri, 'src', 'dest', Psrc);

% Permet de convertir RAS Meters (MNI system) into SCS system géré par
% Brainstorm 
P = cs_convert(sMRI, 'MNI', 'SCS', MatrixCoordinates_M)

%% Ecrire fichiers texte pour importer sur Brainstorm
