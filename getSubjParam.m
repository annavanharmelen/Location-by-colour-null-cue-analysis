function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [95, 37, 92, 74, 49, 52, 99, 39, 96, 42, 90, 13, 72, 44, 85, 24, 76, 71, 50, 47, 32, 59, 19, 93, 88]; %needs to be in the right order

param.path = '\\labsdfs.labs.vu.nl\labsdfs\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\vidi3.2 - location-by-colour null-cue\';

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

log_string = sprintf('data_session_%d.csv', pp);
param.log = [param.path, log_string];

eds_string = sprintf('%d_%d.asc', pp, unique_numbers(pp));
param.eds = [param.path, eds_string];