# Load dependencies
library(stats)
library(car)
library(rstatix)

# Load data
data = read.table(file.choose(), header=TRUE, sep=";")
data$decisiontime[1]

# Test assumptions
# 1. test normality
shapiro.test(data$decisiontime[data$cue_type == 'location' & data$probe_type == 'location'])
shapiro.test(data$decisiontime[data$cue_type == 'colour' & data$probe_type == 'location'])
shapiro.test(data$decisiontime[data$cue_type == 'location' & data$probe_type == 'colour'])
shapiro.test(data$decisiontime[data$cue_type == 'colour' & data$probe_type == 'colour'])

# 2. test equality of variances
var.test(decisiontime ~ cue_type, data)
var.test(decisiontime ~ probe_type, data)

# repeat for error data

# Anova time
dt.aov <- anova_test(data = data, decisiontime ~ cue_type * probe_type, dv=decisiontime, wid = pp, within=c(cue_type, probe_type))
get_anova_table(dt.aov)

er.aov <- anova_test(data = data, error ~ cue_type * probe_type, dv=error, wid = pp, within=c(cue_type, probe_type))
get_anova_table(er.aov)
