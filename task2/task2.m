labeledData_task2 = labeledData(:, {'Case', 'Task2'});

%% Filtraggio risultati task 1

% Carica il CSV
results = readtable('results.csv');

% Filtra solo i Case con Task1 == 1
results_fault = results(results.Task1 == 1, :);

