function test_set_labeled = test_set_labeled()   
    %% Import delle label
    final_test_labels = readtable('dataset/test/answer.csv');
    final_test_labels.Properties.VariableNames(2:3) = {'Name', 'Task1'};
    final_test_labels = final_test_labels(:, {'Name', 'Task1'});
    final_test_labels.Name = "Case" + string(final_test_labels.Name);
    
    %% Import dei dati
    test_folder = 'dataset/test/data';
    test_files = dir(fullfile(test_folder, '*.csv'));
    
    test_set_task1_labeled = table();
    
    for i = 1:length(test_files)
        filename = fullfile(test_folder, test_files(i).name);
        data = readtable(filename);
    
        case_number = str2double(erase(erase(test_files(i).name, 'Case'), '.csv'));
    
        case_name = "Case" + string(case_number);
    
        label_row = final_test_labels(final_test_labels.Name == case_name, :);
        if isempty(label_row)
            error('Etichetta non trovata per il caso %s', case_name);
        end
    
        test_set_task1_labeled = [test_set_task1_labeled; {data, case_name, label_row.Task1}];
    end
    
    test_set_task1_labeled.Properties.VariableNames = {'Case', 'Name', 'Task1'};

    test_set_labeled = test_set_task1_labeled;
end
