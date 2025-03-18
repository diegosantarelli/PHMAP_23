% Caricamento del file CSV con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t1 = data(:, {'ID', 'task1'});

% Rinomina le colonne per uniformità con final_predictions
test_set_labeled_t1.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table = innerjoin(final_predictions_t1, test_set_labeled_t1, 'Keys', 'Case');

% Confronto tra le predizioni e le etichette reali
correct_predictions = merged_table.Task1 == merged_table.CaseLabel;

% Calcolo dell'accuracy
accuracy = sum(correct_predictions) / height(merged_table);

% Mostra il risultato
disp(['Accuratezza del primo task: ', num2str(accuracy * 100, '%.2f'), '%']);
