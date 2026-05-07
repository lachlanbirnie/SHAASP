function [M, el_mesh, az_mesh] = sfd_music(rec, fs, mic_xyz, num_src, options)
% function [M, T, P] = sfd_music(rec, fs, mic_xyz, num_src, options)
% SFD_MUSIC - Source localisation from microphone array recording.
% MUlitple SIgnal Classification source localisation.
%
% Syntax:  [M, T, P] = shmusic(alpha, num_src, r, k, options)
%
% Inputs:
%   rec - (samples, mics)
%   fs - 
%   mic_xyz - [Q by (x,y,z)]
%   num_src - Number of sources to localise.
%
%   Options:
%   ngrid - [360] number of steering directions per (theta, phi) axis.
%   logscale - [true] convert MUSIC spectra to dB log scale.
%   f_plot - [false] plot the MUSIC spectra. 
%   h_fig - figure handle to plot the MUSIC spectra on.
%
% Outputs:
%   M - [T,P] MUSIC spectra for (theta, phi) meshgrid positions.
%   el_mesh - Theta meshgrid values for M.
%   az_mesh - Phi meshgrid values for M.
%
% See also: sph_music,  
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 20-Jan-2025
% Last revision: 20-Jan-2025

% NOT TESTED!

arguments
    rec (:,:)
    fs
    mic_xyz (:,3)
    num_src = 1
    options.ngrid = 360
    options.logscale = true;
    options.f_plot = false;
    options.h_fig = [];
end

% STFT settings.
wlen = 512;
hop = wlen/2;
nfft = 2 * wlen;
wind = shaasp.cola_window(wlen, hop, 'wola');
single_sided = true;
binf = shaasp.cola_nfft_bin_frequencies(fs, nfft, single_sided);
c = 343;
bink = 2 .* pi .* binf ./ c;

% Create localisation / plotting grid.
t = linspace(0, pi, floor(options.ngrid/2)).';
p = linspace(0, 2*pi, options.ngrid).';
[Theta,Phi] = meshgrid(t,p);
M = zeros(size(Theta));

% Measurement STFT.
Pk = shaasp.cola_stft(rec, nfft, hop, wind, single_sided);  % [K,T,Q]
Pk = permute(Pk, [3,2,1]);  % [Q,T,K]

% Covariance.
R = pagemtimes(Pk, 'none', Pk, 'ctranspose');  % [Q,Q,K]

% MUSIC
Mk = zeros(size(Theta));
M = zeros([size(Theta), length(bink)]);
for indf = (1 : numel(bink))
    % Noise subspace.
    [U,~,~] = svd(R(:,:,indf));
    Un = U(:, num_src+1:end);

    % Steering vectors.
    str_kyhat = shaasp.rtp2xyz(bink(indf), Theta(:), Phi(:));
    str_kyx = mic_xyz * str_kyhat.';  % [Q,L]
    str_vec = exp(1i .* str_kyx);

    % MUSIC spectrum.
    Mk(:) = 1 ./ sum(abs(Un' * str_vec ).^2, 1);
    M(:,:,indf) = Mk;
end

    % Average over frequencies.
    Mave = sum(M, 3, 'omitmissing');
    Mave = Mave ./ max(abs(Mave(:)));

if options.logscale
    Mave = 10 .* log10(Mave);
end

% Return average.
M = Mave;
el_mesh = Theta;
az_mesh = Phi;
  
% Plot MUSIC spectra.
if ~nargout || options.f_plot
    
    if options.logscale
        cmin = -40;
        M(M < cmin) = cmin;
    else
        cmin = 10^(-40/20);
        M(M < cmin) = cmin;
    end

    if isempty(options.h_fig)
        options.h_fig = figure('Color', [1,1,1]);
    end

    surf(rad2deg(Theta), rad2deg(Phi), M, 'EdgeColor', 'interp');
    
    view(-90, -90);
    xlabel('theta');
    xlim(rad2deg([min(Theta(:)), max(Theta(:))]));
    ylabel('phi');
    ylim(rad2deg([min(Phi(:)), max(Phi(:))]));
    axis('square');
end
end