import_data;

training_set_task2 = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, {'Case', 'Task2'});
training_set_task2.Task2(:) = 4;

test_set_task2 = test_set();
test_set_task2.Task2 = NaN(height(test_set_task2), 1);

% Aggiungi una colonna 'Name' che segue il formato "CaseXXX"
startIndex = 178;
numRows = height(test_set_task2);
nameStrings = arrayfun(@(x) sprintf('Case%d', x), startIndex:(startIndex+numRows-1), 'UniformOutput', false);
test_set_task2.Name = nameStrings(:);

% Filtra i nomi dei case in results_table dove Task1 == 1
filteredCaseNames = results_table.Case(results_table.Task1 == 1);

% Mantieni solo le righe di test_set_task2 i cui Name sono in filteredCaseNames
test_set_task2 = test_set_task2(ismember(test_set_task2.Name, filteredCaseNames), :);

% Richiama la funzione
k = 5;
[finalModel, falsi_positivi, featureTable_t2_1st, featureTable_test_t2] = one_class_classifier(training_set_task2, test_set_task2, k);

% Mappatura Member -> Case per la tabella delle feature di test
startIndex = 178;
uniqueMembers = unique(featureTable_test_t2.EnsembleID_);
memberToCaseMap = containers.Map(uniqueMembers, startIndex:(startIndex + numel(uniqueMembers) - 1));

% Aggiungi la colonna CaseName alla tabella delle feature di test
featureTable_test_t2.CaseName = cell(height(featureTable_test_t2), 1);
for i = 1:height(featureTable_test_t2)
    featureTable_test_t2.CaseName{i} = sprintf('Case%d', memberToCaseMap(featureTable_test_t2.EnsembleID_{i}));
end

% Predizione per i member e calcolo del voto di maggioranza per ogni case
uniqueCases = unique(featureTable_test_t2.CaseName);
finalLabels = zeros(height(uniqueCases), 1);

for i = 1:height(uniqueCases)
    currentCase = uniqueCases{i};
    caseRows = featureTable_test_t2(strcmp(featureTable_test_t2.CaseName, currentCase), :);

    % Seleziona solo le feature numeriche
    featureColumns = featureTable_t2_1st.Properties.VariableNames(3:end);
    numericData = caseRows(:, featureColumns);
    numericData = numericData{:,:}; % Estrai come matrice

    % Verifica dimensione dei dati e colonne
    disp(['Case: ', currentCase, ' - Dimensione dati: ', mat2str(size(numericData))]);

    % Predizione per ciascuna finestra temporale
    [isAnomaly, ~] = isanomaly(finalModel, numericData);

    % Conta le anomalie
    numAnomalie = sum(isAnomaly);
    disp(['Case ', currentCase, ' - Anomalie rilevate: ', num2str(numAnomalie), ' su ', num2str(height(caseRows))]);

    % Voto di maggioranza
    if numAnomalie >= floor(height(caseRows) / 2)
        finalLabel = 1; % Unknown anomaly
    else
        finalLabel = 4; % Normale
    end

    finalLabels(i) = finalLabel;
end

% Creiamo la tabella finale
caseLabelTable = table(uniqueCases, finalLabels, 'VariableNames', {'Case', 'CaseLabel'});

% Visualizziamo la tabella finale
disp(caseLabelTable);

% Test su rumore bianco per verifica
numSamples = 100;
numFeatures = size(featureTable_t2_1st, 2) - 2;
X_noise = randn(numSamples, numFeatures);
[isAnomaly_noise, ~] = isanomaly(finalModel, X_noise);
disp(['Anomalie rilevate nel rumore bianco: ', num2str(sum(isAnomaly_noise))]);
