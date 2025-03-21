function [bestModel, bestParams, bestFalsiPositivi, featureTable_t2_1st, featureTable_test_t2, selected_feature_names_t2] = one_class_classifier_gridsearch(training_set_task2, test_set, k)
    %% Inizializzazione delle variabili di output
    bestModel = [];
    bestParams = struct('NumLearners', [], 'ContaminationFraction', []);
    bestFalsiPositivi = inf;
    featureTable_t2_1st = table();  
    featureTable_test_t2 = table(); 

    %% Feature Generation Training Set
    window_size = 0.400;
    feature_rows_t2 = {};

    for i = 1:height(training_set_task2)
        case_data = training_set_task2.Case{i};  
        case_id = i;
        case_label = training_set_task2.Task2(i);
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

                % --- FEATURE TEMPORALI ---
                mean_val = mean(window_signal, 'omitnan');
                var_val = var(window_signal, 'omitnan');
                min_val = min(window_signal, [], 'omitnan');
                max_val = max(window_signal, [], 'omitnan');

                % --- FEATURE FREQUENZIALI ---
                Fs = 1 / mean(diff(time(idx))); 
                if isinf(Fs) || isnan(Fs) || Fs <= 0
                    Fs = 1;
                end
                [pxx, f] = pwelch(window_signal, [], [], [], Fs);
                [peak_value, peak_idx] = max(pxx);
                peak_freq = f(peak_idx);
                sum_power_spectrum = sum(pxx);
                rms_freq = sqrt(mean(pxx));

                row_features = [row_features, mean_val, var_val, min_val, max_val, peak_value, peak_freq, sum_power_spectrum, rms_freq];
            end
            
            row_features = [row_features, case_label];
            feature_rows_t2 = [feature_rows_t2; row_features];
        end
    end

    if ~isempty(feature_rows_t2)
        column_names_t2 = {'Case', 'Window_ID'};
        for col = 1:length(signal_columns)
            signal_name = signal_columns{col};
            column_names_t2 = [column_names_t2, ...
                strcat(signal_name, '_Mean'), strcat(signal_name, '_Variance'), ...
                strcat(signal_name, '_Min'), strcat(signal_name, '_Max'), ...
                strcat(signal_name, '_PeakValue'), strcat(signal_name, '_PeakFreq'), ...
                strcat(signal_name, '_SumPowerSpectrum'), strcat(signal_name, '_RMS_Frequency')];
        end
        column_names_t2 = [column_names_t2, 'Task2'];
        
        % Controllo dimensione delle colonne prima di creare la tabella
        num_actual_columns = size(feature_rows_t2, 2);
        if length(column_names_t2) ~= num_actual_columns
            column_names_t2 = column_names_t2(1:num_actual_columns);
        end
        
        featureTable_t2_1st = cell2table(feature_rows_t2, 'VariableNames', column_names_t2);
    else
        error('Errore: feature_rows_t2 è vuoto, impossibile creare la tabella delle feature.');
    end

    %% Feature Selection Training Set
    features_numeric_t2 = featureTable_t2_1st(:, 3:end-1);
    feature_variances = var(table2array(features_numeric_t2), 0, 1);
    [sorted_variances, sorted_idx] = sort(feature_variances, 'descend');
    selected_feature_names_t2 = features_numeric_t2.Properties.VariableNames(sorted_idx(1:12));
    selected_features_t2_1st = featureTable_t2_1st(:, [selected_feature_names_t2, 'Task2']);
    
    % Controlla che almeno 12 feature siano disponibili
    num_features_available = numel(features_numeric_t2.Properties.VariableNames);
    num_features_select = min(12, num_features_available); % Se ci sono meno di 12 feature, seleziona tutte quelle disponibili
    
    % Se il numero di feature disponibili è zero, genera un errore
    if num_features_available == 0
        error('Errore: Nessuna feature disponibile per la selezione.');
    end
    
    % Ora selezioniamo le migliori feature
    selected_feature_names_t2 = features_numeric_t2.Properties.VariableNames(sorted_idx(1:num_features_select));

    %% Feature Generation Test Set
    feature_rows_test_t2 = {};
    for i = 1:height(test_set)
        case_data = test_set.Case{i};  
        case_id = 177 + i;  
        time = case_data.TIME; 
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
                var_val = var(window_signal, 'omitnan');
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
                rms_freq = sqrt(mean(pxx));

                row_features = [row_features, mean_val, var_val, min_val, max_val, peak_value, peak_freq, sum_power_spectrum, rms_freq];
            end
            feature_rows_test_t2 = [feature_rows_test_t2; row_features];
        end
    end

    if ~isempty(feature_rows_test_t2)
        num_actual_columns = size(feature_rows_test_t2, 2);
        if length(column_names_t2) ~= num_actual_columns
            column_names_t2 = column_names_t2(1:num_actual_columns);
        end

        featureTable_test_t2 = cell2table(feature_rows_test_t2, 'VariableNames', column_names_t2);
    else
        error('Errore: feature_rows_test_t2 è vuoto, impossibile creare la tabella delle feature di test.');
    end

    %% **Addestramento Isolation Forest**
    X_train = table2array(selected_features_t2_1st(:, selected_feature_names_t2));
    X_test = table2array(featureTable_test_t2(:, selected_feature_names_t2));
    rng(69);
    cv = cvpartition(size(X_train, 1), 'KFold', k);
    numLearnersGrid = [100, 300, 500, 1000];
    contaminationGrid = [0.01, 0.02, 0.03, 0.05];

    for numLearners = numLearnersGrid
        for contamination = contaminationGrid
            finalModel = iforest(X_train, 'NumLearners', numLearners, 'ContaminationFraction', contamination);
            kfold_results = zeros(size(X_train, 1), 1);
            for i = 1:cv.NumTestSets
                trainIdx = cv.training(i);
                testIdx = cv.test(i);
                [isAnomaly, ~] = isanomaly(finalModel, X_train(testIdx, :));
                kfold_results(testIdx) = isAnomaly;
            end
            falsi_positivi = sum(kfold_results == 1);
            if falsi_positivi < bestFalsiPositivi
                bestFalsiPositivi = falsi_positivi;
                bestModel = finalModel;
                bestParams.NumLearners = numLearners;
                bestParams.ContaminationFraction = contamination;
            end
        end
    end

    %% Predizione finale
    [isAnomaly_test, ~] = isanomaly(bestModel, X_test);
    %disp(['Anomalie rilevate nel test set: ', num2str(sum(isAnomaly_test == 1))]);
end
