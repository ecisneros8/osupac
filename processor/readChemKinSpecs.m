function [ species ] = readChemKinSpecs( filePath )
%readChemKinSpecs Creates a list of species included in a ChemKin formatted
%chemistry file
file = fopen(filePath, 'r');

% Find the start of the species section
line = fgetl(file);
while (length(line) < 7 || ~strcmp(line(1:7), 'SPECIES'))
	line = fgetl(file);
end

% Loop through each line parsing the species and storing them
species = {};
line = fgetl(file);
while(length(line) < 3 || ~strcmp(line(1:3), 'END'))
	species = getSpecies(species, line);
	line = fgetl(file);
end

fclose(file);

end

function [species] = getSpecies(species, line)
% Throw away the comments at the end of the line
commentDelim = find(line=='!');
if ~isempty(commentDelim)
	line = line(1:commentDelim-1);
end

% Loop through line storing the species
line = strtrim(line);
while sum(isspace(line)) > 0
	firstSpace = find(isspace(line),1);
	species{end+1} = line(1:firstSpace - 1);
	line = strtrim(line(firstSpace:end));
end
species{end+1} = line;


end