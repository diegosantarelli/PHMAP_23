% Estrai solo le righe con Task2 uguale a 2 o 3
mask_bubble_valve = (labeledData.Task2 == 2) | (labeledData.Task2 == 3);

% Filtra la tabella
training_data_t2 = labeledData(mask_bubble_valve, :);

training_data_t2 = training_data_t2(:, {'Case', 'Task2'});
