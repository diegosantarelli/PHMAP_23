%%
% Caricamento delle etichette reali dal file answer.csv
test_set_labeled_t4 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Rinominare la colonna 'ID' in 'Case' e trasformare i valori in 'CaseXXX'
test_set_labeled_t4.Case = strcat('Case', string(test_set_labeled_t4.ID));

% Mantenere solo le colonne 'Case' e 'task3' (etichette reali)
test_set_labeled_t4 = test_set_labeled_t4(:, {'Case', 'task4'});

% Rinomina la colonna 'task3' per uniformità con il codice precedente
test_set_labeled_t4.Properties.VariableNames = {'Case', 'CaseLabel_test_set_labeled_t4'};

% Caricamento delle previsioni dal file results.csv
results_t4 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Mantenere solo le colonne 'Case' e 'Task3' (previsioni del classificatore)
results_t4 = results_t4(:, {'Case', 'Task4'});

% Rinomina la colonna 'Task3' per chiarezza
results_t4.Properties.VariableNames = {'Case', 'CaseLabel_results_t4'};

% Unire le tabelle per confronto (solo Case presenti in entrambi i dataset)
merged_table_t4 = innerjoin(results_t4, test_set_labeled_t4, 'Keys', 'Case');

% Confrontare le previsioni con le etichette reali
predizioni_corrette_t4 = merged_table_t4.CaseLabel_results_t4 == merged_table_t4.CaseLabel_test_set_labeled_t4;

% Calcolare l'accuratezza
accuratezza_t4 = sum(predizioni_corrette_t4) / height(merged_table_t4);

% Visualizzare l'accuratezza
disp(['Accuratezza del quarto task: ', num2str(accuratezza_t4)]);
