function [h] = plotdata_add_circle(R,x,y,line_color)
% PLTDATA_ADD_CIRCLE - Add a circle to a surface / sound field plot.
% Usually to indicate the region of interest.
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
% Inputs:
%   R - Radius of circle
%   x,y - center of circle's x,y position.
%   line_color - Color of circle.
%
% Outputs:
%   h - handle of the circle line.
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 29-July-2024
% Last revision: 18-Nov-2024
    
% Default inputs.
if nargin < 2
    x = 0;
    y = 0;
end

if nargin < 4
    line_color = [1,1,1];
end

h = viscircles([x, y], R ...
              ,'EnhanceVisibility',true ...
              ,'LineWidth', 1 ...
              );

% Inner line is solid color.
h1 = h.Children(1);
h1.Color = line_color;
h1.LineWidth = 1;
h1.LineStyle = '-';
    
% Outer line are black dots.
h2 = h.Children(2);
h2.Color = [0 0 0];
h2.LineWidth = 2.5;
h2.LineStyle = ':';
              
end