% Caricamento del dataset con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

test_set_labeled_t1 = data(:, {'ID', 'task1'});

% Ridenominazione delle colonne
test_set_labeled_t1.Properties.VariableNames = {'Case', 'CaseLabel'};

% Assicuriamoci che entrambi abbiano il tipo string per il join
test_set_labeled_t1.Case = string(test_set_labeled_t1.Case);
final_predictions_t1.Case = string(final_predictions_t1.Case);

% Unione delle tabelle basata sul numero del Case
merged_table = innerjoin(final_predictions_t1, test_set_labeled_t1, 'Keys', 'Case');

% Creazione della matrice di confusione
confMat = confusionmat(merged_table.CaseLabel, merged_table.Task1);

% Plot della matrice di confusione
figure;
confusionchart(confMat);
title('Matrice di Confusione - Task 1');
xlabel('Predetto');
ylabel('Reale');