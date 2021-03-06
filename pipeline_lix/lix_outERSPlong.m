inputDir = '~/data/Mood-Pain-Empathy/';
outputDir = fullfile(inputDir, 'csv_rv15');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'painEmpathy_rv15.mat'));

time1 = [0:100:1300];
time2 = [100:100:1400];
trange = [time1; time2];

theta = [4, 7];
alpha = [8, 13];
alpha1 = [8 10];
alpha2 = [10 13];
beta1 = [14, 20];
beta2 = [21, 30];

% bands = {'theta', 'alpha', 'alpha1', 'alpha2', 'beta1', 'beta2'};
bands = {'theta', 'alpha', 'alpha1', 'alpha2'};
% chans = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% chans = {'O1', 'Oz', 'O2'};
% chans = {'F3', 'F1', 'Fz', 'F2', 'F4'};
chans = {'FC3', 'FCz', 'FC4'};

nb = numel(bands);
for iF = 1:nb
    freq = eval(bands{iF});
    out = outERSP3(STUDY, trange, freq, chans);
    filename = sprintf('longersp_%s_%s_t%i-%i.csv', ...
                       cellstrcat(chans, '-'), bands{iF}, ...
                       min(trange(:)), max(trange(:)));
    outFile = fullfile(outputDir, filename);
    struct2csv(out, outFile);
end
