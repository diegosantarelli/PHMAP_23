%% 1. Separazione dei dati in "conosciuti" (Bubble e Valve) e "candidati sconosciuti" (Unknown)
% Dati noti con Task2 == 2 (Bubble) o Task2 == 3 (Valve)
knownData_t2 = FeatureTable1(FeatureTable1.Task2 == 2 | FeatureTable1.Task2 == 3, :);

% Dati etichettati come unknown generati da outlier localized (Task2 == 1)
unknownCandidates_t2 = FeatureTable1(FeatureTable1.Task2 == 1, :);

%% 2. Estrazione delle feature (escludiamo MemberID, TimeStart, TimeEnd e Task2)
features = FeatureTable1(:, 5:end-1); % Prende tutte le colonne delle feature
X_train_OCSVM = knownData_t2(:, 5:end-1); % Le feature dei dati noti
X_train_OCSVM = table2array(X_train_OCSVM);

X_test_OCSVM = unknownCandidates_t2(:, 5:end-1);
X_test_OCSVM = table2array(X_test_OCSVM);

%% 3. Addestramento del modello One-Class SVM
mdl_OCSVM = fitcsvm(X_train_OCSVM, ones(size(X_train_OCSVM, 1), 1), ...
    'KernelScale', 'auto', 'OutlierFraction', 0.05, 'Standardize', true, ...
    'KernelFunction', 'rbf');

%% 4. Predizione dei candidati unknown (frame per frame)
[~, score_OCSVM] = predict(mdl_OCSVM, X_test_OCSVM);
threshold = 0; % Modifica se serve
isUnknown = score_OCSVM > threshold;

% Aggiorna i frame con Task2 = 0 o 1 a seconda del risultato OCSVM
predictedLabels = ones(height(unknownCandidates_t2), 1); % Default: Unknown
predictedLabels(~isUnknown) = 0;

unknownCandidates_t2.Task2 = predictedLabels;

%% 5. Aggregazione per EnsembleID_ (votazione per ogni Member)
members = unique(unknownCandidates_t2.EnsembleID_);
finalLabels = zeros(length(members), 1);

for i = 1:length(members)
    memberFrames = unknownCandidates_t2(strcmp(unknownCandidates_t2.EnsembleID_, members{i}), :);
    if any(memberFrames.Task2 == 1)
        finalLabels(i) = 1; % Se almeno un frame è unknown, etichetta tutto il Member come unknown
    else
        finalLabels(i) = 0;
    end
end

%% 6. Creazione tabella finale per ogni Member
unknownSummary = table(members, finalLabels, 'VariableNames', {'EnsembleID_', 'Task2'});

% Anche per i dati noti, li riportiamo per Member (Bubble e Valve)
knownSummary = unique(knownData_t2(:, {'EnsembleID_', 'Task2'}));

%% 7. Unione dei risultati
task2_finalMembers = [knownSummary; unknownSummary];

%% 8. Visualizza il riepilogo
disp('Distribuzione delle etichette Task2 dopo One-Class Classification (Aggregata per Member):');
tabulate(task2_finalMembers.Task2);
