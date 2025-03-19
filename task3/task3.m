%% TASK 3 - Generazione delle Feature

% Filtra i casi con Task3 diverso da 0
training_set_task3 = labeledData(labeledData.Task3 ~= 0, {'Name', 'Case', 'Task3'});

% Imposta la durata della finestra in secondi
window_size = 0.400;

% Inizializza una cell array per raccogliere i dati
feature_rows_task3 = {};

% Itera su ogni caso nel training set
for i = 1:height(training_set_task3)
    % Estrai la sottotabella del caso attuale
    case_data = training_set_task3.Case{i};  
    
    % Usa l'indice come identificativo del Case
    case_id = training_set_task3.Name(i);

    % Recupera l'etichetta Task3 del caso
    case_label = training_set_task3.Task3(i);

    % Estrai il tempo
    time = case_data.TIME; 
    
    % Ottieni i nomi delle colonne dei segnali (tutti eccetto TIME)
    signal_columns = case_data.Properties.VariableNames(2:end);
    
    % Calcolo corretto della durata totale
    total_duration = max(time) - min(time);
    
    % Calcola il numero di finestre
    num_windows = max(1, floor(total_duration / window_size));

    % Itera su ogni finestra
    for w = 1:num_windows
        % Calcola i limiti della finestra
        start_time = min(time) + (w-1) * window_size;
        end_time = start_time + window_size;
        
        % Seleziona i dati nella finestra
        idx = (time >= start_time) & (time < end_time);

        % Se la finestra è vuota o contiene meno di 2 elementi, la salta
        if sum(idx) < 2
            continue;
        end
        
        % Inizializza un vettore per la riga della tabella
        row_features = {case_id, w};
        
        % Itera su ogni colonna di segnale (P1, P2, ..., Pn)
        for col = 1:length(signal_columns)
            signal_name = signal_columns{col}; % Nome del segnale
            window_signal = case_data.(signal_name)(idx); % Estrai i dati della finestra
            
            % --- FEATURE TEMPORALI ---
            mean_val = mean(window_signal, 'omitnan');
            median_val = median(window_signal, 'omitnan');
            p25_val = prctile(window_signal, 25);
            p75_val = prctile(window_signal, 75);
            var_val = var(window_signal, 'omitnan');
            integral_val = trapz(time(idx), window_signal); % Integrale numerico
            min_val = min(window_signal, [], 'omitnan');
            max_val = max(window_signal, [], 'omitnan');
            
            % --- FEATURE FREQUENZIALI ---
            % Frequenza di campionamento stimata
            Fs = 1 / mean(diff(time(idx))); 
            
            % Evita errori in caso di Fs non valido
            if isinf(Fs) || isnan(Fs) || Fs <= 0
                Fs = 1; % Assegna un valore di default
            end

            % Calcola lo spettro di potenza con pwelch
            [pxx, f] = pwelch(window_signal, [], [], [], Fs); 
            
            % Valore di picco e frequenza di picco
            [peak_value, peak_idx] = max(pxx);
            peak_freq = f(peak_idx);
            
            % Somma dello spettro di potenza e deviazione standard
            sum_power_spectrum = sum(pxx);
            std_power_spectrum = std(pxx);
            
            % RMS nel dominio della frequenza
            rms_freq = sqrt(mean(pxx));

            % Aggiungi le feature alla riga
            row_features = [row_features, mean_val, median_val, p25_val, p75_val, var_val, integral_val, ...
                min_val, max_val, peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, rms_freq];
        end
        
        % Aggiungi l'etichetta
        row_features = [row_features, case_label];
        
        % Salva la riga
        feature_rows_task3 = [feature_rows_task3; row_features];
    end
end

% Costruisci la tabella con nomi di colonna adeguati
column_names = {'Case', 'Window_ID'};

% Aggiungi i nomi delle feature per ogni segnale
for col = 1:length(signal_columns)
    signal_name = signal_columns{col};
    column_names = [column_names, ...
        strcat(signal_name, '_Mean'), strcat(signal_name, '_Median'), ...
        strcat(signal_name, '_P25'), strcat(signal_name, '_P75'), ...
        strcat(signal_name, '_Variance'), strcat(signal_name, '_Integral'), ...
        strcat(signal_name, '_Min'), strcat(signal_name, '_Max'), ...
        strcat(signal_name, '_PeakValue'), strcat(signal_name, '_PeakFreq'), ...
        strcat(signal_name, '_SumPowerSpectrum'), strcat(signal_name, '_StdPowerSpectrum'), ...
        strcat(signal_name, '_RMS_Frequency')];
end

% Aggiungi l'etichetta finale
column_names = [column_names, 'Task3'];

% Converti in tabella
featureTable_task3 = cell2table(feature_rows_task3, 'VariableNames', column_names);

% Salva la tabella nel workspace
assignin('base', 'featureTable_task3', featureTable_task3);

% Visualizza la tabella delle feature
%disp(featureTable_task3);

%% FEATURE IMPORTANCE - ANOVA (Prime 15 Feature)

% Carica il dataset con le feature
features = featureTable_task3;
features_numeric = features(:, 3:end-1); % Esclude 'Case', 'Window_ID', 'Task3'
labels = features.Task3; % Etichetta di classificazione

% Numero di feature
num_features = width(features_numeric);

% Inizializza il vettore dei p-values
p_values = zeros(1, num_features);

% Calcola il valore F di ANOVA per ogni feature
for i = 1:num_features
    p_values(i) = anova1(table2array(features_numeric(:, i)), labels, 'off');
end

% Converti p-values in F-values (F = 1/p_values)
F_values = 1 ./ p_values;
F_values(isinf(F_values) | isnan(F_values)) = max(F_values(~isinf(F_values) & ~isnan(F_values))) * 1.1; % Evita infiniti e NaN

% Ordina le feature in base ai valori F (le più importanti per prime)
[sorted_F, sorted_idx] = sort(F_values, 'descend');
sorted_features = features_numeric.Properties.VariableNames(sorted_idx);

% % Numero di feature da visualizzare
% num_features_to_plot = min(15, num_features);
% 
% % Plotta il grafico della feature importance (Prime 15 feature)
% figure;
% bar(sorted_F(1:num_features_to_plot));
% title('Feature Importance - ANOVA (Top 15 Features)');
% xlabel('Feature Name');
% ylabel('F-Value');
% xticks(1:num_features_to_plot);
% xticklabels(sorted_features(1:num_features_to_plot));
% xtickangle(90); % Ruota le etichette delle feature
% grid on;

% Seleziona solo le prime 9 feature più importanti
num_features_to_keep = 9;
selected_feature_names = sorted_features(1:num_features_to_keep);

% Crea un nuovo dataset con solo le top 9 feature
selected_features_task3 = features(:, ["Case", "Window_ID", selected_feature_names, "Task3"]); 

% Salva il dataset con le feature selezionate
assignin('base', 'selected_features_task3', selected_features_task3);

% Visualizza la tabella con le feature selezionate
disp('Feature selezionate per Task 3:');
disp(selected_feature_names);



%% TASK 3 - Estrazione delle Feature per il Test Set

% Carica il test set
test_set_task3 = test_set();

% Imposta la durata della finestra in secondi
window_size = 0.400;

% Inizializza una cell array per raccogliere i dati
feature_rows_test_task3 = {};

% Itera su ogni caso nel test set
for i = 1:height(test_set_task3)
    % Estrai la sottotabella del caso attuale
    case_data = test_set_task3.Case{i};  
    
    % Mantiene il valore originale del Case
    case_id = test_set_task3.Case{i};

    % Estrai il tempo
    time = case_data.TIME; 
    
    % Ottieni i nomi delle colonne dei segnali (tutti eccetto TIME)
    signal_columns = case_data.Properties.VariableNames(2:end);
    
    % Calcolo corretto della durata totale
    total_duration = max(time) - min(time);
    
    % Calcola il numero di finestre
    num_windows = max(1, floor(total_duration / window_size));

    % Itera su ogni finestra
    for w = 1:num_windows
        % Calcola i limiti della finestra
        start_time = min(time) + (w-1) * window_size;
        end_time = start_time + window_size;
        
        % Seleziona i dati nella finestra
        idx = (time >= start_time) & (time < end_time);

        % Se la finestra è vuota o contiene meno di 2 elementi, la salta
        if sum(idx) < 2
            continue;
        end
        
        % Inizializza un vettore per la riga della tabella
        row_features = {case_id, w};
        
        % Itera su ogni colonna di segnale (P1, P2, ..., Pn)
        for col = 1:length(signal_columns)
            signal_name = signal_columns{col}; % Nome del segnale
            window_signal = case_data.(signal_name)(idx); % Estrai i dati della finestra
            
            % --- FEATURE TEMPORALI ---
            mean_val = mean(window_signal, 'omitnan');
            median_val = median(window_signal, 'omitnan');
            p25_val = prctile(window_signal, 25);
            p75_val = prctile(window_signal, 75);
            var_val = var(window_signal, 'omitnan');
            integral_val = trapz(time(idx), window_signal); % Integrale numerico
            min_val = min(window_signal, [], 'omitnan');
            max_val = max(window_signal, [], 'omitnan');
            
            % --- FEATURE FREQUENZIALI ---
            % Frequenza di campionamento stimata
            Fs = 1 / mean(diff(time(idx))); 
            
            % Evita errori in caso di Fs non valido
            if isinf(Fs) || isnan(Fs) || Fs <= 0
                Fs = 1; % Assegna un valore di default
            end

            % Calcola lo spettro di potenza con pwelch
            [pxx, f] = pwelch(window_signal, [], [], [], Fs); 
            
            % Valore di picco e frequenza di picco
            [peak_value, peak_idx] = max(pxx);
            peak_freq = f(peak_idx);
            
            % Somma dello spettro di potenza e deviazione standard
            sum_power_spectrum = sum(pxx);
            std_power_spectrum = std(pxx);
            
            % RMS nel dominio della frequenza
            rms_freq = sqrt(mean(pxx));

            % Aggiungi le feature alla riga
            row_features = [row_features, mean_val, median_val, p25_val, p75_val, var_val, integral_val, ...
                min_val, max_val, peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, rms_freq];
        end
        
        % Salva la riga
        feature_rows_test_task3 = [feature_rows_test_task3; row_features];
    end
end

% Costruisci la tabella con nomi di colonna adeguati
column_names = {'Case', 'Window_ID'};

% Aggiungi i nomi delle feature per ogni segnale
for col = 1:length(signal_columns)
    signal_name = signal_columns{col};
    column_names = [column_names, ...
        strcat(signal_name, '_Mean'), strcat(signal_name, '_Median'), ...
        strcat(signal_name, '_P25'), strcat(signal_name, '_P75'), ...
        strcat(signal_name, '_Variance'), strcat(signal_name, '_Integral'), ...
        strcat(signal_name, '_Min'), strcat(signal_name, '_Max'), ...
        strcat(signal_name, '_PeakValue'), strcat(signal_name, '_PeakFreq'), ...
        strcat(signal_name, '_SumPowerSpectrum'), strcat(signal_name, '_StdPowerSpectrum'), ...
        strcat(signal_name, '_RMS_Frequency')];
end

% Converti in tabella
featureTable_test_task3 = cell2table(feature_rows_test_task3, 'VariableNames', column_names);

% --- SELEZIONE DELLE TOP 9 FEATURE ---

% Seleziona solo le feature che erano nelle prime 9 nel training set
selected_features_test_task3 = featureTable_test_task3(:, ["Case", "Window_ID", selected_feature_names]);

% Salva e aggiorna il workspace
assignin('base', 'selected_features_test_task3', selected_features_test_task3);

% Verifica la struttura della tabella
disp('Feature selezionate per il Test Set del Task 3:');
disp(selected_feature_names);

%% CONTROLLO DEL MODELLO QUADRATIC SVM

% Carica il modello addestrato per Task 3
load('task3/results/quadratic_svm.mat', 'quadratic_svm');

% Verifica i campi del modello
disp('Campi del modello quadratic_svm:');
disp(fieldnames(quadratic_svm));

% Se esiste un campo con i nomi delle feature, lo usiamo
if isfield(quadratic_svm, 'PredictorNames')
    predictorNames = quadratic_svm.PredictorNames;  % Standard MATLAB models
elseif isfield(quadratic_svm, 'RequiredVariables')
    predictorNames = quadratic_svm.RequiredVariables;  % Esporta modelli creati con l'App
else
    error('Impossibile trovare i nomi delle feature nel modello.');
end

% Debug: Visualizza i nomi delle feature richiesti dal modello
disp('Feature richieste dal modello:');
disp(predictorNames);

% Debug: Visualizza i nomi delle colonne effettivi della tabella
disp('Feature presenti in selected_features_test_task3:');
disp(selected_features_test_task3.Properties.VariableNames);

%% PREVISIONE TASK 3 - MAJORITY VOTING

% Rimuove 'Case' e 'Window_ID' se presenti
if ismember('Case', selected_features_test_task3.Properties.VariableNames)
    selected_features_test_task3 = removevars(selected_features_test_task3, 'Case');
end
if ismember('Window_ID', selected_features_test_task3.Properties.VariableNames)
    selected_features_test_task3 = removevars(selected_features_test_task3, 'Window_ID');
end

% Filtra solo le feature presenti nel test set e richieste dal modello
predictorNames = predictorNames(ismember(predictorNames, selected_features_test_task3.Properties.VariableNames));

% Debug: Controlla le feature dopo il filtraggio
disp('Feature effettivamente usate per la predizione:');
disp(predictorNames);

% Se la tabella non contiene le feature richieste, stampa errore
if isempty(predictorNames)
    error('Nessuna feature valida trovata per la predizione. Controlla il dataset.');
end

% Mantiene solo le feature richieste dal modello
test_features_task3 = selected_features_test_task3(:, predictorNames);

% Effettua le predizioni per ogni finestra temporale
predicted_labels_task3 = quadratic_svm.predictFcn(test_features_task3);

% Aggiunge le predizioni alla tabella delle feature
selected_features_test_task3.PredictedTask3 = predicted_labels_task3;

% Aggregazione per Case con voto di maggioranza
unique_cases = unique(selected_features_test_task3.Case);
final_predictions_task3 = table(unique_cases, zeros(size(unique_cases)), 'VariableNames', {'Case', 'Task3'});

for i = 1:length(unique_cases)
    case_id = unique_cases(i);
    
    % Seleziona tutte le predizioni per lo stesso Case
    case_predictions = selected_features_test_task3.PredictedTask3(selected_features_test_task3.Case == case_id);
    
    % Majority voting: trova l'etichetta più frequente
    final_label = mode(case_predictions);
    
    % Assegna il valore finale
    final_predictions_task3.Task3(i) = final_label;
end

%% AGGIORNAMENTO DEL FILE RESULTS.CSV

% Carica il file CSV esistente con Task1 e Task2
results_t3 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Se la colonna Task3 non esiste, la aggiungiamo
if ~ismember('Task3', results_t3.Properties.VariableNames)
    results_t3.Task3 = zeros(height(results_t3), 1);
end

% Unisce le nuove predizioni con il file esistente (Left Join)
results_t3 = outerjoin(results_t3, final_predictions_task3, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);

% Se Task3_final_predictions_task3 esiste, copiarne i valori in Task3 e rimuoverla
if ismember('Task3_final_predictions_task3', results_t3.Properties.VariableNames)
    results_t3.Task3 = results_t3.Task3_final_predictions_task3;
    results_t3 = removevars(results_t3, 'Task3_final_predictions_task3'); % Rimuovere la colonna temporanea
end

% Sostituisce i NaN con 0 in Task3
results_t3.Task3(isnan(results_t3.Task3)) = 0;

% Rimuove la colonna GroupCount se presente
if ismember('GroupCount', results_t3.Properties.VariableNames)
    results_t3 = removevars(results_t3, 'GroupCount');
end

% Mantieni solo le colonne desiderate nel file finale
varsToKeep = intersect(results_t3.Properties.VariableNames, {'Case', 'Task1', 'Task2', 'Task3'});
results_t3 = results_t3(:, varsToKeep);

% Salva il file aggiornato con Task 3
writetable(results_t3, 'results.csv');

disp('Predizioni per Task 3 completate e salvate in results.csv.');


















% % Ottenere il numero di record nel test set
% numRecords = height(test_set_task3);
% 
% % Creare un array di nomi "CaseXXX"
% caseNames = strcat("Case", string(178:178+numRecords-1));
% 
% % Aggiungere la colonna "Name" alla tabella test_set_task3
% test_set_task3.Name = caseNames';
% 
% % Controlla il nome corretto della colonna Task2
% colName_t3 = "";
% if ismember('Task2', results_t2_2nd.Properties.VariableNames)
%     colName_t3 = 'Task2';
% elseif ismember('CaseLabel_results_t2_2nd', results_t2_2nd.Properties.VariableNames)
%     colName_t3 = 'CaseLabel_results_t2_2nd';
% else
%     error('Errore: né Task2 né CaseLabel_results_t2_2nd trovati in results_t2_2nd!');
% end
% 
% % Usa il nome corretto per filtrare i dati
% filtered_results_t2 = results_t2_2nd(results_t2_2nd.(colName_t3) == 2, {'Case'});
% 
% filtered_results_t2.Properties.VariableNames{'Case'} = 'Name';
% 
% % Unire test_set_task3 con i Case filtrati, mantenendo solo le corrispondenze
% test_set_task3 = innerjoin(test_set_task3, filtered_results_t2, 'Keys', 'Name');
% 
% test_set_task3.Task3 = NaN(height(test_set_task3), 1);
% 
% [featureTable_test_task3, ~] = feature_gen_t3(test_set_task3);
% 
% % Creare una mappatura tra i Case originali e le finestre temporali
% numFeatureRows = height(featureTable_test_task3);
% numTestRows = height(test_set_task3);
% 
% % Se featureTable ha più righe di test_set_task3, ripetiamo i nomi dei Case
% if numFeatureRows > numTestRows
%     repeatedNames = repelem(test_set_task3.Name, numFeatureRows / numTestRows);
%     featureTable_test_task3.Name = repeatedNames;
% else
%     featureTable_test_task3.Name = test_set_task3.Name;
% end
% 
% load('task3/results/SubspaceKNN.mat', 'finalModel_task3');
% 
% %%
% % Predire le etichette per tutte le finestre di featureTable_test_task3
% predicted_labels = finalModel_task3.predictFcn(featureTable_test_task3);
% 
% % Aggiungere le predizioni alla tabella delle feature
% featureTable_test_task3.PredictedLabel = predicted_labels;
% 
% % Verificare che la colonna 'Name' esista
% if ~ismember('Name', featureTable_test_task3.Properties.VariableNames)
%     error('La colonna "Name" non esiste in featureTable_test_task3!');
% end
% featureTable_test_task3.Name = string(featureTable_test_task3.Name);
% 
% % Aggregazione per Case con voto di maggioranza
% grouped_results = groupsummary(featureTable_test_task3, 'Name', 'mode', 'PredictedLabel');
% grouped_results.Properties.VariableNames{'Name'} = 'Case';
% grouped_results.Properties.VariableNames{'mode_PredictedLabel'} = 'Task3';
% 
% % Rimuovere eventuali colonne indesiderate da grouped_results
% colsToRemove = {'GroupCount', 'Task3_grouped_results'};
% grouped_results = removevars(grouped_results, intersect(colsToRemove, grouped_results.Properties.VariableNames));
% 
% % Caricare il file CSV esistente con i risultati di Task 1 e Task 2
% results_t3 = readtable('results.csv', 'VariableNamingRule', 'preserve');
% 
% % Se la colonna Task3 non esiste, la inizializziamo a 0
% if ~ismember('Task3', results_t3.Properties.VariableNames)
%     results_t3.Task3 = zeros(height(results_t3), 1);
% end
% 
% % Unire le predizioni reali con il file esistente (Left Join)
% results_t3 = outerjoin(results_t3, grouped_results, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);
% 
% % Se Task3_grouped_results esiste, copiarne i valori in Task3 e rimuoverla
% if ismember('Task3_grouped_results', results_t3.Properties.VariableNames)
%     results_t3.Task3 = results_t3.Task3_grouped_results;
%     results_t3 = removevars(results_t3, 'Task3_grouped_results'); % Rimuovere la colonna temporanea
% end
% 
% % Sostituire i NaN con 0 in Task3
% results_t3.Task3(isnan(results_t3.Task3)) = 0;
% 
% % Rimuovere la colonna GroupCount se presente
% if ismember('GroupCount', results_t3.Properties.VariableNames)
%     results_t3 = removevars(results_t3, 'GroupCount');
% end
% 
% % Mantieni solo le colonne desiderate nel file finale
% varsToKeep = intersect(results_t3.Properties.VariableNames, {'Case', 'Task1', 'Task2', 'Task3'});
% results_t3 = results_t3(:, varsToKeep);
% 
% % Salvare il file aggiornato con Task 3 senza sovrascrivere altri dati
% writetable(results_t3, 'results.csv');
