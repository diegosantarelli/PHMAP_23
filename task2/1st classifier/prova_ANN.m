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
[featureTable_t2_1st, ~] = prova(training_set_task2); 
[featureTable_test_t2, ~] = prova(test_set_task2);

% Controllo se le tabelle sono vuote
if isempty(featureTable_t2_1st) || isempty(featureTable_test_t2)
    error('Errore: le tabelle delle feature sono vuote. Controllare i dati di input!');
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

% Aggiungi la colonna CaseName a featureTable_test_t2
featureTable_test_t2.CaseName = cell(height(featureTable_test_t2), 1);
for i = 1:height(featureTable_test_t2)
    featureTable_test_t2.CaseName{i} = memberToCaseMap(featureTable_test_t2.EnsembleID_{i});
end

%% 3. Estrazione delle feature numeriche per il modello OC-NN
featureColumns = setdiff(featureTable_t2_1st.Properties.VariableNames(5:end), {'CaseName'});
numericData_train = featureTable_t2_1st(:, featureColumns);
numericData_train = numericData_train{:,:}; % Converti in matrice numerica

numericData_test = featureTable_test_t2(:, featureColumns);
numericData_test = numericData_test{:,:}; % Converti in matrice numerica

% Standardizzazione dei dati
numericData_train = normalize(numericData_train);
numericData_test = normalize(numericData_test);

% Identifica righe con NaN nei dati di training
idxValidTrain = ~any(isnan(numericData_train), 2);

% Filtra i dati di training per rimuovere righe con NaN
numericData_train = numericData_train(idxValidTrain, :);

% Stampa quanti dati sono stati rimossi
fprintf('Rimosse %d righe con NaN dai dati di training.\n', sum(~idxValidTrain));


% Identifica righe valide senza NaN
idxValid = ~any(isnan(numericData_test), 2);

% Filtra sia le feature che la tabella originale per mantenere solo righe valide
numericData_test = numericData_test(idxValid, :);
featureTable_test_t2 = featureTable_test_t2(idxValid, :); % 🔹 Manteniamo solo righe valide

%% 4. Creazione della rete OC-NN (Autoencoder per Anomaly Detection)
layers = [
    featureInputLayer(size(numericData_train,2))
    fullyConnectedLayer(32)
    reluLayer
    dropoutLayer(0.2)
    fullyConnectedLayer(16)
    reluLayer
    fullyConnectedLayer(32)
    reluLayer
    fullyConnectedLayer(size(numericData_train,2)) % Ricostruzione dell'input
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs', 50, ...
    'MiniBatchSize', 16, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

% Addestramento della rete come autoencoder
net = trainNetwork(numericData_train, numericData_train, layers, options);

%% 5. Anomaly Detection tramite errore di ricostruzione

% Ricostruzione dei dati di test
numericData_test_reconstructed = predict(net, numericData_test);

% Calcolo dell'errore di ricostruzione (Mean Squared Error)
reconstructionError = mean((numericData_test - numericData_test_reconstructed).^2, 2);

% Determina la soglia basata sui dati di training
train_reconstructed = predict(net, numericData_train);
trainError = mean((numericData_train - train_reconstructed).^2, 2);

threshold = mean(trainError) + 1 * std(trainError); % Soglia dinamica basata sulla deviazione standard

% Classifica le anomalie basate sull'errore di ricostruzione
Y_pred_numeric = reconstructionError > threshold;
Y_pred_numeric = double(Y_pred_numeric) + 4; % 1 -> 4 (Known), 0 -> 1 (Unknown)

% Assegna le predizioni alla tabella featureTable_test_t2 (nessun errore di dimensione ora!)
featureTable_test_t2.NN_Label = Y_pred_numeric;


%% 6. Voto di maggioranza per determinare l'etichetta finale di ogni Case
uniqueCases = unique(featureTable_test_t2.CaseName);
finalLabels = zeros(height(uniqueCases), 1);

for i = 1:height(uniqueCases)
    currentCase = uniqueCases{i};
    caseRows = featureTable_test_t2(strcmp(featureTable_test_t2.CaseName, currentCase), :);
    
    % Conta le anomalie rilevate
    numAnomalie = sum(caseRows.NN_Label == 1);
    if numAnomalie >= 3
        finalLabel = 1; % Unknown anomaly
    else
        finalLabel = 4; % Known anomaly
    end
    
    finalLabels(i) = finalLabel;
end

% Creazione della tabella dei risultati finali
results_nn = table(uniqueCases, finalLabels, 'VariableNames', {'Case', 'CaseLabel'});

%% 7. Confronto con il file answer.csv
answer_table = readtable('dataset/test/answer.csv');

% Converti i Case in numeri per il confronto
numericCases = cellfun(@(x) str2double(extractAfter(x, 4)), results_nn.Case);
results_nn.NumericCase = numericCases;

% Unisci i risultati con le etichette reali
comparison_table = outerjoin(results_nn, answer_table, 'LeftKeys', 'NumericCase', 'RightKeys', 'ID', 'MergeKeys', true);

% Rinomina le colonne per chiarezza
comparison_table.Properties.VariableNames{'task2'} = 'TrueLabel';
comparison_table.Properties.VariableNames{'CaseLabel'} = 'PredictedLabel';

% Rimuove righe con TrueLabel mancante
comparison_table = comparison_table(~isnan(comparison_table.TrueLabel), :);

% Rimuove le righe in cui Case è un doppio apice o vuoto
comparison_table = comparison_table(~strcmp(comparison_table.Case, "") & ~strcmp(comparison_table.Case, '""'), :);

% Converti i valori 2 e 3 in 4 nella colonna TrueLabel
comparison_table.TrueLabel(ismember(comparison_table.TrueLabel, [2, 3])) = 4;

% Calcola accuratezza
numCorrect = sum(comparison_table.PredictedLabel == comparison_table.TrueLabel);
numTotal = height(comparison_table);
accuracy = (numCorrect / numTotal) * 100;

% Mostra i risultati
disp(comparison_table);
fprintf('Accuratezza del modello OC-NN: %.2f%%\n', accuracy);
