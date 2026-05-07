function [rt60, method] = basic_rt60_from_impulse(ir, fs, HEADROOM, FOOTROOM, BANDPASS)
% BASIC_RT60_FROM_IMPULSE - Estimate RT60 from impulse response.
% Estimate RT60 using Schroeder Method with backwards decay curve integral
% of impulse response.
% This is only a simple RT60 esimate using least squares regression
% between -5 and -35 dB (T30) energy decay or
% between -5 and -25 dB (T20) energy decay.
%
% Syntax:  [rt60, method] = lachlans_rt60_from_impulse(ir, fs)
%
% Inputs:
%   ir - Columns of impulse responses (additional dimensions are averaged).
%   fs - Sample rate of impulse response.
%
%   HEADROOM - (default: -5) dB drop to start line fit.
%   FOOTROOM - (default: -10) dB drop from end of line fit to noise floor.
%   BANDPASS - (default: [100 5000]) Hz to bandpass filter the IR.
%
% Outputs:
%   rt60 - Estimated RT60 in seconds.
%   method - Text description of how RT60 was estimated.
%
%   If no ouputs, plots the decay curve.
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
%
% References:
% ISO 3382-2 is the standard for measuring RT60.
% https://www.nti-audio.com/en/applications/room-building-acoustics/reverberation-time
% https://www.roomeqwizard.com/help/help_en-GB/html/graph_filteredir.html
% https://www.acousticsciences.com/product/rt-60-analysis/
% https://github.com/LCAV/pyroomacoustics/blob/master/pyroomacoustics/experimental/rt60.py
% https://svantek.com/academy/rt60-reverberation-time/
% Schroeder, M.R. New Method of Measuring Reverberation Time, J. Acoust. Soc. Am., Vol. 37, 1965, p. 409
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 12-Dec-2024
% Last revision: 12-Dec-2024

arguments
    ir
    fs (1,1)
    HEADROOM = -5
    FOOTROOM = -10
    BANDPASS = [100 5000]
end

% Format IRs down columns [samples, number of irs].
if isrow(ir), ir = ir(:); end
if size(ir, 3) > 1, ir = ir(:,:); end

% Bandpass IRs.
if ~isempty(BANDPASS)
    ir = bandpass(ir, BANDPASS, fs);
end

% Normalize IRs.
ir = ir ./ max(abs(ir), [], 1);

% Time axis / values of IR.
ir_len = size(ir, 1);
ir_tax = linspace(0, ir_len / fs, ir_len);

% Backwards integral decay curve.
ir_backwards = ir(end:-1:1, :);
ir_backwards_energy = ir_backwards.^2;
ir_backwards_energy_sum = cumsum(ir_backwards_energy, 1);
ir_energy_sum = ir_backwards_energy_sum(end:-1:1, :);
ir_energy_dB_sum = 10 .* log10(ir_energy_sum);

% Normalize to 0 dB to get decay curve.
decay = ir_energy_dB_sum - max(ir_energy_dB_sum, [], 1);

% Align all decays at the HEADROOM value and then average.
if size(decay, 2) > 1
    % Find sample where each decay crosses the head room level.
    i_head = zeros(1, size(decay, 2));
    for col = (1 : size(decay, 2))
        i_head(col) = find(decay(:, col) <= HEADROOM, 1, 'first');
    end

    % Align the decays at the head room level by padding zeros.
    aligned_decays = zeros(size(decay));
    for col = (1 : size(decay, 2))
        pad = max(i_head) - i_head(col);
        aligned_decays(:, col) = [zeros([pad,1]); decay(1:end-pad, col)];
    end

    % Take the average of the aligned decays.
    decay = mean(aligned_decays, 2);
end

% Find time axis of decay where zero time == head room level.
decay_tax = ir_tax - find(decay <= HEADROOM, 1, 'first') / fs;

% Properties of the decay curve.
% Noise floor (assumed the floor is most common non-zero value).
floor_val = median(decay(decay ~= 0));
floor_i = find(decay <= floor_val, 1, 'first');
floor_t = decay_tax(floor_i);

% Headroom point.
head_i = find(decay <= HEADROOM, 1, 'first');
head_t = decay_tax(head_i);

% Footroom point.
foot_val = floor_val - FOOTROOM;
foot_i = find(decay <= foot_val, 1, 'first');
foot_t = decay_tax(foot_i);

% Valid decay range.
decay_range = abs(foot_val - HEADROOM);

% Estimate T20, T30, and Tmax.
T20 = fit_decay(-20);
T30 = fit_decay(-30);

drop = max(-60, foot_val);
Tmax = fit_decay(drop);
Tmax.drop = num2str(round(abs(drop)));

% EDT = early_decay_fit();  % Unused.

% Estimate RT60 from best T20 / T30.
if (T30.found && T30.valid)
    rt60 = T30.rt60;
    method = 'Estimated from T30';

elseif (T20.found && T20.valid)
    rt60 = T20.rt60;
    method = 'Estimated from T20';

else
    rt60 = [];
    method = 'Unable to determine RT60';
end

% Plot results if no output.
if ~nargout
    fprintf('RT60 = %4i ms (%s)', round(rt60 * 1000), method);

    fig = figure('Color', [1, 1, 1]);
    fig.Position(3) = 2 .* fig.Position(3);

    % -60 dB Line.
    line([decay_tax(1), decay_tax(end)], [-60, -60], 'Color', 'k', 'LineStyle', ':', 'LineWidth', 2, 'HandleVisibility', 'off');

    hold on;

    % Zero time point.
    line([0, 0], [-60, 0], 'Color', 'k', 'LineStyle', ':', 'LineWidth', 1, 'HandleVisibility', 'off');
    plot(0, 0, ':ok', 'HandleVisibility', 'off');

    % Impulse.
    if (size(ir, 2) == 1)
        ir_plot = ir(:,1) .* 30 - 30;  % Plot impulse scaled 0 to -60.
        plot(decay_tax, ir_plot, 'Color', 'c', 'LineWidth', 0.5, 'DisplayName', 'Impulse');
    end

    % Decay curve.
    plot(decay_tax, decay, 'k', 'LineWidth', 3, 'DisplayName', 'Decay Curve');

    % T20.
    if T20.found
        plot(decay_tax, T20.decay, 'r', 'LineWidth', 1.5, 'DisplayName', sprintf('T20 [%4i ms]', round(T20.rt60 * 1000)));
        plot(decay_tax + T20.offset / T20.slope, T20.decay, ':r', 'LineWidth', 1, 'HandleVisibility', 'off');
    end

    % T30.
    if T30.found
        plot(decay_tax, T30.decay, 'b', 'LineWidth', 1.5, 'DisplayName', sprintf('T30 [%4i ms]', round(T30.rt60 * 1000)));
        plot(decay_tax + T30.offset / T30.slope, T30.decay, ':b', 'LineWidth', 1, 'HandleVisibility', 'off');
    end

    % Tmax.
    if Tmax.found
        plot(decay_tax, Tmax.decay, 'm', 'LineWidth', 1.5, 'DisplayName', sprintf('T%s [%4i ms]', Tmax.drop, round(Tmax.rt60 * 1000)));
        plot(decay_tax + Tmax.offset / Tmax.slope, Tmax.decay, ':m', 'LineWidth', 1, 'HandleVisibility', 'off');
    end

    xlim([decay_tax(1), decay_tax(end)]);
    xlabel(sprintf('Time [sec] (shifted to 0 @ %+i dB decay)', HEADROOM));

    ylim([min(-60, floor_val), 0]);
    ylabel('Decay Energy [dB]');

    legend('show');
    grid("on");
    set(gca, 'FontSize', 12);
    title(sprintf('RT60 = %4i ms (%s)', round(rt60 * 1000), method));

end


    function [T] = fit_decay(drop_range)
        if (floor_val <= HEADROOM + drop_range)
            T.found = true;

            if (decay_range > abs(drop_range))
                T.valid = true;
            else
                % Not enough valid decay room but fit anyway.
                T.valid = false;
            end

            % Start and end times of the decay drop.
            T.i_start = head_i;
            T.i_end = find(decay <= (HEADROOM + drop_range), 1, 'first');
            t_start = T.i_start / fs;
            T.tax = ir_tax - t_start;

            % Linear fit decay curve between headroom and drop range.
            local_decay = decay(T.i_start : T.i_end);
            local_tax = T.tax(T.i_start : T.i_end);
            slope_offset = [local_tax.', ones(length(local_tax), 1)] \ local_decay;

            % Create best fit decay line.
            T.slope = slope_offset(1);
            T.offset = slope_offset(2);
            T.decay = T.slope .* T.tax + T.offset;

            % Estimate RT from fitted decay.
            T.rt20 = -20 / T.slope;
            T.rt30 = -30 / T.slope;
            T.rt60 = -60 / T.slope;

        else
            % Not a valid decay curve.
            T.found = false;
        end
    end

    function [T] = early_decay_fit()
        if (floor_val <= -10)
            T.found = true;

            if (decay_range > abs(-10))
                T.valid = true;
            else
                % Not enough decay but try anyway.
                T.valid = false;
            end

            % Use -0.5 dB instead of 0 dB to avoid noise error.
            T.i_start = find(decay <= -0.5, 1, 'first');
            T.i_end = find(decay <= -10, 1, 'first');
            t_start = T.i_start / fs;
            T.tax = ir_tax - t_start;

            % Linear fit decay curve between -5 to -25 dB.
            local_decay = decay(T.i_start : T.i_end);
            local_tax = T.tax(T.i_start : T.i_end);
            slope_offset = [local_tax.', ones(length(local_tax), 1)] \ local_decay;

            % Create best fit decay line.
            T.slope = slope_offset(1);
            T.offset = slope_offset(2);
            T.decay = T.slope .* T.tax + T.offset;

            % Estimate RT from fitted decay.
            T.rt20 = -20 / T.slope;
            T.rt30 = -30 / T.slope;
            T.rt60 = -60 / T.slope;

        else
            % Not a valid decay curve.
            T.found = false;
        end
    end

end