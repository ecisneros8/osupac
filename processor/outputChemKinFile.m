function [ ] = outputChemKinFile( config, rates, species1, species2, ...
	species3 )
%outputChemKinFile Writes the ChemKin chemistry file including air plasma
%chemistry, the combustion chemistyr stored in config, including the full
%three sets of species

outFile = fopen(config('chemKinOutputFile'), 'w');
inFile = fopen(config('chemKinInputFile'), 'r');

% Find the begining of the elements block
line = fgetl(inFile);
while(length(line) < 4 || ~strcmp(line(1:4), 'ELEM'))
	line = fgetl(inFile);
end

% Copy everything in elements block until the END is found
while(length(line) < 3 || ~strcmp(line(1:3), 'END'))
	fprintf(outFile,'%s\n',line);
	line=fgetl(inFile);
end
fprintf(outFile, 'E \nEND\n\n');
% First, copy everything up to the start of the species block to the new
% file
line = fgetl(inFile);
while (length(line) < 7 || ~strcmp(line(1:7), 'SPECIES'))
	fprintf(outFile, '%s\n', line);
	line = fgetl(inFile);
end

% Write the species block to the file
fprintf(outFile,'SPECIES\n');
for i = 1:length(species1)
	if (~strcmp('M', species1(i)) && ~strcmp('(M)', species1(i)))
		fprintf(outFile, '%s\n', species1{i});
	end
end
for i = 1:length(species2)
	if (~strcmp('M', species2(i)) && ~strcmp('(M)', species2(i)))
		fprintf(outFile, '%s\n', species2{i});
	end
end
for i = 1:length(species3)
	if (~strcmp('M', species3(i)) && ~strcmp('(M)', species3(i)))
		fprintf(outFile, '%s\n', species3{i});
	end
end
fprintf(outFile,'END\n\n');

% Write Bolsig+ rate fits
fprintf(outFile, 'REACTIONS  KELVIN  MOLECULES\n\n');
fprintf(outFile, '!***************************************\n');
fprintf(outFile, '! BOLSIG+ Predicted E-Impact Rates\n');
fprintf(outFile, '!***************************************\n\n');

for i =1:length(rates)
	fprintf(outFile, '%s  ', formatProcess(rates(i).type, rates(i).reactant, ...
								   rates(i).product));
		
	fprintf(outFile, '%3.2e %3.2e 0.0 \n',...
		rates(i).fit(1)/11600^rates(i).fit(2), rates(i).fit(2));
	fprintf(outFile,'FIT1 /%3.2e  %3.2e  %3.2e  %3.2e /\n',...
		rates(i).fit(3)*11600, rates(i).fit(4)*11600^2, ...
		rates(i).fit(5)*11600^3,...
		rates(i).fit(6)*11600^4);
	
	fprintf(outFile, '  TDEP/E/\nEXCI/ %3.2f /\n', ...
		rates(i).excitationEnergy);

	if rates(i).dup
		fprintf(outFile, '  DUP\n');
	end

	fprintf(outFile, '\n');
	
end

% Write in VV, and air plasma chem
plasmaInFile = fopen(config('plasmaInputFile'),'r');
line = fgetl(plasmaInFile);
while (length(line) < 9 || ~strcmp(line(1:9), 'REACTIONS'))
	line = fgetl(plasmaInFile);
end

fprintf(outFile, ['! This section contains air-plasma chemistry, ',...
				  'including\n! VV and VT processes for N2\n\n']);
fprintf(outFile, ['! This reaction is to work around a bug in ',...
				  'ChemKin parsing\n! which applies the wrong units ',...
				  'to the reaction before a new REACTIONS block.\n\n']);
fprintf(outFile, '%s  ', formatProcess(rates(1).type, rates(1).reactant, ...
 					   rates(1).reactant));
fprintf(outFile, '0.0 0.0 0.0 \n');
fprintf(outFile, '  DUP \n\n');

while(length(line) < 3 || ~strcmp(line(1:3), 'END'))
	fprintf(outFile, '%s\n', line);
	line = fgetl(plasmaInFile);
end

fprintf(outFile, '\n\n');
fclose(plasmaInFile);

% Copy chemistry from chemkinInFile
line = fgetl(inFile);
while (length(line) < 9 || ~strcmp(line(1:9), 'REACTIONS'))
	line = fgetl(inFile);
end

fprintf(outFile, ['! This reaction is to work around a bug in ',...
				  'ChemKin parsing\n! which applies the wrong units ',...
				  'to the reaction before a new REACTIONS block.\n\n']);
fprintf(outFile, '%s  ', formatProcess(rates(1).type, rates(1).reactant, ...
 					   rates(1).reactant));
fprintf(outFile, '0.0 0.0 0.0 \n');
fprintf(outFile, '  DUP \n\n');

while(length(line) < 3 || ~strcmp(line(1:3), 'END'))
	fprintf(outFile, '%s\n', line);
	line = fgetl(inFile);
end

fprintf(outFile,'END\n');
fclose(inFile);
fclose(outFile);

end

