% import_data;

training_set_task3 = labeledData(labeledData.Task3 ~= 0,{'Case','Task3'});

test_set_task3 = test_set();

% Ottenere il numero di record nel test set
numRecords = height(test_set_task3);

% Creare un array di nomi "CaseXXX"
caseNames = strcat("Case", string(178:178+numRecords-1));

% Aggiungere la colonna "Name" alla tabella test_set_task3
test_set_task3.Name = caseNames';

% Rinominare la colonna "Case" in "Name" in results_t2_2nd per evitare conflitti
% results_t2_2nd.Properties.VariableNames{'Case'} = 'Name';

% Filtrare results_t2_2nd per mantenere solo i Case con etichetta pari a 2
filtered_results_t2 = results_t2_2nd(results_t2_2nd.CaseLabel_results_t2_2nd == 2, {'Name'});

% Unire test_set_task3 con i Case filtrati, mantenendo solo le corrispondenze
test_set_task3 = innerjoin(test_set_task3, filtered_results_t2, 'Keys', 'Name');

test_set_task3.Task3 = NaN(height(test_set_task3), 1);

[featureTable_test_task3, ~] = feature_gen_t3(test_set_task3);

load('task3/results/SubspaceKNN.mat', 'finalModel_task3');

%%
% Predire le etichette per tutte le finestre di featureTable_test_task3
predicted_labels = finalModel_task3.predict(featureTable_test_task3);

% Aggiungere le predizioni alla tabella delle feature
featureTable_test_task3.PredictedLabel = predicted_labels;

% Aggregare le predizioni per ogni Case usando la moda (voting)
grouped_results = groupsummary(featureTable_test_task3, 'Name', 'mode', 'PredictedLabel');

% Rinominare la colonna della moda per chiarezza
grouped_results.Properties.VariableNames{'mode_PredictedLabel'} = 'Task3';

% Creiamo una tabella completa con tutti i Case originali
all_cases = caseNames'; % Contiene tutti i CaseXXX creati prima

% Inizializziamo un vettore Task3 con tutti 0
task3_labels = zeros(length(all_cases), 1);

% Creiamo una tabella completa con Task3 = 0 per tutti
results_table = table(all_cases, task3_labels, 'VariableNames', {'Case', 'Task3'});

% Unire le predizioni reali con la tabella completa (Left Join)
results_table = outerjoin(results_table, grouped_results, 'LeftKeys', 'Case', 'RightKeys', 'Name', 'MergeKeys', true);

% Sostituire i NaN con 0 nei Task3
results_table.Task3(isnan(results_table.Task3)) = 0;

% Rinominare correttamente la colonna Case
results_table.Properties.VariableNames{'Case'} = 'Case';

% Salvare il file in formato CSV
writetable(results_table, 'results.csv');

% Messaggio di conferma
disp('File results.csv salvato con successo!');



