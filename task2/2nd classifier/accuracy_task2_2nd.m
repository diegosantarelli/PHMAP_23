% Caricamento del file CSV con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t2 = data(:, {'ID', 'task2'});

% Rinomina le colonne per uniformità con results_task1
test_set_labeled_t2.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table_task2 = innerjoin(final_predictions_t2, test_set_labeled_t2, 'Keys', 'Case');

% Confronto tra le predizioni e le etichette reali
correct_predictions = merged_table_task2.Task2 == merged_table_task2.CaseLabel;

% Calcolo dell'accuracy
accuracy = sum(correct_predictions) / height(merged_table_task2);

disp(['Accuratezza del Task 2: ', num2str(accuracy * 100, '%.2f'), '%']);