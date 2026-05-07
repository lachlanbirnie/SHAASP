function [sig] = istft_inbuilt(spec, nfft, hop, wind)
% Inputs:
%   spec - [fbins, tbins, channels] spectrum of signal.
%   nfft - scalar, nfft number of samples.
%   hop - scalar, hop number of samples.
%   wind - [samples], window.
%
% Outputs:
%   sig - [samples, channels]

arguments
    spec (:,:,:)
    nfft {mustBeScalarOrEmpty}
    hop {mustBeScalarOrEmpty} = nfft
    wind (:,1) = []
end

if isempty(wind)
    cola_method = 'ola';
    wlen = nfft;
    wind = ones(wlen, 1) .* (hop / nfft);
else
    cola_method = 'wola';
    wlen = length(wind);
end

if (size(spec, 1) == nfft)
    freq_range = 'twosided';
    conj_symm = true;
else
    freq_range = 'onesided';
    conj_symm = true;
end

sig = istft( ...
    spec,  ...
    'FFTLength', nfft, ...
    'OverlapLength', wlen - hop, ...
    'method', cola_method, ...
    'Window', wind, ...
    'InputTimeDimension', 'acrosscolumns', ...
    'FrequencyRange', freq_range, ...
    'ConjugateSymmetric', conj_symm);

end