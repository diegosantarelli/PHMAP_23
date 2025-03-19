%% **Preparazione del training set**
training_set_task2_2nd = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, {'Case', 'Task2'});

% Imposta la durata della finestra in secondi
window_size = 0.400;

% Inizializza una cell array per raccogliere i dati
feature_rows_training_2nd = {};

%% **Calcolo delle feature per il training set (Task 2)**
for i = 1:height(training_set_task2_2nd)
    case_data = training_set_task2_2nd.Case{i};  
    case_id = i;
    case_label = training_set_task2_2nd.Task2(i);
    time = case_data.TIME; 
    signal_columns = case_data.Properties.VariableNames(2:end);
    total_duration = max(time) - min(time);
    num_windows = max(1, floor(total_duration / window_size));

    for w = 1:num_windows
        start_time = min(time) + (w-1) * window_size;
        end_time = start_time + window_size;
        idx = (time >= start_time) & (time < end_time);
        if sum(idx) < 2
            continue;
        end
        
        row_features = {case_id, w};
        
        for col = 1:length(signal_columns)
            signal_name = signal_columns{col};
            window_signal = case_data.(signal_name)(idx);
            mean_val = mean(window_signal, 'omitnan');
            median_val = median(window_signal, 'omitnan');
            p25_val = prctile(window_signal, 25);
            p75_val = prctile(window_signal, 75);
            var_val = var(window_signal, 'omitnan');
            integral_val = trapz(time(idx), window_signal);
            min_val = min(window_signal, [], 'omitnan');
            max_val = max(window_signal, [], 'omitnan');
            Fs = 1 / mean(diff(time(idx)));  

            if isinf(Fs) || isnan(Fs) || Fs <= 0
                Fs = 1; 
            end

            [pxx, f] = pwelch(window_signal, [], [], [], Fs); 
            [peak_value, peak_idx] = max(pxx);
            peak_freq = f(peak_idx);
            sum_power_spectrum = sum(pxx);
            std_power_spectrum = std(pxx);
            rms_freq = sqrt(mean(pxx));

            row_features = [row_features, mean_val, median_val, p25_val, p75_val, var_val, integral_val, ...
                min_val, max_val, peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, rms_freq];
        end
        
        row_features = [row_features, case_label];
        feature_rows_training_2nd = [feature_rows_training_2nd; row_features];
    end  % Chiusura del ciclo for w (finestre)
end  % Chiusura del ciclo for i (training set)

%% **Preparazione del test set per il secondo classificatore**
% Seleziona solo i Case con anomalie note dal primo classificatore (CaseLabel == 4 in results_t2_1st)
test_set_task2_2nd = results_t2_1st(results_t2_1st.CaseLabel == 4, {'Case', 'CaseLabel'});

% Carica i dati grezzi
test_raw_data = test_set();
test_set_task2_2nd.RawData = cell(height(test_set_task2_2nd), 1);

% Popola i dati grezzi corrispondenti ai case
for i = 1:height(test_set_task2_2nd)
    caseNumber = str2double(test_set_task2_2nd.Case{i});
    rawDataIndex = caseNumber - startIndex + 1;
    test_set_task2_2nd.RawData{i} = test_raw_data.Case{rawDataIndex};
end

% Inizializza la cell array per raccogliere le feature del test set
feature_rows_test_2nd = {};

% Itera su ogni caso del test set per estrarre le feature
for i = 1:height(test_set_task2_2nd)
    case_data = test_set_task2_2nd.RawData{i};
    case_id = test_set_task2_2nd.Case{i};  % Mantieni il Case originale
    case_label = test_set_task2_2nd.CaseLabel(i);  % Etichetta dal primo classificatore

    time = case_data.TIME;
    signal_columns = case_data.Properties.VariableNames(2:end);
    total_duration = max(time) - min(time);
    num_windows = max(1, floor(total_duration / window_size));

    for w = 1:num_windows
        start_time = min(time) + (w-1) * window_size;
        end_time = start_time + window_size;
        idx = (time >= start_time) & (time < end_time);
        if sum(idx) < 2
            continue;
        end
        
        row_features = {case_id, w};

        for col = 1:length(signal_columns)
            signal_name = signal_columns{col};
            window_signal = case_data.(signal_name)(idx);
            mean_val = mean(window_signal, 'omitnan');
            median_val = median(window_signal, 'omitnan');
            p25_val = prctile(window_signal, 25);
            p75_val = prctile(window_signal, 75);
            var_val = var(window_signal, 'omitnan');
            integral_val = trapz(time(idx), window_signal);
            min_val = min(window_signal, [], 'omitnan');
            max_val = max(window_signal, [], 'omitnan');
            Fs = 1 / mean(diff(time(idx)));  

            [pxx, f] = pwelch(window_signal, [], [], [], Fs); 
            [peak_value, peak_idx] = max(pxx);
            peak_freq = f(peak_idx);
            sum_power_spectrum = sum(pxx);
            std_power_spectrum = std(pxx);
            rms_freq = sqrt(mean(pxx));

            row_features = [row_features, mean_val, median_val, p25_val, p75_val, var_val, integral_val, ...
                min_val, max_val, peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, rms_freq];
        end

        row_features = [row_features, case_label];
        feature_rows_test_2nd = [feature_rows_test_2nd; row_features];
    end  % Chiusura del ciclo for w (finestre)
end  % Chiusura del ciclo for i (test set)

%% **Creazione della tabella per il test set**
column_names_test_2nd = {'Case', 'Window_ID'};

for col = 1:length(signal_columns)
    signal_name = signal_columns{col};
    column_names_test_2nd = [column_names_test_2nd, ...
        strcat(signal_name, '_Mean'), strcat(signal_name, '_Median'), ...
        strcat(signal_name, '_P25'), strcat(signal_name, '_P75'), ...
        strcat(signal_name, '_Variance'), strcat(signal_name, '_Integral'), ...
        strcat(signal_name, '_Min'), strcat(signal_name, '_Max'), ...
        strcat(signal_name, '_PeakValue'), strcat(signal_name, '_PeakFreq'), ...
        strcat(signal_name, '_SumPowerSpectrum'), strcat(signal_name, '_StdPowerSpectrum'), ...
        strcat(signal_name, '_RMS_Frequency')];
end

column_names_test_2nd = [column_names_test_2nd, 'CaseLabel'];

% Converti la cell array in una tabella
featureTable_test_2nd = cell2table(feature_rows_test_2nd, 'VariableNames', column_names_test_2nd);

%% **Predizioni**
load('task2/2nd classifier/results/fine_gaussian_t2_2nd.mat', 'fine_gaussian_t2_2nd');

% Assicurati che Case e Window_ID siano numerici
featureTable_test_2nd.Case = str2double(string(featureTable_test_2nd.Case));
featureTable_test_2nd.Window_ID = str2double(string(featureTable_test_2nd.Window_ID));

% Seleziona solo colonne numeriche per l'input del modello
numeric_features = varfun(@isnumeric, featureTable_test_2nd, 'OutputFormat', 'uniform');
test_features_array = table2array(featureTable_test_2nd(:, numeric_features));

% Effettua la predizione
% Seleziona solo le colonne numeriche dal test set per l'input del modello
numeric_features = featureTable_test_2nd(:, 3:end); 
test_features_array = table2array(numeric_features);  % Converte in array numerico

% Effettua la predizione assicurandoti che l'input sia numerico
predicted_labels = fine_gaussian_t2_2nd.predictFcn(featureTable_test_2nd(:, 3:end));


featureTable_test_2nd.PredictedTask2 = predicted_labels;

%% **Majority voting**
unique_cases = unique(featureTable_test_2nd.Case);
final_predictions_t2 = table(unique_cases, zeros(size(unique_cases)), 'VariableNames', {'Case', 'Task2'});

for i = 1:length(unique_cases)
    case_id = unique_cases(i);
    case_predictions = featureTable_test_2nd.PredictedTask2(featureTable_test_2nd.Case == case_id);
    final_label = mode(case_predictions);  
    final_predictions_t2.Task2(i) = final_label;
end

%% **Salvataggio risultati**
writetable(final_predictions_t2, 'results_task2.csv');

% Carica il file CSV dei risultati del Task 1
results_task1 = readtable('results.csv');

% Assicurati che "Case" sia trattato come stringa
results_task1.Case = string(results_task1.Case);
final_predictions_t2.Case = string(final_predictions_t2.Case);
results_t2_1st.Case = string(results_t2_1st.Case);

% Inizializza la colonna Task2 con 0 per tutti i case
if ~ismember("Task2", results_task1.Properties.VariableNames)
    results_task1.Task2 = zeros(height(results_task1), 1);
end

% Assegna Task2 = 1 per i case con Unknown anomaly (CaseLabel == 1)
idx_unknown = ismember(results_task1.Case, results_t2_1st.Case(results_t2_1st.CaseLabel == 1));
results_task1.Task2(idx_unknown) = 1;

% Aggiorna Task2 con le predizioni di final_predictions_t2
for i = 1:height(final_predictions_t2)
    idx_case = results_task1.Case == final_predictions_t2.Case(i);
    if any(idx_case)
        results_task1.Task2(idx_case) = final_predictions_t2.Task2(i);
    end
end

% Salva il file aggiornato con Task1 e Task2 corretti
writetable(results_task1, 'results.csv');
