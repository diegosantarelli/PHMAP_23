task2_2nd;

training_set_task4 = labeledData(labeledData.Task4 ~= 0, {'Case', 'Task4'});

test_set_task4 = test_set();

% Ottenere il numero di record nel test set
numRecords = height(test_set_task4);

% Creare un array di nomi "CaseXXX"
caseNames = strcat("Case", string(178:178+numRecords-1));

test_set_task4.Name = caseNames';

filtered_results_t2 = results_t2_2nd(results_t2_2nd.Task2 == 2, {'Case'});

filtered_results_t2.Properties.VariableNames{'Case'} = 'Name';

test_set_task4 = innerjoin(test_set_task4, filtered_results_t2, 'Keys', 'Name');

test_set_task4.Task4 = NaN(height(test_set_task4), 1);

%[featureTable_test_task4, ~] = feature_gen_t4(test_set_task4);