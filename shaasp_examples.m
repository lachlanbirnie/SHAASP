%% Example: spherical harmonic coefficients

% Setup acoustic environment.
sfd_f = 1000;  % Source / sound field frequency.
c = 343;  % Speed of sound.
k = 2 * pi * sfd_f / c;  % Wavenumber.

src_r = 1;  % Source position.
src_theta = pi/2;
src_phi = 0;

mic_r = 0.042;  % Microphone radius / Region of interest.

% Simulate spherical harmonic coefficients.
N = ceil(k * mic_r);  % Truncation order.
alphas = 1i .* k .* shaasp.sph_hn(N, k, src_r, "orientation", "[N,Q]") .* conj(shaasp.sph_ynm(N, src_theta, src_phi,"orientation", "[N,Q]"));


%% Example: spherical harmonic sound field reconstruction

% Continuing above example.
mic_theta = pi/2; % Microphone position.
mic_phi = 0;

% Reconsturct SH sound field at microphone.
p = sum(alphas .* shaasp.sph_jn(N, k, mic_r, "orientation", "[N,Q]") .* shaasp.sph_ynm(N, mic_theta, mic_phi, "orientation", "[N,Q]"), 2);

% ---

g = shaasp.sfd_greens('ps', k, shaasp.rtp2xyz(src_r, src_theta, src_phi), shaasp.rtp2xyz(mic_r, mic_theta, mic_phi));

% results:
disp(p); % p = 0.0355 - 0.0878i
disp(g); % g = 0.0222 - 0.0801i

% ---

N = 10;
alphas = 1i .* k .* shaasp.sph_hn(N, k, src_r) .* conj(shaasp.sph_ynm(N, src_theta, src_phi));
p = sum(alphas .* shaasp.sph_jn(N, k, mic_r) .* shaasp.sph_ynm(N, mic_theta, mic_phi), 2);

% results:
disp(p); % p = 0.0222 - 0.0801i
disp(g); % g = 0.0222 - 0.0801i

%% Example: spherical harmonic measurement

% Get microphone array positions.
[mic_r, mic_theta, mic_phi] = shaasp.sampling_positions_em32_eigenmike();

% 'Record' sound field by Green's function to get pressure at each
% microphone due to the point source.
mic_pressure = shaasp.sfd_greens_sphcoord('ps', k, [src_r, src_theta, src_phi], [mic_r, mic_theta, mic_phi]);

% --- 

N = 1;  % Change back to first order, was 10 from previous example.
measured_alphas = pinv(shaasp.sph_jn(N, k, mic_r, "orientation", "[Q,N]") .* shaasp.sph_ynm(N, mic_theta, mic_phi, "orientation", "[Q,N]")) * mic_pressure;

% Compare to theory.
disp([measured_alphas, alphas(1:4)]);
  %  0.2432 - 0.1429i   0.2432 - 0.1429i
  % -0.1588 - 0.3075i  -0.1588 - 0.3074i
  %  0.0001 + 0.0000i  -0.0000 - 0.0000i
  %  0.1588 + 0.3075i   0.1588 + 0.3074i






















