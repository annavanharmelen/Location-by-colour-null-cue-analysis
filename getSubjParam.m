function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [89, 57, 75, 12, 92, 95, 90, 79, 47, 10]; %needs to be in the right order

param.path = 'C:\Users\annav\Documents\Jottacloud\Neuroscience PhD\Experiments\Vidi experiments\Data\Vidi3 - location-by-colour\';

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

log_string = sprintf('data_session_%d.csv', pp);
param.log = [param.path, log_string];

eds_string = sprintf('%d_%d.asc', pp, unique_numbers(pp));
param.eds = [param.path, eds_string];