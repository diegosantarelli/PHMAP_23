%% Import delle label
train_labels = readtable('/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/train/labels.xlsx');

train_labels.Properties.VariableNames(1:3) = {'Case#', 'Spacecraft#', 'Condition'};

test_labels = readtable('/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/test/labels_spacecraft.xlsx');

test_labels.Properties.VariableNames(1:2) = {'Case#', 'Spacecraft#'};

%% Import dei dati

train_folder = '/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/train/data';
test_folder = '/Users/diegosantarelli/Desktop/Manutenzione Preventiva/Progetto/dataset/test/data';

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

disp('Dati di training:')
disp(fieldnames(train_data))
disp('Dati di test:')
disp(fieldnames(test_data))

%% Mapping delle label con i dati

train_data_labeled = struct();
train_cases = fieldnames(train_data);

for i = 1:length(train_cases)
    case_name = train_cases{i}; % Ottieni il nome del caso (ad esempio, 'Case001')
    
    % Ottieni i dati per questo caso
    data = train_data.(case_name);
    
    % Trova l'etichetta corrispondente
    case_number = str2double(erase(case_name, 'Case')); % Converte il nome in numero
    label = train_labels(train_labels.('Case#') == case_number, :);
    
    % Salva i dati e l'etichetta nella nuova struttura
    train_data_labeled.(case_name).data = data;
    train_data_labeled.(case_name).label = label;
end

test_data_labeled = struct();
test_cases = fieldnames(test_data); % Ottieni i nomi dei casi di test

for i = 1:length(test_cases)
    case_name = test_cases{i}; % Ottieni il nome del caso (ad esempio, 'Case178')
    
    % Ottieni i dati per questo caso
    data = test_data.(case_name);
    
    % Trova l'etichetta corrispondente
    case_number = str2double(erase(case_name, 'Case')); % Converte il nome in numero
    label = test_labels(test_labels.('Case#') == case_number, :);
    
    % Salva i dati e l'etichetta nella nuova struttura
    test_data_labeled.(case_name).data = data;
    test_data_labeled.(case_name).label = label;
end