function [fbin] = cola_nfft_bin_frequencies(fs, nfft, SINGLE_SIDED)
    fbin = linspace(0, fs, nfft + 1);
    fbin = fbin(1 : end-1);
    if SINGLE_SIDED
        if ~mod(nfft, 2)
            fbin = fbin(1 : end/2+1);
        else
            fbin = fbin(1 : ceil(end/2));
        end
    end
end