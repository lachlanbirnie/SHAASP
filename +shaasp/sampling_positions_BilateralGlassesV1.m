function [r,t,p,x,y,z,spacing] = sampling_positions_BilateralGlassesV1()
% Lachlan Birnie
% 18-Nov-2024

spacing = [0, -131, 0] ./ 1000;

% Left Ear.
left_local_xyz = [9.1, 0, 0;
    -3, -3.7, 6.2;
    -3, 7.5, 0;
    -3, -3.7, -6.2;
    ];
left_local_xyz = left_local_xyz ./ 1000;
left_local_rtp = shaasp.xyz2rtp(left_local_xyz);
left_local_R = mean(left_local_rtp(:,1));
left_global_origin = [0, 0, 0];

% Right Ear.
right_local_xyz = [9.1, 0, 0;
    -3, 3.7, 6.2;
    -3, -7.5, 0;
    -3, 3.7, -6.2;
    ];
right_local_xyz = right_local_xyz ./ 1000;
right_local_rtp = shaasp.xyz2rtp(right_local_xyz);
right_local_R = mean(right_local_rtp(:,1));
right_global_origin = spacing;

% Outputs.
xyz = [left_local_xyz; right_local_xyz];
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

rtp = [left_local_rtp; right_local_rtp];
r = rtp(:,1);
t = rtp(:,2);
p = rtp(:,3);


% plot.
if ~nargout
    figure('Color', [1 1 1]);

    % Origin.
    plot3(0, 0, 0, 'kx');
    hold on;

    % Axis.
    R = left_local_R;
    plot3([0,1].*R, [0,0].*R, [0,0].*R, 'r-');
    plot3([0,0].*R, [0,1].*R, [0,0].*R, 'g-');
    plot3([0,0].*R, [0,0].*R, [0,1].*R, 'b-');

    [sx,sy,sz] = sphere;
    sx = sx .* R;
    sy = sy .* R;
    sz = sz .* R;
    surf(sx, sy, sz, 'FaceColor', 'none', 'EdgeColor', 'g', 'LineStyle', '--');

    [sx,sy,sz] = sphere;
    sx = sx .* R + spacing(:,1);
    sy = sy .* R + spacing(:,2);
    sz = sz .* R + spacing(:,3);
    surf(sx, sy, sz, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineStyle', '--');

    for i = (1 : size(left_local_xyz,1))
        plot3(left_local_xyz(i,1) + left_global_origin(1), ...
            left_local_xyz(i,2) + left_global_origin(2), ...
            left_local_xyz(i,3) + left_global_origin(3), ...
            'ko');
        text(left_local_xyz(i,1) + left_global_origin(1), ...
            left_local_xyz(i,2) + left_global_origin(2), ...
            left_local_xyz(i,3) + left_global_origin(3), ...
            sprintf('%i',i));
    end
    for i = (1 : size(right_local_xyz,1))
        plot3(right_local_xyz(i,1) + right_global_origin(1), ...
            right_local_xyz(i,2) + right_global_origin(2), ...
            right_local_xyz(i,3) + right_global_origin(3), ...
            'ko');
        text(right_local_xyz(i,1) + right_global_origin(1), ...
            right_local_xyz(i,2) + right_global_origin(2), ...
            right_local_xyz(i,3) + right_global_origin(3), ...
            sprintf('%i',i+size(left_local_xyz,1)));
    end

    grid('minor');
    axis('equal');
    xlabel('x');
    ylabel('y');
    zlabel('z');
end

end