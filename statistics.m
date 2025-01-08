%% behaviour stats
% anova - error
cue_type_levels = {"location_cue", "location_cue", "colour_cue", "colour_cue"};
task_type_levels = {"location_probe", "colour_probe", "location_probe", "colour_probe"};

long_form_congruency_er_effect = reshape(congruency_er_effect, [1,100]);
cue_types = [ones(1,25), ones(1,25)*2, ones(1,25), ones(1,25)*2];
task_types = [ones(1,50), ones(1,50)*2];

%balanced_form_congruency_er_effect = reshape(congruency_er_effect, [50,2]);

%[p, tbl, stats] = anovan(long_form_congruency_er_effect, {cue_types, task_types}, 'model', 'interaction', 'varnames', {'Cue_type', 'Probe_type'});
[p,tbl,stats] = anova2(balanced_form_congruency_er_effect, 25, {cue_types, task_types})

rm_anova_data_er(1:100, 1) = reshape(congruency_er_effect, [100,1]); %data
rm_anova_data_er([1:25, 51:75], 2) = 1; %probe-levels
rm_anova_data_er([26:50, 76:100], 2) = 2; %probe-levels
rm_anova_data_er(1:50, 3) = 1; %cue-levels
rm_anova_data_er(51:100, 3) = 2; %cue-levels
rm_anova_data_er(1:100, 4) = repmat((1:25)', 4, 1); %ppid

stats = rm_anova2(rm_anova_data_er(:,1), rm_anova_data_er(:,4), rm_anova_data_er(:,2), rm_anova_data_er(:,3), {'cue-type', 'probe-type'})

% anova - decision time
rm_anova_data_dt(1:100, 1) = reshape(congruency_dt_effect, [100,1]); %data
rm_anova_data_dt([1:25, 51:75], 2) = 1; %probe-levels
rm_anova_data_dt([26:50, 76:100], 2) = 2; %probe-levels
rm_anova_data_dt(1:50, 3) = 1; %cue-levels
rm_anova_data_dt(51:100, 3) = 2; %cue-levels
rm_anova_data_dt(1:100, 4) = repmat((1:25)', 4, 1); %ppid
RMAOV2 = RMAOV2(rm_anova_data_dt)

% anova - pT
rm_anova_data_pT(1:100, 1) = reshape(pT_effect, [100,1]); %data
rm_anova_data_pT([1:25, 51:75], 2) = 1; %cue-levels
rm_anova_data_pT([26:50, 76:100], 2) = 2; %cue-levels
rm_anova_data_pT(1:50, 3) = 1; %probe-levels
rm_anova_data_pT(51:100, 3) = 2; %probe-levels
rm_anova_data_pT(1:100, 4) = repmat((1:25)', 4, 1); %ppid
RMAOV2 = RMAOV2(rm_anova_data_pT)

% t-tests
[h,p,ci,stats] = ttest(congruency_er_effect(:,1), congruency_er_effect(:,2))
[h,p,ci,stats] = ttest(congruency_er_effect(:,3), congruency_er_effect(:,4))
[h,p,ci,stats] = ttest(congruency_dt_effect(:,1), congruency_dt_effect(:,2))
[h,p,ci,stats] = ttest(congruency_dt_effect(:,3), congruency_dt_effect(:,4))

[h,p,ci,stats] = ttest(mean(congruency_dt_effect(:,[1,4]),2), mean(congruency_dt_effect(:,[2,3]),2))
[h,p,ci,stats] = ttest(mean(congruency_er_effect(:,[1,4]),2), mean(congruency_er_effect(:,[2,3]),2))
[h,p,ci,stats] = ttest(congruency_er(:,1), congruency_er(:,2))
[h,p,ci,stats] = ttest(congruency_dt(:,1), congruency_dt(:,2))

[h,p,ci,stats] = ttest(mean(pT_effect(:,[1,4]),2), mean(pT_effect(:,[2,3]),2))

[h,p,ci,stats] = ttest(mean(congruency_er_effect(:,[1,4]),2))
[h,p,ci,stats] = ttest(mean(congruency_er_effect(:,[2,3]),2))
[h,p,ci,stats] = ttest(mean(congruency_dt_effect(:,[1,4]),2))
[h,p,ci,stats] = ttest(mean(congruency_dt_effect(:,[2,3]),2))
[h,p,ci,stats] = ttest(mean(pT_effect(:,[1,4]),2))
[h,p,ci,stats] = ttest(mean(pT_effect(:,[2,3]),2))
