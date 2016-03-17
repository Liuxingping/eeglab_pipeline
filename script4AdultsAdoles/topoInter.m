% HN vs MN
% HN vs Neutral
% MN vs Neutral
% indir = '~/data/adolesvsadult/conditiondata/';
theta = [5.5, 7.5, 500, 600];
alpha = [10.5, 12, 850, 950];
beta = [18, 20, 500, 600];
band = {'theta', 'alpha', 'beta'};
CONTRAST = {'HN vs MN', 'HN vs Neutral', 'MN vs Neutral'};
YLABEL = {'Adults: ', 'Adolescents: '};
WIDTH = 30;
HEIGHT = 10;
TITLE = cell(6,1);
TITLE(1:3) = strcat(YLABEL{1}, CONTRAST);
TITLE(4:6) = strcat(YLABEL{2}, CONTRAST);
topoOpt = {'style', 'map', ...
           'electrodes', 'on', ...
           'shading', 'flat', ...
           'whitebk', 'off'};
contrast = [1,2; 1,3; 2,3; 4,5; 4,6; 5,6];

for i = 1:numel(band)
    % figure('color', 'w', ...
    %        'nextplot', 'add', ...
    %        'PaperUnits', 'centimeters', ...
    %        'PaperPositionMode', 'manual', ...
    %        'papersize', [WIDTH, HEIGHT], ...
    %        'PaperPosition', [0 0 WIDTH HEIGHT]);
    roi = eval(band{i});
    f = dsearchn(freqs', roi(1:2)');
    t = dsearchn(times', roi(3:4)');
    dataSubset = ...
        cellfun(@(x) {squeeze(mean(mean(x(f(1):f(2), t(1):t(2), :, :), ...
                                        1), 2))}, data);
        [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
            std_stat(dataSubset, 'groupstats', 'on', ...
                     'condstats', 'on', ...
                     'method', 'permutation', ...
                     'alpha', 0.05, ...
                     'naccu', 1000, ...
                     'mode', 'fieldtrip', ...
                     );
        std_chantopo(reshape(pcond, [3,2]), ...
                     'chanlocs', chanlocs, ...
                     'topoplotopt', topoOpt, ...
                     'datatype', 'spec', ...
                     'titles', reshape(TITLE, [3,2]), ...
                     'caxis', [0.01 0.05]);
        colormap(hot);
        hcbar = findobj(gcf, 'tag', 'cbar');
        % set(hcbar, 'yticklabel', [0,0.05, 0.1, 0.15, 0.2]);
        set(get(hcbar, 'title'), 'string', 'p-value');
end
