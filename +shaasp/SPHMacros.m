classdef SPHMacros

    properties(Constant)

        C = 343;    % Speed of sound (m/s) @ 20 deg C.
        RHO = 1.2;  % Density of air (kg/m^3) @ 20 deg C.

        % k(f) - Wave number 'k' of frequency 'f' (Hz), k = 2*pi*f/C.
        k = @(f) 2 .* pi .* f ./ shaasp.SPHMacros.C;
        getWaveNumber = @(f) 2 .* pi .* f ./ shaasp.SPHMacros.C;

        % N(k,r) Spheical harmonic order truncation rule, N = kr.
        N = @(k,r) ceil(k .* r);
        NkrRule = @(k,r) ceil(k .* r);
        truncationOrder = @(k,r) ceil(k .* r);

        % Nker(k,r) Spheical harmonic order truncation rule, N = ker/2.
        Nker = @(k,r) ceil(k .* exp(1) .* r) ./ 2;
        NkerRule = @(k,r) ceil(k .*  r) ./ 2;

        % n_set(N) All harmonic orders 'n' in truncated set N.
        % n_set = [0 1 1 1 2 2 2 2 2 3 ... N] {1 by (N+1)^2}
        n_set = @(N) repelem((0:N), 2 .* (0:N) + 1).';
        
        % m_set(N) All harmonic modes 'm' in truncated set N.
        % m_set = [0 -1 0 +1 -2 -1 0 +1 +2 -3 ... +N] {1 by (N+1)^2}
        m_set = @(N) (1:(N+1)^2).' - shaasp.SPHMacros.n_set(N).^2 - shaasp.SPHMacros.n_set(N) - 1;

        % nm_ind(n,m) Index of the (n,m)th harmonic in a set. 
        nm_ind = @(n,m) n^2 + n + m + 1;

        % n_inds(n) Indexes of all n'th order harmonics in a set.
        n_inds = @(n) ((n^2+n-n+1) : (n^2+n+n+1));
        
        % m_inds(N,m) Indexes of all m'th mode harmonics in Nth order set. 
        m_inds = @(N,m) ((abs(m) : N).^2 + (abs(m) : N) + m + 1).';

        % even_m_inds(N,m) Index of all even m'th harmonics in a Nth order set.
        even_m_inds = @(N,m) ((abs(m):2:N).^2 + (abs(m):2:N) + m + 1).';
        
        % odd_m_inds(N,m) Index of all odd m'th harmonics in a Nth order set.
        odd_m_inds = @(N,m) ((abs(m)+1:2:N).^2 + (abs(m)+1:2:N) + m + 1).';

        % nm_total(N) Total number of harmonics in a Nth order truncated set.
        nm_total = @(N) (N+1)^2;

        % even_nm_total(N) Number of even harmonics in a Nth order truncation.
        even_nm_total = @(N) ((N+1) * (N+2)) / 2;

        % odd_nm_total(N) Number of odd harmonics in a Nth order truncation.
        odd_nm_total = @(N) (N * (N+1)) / 2;

        % even_m_total(N,m) Number of even modes in a Nth order truncation.
        even_m_total = @(N,m) ceil((N - abs(m) + 1) / 2);

        % odd_m_total(N,m) Number of odd modes in a Nth order truncation.
        odd_m_total = @(N,m) floor((N - abs(m) + 1) / 2);

    end

end