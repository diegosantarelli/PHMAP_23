import_data;

test_set_task1_labeled = test_set_labeled();

[featureTable_test_t1labeled, ~] = featureGenerationTask1(test_set_task1_labeled);

load('task1/results/final_model_task1.mat', 'final_model_task1');

% Predizione sui dati di test
[yfit, scores] = final_model_task1.predictFcn(featureTable_test_t1labeled);

% Associa i Member X ai Case 178, 179, ...
member_to_case = 177 + (1:max(str2double(erase(featureTable_test_t1labeled.EnsembleID_, 'Member '))));

% Estrai i Member X e li mappa ai Case reali
member_numbers = str2double(erase(featureTable_test_t1labeled.EnsembleID_, 'Member '));
case_ids_num = member_to_case(member_numbers);

members_results_table = table(featureTable_test_t1labeled.EnsembleID_(:), case_ids_num(:), yfit(:), ...
    'VariableNames', {'Member', 'Case', 'Task1'});

% Voting per maggioranza per ogni case
case_ids_final = unique(case_ids_num);
yfit_final = zeros(size(case_ids_final));

for i = 1:numel(case_ids_final)
    idx = case_ids_num == case_ids_final(i);
    yfit_final(i) = mode(yfit(idx));
end

% Creazione stringa "CaseXXX"
case_ids_final_str = arrayfun(@(x) strcat('Case', num2str(x)), case_ids_final, 'UniformOutput', false);

% Assicurati che siano colonne
case_ids_final_str = case_ids_final_str(:);
yfit_final = yfit_final(:);

% Creazione tabella predizioni finali
predictions_table = table(case_ids_final_str, yfit_final, ...
    'VariableNames', {'Name', 'PredictedTask1'});

% Confronto con etichette reali
results_comparison_table = innerjoin(predictions_table, test_set_task1_labeled(:, {'Name', 'Task1'}), 'Keys', 'Name');

% Calcolo accuratezza
correct_predictions = sum(results_comparison_table.PredictedTask1 == results_comparison_table.Task1);
total_cases = height(results_comparison_table);
accuracy = correct_predictions / total_cases;

fprintf('Accuratezza: %.2f%%\n', accuracy * 100);


% Visualizza i risultati
disp('Accuratezza:');
disp(accuracy);
