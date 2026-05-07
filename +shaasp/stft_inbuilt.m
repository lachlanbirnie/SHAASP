function [spec, f, t] = stft_inbuilt(sig, nfft, hop, wind, single_sided, fs)
% Inputs:
%   sig - [samples, channels]
%   nfft - scalar, nfft number of samples.
%   wind - [samples], window.
%   hop - scalar, hop number of samples.
%   single_sided - bool, return half or all fft-bins.
%
% Outputs:
%   spec - [fbins, tbins, channels] spectrum of signal.
%
%   - Requires fs input - 
%   tbin_sec [tbins] time value in seconds for each time frame.
%   fbin_hz - [fbins] frequency value of each nfft-bin.

arguments
    sig (:,:)
    nfft {mustBeScalarOrEmpty}
    hop {mustBeScalarOrEmpty} = nfft
    wind (:,1) = ones(nfft, 1)
    single_sided logical = false
    fs {mustBeScalarOrEmpty} = []
end

if single_sided
    freq_range = 'onesided';
else
    freq_range = 'twosided';
end

wlen = length(wind);

if isempty(fs)
    spec = stft( ...
        sig, ...
        'FFTLength', nfft, ...
        'OverlapLength', wlen - hop, ...
        'Window', wind, ...
        'OutputTimeDimension', 'acrosscolumns', ...
        'FrequencyRange', freq_range);
    f = [];
    t = [];
else
    [spec, f, t] = stft( ...
        sig, ...
        fs, ...
        'FFTLength', nfft, ...
        'OverlapLength', wlen - hop, ...
        'Window', wind, ...
        'OutputTimeDimension', 'acrosscolumns', ...
        'FrequencyRange', freq_range);
end

end