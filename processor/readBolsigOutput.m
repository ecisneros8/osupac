function [ parameters, swarm, rates ] = ...
                readBolsigOutput( bolsigOutputFile )
%readBolsigOutput Reads output file of BOLSIG+ and returns the information
%in MATLAB friendly data structures
%	This function parses (or calls other functions that parse) the output
%	of BOLSIG+.  There are three main portions to the output, each of which
%	are stored in a separate output:
%		1) parameters - Parameters which deal with the basic settings of
%		BOLSIG+.  These do not change as different E/N cases are run.  They
%		include information such as gas temperature, mixture composition,
%		and numerical parameters and tolerances.  See the BOLSIG+ documentation
%		for the meaning of these parameters
%			Angular field frequency / N (m^3/s)	- parameters('omegaN')
%			Gas Temperature (K)					- parameters('Tg')
%			Ionization Degree					- parameters('ionFrac')
%			Electron Density (/m^3)				- parameters('ne')
%			Longitudinal Diffusion				- parameters('longDiff')
%			Energy Sharing						- parameters('energyShare')
%			Grown Model							- parameters('growthMod')
%			Maxwellian Mean Energy (eV)			- parameters('maxMeanEng')
%			# of grid points					- parameters('numGridPts')
%			Grid type							- parameters('gridType')
%			Precision							- parameters('precision')
%			Convergence							- parameters('convergence')
%			Maximum # of Iterations				- parameters('maxIters')
%		Additionally parameters('MoleFrac') contains another map holding the
%		mole fractions of each input species.  To access this data evaluate code
%		similar to:
%			moleFrac = parameters('MoleFrac');
%			x_i = moleFrac('i');
%		where i is the name of the component you which to get the mole fraction
%		of
%		2) swarm - Parameters which change with each different E/N.  Some 
%		are electron swarm parameters such as Mean electron temperature or 
%		transport coefficients (diffusion and mobility), while others are
%		also numerical, such as maximum energy or number of iterations.
%			E/N (Td)							- swarm('E/N')
%			Mean Energy (eV)					- swarm('Ebar')
%			Max Energy (eV)						- swarm('EMax')
%			Mobility x N (1/m/V/s) 				- swarm('muN')
%			Diffusion coefficient x N (1/m/s)	- swarm('diffN')
%			Longitudinal dif. coef. x N (1/m/s)	- swarm('longDiffCoefN')
%			Energy Mobility x N (1/m/V/s)		- swarm('EMobN')
%			Energy diffusion coef. x N (1/m/s)	- swarm('EDiffCoefN')
%			Imaginary mobility x N (1/m/V/s)	- swarm('ImMobN')
%			Total collision freq. / N (m^3/s)	- swarm('TotCollFreqN')
%			Effect. momentum freq. / N (m^3/s)	- swarm('MomCollFreqN')
%			Effect. mom. transfer fraction		- swarm('MomTransFrac')
%			Temporal growth coef. (m^3/s)		- swarm('TempGrowthCoef')
%			Spatial growth coef. (m^2)			- swarm('SpatGrowthCoef')
%			Power / N (eV m^3/s)				- swarm('PowN')
%			Elastic power loss / N (eV m^3/s)	- swarm('ElasPowLossN')
%			Inelastic power loss / N (eV m^3/s)	- swarm('InelPowLossN')
%			Number of iterations				- swarm('numIters')
%			Number of grid trials				- swarm('numGrids')
%			Error code							- swarm('err')
%		3) rates - This is a set of data which stores the calculated rates
%		for electron impact processes versus electron temperature.  It is a
%		structure, with the following format for the i-th process:
%			rates(i).procNum		- BOLSIG+ assigned number, e.g. C3
%			rates(i).species		- Species which is the collision
%									partner for the electron in this
%									process
%			rates(i).type			- Type of process: 'Elastic',
%									'Excitation', 'Ionization',
%									'Attachment', 'Effective (momentum)'
%			rates(i).excEng			- Excitation energy of the process
%			rates(i).rates			- Array with 2 columns.  The first
%									column is electron temperature (same as
%									swarm('EBar')/1.5) in units of eV and 
%									the second column is the rate 
%									coefficient of the process in cm^3/s

parameters = readBolsigParameters(bolsigOutputFile);

swarm = readBolsigSwarm(bolsigOutputFile);

rates = readBolsigRates(bolsigOutputFile);

end

function [parameters] = readBolsigParameters(bolsigOutputFile)

% Initialize the container that will be returned
parameters = containers.Map;
parameters('MoleFrac') = containers.Map;

first = true;
line = '';

% Loop for as long as there is content in the line
while first || ~isempty(line)
	% Read in the next line from the file
	line = fgetl(bolsigOutputFile);	

	% If the line has contents, parse them
	if (~isempty(line))
		% The first 35 characters are the portion detailing what the 
		% stored value represents
		parameter = line(1:35);
		% Pull the numeric value from the end of the string
		data = sscanf(line(36:end), '%f');

		% Call a function which inserts the parameter into the
		% appropriate location in the container depending on the first
		% portion of the line
		parameters = setParameter(parameters, parameter, data);
	end
	first = false;
end

end

function [parameters] = setParameter(parameters, parameter, data)
% Trim trailing spaces off the parameter string
parameter = strtrim(parameter);
% If it starts with 'Mole fraction', insert into the internal map,
% with the key be the tail of the string which holds the species name
if (strcmp('Mole fraction', parameter(1:min(13,length(parameter)))))
	moleFrac = parameters('MoleFrac');
	moleFrac(parameter(15:end)) = data;
	parameters('MoleFrac') = moleFrac;
else
	% If the parameter string does not start with 'Mole fraction', 
	% pull off the other parameters, and store in the upper level 
	% map.  If it is not found, throw an error because there is a 
	% line in the BOLSIG+ output file that is not expected.
	switch parameter
	case 'Angular field frequency / N (m3/s)'
		parameters('omegaN') = data;
	case 'Gas temperature (K)'
		parameters('Tg') = data;
	case 'Ionization degree'
		parameters('ionFrac') = data;
	case 'Electron density (1/m3)'
		parameters('ne') = data;
	case 'Longitudinal diffusion'
		parameters('longDiff') = data;
	case 'Energy sharing'
		parameters('energyShare') = data;
	case 'Growth model'
		parameters('growthMod') = data;
	case 'Maxwellian mean energy (eV)'
		parameters('maxMeanEng') = data;
	case '# of grid points'
		parameters('numGridPts') = data;
	case 'Grid type'
		parameters('gridType') = data;
	case 'Precision'
		parameters('precision') = data;
	case 'Convergence'
		parameters('convergence') = data;
	case 'Maximum # of iterations'
		parameters('maxIters') = data;
	otherwise
		error(['Unhandled parameter: ' parameter]);
	end
end
end

function [swarm] = readBolsigSwarm(bolsigOutputFile)

% Initialize returned container
swarm = containers.Map;

line = '';

% Read in all the swarm values
while ~isFullSwarm(swarm)
	% Read non-empty lines that appear at the end of tables (usually fits to data)
	while ~isempty(line)
		line = fgetl(bolsigOutputFile);
	end

	% Read empty lines between tables in BOLSIG+ output file
	while isempty(line)
		line = fgetl(bolsigOutputFile);
	end

	% Store header line for later
	headerLine = line;
	% Loop through table, looking for either empty line or line that begins with
	% 'F' since the ends of tables hold a line stating 'Fit coefficients ...'
	line = fgetl(bolsigOutputFile);
	while (~isempty(line) && line(1) ~= 'F')
		data = sscanf(line, '%f %f');
		swarm = setSwarm(swarm, headerLine, data);
		line = fgetl(bolsigOutputFile);
	end
end

end

function [swarm] = setSwarm(swarm, headerLine, data)
headerLine = strtrim(headerLine);
switch headerLine
	case 'Energy (eV) 	Electric field / N (Td)'
		swarm = appendToArray(swarm, 'E/N', data(2));
		swarm = appendToArray(swarm, 'Ebar', data(1));
	case 'Energy (eV) 	Maximum energy'
		swarm = appendToArray(swarm, 'EMax', data(2));
	case 'Energy (eV)	Mean energy (eV)'
		% Do nothing, already stored above
	case 'Energy (eV)	Mobility x N (1/m/V/s)'
		swarm = appendToArray(swarm, 'muN', data(2));
	case 'Energy (eV)	Diffusion coefficient x N (1/m/s)'
		swarm = appendToArray(swarm, 'diffN', data(2));
	case 'Energy (eV)	Longitudinal dif. coef. x N (1/m/s)'
		swarm = appendToArray(swarm, 'longDiffCoefN', data(2));
	case 'Energy (eV)	Energy mobility x N (1/m/V/s)'
		swarm = appendToArray(swarm, 'EMobN', data(2));
	case 'Energy (eV)	Energy diffusion coef. x N (1/m/s)'
		swarm = appendToArray(swarm, 'EDiffCoefN', data(2));
	case 'Energy (eV)	Imaginary mobility x N (1/m/V/s)'
		swarm = appendToArray(swarm, 'ImMobN', data(2));
	case 'Energy (eV)	Total collision freq. / N (m3/s)'
		swarm = appendToArray(swarm, 'TotCollFreqN', data(2));
	case 'Energy (eV)	Effect. momentum freq. / N (m3/s)'
		swarm = appendToArray(swarm, 'MomCollFreqN', data(2));
	case 'Energy (eV)	Effect. mom. transfer fraction'
		swarm = appendToArray(swarm, 'MomTransFrac', data(2));
	case 'Energy (eV)	Temporal growth coef. (m3/s)'
		swarm = appendToArray(swarm, 'TempGrowthCoef', data(2));
	case 'Energy (eV)	Spatial growth coef. (m2)'
		swarm = appendToArray(swarm, 'SpatGrowthCoef', data(2));
	case 'Energy (eV)	Power / N (eV m3/s)'
		swarm = appendToArray(swarm, 'PowN', data(2));
	case 'Energy (eV)	Elastic power loss / N (eV m3/s)'
		swarm = appendToArray(swarm, 'ElasPowLossN', data(2));
	case 'Energy (eV)	Inelastic power loss / N (eV m3/s)'
		swarm = appendToArray(swarm, 'InelPowLossN', data(2));
	case 'Energy (eV)	# of iterations'
		swarm = appendToArray(swarm, 'numIters', data(2));
	case 'Energy (eV)	# of grid trials'
		swarm = appendToArray(swarm, 'numGrids', data(2));
	case 'Energy (eV)	Error code'
		swarm = appendToArray(swarm, 'err', data(2));
	otherwise
		error(['Unhandled swarm header: ' headerLine]);
end
end

function [isFull] = isFullSwarm(swarm)
isFull = (length(swarm) == 20);
end

function [map] = appendToArray(map, key, value)
	if isKey(map, key)
		map(key) = [map(key); value];
	else
		map(key) = value;
	end
end

function [rates] = readBolsigRates(bolsigOutputFile)

% Initialize the structure that will hold the rates
rates = struct('procNum', {}, ...
			   'species', {}, ...
			   'type', {}, ...
			   'excEng', {}, ...
			   'rates', {});
		   
readingRates = true;
line = ' ';
while readingRates
	% Read non-empty lines that appear at the end of tables (usually fits to data)
	while ~isempty(line)
		line = fgetl(bolsigOutputFile);
	end

	% Read empty lines between tables in BOLSIG+ output file
	while isempty(line)
		line = fgetl(bolsigOutputFile);
	end
	
	% Store header line for later
	headerLine = line;
	
	% Read in 1 more line and ensure we are reading a rate coefficient
	% table
	line = fgetl(bolsigOutputFile);
	if (strcmp('Energy (eV)	Rate coefficient (m3/s)', line))
		% Initialize this process in the rates structure array
		strings = strsplit(headerLine, '   ');

		rates(end+1).procNum = strings{1};
		rates(end).species{end+1} = strtrim(strings{2});
		rates(end).type = strtrim(strings{3});

		if strcmp(rates(end).type, 'Ionization') || ...
		   strcmp(rates(end).type, 'Excitation')
			rates(end).excEng = sscanf(strings{4}, '%f');
		else
			rates(end).excEng = 0;
		end
		rates(end).rates = zeros(0,2);
		% Loop through table, looking for either empty line or line that 
		% begins with 'F' since the ends of tables hold a line stating 
		% 'Fit coefficients ...'
		line = fgetl(bolsigOutputFile);
		while (~isempty(line) && line(1) ~= 'F')
			data = sscanf(line, '%f %f').';
			rates(end).rates(end+1,:) = data(1,1:2);
			% Convert from mean energy to Te
			rates(end).rates(end,1) = rates(end).rates(end,1)/1.5;
			% Convert from m^3/s to cm^3/s
			rates(end).rates(end,2) = rates(end).rates(end,2)*1e6;
			line = fgetl(bolsigOutputFile);
		end
	else
		readingRates = false;
	end
end

end
