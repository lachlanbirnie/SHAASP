function [h_surf] = plotdata_sfdsurf(h_axis, plane, X, Y, Z, sfd)
% Plot sound field data on the desired plane using surf.
% Lachlan Birnie
% 18-Nov-2024

switch lower(plane)
    case 'xy', A = X; B = Y; C = Z; a = 'x'; b = 'y';
    case 'yx', A = Y; B = X; C = Z; a = 'y'; b = 'x';
    case 'xz', A = X; B = Z; C = Y; a = 'x'; b = 'z';
    case 'zx', A = Z; B = X; C = Y; a = 'z'; b = 'x';
    case 'yz', A = Y; B = Z; C = X; a = 'y'; b = 'z';
    case 'zy', A = Z; B = Y; C = X; a = 'z'; b = 'y';
    otherwise
        error('Unknown cartesian plane.');
end
if isempty(h_axis)
    h_surf = surf(A, B, C, sfd, 'EdgeColor', 'interp');
    h_axis = gca;
else
    h_surf = surf(h_axis, A, B, C, sfd, 'EdgeColor', 'interp');
end

colormap(h_axis, 'jet');
colorbar;
axis('square');
view(2);
xlim([min(A(:)), max(A(:))]);
ylim([min(B(:)), max(B(:))]);
xlabel(h_axis, sprintf('%s [m]', a));
ylabel(h_axis, sprintf('%s [m]', b));

end