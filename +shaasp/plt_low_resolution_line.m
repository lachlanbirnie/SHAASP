function [h] = plt_low_resolution_line(x, y, res, options)
% PLT_LOW_RESOLUTION_LINE - plot a line with low resolution.
% Simply plots a subset of the x and y data points.
%
% Syntax:  [h] = plt_low_resolution_line(x,y,res,options)
%
% Inputs:
%   x - data.
%   y - data.
%   res - number of data points to plot. Default: 16000
%
% Outputs:
%   h - handle to the plot line object.
%
% Other m-files required: none
% Subfunctions: plot(x,y)
% MAT-files required: none
%
% See also:
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 15-Aug-2024
% Last revision: 23-Aug-2024

    arguments
        x (:,:) double;
        y (:,:) double = [];
        res (1,1) double = 16000;  % approx 16k resolutoin monitor.
        options.?matlab.graphics.chart.primitive.Line;
    end

    optionsCell = namedargs2cell(options);
    [x_low, y_low] = low_resolution_line(x, y, res);
    h = plot(x_low, y_low, optionsCell{:});
end


function [x_low, y_low] = low_resolution_line(x, y, res)
    if isempty(y)
        y = x;
        x = (1 : length(y)).';
    end
    
    if isrow(y)
        y = y.';
    end

    if size(y,1) > res
        ind_low = floor(linspace(1, size(y,1), res));
        x_low = x(ind_low);
        y_low = y(ind_low, :);
    else
        x_low = x;
        y_low = y;
    end
end