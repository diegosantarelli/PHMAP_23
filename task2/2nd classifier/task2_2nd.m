%% **Preparazione del training set**
training_set_task2_2nd = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, {'Case', 'Task2'});

% Imposta la durata della finestra in secondi
window_size = 0.400;

% Inizializza una cell array per raccogliere i dati
feature_rows_training_2nd = {};

%% **Calcolo delle feature per il training set (Task 2)**
for i = 1:height(training_set_task2_2nd)
    case_data = training_set_task2_2nd.Case{i};  
    
    % Usa l'indice come identificativo del Case
    case_id = i;

    % Recupera l'etichetta Task2 del caso
    case_label = training_set_task2_2nd.Task2(i);

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
            Fs = 1 / mean(diff(time(idx)));  % Frequenza di campionamento stimata
            
            % Evita errori in caso di Fs non valido
            if isinf(Fs) || isnan(Fs) || Fs <= 0
                Fs = 1; % Assegna un valore di default
            end

            % Calcola lo spettro di potenza con pwelch
            [pxx, f] = pwelch(window_signal, [], [], [], Fs); 
            
            [peak_value, peak_idx] = max(pxx);
            peak_freq = f(peak_idx);
            
            sum_power_spectrum = sum(pxx);
            std_power_spectrum = std(pxx);
            
            rms_freq = sqrt(mean(pxx));

            % Aggiungi le feature alla riga
            row_features = [row_features, mean_val, median_val, p25_val, p75_val, var_val, integral_val, ...
                min_val, max_val, peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, rms_freq];
        end
        
        % Aggiungi l'etichetta
        row_features = [row_features, case_label];
        
        % Salva la riga
        feature_rows_training_2nd = [feature_rows_training_2nd; row_features];
    end
end

% Costruisci la tabella con nomi di colonna adeguati per il training set
column_names_training_2nd = {'Case', 'Window_ID'};

for col = 1:length(signal_columns)
    signal_name = signal_columns{col};
    column_names_training_2nd = [column_names_training_2nd, ...
        strcat(signal_name, '_Mean'), strcat(signal_name, '_Median'), ...
        strcat(signal_name, '_P25'), strcat(signal_name, '_P75'), ...
        strcat(signal_name, '_Variance'), strcat(signal_name, '_Integral'), ...
        strcat(signal_name, '_Min'), strcat(signal_name, '_Max'), ...
        strcat(signal_name, '_PeakValue'), strcat(signal_name, '_PeakFreq'), ...
        strcat(signal_name, '_SumPowerSpectrum'), strcat(signal_name, '_StdPowerSpectrum'), ...
        strcat(signal_name, '_RMS_Frequency')];
end

% Aggiungi l'etichetta finale
column_names_training_2nd = [column_names_training_2nd, 'Task2'];

% Converti in tabella per il training set
featureTable_training_2nd = cell2table(feature_rows_training_2nd, 'VariableNames', column_names_training_2nd);

%% **Preparazione delle feature per il training set**
% Estrai solo le feature numeriche, escludendo 'Case', 'Window_ID' e 'Task2'
features_numeric_2nd = featureTable_training_2nd(:, 3:end-1);
labels_2nd = featureTable_training_2nd.Task2;  % Etichette di Task2

% Calcola il valore F di ANOVA per ogni feature
p_values_2nd = zeros(1, width(features_numeric_2nd)); % Vettore per i p-values
F_values_2nd = zeros(1, width(features_numeric_2nd)); % Vettore per i F-values

for i = 1:width(features_numeric_2nd)
    % Calcola ANOVA per ogni feature e salva il p-value
    p_values_2nd(i) = anova1(table2array(features_numeric_2nd(:, i)), labels_2nd, 'off');
    % Calcola il valore F (F = 1 / p-value)
    F_values_2nd(i) = 1 / p_values_2nd(i);
end

% Seleziona solo le 14 feature migliori (secondo i valori F di ANOVA)
selected_feature_names_training_2nd = sorted_feature_names_2nd(1:14);
selected_features_training_2nd = featureTable_training_2nd(:, [selected_feature_names_training_2nd, 'Task2']);

% Ora 'selected_features_training_2nd' contiene le 14 feature selezionate insieme alle etichette 'Task2'


% Ordina le feature in base ai valori F (dal più alto al più basso)
[sorted_F_2nd, sorted_idx_2nd] = sort(F_values_2nd, 'descend');
sorted_feature_names_2nd = features_numeric_2nd.Properties.VariableNames(sorted_idx_2nd);

% **Visualizzazione del grafico delle feature ordinate per valori F (ANOVA)**
num_features_plot = 22;  % Numero di feature da visualizzare
top_sorted_F_2nd = sorted_F_2nd(1:num_features_plot);
top_sorted_feature_names_2nd = sorted_feature_names_2nd(1:num_features_plot);

figure('Position', [100, 100, 1200, 600]); % Imposta una dimensione maggiore per il grafico
barh(top_sorted_F_2nd); % Grafico a barre orizzontali dei valori F
set(gca, 'XTick', 1:num_features_plot); % Etichette sull'asse X
set(gca, 'XTickLabel', top_sorted_feature_names_2nd, 'XTickLabelRotation', 90); % Ruota le etichette per una migliore visibilità
xlabel('ANOVA F-value');
title('Top 30 Feature ordinate per valore F (ANOVA) - Task 2');
set(gca, 'YDir', 'reverse'); % Inverte l'ordine delle feature
set(gca, 'XScale', 'log'); % Usa scala logaritmica per evitare distorsioni
xtickformat('%.1e'); % Formatta gli assi per numeri grandi
grid on;


%% Preparazione del test set
test_set_task2_2nd = results_t2_1st(results_t2_1st.CaseLabel == 4, {'Case', 'CaseLabel'});

test_raw_data = test_set();  % Funzione che carica i dati grezzi

% Aggiungi una colonna vuota per contenere i dati grezzi (come cell array)
test_set_task2_2nd.RawData = cell(height(test_set_task2_2nd), 1);

% Indice iniziale dei Case
startIndex = 178;

% Popola la colonna RawData prendendo i dati grezzi dalla tabella test_raw_data
for i = 1:height(test_set_task2_2nd)
    caseNumber = str2double(test_set_task2_2nd.Case{i});  % Assicurati che 'Case' sia una stringa
    rawDataIndex = caseNumber - startIndex + 1;  % Calcola l'indice corrispondente nei dati grezzi
    test_set_task2_2nd.RawData{i} = test_raw_data.Case{rawDataIndex};  % Assegna i dati grezzi alla colonna RawData
end

% Inizializza una cell array per raccogliere i dati del test set
feature_rows_test_2nd = {};

% Itera su ogni caso nel test set
for i = 1:height(test_set_task2_2nd)
    case_data = test_set_task2_2nd.RawData{i};  % Estrai i dati grezzi corrispondenti al case
    
    case_id = i;  % Identificatore del caso
    case_label = test_set_task2_2nd.CaseLabel(i);  % Etichetta Task2

    % Estrai il tempo
    time = case_data.TIME; 
    signal_columns = case_data.Properties.VariableNames(2:end);  % Colonne dei segnali

    % Calcolo della durata totale e numero di finestre
    total_duration = max(time) - min(time);
    num_windows = max(1, floor(total_duration / window_size));

    % Itera su ogni finestra
    for w = 1:num_windows
        start_time = min(time) + (w-1) * window_size;
        end_time = start_time + window_size;
        idx = (time >= start_time) & (time < end_time);
        
        % Se la finestra è vuota o contiene meno di 2 elementi, salta
        if sum(idx) < 2
            continue;
        end
        
        % Aggiungi una riga per ogni finestra
        row_features = {case_id, w};  % Colonne iniziali

        % Estrai le feature per ogni segnale
        for col = 1:length(signal_columns)
            signal_name = signal_columns{col};
            window_signal = case_data.(signal_name)(idx);
            
            % Calcola le feature temporali e frequenziali
            mean_val = mean(window_signal, 'omitnan');
            median_val = median(window_signal, 'omitnan');
            p25_val = prctile(window_signal, 25);
            p75_val = prctile(window_signal, 75);
            var_val = var(window_signal, 'omitnan');
            integral_val = trapz(time(idx), window_signal);
            min_val = min(window_signal, [], 'omitnan');
            max_val = max(window_signal, [], 'omitnan');
            Fs = 1 / mean(diff(time(idx)));  % Frequenza di campionamento stimata
            
            [pxx, f] = pwelch(window_signal, [], [], [], Fs); 
            [peak_value, peak_idx] = max(pxx);
            peak_freq = f(peak_idx);
            sum_power_spectrum = sum(pxx);
            std_power_spectrum = std(pxx);
            rms_freq = sqrt(mean(pxx));

            % Aggiungi le feature calcolate alla riga
            row_features = [row_features, mean_val, median_val, p25_val, p75_val, var_val, integral_val, ...
                min_val, max_val, peak_value, peak_freq, sum_power_spectrum, std_power_spectrum, rms_freq];
        end

        % Aggiungi l'etichetta alla riga
        row_features = [row_features, case_label];

        % Aggiungi la riga alla cell array
        feature_rows_test_2nd = [feature_rows_test_2nd; row_features];
    end
end

% Costruisci la tabella finale con i nomi delle colonne corretti
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

% Converti in tabella per il test set
featureTable_test_2nd = cell2table(feature_rows_test_2nd, 'VariableNames', column_names_test_2nd);

%% **Selezione delle feature per il test set**
% Estrai le feature numeriche per il test set, escludendo 'Case', 'Window_ID' e 'CaseLabel'
features_numeric_test_2nd = featureTable_test_2nd(:, 3:end-1);
labels_test_2nd = featureTable_test_2nd.CaseLabel;  % Etichette di CaseLabel per il test set

% Selezionare solo le 14 feature migliori calcolate durante l'addestramento
selected_features_test_2nd = features_numeric_test_2nd(:, sorted_idx_2nd(1:14)); 

%% Predizioni
% Carica il modello per il secondo task
load('task2/2nd classifier/results/fine_gaussian_t2_2nd.mat', 'fine_gaussian_t2_2nd');

% Esegui le predizioni utilizzando il modello caricato
test_features_array = table2array(selected_features_test_2nd);  % Converte in matrice

% Usa predictFcn come hai fatto in precedenza
predicted_labels = fine_gaussian_t2_2nd.predictFcn(test_features_array);

% Aggiungi le predizioni alla tabella
selected_features_test_2nd.PredictedTask2 = predicted_labels;

% Raggruppa per Case e applica majority voting
unique_cases = unique(selected_features_test_2nd.Case);
final_predictions_t2 = table(unique_cases, zeros(size(unique_cases)), 'VariableNames', {'Case', 'Task2'});

for i = 1:length(unique_cases)
    case_id = unique_cases(i);
    
    % Seleziona tutte le predizioni per lo stesso Case
    case_predictions = selected_features_test_2nd.PredictedTask2(selected_features_test_2nd.Case == case_id);
    
    % Majority voting: trova l'etichetta più frequente
    final_label = mode(case_predictions);  % Calcola il valore più frequente
    
    % Converte l'etichetta in 1 (anomaly) e 0 (normal), 
    % dove 1 indica "unknown anomaly" e 0 indica "known anomaly"
    final_predictions_t2.Task2(i) = double(final_label ~= 0); % Se diverso da 0, è una "unknown anomaly" (1)
end

% Visualizza la tabella finale con le predizioni
disp(final_predictions_t2);

% Salva i risultati nel file CSV
writetable(final_predictions_t2, 'results_task2.csv');














% test_raw_data = test_set();
% 
% % Aggiungi una colonna vuota per contenere i dati grezzi (come cell array)
% test_set_task2_2nd.RawData = cell(height(test_set_task2_2nd), 1);
% 
% % Indice iniziale dei Case
% startIndex = 178;
% 
% % Popola la colonna RawData prendendo i dati grezzi dalla tabella test_raw_data
% for i = 1:height(test_set_task2_2nd)
%     % Estrai il numero del Case dall'etichetta 'CaseXXX'
%     caseNumber = str2double(erase(test_set_task2_2nd.Case{i}, 'Case'));
% 
%     % Calcola l'indice della riga corrispondente in test_raw_data
%     rawDataIndex = caseNumber - startIndex + 1;
% 
%     % Assegna la sottotabella dei dati grezzi
%     test_set_task2_2nd.RawData{i} = test_raw_data.Case{rawDataIndex};
% end
% 
% test_set_task2_2nd.Task2 = NaN(height(test_set_task2_2nd), 1);
% 
% test_set_task2_2nd = test_set_task2_2nd(:, {'RawData', 'Task2'});
% test_set_task2_2nd.Properties.VariableNames = {'Case', 'Task2'};
% 
% [featureTable_test_task2_2nd, ~] = feature_gen_t2_2nd(test_set_task2_2nd);
% 
% load('task2/2nd classifier/results/rusBoostedTrees.mat', 'finalModel_task2_2nd');
% 
% %% Addestrare un classificatore a distinguere tra Bubble Anomaly e Vaulve Fault
% % utilizzando come training set i 177 case etichettati, filtrando solo per
% % Known Anomaly (etichetta Fault e Anomaly)
% % classificazione tramite codice
% 
% % Predizione sui dati di test del secondo classificatore
% [yfit_task2_2nd, ~] = finalModel_task2_2nd.predictFcn(featureTable_test_task2_2nd);
% 
% % Estrai il numero dei Member da EnsembleID_ (Member X -> X)
% memberNumbers = str2double(erase(featureTable_test_task2_2nd.EnsembleID_, 'Member '));
% 
% % Assumi che i Member siano assegnati in blocchi ai Case con etichetta 4
% numMembersPerCase = numel(memberNumbers) / numel(filteredCases);
% 
% if mod(numMembersPerCase, 1) ~= 0
%     error('Il numero di Member non è divisibile esattamente per i Case!');
% end
% 
% % Crea la mappatura Member -> Case usando filteredCases
% caseMapping = repelem(filteredCases, numMembersPerCase);
% 
% % Assegna la colonna Case mappata ai risultati
% results_t2_2nd = table(caseMapping, yfit_task2_2nd, 'VariableNames', {'Case', 'Task2'});
% 
% % Voto di maggioranza per ogni Case
% [uniqueCases, ~, idx] = unique(results_t2_2nd.Case);
% yfit_majority = accumarray(idx, results_t2_2nd.Task2, [], @mode);
% 
% % Tabella finale con una sola riga per ogni Case
% results_t2_2nd = table(uniqueCases, yfit_majority, 'VariableNames', {'Case', 'Task2'});
% 
% % Carica il file CSV dei risultati del Task 1
% results_task1 = readtable('results.csv');
% 
% % Inizializza la colonna Task2 con 0 per default
% results_task1.Task2 = zeros(height(results_task1), 1);
% 
% % 1. Imposta Task2 = 1 per i Case con Unknown anomaly (CaseLabel == 1)
% idx_unknown = ismember(results_task1.Case, results_t2_1st.Case(results_t2_1st.CaseLabel == 1));
% results_task1.Task2(idx_unknown) = 1;
% 
% % 2. Imposta Task2 = 2 o 3 per i Case classificati dal secondo classificatore
% for i = 1:height(results_t2_2nd)
%     idx_case = strcmp(results_task1.Case, results_t2_2nd.Case{i});
%     if any(idx_case)
%         results_task1.Task2(idx_case) = results_t2_2nd.Task2(i);
%     end
% end
% 
% % Salva il file finale
% writetable(results_task1, 'results.csv');
% 
