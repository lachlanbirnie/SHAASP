function [X,Y,Z] = plotdata_cartesian_grid(plane, resolution, lim, origin_shift)
% Get x,y,z grid points for calculating sound field for plotting.
% Lachlan Birnie
% 18-Nov-2024

arguments
    plane = 'xy'
    resolution = 200
    lim = 1
    origin_shift = [0, 0, 0]
end

% Points along axis.
a = linspace(-lim, lim, resolution);
b = a;

% Points in the plane.
[A, B] = meshgrid(a, b);
C = zeros(size(A));

% Assign points to desired plane.
switch lower(plane)
    case 'xy', X = A; Y = B; Z = C;
    case 'yx', Y = A; X = B; Z = C;
    case 'xz', X = A; Z = B; Y = C;
    case 'zx', Z = A; X = B; Y = C;
    case 'yz', Y = A; Z = B; X = C;
    case 'zy', Z = A; Y = B; X = C;
    otherwise
        error('Invalid cartesian plane.');
end

% Apply axis shift.
X = X + origin_shift(1);
Y = Y + origin_shift(2);
Z = Z + origin_shift(3);

end