function [spec, fbin_hz, tbin_sec] = cola_stft(sig, nfft, hop, wind, single_sided, fs)
% COLA_STFT - My Short Time Fourier Transform.
%
% Syntax:  [spec, fbin_hz, tbin_sec] = cola_stft(sig, nfft, hop, wind, single_sided, fs)
%
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
%
% Example: 
%   Line 1 of example
%   Line 2 of example
%   Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: cola_istft
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 10-Jul-2023
% Last revision: 20-Sept-2024

arguments
    sig (:,:)
    nfft {mustBeScalarOrEmpty}
    hop {mustBeScalarOrEmpty} = nfft
    wind (:,1) = ones(nfft, 1)
    single_sided logical = false
    fs {mustBeScalarOrEmpty} = []
end

wlen = length(wind);
sig_nsamples = size(sig, 1);
sig_nchannels = size(sig, 2);
total_frames = ceil((sig_nsamples - wlen + hop) / hop);
total_padded_samples = total_frames * hop + wlen - hop;
sig_padded = [sig; zeros(total_padded_samples - sig_nsamples, sig_nchannels)];

if single_sided
    if ~mod(nfft, 2)
        fbin_index = (1 : nfft/2+1);
    else
        fbin_index = (1 : ceil(nfft/2));
    end
else
    fbin_index = (1 : nfft);
end

spec = zeros(numel(fbin_index), total_frames, sig_nchannels);

for ind_frame = (0 : total_frames - 1)
    frame_samples = (ind_frame * hop + 1 : ind_frame * hop + wlen);
    sig_frame = sig_padded(frame_samples, :) .* wind;
    % Note that the fft function zero pads the frame to nfft size.
    spec_frame = fft(sig_frame, nfft, 1);
    spec_frame = spec_frame(fbin_index, :);
    spec(:, ind_frame + 1, :) = spec_frame;
end

if isempty(fs) || (nargout == 1)
    fbin_hz = [];
    tbin_sec = [];
else
    tbin_sec = shaasp.cola_time_bins_seconds(sig_nsamples, wlen, hop, fs);
    fbin_hz = shaasp.cola_nfft_bin_frequencies(fs, nfft, single_sided);
end

end