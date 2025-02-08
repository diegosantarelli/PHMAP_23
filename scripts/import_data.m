%% Import delle label
train_labels = readtable('/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/train/labels.xlsx');
% train_labels = readtable('/Users/andreamarini/Desktop/Manutenzione/dataset/train/labels.xlsx');
% train_labels = readtable('/Users/simonerecinelli/Desktop/Manutenzione Preventiva/dataset/train/labels.xlsx')

train_labels.Properties.VariableNames(1:3) = {'Case', 'Spacecraft', 'Condition'};

test_labels = readtable('/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/test/labels_spacecraft.xlsx');
% test_labels = readtable('/Users/andreamarini/Desktop/Manutenzione/dataset/test/labels_spacecraft.xlsx');
% test_labels = readtable('/Users/simonerecinelli/Desktop/Manutenzione Preventiva/dataset/test/labels_spacecraft.xlsx');

test_labels.Properties.VariableNames(1:2) = {'Case', 'Spacecraft'};

%% Import dei dati

train_folder = '/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/train/data';
% train_folder = '/Users/andreamarini/Desktop/Manutenzione/dataset/train/data';
% train folder = '/Users/simonerecinelli/Desktop/Manutenzione Preventiva/dataset/train/data'
test_folder = '/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/test/data';
% test_folder = '/Users/andreamarini/Desktop/Manutenzione/dataset/test/data';
% test_folder = '/Users/simonerecinelli/Desktop/Manutenzione Preventiva/dataset/test/data'

train_files = dir(fullfile(train_folder, '*.csv'));
test_files = dir(fullfile(test_folder, '*.csv'));

train_data = struct();
test_data = struct();

% Importa i file di TRAINING
for i = 1:length(train_files)
    filename = fullfile(train_folder, train_files(i).name);
    case_name = erase(train_files(i).name, '.csv');

    train_data.(case_name) = readtable(filename);
end

% Importa i file di TEST
for i = 1:length(test_files)
    filename = fullfile(test_folder, test_files(i).name);
    case_name = erase(test_files(i).name, '.csv');
    
    test_data.(case_name) = readtable(filename);
end

% disp('Dati di training:')
% disp(fieldnames(train_data))
% disp('Dati di test:')
% disp(fieldnames(test_data))


%% Creazione timetable dati di training con mappatura delle label

train_table = table(); % Inizializza la tabella vuota

% Scorriamo tutti i Case# in train_labels
for i = 1:height(train_labels)
    case_id = sprintf('%03d', train_labels.('Case')(i)); % Converte in formato "001", "002", ...
    case_name = strcat("Case", case_id); % Crea il nome esatto (es. "Case001")
    
    if isfield(train_data, case_name)
        % Ottieni i dati del caso specifico
        case_data = train_data.(case_name);
        
        % Ottieni la riga corrispondente in train_labels
        label_row = train_labels(i, :); % Prendi tutta la riga con tutte le colonne
        
        % Creiamo una tabella temporanea replicando la riga delle label per ogni riga di dati
        num_rows = height(case_data); % Numero di righe nel file dati
        label_replicated = repmat(label_row, num_rows, 1); % Replica la riga delle label
        
        % Concatena i dati alla tabella finale
        train_table = [train_table; [case_data, label_replicated]];
    end
end

% Seleziona le colonne dei segnali (escludendo il tempo e le label)
signal_columns = {'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7'}; % Aggiungi le tue colonne

% Converti tutti i segnali in formato double
for i = 1:numel(signal_columns)
    train_table.(signal_columns{i}) = double(train_table.(signal_columns{i}));
end

% Converte TIME da millisecondi a secondi e poi in durata
train_table.TIME = seconds(train_table.TIME / 1000);

% Converte la tabella in timetable
train_timetable = table2timetable(train_table, 'RowTimes', train_table.TIME);


disp(train_timetable.Properties.VariableNames)

% Seleziona solo le colonne numeriche che ti interessano
signal_columns = {'TIME', 'P1'}; % Aggiungi altre colonne segnali se necessario
filtered_timetable = train_timetable(:, signal_columns);
filtered_timetable.Properties.VariableNames{'P1'} = 'Signal_P1';
















% %% Mapping delle label con i dati
% 
% train_data_labeled = struct();
% train_cases = fieldnames(train_data);
% 
% for i = 1:length(train_cases)
%     case_name = train_cases{i}; % Ottieni il nome del caso (ad esempio, 'Case001')
% 
%     % Ottieni i dati per questo caso
%     data = train_data.(case_name);
% 
%     % Trova l'etichetta corrispondente
%     case_number = str2double(erase(case_name, 'Case')); % Converte il nome in numero
%     label = train_labels(train_labels.('Case#') == case_number, :);
% 
%     % Salva i dati e l'etichetta nella nuova struttura
%     train_data_labeled.(case_name).data = data;
%     train_data_labeled.(case_name).label = label;
% end
% 
% test_data_labeled = struct();
% test_cases = fieldnames(test_data); % Ottieni i nomi dei casi di test
% 
% for i = 1:length(test_cases)
%     case_name = test_cases{i}; % Ottieni il nome del caso (ad esempio, 'Case178')
% 
%     % Ottieni i dati per questo caso
%     data = test_data.(case_name);
% 
%     % Trova l'etichetta corrispondente
%     case_number = str2double(erase(case_name, 'Case')); % Converte il nome in numero
%     label = test_labels(test_labels.('Case#') == case_number, :);
% 
%     % Salva i dati e l'etichetta nella nuova struttura
%     test_data_labeled.(case_name).data = data;
%     test_data_labeled.(case_name).label = label;
% end
% 
% %% Conversione da struct a table per utilizzare DiagnosticFeatureDesigner
% 
% train_data_table = table(); % Inizializza una tabella vuota
% 
% % Ottieni i nomi dei casi
% case_names = fieldnames(train_data_labeled);
% 
% for i = 1:length(case_names)
%     case_name = case_names{i};
% 
%     % Estrai i dati del caso e le etichette
%     data = train_data_labeled.(case_name).data; % Dati del caso (misurazioni)
%     label = train_data_labeled.(case_name).label; % Etichette (tutte le colonne)
% 
%     % Aggiungi il nome del caso come colonna
%     data.CaseName = repelem({case_name}, height(data), 1); % Nome del caso
% 
%     % Concatena tutte le colonne di `label` a `data`
%     label_table = repelem(label, height(data), 1); % Ripeti le etichette per ogni riga dei dati
%     data = [data, label_table]; % Concatena i dati con le etichette
% 
%     % Concatena il caso alla tabella principale
%     train_data_table = [train_data_table; data];
% end
% 
% % Trasforma 'Yes'/'No' in 1/0
% train_data_table.BP1 = double(strcmp(train_data_table.BP1, 'Yes'));
% train_data_table.BP2 = double(strcmp(train_data_table.BP2, 'Yes'));
% train_data_table.BP3 = double(strcmp(train_data_table.BP3, 'Yes'));
% train_data_table.BP4 = double(strcmp(train_data_table.BP4, 'Yes'));
% train_data_table.BP5 = double(strcmp(train_data_table.BP5, 'Yes'));
% train_data_table.BP6 = double(strcmp(train_data_table.BP6, 'Yes'));
% train_data_table.BP7 = double(strcmp(train_data_table.BP7, 'Yes'));
% train_data_table.BV1 = double(strcmp(train_data_table.BV1, 'Yes'));
% 
% %% Conversione da struct a table per il test set
% 
% test_data_table = table(); % Inizializza una tabella vuota
% 
% % Ottieni i nomi dei casi di test
% case_names = fieldnames(test_data_labeled);
% 
% for i = 1:length(case_names)
%     case_name = case_names{i};
% 
%     % Estrai i dati del caso e le etichette
%     data = test_data_labeled.(case_name).data; % Dati del caso (misurazioni)
%     label = test_data_labeled.(case_name).label; % Etichette (tutte le colonne)
% 
%     % Aggiungi il nome del caso come colonna
%     data.CaseName = repelem({case_name}, height(data), 1); % Nome del caso
% 
%     % Concatena tutte le colonne di `label` a `data`
%     label_table = repelem(label, height(data), 1); % Ripeti le etichette per ogni riga dei dati
%     data = [data, label_table]; % Concatena i dati con le etichette
% 
%     % Concatena il caso alla tabella principale
%     test_data_table = [test_data_table; data];
% end
% 
% %% Mapping etichette
% 
% %
% %   NORMAL = condizione normale
% %   FAULT = guasto alla valvola (SV1, SV2, SV3, SV4)
% %   ANOMALY = presenza bolla (BV1, BP1, BP2, BP3, BP4, BP5, BP6, BP7)
% %
% 
% 
% % Mappa le condizioni da stringa a valore numerico
% condition_map = containers.Map({'Normal', 'Fault', 'Anomaly'}, [1, 2, 3]);
% 
% train_data_table_condition = train_data_table; % Inizializza una tabella vuota
% 
% train_data_table_condition.Condition = cellfun(@(x) condition_map(x), train_data_table.Condition);
% 
% class(train_data_table_condition.P1)
% 
% 
% % Funzione per la conversione delle condizioni
% map_condition = @(value) (value == 1) * 0 + ismember(value, [2, 3]) * 1;
% 
% % Converti le etichette di train
% train_data_table.Condition = cellfun(@(x) condition_map(x), train_data_table.Condition);
% train_data_table.Condition = arrayfun(map_condition, train_data_table.Condition);
% 
% % % Converti le etichette di test
% % test_data_table.Condition = cellfun(@(x) condition_map(x), test_data_table.Condition);
% % test_data_table.binary_condition = arrayfun(map_condition, test_data_table.Condition);
% 
% % Definisci le colonne da mantenere
% columns_to_keep = {'TIME', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'Condition'};
% 
% % Crea una nuova tabella con solo queste colonne
% new_table = train_data_table_condition(:, columns_to_keep);
