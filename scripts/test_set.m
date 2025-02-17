function test_set = test_set()

    %% Import delle label
    test_labels = readtable('dataset/test/labels_spacecraft.xlsx');
    test_labels.Properties.VariableNames(1:2) = {'Case', 'Spacecraft'};

    %% Import dei dati
    test_folder = 'dataset/test/data';
    test_files = dir(fullfile(test_folder, '*.csv'));

    % Inizializza la tabella
    test_data_table = table();

    % Importa i file di TEST e abbina le etichette
    for i = 1:length(test_files)
        % Carica i dati CSV
        filename = fullfile(test_folder, test_files(i).name);
        data = readtable(filename);

        % Estrai il numero del caso dal nome del file
        case_number = str2double(erase(erase(test_files(i).name, 'Case'), '.csv'));

        % Trova l'etichetta corrispondente
        label_row = test_labels(test_labels.Case == case_number, :);
        if isempty(label_row)
            error('Etichetta non trovata per il caso %d', case_number);
        end

        % Aggiungi una riga alla tabella aggregata
        test_data_table = [test_data_table; {case_number, data, label_row.Spacecraft}];
    end

    % Aggiunta dei nomi delle colonne
    test_data_table.Properties.VariableNames = {'prova', 'Case', 'Spacecraft'};
    test_set = test_data_table(:, {'Case', 'Spacecraft'});

end
