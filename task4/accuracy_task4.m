%% **CALCOLO ACCURATEZZA TASK 4**

% Caricamento del file CSV con le risposte corrette
data_t4 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t4 = data_t4(:, {'ID', 'task4'});

% Rinomina le colonne per uniformità con final_predictions_task4
test_set_labeled_t4.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table_t4 = innerjoin(final_predictions_task4, test_set_labeled_t4, 'Keys', 'Case');

% Confronto tra le predizioni e le etichette reali
correct_predictions_t4 = merged_table_t4.Task4 == merged_table_t4.CaseLabel;

% Calcolo dell'accuracy
accuracy_t4 = sum(correct_predictions_t4) / height(merged_table_t4);

% Mostra il risultato
disp(['Accuratezza del Task 4: ', num2str(accuracy_t4 * 100, '%.2f'), '%']);
