function [ rateStructNew ] = combineProcesses( rateStruct )
%combineProcesses Combines processes with the same product species and same
%type, creating a new structure without extraneous columns
%   If two processes have the same type and same product species, and same
%   initial species, then the rates are combined into a single array prior
%   to fitting.  The excitation energy is chosen as the smallest of the
%   combined processes

rateStructNew = struct('reactant', {}, ...
					   'product', {},...
					   'type', {},...
					   'excitationEnergy', {},...
					   'rates', {},...
					   'dup', {});
i = 1;

while i <= length(rateStruct)
	% Initialize the structure with the single process we are looking for
	% duplicates of
	rateStructNew(i).reactant = rateStruct(i).species;
	rateStructNew(i).product = rateStruct(i).product;
	rateStructNew(i).type = rateStruct(i).type;
	rateStructNew(i).excitationEnergy = rateStruct(i).excEng;
	rateStructNew(i).rates = rateStruct(i).rates;
	rateStructNew(i).dup = false;
	
	% Find duplicates, storing their indices in the combining array
	combining = i;
	for j = length(rateStruct):-1:i+1
		% Ensure that the species being excited is the same and the type is
		% the same
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
			
			if isempty(products1) && isempty(products2)
				combining(end+1) = j;
			end
		end
	end
	
	% If there are processes being combined, print them to screen showing
	% the processes being combined and the final process
	if length(combining) > 1
		fprintf('Combining Processes: '); 
		for j = 1:length(combining)
			fprintf('%s, ', rateStruct(combining(j)).procNum);
		end
		fprintf('\b\b\n');
		for j = 1:length(combining)
			k = combining(j);
			fprintf('  %s: %s \n', rateStruct(k).procNum,...
						formatProcess(rateStruct(k).type,...
							rateStruct(k).species, ...
							rateStruct(k).initProduct));
		end
		fprintf('to form\n');
		fprintf('  %s \n\n', formatProcess(rateStructNew(i).type,...
								rateStructNew(i).reactant,...
								rateStructNew(i).product));
	end

	% Combine the rates, taking the minimum of the excitation energy
	for j = 2:length(combining)
		k = combining(j);
		rateStructNew(i).excitationEnergy = ...
			min(rateStructNew(i).excitationEnergy, ...
				rateStruct(k).excEng);
		rateStructNew(i).rates(:,2) = rateStructNew(i).rates(:,2) + ...
				rateStruct(k).rates(:,2);
	end

	% Remove processes that have been combined with another from the
	% structure array so they are not double counted.
	rateStruct(combining(2:end)) = [];

	i = i+1;
end
end
