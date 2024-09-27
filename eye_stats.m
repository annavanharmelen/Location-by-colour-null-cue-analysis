%% Script for doing stats on saccade and gaze bias data.
% So run those scripts first.
% by Anna, 04-07-2023
%% Saccade bias data - stats
statcfg.xax = saccade.time;
statcfg.npermutations = 1000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

% ft_size = 26;
timeframe = [951:1451];
data_cond1 = d3(:,4,timeframe);
data_cond2 = d3(:,6,timeframe);
null_data = zeros(size(data_cond1));

stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, null_data)
stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, null_data)
stat_comp = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)
%% Saccade bias data - plot only effect
mask_xxx = double(stat_comp.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure; hold on;
ylimit = [-0.3, 0.3];
p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,4,:)), colours(2,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,6,:)), colours(1,:), 'se');
p1.LineWidth = 1.5;
p2.LineWidth = 1.5;
legend([p1, p2], saccade.label([4,6]));
plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylimit, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);

xlim(xlimtoplot);
sig = plot(saccade.time(timeframe), mask_xxx*-0.11, 'Color', 'k', 'LineWidth', 4); % verticaloffset for positioning of the "significance line"
ylim([-0.2, 0.2]);
ylabel('Rate effect (delta Hz)');
xlabel('Time (ms)');
% set(gcf,'position',[0,0, 1800,900])
% fontsize(ft_size*1.5,"points")
legend([p1,p2], saccade.label([4,6]));
