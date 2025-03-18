% Filtra i casi con Task1 = 0
normal_cases = labeledData(labeledData.Task1 == 0, {'Case', 'Task1'});

% Filtra i casi con Task1 = 1
anomaly_cases = labeledData(labeledData.Task1 == 1, {'Case', 'Task1'});

% Supponiamo di avere due tabelle, table1 e table2
anomaly_cases.Group = repmat({'anomaly_cases'}, height(anomaly_cases), 1); % Aggiungi una colonna per identificare il gruppo
normal_cases.Group = repmat({'normal_cases'}, height(normal_cases), 1);

% Unisci le tabelle
combinedTable = [anomaly_cases; normal_cases];

%%
test_set_task1 = test_set();

% Imposta la durata della finestra in secondi
window_size = 0.400;

% Inizializza una cell array per raccogliere i dati
feature_rows = {};

% Itera su ogni caso in combinedTable
for i = 1:height(combinedTable)
    % Estrai la sottotabella del caso attuale
    case_data = combinedTable.Case{i};  
    
    % Usa l'indice come identificativo del Case
    case_id = i;

    % Recupera l'etichetta Task1 del caso
    case_label = combinedTable.Task1(i);

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
        feature_rows = [feature_rows; row_features];
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
column_names = [column_names, 'Task1'];

% Converti in tabella
featureTable_test = cell2table(feature_rows, 'VariableNames', column_names);

% Salva la tabella nel workspace
assignin('base', 'featureTable_test', featureTable_test);

% Visualizza la tabella delle feature
disp(featureTable_test);

%%
% Carica i dati
features = featureTable_test;
features_numeric = features(:, 3:end-1); % Esclude 'Case', 'Window_ID', 'Label'
labels = features.Task1;

% Numero di feature da selezionare
num_features_select = 22;

% --- 1. Calcolo del valore F di ANOVA per ogni feature ---
p_values = zeros(1, width(features_numeric));
for i = 1:width(features_numeric)
    p_values(i) = anova1(table2array(features_numeric(:, i)), labels, 'off');
end

% Converti p-values in F-values (F = 1/p_values)
F_values = 1 ./ p_values;
F_values(isinf(F_values) | isnan(F_values)) = max(F_values(~isinf(F_values) & ~isnan(F_values))) * 1.1; % Evita infiniti e NaN

% Ordina le feature in base ai valori F (le più discriminanti per prime)
[sorted_F, sorted_idx] = sort(F_values, 'descend'); 

% Seleziona le migliori feature
selected_feature_names = features_numeric.Properties.VariableNames(sorted_idx(1:num_features_select));
selected_features = features(:, [selected_feature_names, "Task1"]); % Mantiene anche l'etichetta

% --- Salva la tabella con le feature selezionate nel workspace ---
assignin('base', 'selected_features_anova', selected_features);

% Visualizza le feature selezionate
disp('Feature selezionate con ANOVA:');
disp(selected_feature_names);

% Mostra la nuova tabella ridotta
disp(selected_features);

%% TEST SET
% --- 1. Estrazione delle Feature sul Test Set ---

% Rimuove la colonna 'Spacecraft' dal test set
test_set_task1 = removevars(test_set_task1, 'Spacecraft');

% Imposta la durata della finestra in secondi
window_size = 0.400;

% Inizializza una cell array per raccogliere i dati
feature_rows_test = {};

% Itera su ogni caso nel test set
for i = 1:height(test_set_task1)
    % Estrai la sottotabella del caso attuale
    case_data = test_set_task1.Case{i};  
    
    % Usa l'indice come identificativo del Case
    case_id = 177 + i;

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
        feature_rows_test = [feature_rows_test; row_features];
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
featureTable_testset = cell2table(feature_rows_test, 'VariableNames', column_names);

% --- 2. Selezione delle Top 22 Feature (dai risultati di ANOVA) ---

% Seleziona solo le feature che erano nelle prime 22 nel training set
selected_features_testset = featureTable_testset(:, ["Case", "Window_ID", selected_feature_names]);

% Salva e aggiorna il workspace
assignin('base', 'selected_features_testset', selected_features_testset);

% Verifica la struttura della tabella
summary(selected_features_testset)

%% Predizioni

load('task1/results/coarse_tree_final.mat', 'coarse_tree');

% Rimuove 'Case' e 'Window_ID' per la predizione
test_features = selected_features_testset(:, 3:end); % Mantiene solo le feature

% Esegue le predizioni
predicted_labels = coarse_tree.predictFcn(test_features);

% Aggiunge le predizioni alla tabella
selected_features_testset.PredictedTask1 = predicted_labels;

% Raggruppa per Case e applica majority voting
unique_cases = unique(selected_features_testset.Case);
final_predictions = table(unique_cases, zeros(size(unique_cases)), 'VariableNames', {'Case', 'Task1'});

for i = 1:length(unique_cases)
    case_id = unique_cases(i);
    
    % Seleziona tutte le predizioni per lo stesso Case
    case_predictions = selected_features_testset.PredictedTask1(selected_features_testset.Case == case_id);
    
    % Majority voting: trova l'etichetta più frequente
    final_label = mode(case_predictions);
    
    % Converte l'etichetta in 1 (anomaly) e 0 (normal)
    final_predictions.Task1(i) = double(final_label ~= 0); % Se diverso da 0, allora è anomaly (1)
end

% Visualizza la tabella finale
disp(final_predictions);
















% % Imposta la durata della finestra in secondi
% window_size = 0.400;
% 
% % Inizializza la tabella delle feature
% featureTable_test = table();
% 
% % Definisce la dimensione della finestra mobile (numero di campioni)
% moving_window_size = 3; % Adatta in base alla frequenza di campionamento
% 
% % Itera su ogni caso in combinedTable
% for i = 1:height(combinedTable)
%     % Estrai la sottotabella del caso attuale
%     case_data = combinedTable.Case{i};  
% 
%     % Usa l'indice come identificativo del Case
%     case_id = i;
% 
%     % Recupera l'etichetta Task1 del caso
%     case_label = combinedTable.Task1(i);
% 
%     % Estrai il tempo
%     time = case_data.TIME; 
% 
%     % Ottieni i nomi delle colonne dei segnali (tutti eccetto TIME)
%     signal_columns = case_data.Properties.VariableNames(2:end);
% 
%     % Calcolo corretto della durata totale
%     total_duration = max(time) - min(time);
% 
%     % Calcola il numero di finestre
%     num_windows = max(1, floor(total_duration / window_size));
% 
%     % DEBUG: Stampiamo il numero di finestre per ogni caso
%     disp(['Case ', num2str(i), ': Total Duration = ', num2str(total_duration), ...
%           's, Num Windows = ', num2str(num_windows)]);
% 
%     % Inizializza il contatore delle finestre per questo Case
%     window_id = 0;
% 
%     % Itera su ogni finestra
%     for w = 1:num_windows
%         % Calcola i limiti della finestra
%         start_time = min(time) + (w-1) * window_size;
%         end_time = start_time + window_size;
% 
%         % Seleziona i dati nella finestra
%         idx = (time >= start_time) & (time < end_time);
% 
%         % Debug: Stampa info sulle finestre
%         disp(['Case ', num2str(i), ', Window ', num2str(w), ...
%               ': Start Time = ', num2str(start_time), ...
%               ', End Time = ', num2str(end_time), ...
%               ', Data Points = ', num2str(sum(idx))]);
% 
%         % Se la finestra è vuota o contiene meno di 2 elementi, la salta
%         if sum(idx) < 2
%             continue;
%         end
% 
%         % Incrementa il numero della finestra
%         window_id = window_id + 1;
% 
%         % Itera su ogni colonna di segnale (P1, P2, ..., Pn)
%         for col = 1:length(signal_columns)
%             signal_name = {signal_columns{col}}; % Converte in cella di caratteri
%             window_signal = case_data.(signal_columns{col})(idx); % Estrai i dati della finestra
% 
%             % --- FEATURE TEMPORALI ---
%             mean_val = mean(window_signal, 'omitnan');
%             var_val = var(window_signal, 'omitnan');
%             min_val = min(window_signal, [], 'omitnan');
%             max_val = max(window_signal, [], 'omitnan');
%             median_val = median(window_signal, 'omitnan');
%             percentile_90 = prctile(window_signal, 90);
% 
%             % --- MEDIA MOBILE & DEVIAZIONE STANDARD MOBILE ---
%             mov_mean = movmean(window_signal, moving_window_size, 'omitnan');
%             mov_std = movstd(window_signal, moving_window_size, 'omitnan');
% 
%             % Media e deviazione standard della media mobile su tutta la finestra
%             mean_mov_mean = mean(mov_mean, 'omitnan');
%             mean_mov_std = mean(mov_std, 'omitnan');
% 
%             % --- FEATURE FREQUENZIALI ---
%             % Frequenza di campionamento stimata
%             Fs = 1 / mean(diff(time(idx))); 
% 
%             % Evita errori in caso di Fs non valido
%             if isinf(Fs) || isnan(Fs) || Fs <= 0
%                 Fs = 1; % Assegna un valore di default
%             end
% 
%             % Calcola lo spettro di potenza con pwelch
%             [pxx, f] = pwelch(window_signal, [], [], [], Fs); 
% 
%             % Peak Value & Peak Frequency
%             [peak_value, peak_idx] = max(pxx);
%             peak_freq = f(peak_idx);
% 
%             % Sum Power Spectrum & Std Power Spectrum
%             sum_power_spectrum = sum(pxx);
%             std_power_spectrum = std(pxx);
% 
%             % Aggiungi i risultati alla tabella con l'etichetta Task1
%             new_row = table(...
%                 case_id, window_id, signal_name, mean_val, var_val, min_val, max_val, median_val, percentile_90, ...
%                 mean_mov_mean, mean_mov_std, ...
%                 peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, case_label, ...
%                 'VariableNames', {'Case', 'Window_ID', 'Signal', 'Mean', 'Variance', 'Min', 'Max', 'Median', ...
%                 '90th_Percentile', 'MeanMovMean', 'MeanMovStd', ...
%                 'PeakValue', 'PeakFreq', 'SumPowerSpectrum', 'StdPowerSpectrum', 'Label'});
% 
%             featureTable_test = [featureTable_test; new_row]; % Concatenazione della nuova riga
%         end
%     end
% end
% 
% % Salva la tabella nel workspace
% assignin('base', 'featureTable_test', featureTable_test);
% 
% % Visualizza la tabella delle feature
% disp(featureTable_test);
