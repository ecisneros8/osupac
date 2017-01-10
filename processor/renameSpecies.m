function [ renamedSpeciesList ] = renameSpecies( renameList, speciesList )
%renameProducts Changes the names of chemical species in speciesList based
%on the data in renameList
%   This function takes the speciesList and changes it based on 
%   the values in renameList, storing the result in renamedSpeciesList.  
%	renameList must be a 2 column cell array, the first column representing
%	the original name of species while the second column is the new name of
%	species.
%
%	It is assumed that the first column is unique, and that
%	values in the first column do not appear anywhere in the second column.
%	If the rename list was generated using parseConfigFile, these two
%	conditions are guarenteed by the validation of the configuration.


renamedSpeciesList = speciesList;
keys = renameList.keys;

for i = 1:length(keys);
	if length(renameList(keys{i})) > 1
		error('Attempting to rename species multiple time');
	end
	for j = 1:length(speciesList)
		if strcmp(keys{i}, speciesList{j})
			final = renameList(keys{i});
			renamedSpeciesList{j} = final{1};
		end
	end
end
end



