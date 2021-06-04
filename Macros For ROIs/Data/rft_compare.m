%% Curve Generator
% This function generates a matrix of reverse fourier transforms based on
% the data found in the sorted matrix to look at where the approximation
% falls apart

N = 2*481;
rfts = zeros(N, 5);

for i = 1:5
    rfts(:, i) = rft(sorted(1:(i*5), 1), sorted(1:(i*5), 2), sorted(1:(i*5), 3), N);
end