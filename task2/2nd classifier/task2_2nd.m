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
    end  
end  

%% **Selezione delle feature con ANOVA (Training Set)**
features_training_2nd = cell2table(feature_rows_training_2nd, 'VariableNames', column_names_test_2nd);
features_numeric_2nd = features_training_2nd(:, 3:end-1); 
labels_2nd = features_training_2nd.CaseLabel; % Usa Task2 per etichettare le anomalie
num_features_select_2nd = 20;

p_values_2nd = zeros(1, width(features_numeric_2nd));
for i = 1:width(features_numeric_2nd)
    p_values_2nd(i) = anova1(table2array(features_numeric_2nd(:, i)), labels_2nd, 'off');
end

F_values_2nd = 1 ./ p_values_2nd;
F_values_2nd(isinf(F_values_2nd) | isnan(F_values_2nd)) = max(F_values_2nd(~isinf(F_values_2nd) & ~isnan(F_values_2nd))) * 1.1;
[sorted_F_2nd, sorted_idx_2nd] = sort(F_values_2nd, 'descend'); 
selected_feature_names_2nd = features_numeric_2nd.Properties.VariableNames(sorted_idx_2nd(1:num_features_select_2nd));
selected_features_2nd = features_training_2nd(:, ["Case", "Window_ID", selected_feature_names_2nd, "CaseLabel"]);

assignin('base', 'selected_features_anova_2nd', selected_features_2nd);

%% **Preparazione del test set con feature selezionate**
features_test_2nd = cell2table(feature_rows_test_2nd, 'VariableNames', column_names_test_2nd);

% Assicurati che il test set abbia esattamente le stesse feature del training
missing_features = setdiff(selected_feature_names_2nd, features_test_2nd.Properties.VariableNames);
for feature = missing_features
    features_test_2nd.(feature{1}) = zeros(height(features_test_2nd), 1); % Aggiunge colonne mancanti con zeri
end

% Ora seleziona solo le feature comuni tra training e test
selected_features_testset_2nd = features_test_2nd(:, ["Case", "Window_ID", selected_feature_names_2nd]);
selected_features_testset_2nd.Case = str2double(string(selected_features_testset_2nd.Case));

%% **Selezione delle feature con ANOVA (Test Set)**
features_numeric_test_2nd = selected_features_testset_2nd(:, 3:end); 

% Assicurati che le etichette siano della stessa lunghezza del test set
labels_test_2nd = selected_features_testset_2nd.Case; 

p_values_test_2nd = zeros(1, width(features_numeric_test_2nd));
for i = 1:width(features_numeric_test_2nd)
    p_values_test_2nd(i) = anova1(table2array(features_numeric_test_2nd(:, i)), labels_test_2nd, 'off');
end


F_values_test_2nd = 1 ./ p_values_test_2nd;
F_values_test_2nd(isinf(F_values_test_2nd) | isnan(F_values_test_2nd)) = max(F_values_test_2nd(~isinf(F_values_test_2nd) & ~isnan(F_values_test_2nd))) * 1.1;
[sorted_F_test_2nd, sorted_idx_test_2nd] = sort(F_values_test_2nd, 'descend'); 

% Manteniamo le stesse feature del training
selected_features_testset_2nd = selected_features_testset_2nd(:, ["Case", "Window_ID", selected_feature_names_2nd]);

%% **Predizioni con il secondo classificatore**
load('task2/2nd classifier/results/quadratic_svm.mat', 'quadratic_svm');

test_features_2nd = selected_features_testset_2nd(:, 3:end);
predicted_labels_2nd = quadratic_svm.predictFcn(test_features_2nd);
selected_features_testset_2nd.PredictedTask2 = predicted_labels_2nd;

unique_cases_2nd = unique(selected_features_testset_2nd.Case);
final_predictions_t2 = table(unique_cases_2nd, zeros(size(unique_cases_2nd)), 'VariableNames', {'Case', 'Task2'});

for i = 1:length(unique_cases_2nd)
    case_id = unique_cases_2nd(i);
    case_predictions = selected_features_testset_2nd.PredictedTask2(selected_features_testset_2nd.Case == case_id);
    final_label = mode(case_predictions);
    final_predictions_t2.Task2(i) = final_label;
end

%% **Salvataggio risultati**
writetable(final_predictions_t2, 'results_task2.csv');

% Carica il file CSV dei risultati del Task 1
results_task1 = readtable('results.csv');
results_task1.Case = string(results_task1.Case);
final_predictions_t2.Case = string(final_predictions_t2.Case);

if ~ismember("Task2", results_task1.Properties.VariableNames)
    results_task1.Task2 = zeros(height(results_task1), 1);
end

for i = 1:height(final_predictions_t2)
    idx_case = results_task1.Case == final_predictions_t2.Case(i);
    if any(idx_case)
        results_task1.Task2(idx_case) = final_predictions_t2.Task2(i);
    end
end

writetable(results_task1, 'results.csv');