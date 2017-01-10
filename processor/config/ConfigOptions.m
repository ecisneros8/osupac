classdef ConfigOptions < handle
	properties (SetAccess = private, GetAccess = public)
		commentChars
		extraParamsAllowed
		parameters
	end
	methods
		% Creates a default ConfigOptions object
		function obj = ConfigOptions()	
			obj.commentChars = '%';
			obj.extraParamsAllowed = false;
		end	
		
		% Getter returning a character array of the comment characters
		function chars = get.commentChars(obj)
			chars = obj.commentChars;
		end
		
		% Removes all comment characters
		function obj = clearCommentChars(obj)
			obj.commentChars = '';
		end

		% Add a single comment character
		function obj = addCommentChars(obj, chars)
			if ~isa(chars, 'char')
				error('ConfigOptions:InvalidCommentChar', ...
					  'Comment Characters must be of type character');
			end

			obj.commentChars = [obj.commentChars, chars];
		end

		function obj = allowExtraParams(obj)
			obj.extraParamsAllowed = true;
		end

		function obj = disallowExtraParams(obj)
			obj.extraParamsAllowed = false;
		end

		% Adds a new expected parameter to the configuration 
		function addParameter(obj, param)
			if isa(param, 'ConfigParameter') && isscalar(param)
				if isempty(obj.parameters)
					obj.parameters = param;
				else
					obj.parameters(end+1) = param;
				end
			else
				error('ConfigOptions.addParameter: Improper input');
			end
		end

		function result = isParameter(obj, paramName)
			result = false;
			for i = 1:length(obj.parameters)
				if strcmp(paramName, obj.parameters(i).name)
					result = true;
				end
			end
		end

		function paramType = getParamType(obj, paramName)
			if obj.isParameter(paramName)
				for i = 1:length(obj.parameters)
					if strcmp(paramName, obj.parameters(i).name)
						paramType = obj.parameters(i).paramType;
					end
				end
			else
				error('ConfigOptions:ParamNotFound', ...
					  'Attempting to get type of parameter ',...
					  'which isn''t stored');
			end
		end

		function unique = isUnique(obj, paramName)
			if obj.isParameter(paramName)
				for i = 1:length(obj.parameters)
					if strcmp(paramName, obj.parameters(i).name)
						unique = obj.parameters(i).unique;
					end
				end
			else
				error('ConfigOptions:ParamNotFound', ...
					  'Attempting to get uniqueness of parameter ',...
					  'which isn''t stored');
			end
		end

		function params = getOptionalParams(options)
			params = options.getParamsByRequiredValue(false);
		end

		function params = getRequiredParams(options)
			params = options.getParamsByRequiredValue(true);
		end

	end

	methods (Access = private)
		function params = getParamsByRequiredValue(options, reqVal)
			params = [];
			for i = 1:length(options.parameters)
				if options.parameters(i).required == reqVal
					if isempty(params)
						params = options.parameters(i);
					else
						params(end+1) = options.parameters(i);
					end
				end
			end
		end
	end
end
