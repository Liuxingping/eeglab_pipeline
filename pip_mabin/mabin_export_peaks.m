%% script for exporting peak and peak latency 峰值与峰值潜伏期

base_dir = 'E:\Data\mabin';
output_folder = 'output_erp';
chan_labels = {'FCz'};
time_range = [450 650];  % 取峰值时间（ms）范围
component_label = 'N200'; % 成分名称
direction = 'n'; % 峰的方向，负（n）还是正（p）
n_sample = 2; % 取左右多少个采样点的均值作为峰值；请根据采样率估算。 
% 例如，250hz，4ms为一个采样点，取左右两个采样点则为左右10ms范围的峰值

%% Code begins

output_dir = fullfile(base_dir, output_folder);
mkdir_p(output_dir);

subj = to_col_vector(STUDY.subject);

[STUDY, erp_data, erp_times] = ...
    std_erpplot(STUDY, ALLEEG, ...
    'channels', chan_labels, ...
    'noplot', 'on', ...
    'averagechan', 'on');

var1 = to_row_vector(STUDY.design(1).variable(1).value);
var2 = to_row_vector(STUDY.design(1).variable(2).value);
vars = cellstr_join(var1, var2, '_');

peaks_val = zeros(length(subj), length(vars));
peaks_lat = peaks_val;
for i = 1:length(vars)  % loop through the group

    erp_this = erp_data{i};
    [peaks_val(:,i), peaks_lat(:,i)] = pick_peaks(erp_this, erp_times, time_range, ...
        direction, n_sample);
        
end

% prepare to write
hdr = [{'subj'},vars];
peaks_val_to_write = [hdr; [subj, num2cellstr(peaks_val)]];
peaks_lat_to_write = [hdr; [subj, num2cellstr(peaks_lat)]];

fname_peaks_val = sprintf('peakval-%s_%s_t%i-%i.csv', ...
    component_label,...
    str_join(chan_labels, '-'),...
    time_range(1),...
    time_range(2));
fname_peaks_lat = sprintf('peaklat-%s_%s_t%i-%i.csv', ...
    component_label,...
    str_join(chan_labels, '-'),...
    time_range(1),...
    time_range(2));

% write
cell2csv(fullfile(output_dir, fname_peaks_val), peaks_val_to_write, ',');
cell2csv(fullfile(output_dir, fname_peaks_lat), peaks_lat_to_write, ',');