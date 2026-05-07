function [h_surf, efd] = sfd_plot_error(sfd_true, sfd_approx, options)
% Calculate and plot the error between two sound fields.
% Lachlan Birnie
% 18-Nov-2024

arguments
    sfd_true
    sfd_approx
    options.plane = 'xy'
    options.resolution = 200
    options.lim = 1
    options.origin_shift = [0, 0, 0]
end

% Get plotting grid positions.
[X,Y,Z] = shaasp.plotdata_cartesian_grid(options.plane, options.resolution, options.lim, options.origin_shift);

% Calculate the error field.
efd = sqrt(abs(sfd_approx - sfd_true).^2 ./ abs(sfd_true).^2) .*100;
%efd = (abs(sfd_approx - sfd_true).^2 ./ abs(sfd_true).^2) .*100;
%efd = abs(sfd_approx - sfd_true).^2;
%efd = abs(sfd_approx - sfd_true);

% Plot the error field.
h_axis = gca;
h_surf = shaasp.plotdata_sfdsurf(h_axis, options.plane, X, Y, Z, efd);
h_cb = colorbar;
colormap(h_axis, flip(hot(32)));
clim([0 100]);
ylabel(h_cb, '[%]');
title('Soundfield Error');

end