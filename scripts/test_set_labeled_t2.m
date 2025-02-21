function test_set_labeled_t2 = test_set_labeled_t2()   
    % Caricamento del file CSV
    data = readtable('dataset/test/answer.csv');

    % Rinominare la colonna 'ID' in 'Name' e trasformare i valori in 'CaseXXX'
    data.Name = strcat('Case', string(data.ID));

    % Mantenere solo le colonne 'Name' e 'task2'
    test_set_labeled_t2 = data(:, {'Name', 'task2'});

    % Eliminare i record con etichetta 0
    test_set_labeled_t2(test_set_labeled_t2.task2 == 0, :) = [];

    % Sostituire i valori 2 e 3 con 4
    test_set_labeled_t2.task2(ismember(test_set_labeled_t2.task2, [2, 3])) = 4;

    % Restituisco la tabella come output
    test_set_labeled_t2 = test_set_labeled_t2;
end
