%% **Preparazione del training set**
training_set_task2 = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, {'Case', 'Task2'});
training_set_task2.Task2(:) = 4; % Uniformiamo l'etichetta

%% **Preparazione del test set**
% Creazione del test set partendo dai dati grezzi
test_set_task2 = test_set();

% Aggiunta colonna 'Name' con formato "CaseXXX"
startIndex = 178;
numRows = height(test_set_task2);
test_set_task2.Name = (startIndex:(startIndex+numRows-1))'; % Assegna direttamente i numeri

% Filtriamo solo i Case in cui Task1 == 1
filteredCaseNames = final_predictions_t1.Case(final_predictions_t1.Task1 == 1);
test_set_task2 = test_set_task2(ismember(test_set_task2.Name, filteredCaseNames), :);

%% **Caricamento o addestramento del modello**
model_filename = 'task2/1st classifier/results/best_model_t2_1st.mat';

if isfile(model_filename)
    % Se il modello esiste, lo carichiamo invece di riaddestrarlo
    load(model_filename, 'bestModel', 'bestParams');
    disp('Modello caricato con successo!');
else
    % Se il modello NON esiste, eseguiamo la grid search e addestriamo il modello
    k = 5;
    [bestModel, bestParams, bestFalsiPositivi, featureTable_t2_1st, featureTable_test_t2, selected_feature_names_t2] = one_class_classifier_gridsearch(training_set_task2, test_set_task2, k);
    
    % Salvataggio del modello
    save(model_filename, 'bestModel', 'bestParams');
    disp('Modello salvato con successo dopo il training.');
end

%% **Mappatura EnsembleID -> Case per la tabella delle feature di test**
uniqueMembers = unique(featureTable_test_t2.Case);
numUniqueMembers = numel(uniqueMembers);
numFilteredCases = numel(filteredCaseNames);

if numUniqueMembers ~= numFilteredCases
    error('Mismatch tra il numero di members unici e il numero di Case filtrati!');
end

% Convertiamo le chiavi della mappa in `double`
% Se uniqueMembers è una cell array, convertiamola in un array numerico
if iscell(uniqueMembers)
    uniqueMembers = cellfun(@double, uniqueMembers);
end

% Se filteredCaseNames è una cell array, convertiamola in un array numerico
if iscell(filteredCaseNames)
    filteredCaseNames = cellfun(@double, filteredCaseNames);
end

% Creazione della mappa tra Members e Case filtrati
memberToCaseMap = containers.Map(uniqueMembers, filteredCaseNames);

% Assicuriamoci che `featureTable_test_t2.Case` sia numerico prima di usarlo come chiave nella mappa
featureTable_test_t2.Case = str2double(string(featureTable_test_t2.Case)); % Converte cell array di stringhe in numeri

% Aggiunta della colonna CaseName a featureTable_test_t2 per il voto di maggioranza
featureTable_test_t2.CaseName = cell(height(featureTable_test_t2), 1);

% Esegui il mapping senza errori
for i = 1:height(featureTable_test_t2)
    featureTable_test_t2.CaseName{i} = memberToCaseMap(featureTable_test_t2.Case(i));
end

% Assicura che featureTable_test_t2.CaseName sia una cell array di stringhe
if isnumeric(featureTable_test_t2.CaseName)
    featureTable_test_t2.CaseName = cellstr(string(featureTable_test_t2.CaseName)); 
elseif iscell(featureTable_test_t2.CaseName)
    featureTable_test_t2.CaseName = cellfun(@(x) cellstr(string(x)), featureTable_test_t2.CaseName, 'UniformOutput', false);
end

% Appiattisce eventuali celle nidificate
featureTable_test_t2.CaseName = cellfun(@char, featureTable_test_t2.CaseName, 'UniformOutput', false);

% Ora possiamo usare unique senza errori
uniqueCases = unique(featureTable_test_t2.CaseName);


finalLabels = zeros(height(uniqueCases), 1);

for i = 1:height(uniqueCases)
    currentCase = uniqueCases{i};
    caseRows = featureTable_test_t2(strcmp(featureTable_test_t2.CaseName, currentCase), :);

    % Seleziona solo le feature numeriche, ESCLUDENDO 'CaseName'
    featureColumns = selected_feature_names_t2; % Usa le feature selezionate precedentemente
    numericData = caseRows(:, featureColumns);
    numericData = numericData{:,:}; % Converti in matrice

    % Verifica dimensione dei dati e colonne
    %disp(['Case: ', currentCase, ' - Dimensione dati: ', mat2str(size(numericData))]);

    % Predizione per ciascuna finestra temporale
    [isAnomaly, ~] = isanomaly(bestModel, numericData);

    % Conta le anomalie rilevate
    numAnomalie = sum(isAnomaly);
    %disp(['Case ', currentCase, ' - Anomalie rilevate: ', num2str(numAnomalie), ' su ', num2str(height(caseRows))]);

    % Voto di maggioranza per determinare l'etichetta finale
    if numAnomalie >= 1
        finalLabel = 1; % Unknown anomaly
    else
        finalLabel = 4; % Known anomaly
    end

    finalLabels(i) = finalLabel;
end

%% **Creazione della tabella finale con i risultati**
results_t2_1st = table(uniqueCases, finalLabels, 'VariableNames', {'Case', 'CaseLabel'});

