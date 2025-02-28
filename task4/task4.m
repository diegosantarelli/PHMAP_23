% task2_2nd;

training_set_task4 = labeledData(labeledData.Task4 ~= 0, {'Case', 'Task4'});

test_set_task4 = test_set();

% Ottenere il numero di record nel test set
numRecords = height(test_set_task4);

% Creare un array di nomi "CaseXXX"
caseNames = strcat("Case", string(178:178+numRecords-1));

test_set_task4.Name = caseNames';

filtered_results_t2 = results_t2_2nd(results_t2_2nd.Task2 == 3, {'Case'});

filtered_results_t2.Properties.VariableNames{'Case'} = 'Name';

test_set_task4 = innerjoin(test_set_task4, filtered_results_t2, 'Keys', 'Name');

test_set_task4.Task4 = NaN(height(test_set_task4), 1);

[featureTable_test_task4, ~] = prova_t4(test_set_task4);

% %%
% % Creare una mappatura tra i Case originali e le finestre temporali
% numFeatureRows = height(featureTable_test_task4);
% numTestRows = height(test_set_task4);
% 
% % Se featureTable ha più righe di test_set_task3, ripetiamo i nomi dei Case
% if numFeatureRows > numTestRows
%     repeatedNames = repelem(test_set_task4.Name, numFeatureRows / numTestRows);
%     featureTable_test_task4.Name = repeatedNames;
% else
%     featureTable_test_task4.Name = test_set_task4.Name;
% end
% 
% load('task4/results/baggedTrees_t4.mat', 'finalModel_task4');
% 
% %%
% % Predire le etichette per tutte le finestre di featureTable_test_task3
% predicted_labels = finalModel_task4.predictFcn(featureTable_test_task4);
% 
% % Aggiungere le predizioni alla tabella delle feature
% featureTable_test_task4.PredictedLabel = predicted_labels;
% 
% % Verificare che la colonna 'Name' esista
% if ~ismember('Name', featureTable_test_task4.Properties.VariableNames)
%     error('La colonna "Name" non esiste in featureTable_test_task3!');
% end
% featureTable_test_task4.Name = string(featureTable_test_task4.Name);
% 
% % Aggregazione per Case con voto di maggioranza
% grouped_results = groupsummary(featureTable_test_task4, 'Name', 'mode', 'PredictedLabel');
% grouped_results.Properties.VariableNames{'Name'} = 'Case';
% grouped_results.Properties.VariableNames{'mode_PredictedLabel'} = 'Task4';
% 
% % Rimuovere eventuali colonne indesiderate da grouped_results
% colsToRemove = {'GroupCount', 'Task4_grouped_results'};
% grouped_results = removevars(grouped_results, intersect(colsToRemove, grouped_results.Properties.VariableNames));
% 
% % Caricare il file CSV esistente con i risultati di Task 1 e Task 2
% results_t4 = readtable('results.csv', 'VariableNamingRule', 'preserve');
% 
% % Se la colonna Task3 non esiste, la inizializziamo a 0
% if ~ismember('Task4', results_t4.Properties.VariableNames)
%     results_t4.Task4 = zeros(height(results_t4), 1);
% end
% 
% % Unire le predizioni reali con il file esistente (Left Join)
% results_t4 = outerjoin(results_t4, grouped_results, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);
% 
% % Se Task3_grouped_results esiste, copiarne i valori in Task3 e rimuoverla
% if ismember('Task4_grouped_results', results_t4.Properties.VariableNames)
%     results_t4.Task4 = results_t4.Task4_grouped_results;
%     results_t4 = removevars(results_t4, 'Task4_grouped_results'); % Rimuovere la colonna temporanea
% end
% 
% % Sostituire i NaN con 0 in Task3
% results_t4.Task4(isnan(results_t4.Task4)) = 0;
% 
% % Rimuovere la colonna GroupCount se presente
% if ismember('GroupCount', results_t4.Properties.VariableNames)
%     results_t4 = removevars(results_t4, 'GroupCount');
% end
% 
% % Mantieni solo le colonne desiderate nel file finale
% results_t4 = results_t4(:, {'Case', 'Task1', 'Task2', 'Task3', 'Task4'});
% 
% % Salvare il file aggiornato con Task 3 senza sovrascrivere altri dati
% writetable(results_t4, 'results.csv');
% 
% % Messaggio di conferma
% disp('File results.csv aggiornato con solo Task1, Task2 e Task3!');