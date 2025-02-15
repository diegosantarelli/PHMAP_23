import_data;

test_set_task1 = test_set_task1();

test_set_task1.Task1 = NaN(height(test_set_task1), 1);

[featureTable_test, ~] = featureGenerationT1(test_set_task1);

load('task1/results/MODELLO_FINALE.mat', 'baggedTreesTask1');

% Predizione sui dati di test
[yfit, scores] = baggedTreesTask1.predictFcn(featureTable_test);

% Associa i Member X ai Case 178, 179, ...
member_to_case = 177 + (1:max(str2double(erase(featureTable_test.EnsembleID_, 'Member '))));

% Estrai i Member X e li mappa ai Case reali
member_numbers = str2double(erase(featureTable_test.EnsembleID_, 'Member '));
case_ids_num = member_to_case(member_numbers);

members_results_table = table(featureTable_test.EnsembleID_(:), case_ids_num(:), yfit(:), ...
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

% Creazione tabella nel formato richiesto
results_table = table(case_ids_final_str, yfit_final, ...
    'VariableNames', {'Case', 'Task1'});

% Salva il CSV
writetable(results_table, 'results.csv');