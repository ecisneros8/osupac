function [ fitParams ] = calcRateFit( config, T, rate )
%calcRateFit Fits rates versus temperature, ensuring certain pathologies
%are not present
%   This function takes a temperature array and a rate array and fits the
%   rates with the functional form:
%	
%		k = a T^b exp(c/T + d/T^2 + e/T^3 + f/T^4)
%
%	where the fitParams array is
%
%		fitParams = [a; b; c; d; e; f];
%
%	A least squares fit is performed for the first five parameters,
%	ensuring good accuracy with the data.  The final parameter is then set
%	with the formula:
%
%		f = - T_crit * abs(e)
%
%	where T_crit is a low value.  This ensure that below T_crit, the fit is
%	dominated by the final term, and goes to zero rather than increasing to
%	infinity as T->0 from the right.

% Funtional form of the fit (is log of actual rates)
fit = @(p, T) log(p(1)) + p(2)*log(T)+p(3)./T + p(4)./T.^2 + p(5)./T.^3;
fullFit = @(p, T) p(1)*T.^p(2)*exp(p(3)./T + p(4)./T.^2 + p(5)./T.^3 + ...
						p(6)./T.^4);
% Preprocess the data.  This eliminates data points where the rate is at
% least three order of magnitude smaller than the maximum.
[T, rate] = preprocessRate(T, rate);

% Scale the rates by the value in the middle of the vector.  This is for
% numerical reasons and is undone below
midInd = floor(length(rate)/2);
scale = rate(midInd);

% Set options for the fitting procedure
options = statset('MaxIter',100000, ...
	              'FunValCheck', 'off');

% Initial Guess
fitParams = [1;0;1;0;0];
finalParam = 0;
oldFinalParam = 1;
rateLimited = false;

while abs((finalParam - oldFinalParam)/finalParam) > 1e-2
	if ~rateLimited
		rateCorr = rate./(exp(finalParam./T.^4));
	else
		rateCorr = rate;
	end

	oldFinalParam = finalParam;
	
	% Fit the rates
	fitParams = nlinfit(T, log(rateCorr/scale), fit, fitParams(1:5), ...
		options);

	% Find the final term driving the fit to 0 as T->0, and store for
	% convergence
	[fitParams(6), rateLimited] = findFinalParam(config, T, fitParams);
	finalParam = fitParams(6);
	
end

% Undo the scaling
fitParams(1) = fitParams(1)*scale;

end

function [T, rate] = preprocessRate(T, rate)
T(rate==0) = [];
rate(rate==0) = [];

rMax = max(rate);
normR = rate/rMax;

indices = (normR < 1e-3) & (T < 1);
T(indices) = [];
rate(indices) = [];
end

function [finalParam, rateLimited] = findFinalParam(config, T, fit)
% Set the final parameter, this ensures that the final term in the
% exponential dominates at low T such that the fit goes to zero as T goes
% to zero
%
% This is done by ensuring the final term of the fit dominates below a
% certain critical T.  If T_crit is too low, there may be local maxima
% between the lowest data point and zero.  If it is too high, it can affect
% the quality of the fit at the lower points.  
%
% The parameter is set through an iterative process, a T_crit is guessed,
% then the value is moved upward or downward by factors of 1.1, until for
% two neighboring points the upper point has no local maxima while the
% lower point does.  The parameter is then set based on the upper T_crit
kMax = config('kmax');
Timp = config('TeSS');
minTCrit = -Timp^4/abs(fit(5))*(log(kMax/(fit(1)*Timp^fit(2))) - ...
	fit(3)/Timp -...
	fit(4)/Timp^2 - fit(5)/Timp^3);

TCrit = max(2*minTCrit,min(T)/4);
foundNoMaxima = false;
foundMaxima = false;
largeEnough = true;
rateLimited = false;

while largeEnough && (~foundNoMaxima || ~foundMaxima)
	fit(6) = - TCrit*abs(fit(5));
	
	% Check for maxima or minima in the region between 0 and the minimum data
	% point
	polyCoefs = [fit(2), -fit(3), -2*fit(4), ...
				-3*fit(5), -4*fit(6)];
	extrema = roots(polyCoefs);

	realExtrema = extrema(extrema == real(extrema));
	problemExtrema = realExtrema((realExtrema >=0) & (realExtrema < min(T)));
	
	if isempty(problemExtrema)
		foundNoMaxima = true;
		TCritReal = TCrit;
		TCrit = TCrit/1.1;
	else
		foundMaxima = true;
		TCrit = TCrit*1.1;
		TCritReal = TCrit;
	end
	
	if TCritReal<minTCrit
		largeEnough = false;
		TCritReal = minTCrit;
		rateLimited = true;
	end

end

finalParam = -TCritReal*abs(fit(5));
TCrit = TCritReal;
end

