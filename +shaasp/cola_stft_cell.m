function [spec, fbin_hz, tbin_sec] = cola_stft_cell(sig, nfft, hop, wind, single_sided, fs)
% [spec, fbin_hz, tbin_sec] = cola_stft_cell(sig, nfft, hop, wind, single_sided, fs)
% STFT but time frames are in cell array S{t}[Freq, Chn].
% Lachlan Birnie
% 20 September 2024
    
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

% spec = zeros(numel(fbin_index), total_frames, sig_nchannels);
spec = cell(total_frames, 1);

for ind_frame = (0 : total_frames - 1)
    frame_samples = (ind_frame * hop + 1 : ind_frame * hop + wlen);
    sig_frame = sig_padded(frame_samples, :) .* wind;
    spec_frame = fft(sig_frame, nfft, 1);
    spec_frame = spec_frame(fbin_index, :);
    % spec(:, ind_frame + 1, :) = spec_frame;
    spec{ind_frame + 1} = spec_frame;
end

if isempty(fs) || (nargout == 1)
    fbin_hz = [];
    tbin_sec = [];
else
    tbin_sec = shaasp.cola_get_timebins_seconds(sig_nsamples, wlen, hop, fs);
    fbin_hz = shaasp.cola_nfft_bin_frequencies(fs, nfft, single_sided);
end

end