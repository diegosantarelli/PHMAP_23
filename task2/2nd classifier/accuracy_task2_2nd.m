% Caricamento delle etichette reali dal file answer.csv
test_set_labeled_t2 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Rinominare la colonna 'ID' in 'Case' e trasformare i valori in 'CaseXXX'
test_set_labeled_t2.Case = strcat('Case', string(test_set_labeled_t2.ID));

% Mantenere solo le colonne 'Case' e 'task2' (etichette reali)
test_set_labeled_t2 = test_set_labeled_t2(:, {'Case', 'task2'});

% Rinomina la colonna 'task2' per uniformità con il codice precedente
test_set_labeled_t2.Properties.VariableNames = {'Case', 'CaseLabel_test_set_labeled_t2'};

% Filtrare solo le etichette 2 e 3 dalle etichette reali
test_set_labeled_t2_filtered = test_set_labeled_t2(ismember(test_set_labeled_t2.CaseLabel_test_set_labeled_t2, [2, 3]), :);

% Caricamento delle previsioni dal file results.csv
results_t2_2nd = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Mantenere solo le colonne 'Case' e 'Task2' (previsioni del secondo classificatore)
results_t2_2nd = results_t2_2nd(:, {'Case', 'Task2'});

% Rinomina la colonna 'Task2' per chiarezza
results_t2_2nd.Properties.VariableNames = {'Case', 'CaseLabel_results_t2_2nd'};

% Filtrare solo le etichette 2 e 3 nelle predizioni
results_t2_2nd_filtered = results_t2_2nd(ismember(results_t2_2nd.CaseLabel_results_t2_2nd, [2, 3]), :);

% Unire le tabelle per confronto (solo Case presenti in entrambi i dataset)
merged_table_2nd = innerjoin(results_t2_2nd_filtered, test_set_labeled_t2_filtered, 'Keys', 'Case');

% Confrontare le previsioni con le etichette reali
predizioni_corrette_2nd = merged_table_2nd.CaseLabel_results_t2_2nd == merged_table_2nd.CaseLabel_test_set_labeled_t2;

% Calcolare l'accuratezza
accuratezza_2nd = sum(predizioni_corrette_2nd) / height(merged_table_2nd);

% Visualizzare l'accuratezza
disp(['Accuratezza del secondo task: ', num2str(accuratezza_2nd)]);

