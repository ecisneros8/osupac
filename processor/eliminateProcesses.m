function [ rateStruct ] = eliminateProcesses( rateStruct )
%eliminateProcesses Removes processes that do not have a product
%   This function removes processes from the rateStruct that do not have a
%   product species.  

for i = length(rateStruct):-1:1
	if isempty(rateStruct(i).product)
		rateStruct = removeRate(rateStruct, i);
	else
		for j = 1:length(rateStruct(i).product)
			if isempty(rateStruct(i).product{j})
				rateStruct = removeRate(rateStruct, i);
				break;
			end
		end
	end
end
fprintf('\n');

end

function [ rateStruct ] = removeRate(rateStruct, i)
	if strcmp(rateStruct(i).type, 'Elastic') || ...
		   strcmp(rateStruct(i).type, 'Effective (momentum)')
		disp(['Removing ', rateStruct(i).type, ' process for ',...
			  rateStruct(i).species{1}]);
	else
		disp(['Removing process: ', formatProcess(rateStruct(i).type,...
								rateStruct(i).species,...
								rateStruct(i).initProduct)]);
	end
	rateStruct(i) = [];
end

