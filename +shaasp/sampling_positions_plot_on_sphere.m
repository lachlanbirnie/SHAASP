function sampling_positions_plot_on_sphere(x,y,z)
% Plot sampling positions on a sphere to visualize.
% Lachlan Birnie - 16-Dec-2024
    R = mean(sqrt(x.^2 + y.^2 + z.^2));
    
    % Origin.
    plot3(0, 0, 0, 'kx');
    hold on;

    % Axis.
    plot3([0,1].*R, [0,0].*R, [0,0].*R, 'r-');
    plot3([0,0].*R, [0,1].*R, [0,0].*R, 'g-');
    plot3([0,0].*R, [0,0].*R, [0,1].*R, 'b-');

    % Spherical region.
    [sx,sy,sz] = sphere;
    sx = sx .* R;
    sy = sy .* R;
    sz = sz .* R;
    surf(sx, sy, sz, 'FaceColor', 'none', 'EdgeColor', 'c', 'LineStyle', '--');

    % Sampling positions.
    for i = (1 : length(x))
        plot3(x(i), y(i), z(i), 'ko', 'LineWidth', 2); 
        text(x(i)*1.1, y(i)*1.1, z(i)*1.1, sprintf('%i',i), 'Color', 'k');
    end

    axis('equal');
    grid('on');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title('Sampling Positions')
end