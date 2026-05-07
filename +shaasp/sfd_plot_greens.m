function [h_surf, sfd] = sfd_plot_greens(src_type, k, src_xyz, src_sig, src_w, options)
% Plot the sound field in a plane described by greens function sources.
% Lachlan Birnie
% 18-Nov-2024

arguments
    src_type {mustBeMember(src_type, ...
        ["pw", "planewave", "pw-", "planewave-", "pw+", "planewave+", ...
        "ps", "pointsource", "ps-", "pointsource-", "ps+", "pointsource+", ...
        "ms", "mixedsource", "ms-", "mixedsource-", "ms+", "mixedsource+", ...
        "mw", "mixedwave", "mw-", "mixedwave-", "mw+", "mixedwave+"])}
    k (1,1)
    src_xyz (:,3)
    src_sig (:,1) = 1
    src_w (:,1) = 1
    options.plane = 'xy'
    options.resolution = 200
    options.lim = 1
    options.origin_shift = [0, 0, 0]
end

% Get plot grid points.
[X, Y, Z] = shaasp.plotdata_cartesian_grid(options.plane, options.resolution, options.lim, options.origin_shift);

% Calculate sound field pressure at each plot point.
mic_xyz = [X(:), Y(:), Z(:)];
sfd = shaasp.sfd_greens(src_type, k, src_xyz, mic_xyz, src_sig, src_w);
sfd = reshape(sfd, size(X));

% Plot sound field in plane.
h_axis = gca;
h_surf = shaasp.plotdata_sfdsurf(h_axis, options.plane, X, Y, Z, real(sfd));
title('Soundfield Pressure');

end