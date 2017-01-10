function [ newSpecies ] = uniqueSpecies( species, processSpecies )
%uniqueSpecies Finds elements of processSpecies which are not in species
%	This function creates a cell array of strings that are in
%	processSpecies but not in species.  Duplicates in processSpecies are
%	removed from the output

newSpecies = {};
for i = 1:length(processSpecies)
	nop = 1;
	if iscell(processSpecies(i))
		multSpecs = processSpecies(i);
		for j = 1:length(processSpecies(i))
			newSpecies = searchForSpecies(species, newSpecies, multSpecs{j});
		end
	else
		newSpecies = searchForSpecies(species, processSpecies(i));
	end
end

end

function[newSpecies] = searchForSpecies(species, newSpecies, specie)
	found = false;
	for j = 1:length(species)
		if (strcmp(species(j), specie))
			found = true;
		end
	end
	
	for j = 1:length(newSpecies)
		if (strcmp(newSpecies{j}, specie))
			found = true;
		end
	end
	
	if ~found
		newSpecies{end+1,1} = specie;
	end
end

