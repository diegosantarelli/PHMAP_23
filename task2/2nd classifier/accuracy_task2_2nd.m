% Caricamento del file CSV con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t2 = data(:, {'ID', 'task2'});

% Rinomina le colonne per uniformità con results_task1
test_set_labeled_t2.Properties.VariableNames = {'Case', 'CaseLabel'};

% Caricamento delle predizioni del Task 2
results_task2 = readtable('results.csv');

% Conversione delle colonne 'Case' in stringhe per garantire la corretta unione
results_task2.Case = string(results_task2.Case);
test_set_labeled_t2.Case = string(test_set_labeled_t2.Case);

% Unione delle tabelle basata sul numero del Case
merged_table_t2 = innerjoin(results_task2, test_set_labeled_t2, 'Keys', 'Case');

% Confronto tra le predizioni e le etichette reali
correct_predictions_t2 = merged_table_t2.Task2 == merged_table_t2.CaseLabel;

% Calcolo dell'accuratezza
accuracy_task2 = sum(correct_predictions_t2) / height(merged_table_t2);

% Mostra il risultato
disp(['Accuratezza del secondo task: ', num2str(accuracy_task2 * 100, '%.2f'), '%']);
