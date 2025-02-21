%task2_1st;

% Filtra solo i casi con Task2 == 4 da caseLabelTable
filteredCases = results_t2_1st.Case(results_t2_1st.CaseLabel == 4);

training_set_task2_2nd = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, {'Case', 'Task2'});

test_set_task2_2nd = results_t2_1st(results_t2_1st.CaseLabel == 4, {'Case', 'CaseLabel'});

test_raw_data = test_set();

% Aggiungi una colonna vuota per contenere i dati grezzi (come cell array)
test_set_task2_2nd.RawData = cell(height(test_set_task2_2nd), 1);

% Indice iniziale dei Case
startIndex = 178;

% Popola la colonna RawData prendendo i dati grezzi dalla tabella test_raw_data
for i = 1:height(test_set_task2_2nd)
    % Estrai il numero del Case dall'etichetta 'CaseXXX'
    caseNumber = str2double(erase(test_set_task2_2nd.Case{i}, 'Case'));

    % Calcola l'indice della riga corrispondente in test_raw_data
    rawDataIndex = caseNumber - startIndex + 1;

    % Assegna la sottotabella dei dati grezzi
    test_set_task2_2nd.RawData{i} = test_raw_data.Case{rawDataIndex};
end

test_set_task2_2nd.Task2 = NaN(height(test_set_task2_2nd), 1);

test_set_task2_2nd = test_set_task2_2nd(:, {'RawData', 'Task2'});
test_set_task2_2nd.Properties.VariableNames = {'Case', 'Task2'};

[featureTable_test_task2_2nd, ~] = feature_gen_t2_2nd(test_set_task2_2nd);

load('task2/2nd classifier/results/rusBoostedTrees.mat', 'finalModel_task2_2nd');

%% Addestrare un classificatore a distinguere tra Bubble Anomaly e Vaulve Fault
% utilizzando come training set i 177 case etichettati, filtrando solo per
% Known Anomaly (etichetta Fault e Anomaly)
% classificazione tramite codice

% Predizione sui dati di test del secondo classificatore
[yfit_task2_2nd, ~] = finalModel_task2_2nd.predictFcn(featureTable_test_task2_2nd);

% Estrai il numero dei Member da EnsembleID_ (Member X -> X)
memberNumbers = str2double(erase(featureTable_test_task2_2nd.EnsembleID_, 'Member '));

% Assumi che i Member siano assegnati in blocchi ai Case con etichetta 4
numMembersPerCase = numel(memberNumbers) / numel(filteredCases);

if mod(numMembersPerCase, 1) ~= 0
    error('Il numero di Member non è divisibile esattamente per i Case!');
end

% Crea la mappatura Member -> Case usando filteredCases
caseMapping = repelem(filteredCases, numMembersPerCase);

% Assegna la colonna Case mappata ai risultati
results_t2_2nd = table(caseMapping, yfit_task2_2nd, 'VariableNames', {'Case', 'Task2'});

% Voto di maggioranza per ogni Case
[uniqueCases, ~, idx] = unique(results_t2_2nd.Case);
yfit_majority = accumarray(idx, results_t2_2nd.Task2, [], @mode);

% Tabella finale con una sola riga per ogni Case
results_t2_2nd = table(uniqueCases, yfit_majority, 'VariableNames', {'Case', 'Task2'});

% Carica il file CSV dei risultati del Task 1
results_task1 = readtable('results.csv');

% Inizializza la colonna Task2 con 0 per default
results_task1.Task2 = zeros(height(results_task1), 1);

% 1. Imposta Task2 = 1 per i Case con Unknown anomaly (CaseLabel == 1)
idx_unknown = ismember(results_task1.Case, results_t2_1st.Case(results_t2_1st.CaseLabel == 1));
results_task1.Task2(idx_unknown) = 1;

% 2. Imposta Task2 = 2 o 3 per i Case classificati dal secondo classificatore
for i = 1:height(results_t2_2nd)
    idx_case = strcmp(results_task1.Case, results_t2_2nd.Case{i});
    if any(idx_case)
        results_task1.Task2(idx_case) = results_t2_2nd.Task2(i);
    end
end

% Salva il file finale
writetable(results_task1, 'results.csv');

