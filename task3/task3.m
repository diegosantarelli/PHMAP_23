training_set_task3 = labeledData(labeledData.Task3 ~= 0, {'Case', 'Task3'});

test_set_task3 = test_set();

% Ottenere il numero di record nel test set
numRecords = height(test_set_task3);

% Creare un array di nomi "CaseXXX"
caseNames = strcat("Case", string(178:178+numRecords-1));

% Aggiungere la colonna "Name" alla tabella test_set_task3
test_set_task3.Name = caseNames';

% Controlla il nome corretto della colonna Task2
colName_t3 = "";
if ismember('Task2', results_t2_2nd.Properties.VariableNames)
    colName_t3 = 'Task2';
elseif ismember('CaseLabel_results_t2_2nd', results_t2_2nd.Properties.VariableNames)
    colName_t3 = 'CaseLabel_results_t2_2nd';
else
    error('Errore: né Task2 né CaseLabel_results_t2_2nd trovati in results_t2_2nd!');
end

% Usa il nome corretto per filtrare i dati
filtered_results_t2 = results_t2_2nd(results_t2_2nd.(colName_t3) == 2, {'Case'});

filtered_results_t2.Properties.VariableNames{'Case'} = 'Name';

% Unire test_set_task3 con i Case filtrati, mantenendo solo le corrispondenze
test_set_task3 = innerjoin(test_set_task3, filtered_results_t2, 'Keys', 'Name');

test_set_task3.Task3 = NaN(height(test_set_task3), 1);

[featureTable_test_task3, ~] = feature_gen_t3(test_set_task3);

% Creare una mappatura tra i Case originali e le finestre temporali
numFeatureRows = height(featureTable_test_task3);
numTestRows = height(test_set_task3);

% Se featureTable ha più righe di test_set_task3, ripetiamo i nomi dei Case
if numFeatureRows > numTestRows
    repeatedNames = repelem(test_set_task3.Name, numFeatureRows / numTestRows);
    featureTable_test_task3.Name = repeatedNames;
else
    featureTable_test_task3.Name = test_set_task3.Name;
end

load('task3/results/SubspaceKNN.mat', 'finalModel_task3');

%%
% Predire le etichette per tutte le finestre di featureTable_test_task3
predicted_labels = finalModel_task3.predictFcn(featureTable_test_task3);

% Aggiungere le predizioni alla tabella delle feature
featureTable_test_task3.PredictedLabel = predicted_labels;

% Verificare che la colonna 'Name' esista
if ~ismember('Name', featureTable_test_task3.Properties.VariableNames)
    error('La colonna "Name" non esiste in featureTable_test_task3!');
end
featureTable_test_task3.Name = string(featureTable_test_task3.Name);

% Aggregazione per Case con voto di maggioranza
grouped_results = groupsummary(featureTable_test_task3, 'Name', 'mode', 'PredictedLabel');
grouped_results.Properties.VariableNames{'Name'} = 'Case';
grouped_results.Properties.VariableNames{'mode_PredictedLabel'} = 'Task3';

% Rimuovere eventuali colonne indesiderate da grouped_results
colsToRemove = {'GroupCount', 'Task3_grouped_results'};
grouped_results = removevars(grouped_results, intersect(colsToRemove, grouped_results.Properties.VariableNames));

% Caricare il file CSV esistente con i risultati di Task 1 e Task 2
results_t3 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Se la colonna Task3 non esiste, la inizializziamo a 0
if ~ismember('Task3', results_t3.Properties.VariableNames)
    results_t3.Task3 = zeros(height(results_t3), 1);
end

% Unire le predizioni reali con il file esistente (Left Join)
results_t3 = outerjoin(results_t3, grouped_results, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);

% Se Task3_grouped_results esiste, copiarne i valori in Task3 e rimuoverla
if ismember('Task3_grouped_results', results_t3.Properties.VariableNames)
    results_t3.Task3 = results_t3.Task3_grouped_results;
    results_t3 = removevars(results_t3, 'Task3_grouped_results'); % Rimuovere la colonna temporanea
end

% Sostituire i NaN con 0 in Task3
results_t3.Task3(isnan(results_t3.Task3)) = 0;

% Rimuovere la colonna GroupCount se presente
if ismember('GroupCount', results_t3.Properties.VariableNames)
    results_t3 = removevars(results_t3, 'GroupCount');
end

% Mantieni solo le colonne desiderate nel file finale
varsToKeep = intersect(results_t3.Properties.VariableNames, {'Case', 'Task1', 'Task2', 'Task3'});
results_t3 = results_t3(:, varsToKeep);

% Salvare il file aggiornato con Task 3 senza sovrascrivere altri dati
writetable(results_t3, 'results.csv');
