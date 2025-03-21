% Caricamento del file CSV con le risposte corrette
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Rinominare 'ID' in 'Name' e trasformare i valori in numeri
data.Name = erase(string(data.ID), "Case");

% Mantenere solo le colonne 'Name' e 'task2'
test_set_labeled_t2 = data(:, {'Name', 'task2'});

% Rimuovere i record con task2 == 0
test_set_labeled_t2 = test_set_labeled_t2(test_set_labeled_t2.task2 ~= 0, :);

% Sostituire i valori 2 e 3 con 4
test_set_labeled_t2.task2(ismember(test_set_labeled_t2.task2, [2, 3])) = 4;

% Uniformare i nomi delle colonne per confronto
test_set_labeled_t2.Properties.VariableNames = {'Case', 'Task2'};

% Assicurarci che 'Case' sia string per evitare problemi di join
test_set_labeled_t2.Case = string(test_set_labeled_t2.Case);
results_t2_1st.Case = string(results_t2_1st.Case);

% Unione con controllo dei Case
merged_table = innerjoin(results_t2_1st, test_set_labeled_t2, 'Keys', 'Case');

% Controllo se la tabella è vuota
if isempty(merged_table)
    error('Errore critico: Nessun match tra predizioni e etichette reali! Verifica i Case.');
end

% Estrai le etichette predette e reali
true_labels = merged_table.Task2;
predicted_labels = merged_table.CaseLabel;

% Plot della matrice di confusione
figure;
confusionchart(true_labels, predicted_labels);
title('Matrice di Confusione - Task 2');
xlabel('Predetto');
ylabel('Reale');