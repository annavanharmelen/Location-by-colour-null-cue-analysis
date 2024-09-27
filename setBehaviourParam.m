function [bar_size, colours, dark_colours, labels, subplot_size, percentageok] = setBehaviourParam(pp2do)
%SETBEHAVIOURPARAM sets the parameters for analysing the behavioural data.
bar_size = 0.8;

colours = [hex2rgb("#3E8DD6"); hex2rgb("#D649C3"); hex2rgb("#27A579")];

dark_colours = [hex2rgb("#143756"); hex2rgb("#611F59"); hex2rgb("#004029")];
dark_colours = [dark_colours;dark_colours];

labels = {'location cue', 'colour cue'};

subplot_size = ceil(sqrt(size(pp2do, 2)));

percentageok = zeros(size(pp2do));

end

