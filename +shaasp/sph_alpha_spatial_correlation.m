function [C] = sph_alpha_spatial_correlation(alpha_est, alpha_true, binf)
% SPH_ALPHA_SPATIAL_CORRELATION - Performance metric for measured alphas.
% Get the spatial correlation between two sets of alpha coefficients.
% True free-field alphas due to planewaves from all directions.
% Estimated alphas from a microphone array encoding matrix.
%
% Syntax:  [C] = sph_alpha_spatial_correlation(alpha_est, alpha_true, binf)
%
% Inputs:
%   alpha_est = [N,L,K] estimated coefficients, L = coefficients of PWD sources.
%   alpha_true = [N,L,K] true coefficients given PWD.
%   binf = frequency bin Hz for third dimension, only used for plotting.
%
% Outputs:
%   C - [n,K] spatial correlation for each order n.
%   
%   no output = plot.
%
% Other m-files required: simulate_measured_encoding_matrix.
%
% See also: shaasp.sph_alpha_diffuse_level_difference
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
C = zeros((N+1), num_bins);

for bin = (1 : num_bins)
    for n = (0 : N)

        % Indexes of all m'th modes of order n.
        mset = shaasp.SPHMacros.n_inds(n);

        % Alpha true may or may not be frequency dependent.
        if ismatrix(alpha_true)
            alpha_true_bin = alpha_true(mset,:);
        elseif ndims(alpha_true) == 3
            alpha_true_bin = alpha_true(mset,:,bin);
        end

        % Spatial correlation.
        cross_corr = sum(diag(alpha_est(mset,:,bin) * alpha_true_bin'));
        auto_est = sum(diag(alpha_est(mset,:,bin) * alpha_est(mset,:,bin)'));
        auto_true = sum(diag(alpha_true_bin * alpha_true_bin'));
        C(n+1,bin)  =  real(cross_corr ./ sqrt( auto_est * auto_true ));

    end
end

% Plot results if no output.
if ~nargout
    N = floor(sqrt(size(alpha_est,1)) - 1);
    for i = (1 : N+1)
        semilogx(binf, real(C(i,:)), 'DisplayName', sprintf('n = %i',i-1));
        hold on;
    end
    xlim([10 binf(end)]);
    ylim([0 1]);
    xlabel('frequency [Hz]');
    ylabel('Correlation Value');
    title('Spatial Correlation');
    legend('Location','southwest');
end

end