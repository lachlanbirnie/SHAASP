function [hn, hnm] = sph_hn2_closedform(N,k,r,options)
% SPH_HN2_CLOSEDFORM - Get the closed form expression for hn(2)(kr).
%
% Syntax:  [hn, hnm] = sph_hn2_closedform(N,k,r)
%
% Outputs:
%
%   hn = [N+1, r, k]
%   hnm = [(N+1)^2, r, k] (padded for nm pairs)
%
% See also: sph_hn, sph_hn_closedform
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 03-02-2023
% Last revision: 10-Jan-2025

    arguments
        N (1,1) {mustBeNonnegative, mustBeInteger}
        k (1,1,:) {mustBeNonnegative}
        r (1,:) {mustBeNonnegative}
        options.orientation {mustBeMember(options.orientation, ["[N,Q]", "[Q,N]", "[N,Q,K]", "[Q,N,K]"])} = '[N,Q]'
    end

    K = length(k);
    Q = length(r);
    
    kr_vec = reshape(k .* r, [1, K * Q]);  % [1,kr]

    ekr_term = exp(-1i .* kr_vec) ./ kr_vec;  % [1,kr]

    hnkr = zeros(N+1, K*Q);  % [N+1, kr]
    for n = (0:N)
        m = (0:n).';
        c1 = (factorial(n+m) ./ factorial(n-m)).';  % [1,m]
        c2 = (1i).^(-m) ./ (factorial(m) .* (2.*kr_vec).^m);  % [m,kr]
        hnkr(n+1, :) = (-1i).^-(n+1) .* ekr_term .* (c1 * c2);  % [(n),kr]
    end
    
    hn = reshape(hnkr, [N+1, Q, K]);  % [N+1, Q, K]
    if (nargout > 1)
        ind = repelem((0:N)+1, 2.*(0:N)+1).';  % [(N+1)^2,1]
        hnm = hn(ind, :, :);  % [(N+1)^2, k, r]
    else
        hnm = [];
    end

    % Options orientation for [jn].
    switch options.orientation
        case {'[Q,N]', '[Q,N,K]'}
            hn = permute(hn, [2,1,3]);
            hnm = permute(hnm, [2,1,3]);
        otherwise
    end
end