function test_set = test_set()

    %% Import delle label
    test_labels = readtable('dataset/test/labels_spacecraft.xlsx', 'VariableNamingRule', 'preserve');
    test_labels.Properties.VariableNames(1:2) = {'Case', 'Spacecraft'};

    %% Import dei dati
    test_folder = 'dataset/test/data';
    test_files = dir(fullfile(test_folder, '*.csv'));

    test_data_table = table();

    for i = 1:length(test_files)
        filename = fullfile(test_folder, test_files(i).name);
        data = readtable(filename);

        case_number = str2double(erase(erase(test_files(i).name, 'Case'), '.csv'));

        label_row = test_labels(test_labels.Case == case_number, :);
        if isempty(label_row)
            error('Etichetta non trovata per il caso %d', case_number);
        end

        test_data_table = [test_data_table; {case_number, data, label_row.Spacecraft, case_number}];
    end

    test_data_table.Properties.VariableNames = {'prova', 'Case', 'Spacecraft', 'Name'};
    test_set = test_data_table(:, {'Name', 'Case', 'Spacecraft'});

end
