function [noisy_sig, noise] = sig_awgn(sig, desired_snr)
sig_pwr = sum(abs(sig).^2, "all", "omitmissing") / numel(sig);
desired_noise_pwr = sig_pwr / 10^(desired_snr/10);
noise_gain = sqrt(desired_noise_pwr);
noise = randn(size(sig), 'like', sig) .* noise_gain;
noisy_sig = sig + noise;
end