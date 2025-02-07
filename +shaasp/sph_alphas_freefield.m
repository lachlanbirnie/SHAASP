function [alphas] = sph_alphas_freefield(source_type, source_rtp, N, k, kind)
% SPH_ALPHAS_FREEFIELD - Equation for free-field pointsource / planewave
% spherical harmonic coefficients.
%
% Syntax:  [alphas] = sph_alphas_freefield(source_type, source_rtp, N, k, kind)
%
% Inputs:
%   source_type - "pointsource" "ps" "planewave" "pw"
%   source_rtp - [r,theta,phi] position of source
%   N - Truncation order of alphas
%   k - wave number of alphas
%   kind - "+" or "-" for the sign of the 'i' term.
%
% Outputs:
%   alphas - [N, L, K] coefficients for (order, source, wavenumber)
%
% Equations: 
%
%   Point-source
%                              *
%       alphas = i k hn(kr) Ynm (theta,\phi)
%
%   Planewave
%                        n     *
%       alphas = 4 pi (i)   Ynm (theta,\phi)
%
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 10-Jan-2024
% Last revision: 07-Feb-2025
arguments
    source_type {mustBeMember(source_type, ["planewave", "pointsource", "pw", "ps"])}
    source_rtp (:,3)
    N {mustBeScalarOrEmpty, mustBePositive}
    k (1,1,:)
    kind {mustBeMember(kind, ["+", "-"])} = "+";
end

% Planewave alphas.
if contains(source_type, ["pw", "planewave"])

    if contains(kind, {'+'})
        coe_sign = +1i;
    elseif contains(kind, {'-'})
        coe_sign = -1i;
    end

    n = shaasp.SPHMacros.n_set(N);  % n = [0,1,1,1,2 ...].'

    % Ynm(theta, phi) used for both point source and planewave.
    ynm_term = shaasp.sph_ynm(N, source_rtp(:,2), source_rtp(:,3), "orientation", "[N,Q]");

    % Planewave alpha = 4 pi i^n Ynm*(theta, phi)
    alphas = 4 .* pi .* (coe_sign).^n .* conj(ynm_term);


% Point-source alphas.
elseif contains(source_type, ["ps", "pointsource"])

    if contains(kind, {'+'})
        coe_sign = +1i;
        hn_term = shaasp.sph_hn(N, k, source_rtp(:,1));  % [N,Q,K]

    elseif contains(kind, {'-'})
        coe_sign = -1i;
        hn_term = shaasp.sph_hn(N, k, source_rtp(:,1), "kind", "second");
    end

    % Ynm(theta, phi) used for both point source and planewave.
    ynm_term = shaasp.sph_ynm(N, source_rtp(:,2), source_rtp(:,3), "orientation", "[N,Q]");

    % Point source alpha = i k hn(kr) Ynm*(theta, phi)
    alphas = coe_sign .* k .* hn_term .* conj(ynm_term);

end

end