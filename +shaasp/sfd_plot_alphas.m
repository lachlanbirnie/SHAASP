function [h_surf, sfd] = sfd_plot_alphas(alphas, k, options)
% Plot the interior sound field in a plane desribed by alpha coefficients.
% Lachlan Birnie
% 18-Nov-2024

arguments
    alphas
    k
    options.plane = 'xy'
    options.resolution = 200
    options.lim = 1
    options.origin_shift = [0, 0, 0]
end

N = sqrt(size(alphas, 1)) - 1;

% Get plot grid points.
[X, Y, Z] = shaasp.plotdata_cartesian_grid(options.plane, options.resolution, options.lim, options.origin_shift);
[R, T, P] = shaasp.xyz2rtp(X(:), Y(:), Z(:));

% Reconstruct sound field pressure at each plot point.
jn = shaasp.sph_jn(N, k, R).';
ynm = shaasp.sph_ynm(N, T, P).';
sfd = (jn .* ynm) * alphas;
sfd = reshape(sfd, size(X));

% Plot sound field in plane.
h_axis = gca;
h_surf = shaasp.plotdata_sfdsurf(h_axis, options.plane, X, Y, Z, real(sfd));
title('Soundfield Pressure');

end