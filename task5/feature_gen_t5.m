function [featureTable,outputTable] = feature_gen_t5(inputData)
%DIAGNOSTICFEATURES recreates results in Diagnostic Feature Designer.
%
% Input:
%  inputData: A table or a cell array of tables/matrices containing the
%  data as those imported into the app.
%
% Output:
%  featureTable: A table containing all features and condition variables.
%  outputTable: A table containing the computation results.
%
% This function computes spectra:
%  Case_ps/SpectrumData
%  Case_ps_1/SpectrumData
%  Case_ps_2/SpectrumData
%  Case_ps_5/SpectrumData
%  Case_ps_6/SpectrumData
%
% This function computes features:
%  Case_sigstats/ClearanceFactor
%  Case_sigstats/CrestFactor
%  Case_sigstats/ImpulseFactor
%  Case_sigstats/PeakValue
%  Case_sigstats/RMS
%  Case_sigstats/ShapeFactor
%  Case_sigstats/Std
%  Case_sigstats/THD
%  Case_sigstats_1/ClearanceFactor
%  Case_sigstats_1/CrestFactor
%  Case_sigstats_1/ImpulseFactor
%  Case_sigstats_1/Kurtosis
%  Case_sigstats_1/PeakValue
%  Case_sigstats_1/ShapeFactor
%  Case_sigstats_1/Std
%  Case_sigstats_2/ClearanceFactor
%  Case_sigstats_2/CrestFactor
%  Case_sigstats_2/ImpulseFactor
%  Case_sigstats_2/PeakValue
%  Case_sigstats_2/RMS
%  Case_sigstats_2/ShapeFactor
%  Case_sigstats_2/Std
%  Case_sigstats_2/THD
%  Case_sigstats_3/Mean
%  Case_sigstats_3/RMS
%  Case_sigstats_3/ShapeFactor
%  Case_sigstats_3/Std
%  Case_sigstats_4/ClearanceFactor
%  Case_sigstats_4/CrestFactor
%  Case_sigstats_4/ImpulseFactor
%  Case_sigstats_4/Mean
%  Case_sigstats_4/PeakValue
%  Case_sigstats_4/ShapeFactor
%  Case_sigstats_4/Std
%  Case_sigstats_5/SNR
%  Case_sigstats_5/ShapeFactor
%  Case_sigstats_5/Std
%  Case_sigstats_6/RMS
%  Case_sigstats_6/ShapeFactor
%  Case_sigstats_6/Skewness
%  Case_sigstats_6/Std
%  Case_ps_spec/PeakAmp2
%  Case_ps_spec/PeakAmp3
%  Case_ps_spec/PeakFreq4
%  Case_ps_1_spec/PeakFreq1
%  Case_ps_2_spec/PeakAmp2
%  Case_ps_2_spec/PeakAmp5
%  Case_ps_2_spec/PeakFreq2
%  Case_ps_5_spec/PeakAmp2
%  Case_ps_5_spec/PeakAmp3
%  Case_ps_5_spec/PeakFreq2
%  Case_ps_6_spec/PeakAmp3
%  Case_ps_6_spec/PeakFreq2
%
% Frame Policy:
%  Frame name: FRM_1
%  Frame size: 0.256 seconds
%  Frame rate: 0.256 seconds
%
% Organization of the function:
% 1. Compute signals/spectra/features
% 2. Extract computed features into a table
%
% Modify the function to add or remove data processing, feature generation
% or ranking operations.

% Auto-generated by MATLAB on 01-Mar-2025 11:23:34

% Create output ensemble.
outputEnsemble = workspaceEnsemble(inputData,'DataVariables',"Case",'ConditionVariables',"Task5");

% Reset the ensemble to read from the beginning of the ensemble.
reset(outputEnsemble);

% Append new frame policy name to DataVariables.
outputEnsemble.DataVariables = [outputEnsemble.DataVariables;"FRM_1"];

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = "Case";

% Initialize a cell array to store all the results.
allMembersResult = {};

% Loop through all ensemble members to read and write data.
while hasdata(outputEnsemble)
    % Read one member.
    member = read(outputEnsemble);

    % Read signals.
    Case_full = readMemberData(member,"Case",["TIME","P5","P1","P2","P3","P4","P6","P7"]);

    % Get the frame intervals.
    lowerBound = Case_full.TIME(1);
    upperBound = Case_full.TIME(end);
    fullIntervals = frameintervals([lowerBound upperBound],0.256,0.256,'FrameUnit',"seconds");
    intervals = fullIntervals;

    % Initialize a table to store frame results.
    frames = table;

    % Loop through all frame intervals and compute results.
    for ct = 1:height(intervals)
        % Get all input variables.
        Case = Case_full(Case_full.TIME>=intervals{ct,1}&Case_full.TIME<intervals{ct,2},:);

        % Initialize a table to store results for one frame interval.
        frame = intervals(ct,:);

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P5;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,PeakValue,RMS,ShapeFactor,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','PeakValue','RMS','ShapeFactor','Std','THD'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,8);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','PeakValue','RMS','ShapeFactor','Std','THD'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats},'VariableNames',{'Case_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P1;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            PeakValue = max(abs(inputSignal));
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,PeakValue,ShapeFactor,Std];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','PeakValue','ShapeFactor','Std'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,7);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','PeakValue','ShapeFactor','Std'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_1},'VariableNames',{'Case_sigstats_1'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P2;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,PeakValue,RMS,ShapeFactor,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','PeakValue','RMS','ShapeFactor','Std','THD'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,8);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','PeakValue','RMS','ShapeFactor','Std','THD'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_2},'VariableNames',{'Case_sigstats_2'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P3;
            Mean = mean(inputSignal,'omitnan');
            RMS = rms(inputSignal,'omitnan');
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [Mean,RMS,ShapeFactor,Std];

            % Store computed features in a table.
            featureNames = {'Mean','RMS','ShapeFactor','Std'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,4);
            featureNames = {'Mean','RMS','ShapeFactor','Std'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_3},'VariableNames',{'Case_sigstats_3'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P4;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Mean,PeakValue,ShapeFactor,Std];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Mean','PeakValue','ShapeFactor','Std'};
            Case_sigstats_4 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,7);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Mean','PeakValue','ShapeFactor','Std'};
            Case_sigstats_4 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_4},'VariableNames',{'Case_sigstats_4'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P6;
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [SNR,ShapeFactor,Std];

            % Store computed features in a table.
            featureNames = {'SNR','ShapeFactor','Std'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'SNR','ShapeFactor','Std'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_5},'VariableNames',{'Case_sigstats_5'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P7;
            RMS = rms(inputSignal,'omitnan');
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [RMS,ShapeFactor,Skewness,Std];

            % Store computed features in a table.
            featureNames = {'RMS','ShapeFactor','Skewness','Std'};
            Case_sigstats_6 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,4);
            featureNames = {'RMS','ShapeFactor','Skewness','Std'};
            Case_sigstats_6 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_6},'VariableNames',{'Case_sigstats_6'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P5;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,20,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps = ps;
        catch
            Case_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps},'VariableNames',{'Case_ps'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P1;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,20,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_1 = ps;
        catch
            Case_ps_1 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_1},'VariableNames',{'Case_ps_1'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P2;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,20,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_2 = ps;
        catch
            Case_ps_2 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_2},'VariableNames',{'Case_ps_2'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P6;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,20,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_5 = ps;
        catch
            Case_ps_5 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_5},'VariableNames',{'Case_ps_5'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P7;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,20,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_6 = ps;
        catch
            Case_ps_6 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_6},'VariableNames',{'Case_ps_6'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps.SpectrumData;
            w = Case_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*1.59154943091895e-05) & (w<=factor*500.000000000055);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',5);
            peakAmp = [peakAmp(:); NaN(5-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(5-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp2 = peakAmp(2);
            PeakAmp3 = peakAmp(3);
            PeakFreq4 = peakFreq(4);

            % Concatenate signal features.
            featureValues = [PeakAmp2,PeakAmp3,PeakFreq4];

            % Store computed features in a table.
            featureNames = {'PeakAmp2','PeakAmp3','PeakFreq4'};
            Case_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp2','PeakAmp3','PeakFreq4'};
            Case_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_spec},'VariableNames',{'Case_ps_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_1.SpectrumData;
            w = Case_ps_1.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*1.59154943091895e-05) & (w<=factor*500.000000000055);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',5);
            peakAmp = [peakAmp(:); NaN(5-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(5-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakFreq1 = peakFreq(1);

            % Concatenate signal features.
            featureValues = PeakFreq1;

            % Store computed features in a table.
            featureNames = {'PeakFreq1'};
            Case_ps_1_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'PeakFreq1'};
            Case_ps_1_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_1_spec},'VariableNames',{'Case_ps_1_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_2.SpectrumData;
            w = Case_ps_2.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*1.59154943091895e-05) & (w<=factor*500.000000000055);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',5);
            peakAmp = [peakAmp(:); NaN(5-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(5-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp2 = peakAmp(2);
            PeakAmp5 = peakAmp(5);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp2,PeakAmp5,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp2','PeakAmp5','PeakFreq2'};
            Case_ps_2_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp2','PeakAmp5','PeakFreq2'};
            Case_ps_2_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_2_spec},'VariableNames',{'Case_ps_2_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_5.SpectrumData;
            w = Case_ps_5.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*1.59154943091895e-05) & (w<=factor*500.000000000055);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',5);
            peakAmp = [peakAmp(:); NaN(5-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(5-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp2 = peakAmp(2);
            PeakAmp3 = peakAmp(3);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp2,PeakAmp3,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp2','PeakAmp3','PeakFreq2'};
            Case_ps_5_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp2','PeakAmp3','PeakFreq2'};
            Case_ps_5_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_5_spec},'VariableNames',{'Case_ps_5_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_6.SpectrumData;
            w = Case_ps_6.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*1.59154943091895e-05) & (w<=factor*500.000000000055);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',5);
            peakAmp = [peakAmp(:); NaN(5-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(5-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp3 = peakAmp(3);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp3,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp3','PeakFreq2'};
            Case_ps_6_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'PeakAmp3','PeakFreq2'};
            Case_ps_6_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_6_spec},'VariableNames',{'Case_ps_6_spec'})];

        %% Concatenate frames.
        frames = [frames;frame]; %#ok<*AGROW>
    end
    % Append all member results to the cell array.
    memberResult = table({frames},'VariableNames',"FRM_1");
    allMembersResult = [allMembersResult; {memberResult}]; %#ok<AGROW>
end

% Write the results for all members to the ensemble.
writeToMembers(outputEnsemble,allMembersResult)

% Gather all features into a table.
selectedFeatureNames = ["FRM_1/Case_sigstats/ClearanceFactor","FRM_1/Case_sigstats/CrestFactor","FRM_1/Case_sigstats/ImpulseFactor","FRM_1/Case_sigstats/PeakValue","FRM_1/Case_sigstats/RMS","FRM_1/Case_sigstats/ShapeFactor","FRM_1/Case_sigstats/Std","FRM_1/Case_sigstats/THD","FRM_1/Case_sigstats_1/ClearanceFactor","FRM_1/Case_sigstats_1/CrestFactor","FRM_1/Case_sigstats_1/ImpulseFactor","FRM_1/Case_sigstats_1/Kurtosis","FRM_1/Case_sigstats_1/PeakValue","FRM_1/Case_sigstats_1/ShapeFactor","FRM_1/Case_sigstats_1/Std","FRM_1/Case_sigstats_2/ClearanceFactor","FRM_1/Case_sigstats_2/CrestFactor","FRM_1/Case_sigstats_2/ImpulseFactor","FRM_1/Case_sigstats_2/PeakValue","FRM_1/Case_sigstats_2/RMS","FRM_1/Case_sigstats_2/ShapeFactor","FRM_1/Case_sigstats_2/Std","FRM_1/Case_sigstats_2/THD","FRM_1/Case_sigstats_3/Mean","FRM_1/Case_sigstats_3/RMS","FRM_1/Case_sigstats_3/ShapeFactor","FRM_1/Case_sigstats_3/Std","FRM_1/Case_sigstats_4/ClearanceFactor","FRM_1/Case_sigstats_4/CrestFactor","FRM_1/Case_sigstats_4/ImpulseFactor","FRM_1/Case_sigstats_4/Mean","FRM_1/Case_sigstats_4/PeakValue","FRM_1/Case_sigstats_4/ShapeFactor","FRM_1/Case_sigstats_4/Std","FRM_1/Case_sigstats_5/SNR","FRM_1/Case_sigstats_5/ShapeFactor","FRM_1/Case_sigstats_5/Std","FRM_1/Case_sigstats_6/RMS","FRM_1/Case_sigstats_6/ShapeFactor","FRM_1/Case_sigstats_6/Skewness","FRM_1/Case_sigstats_6/Std","FRM_1/Case_ps_spec/PeakAmp2","FRM_1/Case_ps_spec/PeakAmp3","FRM_1/Case_ps_spec/PeakFreq4","FRM_1/Case_ps_1_spec/PeakFreq1","FRM_1/Case_ps_2_spec/PeakAmp2","FRM_1/Case_ps_2_spec/PeakAmp5","FRM_1/Case_ps_2_spec/PeakFreq2","FRM_1/Case_ps_5_spec/PeakAmp2","FRM_1/Case_ps_5_spec/PeakAmp3","FRM_1/Case_ps_5_spec/PeakFreq2","FRM_1/Case_ps_6_spec/PeakAmp3","FRM_1/Case_ps_6_spec/PeakFreq2"];
featureTable = readFeatureTable(outputEnsemble,"FRM_1",'Features',selectedFeatureNames,'ConditionVariables',outputEnsemble.ConditionVariables,'IncludeMemberID',true);

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');

% Gather results into a table.
if nargout > 1
    outputTable = readall(outputEnsemble);
end
end
