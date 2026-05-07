function [wind] = cola_window(wlen, hop, ola_method)
% Author: Lachlan Birnie
% Version: 20 September 2023

    arguments
        wlen (1,1)
        hop (1,1)
        ola_method {mustBeMember(ola_method, ["wola", "ola"])} = 'ola';
    end

    if ~mod(wlen, 2)
        % Even window length.
        wind = hann(wlen, 'periodic');
        wind = wind ./ (wlen / hop / 2);  % Normalize for overlap add.
    else
        % Odd window length.
        wind = hann(wlen, 'symmetric');
        wind(1) = wind(1) / 2;
        wind(wlen) = wind(wlen) / 2;
        wind = wind ./ ((wlen - 1) / hop / 2);  % Normalize for ola.
    end
    
    % Apply sqrt if weighted overlap add.
    if strcmp(ola_method, 'wola')
        wind = sqrt(wind);
    end
    
    % Check if the window is COLA compliant.
    [a,b,c] = iscola(wind, wlen-hop, ola_method);

    if (b ~= 1)
        % Note, used to check if a ~= 1, but it would fail cola check for
        % window size of 16384 and 50% overlap. Whereas, b will still = 1.
        error('window is not cola');
    end

end