function [w3j] = wigner_3j_symbol(j1, j2, j3, m1, m2, m3)
% WIGNER_3J_SYMBOL - Compute Wigner 3j symbol using Racah formula. 
%
% Syntax:  [w3j] = wigner_3j_symbol(j1, j2, j3, m1, m2, m3)
%
% Inputs:
%
%   / j1 j2 j3 \
%   \ m1 m2 m3 /
%
%   Where all 'j' and 'm' terms are matricies of the same size.
%
% Outputs:
%   
%   w3j(i) = / j1(i) j2(i) j3(i) \
%            \ m1(i) m2(i) m3(i) /
%
%   w3j symbols corresponding to the elements of input terms.
%   Matrix is the same size as the input. 
%   w3j = 0 if the input terms are invalid.
%
% Theory: 
%
% w3j = factor1 * factor2 * factor3
%
% factor1 = (-1)^(j1 - j2 - m3)
%
%            ___________  ________________________________________________
% factor2 = /T(j1,j2,j3) /(j1+m1)!(j1-m1)!(j2+m2)!(j2-m2)!(j3+m3)!(j3-m3)!
%
%   T() = triangle coefficient.
%
% factor3 = sum over 't' [ (-1)^t / x(t) ] 
%
%   x(t) = eq. 8 on the mathworld webpage.
%
% Other m-files required: none
% Subfunctions: w3j_by_gammaln, w3j_by_factorial
% MAT-files required: none
%
% See also: none
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 14-June-2024
% Last revision: 19-July-2024
%
% References:
% https://mathworld.wolfram.com/Wigner3j-Symbol.html
% https://mathworld.wolfram.com/TriangleCoefficient.html
%
% David Terr (2024). Wigner3j.m 
% (https://www.mathworks.com/matlabcentral/fileexchange/5275-wigner3j-m), 
% MATLAB Central File Exchange. Retrieved June 14, 2024.
%
% Kobi (2024). Wigner3j symbol 
% (https://www.mathworks.com/matlabcentral/fileexchange/20619-wigner3j-symbol),
% MATLAB Central File Exchange. Retrieved June 14, 2024. 


% Check input size.
if ~isequal(size(j1), size(j2), size(j3), size(m1), size(m2), size(m3))
    error('Inputs must be same size.');
end

% Allocate w3j result with zeros.
original_size = size(j1);
w3j = zeros(original_size);

% Make all terms into columns.
make_col = @(x) x(:);

if numel(j1) > 1
    make_col(j1);
    make_col(j2);
    make_col(j3);
    make_col(m1);
    make_col(m2);
    make_col(m3);
end
    

% ##### Find which input terms are valid for w3j symbols. #####
% If no valid inputs remain, return zeros and a warning.

i_valid_inputs = ones(size(j1));  % Indexes of valid inputs.

% Term must be integer or half-integer.
i_valid_inputs = i_valid_inputs & (2*j1 == round(2*j1));
i_valid_inputs = i_valid_inputs & (2*j2 == round(2*j2));
i_valid_inputs = i_valid_inputs & (2*j3 == round(2*j3));
i_valid_inputs = i_valid_inputs & (2*m1 == round(2*m1));
i_valid_inputs = i_valid_inputs & (2*m2 == round(2*m2));
i_valid_inputs = i_valid_inputs & (2*m3 == round(2*m3));

if ~any(i_valid_inputs)
    warning('Wigner 3j terms must be integers or half-integers.');
    return;
end

% Selection rule 1, m is in range.
i_valid_inputs = i_valid_inputs & (abs(m1) <= abs(j1));
i_valid_inputs = i_valid_inputs & (abs(m2) <= abs(j2));
i_valid_inputs = i_valid_inputs & (abs(m3) <= abs(j3));

if ~any(i_valid_inputs)
    warning('Wigner 3j m_x terms must be within {-|j_x| : |j_x|}.')
    return;
end

% Selection rule 2, non-conserving angular momentum.
i_valid_inputs = i_valid_inputs & ((m1 + m2 + m3) == 0);

if ~any(i_valid_inputs)
    warning('Wigner 3j m terms must sum to zero.')
    return;
end

% Selection rule 3, triangular inequalities.
i_valid_inputs = i_valid_inputs & (abs(j1 - j2) <= j3) & (j3 <= (j1 + j2));

if ~any(i_valid_inputs)
    warning('Wigner 3j terms do not meet selection rule 3.')
    return;
end

% Selection rule 4, integer perimeter rule.
i_valid_inputs = i_valid_inputs & (j1 + j2 + j3 == round(j1 + j2 + j3));

if ~any(i_valid_inputs)
    warning('Wigner 3j j1,2,3 term do not sum to an integer.')
    return;
end

% Check general case: w3j=0 when m1,m2,m3 are 0, and j1+j2+j3 is odd.
is_case = (~m1 & ~m2 & ~m3) & (mod(j1 + j2 + j3, 2));
i_valid_inputs = i_valid_inputs & ~is_case;

if ~any(i_valid_inputs)
    warning('All Wigner 3j terms met the general case for zero.')
    return;
end

% Only solve the valid terms for now on.
j1 = j1(i_valid_inputs);
j2 = j2(i_valid_inputs);
j3 = j3(i_valid_inputs);
m1 = m1(i_valid_inputs);
m2 = m2(i_valid_inputs);
m3 = m3(i_valid_inputs);


% Solve w3j symbols using factorial() or gammaln() function. 
% valid_w3j = w3j_by_factorial(j1, j2, j3, m1, m2, m3);
valid_w3j = w3j_by_gammaln(j1, j2, j3, m1, m2, m3);


% #### Reshape w3j results to match the inputs, and return. ####
w3j(i_valid_inputs) = valid_w3j;

end


function [w3j] = w3j_by_gammaln(j1, j2 ,j3, m1, m2, m3)
    % #### Solve w3j symbols using Kobi Kraus's approach in log domain. ####
    %
    % Kobi uses the "gammaln" function instead of factorial, to calucalute the
    % w3j symbols in log domain. This has advantage of the factors not
    % rounding to inf in some cases.
    %
    % Note that     gammaln(n+1) == log(factorial(n)).
    % and,       (sqrt(x! * y!)) == exp(0.5 * gammaln(x + y))
    %
    % Kobi (2024). Wigner3j symbol (https://www.mathworks.com/matlabcentral
    % /fileexchange/20619-wigner3j-symbol), MATLAB Central File Exchange. 
    % Retrieved June 14, 2024. 
    
    % --- Factor 1) (-1)^(a - b - gamma) Eq. (7)
    factor1 = (-1).^(j1 - j2 - m3);
    
    % --- Factor 2) sqrt(tri_coe) * sqrt(f2 terms)
    tri_coes = [(j1 + j2 - j3), (j1 - j2 + j3), (-j1 + j2 + j3), (j1 + j2 + j3 + 1)];
    % Fourth term is divide, so add -1 coefficient for log(1/y) = -log(y).
    tri_signs = [1, 1, 1, -1];
    tri_coes_ln = 0.5 .* (tri_signs .* gammaln(tri_coes + 1));
    
    f2_coes = [(j1 + m1), (j1 - m1), (j2 + m2), (j2 - m2), (j3 + m3), (j3 - m3)];
    f2_coes_ln = 0.5 .* (gammaln(f2_coes + 1));
    
    factor2_ln = sum([tri_coes_ln, f2_coes_ln], 2);
    
    % -- Factor 3) summation over all integers t for which factorials all have
    % nonnegative arguments.
    
    % Separate the factorial terms in x (eq.8).
    x1 = j3 - j2 + m1;  % -1 * notation by Terr.
    x2 = j3 - j1 - m2;  % -1 * notation by Terr.
    x3 = j1 + j2 - j3;
    x4 = j1 - m1;
    x5 = j2 + m2;
    
    % t must be large enough such that x1+t and x2+t are nonnegative.
    tmin = abs(min(0, min(x1, x2)));
    
    % t must be small enough such that x3-t, x4-t, x5-t are nonnegative.
    tmax = min([x3, x4, x5], [], 2);
    
    % Solve factor 3 separately for each valid input (i).
    factor_2_and_3 = zeros(size(x1));
    
    for i = (1 : numel(factor_2_and_3))
        for t = (tmin(i) : tmax(i))
    
            % Eq. (8) on mathworld webpage.
            xt = [(t) ...
                 ,(x1(i) + t) ...
                 ,(x2(i) + t) ...
                 ,(x3(i) - t) ...
                 ,(x4(i) - t) ...
                 ,(x5(i) - t) ...
                 ];
    
            % Add factor 2 to factor 3 inside the exp() so big numbers don't
            % round to inf.
            % The (-1) in the summation is for the 1/x(t) in log domain.
            factor_2_and_3(i) = factor_2_and_3(i) + (-1).^t .* exp(sum(-1 .* gammaln(xt + 1), 2) + factor2_ln(i));
    
        end
    end
    
    % -- Solve w3j terms.
    w3j = factor1 .* factor_2_and_3;

end

function [w3j] = w3j_by_factorial(j1, j2, j3, m1, m2, m3)
    % #### Solve w3j symbols using Racah Formula. ####
    %
    % The following code calculates the w3j symbols using the factorial
    % notation from: 
    %   Weisstein, Eric W. "Wigner 3j-Symbol." From MathWorld--A Wolfram Web 
    %   Resource. https://mathworld.wolfram.com/Wigner3j-Symbol.html 
    % Breaks from large values going to Inf when j and m inputs are too
    % large. This does not occur for the gammaln function implementation.
    
    % -- Factor 1) (-1)^(a - b - gamma) eq.(7)
    factor1 = (-1).^(j1 - j2 - m3);
    
    % -- Factor 2) sqrt(tri_coe) * sqrt(more terms)
    tri_coe = factorial(j1 + j2 - j3) ...
           .* factorial(j1 - j2 + j3) ...
           .* factorial(-j1 + j2 + j3) ...
           ./ factorial(j1 + j2 + j3 + 1);
    
    f2_coe = factorial(j1 + m1) ...
             .* factorial(j1 - m1) ...
             .* factorial(j2 + m2) ...
             .* factorial(j2 - m2) ...
             .* factorial(j3 + m3) ...
             .* factorial(j3 - m3);
    
    factor2 = sqrt(tri_coe) .* sqrt(f2_coe);
    
    % -- Factor 3) summation over all integers t for which factorials all have
    % nonnegative arguments.
    
    % Separate the factorial terms in x(t) Eq. (8).
    x1 = j3 - j2 + m1;  % -1 * notation by Terr.
    x2 = j3 - j1 - m2;  % -1 * notation by Terr.
    x3 = j1 + j2 - j3;
    x4 = j1 - m1;
    x5 = j2 + m2;
    
    % t must be large enough such that x1+t and x2+t are nonnegative.
    tmin = abs(min(0, min(x1, x2)));
    
    % t must be small enough such that x3-t, x4-t, x5-t are nonnegative.
    tmax = min([x3, x4, x5], [], 2);
    
    % Solve factor 3 separately for each valid input (i).
    factor3 = zeros(size(x1));
    
    for i_f3 = (1 : numel(factor3))
    
        % Summing over t in Eq. (7).
        for t = (tmin(i_f3) : tmax(i_f3))
    
            % Eq. (8) on mathworld webpage.
            xt = factorial(t) ...
              .* factorial(x1(i_f3) + t) ...
              .* factorial(x2(i_f3) + t) ...
              .* factorial(x3(i_f3) - t) ...
              .* factorial(x4(i_f3) - t) ...
              .* factorial(x5(i_f3) - t);
    
            factor3(i_f3) = factor3(i_f3) + (-1).^t ./ xt;
    
        end
    end
    
    % -- Solve w3j terms.
    w3j = factor1 .* factor2 .* factor3;
end