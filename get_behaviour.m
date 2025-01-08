clear all
close all
clc

%% set parameters and loops
see_performance = 0;
display_percentageok = 1;
plot_individuals = 1;
plot_averages = 1;

pp2do = [1:9]; 
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
    % oktrials = abs(zscore(behdata.idle_reaction_time_in_ms))<=3; 
    oktrials = abs(zscore(behdata.absolute_difference))<=3; 
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
    cond_labels = ["locc_locp", "colc_locp", "locc_colp", "colc_colp"];
    conditions = [1 : size(cond_labels, 2)];
    condition_sets = [location_cue_trials&location_probe_trials, colour_cue_trials&location_probe_trials, location_cue_trials&colour_probe_trials, colour_cue_trials&colour_probe_trials];

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
        bar([1,2], [congruency_dt_effect(p,1:2); congruency_dt_effect(p,3:4)]);
        xticks([1,2]);
        xticklabels(probe_labels);
        ylim([0 200]);
        legend("location cue", "colour cue");
        title(['decision time effect - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [congruency_er_effect(p,1:2); congruency_er_effect(p,3:4)]);
        xticks([1,2]);
        xticklabels(probe_labels);
        ylim([0 10]);
        legend("location cue", "colour cue");
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
   
    %% task relevance plot
    %task-relevant vs. task-irrelevant cue

    % decision time
    figure;
    hold on 
    b1 = bar([1], mean(congruency_dt_effect(:,[1,4]), "all"), 'FaceColor', colours(3,:), 'LineStyle', 'none');
    b2 = bar([2], mean(congruency_dt_effect(:,[2,3]), "all"), 'FaceColor', [0.5, 0.5, 0.5], 'LineStyle', 'none');
    errorbar([1], mean(congruency_dt_effect(:,[1,4]), "all"), std(mean(congruency_dt_effect(:,[1,4]), 2)) ./ sqrt(p), 'LineStyle', 'none', 'Color', dark_colours(3,:), 'LineWidth', 1.5)
    errorbar([2], mean(congruency_dt_effect(:,[2,3]), "all"), std(mean(congruency_dt_effect(:,[2,3]), 2)) ./ sqrt(p), 'LineStyle', 'none', 'Color', [0.8, 0.8, 0.8], 'LineWidth', 1.5)
    xticks([1 2]);
    xticklabels({"task relevant", "task irrelevant"});
    title(['relevancy effect - dt']);
    % add individuals
    plot([1:2], [reshape(congruency_dt_effect(:,[1,4]), [], 1), reshape(congruency_dt_effect(:,[2,3]), [], 1)], 'Color', [0, 0, 0, 0.25]);
    % ylim([300, 1200])

    % error
    figure;
    hold on 
    b1 = bar([1], mean(congruency_er_effect(:,[1,4]), "all"), 'FaceColor', colours(3,:), 'LineStyle', 'none');
    b2 = bar([2], mean(congruency_er_effect(:,[2,3]), "all"), 'FaceColor', [0.5, 0.5, 0.5], 'LineStyle', 'none');
    errorbar([1], mean(congruency_er_effect(:,[1,4]), "all"), std(mean(congruency_er_effect(:,[1,4]), 2)) ./ sqrt(p), 'LineStyle', 'none', 'Color', dark_colours(3,:), 'LineWidth', 1.5)
    errorbar([2], mean(congruency_er_effect(:,[2,3]), "all"), std(mean(congruency_er_effect(:,[2,3]), 2)) ./ sqrt(p), 'LineStyle', 'none', 'Color', [0.8, 0.8, 0.8], 'LineWidth', 1.5)
    xticks([1 2]);
    xticklabels({"task relevant", "task irrelevant"});
    title(['relevancy effect - error']);
    % add individuals
    plot([1:2], [reshape(congruency_er_effect(:,[1,4]), [], 1), reshape(congruency_er_effect(:,[2,3]), [], 1)], 'Color', [0, 0, 0, 0.25]);
    ylim([-2, 2])

    % pT
    figure;
    hold on 
    b1 = bar([1], mean(pT_effect(:,[1,4]), "all"), 'FaceColor', colours(3,:), 'LineStyle', 'none');
    b2 = bar([2], mean(pT_effect(:,[2,3]), "all"), 'FaceColor', [0.5, 0.5, 0.5], 'LineStyle', 'none');
    errorbar([1], mean(pT_effect(:,[1,4]), "all"), std(pT_effect(:,[1,4]), 0 , "all") ./ sqrt(p), 'LineStyle', 'none', 'Color', dark_colours(3,:), 'LineWidth', 1.5)
    errorbar([2], mean(pT_effect(:,[2,3]), "all"), std(pT_effect(:,[2,3]), 0 , "all") ./ sqrt(p), 'LineStyle', 'none', 'Color', [0.8, 0.8, 0.8], 'LineWidth', 1.5)
    xticks([1 2]);
    xticklabels({"task relevant", "task irrelevant"});
    title(['relevancy effect - pT']);
    % add individuals
    plot([1:2], [reshape(pT_effect(:,[1,4]), [], 1), reshape(pT_effect(:,[2,3]), [], 1)], 'Color', [0, 0, 0, 0.25]);
    %ylim([-0.1, 0.2]);
    
    %% grand average bar graphs of data as function of condition
    figure; 
    hold on
    bar([1,2], [mean(loc_probe_decisiontime(:,1:2)); mean(loc_probe_decisiontime(:,3:4))]);
    % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(loc_probe_decisiontime(:,i)), std(loc_probe_decisiontime(:,i)) ./ sqrt(p), "black");
    end
    xticks([1,2]);
    xticklabels(labels);
    ylim([0 dt_lim]);
    legend("congruent", "incongruent");
    title(['decision time, location probe - averaged']);

    figure; 
    hold on
    bar([1,2], [mean(loc_probe_error(:,1:2)); mean(loc_probe_error(:,3:4))]);
   % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(loc_probe_error(:,i)), std(loc_probe_error(:,i)) ./ sqrt(p), "black");
    end
    xticks([1,2]);
    xticklabels(labels);
    ylim([0 er_lim]);
    legend("congruent", "incongruent");
    title(['error, location probe - averaged']);

    figure; 
    hold on
    bar([1,2], [mean(col_probe_decisiontime(:,1:2)); mean(col_probe_decisiontime(:,3:4))]);
    % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(col_probe_decisiontime(:,i)), std(col_probe_decisiontime(:,i)) ./ sqrt(p), "black");
    end
    xticks([1,2]);
    xticklabels(labels);
    ylim([0 dt_lim]);
    legend("congruent", "incongruent");
    title(['decision time, colour probe - averaged']);

    figure;
    hold on
    bar([1,2], [mean(col_probe_error(:,1:2)); mean(col_probe_error(:,3:4))]);
    % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(col_probe_error(:,i)), std(col_probe_error(:,i)) ./ sqrt(p), "black");
    end
    xticks([1,2]);
    xticklabels(labels);
    ylim([0 er_lim]);
    legend("congruent", "incongruent");
    title(['error, colour probe - averaged']);

    %% main behavioural figure - dt
    figure; 
    hold on
    b = bar([1,2], [mean(congruency_dt_effect(:,1:2)); mean(congruency_dt_effect(:,3:4))], 'LineStyle', 'none');
    b(1).FaceColor = colours(1,:);
    b(2).FaceColor = colours(2,:);
    % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    dark_colours_for_loop = [dark_colours(1:2,:); dark_colours(1:2,:)];
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(congruency_dt_effect(:,i)), std(congruency_dt_effect(:,i)) ./ sqrt(p), "black", 'Color', dark_colours_for_loop(i,:), 'LineWidth', 1.5);
    end
    % add individuals
    plot([x(1),x(2)], [congruency_dt_effect(:,1:2)]', 'Color', [0, 0, 0, 0.25]);
    plot([x(3),x(4)], [congruency_dt_effect(:,3:4)]', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2]);
    xticklabels(cue_labels);
    ylim([-65 185]);
    legend("location probe", "colour probe");
    title(['decision time effect - averaged']);
    
    %% main behavioural figure - error
    figure; 
    hold on
    b = bar([1,2], [mean(congruency_er_effect(:,[1,2])); mean(congruency_er_effect(:,[3,4]))], 'LineStyle', 'none');
    b(1).FaceColor = colours(1,:);
    b(2).FaceColor = colours(2,:);
    % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    dark_colours_for_loop = [dark_colours(1:2,:); dark_colours(1:2,:)];
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(congruency_er_effect(:,i)), std(congruency_er_effect(:,i)) ./ sqrt(p), "black", 'Color', dark_colours_for_loop(i,:), 'LineWidth', 1.5);
    end
    % add individuals
    plot([x(1),x(2)], [congruency_er_effect(:,[1,2])]', 'Color', [0, 0, 0, 0.25]);
    plot([x(3),x(4)], [congruency_er_effect(:,[3,4])]', 'Color', [0, 0, 0, 0.25]);
    % highlight excluded participants (only works if included at the top)
    % plot([x(1),x(2)], [congruency_er_effect(9,1:2)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(9,3:4)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(1),x(2)], [congruency_er_effect(17,1:2)]', 'Color', [0, 0, 1, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(17,3:4)]', 'Color', [0, 0, 1, 0.25]);
    xticks([1,2]);
    xticklabels(cue_labels);
    ylim([-3.5 6.5]);
    legend("location probe", "colour probe");
    title(['error effect - averaged']);
    
    %% main behavioural figure - pT
    figure; 
    hold on
    b = bar([1,2], [mean(pT_effect(:,1:2)); mean(pT_effect(:,3:4))], 'LineStyle', 'none');
    b(1).FaceColor = colours(1,:);
    b(2).FaceColor = colours(2,:);
    % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    dark_colours_for_loop = [dark_colours(1:2,:); dark_colours(1:2,:)];
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(pT_effect(:,i)), std(pT_effect(:,i)) ./ sqrt(p), "black", 'Color', dark_colours_for_loop(i,:), 'LineWidth', 1.5);
    end
    % add individuals
    plot([x(1),x(2)], [pT_effect(:,1:2)]', 'Color', [0, 0, 0, 0.25]);
    plot([x(3),x(4)], [pT_effect(:,3:4)]', 'Color', [0, 0, 0, 0.25]);
    % highlight excluded participants (only works if included at the top)
    % plot([x(1),x(2)], [congruency_er_effect(9,1:2)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(9,3:4)]', 'Color', [1, 0, 0, 0.25]);
    % plot([x(1),x(2)], [congruency_er_effect(17,1:2)]', 'Color', [0, 0, 1, 0.25]);
    % plot([x(3),x(4)], [congruency_er_effect(17,3:4)]', 'Color', [0, 0, 1, 0.25]);
    xticks([1,2]);
    xticklabels(cue_labels);
    % ylim([-3.5 6.5]);
    legend("location probe", "colour probe");
    title(['pT effect - averaged']);

    % set(gcf,'position',[0,0, 700,1080])

     %% main behavioural figure - pNT
    figure; 
    hold on
    b = bar([1,2], [mean(pNT_effect(:,1:2)); mean(pNT_effect(:,3:4))], 'LineStyle', 'none');
    b(1).FaceColor = colours(1,:);
    b(2).FaceColor = colours(2,:);
    % add errorbars
    ngroups = 2;
    nbars_per_group = 2;
    offset = min(0.8, nbars_per_group/(nbars_per_group + 1.5)) / 4;
    for i = 1:ngroups
        x(i*2-1) = i - offset;
        x(i*2) = i + offset;
    end
    dark_colours_for_loop = [dark_colours(1:2,:); dark_colours(1:2,:)];
    for i = 1:ngroups*nbars_per_group
        errorbar(x(i), mean(pNT_effect(:,i)), std(pNT_effect(:,i)) ./ sqrt(p), "black", 'Color', dark_colours_for_loop(i,:), 'LineWidth', 1.5);
    end
    % add individuals
    plot([x(1),x(2)], [pNT_effect(:,1:2)]', 'Color', [0, 0, 0, 0.25]);
    plot([x(3),x(4)], [pNT_effect(:,3:4)]', 'Color', [0, 0, 0, 0.25]);
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
