
Patient_night = ans

% Initialisation des compteurs
count_W = 0;
count_N2 = 0;
count_N3 = 0;
count_R = 0;

% Initialisation des compteurs pour le nouveau critère
count_W_over_10 = 0;
count_N2_over_10 = 0;
count_N3_over_10 = 0;
count_R_over_10 = 0;

total_epochs_W = 0;
total_epochs_N2 = 0;
total_epochs_N3 = 0;
total_epochs_R = 0;

% Initialisation des compteurs pour le nombre d'époques ignorées
count_W_ignored = 0;
count_N2_ignored = 0;
count_N3_ignored = 0;
count_R_ignored = 0;

% Parcourir le tableau
for i = 1:size(Patient_night, 1)
    categorie_cell = Patient_night{i, 4};  % Colonne 4 : Catégorie (en tant que cellule)
    nombre_d_epoques = Patient_night{i, 5};  % Colonne 5 : Nombre d'époques consécutives

    % Convertir la cellule en chaîne de caractères
    categorie = char(categorie_cell);

    % Mise à jour des compteurs en fonction de la catégorie
    if nombre_d_epoques >= 10
        switch categorie
            case 'W'
                count_W = count_W + nombre_d_epoques;
                count_W_over_10 = count_W_over_10 + 1;
                total_epochs_W = total_epochs_W + nombre_d_epoques;
            case 'N2'
                count_N2 = count_N2 + nombre_d_epoques;
                count_N2_over_10 = count_N2_over_10 + 1;
                total_epochs_N2 = total_epochs_N2 + nombre_d_epoques;
            case 'N3'
                count_N3 = count_N3 + nombre_d_epoques;
                count_N3_over_10 = count_N3_over_10 + 1;
                total_epochs_N3 = total_epochs_N3 + nombre_d_epoques;
            case 'R'
                count_R = count_R + nombre_d_epoques;
                count_R_over_10 = count_R_over_10 + 1;
                total_epochs_R = total_epochs_R + nombre_d_epoques;
        end
    else
        % Mise à jour des compteurs pour le nombre d'époques ignorées
        switch categorie
            case 'W'
                count_W_ignored = count_W_ignored + 1;
            case 'N2'
                count_N2_ignored = count_N2_ignored + 1;
            case 'N3'
                count_N3_ignored = count_N3_ignored + 1;
            case 'R'
                count_R_ignored = count_R_ignored + 1;
        end
    end
end

total_epochs = (total_epochs_R + total_epochs_W + total_epochs_N2 + total_epochs_N3)


% Afficher les résultats
clc;

disp(' ');
disp(' ');
disp('Résultats pour les périodes de plus de 10 époques consécutives :');
disp(' ');
disp(['Le total est : ' num2str(total_epochs)]);
disp(['Le stade ''W'' est apparu ' num2str(count_W_over_10) ' fois pendant plus de 10 époques, pour un total de ' num2str(total_epochs_W) ' époques']);
disp(['Le stade ''N2'' est apparu ' num2str(count_N2_over_10) ' fois pendant plus de 10 époques, pour un total de ' num2str(total_epochs_N2) ' époques']);
disp(['Le stade ''N3'' est apparu ' num2str(count_N3_over_10) ' fois pendant plus de 10 époques, pour un total de ' num2str(total_epochs_N3) ' époques']);
disp(['Le stade ''R'' est apparu ' num2str(count_R_over_10) ' fois pendant plus de 10 époques, pour un total de ' num2str(total_epochs_R) ' époques']);
disp(' ');
disp(' ');
disp('Résultats pour les périodes ignorées (nombre d''époques <= 10) :');
disp(' ');
disp(['Le stade ''W'' a été ignoré ' num2str(count_W_ignored) ' fois']);
disp(['Le stade ''N2'' a été ignoré ' num2str(count_N2_ignored) ' fois']);
disp(['Le stade ''N3'' a été ignoré ' num2str(count_N3_ignored) ' fois']);
disp(['Le stade ''R'' a été ignoré ' num2str(count_R_ignored) ' fois']);
