knownData_t2 = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, :);
normalData_t2 = labeledData(labeledData.Task2 == 0, :);

%% Generation of unknown conditions with localized outliers

unknownData_t2 = normalData_t2;  % Copia i dati normali
for i = 1:height(unknownData_t2)
    caseData = unknownData_t2.Case{i};
    num_outliers = 5;  % Numero di picchi casuali da inserire
    indices = randi(height(caseData), num_outliers, 1);
    caseData{indices, 2:end} = caseData{indices, 2:end} + 5;  % Aggiungi picchi di ampiezza 5
    unknownData_t2.Case{i} = caseData;
    unknownData_t2.Task2(i) = 1;  % Etichetta come Unknown Condition
end

task2_finalData = [knownData_t2; unknownData_t2];
task2_finalData = task2_finalData(:, {'Case', 'Task2'});