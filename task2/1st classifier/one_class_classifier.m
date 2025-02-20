function [finalModel, falsi_positivi, featureTable_t2_1st, featureTable_test_t2] = one_class_classifier(training_set_task2, test_set, k)
    
    % Generazione delle feature utilizzando la funzione
    [featureTable_t2_1st, ~] = feature_gen_t2_1st(training_set_task2);
    [featureTable_test_t2, ~] = feature_gen_t2_1st(test_set);

    % Supponiamo che le tabelle delle feature siano state generate correttamente
    X_train = featureTable_t2_1st{:, 3:end}; % Supponiamo che le prime due colonne siano EnsembleID_ e Task2
    X_test = featureTable_test_t2{:, 3:end};

    cv = cvpartition(size(X_train, 1), 'KFold', k);
    kfold_results = zeros(size(X_train, 1), 1);

    % Addestramento Isolation Forest con IFOREST su tutto il dataset di training
    finalModel = iforest(X_train, 'NumLearners', 500, 'ContaminationFraction', 0.03);

    for i = 1:cv.NumTestSets
        trainIdx = cv.training(i);
        testIdx = cv.test(i);

        % Predizione sul fold di test (isanomaly restituisce direttamente le etichette)
        [isAnomaly, ~] = isanomaly(finalModel, X_train(testIdx, :));
        kfold_results(testIdx) = isAnomaly; % 1 se anomalia, 0 se normale
    end

    % Verifica falsi positivi (dati noti classificati come anomaly)
    % Falsi positivi: osservazioni normali (anomalie note) che il modello
    % ha classificato erroneamente come anomalie sconosciute
    falsi_positivi = sum(kfold_results == 1);
    disp(['Falsi positivi sui dati noti: ', num2str(falsi_positivi)]);

    % Predizione sul test set esterno
    [isAnomaly_test, ~] = isanomaly(finalModel, X_test);
    disp(['Anomalie rilevate nel test set: ', num2str(sum(isAnomaly_test == 1))]);
end