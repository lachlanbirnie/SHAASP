function [r,t,p,x,y,z,w] = sampling_positions_NTSF1()
% SAMPLING_POSITIONS_NTSF1 - Rode NT SF1 sensor positions.
%
% Description
%
%   Properties of the Rode NT SF1 A-format microphone array.
%
% Inputs
%
%   N       | Truncation order of inversion matrix
%   k       | Wave numbers (frequencies) of inversions matrices
%   open    | 1 = open spherical array, 0 = [] = rigid spherical array.
%
% Outputs
%
%   r       | [Q by 1] radius of each sensor
%   t       | [Q by 1] elevation (0>pi) of each sensor
%   p       | [Q by 1] rotational position (0>2pi) of each sensor
%   x       | [Q by 1] x-position of each sensor w.r.t center
%   y       | [Q by 1] y-position ""
%   z       | [Q by 1] z-position ""
%   w       | [Q by 1] sampling weight of each sensor
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 13-Dec-2024
% Last revision: 13-Dec-2024

% Spherical (r, theta, phi) coordinates (rads).
r = ones(4, 1) .* 0.0251;

t = [ 54.736
    125.264
    125.264
    54.736 ] .* (2*pi/360);

p = [ 45
    315
    135
    225 ] .* (2*pi/360);

% Cartesian (x,y,z) coordinates (m).
x = (r .* sin(t) .* cos(p));
y = (r .* sin(t) .* sin(p));
z = (r .* cos(t));

% Uniform sampling weights.
w = ones(size(t));

% Plot the positions if no output.
if ~nargout
    shaasp.sampling_positions_plot_on_sphere(x,y,z);
end

end