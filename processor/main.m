function [] = main( configFileName )
clc
close all

addpath config

%% Configuration file
% This file stores the inputs to the processing code, such as the paths to
% different input and output files, along with conversion of species names
% from BOLSIG+ to ChemKin
if (nargin == 0)
	configFileName = 'config.in';
end
configOptions = configSetup();
configParser = ConfigParser(configOptions);
config = configParser.parse(configFileName);

%% Bolsig Output
bolsigOutputFile = fopen(config('bolsigOutputFile'), 'r');

% Read in the rates from the BOLSIG+ output file, discarding the extra
% information
[~, ~, bolsigRates] = readBolsigOutput(bolsigOutputFile);

fclose(bolsigOutputFile);

%% Process Identification 
% Adds a new field to the bolsigRates structure which holds what the
% resulting species of each process is, taking that data from the Bolsig+
% cross section file
bolsigRates = findOutputSpecies(config('bolsigXSFile'), bolsigRates);
% Parse the product species string and break on the products on the 
% appropriate '+' signs.
for i = 1:length(bolsigRates)
	bolsigRates(i).initProduct = splitSpecies(bolsigRates(i).initProduct);
end
% Applies the requested renaming to output species from config.in
for i = 1:length(bolsigRates)
	bolsigRates(i).product = renameSpecies( config('extraParameters'), ...
											bolsigRates(i).initProduct);
end
% Eliminate processes without output species
bolsigRates = eliminateProcesses(bolsigRates);
% Now the species must be split again, since some species may be renamed
% into their dissociative products
for i = 1:length(bolsigRates)
	bolsigRates(i).product = splitSpecies(bolsigRates(i).product);
end

% Now depending on the configuration flag, either add the rates of 
% duplicate reactions or mark them as duplicate
if config('combineDuplicateBolsigReactions')
	% Combine processes which have the same resulting product
	bolsigRates = combineProcesses(bolsigRates);
else
	bolsigRates = markDuplicates(bolsigRates);
end

%% Fit Rates
% Append empty arrays to bolsigRates.fit so they can be calculated later
[bolsigRates.fit] = deal([]);

% Loop through each set of rates and create fits for the excitation and
% ionization processes
for i = 1:length(bolsigRates)
	fprintf('Fitting process: %s \n', formatProcess(bolsigRates(i).type,...
											   bolsigRates(i).reactant,...
											   bolsigRates(i).product));
	bolsigRates(i).fit = calcRateFit(config, ...
									 bolsigRates(i).rates(:,1),...
									 bolsigRates(i).rates(:,2));

	if ~config('silent')
		plotFit(bolsigRates(i).product, bolsigRates(i).rates,...
				bolsigRates(i).fit);
	end
end

close all
%% Merge ChemKin-Pro Data
% Read in the species from the Air Plasma Chem file and make sure that the
% species there handle all the species from Bolsig+
airPlasmaSpec = readChemKinSpecs(config('plasmaInputFile')).';
bolsigSpec = {};
for i = 1:length(bolsigRates)
	bolsigSpec{end+1} = bolsigRates(i).reactant{1};
	for j = 1:length(bolsigRates(i).product)
		bolsigSpec{end+1} = bolsigRates(i).product{j};
	end
end
uniqueBolsigSpecs = uniqueSpecies(airPlasmaSpec, bolsigSpec);

isCell = false;
for i = 1:length(uniqueBolsigSpecs)
	if iscell(uniqueBolsigSpecs{i})
		isCell = true;
	end
end

if isCell
	uniqueBolsigSpecs = [uniqueBolsigSpecs{:}];
end

if ~isempty(uniqueBolsigSpecs)
	fprintf(['\n\nHere are species which have processes from Bolsig+ \n'...
			 'with fit rates, but do not appear in the air plasma  \n',...
			 'chemistry mechanism.  If any nitrogen or oxygen species \n',...
			 'are listed, make sure the renaming command in config.in \n',...
			 'are correct\n']);
	disp(uniqueBolsigSpecs.')
end

% Read in the species from the ChemKin chemistry file
species = readChemKinSpecs(config('chemKinInputFile')).';
% find the species that are unique to the air plasma chemistry
uniquePlasmaSpecies = uniqueSpecies(species, airPlasmaSpec).';

% At this point, the full set of species required for the ChemKin file is
% [species, uniquePlasmaSpecies, uniqueBolsigSpecs].  
outputChemKinFile(config, bolsigRates, species,...
				  uniquePlasmaSpecies, uniqueBolsigSpecs);
								
end
