classdef ConfigParser < handle
	properties (Access = private)
		options
		fID
		config
	end

	methods
		function parser = ConfigParser(configOptions);
			% Store the ConfigOptions object which holds information regarding
			% the behavior of the parser
			if ~isa(configOptions, 'ConfigOptions');
				error('ConfigParser:InvalidOptions', ...
					  'Object of type ConfigOptions required');
			end
			parser.options = configOptions;
		end

		function config = parse(parser, configFilePath)
			% Parse the file at the given file path using the rules stored in
			% options
			parser.openConfigFile(configFilePath);
			config = containers.Map;

			while ~feof(parser.fID)
				parser.parseLine(fgetl(parser.fID), config);
			end

			parser.finalizeConfig(config);
			fclose(parser.fID);
		end
	end

	methods (Access = private)
		function openConfigFile(parser, filePath)
			parser.fID = -1;
			parser.fID = fopen(filePath, 'r');

			if parser.fID < 0
				error('ConfigParser:FileNotFound', ...
					  'Failed to open file at provided path');
			end
		end

		function parseLine(parser, line, config)
			% Handle the special case where the file is empty.  fgetl will 
			% return once with a value -1
			if line == -1
				return
			end

			line = parser.removeComment(line);
			if (length(line) > 0)
				equals = (line == '=');
				if sum(equals) == 1
					entry = parser.getParamAndValue(line);
					if (parser.options.isParameter(entry{1}))
						parser.appendExpectedParam(entry, config);
					elseif (parser.options.extraParamsAllowed)
						parser.appendExtraParam(entry, config);
					else
						error('ConfigParser:ExtraParam', ...
							  ['Unallowed extra parameter included in ', ...
							   'config file: ', entry{1}]);
					end
				else
					error('ConfigParser:ParsingFailure', ...
				  		'More than one equals sign on a single line');
				end
			end
		end

		function line = removeComment(parser, line)
			line = strtrim(line);
			for i = 1:length(line)
				if sum(line(i) == parser.options.commentChars) > 0
					line(i:end) = '';
					break;
				end
			end
		end

		function entry = getParamAndValue(parser, line)
			splitStr = strsplit(line, '=');
			splitStr{1} = strtrim(splitStr{1});
			splitStr{2} = strtrim(splitStr{2});
			entry = splitStr;
		end

		function appendExpectedParam(parser, entry, config)
			if parser.options.isUnique(entry{1})
				if isKey(config, entry{1})
					error('ConfigParser:UnallowedDuplicateParam', ...
					  	  'Unique parameter is declared twice in config file');
				end
				config(entry{1}) = parser.convertParamType(entry);
			else
				parser.addDuplicateParam(entry, config);
			end
		end

		function addDuplicateParam(parser, entry, config)
			if strcmp(parser.options.getParamType(entry{1}), 'str')
				if ~isKey(config, entry{1})
					config(entry{1}) = {};
				end
				value = config(entry{1});
				value{end+1} = parser.convertParamType(entry);
				config(entry{1}) = value;
			else
				if ~isKey(config, entry{1})
					config(entry{1}) = [];
				end
				value = config(entry{1});
				value(end+1) = parser.convertParamType(entry);
				config(entry{1}) = value;
			end
		end

		function appendExtraParam(parser, entry, config)
			if ~isKey(config, 'extraParameters')
				config('extraParameters') = containers.Map;
			end
			
			map = config('extraParameters');
			if ~isKey(map, entry{1})		
				map(entry{1}) = {};
			end
			
			cellArray = map(entry{1});
			cellArray{end+1} = entry{2};
			map(entry{1}) = cellArray;
			config('extraParameters') = map;
		end
		
		function value = convertParamType(parser, entry)
			paramType = parser.options.getParamType(entry{1});

			switch paramType
				case 'numeric'
					value = str2num(entry{2});
				case 'str'
					value = entry{2};
				case 'bool'
					if strcmp('true', lower(entry{2}))
						value = true;
					elseif strcmp('false', lower(entry{2}))
						value = false;
					end
			end
		end

		function finalizeConfig(parser, config)
			optionalParams = parser.options.getOptionalParams();
			for i = 1:length(optionalParams)
				if ~isKey(config, optionalParams(i).name)
					config(optionalParams(i).name) = optionalParams(i).default;
				end
			end

			requiredParams = parser.options.getRequiredParams();
			for i = 1:length(requiredParams)
				if ~isKey(config, requiredParams(i).name)
					error('ConfigParser:MissingRequiredParameter', ...
						 ['Parameter ''', requiredParams(i).name, ...
						  ''' expected in configuration file but not found']);
				end
			end
		end
	end
end
