% Percentuale di dati da utilizzare per il test set
testPercentage = 20; % 20% dei dati per il test set

% Seleziona il campo target su cui effettuare la divisione (esempio: Task1)
targetField = 'Task1';

% Prepara i due dataset
trainingSet = table();
testSet = table();

% Trova le classi uniche
uniqueClasses = unique(labeledData.(targetField));

% Per ogni classe, esegui una divisione stratificata
for c = 1:length(uniqueClasses)
    % Filtra i dati per la classe corrente
    classData = labeledData(labeledData.(targetField) == uniqueClasses(c), :);
    
    % Determina il numero di campioni da includere nel test set
    numTestSamples = round(height(classData) * testPercentage / 100);
    
    % Mescola i dati casualmente
    shuffledIndices = randperm(height(classData));
    
    % Seleziona i campioni per il test set
    testIndices = shuffledIndices(1:numTestSamples);
    trainIndices = shuffledIndices(numTestSamples+1:end);
    
    % Aggiungi i campioni ai rispettivi set
    testSet = [testSet; classData(testIndices, :)];
    trainingSet = [trainingSet; classData(trainIndices, :)];
end

% Visualizza il risultato
disp(['Numero di record nel Training Set: ', num2str(height(trainingSet))]);
disp(['Numero di record nel Test Set: ', num2str(height(testSet))]);

