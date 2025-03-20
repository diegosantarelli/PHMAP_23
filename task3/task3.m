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

%% FEATURE IMPORTANCE - ANOVA

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

% Carica il test set completo
test_set_complete = test_set();

% Filtra solo i Case che hanno Task2 == 2 (caso del Task 3)
filtered_cases = final_predictions_t2.Case(final_predictions_t2.Task2 == 2);

% Assicura che Case sia trattato come stringa
test_set_complete.Name = string(test_set_complete.Name);
filtered_cases = string(filtered_cases);

% Seleziona solo i Case di interesse
test_set_task3 = test_set_complete(ismember(test_set_complete.Name, filtered_cases), :);

% Imposta la durata della finestra
window_size = 0.400;

% Inizializza cell array per raccogliere le feature
feature_rows_test_task3 = {};

% Itera su ogni caso nel test set
for i = 1:height(test_set_task3)
    % Estrai la sottotabella del caso attuale
    case_data = test_set_task3.Case{i};  
    
    % Identificativo del Case
    case_id = test_set_task3.Name(i);

    % Estrai il tempo
    time = case_data.TIME; 
    
    % Ottieni i nomi delle colonne dei segnali (tutti eccetto TIME)
    signal_columns = case_data.Properties.VariableNames(2:end);
    
    % Calcola la durata totale e il numero di finestre
    total_duration = max(time) - min(time);
    num_windows = max(1, floor(total_duration / window_size));

    % Itera sulle finestre temporali
    for w = 1:num_windows
        % Calcola i limiti della finestra
        start_time = min(time) + (w-1) * window_size;
        end_time = start_time + window_size;
        
        % Seleziona i dati nella finestra
        idx = (time >= start_time) & (time < end_time);

        % Se la finestra è vuota o contiene meno di 2 elementi, la salta
        if sum(idx) < 2, continue; end

        % Inizializza il vettore per la riga della tabella
        row_features = {case_id, w};
        
        % Itera su ogni colonna di segnale
        for col = 1:length(signal_columns)
            signal_name = signal_columns{col};  
            window_signal = case_data.(signal_name)(idx); 

            % --- FEATURE TEMPORALI ---
            mean_val = mean(window_signal, 'omitnan');
            median_val = median(window_signal, 'omitnan');
            p25_val = prctile(window_signal, 25);
            p75_val = prctile(window_signal, 75);
            var_val = var(window_signal, 'omitnan');
            integral_val = trapz(time(idx), window_signal);
            min_val = min(window_signal, [], 'omitnan');
            max_val = max(window_signal, [], 'omitnan');

            % --- FEATURE FREQUENZIALI ---
            Fs = 1 / mean(diff(time(idx))); 
            if isinf(Fs) || isnan(Fs) || Fs <= 0, Fs = 1; end

            % Calcola lo spettro di potenza con pwelch
            [pxx, f] = pwelch(window_signal, [], [], [], Fs); 

            % Frequenza e valore di picco
            [peak_value, peak_idx] = max(pxx);
            peak_freq = f(peak_idx);

            % Somma spettro di potenza, deviazione standard e RMS
            sum_power_spectrum = sum(pxx);
            std_power_spectrum = std(pxx);
            rms_freq = sqrt(mean(pxx));

            % Aggiungi le feature alla riga
            row_features = [row_features, mean_val, median_val, p25_val, p75_val, var_val, integral_val, ...
                min_val, max_val, peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, rms_freq];
        end
        
        % Salva la riga nella lista di feature
        feature_rows_test_task3 = [feature_rows_test_task3; row_features];
    end
end

% Costruisci la tabella con nomi di colonna adeguati
column_names = {'Case', 'Window_ID'};
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

% Creazione della tabella finale
featureTable_test_task3 = cell2table(feature_rows_test_task3, 'VariableNames', column_names);

% --- Selezione delle Feature per il Test Set ---

% Usa le stesse feature selezionate nel training
selected_features_test_task3 = featureTable_test_task3(:, ["Case", "Window_ID", selected_feature_names]);

% Salva il dataset con le feature selezionate
assignin('base', 'selected_features_test_task3', selected_features_test_task3);

%% TASK 3 - Predizioni e Majority Voting

% Carica il modello addestrato per il Task 3
load('task3/results/linear_svm.mat', 'linear_svm');

% Rimuove 'Case' e 'Window_ID' per la predizione
test_features_task3 = selected_features_test_task3(:, 3:end); 

% Esegue la predizione
predicted_labels_task3 = linear_svm.predictFcn(test_features_task3);

% Aggiunge le predizioni alla tabella delle feature
selected_features_test_task3.PredictedTask3 = predicted_labels_task3;

% --- Aggregazione per Case con Majority Voting ---
unique_cases = unique(selected_features_test_task3.Case);
final_predictions_task3 = table(unique_cases, zeros(size(unique_cases)), 'VariableNames', {'Case', 'Task3'});

for i = 1:length(unique_cases)
    case_id = unique_cases(i);
    
    % Seleziona tutte le predizioni per lo stesso Case
    case_predictions = selected_features_test_task3.PredictedTask3(selected_features_test_task3.Case == case_id);
    
    % Majority voting: trova l'etichetta più frequente
    final_label = mode(case_predictions);
    
    % Assegna l'etichetta finale
    final_predictions_task3.Task3(i) = final_label;
end


%% AGGIORNAMENTO DEL FILE RESULTS.CSV

% Carica il file CSV con Task1 e Task2
results_t3 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Se la colonna Task3 non esiste, la aggiunge
if ~ismember('Task3', results_t3.Properties.VariableNames)
    results_t3.Task3 = zeros(height(results_t3), 1);
end

% Unisce le nuove predizioni con il file esistente (Left Join)
results_t3 = outerjoin(results_t3, final_predictions_task3, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);

% Se Task3_final_predictions_task3 esiste, copia i valori in Task3 e la rimuove
if ismember('Task3_final_predictions_task3', results_t3.Properties.VariableNames)
    results_t3.Task3 = results_t3.Task3_final_predictions_task3;
    results_t3 = removevars(results_t3, 'Task3_final_predictions_task3'); 
end

% Sostituisce i NaN con 0
results_t3.Task3(isnan(results_t3.Task3)) = 0;

% Salva il file aggiornato
writetable(results_t3, 'results.csv');

disp('Predizioni per Task 3 completate e salvate in results.csv.');
