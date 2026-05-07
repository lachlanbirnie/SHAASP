function [p] = sfd_greens_sphcoord(source_type, k, source_rtp, mic_rtp, s, w)
% [p] = sfd_greens_sphcoord(source_type, k, source_rtp, mic_rtp, s, w)
% Wrapper function for shaasp.sfd_greens().
% Take input as spherical coordinates instead of cartesian coordinates.
% (r,t,p) == (radius, theta, phi) == (radius, elevation, azimuth).
% Theta = elevation angle downwards from +z-axis, 0 to pi.
% Phi = azimuth angle counterclockwise from +x-axis >> +y-axis, 0 to 2pi.

    arguments
        source_type {mustBeMember(source_type, ...
            ["pw", "planewave", "pw-", "planewave-", "pw+", "planewave+", ...
             "ps", "pointsource", "ps-", "pointsource-", "ps+", "pointsource+", ...
             "ms", "mixedsource", "ms-", "mixedsource-", "ms+", "mixedsource+", ...
             "mw", "mixedwave", "mw-", "mixedwave-", "mw+", "mixedwave+"])}
        k {mustBeScalarOrEmpty}
        source_rtp (:,:)
        mic_rtp (:,3)
        s (:,1) = 1
        w (:,1) = 1
    end

    % Allow input of planewave source (theta, phi)
    if size(source_rtp, 2) == 2
        source_rtp = [zeros(size(source_rtp,1),1), source_rtp];
    end

    % Convert to cartesian.
    mic_xyz = shaasp.rtp2xyz(mic_rtp);
    if contains(source_type, {'pw', 'planewave'})
        source_xyz = shaasp.rtp2xyz(k, source_rtp(:,2), source_rtp(:,3));
    else
        source_xyz = shaasp.rtp2xyz(source_rtp);
    end
    
    p = shaasp.sfd_greens(source_type, k, source_xyz, mic_xyz, s, w);    
end