% =================== CARICAMENTO DATI ===================
% Carica il dataset con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Se 'ID' è già numerico, lo usiamo direttamente
test_set_labeled_t1 = data(:, {'ID', 'task1'});

% Rinomina le colonne per uniformità con final_predictions_t1
test_set_labeled_t1.Properties.VariableNames = {'Case', 'CaseLabel'};

% =================== UNIONE DEI RISULTATI ===================
% Assicuriamoci che entrambi abbiano il tipo string per il join
test_set_labeled_t1.Case = string(test_set_labeled_t1.Case);
final_predictions_t1.Case = string(final_predictions_t1.Case);

% Unione delle tabelle basata sul numero del Case
merged_table = innerjoin(final_predictions_t1, test_set_labeled_t1, 'Keys', 'Case');

% =================== MATRICE DI CONFUSIONE ===================
% Creazione della matrice di confusione
confMat = confusionmat(merged_table.CaseLabel, merged_table.Task1);

% Plot della matrice di confusione
figure;
confusionchart(confMat);
title('Matrice di Confusione - Task 1');
xlabel('Predetto');
ylabel('Reale');