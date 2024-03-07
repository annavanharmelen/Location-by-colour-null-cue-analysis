%% Import extra behavioural data, like task confusion score etc.
% 19-06-2023, by Anna

%% load data
data_path = "C:\Users\annav\Documents\Jottacloud\Neuroscience\Year 2\Thesis\Data\Vidi1 - null-cue gaze-bias\Vidi1 Experiment participantlog\Vidi1 participantlog.xlsx";
data = readtable(data_path);

% change strings to boolean
data.ParticipatedInSimilairExperimentsBefore = strcmpi(data.ParticipatedInSimilairExperimentsBefore, 'Yes');

%% Grab task-confusion data
taskconfusion_scores = flip([data.Session, data.Task_confusion], 1);
