clc;

%% Import dei dati
disp('Importazione dati...');
import_data; % Assicurati che questo carichi i dati necessari
disp('Dati importati correttamente.');

%% Esecuzione dei task cascata
disp('Avvio Task1...');
task1_final;
disp('Task1 completato! Ora avvio Task2_1st.');

disp('Avvio Task2_1st...');
task2_1st;
disp('Task2_1st completato! Ora avvio Task2_2nd.');

disp('Avvio Task2_2nd...');
task2_2nd;
disp('Task2_2nd completato! Ora avvio Task3.');

disp('Avvio Task3...');
task3;
disp('Task3 completato! Ora avvio Task4.');

disp('Avvio Task4...');
task4;
disp('Task4 completato! Ora avvio Task5.');

disp('Avvio Task5...');
task5;
disp('Task5 completato! Tutti i task sono stati eseguiti con successo.');

%% Accuratezze

accuracy_task1;
accuracy_task2_1st;
accuracy_task2_2nd;
accuracy_task3;
accuracy_task4;
rmse_mae_task5;

%% Caricamento risultati
results = readtable('results.csv', 'VariableNamingRule', 'preserve');  % File con le predizioni
answers = readtable('answer.csv', 'VariableNamingRule', 'preserve');   % File con i valori reali

% Verifica se i file contengono dati validi
if isempty(results) || isempty(answers)
    error('Errore: uno dei file results.csv o answer.csv è vuoto o non valido.');
end

% Unire i dati usando la colonna "Case" di results e "ID" di answers
data = innerjoin(results, answers, 'LeftKeys', 'Case', 'RightKeys', 'ID');

% Estrarre colonne corrette
task1_pred = data.Task1;
task1_real = data.task1;

task2_pred = data.Task2;
task2_real = data.task2;

task3_pred = data.Task3;
task3_real = data.task3;

task4_pred = data.Task4;
task4_real = data.task4;

task5_pred = data.Task5;
task5_real = data.task5;

spacecraft_no = data.("Spacecraft No.");

% Inizializzare il punteggio per ogni campione
num_samples = height(data);
score = zeros(num_samples, 1);

%% Assegnazione punteggi
for i = 1:num_samples
    % Task 1: Classificazione normale/anomalo
    if task1_pred(i) == task1_real(i)
        score(i) = score(i) + 10;

        % Task 2: Classificazione tra anomalie (solo se il Task 1 è corretto)
        if task2_pred(i) == task2_real(i)
            score(i) = score(i) + 10;

            % Task 3: Identificazione della posizione della bolla (solo per bubble contamination)
            if task2_real(i) == 2  % 2 = bubble contamination
                if task3_pred(i) == task3_real(i)
                    score(i) = score(i) + 10;
                end
            end

            % Task 4: Identificazione della valvola guasta (solo per valve fault)
            if task2_real(i) == 3  % 3 = solenoid valve fault
                if task4_pred(i) == task4_real(i)
                    score(i) = score(i) + 10;

                    % Task 5: Predizione dell’apertura della valvola
                    task5_score = max(-abs(task5_real(i) - task5_pred(i)) + 20, 0);
                    score(i) = score(i) + task5_score;
                end
            end
        end
    end
end

%% Debugging: Controllo punteggi per ogni campione
% disp('--- Dettaglio punteggi per ogni campione ---');
% disp(table(data.Case, task1_pred, task1_real, task2_pred, task2_real, ...
%     task3_pred, task3_real, task4_pred, task4_real, task5_pred, task5_real, score, ...
%     'VariableNames', {'ID', 'T1_pred', 'T1_real', 'T2_pred', 'T2_real', ...
%     'T3_pred', 'T3_real', 'T4_pred', 'T4_real', 'T5_pred', 'T5_real', 'Score'}));

%% Debugging: Task 5 - Controllo punteggi
% disp('--- Controllo punteggi Task 5 ---');
% disp(table(task5_real, task5_pred, -abs(task5_real - task5_pred) + 20, ...
%     'VariableNames', {'Task5_Real', 'Task5_Pred', 'Task5_Score'}));

%% Raddoppio punteggi per Spacecraft-4
spacecraft4_cases = (spacecraft_no == 4);
score(spacecraft4_cases) = score(spacecraft4_cases) * 2;

% disp('--- Punteggi dopo raddoppio per Spacecraft-4 ---');
% disp(table(data.Case(spacecraft4_cases), score(spacecraft4_cases), ...
%     'VariableNames', {'ID', 'Score_After_Doubling'}));

%% Calcolo punteggio totale
max_per_sample = 50; % Un campione può avere al massimo 50 punti
max_possible_score = num_samples * max_per_sample;
total_score = sum(score);
score_percentage = (total_score / max_possible_score) * 100;

% disp('--- Punteggio massimo ottenuto per campione ---');
% disp(max(score));

%% Stampare il risultato finale
fprintf('--- RISULTATI FINALI DELLA CHALLENGE ---\n');
fprintf('Punteggio Totale: %.2f / %.2f\n', total_score, max_possible_score);
fprintf('Percentuale Punteggio Finale: %.2f%%\n', score_percentage);