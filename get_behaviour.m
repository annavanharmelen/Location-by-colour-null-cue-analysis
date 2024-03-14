clear all
close all
clc

%% set parameters and loops
see_performance = 0;
display_percentageok = 1;
plot_individuals = 1;
plot_averages = 0;

pp2do = [1:4]; 
p = 0;

[bar_size, colours,  dark_colours, labels, subplot_size, percentageok] = setBehaviourParam(pp2do);

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
    percentageok(p) = mean(oktrials)*100;

    %% display percentage OK
    if display_percentageok
        fprintf('%s has %.2f%% OK trials\n\n', param.subjName, percentageok(p))
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
    
    %% extract data of interest
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

    %% calculate aggregates of interest
    congruency_labels = {"location probe", "colour probe"};

    congruency_dt_effect(p,1) = loc_probe_decisiontime(p,2) - loc_probe_decisiontime(p,1);
    congruency_dt_effect(p,2) = loc_probe_decisiontime(p,4) - loc_probe_decisiontime(p,3);
    congruency_dt_effect(p,3) = col_probe_decisiontime(p,2) - col_probe_decisiontime(p,1);
    congruency_dt_effect(p,4) = col_probe_decisiontime(p,4) - col_probe_decisiontime(p,3);

    congruency_er_effect(p,1) = loc_probe_error(p,2) - loc_probe_error(p,1);
    congruency_er_effect(p,2) = loc_probe_error(p,4) - loc_probe_error(p,3);
    congruency_er_effect(p,3) = col_probe_error(p,2) - col_probe_error(p,1);
    congruency_er_effect(p,4) = col_probe_error(p,4) - col_probe_error(p,3);

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
        xticklabels(congruency_labels);
        ylim([0 200]);
        legend("location cue", "colour cue");
        title(['decision time effect - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1,2], [congruency_er_effect(p,1:2); congruency_er_effect(p,3:4)]);
        xticks([1,2]);
        xticklabels(congruency_labels);
        ylim([0 10]);
        legend("location cue", "colour cue");
        title(['error effect - pp ', num2str(pp)]);

    end
end


%% all pp plot
if plot_averages

    figure; 
    subplot(3,1,1); bar(ppnum, loc_probe_overall_dt);     title('overall decision time'); ylim([0 900]);  xlabel('pp #');
    subplot(3,1,2); bar(ppnum, location_probe_overall_error);  title('overall error');         ylim([0 25]);   xlabel('pp #');
    subplot(3,1,3); bar(ppnum, percentageok);  title('percentage ok trials');   ylim([90 100]); xlabel('pp #');
    
    %% grand average bar graphs of data as function of condition

    figure;  
    subplot(1,2,1); hold on;
    b1 = bar([1], [mean(loc_probe_decisiontime(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(loc_probe_decisiontime(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    title('Decision time')
    ylim([0 1300]);
    errorbar([1], [mean(loc_probe_decisiontime(:,1))],[std(loc_probe_decisiontime(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(loc_probe_decisiontime(:,2))],[std(loc_probe_decisiontime(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    % for i = [1 : length(decisiontime)]
    %     plot([1,2,3], [decisiontime(:,1:3)]', '-o');
    % end
    plot([1,2,3], [loc_probe_decisiontime(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylabel('Decision time (ms)');
    set(gcf,'position',[0,0, 1080,1600])
    fontsize(23, "points");
    
    subplot(1,2,2); hold on;
    b1 = bar([1], [mean(loc_probe_error(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(loc_probe_error(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    errorbar([1], [mean(loc_probe_error(:,1))],[std(loc_probe_error(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(loc_probe_error(:,2))],[std(loc_probe_error(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    %     plot([1,2,3], [error(:,1:3)]', '-o');
    % end
    title('Reproduction error')
    ylim([0 27])
    plot([1,2,3], [loc_probe_error(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylabel('Error (degrees)');
    fontsize(23, "points");
    
    %% grand average bar graphs of data as function of condition - with mean subtraction per participant
    figure;
    subplot(1,2,1); hold on;
    b1 = bar([1], [mean(location_probe_decisiontimes_meansubtracted(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(location_probe_decisiontimes_meansubtracted(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    errorbar([1], [mean(location_probe_decisiontimes_meansubtracted(:,1))],[std(location_probe_decisiontimes_meansubtracted(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(location_probe_decisiontimes_meansubtracted(:,2))],[std(location_probe_decisiontimes_meansubtracted(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    % for i = [1 : length(decisiontimes_meansubtracted)]
    %     plot([1,2,3], [decisiontimes_meansubtracted(:,1:3)]', '-o');
    % end
    title('Decision time')
    plot([1,2,3], [location_probe_decisiontimes_meansubtracted(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylim([-70 60]);
    ylabel('Decision time (ms)');
    set(gcf,'position',[0,0, 1080,1600])
    fontsize(23, "points");

    subplot(1,2,2); hold on;
    b1 = bar([1], [mean(location_probe_error_meansubtracted(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(location_probe_error_meansubtracted(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    errorbar([1], [mean(location_probe_error_meansubtracted(:,1))],[std(location_probe_error_meansubtracted(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(location_probe_error_meansubtracted(:,2))],[std(location_probe_error_meansubtracted(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    % for i = [1 : length(error_meansubtracted)]
    %     plot([1,2,3], [error_meansubtracted(:,1:3)]', '-o');
    % end
    title('Reproduction error')
    ylim([-2 2]);
    plot([1,2,3], [location_probe_error_meansubtracted(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylabel('Error (degrees)');  
    fontsize(23, "points");
    
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
