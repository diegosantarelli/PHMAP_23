task1_completed;

% Seleziona solo i dati di training con Task2 == 2 o Task2 == 3
training_set_task2 = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, {'Case', 'Task2'});
training_set_task2.Task2(:) = 4; % Uniformiamo l'etichetta

% Crea il test set
test_set_task2 = test_set();
test_set_task2.Task2 = NaN(height(test_set_task2), 1);

% Aggiungi una colonna 'Name' con il formato "CaseXXX"
startIndex = 178;
numRows = height(test_set_task2);
nameStrings = arrayfun(@(x) sprintf('Case%d', x), startIndex:(startIndex+numRows-1), 'UniformOutput', false);
test_set_task2.Name = nameStrings(:);

% Filtra i nomi dei case in results_table dove Task1 == 1
filteredCaseNames = results_table.Case(results_table.Task1 == 1);
test_set_task2 = test_set_task2(ismember(test_set_task2.Name, filteredCaseNames), :);

% Percorso del file salvato
model_filename = 'task2/1st classifier/results/best_model_t2_1st.mat';

if isfile(model_filename)
    % Se il modello esiste, caricalo invece di riaddestrarlo
    load(model_filename, 'bestModel', 'bestParams');
    disp('Modello caricato con successo!');
else
    % Se il modello NON esiste, esegui la grid search e addestralo
    k = 5;
    [bestModel, bestParams, bestFalsiPositivi, featureTable_t2_1st, featureTable_test_t2] = one_class_classifier_gridsearch(training_set_task2, test_set_task2, k);
    
    % Salva il modello appena addestrato
    save(model_filename, 'bestModel', 'bestParams');
    disp('Modello salvato con successo dopo il training.');
end


% Mappatura Member -> Case per la tabella delle feature di test
uniqueMembers = unique(featureTable_test_t2.EnsembleID_);
numUniqueMembers = numel(uniqueMembers);
numFilteredCases = numel(filteredCaseNames);

if numUniqueMembers ~= numFilteredCases
    error('Mismatch tra il numero di members unici e il numero di Case filtrati!');
end

% Associa i Member ai Case filtrati SEGUENDO L'ORDINE di filteredCaseNames
memberToCaseMap = containers.Map(uniqueMembers, filteredCaseNames);

% Aggiungi la colonna CaseName a featureTable_test_t2 solo per il voto di maggioranza
featureTable_test_t2.CaseName = cell(height(featureTable_test_t2), 1);
for i = 1:height(featureTable_test_t2)
    featureTable_test_t2.CaseName{i} = memberToCaseMap(featureTable_test_t2.EnsembleID_{i});
end

% Predizione per i member e calcolo del voto di maggioranza per ogni case
uniqueCases = unique(featureTable_test_t2.CaseName);
finalLabels = zeros(height(uniqueCases), 1);

for i = 1:height(uniqueCases)
    currentCase = uniqueCases{i};
    caseRows = featureTable_test_t2(strcmp(featureTable_test_t2.CaseName, currentCase), :);

    % Seleziona solo le feature numeriche, ESCLUDENDO 'CaseName'
    featureColumns = setdiff(featureTable_t2_1st.Properties.VariableNames(5:end), {'CaseName'});
    numericData = caseRows(:, featureColumns);
    numericData = numericData{:,:}; % Estrai come matrice

    % Verifica dimensione dei dati e colonne
    disp(['Case: ', currentCase, ' - Dimensione dati: ', mat2str(size(numericData))]);

    % Predizione per ciascuna finestra temporale
    [isAnomaly, ~] = isanomaly(bestModel, numericData);

    % Conta le anomalie
    numAnomalie = sum(isAnomaly);
    disp(['Case ', currentCase, ' - Anomalie rilevate: ', num2str(numAnomalie), ' su ', num2str(height(caseRows))]);

    % Voto di maggioranza
    if numAnomalie >= 3
        finalLabel = 1; % Unknown anomaly
    else
        finalLabel = 4; % Known Anomaly
    end

    finalLabels(i) = finalLabel;
end

% Creiamo la tabella finale con i risultati
results_t2_1st = table(uniqueCases, finalLabels, 'VariableNames', {'Case', 'CaseLabel'});

% Verifica finale: controlla che training e test abbiano lo stesso numero di feature
disp(['Numero di feature nel training set: ', num2str(size(featureTable_t2_1st, 2) - 2)]); % Escludiamo Case e Task2
disp(['Numero di feature nel test set (senza CaseName): ', num2str(size(numericData, 2))]);
