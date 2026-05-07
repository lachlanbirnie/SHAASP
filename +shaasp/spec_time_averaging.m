function [ave_spec] = spec_time_averaging(spec, num_ave_time_frames, averaging_method)
% SPEC_TIME_AVERAGING - Averager a spectrum over a number of time frames.
% Used to calculate covariance matrix.
%
% Syntax:   [ave_spec] = spec_time_averaging(spec, num_ave_time_frames)
%
% Inputs:
%   spec - [fbins, tbins, channels]
%   num_ave_time_frames - scalar, number of tframes to average over.
%   averaging_method - "causal", "all", or "closest" (default)
%
% Outputs:
%   ave_spec - [fbins, tbins, channels]
%
%
% See also: spec_to_crossspec
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 29-Aug-2024
% Last revision: 04-Oct-2024

arguments
    spec (:,:,:,:)
    num_ave_time_frames = []
    averaging_method {mustBeMember(averaging_method, ["causal", "all", "closest"])} = "closest"
end

spec_nframes = size(spec, 2);

if isempty(num_ave_time_frames) || (num_ave_time_frames > spec_nframes)
    num_ave_time_frames = spec_nframes;
end
    
switch averaging_method
    case "all"
        ave_spec = mean(spec, 2);
        return;

    case "causal"
        ave_spec = zeros(size(spec));
    
        for i = (1 : spec_nframes)
            ave_frame_inds = (i - ceil(num_ave_time_frames) - 1 : i);
            
            if (ave_frame_inds(1) < 1)
                ave_frame_inds = (1 : i);
            end
    
            ave_spec(:, i, :) = sum(spec(:, ave_frame_inds, :), 2) .* (1/length(ave_frame_inds));
        end
    
        return;

    case "closest"
        ave_spec = zeros(size(spec));
        
        for i = (1 : spec_nframes)
            % Average over next past and future time frames.
            ave_frame_inds = (i - floor(num_ave_time_frames/2) : i + ceil(num_ave_time_frames/2) - 1);
        
            % Average over future tframes.
            if (ave_frame_inds(1) < 1)
                ave_frame_inds = (1 : num_ave_time_frames);
            end
        
            % Average over past tframes.
            if (ave_frame_inds(end) > spec_nframes)
                ave_frame_inds = (spec_nframes - num_ave_time_frames + 1 : spec_nframes);
            end
        
            ave_spec(:, i, :) = sum(spec(:, ave_frame_inds, :), 2) .* (1/length(ave_frame_inds));
        end
    
        return;

    otherwise
        error('Invalid averaging method.');
end

end