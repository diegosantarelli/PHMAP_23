% Lista dei sensori
sensors = {'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7'};

% Palette di colori
sensor_colors = [ 
    0.85, 0.33, 0.10; % P1 - Rosso scuro
    0.93, 0.69, 0.13; % P2 - Giallo ocra
    0.47, 0.67, 0.19; % P3 - Verde prato
    0.30, 0.74, 0.93; % P4 - Azzurro brillante
    0.50, 0.40, 0.90; % P5 - Blu-violetto
    0.00, 0.50, 0.80; % P6 - Blu classico
    0.99, 0.41, 0.23  % P7 - Arancio acceso
];

for s = 1:length(sensors)
    sensor_name = sensors{s};
    
    % Colori più distintivi per Task1=1 e Task1=0
    color_task1_1 = sensor_colors(s, :);       % Più scuro per Task1=1
    color_task1_0 = color_task1_1 + 0.15;      % Più chiaro per Task1=0

    color_task1_0(color_task1_0 > 1) = 1;
    
    figure;
    hold on;
    
    for i = 1:height(labeledData)
        case_data = labeledData.Case{i};
        time = case_data.TIME;
        
        if ismember(sensor_name, case_data.Properties.VariableNames)
            signal = case_data.(sensor_name);
            
            % Calcolo dello spettro di potenza
            Fs = 1 / mean(diff(time), 'omitnan');
            [pxx, f] = pwelch(signal, [], [], [], Fs);
            pxx_dB = 10*log10(pxx); % Conversione in dB
            
            % Selezione colore in base a Task1
            if labeledData.Task1(i) == 1
                plot(f, pxx_dB, 'Color', color_task1_1, 'LineWidth', 1.2);
            else
                plot(f, pxx_dB, 'Color', color_task1_0, 'LineWidth', 1.2);
            end
        end
    end
    
    % Impostazioni del grafico
    set(gca, 'XScale', 'log');
    xlabel('Frequency (Hz)');
    ylabel('Case\_ps/SpectrumData');
    title(['Power Spectrum - ', sensor_name]);

    % Legenda con colori visibili
    legend({'Task1=1', 'Task1=0'}, 'Location', 'northeast', 'TextColor', 'black', 'FontSize', 10);
    
    hold off;
end
