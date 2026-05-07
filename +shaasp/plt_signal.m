function [h_line, sig] = plt_signal(sig, fs, dark_mode, normalise, new_fig, do_subplots)
% PLT_SIGNAL - Plot a signals.
%
% Syntax:  [h, sig] = plt_signal(sig, fs, dark_mode, normalise, separate)
%
% Inputs:
%   sig - [samples, channels]
%   fs - Sampling frequency in Hz.
%   dark_mode - bool.
%   normalise - normalize signal to +-1 before plotting.
%   new_fig - plot signals on a new figure.
%   separate_figs - bool, plot each channel on a new figure.
%
% Outputs:
%   h_line - Cell array of handles to each plot line.
%   sig - [samples, channels] the plotted signal data.
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 24-March-2023
% Last revision: 29-July-2024


% Optional inputs.
if (nargin < 2), fs = []; end
if (nargin < 3) || isempty(dark_mode), dark_mode = true; end
if (nargin < 4) || isempty(normalise), normalise = false; end
if (nargin < 5) || isempty(new_fig), new_fig = false; end
if (nargin < 6) || isempty(do_subplots), do_subplots = false; end

% Signal sizes.
sig_nsamples = size(sig, 1);
sig_nchannels = size(sig, 2);

if isempty(fs)
    tval = (1 : sig_nsamples);  % Samples.
    tlabel = 'Samples';
else
    tval = linspace(0, sig_nsamples/fs, sig_nsamples);  % Seconds.
    tlabel = 'Seconds';
end

% Normalise the signal.
if normalise
    sig = sig ./ max(abs(sig(:)));
end

% Plotting.
if new_fig
    h_fig = figure('Color', [1, 1, 1]);
    pos = h_fig.Position;
    h_fig.Position = [pos(1), pos(2), pos(3)*2, pos(4)];
end

if (sig_nchannels > 1) && do_subplots
    tiledlayout(sig_nchannels, 1, 'TileSpacing', 'normal', 'Padding', 'normal');
end

h_line = cell(sig_nchannels, 1);

for i = (1 : sig_nchannels)

    if do_subplots
        nexttile;
    end

    h_line{i} = plot(tval, sig(:,i), ...
            'LineWidth', 1.5, ...
            'DisplayName', sprintf('Channel %i',i) );

    xlabel(tlabel);
    ylabel('Amplitude');
    xlim([0, tval(end)]);
    if normalise
        ylim([-1, 1]);
    end
    set(gca, 'FontSize', 18);
    title(sprintf('Channel %i',i), 'Color', [0,0,0]);

    if ~do_subplots 
        leg = legend('show');
        hold on;
    else
        leg = legend('off');
    end

    % Dark mode colors.
    if dark_mode
        set(gcf, 'Color', [0, 0, 0]);
        set(gca ...
            ,'MinorGridColor',[1 1 1] ...
            ,'GridColor'     ,[1 1 1] ...
            ,'Color'         ,[0 0 0] ...
            ,'XColor'        ,[1 1 1] ...
            ,'YColor'        ,[1 1 1] ...
            );
        line_color = min(h_line{i}.Color .* 2, 1);
        h_line{i}.Color = line_color;
        title(sprintf('Channel %i',i), 'Color', [1,1,1]);
        if ~isempty(leg)
            leg.Color = [1,1,1];
        end
    end

end

end