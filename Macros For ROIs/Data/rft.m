function out = rft(mag, phi, freq, N)
    out = zeros(N,1);
    for n = 1:N
        for j = 1:length(mag)
            out(n) = out(n) + mag(j)*cos(2*pi*freq(j)*(n-1) + phi(j));
        end
    end
end