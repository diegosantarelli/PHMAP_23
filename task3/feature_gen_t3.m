function [featureTable,outputTable] = feature_gen_t3(inputData)
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
%  Case_ps_3/SpectrumData
%  Case_ps_4/SpectrumData
%  Case_ps_6/SpectrumData
%
% This function computes features:
%  Case_sigstats_1/SNR
%  Case_sigstats_1/THD
%  Case_sigstats_2/SINAD
%  Case_sigstats_2/SNR
%  Case_sigstats_3/SINAD
%  Case_sigstats_3/SNR
%  Case_sigstats_4/SINAD
%  Case_sigstats_4/SNR
%  Case_sigstats_5/SNR
%  Case_ps_spec/PeakFreq1
%  Case_ps_1_spec/PeakAmp3
%  Case_ps_1_spec/PeakAmp4
%  Case_ps_1_spec/PeakFreq3
%  Case_ps_1_spec/PeakFreq4
%  Case_ps_2_spec/PeakAmp2
%  Case_ps_2_spec/PeakFreq3
%  Case_ps_2_spec/PeakFreq4
%  Case_ps_3_spec/PeakFreq2
%  Case_ps_4_spec/PeakAmp3
%  Case_ps_6_spec/PeakFreq1
%  Case_ps_6_spec/PeakFreq3
%
% Frame Policy:
%  Frame name: FRM_1
%  Frame size: 0.128 seconds
%  Frame rate: 0.064 seconds
%
% Organization of the function:
% 1. Compute signals/spectra/features
% 2. Extract computed features into a table
%
% Modify the function to add or remove data processing, feature generation
% or ranking operations.

% Auto-generated by MATLAB on 21-Feb-2025 11:48:14

% Create output ensemble.
outputEnsemble = workspaceEnsemble(inputData,'DataVariables',"Case",'ConditionVariables',"Task3");

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
    Case_full = readMemberData(member,"Case",["TIME","P1","P2","P3","P4","P6","P5","P7"]);

    % Get the frame intervals.
    lowerBound = Case_full.TIME(1);
    upperBound = Case_full.TIME(end);
    fullIntervals = frameintervals([lowerBound upperBound],0.064,0.128,'FrameUnit',"seconds");
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
            inputSignal = Case.P1;
            SNR = snr(inputSignal);
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [SNR,THD];

            % Store computed features in a table.
            featureNames = {'SNR','THD'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'SNR','THD'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_1},'VariableNames',{'Case_sigstats_1'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P2;
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);

            % Concatenate signal features.
            featureValues = [SINAD,SNR];

            % Store computed features in a table.
            featureNames = {'SINAD','SNR'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'SINAD','SNR'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_2},'VariableNames',{'Case_sigstats_2'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P3;
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);

            % Concatenate signal features.
            featureValues = [SINAD,SNR];

            % Store computed features in a table.
            featureNames = {'SINAD','SNR'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'SINAD','SNR'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_3},'VariableNames',{'Case_sigstats_3'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P4;
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);

            % Concatenate signal features.
            featureValues = [SINAD,SNR];

            % Store computed features in a table.
            featureNames = {'SINAD','SNR'};
            Case_sigstats_4 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'SINAD','SNR'};
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

            % Concatenate signal features.
            featureValues = SNR;

            % Store computed features in a table.
            featureNames = {'SNR'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'SNR'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_5},'VariableNames',{'Case_sigstats_5'})];

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
            x_raw = Case.P3;
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
            Case_ps_3 = ps;
        catch
            Case_ps_3 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_3},'VariableNames',{'Case_ps_3'})];

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
            x_raw = Case.P4;
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
            Case_ps_4 = ps;
        catch
            Case_ps_4 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_4},'VariableNames',{'Case_ps_4'})];

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
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',4);
            peakAmp = [peakAmp(:); NaN(4-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(4-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakFreq1 = peakFreq(1);

            % Concatenate signal features.
            featureValues = PeakFreq1;

            % Store computed features in a table.
            featureNames = {'PeakFreq1'};
            Case_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'PeakFreq1'};
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
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',4);
            peakAmp = [peakAmp(:); NaN(4-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(4-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp3 = peakAmp(3);
            PeakAmp4 = peakAmp(4);
            PeakFreq3 = peakFreq(3);
            PeakFreq4 = peakFreq(4);

            % Concatenate signal features.
            featureValues = [PeakAmp3,PeakAmp4,PeakFreq3,PeakFreq4];

            % Store computed features in a table.
            featureNames = {'PeakAmp3','PeakAmp4','PeakFreq3','PeakFreq4'};
            Case_ps_1_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,4);
            featureNames = {'PeakAmp3','PeakAmp4','PeakFreq3','PeakFreq4'};
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
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',4);
            peakAmp = [peakAmp(:); NaN(4-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(4-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp2 = peakAmp(2);
            PeakFreq3 = peakFreq(3);
            PeakFreq4 = peakFreq(4);

            % Concatenate signal features.
            featureValues = [PeakAmp2,PeakFreq3,PeakFreq4];

            % Store computed features in a table.
            featureNames = {'PeakAmp2','PeakFreq3','PeakFreq4'};
            Case_ps_2_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp2','PeakFreq3','PeakFreq4'};
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
            ps = Case_ps_3.SpectrumData;
            w = Case_ps_3.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*1.59154943091895e-05) & (w<=factor*500.000000000055);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',4);
            peakAmp = [peakAmp(:); NaN(4-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(4-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = PeakFreq2;

            % Store computed features in a table.
            featureNames = {'PeakFreq2'};
            Case_ps_3_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'PeakFreq2'};
            Case_ps_3_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_3_spec},'VariableNames',{'Case_ps_3_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_4.SpectrumData;
            w = Case_ps_4.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*1.59154943091895e-05) & (w<=factor*500.000000000055);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',4);
            peakAmp = [peakAmp(:); NaN(4-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(4-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp3 = peakAmp(3);

            % Concatenate signal features.
            featureValues = PeakAmp3;

            % Store computed features in a table.
            featureNames = {'PeakAmp3'};
            Case_ps_4_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'PeakAmp3'};
            Case_ps_4_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_4_spec},'VariableNames',{'Case_ps_4_spec'})];

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
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',4);
            peakAmp = [peakAmp(:); NaN(4-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(4-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakFreq1 = peakFreq(1);
            PeakFreq3 = peakFreq(3);

            % Concatenate signal features.
            featureValues = [PeakFreq1,PeakFreq3];

            % Store computed features in a table.
            featureNames = {'PeakFreq1','PeakFreq3'};
            Case_ps_6_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'PeakFreq1','PeakFreq3'};
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
selectedFeatureNames = ["FRM_1/Case_sigstats_1/SNR","FRM_1/Case_sigstats_1/THD","FRM_1/Case_sigstats_2/SINAD","FRM_1/Case_sigstats_2/SNR","FRM_1/Case_sigstats_3/SINAD","FRM_1/Case_sigstats_3/SNR","FRM_1/Case_sigstats_4/SINAD","FRM_1/Case_sigstats_4/SNR","FRM_1/Case_sigstats_5/SNR","FRM_1/Case_ps_spec/PeakFreq1","FRM_1/Case_ps_1_spec/PeakAmp3","FRM_1/Case_ps_1_spec/PeakAmp4","FRM_1/Case_ps_1_spec/PeakFreq3","FRM_1/Case_ps_1_spec/PeakFreq4","FRM_1/Case_ps_2_spec/PeakAmp2","FRM_1/Case_ps_2_spec/PeakFreq3","FRM_1/Case_ps_2_spec/PeakFreq4","FRM_1/Case_ps_3_spec/PeakFreq2","FRM_1/Case_ps_4_spec/PeakAmp3","FRM_1/Case_ps_6_spec/PeakFreq1","FRM_1/Case_ps_6_spec/PeakFreq3"];
featureTable = readFeatureTable(outputEnsemble,"FRM_1",'Features',selectedFeatureNames,'ConditionVariables',outputEnsemble.ConditionVariables,'IncludeMemberID',true);

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');

% Gather results into a table.
if nargout > 1
    outputTable = readall(outputEnsemble);
end
end
