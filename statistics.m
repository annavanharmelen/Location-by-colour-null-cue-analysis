% behaviour stats
[h,p,ci,stats] = ttest(congruency_er_effect(:,1), congruency_er_effect(:,2))
[h,p,ci,stats] = ttest(congruency_er_effect(:,3), congruency_er_effect(:,4))
[h,p,ci,stats] = ttest(congruency_dt_effect(:,1), congruency_dt_effect(:,2))
[h,p,ci,stats] = ttest(congruency_dt_effect(:,3), congruency_dt_effect(:,4))

