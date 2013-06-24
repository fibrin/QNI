function imagBW = otsu(imag)
% OTSU binarizes a gray scale image 'imag' into a binary image, with the
% noises removed.
% Input:
%   imag: the gray scale image, with black foreground(0), and white
%   background(255).
% Output:
%   imagBW: the binary image of the gray scale image 'imag', with Otsu
%   algorithm.

% Reference:
%   Nobuyuki Otsu. A Threshold Selection Method from Gray-Level Histograms.
%   IEEE Transactions on Systems, Man, and Cybernetics. 1979.SMC-9(1):62-66

imag = imag(:, :, 1);

[counts, x] = imhist(imag);  % counts are the histogram. x is the intensity level.
GradeI = length(x);   % the resolusion of the intensity. i.e. 256 for uint8.
varB = zeros(GradeI, 1);  % Between-class Variance of binarized image.

prob = counts ./ sum(counts);  % Probability distribution
meanT = 0;  % Total mean level of the picture
for i = 0 : (GradeI-1)
    meanT = meanT + i * prob(i+1);
end
varT = ((x-meanT).^2)' * prob; 
% Initialization
w0 = prob(1);   % Probability of the first class
miuK = 0;   % First-order cumulative moments of the histogram up to the kth level.
varB(1) = 0;
% Between-class variance calculation
for i = 1 : (GradeI-1)
    w0 = w0 + prob(i+1);
    miuK = miuK + i * prob(i+1);
    if (w0 == 0) || (w0 == 1)
        varB(i+1) = 0;
    else
        varB(i+1) = (meanT * w0 - miuK) .^ 2 / (w0 * (1-w0));
    end
end

maxvar = max(varB);
em = maxvar / varT  % Effective measure
index = find(varB == maxvar);
index = mean(index);
th = (index-1)/(GradeI-1)
imagBW = im2bw(imag, th);

% thOTSU = graythresh(imag)
% imagBWO = im2bw(imag, thOTSU);








