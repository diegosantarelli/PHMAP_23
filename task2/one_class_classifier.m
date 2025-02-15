X_features = normalize(FeatureTable1{:, 3:end}, 'zscore'); % Normalizzazione Z-score

k = 10;
cv = cvpartition(size(X_features, 1), 'KFold', k);

false_negatives_total = 0;
total_samples = 0;

for i = 1:cv.NumTestSets
    X_train = X_features(training(cv, i), :);
    X_val = X_features(test(cv, i), :);
    
    rng(42);
    % Addestra il OCSVM (OutlierFraction 0 perché non ci sono anomalie nel training)
    ocsvm_model = ocsvm(X_train, ...
                    'Nu', 0.4, ...
                    'KernelScale', 1, ...
                    'NumExpansionDimensions', 17000);


    % Predizione sui dati noti di validazione
    isAnomaly = ocsvm_model.isanomaly(X_val);

    % Conta i falsi negativi (cioè i dati noti classificati come anomali)
    false_negatives = sum(isAnomaly == -1);
    false_negatives_total = false_negatives_total + false_negatives;
    total_samples = total_samples + size(X_val, 1);

    fprintf('Fold %d: Falsi negativi = %d su %d campioni\n', i, false_negatives, size(X_val, 1));
end

false_negative_rate = false_negatives_total / total_samples;
fprintf('Tasso di falsi negativi complessivo: %.2f%%\n', false_negative_rate * 100);

% Test su rumore bianco ripetuto più volte
num_samples = 1000;
num_features = size(X_features, 2);
num_tests = 100;

results = zeros(num_tests, 1);
for i = 1:num_tests
    X_noise = randn(num_samples, num_features);
    [isAnomaly_noise, ~] = isanomaly(ocsvm_model, X_noise);
    results(i) = sum(isAnomaly_noise);
end

media_anomalie_rilevate = mean(results);
fprintf('Media anomalie rilevate su rumore bianco (5 prove): %.2f su %d campioni (%.2f%%)\n', ...
        media_anomalie_rilevate, num_samples, media_anomalie_rilevate / num_samples * 100);