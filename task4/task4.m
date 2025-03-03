training_set_task4 = labeledData(labeledData.Task4 ~= 0, {'Case', 'Task4'});

%%
% Numero di copie da generare (esclusa l'originale)
num_copies = 3;

% Creiamo il dataset aumentato
augmented_data = training_set_task4; % Iniziamo con il dataset originale

for i = 2:num_copies % Iniziamo da 2 perché il primo è il dataset originale
    noisy_data = training_set_task4; % Copia dell'originale

    % Itera su ogni riga per modificare i dati dentro le sottotabelle "Case"
    for j = 1:height(noisy_data)
        if istable(noisy_data.Case{j})  % Controlla se la cella contiene una tabella
            % Identifica le colonne numeriche ESCLUDENDO 'TIME'
            numeric_columns = setdiff(noisy_data.Case{j}.Properties.VariableNames, {'TIME'});

            % Aggiunta di rumore solo alle colonne numeriche (tranne TIME)
            for col = numeric_columns
                col_name = char(col); % Converte in stringa per accesso alla tabella
                noise_factor = 0.02 * std(noisy_data.Case{j}{:, col_name});
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

% Il dataset aumentato ora può essere usato per il training
training_set_task4 = augmented_data;

%%
test_set_task4 = test_set();

% Ottenere il numero di record nel test set
numRecords = height(test_set_task4);

% Creare un array di nomi "CaseXXX"
caseNames = strcat("Case", string(178:178+numRecords-1));

test_set_task4.Name = caseNames';

% Controlla il nome corretto della colonna Task2
colName_t4 = "";
if ismember('Task2', results_t2_2nd.Properties.VariableNames)
    colName_t4 = 'Task2';
elseif ismember('CaseLabel_results_t2_2nd', results_t2_2nd.Properties.VariableNames)
    colName_t4 = 'CaseLabel_results_t2_2nd';
else
    error('Errore: né Task2 né CaseLabel_results_t2_2nd trovati in results_t2_2nd!');
end

% Usa il nome corretto per filtrare i dati
filtered_results_t2 = results_t2_2nd(results_t2_2nd.(colName_t4) == 3, {'Case'});

filtered_results_t2.Properties.VariableNames{'Case'} = 'Name';

% Unire test_set_task3 con i Case filtrati, mantenendo solo le corrispondenze
test_set_task4 = innerjoin(test_set_task4, filtered_results_t2, 'Keys', 'Name');

test_set_task4.Task4 = NaN(height(test_set_task4), 1);

[featureTable_test_task4, ~] = prova_t4(test_set_task4);

% Creare una mappatura tra i Case originali e le finestre temporali
numFeatureRows = height(featureTable_test_task4);
numTestRows = height(test_set_task4);

% Se featureTable ha più righe di test_set_task3, ripetiamo i nomi dei Case
if numFeatureRows > numTestRows
    repeatedNames = repelem(test_set_task4.Name, numFeatureRows / numTestRows);
    featureTable_test_task4.Name = repeatedNames;
else
    featureTable_test_task4.Name = test_set_task4.Name;
end

load('task4/results/baggedTrees_t4.mat', 'prova_model_t4');

% Predire le etichette per tutte le finestre di featureTable_test_task3
predicted_labels = prova_model_t4.predictFcn(featureTable_test_task4);

% Aggiungere le predizioni alla tabella delle feature
featureTable_test_task4.PredictedLabel = predicted_labels;

% Verificare che la colonna 'Name' esista
if ~ismember('Name', featureTable_test_task4.Properties.VariableNames)
    error('La colonna "Name" non esiste in featureTable_test_task4!');
end
featureTable_test_task4.Name = string(featureTable_test_task4.Name);

% Aggregazione per Case con voto di maggioranza
grouped_results = groupsummary(featureTable_test_task4, 'Name', 'mode', 'PredictedLabel');
grouped_results.Properties.VariableNames{'Name'} = 'Case';
grouped_results.Properties.VariableNames{'mode_PredictedLabel'} = 'Task4';

% Rimuovere eventuali colonne indesiderate da grouped_results
colsToRemove = {'GroupCount', 'Task4_grouped_results'};
grouped_results = removevars(grouped_results, intersect(colsToRemove, grouped_results.Properties.VariableNames));

% Caricare il file CSV esistente con i risultati di Task 1 e Task 2
results_t4 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Se la colonna Task3 non esiste, la inizializziamo a 0
if ~ismember('Task4', results_t4.Properties.VariableNames)
    results_t4.Task4 = zeros(height(results_t4), 1);
end

% Unire le predizioni reali con il file esistente (Left Join)
results_t4 = outerjoin(results_t4, grouped_results, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);

% Se Task3_grouped_results esiste, copiarne i valori in Task3 e rimuoverla
if ismember('Task4_grouped_results', results_t4.Properties.VariableNames)
    results_t4.Task4 = results_t4.Task4_grouped_results;
    results_t4 = removevars(results_t4, 'Task4_grouped_results'); % Rimuovere la colonna temporanea
end

% Sostituire i NaN con 0 in Task3
results_t4.Task4(isnan(results_t4.Task4)) = 0;

% Rimuovere la colonna GroupCount se presente
if ismember('GroupCount', results_t4.Properties.VariableNames)
    results_t4 = removevars(results_t4, 'GroupCount');
end

% Mantieni solo le colonne desiderate nel file finale
results_t4 = results_t4(:, {'Case', 'Task1', 'Task2', 'Task3', 'Task4'});

% Salvare il file aggiornato con Task 3 senza sovrascrivere altri dati
writetable(results_t4, 'results.csv');
