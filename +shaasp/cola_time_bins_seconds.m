function [tbin_sec] = cola_time_bins_seconds(total_samples, wlen, hop, fs)
    total_frames = ceil((total_samples - wlen + hop) / hop);
    total_padded_samples = total_frames * hop + wlen - hop;
    tbin_sec = linspace(0, total_padded_samples/fs, total_frames);
end