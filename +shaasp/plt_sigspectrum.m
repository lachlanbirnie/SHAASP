function [h_surf, spec] = plt_sigspectrum(sig, fs, nfft, wlen, hop, single_sided, dark_mode, new_fig)
% PLT_SIGSPECTRUM - Plot the spectrum of a signal.
%
% Syntax:  [h, spec] = plt_sigspectrum(sig, fs, dark_mode, normalise, new_fig)
%
% Inputs:
%   sig - [samples, channels] time domain signal.
%   fs  - sampling rate in Hz.
%   nfft - nfft size of frequency axis (default 2048).
%   wlen - window length of stft (default nfft).
%   hop - hop size for stft (default wlen / 2).
%   single_sided - bool, single or double stft (default true).
%   dark_mode - bool.
%   new_fig - bool, plot on a new figure handle.
%
% Outputs:
%   h_surf - Handle to surface object.
%   spec - [f, t, channels] spectrum data of the signal in dB.
%
% Other m-files required: cola_stft(), plt_spectrum().
% Subfunctions: none
% MAT-files required: none
%
% See also: plt_signal()
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 29-July-2024
% Last revision: 03-Oct-2024

arguments
    sig (:,:)
    fs {isscalar} = []
    nfft {isscalar} = 2048
    wlen {isscalar} = nfft
    hop {isscalar} = wlen / 2;
    single_sided {islogical} = true
    dark_mode {islogical} = true
    new_fig {islogical} = false
end

% Settings.
wind = ones(wlen, 1);
iscola(wind, nfft - hop, 'ola');

% Get signal's spectrum, and time frequency dimension values.
[spec, fbin_hz, tbin_sec] = shaasp.cola_stft(sig, nfft, hop, wind, single_sided, fs);

% dB scale.
spec = 20 .* log10(abs(spec));

% Plot spectrum.
[h_surf, spec] = shaasp.plt_spectrum(spec, nfft, fs, wlen, hop, dark_mode, new_fig);

end  % plt_sigspectrum.