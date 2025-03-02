%task2_2nd;

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

% Stampa dimensioni per verifica
disp(['Dimensione originale del training set: ', num2str(height(labeledData(labeledData.Task4 ~= 0, :)))]);
disp(['Dimensione dopo Data Augmentation: ', num2str(height(augmented_data))]);

% Il dataset aumentato ora può essere usato per il training
training_set_task4 = augmented_data;

%%
test_set_task4 = test_set();

% Ottenere il numero di record nel test set
numRecords = height(test_set_task4);

% Creare un array di nomi "CaseXXX"
caseNames = strcat("Case", string(178:178+numRecords-1));

test_set_task4.Name = caseNames';

filtered_results_t2 = results_t2_2nd(results_t2_2nd.Task2 == 3, {'Case'});

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

% Messaggio di conferma
disp('File results.csv aggiornato con solo Task1, Task2, Task3 e Task4!');








% 
% %% **Caricamento dei dati**
% % results = readtable('results.csv', 'VariableNamingRule', 'preserve'); % Carica tutte le colonne esistenti
% 
% % Seleziona solo i Case con Task2 == 3
% filtered_results_t2 = results_t2_2nd(results_t2_2nd.Task2 == 3, {'Case'});
% filtered_results_t2.Properties.VariableNames{'Case'} = 'Name';
% 
% % Filtra il test set usando solo i case validi dal Task2
% test_set_task4 = test_set();
% numRecords = height(test_set_task4);
% 
% % Creare un array di nomi "CaseXXX"
% caseNames = strcat("Case", string(178:178+numRecords-1));
% test_set_task4.Name = caseNames';
% 
% % Effettuare l'inner join per mantenere solo i case validi
% test_set_task4 = innerjoin(test_set_task4, filtered_results_t2, 'Keys', 'Name');
% 
% % Inizializza Task4 con NaN per le previsioni
% test_set_task4.Task4 = NaN(height(test_set_task4), 1);
% 
% % Genera le feature per il test set del Task4
% [featureTable_test_task4, ~] = prova_t4(test_set_task4);
% 
% %% **Assegna i nomi dei Case alle feature per il voting**
% numFeatureRows = height(featureTable_test_task4);
% numTestRows = height(test_set_task4);
% 
% if numFeatureRows > numTestRows
%     repeatedNames = repelem(test_set_task4.Name, numFeatureRows / numTestRows);
%     featureTable_test_task4.Name = repeatedNames;
% else
%     featureTable_test_task4.Name = test_set_task4.Name;
% end
% 
% %% **Effettua le previsioni**
% load('task4/results/baggedTrees_t4.mat', 'prova_model_t4');
% 
% % **Verifica che ci siano dati**
% if isempty(featureTable_test_task4)
%     warning('featureTable_test_task4 è vuoto, impossibile fare previsioni.');
%     return;
% end
% 
% % **Previsione per ogni membro**
% predicted_labels = prova_model_t4.predictFcn(featureTable_test_task4);
% 
% % **Aggiungere le predizioni alla tabella delle feature**
% featureTable_test_task4.PredictedLabel = predicted_labels;
% 
% % **Aggregazione per Case con voto di maggioranza (Metodo Originale con 82% Accuracy)**
% grouped_results = groupsummary(featureTable_test_task4, 'Name', 'mode', 'PredictedLabel');
% grouped_results.Properties.VariableNames{'Name'} = 'Case';
% grouped_results.Properties.VariableNames{'mode_PredictedLabel'} = 'Task4';
% 
% %% **Aggiornamento del file results.csv senza sovrascrivere altre colonne**
% % Se `Task4` non esiste, lo inizializziamo a 0 per tutti i Case
% if ~ismember('Task4', results.Properties.VariableNames)
%     results.Task4 = zeros(height(results), 1);
% end
% 
% % **Mappa i risultati nel file results.csv senza eliminare `Task3`**
% for i = 1:height(grouped_results)
%     case_idx = strcmp(results.Case, grouped_results.Case(i));
%     results.Task4(case_idx) = grouped_results.Task4(i);
% end
% 
% % **Sostituiamo eventuali NaN con 0**
% results.Task4(isnan(results.Task4)) = 0;
% 
% % **Manteniamo solo le colonne originali**
% colonne_originali = {'Case', 'Task1', 'Task2', 'Task3', 'Task4'};
% colonne_presenti = intersect(colonne_originali, results.Properties.VariableNames, 'stable');
% results = results(:, colonne_presenti); % Riordiniamo e manteniamo solo le colonne corrette
% 
% % **Salva il file aggiornato senza rimuovere Task3**
% writetable(results, 'results.csv', 'WriteMode', 'overwrite'); 
% 
% disp('File results.csv aggiornato correttamente senza sovrascrivere Task3!');
