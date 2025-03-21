% Caricamento del file CSV con le risposte corrette
data_t3 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t3 = data_t3(:, {'ID', 'task3'});

% Rinomina le colonne per uniformità con final_predictions_task3
test_set_labeled_t3.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table_t3 = innerjoin(final_predictions_task3, test_set_labeled_t3, 'Keys', 'Case');

% Confronto tra le predizioni e le etichette reali
correct_predictions_t3 = merged_table_t3.Task3 == merged_table_t3.CaseLabel;

% Calcolo dell'accuracy
accuracy_t3 = sum(correct_predictions_t3) / height(merged_table_t3);

disp(['Accuratezza del Task 3: ', num2str(accuracy_t3 * 100, '%.2f'), '%']);
