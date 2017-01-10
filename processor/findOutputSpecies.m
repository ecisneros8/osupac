function [ rateStruct ] = findOutputSpecies( XSFileName, rateStruct )
%findOutputSpecies Finds the resulting species for each process
%   This function parses the cross section file used by Bolsig+ and finds
%   which rates go with which excited state.

XSFile = fopen(XSFileName, 'r');

procCount = containers.Map;

readUntilBreak(XSFile);

[rateStruct.initProduct] = deal({});
running = true;
while running
typeString = getBlockType(XSFile);
	switch (typeString)
		case 'COMMENT'
			readUntilBreak(XSFile);
		case 'ELASTIC'
			procCount = skipProcess(XSFile, procCount);
		case 'EFFECTIVE'
			procCount = skipProcess(XSFile, procCount);
		case 'ATTACHMENT'
			[procCount, rateStruct] = setProduct(XSFile, procCount, ...
				rateStruct);
		case 'EXCITATION'
			[procCount, rateStruct] = setProduct(XSFile, procCount, ...
				rateStruct);
		case 'IONIZATION'
			[procCount, rateStruct] = setProduct(XSFile, procCount, ...
				rateStruct);
		case ['+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-',...
			  '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-',...
			  '+-+-+-+-+-+']
			running = false;
		otherwise
			readUntilBreak(XSFile);
			readUntilBreak(XSFile);
			disp(typeString);
	end

end

fclose(XSFile);
end

function readUntilBreak(file)
	line=fgetl(file);
	while ~((length(line)>=5) && strcmp('-----',line(1:5)))
		line = fgetl(file);
	end
end

function typeString = getBlockType(XSFile)
line = fgetl(XSFile);

while (sum(isspace(line))==length(line))
	line = fgetl(XSFile);
end

typeString = strtrim(line);
end

function procCount = skipProcess(XSFile, procCount)
	spec = findReactant(fgetl(XSFile));
	addProcess(procCount, spec);
	readUntilBreak(XSFile);
	readUntilBreak(XSFile);
end

function procCount = addProcess(procCount, reactant)
	if isKey(procCount, reactant)
		procCount(reactant) = procCount(reactant) + 1;
	else
		procCount(reactant) = 1;
	end
end

function spec = findReactant(string)
	arrowBeginning = find(string=='-');
	if isempty(arrowBeginning)
		endReact = length(string);
	else
		for i = 1:length(arrowBeginning)
			if (arrowBeginning(i)~=length(string)) && ...
			   (string(arrowBeginning(i) + 1) == '>')
				if string(arrowBeginning(i) - 1) =='<'
					endReact = arrowBeginning(i) - 2;
				else
					endReact = arrowBeginning(i) - 1;
				end
			end
		end
	end
	
	spec = strtrim(string(1:endReact));
end

function spec = findProduct(string)
	arrowBeginning = find(string=='-');
	if isempty(arrowBeginning)
		startProd = 1;
	else
		for i = 1:length(arrowBeginning)
			if (arrowBeginning(i)~=length(string)) && ...
			   (string(arrowBeginning(i) + 1) == '>')
					startProd = arrowBeginning(i) + 2;
			end
		end
	end
	
	spec = strtrim(string(startProd:end));
end

function [procCount, rateStruct] = setProduct(XSFile, procCount,...
											rateStruct)
	process = fgetl(XSFile);
	react = findReactant(process);
	product = findProduct(process);
	procCount = addProcess(procCount, react);
	
	processNum = procCount(react);
	
	matchReactant = [];
	for i = 1:length(rateStruct)
		matchReactant(end+1) = strcmp(rateStruct(i).species, react);
	end
	processIndices = find(matchReactant, processNum);
	
	if ~isempty(processIndices)
		rateStruct(processIndices(end)).initProduct{end+1} = product;
	end

	readUntilBreak(XSFile);
	readUntilBreak(XSFile);
end