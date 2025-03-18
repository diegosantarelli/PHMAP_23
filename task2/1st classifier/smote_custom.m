function synthetic_samples = smote_custom(X, num_samples_needed, k)
    % SMOTE personalizzato per generare dati sintetici
    % X: dati della classe minoritaria (matrice N x M)
    % num_samples_needed: numero di campioni sintetici da generare
    % k: numero di vicini più prossimi per generare i campioni
    
    % Trova i k vicini più prossimi usando knnsearch
    Mdl = fitcknn(X, ones(size(X,1),1), 'NumNeighbors', k);
    idx = knnsearch(X, X, 'K', k+1); % Trova i k vicini (compreso se stesso)
    
    % Generazione dei campioni sintetici
    synthetic_samples = zeros(num_samples_needed, size(X, 2));

    % Genera un fattore di rumore casuale
    noise_factor = 0.01 * randn(size(synthetic_samples)); % 1% di rumore
    synthetic_samples = synthetic_samples + noise_factor;
    
    for i = 1:num_samples_needed
        sample_idx = randi(size(X, 1)); % Scegli un campione casuale
        neighbor_idx = idx(sample_idx, randi(k) + 1); % Scegli un vicino casuale (escludendo se stesso)
        
        % Genera il nuovo campione interpolando tra il campione e il vicino
        lambda = rand();
        synthetic_samples(i, :) = X(sample_idx, :) + lambda * (X(neighbor_idx, :) - X(sample_idx, :));
    end
end
