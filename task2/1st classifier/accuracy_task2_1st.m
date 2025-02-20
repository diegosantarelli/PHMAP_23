% Caricamento del file CSV con nome colonne preservato
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Rinominare la colonna 'ID' in 'Name' e trasformare i valori in 'CaseXXX'
data.Name = strcat('Case', string(data.ID));

% Mantenere solo le colonne 'Name' e 'task2'
test_set_labeled_t2 = data(:, {'Name', 'task2'});

% Eliminare i record con etichetta 0
test_set_labeled_t2(test_set_labeled_t2.task2 == 0, :) = [];

% Sostituire i valori 2 e 3 con 4
test_set_labeled_t2.task2(ismember(test_set_labeled_t2.task2, [2, 3])) = 4;

% Uniformare i nomi delle colonne per confrontare
test_set_labeled_t2.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unire le tabelle in base alla colonna 'Case'
merged_table = innerjoin(results_t2_1st, test_set_labeled_t2, 'Keys', 'Case');

% Verifica i nomi effettivi delle colonne con CaseLabel
predizioni_corrette = merged_table{:,'CaseLabel_results_t2_1st'} == merged_table{:,'CaseLabel_test_set_labeled_t2'};

% Calcolare l'accuratezza
accuratezza = sum(predizioni_corrette) / height(merged_table);

% Visualizzare il risultato
disp(['Accuratezza del modello: ', num2str(accuratezza)]);
