function [alphas, alphas_ell] = sph_alphas_planewave(N, source_rtp, kind)
% kind = '-' / 'outgoing' (default) or '+' / 'incoming'
% Output: alphas [N, 1], alphas_ell [N, L].
% Lachlan Birnie
% 10-Jan-2024

arguments
    N {mustBeScalarOrEmpty}
    source_rtp (:,3)
    kind {mustBeMember(kind, ["+", "incoming", "-", "outgoing"])} = '-'
end

n_vals = shaasp.SPHMacros.n_set(N);  %[0,1,1,1,2 ...].'

if contains(kind, {'+','incoming'})
    coe_sign = +1i;
elseif contains(kind, {'-','outgoing'})
    coe_sign = -1i;
end

ynm_mat = shaasp.sph_ynm(N, source_rtp(:,2), source_rtp(:,3));  % [N,L]
alphas = 4 .* pi .* (coe_sign).^n_vals .* conj(ynm_mat);
alphas_ell = alphas;  % Coefficients due to each source.
alphas = sum(alphas, 2);

end