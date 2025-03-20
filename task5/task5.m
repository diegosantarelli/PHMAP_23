training_set_task5 = labeledData(labeledData.Task5 ~= 100, {'Case', 'Task5'});

%%
% Numero di copie da generare (esclusa l'originale)
num_copies = 3;

% Creiamo il dataset aumentato
augmented_data = training_set_task5;

for i = 2:num_copies
    noisy_data = training_set_task5;

    % Itera su ogni riga per modificare i dati dentro le sottotabelle "Case"
    for j = 1:height(noisy_data)
        if istable(noisy_data.Case{j})  % Controlla se la cella contiene una tabella
            % Identifica le colonne numeriche ESCLUDENDO 'TIME'
            numeric_columns = setdiff(noisy_data.Case{j}.Properties.VariableNames, {'TIME'});

            % Aggiunta di rumore solo alle colonne numeriche (tranne TIME)
            for col = numeric_columns
                col_name = char(col);
                noise_factor = 0.02 * std(noisy_data.Case{j}{:, col_name}); % 2% dello std come rumore
                noisy_data.Case{j}.(col_name) = noisy_data.Case{j}.(col_name) + ...
                    noise_factor .* randn(size(noisy_data.Case{j}.(col_name)));
            end
        end
    end

    % Aggiungi il dataset modificato a quello aumentato
    augmented_data = [augmented_data; noisy_data];
end

% Shuffle finale per evitare pattern ripetitivi
augmented_data = augmented_data(randperm(height(augmented_data)), :);

% Il dataset aumentato ora può essere usato per la regressione
training_set_task5 = augmented_data;

%%

test_set_task5 = test_set();

% Ottenere il numero di record nel test set
numRecords = height(test_set_task5);

caseNumbers = string(178:178+numRecords-1)';

test_set_task5.Name = caseNumbers;

colName = "";
if ismember('Task4', results_t4.Properties.VariableNames)
    colName = 'Task4';
elseif ismember('CaseLabel_results_t4', results_t4.Properties.VariableNames)
    colName = 'CaseLabel_results_t4';
else
    error('Errore: né Task4 né CaseLabel_results_t4 trovati in results_t4!');
end

% Usa il nome corretto della colonna
filtered_results_t4 = results_t4(results_t4.(colName) ~= 0, {'Case'});
filtered_results_t4.Properties.VariableNames{'Case'} = 'Name';

test_set_task5 = innerjoin(test_set_task5, filtered_results_t4, 'Keys', 'Name');

test_set_task5.Task5 = NaN(height(test_set_task5), 1);

[featureTable_test_task5, ~] = feature_gen_t5(test_set_task5);

% Creare una mappatura tra i Case originali e le finestre temporali
numFeatureRows = height(featureTable_test_task5);
numTestRows = height(test_set_task5);

% Se featureTable ha più righe di test_set_task3, ripetiamo i nomi dei Case
if numFeatureRows > numTestRows
    repeatedNames = repelem(test_set_task5.Name, numFeatureRows / numTestRows);
    featureTable_test_task5.Name = repeatedNames;
else
    featureTable_test_task5.Name = test_set_task5.Name;
end

load('task5/results/baggedTrees_t5.mat', 'finalModel_t5');

% Predire le etichette per tutte le finestre di featureTable_test_task3
predicted_labels = finalModel_t5.predictFcn(featureTable_test_task5);

% Aggiungere le predizioni alla tabella delle feature
featureTable_test_task5.PredictedLabel = predicted_labels;

% Verificare che la colonna 'Name' esista
if ~ismember('Name', featureTable_test_task5.Properties.VariableNames)
    error('La colonna "Name" non esiste in featureTable_test_task5!');
end
featureTable_test_task5.Name = string(featureTable_test_task5.Name);

% Aggregazione per Case con voto di maggioranza
grouped_results = groupsummary(featureTable_test_task5, 'Name', 'mode', 'PredictedLabel');
grouped_results.Properties.VariableNames{'Name'} = 'Case';
grouped_results.Properties.VariableNames{'mode_PredictedLabel'} = 'Task5';

% Rimuovere eventuali colonne indesiderate da grouped_results
colsToRemove = {'GroupCount', 'Task5_grouped_results'};
grouped_results = removevars(grouped_results, intersect(colsToRemove, grouped_results.Properties.VariableNames));

% Caricare il file CSV esistente con i risultati di Task 1 e Task 2
results_t5 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Se la colonna Task3 non esiste, la inizializziamo a 0
if ~ismember('Task5', results_t5.Properties.VariableNames)
    results_t5.Task5 = zeros(height(results_t5), 1);
end

% Unire le predizioni reali con il file esistente (Left Join)
results_t5 = outerjoin(results_t5, grouped_results, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);

% Se Task3_grouped_results esiste, copiarne i valori in Task3 e rimuoverla
if ismember('Task5_grouped_results', results_t5.Properties.VariableNames)
    results_t5.Task5 = results_t5.Task5_grouped_results;
    results_t5 = removevars(results_t5, 'Task5_grouped_results'); % Rimuovere la colonna temporanea
end

% Sostituire i NaN con 0 in Task3
results_t5.Task5(isnan(results_t5.Task5)) = 100;

% Rimuovere la colonna GroupCount se presente
if ismember('GroupCount', results_t5.Properties.VariableNames)
    results_t5 = removevars(results_t5, 'GroupCount');
end

% Mantieni solo le colonne desiderate nel file finale
results_t5 = results_t5(:, {'Case', 'Task1', 'Task2', 'Task3', 'Task4', 'Task5'});

% Salvare il file aggiornato con Task 3 senza sovrascrivere altri dati
writetable(results_t5, 'results.csv');
