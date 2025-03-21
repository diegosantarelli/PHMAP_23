% Caricamento del file CSV con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

test_set_labeled_t1 = data(:, {'ID', 'task1'});

% Ridenominazione delle colonne
test_set_labeled_t1.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table = innerjoin(final_predictions_t1, test_set_labeled_t1, 'Keys', 'Case');

% Confronto tra le predizioni e le etichette reali
correct_predictions = merged_table.Task1 == merged_table.CaseLabel;

% Calcolo dell'accuracy
accuracy = sum(correct_predictions) / height(merged_table);

disp(['Accuratezza del Task 1: ', num2str(accuracy * 100, '%.2f'), '%']);
