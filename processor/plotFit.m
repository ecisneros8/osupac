function [ ] = plotFit(procNum, data, fitParams )
%plotFit Plots fit of rate data overlayed with data
%   This function takes an array of rate data and a set of fit parameters
%   and creates a comparison plot.  The data array must be two columns,
%   with the first column representing the temperature and the second
%   column representing the rate.  The fitParams array must be a vector
%   with six elements.  The fit has the form
%
%		k = a T^b exp(c/T + d/T^2 + e/T^3 + f/T^4)
%
%	where the fitParams array is
%
%		fitParams = [a; b; c; d; e; f];
%

fit1 = @(p, T) p(1)*T.^p(2).*exp(p(3)./T + p(4)./T.^2 + ...
							p(5)./T.^3 + 0./T.^4);
fit2 = @(p, T) p(1)*T.^p(2).*exp(p(3)./T + p(4)./T.^2 + ...
								p(5)./T.^3 + p(6)./T.^4);					

dataLimit = find(data(:,1) > 1 | data(:,2)/max(data(:,2)) > 1e-3, 1);
figure(1);

loglog(data(:,1), data(:,2),'x',...
	 linspace(0,20,1000), fit1(fitParams, linspace(0,20,1000)),'g',...
	 linspace(0,20,1000), fit2(fitParams, linspace(0,20,1000)),'m',...
	 [1e-2 1e3], [data(dataLimit,2) data(dataLimit,2)], 'r');
title(procNum);
ylim([max(data(:,2))/1e6 ...
	  max(data(:,2))*10]);
waitforbuttonpress;

end

