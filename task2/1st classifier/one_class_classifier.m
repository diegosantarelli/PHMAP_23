training_data_task2;

% Generazione delle feature utilizzando la tua funzione
[featureTable_t2_1st, ~] = feature_gen_t2_1st(training_set_task2);

%%
% Supponiamo che featureTable_t2_1st sia stato generato correttamente
X_train = featureTable_t2_1st{:, 3:end}; % Supponiamo che le prime due colonne siano MemberID e Task2

% K-fold Cross Validation per i dati noti (Task2 = 4)
cv = cvpartition(size(X_train, 1), 'KFold', 5);
kfold_results = zeros(size(X_train, 1), 1);

for i = 1:cv.NumTestSets
    trainIdx = cv.training(i);
    testIdx = cv.test(i);

    % Addestramento OCSVM su k-1 fold
    model = ocsvm(X_train, StandardizeData=true, KernelScale="auto");

    % Predizione sul fold di test
    score = anomalyScore(model, X_train(testIdx, :));
    kfold_results(testIdx) = isanomaly(score);


end

% Verifica falsi positivi (dati noti classificati come anomaly)
falsi_positivi = sum(kfold_results == 1);
disp(['Falsi positivi sui dati noti: ', num2str(falsi_positivi)]);

% %%
% % Generazione di dati di rumore bianco
% numSamples = 50; % Numero di campioni di rumore bianco
% numFeatures = size(X_train, 2);
% X_noise = randn(numSamples, numFeatures);
% 
% % Addestramento modello finale su tutto il training set
% ocsvmModel = fitcsvm(X_train, 'KernelFunction', 'rbf', 'Standardize', true, 'Nu', 0.5);
% ocsvmModel = fitSVMPosterior(ocsvmModel);
% 
% % Predizione sul rumore bianco
% [~, score_noise] = predict(ocsvmModel, X_noise);
% pred_noise = isanomaly(score_noise(:, 1));
% anomalie_rumore_bianco = sum(pred_noise == 1);
% disp(['Anomalie rilevate nel rumore bianco: ', num2str(anomalie_rumore_bianco)]);

