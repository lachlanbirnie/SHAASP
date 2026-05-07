function [c] = sph_bninv_regularization(bnkr, type, options)
%SPH_BNINV_REGULARIZATION Get regularization matrix C for a radial
% funciton bn(kr), such that the regularized b_inv = C .* b_inv.
%
% Inputs:
%   bnkr - [N by R by K] matrix of bn(kr) values. [NOT 1/bn(kr)]
%   type - of regularization {'PWD', 'R-PWD', 'Tikhonov', 'Softknee'}
%
%   - options -
%   R_PWD_SNR = 40;  % R-PWD snr value.
%   TIKHONOV_LAMBDA = 0.1;  % Tikhonov lambda value.
%   SOFTKNEE_AMP_DB = 62;  % Softknee max amplitude gain value.
%
% Outputs:
%   c - [N by R by K] regularization weight matrix use in: c .* bnkr.^-1;
%
% References:
% Ville Pulkki; Symeon Delikaris-Manias; Archontis Politis, 
% "Spatial Decomposition by Spherical Array Processing," 
% in Parametric Time-Frequency Domain Spatial Audio , IEEE, 2018, 
% pp.25-47, doi: 10.1002/9781119252634.ch2.
%
% See also: sph_bn_rigid,  sph_bn_cardioid, 
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 16-Dec-2024
% Last revision: 16-Dec-2024

arguments
    bnkr (:,:,:)
    type {ismember(type,["conv","PWD","R-PWD","Tikhonov","Softknee"])} = "R-PWD";
    options.R_PWD_SNR_DB = 40;
    options.TIKHONOV_LAMBDA = 0.1;
    options.SOFTKNEE_AMP_DB = 62;
end

switch type
    case {'conv', 'PWD'}
        c = ones(size(bnkr));
    case 'R-PWD'
        c = abs(bnkr).^2 ./ ( abs(bnkr).^2 + (10.^(options.R_PWD_SNR_DB/10)).^-1 );
    case 'Tikhonov'
        c = abs(bnkr).^2 ./ ( abs(bnkr).^2 + options.TIKHONOV_LAMBDA.^2 );
    case 'Softknee'
        amp = 10.^(options.SOFTKNEE_AMP_DB/20);
        invb = bnkr.^-1;
        c = (2*amp)./pi .* 1./abs(invb) .* atan(pi./(2*amp) .* abs(invb));
    otherwise
        error('Invalid regularization type {"R-PWD", "Tikhonov"}.');
end

end

% PLOTTING:
% close all;
% 
% f = 10:1:10000;
% k = 2 .* pi .* f ./ 343;
% r = 0.042;
% 
% N = 3;
% 
% b = shaasp.sph_bn(N, k, r);
% ib = b.^-1;
% b3 = squeeze(ib(1,end,:));
% 
% plot(f, 20.*log10(abs(b3)));
% hold on;
% 
% c = sph_bn_regularization(b, 'PWD');
% cb = c .* b.^-1;
% cb3 = squeeze(cb(1,end,:));
% 
% plot(f, 20.*log10(abs(cb3)), 'DisplayName', 'PWD');
% 
% c = sph_bn_regularization(b, 'R-PWD');
% cb = c .* b.^-1;
% cb3 = squeeze(cb(1,end,:));
% 
% plot(f, 20.*log10(abs(cb3)), 'DisplayName', 'R-PWD');
% 
% c = sph_bn_regularization(b, 'Softknee');
% cb = c .* b.^-1;
% cb3 = squeeze(cb(1,end,:));
% 
% plot(f, 20.*log10(abs(cb3)), 'DisplayName', 'Softknee');
% 
% c = sph_bn_regularization(b, 'Tikhonov');
% cb = c .* b.^-1;
% cb3 = squeeze(cb(1,end,:));
% 
% plot(f, 20.*log10(abs(cb3)), 'DisplayName', 'Tikhonov');
% 
% legend('show');