%%
% Caricamento delle etichette reali dal file answer.csv
test_set_labeled_t3 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Rinominare la colonna 'ID' in 'Case' e trasformare i valori in 'CaseXXX'
test_set_labeled_t3.Case = strcat('Case', string(test_set_labeled_t3.ID));

% Mantenere solo le colonne 'Case' e 'task3' (etichette reali)
test_set_labeled_t3 = test_set_labeled_t3(:, {'Case', 'task3'});

% Rinomina la colonna 'task3' per uniformità con il codice precedente
test_set_labeled_t3.Properties.VariableNames = {'Case', 'CaseLabel_test_set_labeled_t3'};

% Caricamento delle previsioni dal file results.csv
results_t3 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Mantenere solo le colonne 'Case' e 'Task3' (previsioni del classificatore)
results_t3 = results_t3(:, {'Case', 'Task3'});

% Rinomina la colonna 'Task3' per chiarezza
results_t3.Properties.VariableNames = {'Case', 'CaseLabel_results_t3'};

% Unire le tabelle per confronto (solo Case presenti in entrambi i dataset)
merged_table_t3 = innerjoin(results_t3, test_set_labeled_t3, 'Keys', 'Case');

% Confrontare le previsioni con le etichette reali
predizioni_corrette_t3 = merged_table_t3.CaseLabel_results_t3 == merged_table_t3.CaseLabel_test_set_labeled_t3;

% Calcolare l'accuratezza
accuratezza_t3 = sum(predizioni_corrette_t3) / height(merged_table_t3);

% Visualizzare l'accuratezza
disp(['Accuratezza del classificatore Task 3: ', num2str(accuratezza_t3)]);
