function [ formattedString ] = formatProcess( type, reactant, product )
%formatProcess Formats a human readable string representing the electron
%impact process
%   Depending on the type, the reactant, and the product, formats a string
%   represeting the process in a chemical reaction form
formattedString = ['E + ', reactant{1}];

for i = 1:length(product)
	if (strcmp(product{i}, 'M') || strcmp(product{i}, '(M)'))
		formattedString = [formattedString, ' + ', product{i}];
		break;
	end
end

formattedString = [formattedString, ' => '];

for i = 1:length(product) - 1
	formattedString = [formattedString, product{i}, ' + '];
end
formattedString = [formattedString, product{end}];


switch (type)
	case 'Excitation'
		formattedString = [formattedString, ' + E'];
	case 'Ionization'
		formattedString = [formattedString, ' + E + E'];
	case 'Attachment'
	otherwise
		warning(['Attempting to format process type: ', type]);
end

end

