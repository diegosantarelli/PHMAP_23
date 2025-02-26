% Caricamento del file CSV con risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

data.Name = strcat('Case', string(data.ID)); % Converti l'ID in "CaseXXX"
test_set_labeled_t1 = data(:, {'Name', 'task1'});

test_set_labeled_t1.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle per confronto
merged_table = innerjoin(results_table, test_set_labeled_t1, 'Keys', 'Case');

% Calcolo accuratezza
correct_predictions = merged_table.Task1 == merged_table.CaseLabel;
accuracy = sum(correct_predictions) / height(merged_table);

disp(['Accuratezza del modello: ', num2str(accuracy * 100), '%']);
