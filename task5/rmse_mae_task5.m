task5;

%%
% **Caricamento delle etichette reali dal file answer.csv**
test_set_labeled_t5 = readtable('dataset/test/answer.csv', 'VariableNamingRule', 'preserve');

% **Rinominare la colonna 'ID' in 'Case' e trasformare i valori in 'CaseXXX'**
test_set_labeled_t5.Case = strcat('Case', string(test_set_labeled_t5.ID));

% **Mantenere solo le colonne 'Case' e 'task5' (etichette reali)**
test_set_labeled_t5 = test_set_labeled_t5(:, {'Case', 'task5'});

% **Rinominare la colonna 'task5' per uniformità con il codice precedente**
test_set_labeled_t5.Properties.VariableNames = {'Case', 'CaseLabel_test_set_labeled_t5'};

%%
% **Caricamento delle previsioni dal file results.csv**
results_t5 = readtable('results.csv', 'VariableNamingRule', 'preserve');

% **Mantenere solo le colonne 'Case' e 'Task5' (previsioni del modello)**
results_t5 = results_t5(:, {'Case', 'Task5'});

% **Rinominare la colonna 'Task5' per chiarezza**
results_t5.Properties.VariableNames = {'Case', 'CaseLabel_results_t5'};

%%
% **Unire le tabelle per confronto (solo Case presenti in entrambi i dataset)**
merged_table_t5 = innerjoin(results_t5, test_set_labeled_t5, 'Keys', 'Case');

% **Estrarre i valori reali e predetti**
y_true = merged_table_t5.CaseLabel_test_set_labeled_t5;  % Valori reali
y_pred = merged_table_t5.CaseLabel_results_t5;           % Valori predetti

%%
% **Calcolare RMSE (Root Mean Squared Error)**
rmse_t5 = sqrt(mean((y_true - y_pred).^2));

% **Calcolare MAE (Mean Absolute Error)**
mae_t5 = mean(abs(y_true - y_pred));

%%
% **Visualizzare i risultati**
disp(['RMSE del quinto task: ', num2str(rmse_t5)]);
disp(['MAE del quinto task: ', num2str(mae_t5)]);
