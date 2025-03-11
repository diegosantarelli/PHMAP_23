%% 1. Preparazione del dataset

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

%% 2. Generazione delle feature per il clustering
[featureTable_t2_1st, ~] = feature_gen_t2_1st(training_set_task2); 
[featureTable_test_t2, ~] = feature_gen_t2_1st(test_set_task2);

% Mappatura Member -> Case per la tabella delle feature di test
uniqueMembers = unique(featureTable_test_t2.EnsembleID_);
numUniqueMembers = numel(uniqueMembers);
numFilteredCases = numel(filteredCaseNames);

if numUniqueMembers ~= numFilteredCases
    error('Mismatch tra il numero di members unici e il numero di Case filtrati!');
end

% Associa i Member ai Case filtrati SEGUENDO L'ORDINE di filteredCaseNames
memberToCaseMap = containers.Map(uniqueMembers, filteredCaseNames);

% Aggiungi la colonna CaseName a featureTable_test_t2
featureTable_test_t2.CaseName = cell(height(featureTable_test_t2), 1);
for i = 1:height(featureTable_test_t2)
    featureTable_test_t2.CaseName{i} = memberToCaseMap(featureTable_test_t2.EnsembleID_{i});
end

%% 3. Estrazione delle feature numeriche per il clustering DBSCAN
featureColumns = setdiff(featureTable_t2_1st.Properties.VariableNames(5:end), {'CaseName'});
numericData = featureTable_test_t2(:, featureColumns);
numericData = numericData{:,:}; % Converti in matrice numerica

% Standardizzazione (opzionale, ma consigliata per DBSCAN)
numericData = normalize(numericData);

%% 4.1 Ottimizzazione dei parametri DBSCAN
epsilon_values = linspace(0.5, 5, 10); % Prova epsilon tra 0.5 e 5 con 10 valori
minPts_values = [5, 10, 15, 20, 25, 30, 35]; % Prova diversi valori per minPts

bestEpsilon = NaN;
bestMinPts = NaN;
bestSilhouette = -Inf; % Peggior caso iniziale

disp('Ottimizzazione dei parametri DBSCAN...');
results = []; % Per memorizzare i risultati

for eps = epsilon_values
    for minPts = minPts_values
        % Esegui DBSCAN con i parametri attuali
        labels = dbscan(numericData, eps, minPts);
        
        % Conta il numero di cluster e outlier
        uniqueClusters = unique(labels);
        numClusters = sum(uniqueClusters >= 0);
        numOutliers = sum(labels == -1);
        
        % Stampiamo i risultati per analizzare il comportamento
        fprintf('Eps: %.2f, MinPts: %d -> Cluster: %d, Outliers: %d\n', eps, minPts, numClusters, numOutliers);
        
        % Salviamo i risultati per dopo
        results = [results; eps, minPts, numClusters, numOutliers];

        % Evita combinazioni con tutti i punti outlier
        if numClusters < 1 || numOutliers > 0.7 * length(labels)
            continue;
        end

        % Calcola il Silhouette Score solo se ci sono almeno due cluster
        if numClusters >= 2
            silScores = silhouette(numericData, labels);
            silScore = mean(silScores);
            
            % Aggiorna i parametri migliori se il Silhouette Score è migliore
            if silScore > bestSilhouette
                bestSilhouette = silScore;
                bestEpsilon = eps;
                bestMinPts = minPts;
            end
        end
    end
end

% Se nessuna combinazione è stata selezionata, scegliamo la migliore tra quelle provate
if isnan(bestEpsilon) || isnan(bestMinPts)
    disp('Nessuna combinazione ottimale trovata, selezioniamo i migliori parametri trovati.');
    
    % Selezioniamo il valore di epsilon che ha generato più cluster validi
    validResults = results(results(:, 3) >= 1, :); % Consideriamo solo configurazioni con almeno 1 cluster
    if ~isempty(validResults)
        [~, bestIdx] = max(validResults(:, 3)); % Massimizza il numero di cluster
        bestEpsilon = validResults(bestIdx, 1);
        bestMinPts = validResults(bestIdx, 2);
    else
        % Se non troviamo niente, usiamo dei default più sicuri
        warning('Ancora nessun parametro valido, uso epsilon=1.5 e minPts=10.');
        bestEpsilon = 3.0;
        bestMinPts = 15;
    end
end

fprintf('Miglior epsilon: %.2f, miglior minPts: %d, Silhouette Score: %.3f\n', bestEpsilon, bestMinPts, bestSilhouette);

%% 4.2 Applicazione del clustering DBSCAN con i parametri migliori
clustLabels = dbscan(numericData, bestEpsilon, bestMinPts);

%% 5. Identificazione delle anomalie
isAnomaly = (clustLabels == -1); % I punti con etichetta -1 sono outlier

% Creazione di una colonna nel dataset con le etichette DBSCAN
featureTable_test_t2.DBSCAN_Label = clustLabels;
featureTable_test_t2.IsAnomaly = isAnomaly;

%% 6. Voto di maggioranza per determinare l'etichetta finale di ogni Case
uniqueCases = unique(featureTable_test_t2.CaseName);
finalLabels = zeros(height(uniqueCases), 1);

for i = 1:height(uniqueCases)
    currentCase = uniqueCases{i};
    caseRows = featureTable_test_t2(strcmp(featureTable_test_t2.CaseName, currentCase), :);

    % Conta le anomalie rilevate per il Case corrente
    numAnomalie = sum(caseRows.IsAnomaly);
    disp(['Case ', currentCase, ' - Anomalie DBSCAN: ', num2str(numAnomalie), ' su ', num2str(height(caseRows))]);

    % Voto di maggioranza per la classificazione
    if numAnomalie >= 4
        finalLabel = 1; % Unknown anomaly
    else
        finalLabel = 4; % Known Anomaly
    end

    finalLabels(i) = finalLabel;
end

%% 7. Creazione della tabella finale con i risultati
results_dbscan = table(uniqueCases, finalLabels, 'VariableNames', {'Case', 'CaseLabel'});

%% 8. Confronto con il file answer.csv

% Carica il file con le etichette reali
answer_table = readtable('dataset/test/answer.csv');

% Converti la colonna 'Case' di results_dbscan in numeri rimuovendo 'Case' e trasformandoli in double
numericCases = cellfun(@(x) str2double(extractAfter(x, 4)), results_dbscan.Case);

% Aggiungi la colonna numerica alla tabella dei risultati
results_dbscan.NumericCase = numericCases;

% Unisci i risultati con le risposte reali sulla base dell'ID numerico
comparison_table = outerjoin(results_dbscan, answer_table, 'LeftKeys', 'NumericCase', 'RightKeys', 'ID', 'MergeKeys', true);

% Rinomina le colonne per chiarezza
comparison_table.Properties.VariableNames{'task2'} = 'TrueLabel';
comparison_table.Properties.VariableNames{'CaseLabel'} = 'PredictedLabel';

% Rimuove eventuali casi con etichetta TrueLabel mancante
comparison_table = comparison_table(~isnan(comparison_table.TrueLabel), :);

% Rimuove le righe con valore vuoto ("") nella colonna 'Case'
comparison_table = comparison_table(~strcmp(comparison_table.Case, ""), :);

% Converti i valori 2 e 3 in 4 nella colonna TrueLabel
comparison_table.TrueLabel(ismember(comparison_table.TrueLabel, [2, 3])) = 4;

% Calcola il numero di corrispondenze corrette
numCorrect = sum(comparison_table.PredictedLabel == comparison_table.TrueLabel);
numTotal = height(comparison_table);

% Calcola accuratezza
accuracy = (numCorrect / numTotal) * 100;

% Mostra la tabella con il confronto
disp(comparison_table);

% Mostra l'accuratezza del modello
fprintf('Accuratezza del modello DBSCAN: %.2f%%\n', accuracy);
