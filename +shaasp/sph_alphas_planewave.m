function [alphas] = sph_alphas_planewave(N, source_rtp, kind)
% kind = '-' / 'outgoing' (default) or '+' / 'incoming'
% Lachlan Birnie
% 27-Sept-2024

arguments
    N {mustBeScalarOrEmpty}
    source_rtp (:,3)
    kind {mustBeMember(kind, ["+", "incoming", "-", "outgoing"])} = '-'
end

n_vals = shaasp.SPHMacros.n_set(N).';  %[0,1,1,1,2 ...].'

if contains(kind, {'+','incoming'})
    coe_sign = +1i;
elseif contains(kind, {'-','outgoing'})
    coe_sign = -1i;
end

ynm_mat = shaasp.sph_ynm(N, source_rtp(:,2), source_rtp(:,3));  % [L,N]
alphas = 4 .* pi .* (coe_sign).^n_vals .* ynm_mat';
alphas = sum(alphas, 2);

end