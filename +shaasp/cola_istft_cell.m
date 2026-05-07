function [sig] = cola_istft_cell(spec, nfft, hop, wind)
% [sig] = cola_istft_cell(spec, nfft, hop, wind)
% ISTFT but time frames are in cell array S{t}[Freq, Chn].
% Lachlan Birnie
% 20 September 2024

arguments
    spec (:,1)
    nfft {mustBeScalarOrEmpty}
    hop {mustBeScalarOrEmpty} = nfft
    wind (:,1) = ones(nfft, 1)
end

wlen = length(wind);
total_frames = size(spec, 1);
total_samples = total_frames * hop + wlen - hop;

wind_zeropad = [wind; zeros(nfft - wlen, 1)];

sig = zeros(total_samples, size(spec{1}, 3));

for ind_frame = (0 : total_frames - 1)
    frame_samples = (ind_frame * hop + 1 : ind_frame * hop + wlen);
    % spec_frame = spec(:, ind_frame + 1, :);
    spec_frame = spec{ind_frame + 1};
    sig_frame = ifft(spec_frame, nfft, 1, "symmetric");
    sig_frame = real(sig_frame) .* wind_zeropad;
    sig(frame_samples, :) = sig(frame_samples, :) + sig_frame(1:wlen, :);
end

end