# Load dependencies
library(stats)
install.packages('car')
library(car)

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
dt_results <- aov(decisiontime ~ cue_type * probe_type * pp, data = data)
summary(dt_results)

er_results <- aov(error ~ cue_type * probe_type, data = data)
summary(er_results)
