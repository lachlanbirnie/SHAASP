function [smoothed_spec, bin_freqs] = spectrum_octave_smoothing(spec, nfft, fs, b, wind_method)
% SPECTRUM_OCATVE_SMOOTHING - 1/b fractional octave smoothing for spectrum.
% A algorithm to smooth the FFT of an impulse response (or other spectra)
% by averaging over octaves / fractional octaves. I am not confident on the
% accuracy of my implementation as I am just focused on making a nice plot.
%
% The method follows:
% 
% For each NFFT bin (denoted k) find the smoothed spectrum value.
%
%   Set the frequency of the k-th bin as the octave center freqency.
%
%   Find the octave's lower and upper edge frequencies using the
%   formula from MATLAB poctave function.
%   (https://au.mathworks.com/help/signal/ref/poctave.html)
%
%   Account for the miss-match between the actual ocatve edge frequencies
%   and the frequency values of the nearest NFFT bin. By assigning a 
%   weight to the edge bins for the amount of percentages overlap between
%   the octave and the bin. Following the description in the MATLAB poctave
%   function (https://au.mathworks.com/help/signal/ref/poctave.html)
%
%   Create a window for the octave to sum over for a smoothed value.
%   Three options:
%
%       'basic-rectangle' - Rectangle window, apply equal weight to each
%       bin in the octave. This has a bias to the smoothed value where both
%       low and high frequencies are given equal weight even though there
%       are more high frequencies in an octave than low.
%       Similar approach to: AARAE toolbox 'octavesmoothing.m'
%       (https://github.com/densilcabrera/aarae)
%
%       'basic-hann' - Apply a Hann window over the octave. Similar to the
%       rectangle window. The middle of the hann window will not match the
%       center frequency of the octave, so this is probably not a good
%       approach.
%
%       'log-compensated' - Following the approach of Method 3 by J. P.
%       Tylka in A Generalized Method for Fractional-Octave Smoothing of
%       Transfer Functions that Perserves Log-Frequency Symmery, AES, 2017.
%       (https://doi.org/10.17743/jaes.2016.0053) 
%       This method creates a window over the octave that has symmetric
%       weight to the low and high frequencies in a log-scale.
%
%   Apply the window to the octave and sum to get the smoothed spectra
%   value.
% 
% Syntax:  [smoothed_spec] = function_name(spec, nfft, fs, b, wind_method)
%
% Inputs:
%   spec - [bins, channels] frequency response / spectrum data.
%   nfft - NFFT size of the frequency response / spectrum.
%   fs - Sampling frequency of the frequency response / spectrum.
%   b - Number of bands per octave for 1/b-octave smoothing.
%   wind_method - 'basic-rectrangle' 'basic-hann' 'log-compensated'
%
% Outputs:
%   smoothed_spec - [bins, channels] smoothed spec single sided.
%   bin_freqs - Frequencies of the spectrum bins.
%
% Example: 
% spec = zeros(2049, 1);
% spec(200,1) = 1;
% nfft = 4096;
% fs = 48000;
% b = 1;
% rec_spec = spectrumOctaveSmoothing(spec,nfft,fs,1,'basic-rectangle');
% hann_spec = spectrumOctaveSmoothing(spec,nfft,fs,1,'basic-hann');
% comp_spec = spectrumOctaveSmoothing(spec,nfft,fs,1,'log-compensated');
% figure('Color',[1 1 1]);
% semilogx(spec,'k','LineWidth',2,'DisplayName','Unsmooth spectra');
% hold on;
% semilogx(rec_spec,'g','LineWidth',2,'Displayname','Rectangle window');
% semilogx(hann_spec,'r','LineWidth',2,'Displayname','Hann window');
% semilogx(comp_spec,'b','LineWidth',2,'DisplayName','log-compensated');
% legend('show');
% ylim([0 0.05]);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ...
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: May 2024
% Last revision: 20-May-2024
%
% References:
%
%   https://au.mathworks.com/matlabcentral/fileexchange/55161-1-n-octave-smoothing
%   https://dsp.stackexchange.com/questions/16635/1-n-octave-complex-smoothing
%   https://doi.org/10.17743/jaes.2016.0053
%   https://au.mathworks.com/help/signal/ref/poctave.html

% Default octave smoothing.
if nargin < 4
    b = 1;
end

% Default use log-compensated smoothing window.
if nargin < 5
    wind_method = 'log-compensated';
end

% Make spectrum single sided if not already.
nfft_is_odd = ~mod(nfft, 2);
if size(spec, 1) == nfft
    if nfft_is_odd
        spec = spec(1 : nfft/2+1, :);
    else
        spec = spec(1 : ceil(nfft/2), :);
    end
end

% Find frequency of each nfft bin.
bin_freqs = linspace(0, fs, nfft+1).';
bin_freqs = bin_freqs(1 : end-1);
if nfft_is_odd
    bin_freqs = bin_freqs(1 : nfft/2+1);
else
    bin_freqs = bin_freqs(1 : ceil(nfft/2));
end
bin_bw = bin_freqs(2);  % Bandwidth of nfft bins.
bin_total = numel(bin_freqs);  % Total number of nfft bins.

% Smooth each sample in the spectrum.
smoothed_spec = zeros(size(spec));

% Exit if no smoothing applied.
if isempty(b)
    smoothed_spec = spec;
    return
end

% k denotes the index of the center bin to be smoothed.
for k = (1 : bin_total)

    % Find frequencies for fractional octave given the kth bin as center.
    oct_cen_freq = bin_freqs(k);  % Center frequency.
    oct_low_freq = oct_cen_freq * 10^(0.3)^(-1/(2 * b));
    oct_up_freq = oct_cen_freq * 10^(0.3)^(1/(2 * b));   % EQ from matlab.

    % Truncate the octave band to Nyquist.
    if oct_up_freq > bin_freqs(bin_total)
        oct_up_freq = bin_freqs(bin_total);
    end
    
    % Find bins nearest to the octave edges.
    [~, bin_low_ind] = min(abs(bin_freqs - oct_low_freq));
    [~, bin_up_ind] = min(abs(bin_freqs - oct_up_freq));

    % Make sure lower bin is below octave lower edge frequency.
    if bin_freqs(bin_low_ind) > oct_low_freq
        bin_low_ind = bin_low_ind - 1;
    end

    % Make sure upper bin bin is above octave upper edge frequency.
    if bin_freqs(bin_up_ind) < oct_up_freq
        bin_up_ind = min(bin_up_ind + 1, bin_total);
    end

    oct_num_bins = bin_up_ind - bin_low_ind + 1;  % Total bins in octave.

    % - Account for octave edge falling in the middle of a bin - 

    % Following MATLAB octave smoothing description.
    % (https://au.mathworks.com/help/signal/ref/poctave.html)
    % Assign percentage weights to the edge bins for how much overlap there
    % is between the bin's bandwidth and the octave.

    % Percent of the lowest bin that contains the octave band.
    bin_low_freq = bin_freqs(bin_low_ind);
    lower_edge_weight = 1 - (oct_low_freq - bin_low_freq) / bin_bw;

    % Percent of the upper bin that contains the octave band.
    bin_up_freq = bin_freqs(bin_up_ind);
    upper_edge_weight = 1 - (bin_up_freq - oct_up_freq) / bin_bw;
    
    % - Make octave window - 

    % Basic Method) window over the fractional octave.
    if strcmp(wind_method, 'basic-rectangle')
        wind = ones(oct_num_bins, 1) ./ oct_num_bins;
    end

    if strcmp(wind_method, 'basic-hann')
        wind = hann(oct_num_bins) ./ ((oct_num_bins-1) / 2);
    end

    % AES Paper Method 3) Logarithmically-compensated window.
    % (https://doi.org/10.17743/jaes.2016.0053)
    if strcmp(wind_method, 'log-compensated')
        % Need to find the value of the window for every k' centered
        % around the k-th bin by integrating a rectangle window.
        kdashes = (bin_low_ind : 1 : bin_up_ind).';
        
        % % Old version that shows the process.
        % wind = zeros(numel(kdashes), 1);
        % for ind_kd = 1 : numel(kdashes)
        %     kd = kdashes(ind_kd);  % Solve the window's value for k'. 
        % 
        %     % Find the limits of integration for k'.
        %     phi_l = log2((kd - 0.5) / k);  % Lower limit Eq.17.
        %     phi_u = log2((kd + 0.5) / k);  % Upper limit Eq.17.
        % 
        %     % Truncate to only include Phi's that are inside the octave.
        %     % From Eq.15 Wr = 0 if abs(phi) > 1/(2b).
        %     phi_l = max(phi_l, -1/(2*b));
        %     phi_u = min(phi_u, 1/(2*b));
        % 
        %     % Width is how much of the window overlaps the octave.
        %     % If phu_u - phi_l is negative then there is no overlap.
        %     width = max(phi_u - phi_l, 0);
        % 
        %     % Height is b for a rectangle window. (Eq.15 in paper).
        %     height = b;
        % 
        %     % Approx integral of rectangle function Wr as it's area.
        %     W_k_kdash = width * height;  % Eq.16.
        %     wind(ind_kd) = W_k_kdash;
        % end
        
        % % Faster version to solve all k' at the same time.
        phi_edges = log2(([kdashes(1)-1; kdashes] + 0.5) / k);
        lower_phis = max(phi_edges(1:oct_num_bins), -1/(2*b));
        upper_phis = min(phi_edges(2:oct_num_bins+1), 1/(2*b));
        widths = max(upper_phis - lower_phis, 0);
        wind = widths .* b;

    end

    % Apply edge weights to window.
    wind(1) = wind(1) * lower_edge_weight;
    wind(oct_num_bins) = wind(oct_num_bins) * upper_edge_weight;
    
    % Scale window to keep unit area.
    wind = wind ./ sum(wind);

    % Apply window to the octave and sum.
    smoothed_spec(k, :) = sum(spec(bin_low_ind:bin_up_ind, :) .* wind, 1);
end

% Plot spectra and smoothed spectra if no output.
if nargout < 1
    figure('Color', [1 1 1]);
    line_colors = [[0, 0, 0]; [1, 0.6, 0.3]; [0.3, 1, 0.6]; [0.6, 0.3, 1]];
    for ch = (1 : size(spec, 2))
        s1 = semilogx(bin_freqs, spec(:,ch), ...
            '-', ...
            'DisplayName', 'Original spectra', ...
            'HandleVisibility', 'off');
        hold on;
        s2 = semilogx(bin_freqs, smoothed_spec(:,ch), ...
            '-', ...
            'LineWidth', 2.5, ...
            'DisplayName', sprintf('Smoothed Spectra %i', ch));

        if ch <= size(line_colors, 1)
            set(s1, 'Color', [line_colors(ch,:), 0.3]);
            set(s2, 'Color', [line_colors(ch,:), 1]);
        else
            col = get(s1, 'Color');
            set(s1, 'Color', [col, 0.3]);
            set(s2, 'Color', [col, 1]);
        end
    end
    xlim([20, 24000]);
    xlabel('Freqency (Hz)');
    ylabel('Magnitude');   
    legend('show', 'Location', 'northwest');
    title(sprintf('1/%3.1f Fractional Octave Smoothed Spectra', b));
    set(gca, 'FontSize', 14, 'XGrid', 'on');
end

end  % spectrumOctaveSmoothing()

% % %% Debugging
% % % Compare integrating the rectangle window with Riemann Sum and area of a 
% % % rectangle for the log-compensated method.
% % 
% % % Settings.
% % b = 1;
% % k = 10;
% % kdashes = (floor(k*2^(-1/(2*b))) : ceil(k*2^(+1/(2*b))));
% % 
% % % Riemann sum.
% % wind = zeros(numel(kdashes), 1);
% % for ind_kd = 1 : numel(kdashes)
% %     kd = kdashes(ind_kd); % Build window each k-dash at a time. 
% % 
% %     phi_l = log2((kd - 0.5) / k);  % By integrating from phi_l
% %     phi_u = log2((kd + 0.5) / k);  % to phi_u.
% % 
% %     % Approximate continueous functions phi with discrete points.
% %     res = 10000;
% %     phi = linspace(phi_l, phi_u, res);
% % 
% %     % Find values of phi that are in the octave. 
% %     inoct_phi = (abs(phi) <= 1/(2*b));
% % 
% %     % Create normalized rectangle window that is 1 when phi is in the
% %     % octave and 0 outside. 
% %     w = zeros(res, 1); 
% %     w(inoct_phi) = b;
% % 
% %     % Approximately integrate over this window by neumerical integration.
% %     delta_phi = phi(2) - phi(1);
% %     wind(ind_kd) = sum(w * delta_phi);
% % end
% % 
% % figure;
% % stem(wind, 'k', 'LineWidth', 2.5);
% % 
% % % Area of rectangle.
% % wind = zeros(numel(kdashes), 1);
% % for ind_kd = 1 : numel(kdashes)
% %     kd = kdashes(ind_kd);  %
% % 
% %     phi_l = log2((kd - 0.5) / k);
% %     phi_u = log2((kd + 0.5) / k);
% % 
% %     phi_l = max(phi_l, -1/(2*b));
% %     phi_u = min(phi_u, 1/(2*b));
% % 
% %     width = max(phi_u - phi_l, 0);
% % 
% %     height = b;
% %     wind(ind_kd) = width * height;
% % end
% % 
% % hold on;
% % stem(wind, 'r-.', 'LineWidth', 1.5);