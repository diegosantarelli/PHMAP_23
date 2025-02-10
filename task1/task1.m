% Filtra i casi con Task1 = 0
normal_cases = labeledData(labeledData.Task1 == 0, {'Case', 'Task1'});

% Filtra i casi con Task1 = 1
anomaly_cases = labeledData(labeledData.Task1 == 1, {'Case', 'Task1'});

% Supponiamo di avere due tabelle, table1 e table2
anomaly_cases.Group = repmat({'anomaly_cases'}, height(anomaly_cases), 1); % Aggiungi una colonna per identificare il gruppo
normal_cases.Group = repmat({'normal_cases'}, height(normal_cases), 1);

% Unisci le tabelle
combinedTable = [anomaly_cases; normal_cases];