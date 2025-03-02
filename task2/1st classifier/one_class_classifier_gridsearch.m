function [bestModel, bestParams, bestFalsiPositivi, featureTable_t2_1st, featureTable_test_t2] = one_class_classifier_gridsearch(training_set_task2, test_set, k)
    
    % Generazione delle feature
    [featureTable_t2_1st, ~] = feature_gen_t2_1st(training_set_task2); 
    [featureTable_test_t2, ~] = feature_gen_t2_1st(test_set);
    % [featureTable_t2_1st, ~] = prova4_128_VARIANCE(training_set_task2); 
    % [featureTable_test_t2, ~] = prova4_128_VARIANCE(test_set);

    % Trova le colonne da escludere
    columns_to_discard = {'EnsembleID_', 'Task2', 'FRM_1/TimeStart', 'FRM_1/TimeEnd'};
    
    % Seleziona solo le feature numeriche utili
    feature_columns = setdiff(featureTable_t2_1st.Properties.VariableNames, columns_to_discard);
    
    % Estrai solo le colonne corrette
    X_train = featureTable_t2_1st{:, feature_columns};
    X_test = featureTable_test_t2{:, feature_columns};

    % Seed fisso per garantire risultati stabili
    rng(75);
    cv = cvpartition(size(X_train, 1), 'KFold', k);

    % Definizione della griglia di parametri
    numLearnersGrid = [100, 300, 500, 1000];
    contaminationGrid = [0.01, 0.02, 0.03, 0.05];

    % Per memorizzare i risultati
    bestFalsiPositivi = inf;
    bestModel = [];
    bestParams = struct('NumLearners', [], 'ContaminationFraction', []);

    % Loop sui parametri
    for numLearners = numLearnersGrid
        for contamination = contaminationGrid
            disp(['Testando NumLearners=', num2str(numLearners), ', ContaminationFraction=', num2str(contamination)]);

            % Addestramento Isolation Forest con i parametri della griglia
            finalModel = iforest(X_train, 'NumLearners', numLearners, 'ContaminationFraction', contamination);

            % Validazione K-Fold
            kfold_results = zeros(size(X_train, 1), 1);
            for i = 1:cv.NumTestSets
                trainIdx = cv.training(i);
                testIdx = cv.test(i);

                [isAnomaly, ~] = isanomaly(finalModel, X_train(testIdx, :));
                kfold_results(testIdx) = isAnomaly;
            end

            falsi_positivi = sum(kfold_results == 1);
            disp(['Falsi positivi: ', num2str(falsi_positivi)]);

            % Aggiorna il miglior modello se necessario
            if falsi_positivi < bestFalsiPositivi
                bestFalsiPositivi = falsi_positivi;
                bestModel = finalModel;
                bestParams.NumLearners = numLearners;
                bestParams.ContaminationFraction = contamination;
            end
        end
    end

    % Predizione sul test set esterno con il miglior modello trovato
    [isAnomaly_test, ~] = isanomaly(bestModel, X_test);
    disp(['Anomalie rilevate nel test set (miglior modello): ', num2str(sum(isAnomaly_test == 1))]);

    disp(['Miglior NumLearners: ', num2str(bestParams.NumLearners)]);
    disp(['Miglior ContaminationFraction: ', num2str(bestParams.ContaminationFraction)]);
end