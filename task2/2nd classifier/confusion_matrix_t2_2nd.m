% Caricamento del file CSV con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t2 = data(:, {'ID', 'task2'});

% Rinomina le colonne per uniformità con final_predictions_t2
test_set_labeled_t2.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table_task2 = innerjoin(final_predictions_t2, test_set_labeled_t2, 'Keys', 'Case');

% Estrai i valori di predizioni e etichette reali
predicted_labels_t2 = merged_table_task2.Task2;
true_labels_t2 = merged_table_task2.CaseLabel;

% Generazione della matrice di confusione
conf_matrix_t2 = confusionmat(true_labels_t2, predicted_labels_t2);

% Plotta la matrice di confusione
figure;
confusionchart(conf_matrix_t2);
title('Matrice di Confusione - Task 2');
xlabel('Predizioni');
ylabel('Etichette Reali');
grid on;
