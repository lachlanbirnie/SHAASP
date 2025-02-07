function [hn] = sph_hn(N,k,r,options)
% SPH_HN - Spherical Hankel function of the first kind.
%   Returns the first kind spherial Hankel function,
%   for input argument vectors (k,r) in matrix from, 
%   for all harmonics up to N ([N+1]^2 total).
%
% Syntax:  [hn] = sph_hn(N,k,r)
%
% Inputs:
%
%   N   Order of the returned spherial Hankel matrix.
%   k   [K,1] vector of frequency (wave number) arguments.
%   r   [Q,1] vector of radius arguments (m).
%
% Outputs:
%
%   hn  [(N+1)^2 by Q by K] matrix of the spherial Hankel function
%
%       hn(:,:,k) = [ h_0(k * r1) ... h_0(k * rQ) ]
%                   [    ...             ...      ]
%                   [ h_N(k * r1) ... h_N(k * rQ) ]
%
%   Note that the n'th order of each column increments as:
%       [0,1,1,1,2,2,2,2,2,3,3, ... N].',
%   to match with the order-mode index's of (n,m) = (0,0) (1,-1) (1,0) ...
%
% Equaition:
%
%   h_n(x) = sqrt(pi/2) * 1/sqrt(x) * H_(n+1/2)(x)
%
%   where H_n(x) is the first kind Hankel Function,
%   given by MATLAB inbuilt function 'besselh()'
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 13-Feb-2019
% Last revision: 07-Feb-2025

    arguments
        N (1,1) {mustBeNonnegative, mustBeInteger}
        k (1,1,:) {mustBeNonnegative}
        r (1,:) {mustBeNonnegative}
        options.orientation {mustBeMember(options.orientation, ["[N,Q]", "[Q,N]", "[N,Q,K]", "[Q,N,K]"])} = '[N,Q]';
        options.kind {mustBeMember(options.kind, ["first", "second", "1", "2"])} = "first";
    end
                                
    % Implicit inputs.
    K = length(k);
    Q = length(r);
    
    % Value of n for all nm pairs (0 : (N+1)^2).
    v_n = repelem((0:N).', 2.*(0:N)+1);  % [N,1]

    % Expand arguments to matrix of equal size and dimensions [N,Q,K].
    arg_n = repmat(v_n, [1, Q, K]);
    arg_k = repmat(k, [(N+1)^2, Q, 1]);
    arg_r = repmat(r, [(N+1)^2, 1, K]);
    
    % Solve first kind spherical Hankel function.
    hn = sqrt(pi/2) ...
     .* (1 ./ sqrt(arg_k .* arg_r)) ...
     .* besselh(arg_n + 0.5, arg_k .* arg_r);

    % Options, orientation.
    switch options.orientation
        case {'[Q,N]', '[Q,N,K]'}
            hn = permute(hn, [2,1,3]);
        otherwise
            % hn = permute(hn, [1,2,3]);
    end

    % Options, kind.
    switch options.kind
        case {"second", "2"}
            hn = conj(hn);
        otherwise
    end

end