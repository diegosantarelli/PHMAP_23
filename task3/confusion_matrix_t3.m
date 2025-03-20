%% CALCOLO ACCURATEZZA TASK 3 E MATRICE DI CONFUSIONE

% Caricamento del file CSV con le risposte corrette
data_t3 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t3 = data_t3(:, {'ID', 'task3'});

% Rinomina le colonne per uniformità con final_predictions_task3
test_set_labeled_t3.Properties.VariableNames = {'Case', 'CaseLabel'};

% Unione delle tabelle basata sul numero del Case
merged_table_t3 = innerjoin(final_predictions_task3, test_set_labeled_t3, 'Keys', 'Case');

% Estrai i valori di predizioni e etichette reali
predicted_labels_t3 = merged_table_t3.Task3;
true_labels_t3 = merged_table_t3.CaseLabel;

% Generazione della matrice di confusione
conf_matrix_t3 = confusionmat(true_labels_t3, predicted_labels_t3);

% Plotta la matrice di confusione
figure;
confusionchart(conf_matrix_t3);
title('Matrice di Confusione - Task 3');
xlabel('Predizioni');
ylabel('Etichette Reali');
grid on;
