% =================== CARICAMENTO DATI ===================
data = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% Rinominare 'ID' in 'Name' e trasformare i valori in 'CaseXXX'
data.Name = strcat('Case', string(data.ID));

% =================== PREPARAZIONE DEL TEST SET ===================
% Mantenere solo le colonne 'Name' e 'task2'
test_set_labeled_t2 = data(:, {'Name', 'task2'});

% Rimuovere i record con task2 == 0
test_set_labeled_t2 = test_set_labeled_t2(test_set_labeled_t2.task2 ~= 0, :);

% Sostituire i valori 2 e 3 con 4
test_set_labeled_t2.task2(ismember(test_set_labeled_t2.task2, [2, 3])) = 4;

% Uniformare i nomi delle colonne per confronto
test_set_labeled_t2.Properties.VariableNames = {'Case', 'Task2'};

% =================== UNIONE DEI RISULTATI ===================
merged_table = innerjoin(results_t2_1st, test_set_labeled_t2, 'Keys', 'Case');

% =================== CALCOLO ACCURATEZZA ===================
% Identificazione della colonna corretta per il confronto
col_predizioni = 'CaseLabel';
col_real = 'Task2';

% Calcolare l'accuratezza confrontando le etichette predette con quelle reali
num_predizioni_corrette = sum(merged_table{:, col_predizioni} == merged_table{:, col_real});

% Evitare divisioni per zero se la tabella è vuota
if height(merged_table) == 0
    disp('Errore: Nessun dato disponibile per il calcolo dell’accuratezza!');
    accuratezza = NaN;
else
    accuratezza = sum(num_predizioni_corrette) / height(merged_table);
end

% =================== RISULTATI ===================
disp(['Accuratezza della one-class classification: ', num2str(accuratezza * 100), '%']);
