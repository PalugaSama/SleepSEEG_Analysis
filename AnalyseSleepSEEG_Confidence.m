%Sleep_Confidence = ans

High_confidence = Sleep_Confidence(Sleep_Confidence(:, 4) > 0.5, :);


% Catégorie de sommeil
categories_sommeil = {'R', 'W', 'N1', 'N2', 'N3'};

% Indices correspondants aux catégories
indices_categories = containers.Map(categories_sommeil, 1:length(categories_sommeil));

% Extraire les colonnes pertinentes
categorie_colonne = High_confidence(:, 3); % Colonne des catégories
confiance_colonne = High_confidence(:, 4); % Colonne du niveau de confiance

% Compter le nombre d'époques par catégorie
nombre_epoques_par_categorie = accumarray(categorie_colonne, 1, [length(categories_sommeil), 1]);

% Calculer la moyenne et la médiane du niveau de confiance par catégorie
moyenne_confiance_par_categorie = grpstats(confiance_colonne, categorie_colonne, {'mean'});
median_confiance_par_categorie = grpstats(confiance_colonne, categorie_colonne, {'median'});

% Afficher les résultats
for i = 1:length(categories_sommeil)
    categorie_actuelle = categories_sommeil{i};
    
    % Trouver l'indice correspondant à la catégorie actuelle
    indice_categorie = indices_categories(categorie_actuelle);
    
    % Extraire les résultats pour la catégorie actuelle
    nombre_epoques = nombre_epoques_par_categorie(indice_categorie);
    moyenne_confiance = moyenne_confiance_par_categorie(indice_categorie);
    mediane_confiance = median_confiance_par_categorie(indice_categorie);
    
    % Afficher les résultats
    disp(' ');
    disp([num2str(nombre_epoques) ' époques de catégorie ''' categorie_actuelle ''' ont été trouvées avec un niveau de confiance moyen de ' num2str(moyenne_confiance) ' et une médiane de ' num2str(mediane_confiance)]);
end
