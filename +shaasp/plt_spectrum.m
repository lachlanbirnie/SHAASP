function [h_surf, spec] = plt_spectrum(spec, nfft, fs, wlen, hop, dark_mode, new_fig)
% PLT_SPECTRUM - Plot a spectrum.
%
% Syntax:  [h_surf, spec] = plt_spectrum(spec, nfft, fs, wlen, hop, dark_mode, new_fig)
%
% Inputs:
%   spec - [f, t, channels] spectrum.
%
%   - Optional -
%   nfft - NFFT size for spectrum.
%   fs  - sampling rate in Hz.  (needed for Hz axis)
%   wlen - window length used for spectrum.  (needed for time axis)
%   hop - hop size used for spectrum.  (needed for time axis)
%   dark_mode - bool.
%   new_fig - bool, plot on a new figure handle.
%
% Outputs:
%   h_surf - Handle to surface object.
%   spec - [f, t, channels] spectrum data that was plotted.
%
% Other m-files required: none
% Subfunctions: fire().
% MAT-files required: none
%
% See also: plt_sigspectrum()
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 30-July-2024
% Last revision: 04-Oct-2024

% Optional inputs.
arguments
    spec (:,:,:)
    nfft {isscalar} = []
    fs {isscalar} = []
    wlen {isscalar} = []
    hop {isscalar} = []
    dark_mode {islogical} = true;
    new_fig {islogical} = false;
end

spec_nbins = size(spec, 1);
spec_nframes = size(spec, 2);
spec_nchannels = size(spec, 3);

% Find frequency axis values.
if isempty(fs) || isempty(nfft)
    fbin_vals = (1 : spec_nbins);
    fbin_label = 'Frequency Bin Index';
else
    if (nfft == spec_nbins)
        single_sided = false;
    else
        single_sided = true;
    end
    fbin_vals = shaasp.cola_nfft_bin_frequencies(fs, nfft, single_sided);
    fbin_label = 'Frequency (Hz)';
    if max(fbin_vals) > 20000
        fbin_vals = fbin_vals ./ 1000;
        fbin_label = 'Frequency (kHz)';
    end
end

% Find time axis values.
if ~isempty(fs) && ~isempty(wlen) && ~isempty(hop)
    total_samples = spec_nframes * hop + wlen - hop;
    tbin_vals = linspace(0, total_samples/fs, spec_nframes);
    tbin_label = 'Time (sec)';
else
    tbin_vals = (1 : spec_nframes);
    tbin_label = 'Time Frame Index';
end

% Check if spectrum is complex.
if ~isreal(spec)
    spec = abs(spec);
end

% Find color axis values.
mean_spec = mean(spec(~isinf(spec)));
var_spec = var(spec(~isinf(spec)));
cmin = max(min(spec(~isinf(spec))), mean_spec - var_spec) / 2;
cmax = min(max(spec(~isinf(spec))), mean_spec + var_spec) / 2;

% Remove -inf and NaN for plotting.
spec(isinf(spec)) = intmin;  % Replace log10(0) = -inf -> intmin

% Plotting.
if new_fig
    figure('Color', [1, 1, 1]);
end

if spec_nchannels > 1
    tiledlayout('flow', 'TileSpacing', 'normal', 'Padding', 'normal');
end

for i = (1 : spec_nchannels)

    if spec_nchannels > 1
        nexttile;
    end

    h_surf = surf(tbin_vals, fbin_vals, spec(:,:,i), ...
        'EdgeColor', 'interp', ...
        'FaceColor', 'interp');

    view(2);
    xlabel(tbin_label);
    ylabel(fbin_label);
    cbar = colorbar('Color', [0, 0, 0,]);
    ylabel(cbar, 'Magnitude');
    colormap(jet(128));
    xlim([0, tbin_vals(end)]);
    ylim([0, fbin_vals(end)]);
    clim([cmin, cmax]);
    set(gca, 'FontSize', 18);
    title(sprintf('%i',i), 'Color', [0,0,0]);

    % Dark mode colors.
    if dark_mode
        colormap(fire(128));
        cbar.Color = [1, 1, 1];
        set(gcf, 'Color', [0, 0, 0]);
        set(gca ...
            ,'MinorGridColor',[1 1 1] ...
            ,'GridColor'     ,[1 1 1] ...
            ,'Color'         ,[0 0 0] ...
            ,'XColor'        ,[1 1 1] ...
            ,'YColor'        ,[1 1 1] ...
            );
        title(sprintf('%i',i), 'Color', [1,1,1]);
    end

end


    function p = fire(m)
        % FIRE   Blue-Purple Hot colormap
        %
        % FIRE(M) returns an M-by-3 matrix containing a "fire" colormap.
        % FIRE, by itself, is the same length as the current figure's
        % colormap. If no figure exists, MATLAB creates one.
        %
        % To add this colormap as a default map, use 'addpath' with the
        % directory containing 'fire.m'.
        %
        % To reset the colormap of the current figure use 'colormap(fire)'.
        %
        % see also:  HSV, GRAY, HOT, COOL, BONE, COPPER, FLAG, PINK, COLORMAP,
        % RGBPLOT.
        %
        % To create any custom colormap, see the directions on line 23 of this
        % m-file.
        %
        % CITE:
        %   Tristan Ursell (2024). Fire and/or Custom Colormap Function
        %   (https://www.mathworks.com/matlabcentral/fileexchange/
        %    35730-fire-and-or-custom-colormap-function),
        %   MATLAB Central File Exchange. Retrieved July 29, 2024.
        %
        % LICENCE:
        % Copyright (c) 2012, Tristan Ursell
        % All rights reserved.
        %
        % Redistribution and use in source and binary forms, with or without
        % modification, are permitted provided that the following conditions are met:
        %
        % * Redistributions of source code must retain the above copyright notice, this
        %   list of conditions and the following disclaimer.
        %
        % * Redistributions in binary form must reproduce the above copyright notice,
        %   this list of conditions and the following disclaimer in the documentation
        %   and/or other materials provided with the distribution
        % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
        % AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
        % IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        % DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
        % FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
        % DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
        % SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
        % CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
        % OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
        % OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

        if nargin < 1
            m = size(get(gcf,'colormap'),1);
        end

        %You can replace this M x 3 matrix with any matrix whose values range
        %between 0 and 1 to create a new colormap file.  Use copy / paste to create
        %a matrix like the one below, you do not have to add these values
        %manually.  To create a new colormap, change 'cmap_mat' to the desired
        %matrix, rename the function *and* the m-file from 'fire' to your desired
        %colormap name.

        cmap_mat=[
            0         0         0
            0         0    0.0275
            0         0    0.0588
            0         0    0.0863
            0         0    0.1176
            0         0    0.1490
            0         0    0.1765
            0         0    0.2078
            0         0    0.2392
            0         0    0.2549
            0         0    0.2706
            0         0    0.2902
            0         0    0.3059
            0         0    0.3216
            0         0    0.3412
            0         0    0.3569
            0.0039         0    0.3765
            0.0157         0    0.3922
            0.0275         0    0.4078
            0.0392         0    0.4235
            0.0510         0    0.4431
            0.0627         0    0.4588
            0.0745         0    0.4745
            0.0863         0    0.4902
            0.0980         0    0.5098
            0.1098         0    0.5255
            0.1216         0    0.5412
            0.1333         0    0.5608
            0.1451         0    0.5765
            0.1569         0    0.5922
            0.1686         0    0.6118
            0.1804         0    0.6275
            0.1922         0    0.6471
            0.2039         0    0.6588
            0.2157         0    0.6706
            0.2275         0    0.6863
            0.2392         0    0.6980
            0.2510         0    0.7098
            0.2627         0    0.7255
            0.2745         0    0.7373
            0.2863         0    0.7529
            0.2980         0    0.7647
            0.3098         0    0.7804
            0.3216         0    0.7922
            0.3333         0    0.8078
            0.3451         0    0.8196
            0.3569         0    0.8353
            0.3686         0    0.8471
            0.3843         0    0.8627
            0.3961         0    0.8627
            0.4078         0    0.8667
            0.4196         0    0.8706
            0.4314         0    0.8745
            0.4431         0    0.8784
            0.4549         0    0.8824
            0.4667         0    0.8863
            0.4784         0    0.8902
            0.4902         0    0.8784
            0.5020         0    0.8706
            0.5137         0    0.8627
            0.5255         0    0.8549
            0.5373         0    0.8471
            0.5490         0    0.8392
            0.5608         0    0.8314
            0.5725         0    0.8235
            0.5804         0    0.8078
            0.5882         0    0.7922
            0.5961         0    0.7804
            0.6039         0    0.7647
            0.6118         0    0.7490
            0.6196         0    0.7373
            0.6275         0    0.7216
            0.6353         0    0.7098
            0.6392         0    0.6941
            0.6431         0    0.6784
            0.6510         0    0.6627
            0.6549         0    0.6510
            0.6588         0    0.6353
            0.6667         0    0.6196
            0.6706         0    0.6039
            0.6784         0    0.5922
            0.6824         0    0.5765
            0.6863         0    0.5608
            0.6941         0    0.5490
            0.6980         0    0.5333
            0.7020         0    0.5176
            0.7098         0    0.5059
            0.7137         0    0.4902
            0.7216         0    0.4784
            0.7255         0    0.4627
            0.7294         0    0.4471
            0.7373         0    0.4353
            0.7412         0    0.4196
            0.7451         0    0.4039
            0.7529         0    0.3922
            0.7569         0    0.3765
            0.7647         0    0.3647
            0.7686    0.0039    0.3490
            0.7765    0.0118    0.3333
            0.7804    0.0196    0.3216
            0.7882    0.0275    0.3059
            0.7922    0.0314    0.2902
            0.8000    0.0392    0.2784
            0.8039    0.0471    0.2627
            0.8118    0.0549    0.2510
            0.8157    0.0627    0.2353
            0.8196    0.0745    0.2196
            0.8235    0.0824    0.2078
            0.8314    0.0941    0.1922
            0.8353    0.1059    0.1765
            0.8392    0.1137    0.1647
            0.8431    0.1255    0.1490
            0.8510    0.1373    0.1373
            0.8549    0.1451    0.1216
            0.8627    0.1569    0.1059
            0.8667    0.1686    0.0902
            0.8745    0.1804    0.0784
            0.8784    0.1882    0.0627
            0.8863    0.2000    0.0471
            0.8902    0.2118    0.0314
            0.8980    0.2235    0.0196
            0.9020    0.2314    0.0157
            0.9059    0.2431    0.0118
            0.9137    0.2549    0.0118
            0.9176    0.2667    0.0078
            0.9216    0.2745    0.0039
            0.9294    0.2863    0.0039
            0.9333    0.2980         0
            0.9412    0.3098         0
            0.9451    0.3176         0
            0.9529    0.3294         0
            0.9569    0.3412         0
            0.9647    0.3529         0
            0.9686    0.3608         0
            0.9765    0.3725         0
            0.9804    0.3843         0
            0.9882    0.3961         0
            0.9882    0.4039         0
            0.9882    0.4118         0
            0.9922    0.4196         0
            0.9922    0.4275         0
            0.9922    0.4353         0
            0.9961    0.4431         0
            0.9961    0.4510         0
            1.0000    0.4588         0
            1.0000    0.4667         0
            1.0000    0.4745         0
            1.0000    0.4824         0
            1.0000    0.4902         0
            1.0000    0.4980         0
            1.0000    0.5059         0
            1.0000    0.5137         0
            1.0000    0.5216         0
            1.0000    0.5255         0
            1.0000    0.5333         0
            1.0000    0.5412         0
            1.0000    0.5490         0
            1.0000    0.5529         0
            1.0000    0.5608         0
            1.0000    0.5686         0
            1.0000    0.5765         0
            1.0000    0.5804         0
            1.0000    0.5882         0
            1.0000    0.5961         0
            1.0000    0.6039         0
            1.0000    0.6078         0
            1.0000    0.6157         0
            1.0000    0.6235         0
            1.0000    0.6314         0
            1.0000    0.6353         0
            1.0000    0.6431         0
            1.0000    0.6510         0
            1.0000    0.6588         0
            1.0000    0.6627         0
            1.0000    0.6706         0
            1.0000    0.6784         0
            1.0000    0.6863         0
            1.0000    0.6902         0
            1.0000    0.6980         0
            1.0000    0.7059         0
            1.0000    0.7137         0
            1.0000    0.7216         0
            1.0000    0.7294         0
            1.0000    0.7373         0
            1.0000    0.7451         0
            1.0000    0.7490         0
            1.0000    0.7569         0
            1.0000    0.7647         0
            1.0000    0.7725         0
            1.0000    0.7804         0
            1.0000    0.7882         0
            1.0000    0.7961         0
            1.0000    0.8039         0
            1.0000    0.8078         0
            1.0000    0.8157         0
            1.0000    0.8235         0
            1.0000    0.8314         0
            1.0000    0.8353         0
            1.0000    0.8431         0
            1.0000    0.8510         0
            1.0000    0.8588         0
            1.0000    0.8627         0
            1.0000    0.8706         0
            1.0000    0.8784         0
            1.0000    0.8863         0
            1.0000    0.8941         0
            1.0000    0.9020         0
            1.0000    0.9098         0
            1.0000    0.9176         0
            1.0000    0.9216    0.0157
            1.0000    0.9294    0.0314
            1.0000    0.9373    0.0510
            1.0000    0.9451    0.0667
            1.0000    0.9490    0.0824
            1.0000    0.9569    0.1020
            1.0000    0.9647    0.1176
            1.0000    0.9725    0.1373
            1.0000    0.9725    0.1647
            1.0000    0.9765    0.1961
            1.0000    0.9804    0.2275
            1.0000    0.9843    0.2588
            1.0000    0.9882    0.2902
            1.0000    0.9922    0.3216
            1.0000    0.9961    0.3529
            1.0000    1.0000    0.3843
            1.0000    1.0000    0.4118
            1.0000    1.0000    0.4431
            1.0000    1.0000    0.4745
            1.0000    1.0000    0.5059
            1.0000    1.0000    0.5333
            1.0000    1.0000    0.5647
            1.0000    1.0000    0.5961
            1.0000    1.0000    0.6275
            1.0000    1.0000    0.6549
            1.0000    1.0000    0.6863
            1.0000    1.0000    0.7176
            1.0000    1.0000    0.7490
            1.0000    1.0000    0.7804
            1.0000    1.0000    0.8118
            1.0000    1.0000    0.8431
            1.0000    1.0000    0.8745
            1.0000    1.0000    0.8902
            1.0000    1.0000    0.9059
            1.0000    1.0000    0.9216
            1.0000    1.0000    0.9373
            1.0000    1.0000    0.9529
            1.0000    1.0000    0.9686
            1.0000    1.0000    0.9843
            1.0000    1.0000    1.0000
            1.0000    1.0000    1.0000
            1.0000    1.0000    1.0000
            1.0000    1.0000    1.0000
            1.0000    1.0000    1.0000
            1.0000    1.0000    1.0000
            1.0000    1.0000    1.0000
            1.0000    1.0000    1.0000
            ];

        %interpolate values
        xin=linspace(0,1,m)';
        xorg=linspace(0,1,size(cmap_mat,1));
        p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
        p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
        p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');

    end  % fire.


end  % plt_signals_spectrum.