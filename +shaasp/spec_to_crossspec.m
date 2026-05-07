function [cross_spec] = spec_to_crossspec(spec_a, spec_b)
% SPEC_TO_CROSSSPEC - Cross power spectral density of two spectrums.
%
% Syntax:  [cross_spec] = spec_to_crossspec(spec_a, spec_b);
%          [psd] = spec_to_crossspec(spec_a);
%
% Inputs:
%   spec_a - [fbins, tbins, channels_a]
%   spec_b - [fbins, tbins, channels_b]
%
% Outputs:
%   cross_spec - [fbins, tbins, channels_a, channels_b]
%
% Subfunctions: pagemtimes (matlab 2020b)
%
% See also: OTHER_FUNCTION_NAME1,
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 10-Jul-2023
% Last revision: 10-Jul-2023

if nargin == 1
    % Power spectral density if only one input spectrum.
    spec_b = spec_a;
end

% Reshape spectrums so (f,t) are last dimensions.
spec_a = permute(spec_a, [3,4,1,2]);  % [f,t,cha] -> [cha,1,f,t].
spec_b = permute(spec_b, [3,4,1,2]);  % [f,t,chb] -> [chb,1,f,t].

% (Cab = Sa x Sb^*) [cha,chb,f,t] = [cha,1,f,t] * [1,chb,f,t]
cross_spec = pagemtimes(spec_a, 'none', spec_b, 'ctranspose');

% Reshape cross spectrum for (f,t) being first dimensions [f,t,cha,chb].
cross_spec = permute(cross_spec, [3,4,1,2]);

end