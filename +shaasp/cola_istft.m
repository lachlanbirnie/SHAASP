function [sig] = cola_istft(spec, nfft, hop, wind)
% COLA_ISTFT - my Inverse Short Time Fourier Transform.
%
% Syntax:  [sig] = cola_istft(spec, nfft, wind, hop)
%
% Inputs:
%   spec - [fbins, tbins, channels] spectrum of signal.
%   nfft - scalar, nfft number of samples.
%   hop - scalar, hop number of samples.
%   wind - [samples], window.
%
% Outputs:
%   sig - [samples, channels]
%
%
% Notes:
%
%   - The 'wind' input is only used for WOLA (weighted-overlap-add) method.
%   - If the spectrum is processed in the STFT domain, then OLA should be
%   used instead of WOLA, and the window input should not be provided.
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: cola_stft,  cola_window
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 10-Jul-2023
% Last revision: 20-Sept-2024

arguments
    spec (:,:,:)
    nfft {mustBeScalarOrEmpty}
    hop {mustBeScalarOrEmpty} = nfft
    wind (:,1) = ones(nfft, 1)
end

wlen = length(wind);
total_frames = size(spec, 2);
total_samples = total_frames * hop + wlen - hop;

wind_zeropad = [wind; zeros(nfft - wlen, 1)];

sig = zeros(total_samples, size(spec, 3));

for ind_frame = (0 : total_frames - 1)
    frame_samples = (ind_frame * hop + 1 : ind_frame * hop + wlen);
    spec_frame = spec(:, ind_frame + 1, :);
    sig_frame = ifft(spec_frame, nfft, 1, "symmetric");
    sig_frame = real(sig_frame) .* wind_zeropad;
    sig(frame_samples, :) = sig(frame_samples, :) + sig_frame(1:wlen, :);
end

end