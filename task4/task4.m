%% **Preparazione del Training Set per Task 4 (Valve Fault)**

% Filtra i casi con Task2 == 3 (Valve Fault)
training_set_task4 = labeledData(labeledData.Task2 == 3, {'Name', 'Case', 'Task4'});

% Imposta la durata della finestra in secondi
window_size = 0.400;

% Inizializza una cell array per raccogliere i dati
feature_rows_task4 = {};

% Itera su ogni caso nel training set
for i = 1:height(training_set_task4)
    % Estrai la sottotabella del caso attuale
    case_data = training_set_task4.Case{i};  
    
    % Usa l'indice come identificativo del Case
    case_id = training_set_task4.Name(i);

    % Recupera l'etichetta Task4 del caso
    case_label = training_set_task4.Task4(i);

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
        feature_rows_task4 = [feature_rows_task4; row_features];
    end
end

% Costruisci la tabella con nomi di colonna adeguati
column_names_task4 = {'Case', 'Window_ID'};

% Aggiungi i nomi delle feature per ogni segnale
for col = 1:length(signal_columns)
    signal_name = signal_columns{col};
    column_names_task4 = [column_names_task4, ...
        strcat(signal_name, '_Mean'), strcat(signal_name, '_Median'), ...
        strcat(signal_name, '_P25'), strcat(signal_name, '_P75'), ...
        strcat(signal_name, '_Variance'), strcat(signal_name, '_Integral'), ...
        strcat(signal_name, '_Min'), strcat(signal_name, '_Max'), ...
        strcat(signal_name, '_PeakValue'), strcat(signal_name, '_PeakFreq'), ...
        strcat(signal_name, '_SumPowerSpectrum'), strcat(signal_name, '_StdPowerSpectrum'), ...
        strcat(signal_name, '_RMS_Frequency')];
end

% Aggiungi l'etichetta finale
column_names_task4 = [column_names_task4, 'Task4'];

% Converti in tabella
featureTable_task4 = cell2table(feature_rows_task4, 'VariableNames', column_names_task4);

% Salva la tabella nel workspace
assignin('base', 'featureTable_task4', featureTable_task4);

%disp('Feature extraction completata per Task 4.');

%% **FEATURE IMPORTANCE - ANOVA per Task 4**

% Carica il dataset con le feature
features_task4 = featureTable_task4;
features_numeric_task4 = features_task4(:, 3:end-1); % Esclude 'Case', 'Window_ID', 'Task4'
labels_task4 = features_task4.Task4; % Etichetta di classificazione

% Numero di feature
num_features_task4 = width(features_numeric_task4);

% Inizializza il vettore dei p-values
p_values_task4 = zeros(1, num_features_task4);

% Calcola il valore F di ANOVA per ogni feature
for i = 1:num_features_task4
    p_values_task4(i) = anova1(table2array(features_numeric_task4(:, i)), labels_task4, 'off');
end

% Converti p-values in F-values (F = 1/p_values)
F_values_task4 = 1 ./ p_values_task4;
F_values_task4(isinf(F_values_task4) | isnan(F_values_task4)) = max(F_values_task4(~isinf(F_values_task4) & ~isnan(F_values_task4))) * 1.1; % Evita infiniti e NaN

% Ordina le feature in base ai valori F (le più importanti per prime)
[sorted_F_task4, sorted_idx_task4] = sort(F_values_task4, 'descend');
sorted_features_task4 = features_numeric_task4.Properties.VariableNames(sorted_idx_task4);

% Numero di feature da visualizzare
num_features_to_plot_task4 = min(15, num_features_task4);

% Plotta il grafico della feature importance (Prime 15 feature)
% figure;
% bar(sorted_F_task4(1:num_features_to_plot_task4));
% title('Feature Importance - ANOVA (Top 15 Features) - Task 4');
% xlabel('Feature Name');
% ylabel('F-Value');
% xticks(1:num_features_to_plot_task4);
% xticklabels(sorted_features_task4(1:num_features_to_plot_task4));
% xtickangle(90); % Ruota le etichette delle feature
% grid on;

% Seleziona le prime **15** feature più importanti
num_features_to_keep_task4 = 15;
selected_feature_names_task4 = sorted_features_task4(1:num_features_to_keep_task4);

% Crea un nuovo dataset con solo le **top 15 feature**
selected_features_task4 = features_task4(:, ["Case", "Window_ID", selected_feature_names_task4, "Task4"]); 

% Salva il dataset con le feature selezionate
assignin('base', 'selected_features_task4', selected_features_task4);

% disp('Feature selezionate per Task 4:');
% disp(selected_feature_names_task4);

%% **TASK 4 - Estrazione delle Feature per il Test Set (Valve Fault)**

% Carica il test set completo
test_set_complete = test_set();

% Filtra solo i Case che hanno Task2 == 3 (Valve Fault)
filtered_cases_task4 = final_predictions_t2.Case(final_predictions_t2.Task2 == 3);

% Assicura che Case sia trattato come stringa
test_set_complete.Name = string(test_set_complete.Name);
filtered_cases_task4 = string(filtered_cases_task4);

% Seleziona solo i Case di interesse
test_set_task4 = test_set_complete(ismember(test_set_complete.Name, filtered_cases_task4), :);

% Debug: Controlla se i Case selezionati sono corretti
% disp("Numero di casi selezionati per il test:");
% disp(height(test_set_task4));
% 
% disp("Casi selezionati:");
% disp(test_set_task4.Name);

% Imposta la durata della finestra
window_size = 0.400;

% Inizializza cell array per raccogliere le feature
feature_rows_test_task4 = {};

% Itera su ogni caso nel test set
for i = 1:height(test_set_task4)
    % Estrai la sottotabella del caso attuale
    case_data = test_set_task4.Case{i};  
    
    % Identificativo del Case
    case_id = test_set_task4.Name(i);

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
        feature_rows_test_task4 = [feature_rows_test_task4; row_features];
    end
end

% Costruisci la tabella con nomi di colonna adeguati
column_names_task4 = {'Case', 'Window_ID'};
for col = 1:length(signal_columns)
    signal_name = signal_columns{col};
    column_names_task4 = [column_names_task4, ...
        strcat(signal_name, '_Mean'), strcat(signal_name, '_Median'), ...
        strcat(signal_name, '_P25'), strcat(signal_name, '_P75'), ...
        strcat(signal_name, '_Variance'), strcat(signal_name, '_Integral'), ...
        strcat(signal_name, '_Min'), strcat(signal_name, '_Max'), ...
        strcat(signal_name, '_PeakValue'), strcat(signal_name, '_PeakFreq'), ...
        strcat(signal_name, '_SumPowerSpectrum'), strcat(signal_name, '_StdPowerSpectrum'), ...
        strcat(signal_name, '_RMS_Frequency')];
end

% Creazione della tabella finale
featureTable_test_task4 = cell2table(feature_rows_test_task4, 'VariableNames', column_names_task4);

%disp("Feature extraction completata per il Test Set di Task 4.");

%% **SELEZIONE DELLE FEATURE - TEST SET (Task 4)**

% Usa le stesse feature selezionate nel training
selected_features_test_task4 = featureTable_test_task4(:, ["Case", "Window_ID", selected_feature_names_task4]);

% Salva il dataset con le feature selezionate
assignin('base', 'selected_features_test_task4', selected_features_test_task4);

% disp('Feature selezionate per il Test Set di Task 4:');
% disp(selected_feature_names_task4);

%% **TASK 4 - Predizioni e Majority Voting**

% Carica il modello addestrato per il Task 4
load('task4/results/bagged_trees.mat', 'bagged_trees');

% Rimuove 'Case' e 'Window_ID' per la predizione
test_features_task4 = selected_features_test_task4(:, 3:end); 

% Esegue la predizione
predicted_labels_task4 = bagged_trees.predictFcn(test_features_task4);

% Aggiunge le predizioni alla tabella delle feature
selected_features_test_task4.PredictedTask4 = predicted_labels_task4;

% --- Aggregazione per Case con Majority Voting ---
unique_cases_task4 = unique(selected_features_test_task4.Case);
final_predictions_task4 = table(unique_cases_task4, zeros(size(unique_cases_task4)), 'VariableNames', {'Case', 'Task4'});

for i = 1:length(unique_cases_task4)
    case_id = unique_cases_task4(i);
    
    % Seleziona tutte le predizioni per lo stesso Case
    case_predictions = selected_features_test_task4.PredictedTask4(selected_features_test_task4.Case == case_id);
    
    % Majority voting: trova l'etichetta più frequente
    final_label = mode(case_predictions);
    
    % Assegna l'etichetta finale
    final_predictions_task4.Task4(i) = final_label;
end

%% **AGGIORNAMENTO DEL FILE RESULTS.CSV**

% Carica il file CSV con Task1, Task2 e Task3
results_t4 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% Se la colonna Task4 non esiste, la aggiunge
if ~ismember('Task4', results_t4.Properties.VariableNames)
    results_t4.Task4 = zeros(height(results_t4), 1);
end

% Unisce le nuove predizioni con il file esistente (Left Join)
results_t4 = outerjoin(results_t4, final_predictions_task4, 'LeftKeys', 'Case', 'RightKeys', 'Case', 'MergeKeys', true);

% Se "Task4_final_predictions_task4" esiste, copia i valori in Task4 e la rimuove
if ismember('Task4_final_predictions_task4', results_t4.Properties.VariableNames)
    results_t4.Task4 = results_t4.Task4_final_predictions_task4;
    results_t4 = removevars(results_t4, 'Task4_final_predictions_task4'); 
end

% Sostituisce i NaN con 0
results_t4.Task4(isnan(results_t4.Task4)) = 0;

% Salva il file aggiornato
writetable(results_t4, 'results.csv');

%disp('Predizioni per Task 4 completate e salvate in results.csv.');

