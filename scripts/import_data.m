%% Import delle label
train_labels = readtable('dataset/train/labels.xlsx', 'VariableNamingRule', 'preserve');
train_labels.Properties.VariableNames(1:3) = {'Case', 'Spacecraft', 'Condition'};

% Trasforma 'Yes'/'No' in 1/0
train_labels.BP1 = double(strcmp(train_labels.BP1, 'Yes'));
train_labels.BP2 = double(strcmp(train_labels.BP2, 'Yes'));
train_labels.BP3 = double(strcmp(train_labels.BP3, 'Yes'));
train_labels.BP4 = double(strcmp(train_labels.BP4, 'Yes'));
train_labels.BP5 = double(strcmp(train_labels.BP5, 'Yes'));
train_labels.BP6 = double(strcmp(train_labels.BP6, 'Yes'));
train_labels.BP7 = double(strcmp(train_labels.BP7, 'Yes'));
train_labels.BV1 = double(strcmp(train_labels.BV1, 'Yes'));

%% Import dei dati

train_folder = 'dataset/train/data';
train_files = dir(fullfile(train_folder, '*.csv'));

% Crea la tabella finale
labeledData = table();

% Identificatore autoincrementale
id_counter = 1;

% Etichettatura per i task e creazione delle sottotabelle
for i = 1:length(train_files)
    % Nome del caso nel file
    case_name_file = erase(train_files(i).name, '.csv'); % Nome del file senza estensione
    
    % Confronto con la tabella delle label
    % Assumi che train_labels.Case contenga numeri, quindi convertilo in formato "Case001"
    case_id = sprintf('Case%03d', train_labels.Case(i)); % Converte in formato "Case001"
    
    % Controllo diretto del confronto
    if ~strcmp(case_name_file, case_id)
        error(['Il nome del caso non corrisponde: ', case_name_file, ' vs ', case_id]);
    end
    
    % Trova la condizione associata nella tabella delle label
    condition = train_labels.Condition{i};
    
    %% Etichettatura per Task 1
    if strcmp(condition, 'Normal')
        task1_label = 0; % Situazione normale
    elseif strcmp(condition, 'Fault') || strcmp(condition, 'Anomaly')
        task1_label = 1; % Situazione anormale
    else
        error(['Condizione sconosciuta per il caso: ', case_id]);
    end
    
    %% Etichettatura per Task 2
    if strcmp(condition, 'Fault')
        task2_label = 3; % Solenoid Valve Fault
    elseif strcmp(condition, 'Anomaly')
        task2_label = 2; % Bubble Contamination
    else
        task2_label = 0; % Normal
    end

    %% Etichettatura per Task 3
    sv_cols = {'SV1', 'SV2', 'SV3', 'SV4'};
    bp_cols = {'BV1', 'BP1', 'BP2', 'BP3', 'BP4', 'BP5', 'BP6', 'BP7'};
    
    sv_values = train_labels{i, sv_cols}; % Valori di SV
    bp_values = train_labels{i, bp_cols}; % Valori di BP

    if task2_label == 2 % Solo per Bubble Anomalies
        if train_labels.BV1(i) == 1 && all(train_labels{i, bp_cols} == 0)
            task3_label = 8; % Bolla in BV1
        else
            bp_position = find([train_labels.BP1(i), train_labels.BP2(i), train_labels.BP3(i), ...
                                train_labels.BP4(i), train_labels.BP5(i), train_labels.BP6(i), ...
                                train_labels.BP7(i)] == 1);
            if ~isempty(bp_position) && length(bp_position) == 1
                task3_label = bp_position; % Bolla in BP1 - BP7
            else
                task3_label = 0; % Non identificabile o normale
            end
        end
    else
        task3_label = 0; % Normal e Valve Fault
    end
    
    % Etichettatura per Task 4
    if task2_label == 3 % Solo per Valve Fault
        sv_fault = find(sv_values ~= 100); % Valvole con fault
        if ~isempty(sv_fault) && length(sv_fault) == 1 && all(sv_values(setdiff(1:4, sv_fault)) == 100)
            task4_label = sv_fault; % Fault in SV1, SV2, SV3 o SV4
        else
            task4_label = 0; % Non identificabile o normale
        end
    else
        task4_label = 0; % Non Valve Fault
    end
    
    % Etichettatura per Task 5
    if task4_label >= 1 && task4_label <= 4 % Fault in SV1-SV4
        task5_label = sv_values(task4_label); % Percentuale di apertura della valvola con fault
    else
        task5_label = 100; % Normal e Bubble Fault
    end
    
    % Carica i dati del file corrente
    filename = fullfile(train_folder, train_files(i).name);
    tbl = readtable(filename);
    
    % Crea la sottotabella con i dati del caso corrente
    sub_table = tbl; % Include tutte le colonne, puoi ridurre alle necessarie
    
    % Assegna un identificativo autoincrementale
    name_id = id_counter;
    id_counter = id_counter + 1;
    
    % Crea una riga della tabella finale
    new_row = table(name_id, {sub_table}, task1_label, task2_label, task3_label, task4_label, task5_label, ...
                    'VariableNames', {'Name', 'Case', 'Task1', 'Task2', 'Task3', 'Task4', 'Task5'});
    
    % Aggiungi la riga alla tabella finale
    labeledData = [labeledData; new_row];
end
