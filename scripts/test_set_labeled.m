function test_set_labeled = test_set_labeled()   
    %% Import delle label
    final_test_labels = readtable('dataset/test/answer.csv');
    final_test_labels.Properties.VariableNames(2:3) = {'Name', 'Task1'};
    final_test_labels = final_test_labels(:, {'Name', 'Task1'});
    final_test_labels.Name = "Case" + string(final_test_labels.Name);
    
    %% Import dei dati
    test_folder = 'dataset/test/data';
    test_files = dir(fullfile(test_folder, '*.csv'));
    
    % Inizializza la tabella finale
    test_set_task1_labeled = table();
    
    % Importa i file di TEST e abbina le etichette
    for i = 1:length(test_files)
        % Carica i dati CSV
        filename = fullfile(test_folder, test_files(i).name);
        data = readtable(filename);
    
        % Estrai il numero del caso dal nome del file
        case_number = str2double(erase(erase(test_files(i).name, 'Case'), '.csv'));
    
        % Costruisci il nome del case
        case_name = "Case" + string(case_number);
    
        % Trova l'etichetta corrispondente
        label_row = final_test_labels(final_test_labels.Name == case_name, :);
        if isempty(label_row)
            error('Etichetta non trovata per il caso %s', case_name);
        end
    
        % Aggiungi una riga alla tabella aggregata
        test_set_task1_labeled = [test_set_task1_labeled; {data, case_name, label_row.Task1}];
    end
    
    % Dai i nomi alle colonne della tabella finale
    test_set_task1_labeled.Properties.VariableNames = {'Case', 'Name', 'Task1'};

    % Assegna il risultato all'output della funzione
    test_set_labeled = test_set_task1_labeled;
end
