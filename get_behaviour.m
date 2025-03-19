clear all
close all
clc

%% set parameters and loops
see_performance = 0;
display_percentageok = 1;
plot_individuals = 0;
plot_averages = 1;

pp2do = [1:25]; 
p = 0;

[bar_size, colours, dark_colours, labels, subplot_size, percentageok] = setBehaviourParam(pp2do);

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    figure_nr = 1;

    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);
    
    %% update signed error to stay within -90/+90
    behdata.signed_difference(behdata.signed_difference>90) = behdata.signed_difference(behdata.signed_difference>90)-180;
    behdata.signed_difference(behdata.signed_difference<-90) = behdata.signed_difference(behdata.signed_difference<-90)+180;
    
    %% check ok trials, just based on decision time, because this one is unlimited.
    oktrials = abs(zscore(behdata.idle_reaction_time_in_ms))<=3; 
    % oktrials = abs(zscore(behdata.absolute_difference))<=3; 
    percentageok(p) = mean(oktrials)*100;

    %% display percentage OK
    if display_percentageok
        fprintf('%s has %.2f%% OK trials ', param.subjName, percentageok(p))
        fprintf('and an average score of %.2f \n\n', mean(behdata.performance))
    end

    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.response_time_in_ms(oktrials),50);
        title(['response time - pp ', num2str(pp2do(p))]);
        xlim([0 1500]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.idle_reaction_time_in_ms(oktrials),50);
        title(['decision time - pp ', num2str(pp2do(p))]);  

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.signed_difference(oktrials),50);
        title(['signed error - pp ', num2str(pp2do(p))]);
        xlim([-100 100]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.absolute_difference(oktrials),50);
        title(['error - pp ', num2str(pp2do(p))]);
        xlim([0 100]);
        
    end
    
    %% trial selections
    location_probe_trials = ismember(behdata.block_type, {'location_probe'});
    colour_probe_trials = ismember(behdata.block_type, {'colour_probe'});

    location_cue_trials = ismember(behdata.cue_form, {'location_cue'});
    colour_cue_trials = ismember(behdata.cue_form, {'colour_cue'});

    congruent_trials = ismember(behdata.trial_condition, {'congruent'});
    incongruent_trials = ismember(behdata.trial_condition, {'incongruent'});

    left_target_trials = ismember(behdata.target_bar, {'left'});
    right_target_trials = ismember(behdata.target_bar, {'right'});

    %% mixture models of target error
    % get non-target orientations
    non_target_orientations = zeros(size(behdata.trial_number));
    right_target_trials = find(strcmp(behdata.target_bar,'right'));
    left_target_trials = find(strcmp(behdata.target_bar,'left'));
    non_target_orientations(right_target_trials) = behdata.left_orientation(right_target_trials);
    non_target_orientations(left_target_trials) = behdata.right_orientation(left_target_trials);
    
    % turn all orientations to radians...
    non_target_orientations = (non_target_orientations/90*pi);
    behdata.report_orientation = behdata.report_orientation/90*pi;
    behdata.target_orientation = behdata.target_orientation/90*pi;
    
    % create model for each condition
    cond_labels = ["loc_probe", "col_probe"];
    conditions = [1 : size(cond_labels, 2)];
    condition_sets = [colour_cue_trials&location_probe_trials, colour_cue_trials&colour_probe_trials];

    for condition = conditions
        [B, LL] = mixtureFit(behdata.report_orientation(condition_sets(:,condition)&congruent_trials&oktrials), ...
            behdata.target_orientation(condition_sets(:,condition)&congruent_trials&oktrials),...
            non_target_orientations(condition_sets(:,condition)&congruent_trials&oktrials));
        
        precision_c(p, condition) = B(1);
        pT_c(p, condition) = B(2);
        pNT_c(p, condition) = B(3);
        pU_c(p, condition) = B(4);
    end

    for condition = conditions
        [B, LL] = mixtureFit(behdata.report_orientation(condition_sets(:,condition)&incongruent_trials&oktrials), ...
            behdata.target_orientation(condition_sets(:,condition)&incongruent_trials&oktrials),...
            non_target_orientations(condition_sets(:,condition)&incongruent_trials&oktrials));
        
        precision_i(p, condition) = B(1);
        pT_i(p, condition) = B(2);
        pNT_i(p, condition) = B(3);
        pU_i(p, condition) = B(4);
    end
    
    %% extract data of interest
    overall_dt(p,1) = mean(behdata.idle_reaction_time_in_ms(oktrials));
    overall_error(p,1) = mean(behdata.absolute_difference(oktrials));

    loc_probe_decisiontime(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&location_cue_trials&location_probe_trials&oktrials));
    loc_probe_decisiontime(p,2) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&location_cue_trials&location_probe_trials&oktrials));
    loc_probe_decisiontime(p,3) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&colour_cue_trials&location_probe_trials&oktrials));
    loc_probe_decisiontime(p,4) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&colour_cue_trials&location_probe_trials&oktrials));
    loc_probe_decisiontime(p,5) = mean(behdata.idle_reaction_time_in_ms(location_probe_trials&oktrials));

    loc_probe_error(p,1) = mean(behdata.absolute_difference(congruent_trials&location_cue_trials&location_probe_trials&oktrials));
    loc_probe_error(p,2) = mean(behdata.absolute_difference(incongruent_trials&location_cue_trials&location_probe_trials&oktrials));
    loc_probe_error(p,3) = mean(behdata.absolute_difference(congruent_trials&colour_cue_trials&location_probe_trials&oktrials));
    loc_probe_error(p,4) = mean(behdata.absolute_difference(incongruent_trials&colour_cue_trials&location_probe_trials&oktrials));
    loc_probe_error(p,5) = mean(behdata.absolute_difference(location_probe_trials&oktrials));

    col_probe_decisiontime(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&location_cue_trials&colour_probe_trials&oktrials));
    col_probe_decisiontime(p,2) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&location_cue_trials&colour_probe_trials&oktrials));
    col_probe_decisiontime(p,3) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&colour_cue_trials&colour_probe_trials&oktrials));
    col_probe_decisiontime(p,4) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&colour_cue_trials&colour_probe_trials&oktrials));
    col_probe_decisiontime(p,5) = mean(behdata.idle_reaction_time_in_ms(location_probe_trials&oktrials));

    col_probe_error(p,1) = mean(behdata.absolute_difference(congruent_trials&location_cue_trials&colour_probe_trials&oktrials));
    col_probe_error(p,2) = mean(behdata.absolute_difference(incongruent_trials&location_cue_trials&colour_probe_trials&oktrials));
    col_probe_error(p,3) = mean(behdata.absolute_difference(congruent_trials&colour_cue_trials&colour_probe_trials&oktrials));
    col_probe_error(p,4) = mean(behdata.absolute_difference(incongruent_trials&colour_cue_trials&colour_probe_trials&oktrials));
    col_probe_error(p,5) = mean(behdata.absolute_difference(location_probe_trials&oktrials));

    congruency_labels = {"congruent", "incongruent"};

    congruency_dt(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&oktrials));
    congruency_dt(p,2) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&oktrials));

    congruency_er(p,1) = mean(behdata.absolute_difference(congruent_trials&oktrials));
    congruency_er(p,2) = mean(behdata.absolute_difference(incongruent_trials&oktrials));

    
    %% calculate aggregates of interest
    probe_labels = {"location probe", "colour probe", "location probe", "colour probe"};
    cue_labels = {"location cue", "colour cue"};

    % order here is:
    % 1: colour cue (location probe) -> TI
    % 2: colour cue (colour probe) -> TR

    congruency_dt_effect(p,1) = loc_probe_decisiontime(p,4) - loc_probe_decisiontime(p,3);
    congruency_dt_effect(p,2) = col_probe_decisiontime(p,4) - col_probe_decisiontime(p,3);

    congruency_er_effect(p,1) = loc_probe_error(p,4) - loc_probe_error(p,3);
    congruency_er_effect(p,2) = col_probe_error(p,4) - col_probe_error(p,3);


    %% plot individuals
    dt_lim = 1200;
    er_lim = 30;

    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [loc_probe_decisiontime(p,1:2); loc_probe_decisiontime(p,3:4)]); 
        xticks([1,2]);
        xticklabels(labels);
        ylim([0 dt_lim]);
        legend("congruent", "incongruent");
        title(['decision time, location probe - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [loc_probe_error(p,1:2); loc_probe_error(p,3:4)]);
        xticks([1,2]);
        xticklabels(labels);
        ylim([0 er_lim]);
        legend("congruent", "incongruent");
        title(['error, location probe - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [col_probe_decisiontime(p,1:2); col_probe_decisiontime(p,3:4)]);
        xticks([1,2]);
        xticklabels(labels);
        ylim([0 dt_lim]);
        legend("congruent", "incongruent");
        title(['decision time, colour probe - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [col_probe_error(p,1:2); col_probe_error(p,3:4)]);
        xticks([1,2]);
        xticklabels(labels);
        ylim([0 er_lim]);
        legend("congruent", "incongruent");
        title(['error, colour probe - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [congruency_dt_effect(p,1); congruency_dt_effect(p,2)]);
        xticks([1,2]);
        xticklabels(probe_labels);
        ylim([0 200]);
        legend("location probe", "colour probe");
        title(['decision time effect - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [congruency_er_effect(p,1); congruency_er_effect(p,2)]);
        xticks([1,2]);
        xticklabels(probe_labels);
        ylim([0 10]);
        legend("location probe", "colour probe");
        title(['error effect - pp ', num2str(pp)]);

    end
end

    pT_effect = pT_c - pT_i;
    pNT_effect = pNT_c - pNT_i;
    pU_effect = pU_c - pU_i;
    precision_effect = precision_c - precision_i;
    
    writematrix(congruency_er, [param.path, '\saved_data\beh_congruency_er']);
    writematrix(congruency_dt, [param.path, '\saved_data\beh_congruency_dt']);
    writematrix(congruency_er_effect, [param.path, '\saved_data\beh_congruency_er_effect']);
    writematrix(congruency_dt_effect, [param.path, '\saved_data\beh_congruency_dt_effect']);

%% calculate % change
pp_dt_avg = overall_dt;
pp_er_avg = overall_error;

norm_dt_loc_con = (loc_probe_decisiontime(:,3) - pp_dt_avg) ./ pp_dt_avg * 100;
norm_dt_loc_incon = (loc_probe_decisiontime(:,4) - pp_dt_avg) ./ pp_dt_avg * 100;
norm_dt_col_con = (col_probe_decisiontime(:,3) - pp_dt_avg) ./ pp_dt_avg * 100;
norm_dt_col_incon = (col_probe_decisiontime(:,4) - pp_dt_avg) ./ pp_dt_avg * 100;

dt_effect_norm(:,1) = norm_dt_loc_incon - norm_dt_loc_con;
dt_effect_norm(:,2) = norm_dt_col_incon - norm_dt_col_con;

norm_er_loc_con = (loc_probe_error(:,3) - pp_er_avg) ./ pp_er_avg * 100;
norm_er_loc_incon = (loc_probe_error(:,4) - pp_er_avg) ./ pp_er_avg * 100;
norm_er_col_con = (col_probe_error(:,3) - pp_er_avg) ./ pp_er_avg * 100;
norm_er_col_incon = (col_probe_error(:,4) - pp_er_avg) ./ pp_er_avg * 100;

er_effect_norm(:,1) = norm_er_loc_incon - norm_er_loc_con;
er_effect_norm(:,2) = norm_er_col_incon - norm_er_col_con;

comb_norm_effect(:,1) = mean([dt_effect_norm(:,1), er_effect_norm(:,1)], 2);
comb_norm_effect(:,2) = mean([dt_effect_norm(:,2), er_effect_norm(:,2)], 2);

figure;
subplot(1,3,1)
hold on
bar([1,2], mean(dt_effect_norm))
plot([dt_effect_norm(:,1), dt_effect_norm(:,2)]')
ylim([-25 50]);
title("dt");

subplot(1,3,2)
hold on
bar([1,2], mean(er_effect_norm))
plot([er_effect_norm(:,1), er_effect_norm(:,2)]')
ylim([-25 50]);
title("error");

subplot(1,3,3)
hold on
bar([1,2], mean(comb_norm_effect))
plot([comb_norm_effect(:,1), comb_norm_effect(:,2)]')
ylim([-25 50]);
title("comb");

%% plot mixture moduling results
figure;
subplot(2,2,1);
hold on
bar([1,2,3,4], [mean(pT_c(:,1)), mean(pT_i(:,1)), mean(pT_c(:,2)), mean(pT_i(:,2))])
plot([1,2], [pT_c(:,1), pT_i(:,1)]')
plot([3,4], [pT_c(:,2), pT_i(:,2)]')
xticks([1,2,3,4])
xticklabels({"con_loc", "incon_loc", "con_col", "incon_col"})
title("pT")

subplot(2,2,2);
hold on
bar([1,2,3,4], [mean(pNT_c(:,1)), mean(pNT_i(:,1)), mean(pNT_c(:,2)), mean(pNT_i(:,2))])
plot([1,2], [pNT_c(:,1), pNT_i(:,1)]')
plot([3,4], [pNT_c(:,2), pNT_i(:,2)]')
xticks([1,2,3,4])
xticklabels({"con_loc", "incon_loc", "con_col", "incon_col"})
title("pNT")

subplot(2,2,3);
hold on
bar([1,2,3,4], [mean(pU_c(:,1)), mean(pU_i(:,1)), mean(pU_c(:,2)), mean(pU_i(:,2))])
plot([1,2], [pU_c(:,1), pU_i(:,1)]')
plot([3,4], [pU_c(:,2), pU_i(:,2)]')
xticks([1,2,3,4])
xticklabels({"con_loc", "incon_loc", "con_col", "incon_col"})
title("pU")

subplot(2,2,4);
hold on
bar([1,2,3,4], [mean(precision_c(:,1)), mean(precision_i(:,1)), mean(precision_c(:,2)), mean(precision_i(:,2))])
plot([1,2], [precision_c(:,1), precision_i(:,1)]')
plot([3,4], [precision_c(:,2), precision_i(:,2)]')
xticks([1,2,3,4])
xticklabels({"con_loc", "incon_loc", "con_col", "incon_col"})
title("precision")


    %% all pp plot
if plot_averages

    figure; 
    subplot(3,1,1);
    bar(ppnum, overall_dt(:,1));
    title('overall decision time');
    ylim([0 900]);
    xlabel('pp #');

    subplot(3,1,2);
    bar(ppnum, overall_error(:,1));
    title('overall error');
    ylim([0 25]);
    xlabel('pp #');

    subplot(3,1,3);
    bar(ppnum, percentageok);
    title('percentage ok trials');
    ylim([90 100]);
    xlabel('pp #');

    %% does it work at all?
    %congruent vs. incongruent cue
    
    % decision time
    figure;
    hold on 
    b = bar(mean(congruency_dt), 'FaceColor', colours(3,:), 'LineStyle', 'none');
    errorbar([1:2], mean(congruency_dt), std(congruency_dt) ./ sqrt(p), 'LineStyle', 'none', 'Color', dark_colours(3,:), 'LineWidth', 1.5)
    xticks([1 2]);
    xticklabels(congruency_labels);
    title(['dt as function of congruency']);
    % add individuals
    plot([1:2], congruency_dt, 'Color', [0, 0, 0, 0.25]);
    ylim([300, 1200])

    % error
    figure;
    hold on 
    b = bar(mean(congruency_er), 'FaceColor', colours(3,:), 'LineStyle', 'none');
    errorbar([1:2], mean(congruency_er), std(congruency_er) ./ sqrt(p), 'LineStyle', 'none', 'Color', dark_colours(3,:), 'LineWidth', 1.5)
    xticks([1 2]);
    xticklabels(congruency_labels);
    title(['error as function of congruency']);
    % add individuals
    plot([1:2], congruency_er, 'Color', [0, 0, 0, 0.25]);
    ylim([8, 31])
   
    %% main behavioural figure - dt
    figure; 
    hold on
    b = bar([1,2], [mean(congruency_dt_effect(:,1)); mean(congruency_dt_effect(:,2))], 'LineStyle', 'none');
    % add errorbars
    dark_colours_for_loop = [dark_colours(1:2,:); dark_colours(1:2,:)];
    errorbar([1,2], mean(congruency_dt_effect(:,1:2)), std(congruency_dt_effect(:,1:2)) ./ sqrt(p), "black", 'Color', dark_colours(1,:), 'LineWidth', 1.5);
   
    % add individuals
    plot([1:2], [congruency_dt_effect(:,1:2)]', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2]);
    xticklabels(probe_labels);
    ylim([-65 185]);
    title(['decision time effect - averaged']);
    
    %% main behavioural figure - error
    figure; 
    hold on
    b = bar([1,2], [mean(congruency_er_effect(:,[1])); mean(congruency_er_effect(:,[2]))], 'LineStyle', 'none');
    % add errorbars
    errorbar([1,2], mean(congruency_er_effect(:,1:2)), std(congruency_er_effect(:,1:2)) ./ sqrt(p), "black", 'Color', dark_colours(1,:), 'LineWidth', 1.5);

    % add individuals
    plot([1:2], [congruency_er_effect(:,[1,2])]', 'Color', [0, 0, 0, 0.25]);
    % highlight excluded participants (only works if included at the top)
    % plot([x(1),x(2)], [congruency_er_effect(9,1:2)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(9,3:4)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(1),x(2)], [congruency_er_effect(17,1:2)]', 'Color', [0, 0, 1, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(17,3:4)]', 'Color', [0, 0, 1, 0.25]);
    xticks([1,2]);
    xticklabels(probe_labels);
    ylim([-3.5 6.5]);
    legend("location probe", "colour probe");
    title(['error effect - averaged']);
    
    %% main behavioural figure - pT
    figure; 
    hold on
    b = bar([1,2], [mean(pT_effect(:,1)); mean(pT_effect(:,2))], 'LineStyle', 'none');
    % add errorbars
    errorbar([1:2], mean(pT_effect(:,1:2)), std(pT_effect(:,1:2)) ./ sqrt(p), "black", 'Color', dark_colours(1,:), 'LineWidth', 1.5);

    % add individuals
    plot([1:2], [pT_effect(:,1:2)]', 'Color', [0, 0, 0, 0.25]);
    % highlight excluded participants (only works if included at the top)
    % plot([x(1),x(2)], [congruency_er_effect(9,1:2)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(9,3:4)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(1),x(2)], [congruency_er_effect(17,1:2)]', 'Color', [0, 0, 1, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(17,3:4)]', 'Color', [0, 0, 1, 0.25]);
    xticks([1,2]);
    xticklabels(probe_labels);
    % ylim([-3.5 6.5]);
    legend("location probe", "colour probe");
    title(['pT effect - averaged']);

    % set(gcf,'position',[0,0, 700,1080])

     %% main behavioural figure - pNT
    figure; 
    hold on
    b = bar([1,2], [mean(pNT_effect(:,1)); mean(pNT_effect(:,2))], 'LineStyle', 'none');
    % add errorbars
    errorbar([1,2], mean(pNT_effect(:,1:2)), std(pNT_effect(:,1:2)) ./ sqrt(p), "black", 'Color', dark_colours(1,:), 'LineWidth', 1.5);
    % add individuals
    plot([1:2], [pNT_effect(:,1:2)]', 'Color', [0, 0, 0, 0.25]);
    % highlight excluded participants (only works if included at the top)
    % plot([x(1),x(2)], [congruency_er_effect(9,1:2)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(9,3:4)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(1),x(2)], [congruency_er_effect(17,1:2)]', 'Color', [0, 0, 1, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(17,3:4)]', 'Color', [0, 0, 1, 0.25]);
    xticks([1,2]);
    xticklabels(probe_labels);
    % ylim([-3.5 6.5]);
    legend("location cue", "colour cue");
    title(['pNT effect - averaged']);

    % set(gcf,'position',[0,0, 700,1080])
     
end

%% see performance per block (for fun for participants)
if see_performance
    x = (1:16);
    block_performance = zeros(1, length(x));
    block_performance_std = zeros(1, length(x));
    block_speed = zeros(1, length(x));
    block_speed_std = zeros(1, length(x));
    
    for i = x
        block_performance(i) = mean(behdata.performance(behdata.block == i));
        block_performance_std(i) = std(behdata.performance(behdata.block == i));
        block_speed(i) = mean(behdata.idle_reaction_time_in_ms(behdata.block == i));
        block_speed_std(i) = std(behdata.idle_reaction_time_in_ms(behdata.block == i));
    end
    
    figure;
    hold on
    plot(block_performance)
    %errorbar(block_performance, block_performance_std)
    ylim([50 100])
    xlim([1 16])
    ylabel('Performance score')
    yyaxis right
    plot(block_speed)
    %errorbar(block_speed, block_speed_std)
    ylim([100 2000])
    ylabel('Reaction time (ms)')
    xlabel('Block number')
    xticks(x)
end
