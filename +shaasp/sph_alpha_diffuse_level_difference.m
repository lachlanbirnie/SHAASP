function [L] = sph_alpha_diffuse_level_difference(alpha_est, alpha_true, binf)
% SPH_ALPHA_DIFFUSE_LEVEL_DIFFERENCE - Performance metric for alpha coes.
% Get the DLD between two sets of alpha coefficients.
% True free-field alphas due to planewaves from all directions.
% Estimated alphas from a microphone array encoding matrix.
%
% Syntax:  [L] = sph_alpha_diffuse_level_difference(alpha_est, alpha_true, binf)
%
% Inputs:
%   alpha_est = [N,L,K] estimated coefficients, L = coefficients of PWD sources.
%   alpha_true = [N,L,K] true coefficients given PWD.
%   binf = frequency bin Hz for third dimension, only used for plotting.
%
% Outputs:
%   L - [n,K] Diffuse level difference for each order n.
%   
%   no output = plot.
%
% Other m-files required: simulate_measured_encoding_matrix.
%
% See also: shaasp.sph_alpha_spatial_correlation.
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 07-Feb-2025
% Last revision: 07-Feb-2025

arguments
    alpha_est (:,:,:)
    alpha_true (:,:,:)
    binf (:,1)
end

N = sqrt(size(alpha_est, 1)) - 1;
num_srcs = size(alpha_est, 2);
num_bins = size(alpha_est, 3);
L = zeros((N+1), num_bins);

for bin = (1 : num_bins)
    for n = (0 : N)

        % Index of m'th modes of order n.
        mset = shaasp.SPHMacros.n_inds(n);

        % Alpha true may or may not be frequency dependent.
        if ismatrix(alpha_true)
            alpha_true_bin = alpha_true(mset,:);
        elseif ndims(alpha_true) == 3
            alpha_true_bin = alpha_true(mset,:,bin);
        end

        % Diffuse level difference between measured and true alphas.
        auto_est = sum(diag(alpha_est(mset,:,bin) * alpha_est(mset,:,bin)'));
        auto_true = sum(diag(alpha_true_bin * alpha_true_bin'));
        L(n+1,bin)  =  10.*log10(real( auto_est / auto_true ));

    end
end

% Plot results if no output.
if ~nargout
    N = floor(sqrt(size(alpha_est,1)) - 1);
    for i = (1 : N+1)
        semilogx(binf, real(L(i,:)), 'DisplayName', sprintf('n = %i',i-1));
        hold on;
    end
    xlim([10 binf(end)]);
    ylim([-max(abs(min(real(L), [], "all")), abs(-1)), max(real(L(:,2:end)), [], "all")]);
    xlabel('frequency [Hz]');
    ylabel('Level [dB]');
    title('Diffuse level difference');
    legend('Location','southwest');
end

end