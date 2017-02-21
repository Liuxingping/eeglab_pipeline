%% Script for running ICA


%% Initialize Variables
clear, clc, close all
base_dir = '';
input_folder = 'raw';
ica_folder = 'ica';
output_prefix = 's';
output_sufix = 'ica';
file_ext = {'raw'};
seperator = 1;

% Parameters for preprocessing
brain_template = 'EGI65';  % Spherical
on_ref = 'Cz';
append_on_ref = true;
off_ref = {'TP9', 'TP10'};
srate = 250;
hipass = 0.1;
lowpass = 40;
marks = {'zheg', 'fu__', 'zhog'};
epoch_time = [-0.2, 1];

% Thresholds for detecting bad epochs
thresh_param.low_thresh = -300;
thresh_param.up_thresh = 300;
trends_param.slope = 200;
trends_param.r2 = 0.3;
spectra_param.threshold = [-35, 35];
spectra_param.freqlimits = [20 40];
joint_param.single_chan = 8;
joint_param.all_chan = 4;
kurt_param.single_chan = 8;
kurt_param.all_chan = 4;
thresh_chan = 1;
reject = 1;

%% Code begins

input_dir = fullfile(base_dir, input_folder);
ica_dir = fullfile(base_dir, ica_folder);
output_dir = fullfile(base_dir, output_sufix);
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

[input_fname, id] = get_fileinfo(input_dir, file_ext, seperator);
[ica_fname, ~] = get_fileinfo(ica_dir, 'mat', 2);

rm_chans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
            'VEOD', 'VEO', 'VEOU', 'VEOG', ...
            'M1', 'M2', 'TP9', 'TP10', ...
            'CB1', 'CB2', 'E63', 'E64', ...
            'E23', 'E59'};

for i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    if ~exist(output_prefix, 'var') || isempty(output_prefix)
        output_fname = sprintf('%s_%s.mat', id{i}, output_sufix);
    else
        output_fname = sprintf('%s%s_%s.mat', output_prefix, id{i}, ...
                               output_sufix);
    end
    output_fname_full = fullfile(output_dir, output_fname);
    if exist(output_fname_full, 'file')
        warning('files alrealy exist!')
        continue
    end

    if ~exist(fullfile(ica_dir, ica_fname), 'file')
        continue
    else
        data = parload(fullfile(ica_dir, ica_fname));
    end
    ica = data.ica;
    
    if strcmp(off_ref, 'average')
        isavg = 1;
    else
        isavg = 0;
    end
    
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(input_dir, input_fname{i});
    
    % high pass filtering
    EEG = pop_eegfiltnew(EEG, hipass, 0);
    EEG = eeg_checkset(EEG);
    
    % low pass filtering
    if ~isempty(lowpass)
        EEG = pop_eegfiltnew(EEG, 0, lowpass);
        EEG = eeg_checkset(EEG);
    end
    
    % add channel locations
    EEG = add_chanloc(EEG, brain_template, on_ref, append_on_ref);
    
    % remove channels
    if ~isavg
        real_rm_chans = setdiff(rm_chans, off_ref);
    else
        real_rm_chans = rm_chans;
    end
    
    EEG = pop_select(EEG, 'nochannel', real_rm_chans);
    EEG = eeg_checkset(EEG);
    
    labels = {EEG.chanlocs.labels};
    % re-reference if necessary
    if ~isavg
        real_off_ref = intersect(labels, off_ref);
        if strcmpi(char(real_off_ref), 'm2')
            indexM2 = find(ismember(labels, real_off_ref));
            EEG.data(indexM2, :) = EEG.data(indexM2, :)/2;
        end
        EEG = pop_reref(EEG, find(ismember(labels, real_off_ref)));
        EEG = eeg_checkset(EEG);
    else
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    orig_chanlocs = EEG.chanlocs;
    

    % reject bad channels
    labels = {EEG.chanlocs.labels};
    badchans = union(ica.info.rej_chan_by_epoch, ica.info.badchans);
    EEG = pop_select(EEG, 'nochannel', find(ismember(labels, badchans))); 
    
    % re-reference if offRef is average
    if isavg
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, natsort(marks), epoch_time, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);
    
    % baseline-zero
    EEG = pop_rmbase(EEG, []);

    % down-sampling
    EEG = pop_resample(EEG, srate);
    EEG = eeg_checkset(EEG);
    
    % reject wrong response 
    rej_wrong_resp = ica.info.rej_wrong_resp;
    EEG = pop_rejepoch(EEG, rej_wrong_resp, 0);
    EEG = eeg_checkset(EEG); 

    % reject epochs
    [EEG, info] = rej_epoch_auto(EEG, thresh_param, trends_param, spectra_param, ...
                                 joint_param, kurt_param, thresh_chan, ...
                                 reject);

    % apply ica 
    EEG = apply_ica(EEG, ica)
    
    EEG.info = EEG.info;
    EEG.info.rej_wrong_resp = rej_wrong_resp;
    EEG.info.badchans = badchans;
    EEG.info.orig_chanlocs = orig_chanlocs;
    
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull); 
    EEG = []; ALLEEG = []; CURRENTSET = [];
end
% eeglab redraw;
