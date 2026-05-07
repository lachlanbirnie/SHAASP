function [betas] = sph_betas_freefield(source_rtp, N, k)
% Lachlan Birnie
% 07-Feb-2025

arguments
    source_rtp (:,3)
    N {mustBeScalarOrEmpty}
    k (1,1,:)
end

jn_mat = shaasp.sph_jn(N, k, source_rtp(:,1));  % [N,L,K]
ynm_mat = shaasp.sph_ynm(N, source_rtp(:,2), source_rtp(:,3));  % [N,L]

% betas = [1] .* [1,1,K] .* [N,Q,K] .* [N,Q]
betas = +1i .* k .* jn_mat .* conj(ynm_mat);

end