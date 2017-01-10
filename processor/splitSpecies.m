function [ species ] = splitSpecies( speciesStrings )
%splitSpecies Separates species that are stored in a single string
%	Takes a cell array of strings, and breaks each string based on location
%	of '+', returning a cell array of all the species, each trimmed of
%	leading and trailing white space.  This function also handles positive
%	ions, so long as the '+' signifying the ion is at the end of the ion's
%	name.

species = {};
for i = 1:length(speciesStrings)
	% Trim off white space from before or after the string
	trimSpecString = strtrim(speciesStrings{i});
	% Find all '+' characters in the string
	plusInds = find(trimSpecString == '+');
	
	% If a '+' appears at the end of the string, it must be connected to an
	% ion and not a separator for species so we simply ignore it
	if ~isempty(plusInds) && plusInds(end) == length(trimSpecString)
		plusInds(end) = [];
	end
	
	% Loop through each pair of adjacent '+''s and check if there are
	% non-space characters between them.  If there are only space
	% characters, the first '+' must be connected to an ion, and therefore
	% should be ignored.  The loop goes backwards since we are editing the
	% array in place.  This leads to some double checking, but no errors.
	for j = length(plusInds):-1:2
		if (sum(~isspace(trimSpecString(plusInds(j-1)+1:plusInds(j)-1)))==0)
			plusInds(j-1) = [];
		end
	end
	
	plusInds = [0, plusInds, length(trimSpecString)+1];
	for j = 2:length(plusInds)
		species{end+1} = strtrim(...
			trimSpecString(plusInds(j-1)+1:plusInds(j)-1));
	end
end

end

