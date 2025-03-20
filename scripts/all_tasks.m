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

%% Prestazioni dei task

accuracy_task1;
accuracy_task2_1st;
accuracy_task2_2nd;
accuracy_task3;
accuracy_task4;
rmse_mae_task5;
