classdef ConfigParameter
	properties (SetAccess = private, GetAccess = public)
		name
		paramType
		unique
		required
		default
	end
	methods
		% Creates a new ConfigParameter
		% Parameters:
		% 	name - a string representing the key used in the configuration file 
		%		identify this configuration parameter
		%	type - the data type of the parameter.  Must be one of 'str', 'numeric',
		%		or 'bool'
		%	unique - boolean value as to whether multiple assignments can be 
		%		made to this configuration parameter.  If true, a second 
		%		assignment will cause an error.  If false, additional 
		%		assigments will be appended to either an array in the case
		% 		of boolean or numeric values, or a cell array in the case
		% 		of strings
		%	default - optional value that must match the expected type.  If
		%		provided, the configuration parameter is then assumed to be 
		%		optional.  If not provided, the configuration parameter is 
		%		assumed to be required, meaning that if it does not appear in 
		%		the configuration file, an error will be thrown
		function obj = ConfigParameter(name, paramType, unique, default)
			obj = setName(obj, name);
			obj = setType(obj, paramType);
			obj = setUnique(obj, unique);

			if nargin < 3
				error(['Too few parameters provided to constructor of ',...
					   'ConfigParameter']);
			elseif nargin == 3
				obj.required = true;
				obj = setDefault(obj);
			elseif nargin == 4
				obj.required = false;
				obj = setDefault(obj, default);
			else
				error(['Too many parameters provided to constructor of ',...
					   'ConfigParameter']);
			end
		end

		function name = get.name(obj)
			name = obj.name;
		end

		function paramType = get.paramType(obj)
			paramType = obj.paramType;
		end

		function unique = get.unique(obj)
			unique = obj.unique;
		end

		function required = get.required(obj)
			required = obj.required;
		end

		function default = get.default(obj);
			if ~obj.required
				default = obj.default;
			else
				error(['No default value for required ConfigParameter']);
			end
		end
	end

	methods (Access = private)
		function obj = setName(obj, name)
			if isa(name, 'char')
				obj.name = name;
			else
				error('Name of ConfigParameter must be of type string');
			end
		end

		function obj = setType(obj, paramType)
			switch paramType
				case 'numeric'
					obj.paramType = 'numeric';
				case 'str'
					obj.paramType = 'str';
				case 'bool'
					obj.paramType = 'bool';
				otherwise
					error('ConfigParameter:invalidParamType',...
						'Invalid configuration parameter type');
			end
		end
	
		function obj = setUnique(obj, unique)
			if islogical(unique)
				obj.unique = unique;
			else
				error('ConfigParameter:invalidUniqueValue',...
					'Configuration parameter unique must be a logical value');
			end
		end

		function obj = setDefault(obj, default)
			if nargin == 1
				% Do nothing
			elseif nargin == 2
				switch obj.paramType
					case 'numeric'
						if isnumeric(default)
							obj.default = default;
						else
							error(['Incorrect type for default value of ',...
								   'ConfigParameter']);
						end
					case 'str'
						if isa(default,'char')
							obj.default = default;
						else
							error(['Incorrect type for default value of ',...
								   'ConfigParameter']);
						end
					case 'bool'
						if isa(default, 'logical')
							obj.default = default;
						else
							error(['Incorrect type for default value of ',...
								   'ConfigParameter']);
						end
					otherwise
						error(['ConfigParameter.type has been initialize to ',...
							   'an invalid value']);
				end
			end
		end
	end		
end
