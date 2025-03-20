% Caricamento del file CSV con le risposte corrette
data_t4 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t4 = data_t4(:, {'ID', 'task4'});

% Rinomina le colonne per uniformità con final_predictions_task4
test_set_labeled_t4.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table_t4 = innerjoin(final_predictions_task4, test_set_labeled_t4, 'Keys', 'Case');

% Estrai i valori di predizioni e etichette reali
predicted_labels = merged_table_t4.Task4;
true_labels = merged_table_t4.CaseLabel;

% Generazione della matrice di confusione
conf_matrix_t4 = confusionmat(true_labels, predicted_labels);

% Plotta la matrice di confusione
figure;
confusionchart(conf_matrix_t4);
title('Matrice di Confusione - Task 4');
xlabel('Predizioni');
ylabel('Etichette RealI');
grid on;
