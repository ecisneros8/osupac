function [ rateStructNew ] = markDuplicates( rateStruct )
%markDuplicates Finds duplicate reactions and creates a flag in the struct 
%signaling that fact
%	If two processes have the same type, the same product species, and the 
%	same initial species, then the reactions are flagged as duplicate.

rateStructNew = struct('reactant', {}, ...
					   'product', {},...
					   'type', {},...
					   'excitationEnergy', {},...
					   'rates', {},...
					   'dup', {});

for i = 1:length(rateStruct)
	rateStructNew(i).reactant = rateStruct(i).species;
	rateStructNew(i).product = rateStruct(i).product;
	rateStructNew(i).type = rateStruct(i).type;
	rateStructNew(i).excitationEnergy = rateStruct(i).excEng;
	rateStructNew(i).rates = rateStruct(i).rates;
	rateStructNew(i).dup = false;

	combining = i;
	for j = 1:length(rateStruct)
		if (strcmp(rateStruct(i).species, rateStruct(j).species) && ...
			strcmp(rateStruct(i).type, rateStruct(j).type))
			products1 = rateStruct(i).product;
			products2 = rateStruct(j).product;

			for n = length(products1):-1:1
				for m = length(products2):-1:1
					if strcmp(products1{n}, products2{m})
						products1(n) = [];
						products2(m) = [];
						break;
					end
				end
			end
			
			if isempty(products1) && isempty(products2) && (i~=j)
				combining(end+1) = j;
			end
		end
	end

	if length(combining) > 1
		rateStructNew(i).dup = true;
		fprintf('Marking Duplicate: %s matched with ', ...
			rateStruct(combining(1)).procNum);
		for j = 2:length(combining)
			fprintf('%s, ', rateStruct(combining(j)).procNum);
		end
		fprintf('\b\b\n');
	end
end
end
