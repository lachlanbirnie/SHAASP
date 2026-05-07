function [ibm] = spec_ideal_binary_mask(mixture_spec, noise_spec, db_threshold)
% SPEC_IDEAL_BINARY_MASK - Get IBM mask for a mixture and noise spectrum.
%
% Syntax:  [ibm] = spec_ideal_binary_mask(mixture_spec, noise_spec, db_threshold)
%
% Inputs:
%   mixture_spec - [fbins, tbins, channels] spectrum of noise + signal.
%   noise_spec - [fbins, tbins, channels] spectrum of noise.
%   db_threshold - (default 5 dB) remove spec bins with SNR < threshold.
%
% Outputs:
%   ibm - [fbins, tbins, channels] mask, 1 = keep, 0 = remove.
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 02-Oct-2024
% Last revision: 02-Oct-2024

    arguments
        mixture_spec (:,:,:);
        noise_spec (:,:,:);
        db_threshold {mustBeScalarOrEmpty} = 5;
    end

    estimated_snr = abs(mixture_spec - noise_spec).^2 ./ abs(noise_spec).^2;
    estimated_snr(isnan(estimated_snr)) = inf;
    ibm = estimated_snr > 10^(0.1 * db_threshold);
end