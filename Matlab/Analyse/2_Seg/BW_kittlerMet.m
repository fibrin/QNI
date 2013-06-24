function imagBW = kittlerMet(imag)
% KITTLERMET binarizes a gray scale image 'imag' into a binary image
% Input:
%   imag: the gray scale image, with black foreground(0), and white
%   background(255).
% Output:
%   imagBW: the binary image of the gray scale image 'imag', with kittler's
%   minimum error thresholding algorithm.

% Reference:
%   J. Kittler and J. Illingworth. Minimum Error Thresholding. Pattern
%   Recognition. 1986. 19(1):41-47

MAXD = 100000;
imag = imag(:,:,1);
[counts, x] = imhist(imag);  % counts are the histogram. x is the intensity level.
GradeI = length(x);   % the resolusion of the intensity. i.e. 256 for uint8.
J_t = zeros(GradeI, 1);  % criterion function
prob = counts ./ sum(counts);  % Probability distribution
meanT = x' * prob;  % Total mean level of the picture
% Initialization
w0 = prob(1);   % Probability of the first class
miuK = 0;   % First-order cumulative moments of the histogram up to the kth level.
J_t(1) = MAXD; 
n = GradeI-1;
for i = 1 : n
    w0 = w0 + prob(i+1);
    miuK = miuK + i * prob(i+1);  % first-order cumulative moment
    if (w0 < eps) || (w0 > 1-eps)
        J_t(i+1) = MAXD;    % T = i
    else
        miu1 = miuK / w0;
        miu2 = (meanT-miuK) / (1-w0);
        var1 = (((0 : i)'-miu1).^2)' * prob(1 : i+1);
        var1 = var1 / w0;  % variance
        var2 = (((i+1 : n)'-miu2).^2)' * prob(i+2 : n+1);
        var2 = var2 / (1-w0);
        if var1 > eps && var2 > eps   % in case of var1=0 or var2 =0
            J_t(i+1) = 1+w0 * log(var1)+(1-w0) * log(var2)-2*w0*log(w0)-2*(1-w0)*log(1-w0);
        else
            J_t(i+1) = MAXD;
        end
    end
end
minJ = min(J_t);
index = find(J_t == minJ);
th = mean(index);
th = (th-1)/n
imagBW = im2bw(imag, th);

% figure, imshow(imagBW), title('kittler binary');

