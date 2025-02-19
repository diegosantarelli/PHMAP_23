% task2_1st;

% Filtra solo i casi con Task2 == 4 da caseLabelTable
filteredCases = results_t2_1st.Case(results_t2_1st.CaseLabel == 4);

training_set_task2_2nd = labeledData(labeledData.Task2 == 2 | labeledData.Task2 == 3, {'Case', 'Task2'});

test_set_task2_2nd = results_t2_1st(results_t2_1st.CaseLabel == 4, {'Case', 'CaseLabel'});


test_raw_data = test_set();

% Aggiungi una colonna vuota per contenere i dati grezzi (come cell array)
test_set_task2_2nd.RawData = cell(height(test_set_task2_2nd), 1);

% Indice iniziale dei Case
startIndex = 178;

% Popola la colonna RawData prendendo i dati grezzi dalla tabella test_raw_data
for i = 1:height(test_set_task2_2nd)
    % Estrai il numero del Case dall'etichetta 'CaseXXX'
    caseNumber = str2double(erase(test_set_task2_2nd.Case{i}, 'Case'));

    % Calcola l'indice della riga corrispondente in test_raw_data
    rawDataIndex = caseNumber - startIndex + 1;

    % Assegna la sottotabella dei dati grezzi
    test_set_task2_2nd.RawData{i} = test_raw_data.Case{rawDataIndex};
end

test_set_task2_2nd.Task2 = NaN(height(test_set_task2_2nd), 1);

test_set_task2_2nd = test_set_task2_2nd(:, {'RawData', 'Task2'});
test_set_task2_2nd.Properties.VariableNames = {'Case', 'Task2'};

[featureTable_test_task2_2nd, ~] = feature_gen_t2_2nd(test_set_task2_2nd);

%% Addestrare un classificatore a distinguere tra Bubble Anomaly e Vaulve Fault
 % utilizzando come training set i 177 case etichettati, filtrando solo per
 % Known Anomaly (etichetta Fault e Anomaly)
 % classificazione tramite codice
