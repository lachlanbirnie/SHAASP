function [bn] = sph_bn(N,k,r,type,options)
% SPH_BN - Spherical Baffle Equation, bn(kr).
%   'open', 'rigid', and 'cardoid' baffle equations.
%
% Syntax:  [bn] = sph_bn(N,k,r,type)
%
% Inputs:
%
%   N       Order of the returned baffle term matrix.
%   k       [K,1] vector of frequency (wave number) arguments.
%   r       [Q,1] vector of radius arguments (m).
%   type    'open', 'rigid', 'cardioid'
%
%   options
%       r_baff  Radius of rigid baffle, default is same as r.
%
% Outputs:
%
%   bn  [(N+1)^2 by Q by K] matrix of array baffle equation.
%
%       bn(:,:,k) = [ b_0(k * r1) ... b_0(k * rQ) ]
%                   [    ...             ...      ]
%                   [ b_N(k * r1) ... b_N(k * rQ) ]
%
% Equation:
%
%   Array Baffle Equation:
%
%       b_n(kr) = j_n(kr) - i * d/dx j_n(kr)                [cardioid]
%
%                           /  d/dx j_n(kr)           \
%       b_n(kr) = j_n(kr) - |  ------------ X h_n(kr) |     [rigid sphere]
%                           \  d/dx h_n(kr)           /
%
%       b_n(kr) = j_n(kr)                                   [open sphere]
%
%
% Other m-files required: +shaasp. sph_jn, sph_hn, sph_djndx, sph_dhndx
% Subfunctions: none
% MAT-files required: none
%
% See also: sph_jn, sph_hn, sph_djndx, sph_dhndx.
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 28-Jan-2021
% Last revision: 07-Feb-2025

    arguments
        N (1,1) {mustBeNonnegative, mustBeInteger}
        k (1,1,:) {mustBeNonnegative}
        r (1,:) {mustBeNonnegative}
        type {mustBeMember(type, ["open", "rigid", "cardioid"])} = 'rigid'
        options.r_baff (1,:) {mustBeNonnegative} = r
        options.orientation {mustBeMember(options.orientation, ["[N,Q]", "[Q,N]", "[N,Q,K]", "[Q,N,K]"])} = '[N,Q]'
    end

    switch type
        case 'open'
            bn = shaasp.sph_jn(N,k,r);

        case 'rigid'
            bn = shaasp.sph_jn(N,k,r) ...
                - ( shaasp.sph_djndx(N,k,options.r_baff) ...
                    ./ shaasp.sph_dhndx(N,k,options.r_baff) ) ...
                .* shaasp.sph_hn(N,k,r);

        case 'cardioid'
            bn = shaasp.sph_jn(N,k,r) - 1i .* shaasp.sph_djndx(N,k,r);

        otherwise
            error('Invalid array baffle type.');
    end

    % Options orientation.
    switch options.orientation
        case {'[Q,N]', '[Q,N,K]'}
            bn = permute(bn, [2,1,3]);
        otherwise
    end
    
end