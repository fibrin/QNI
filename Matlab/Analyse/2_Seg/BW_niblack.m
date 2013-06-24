function imagBW = niblack(imag)
% NIBLACK binarizes a gray scale image 'imag' to a binary image, using
% Niblack algorithm. The noises of the gray scale image are removed.
%  Input:
%       imag: the gray scale image, with black foreground(0), and white
%       background(255).
%  Output:
%       imagBW: the binary image of the gray scale image 'imag', with
%       Niblack algorithm.

% Reference:
%   Wayne Niblack. An Introduction to Digital Image Processing. pp: 115.
%   1986. Prentice/Hall International. ISBN: 013 480674 3

tic;

k = -0.2;  % the first manual parameter
b = 80;   % the second manual parameter, about the width of the square neighborhood
choice = 1; % 1 for pixel-to-pixel computation, 2 for pixel averaging within the square neighborhood for fast computation.

imag = imag( :, :, 1);
[Hei, Wid] = size(imag);

imag = padarray(imag, [b b], 'symmetric', 'both');  % Pad image array 
Hei_pad = Hei + 2 * b;
Wid_pad = Wid + 2 * b;
imagBW = false(Hei_pad, Wid_pad);
switch choice
    case 1
        for i = 1+b : Hei+b
            for j = 1+b : Wid+b
                upR = i-floor(b/2-1/2);
                dnR = i+floor(b/2);
                lfC = j-floor(b/2-1/2);
                rtC = j+floor(b/2);
                m_ij = mean(mean(imag(upR : dnR, lfC : rtC)));
                sigma_squared = double(imag(upR : dnR, lfC : rtC)) - m_ij;
                sigma_squared = mean(mean(sigma_squared .^2));
                sigma = sqrt(sigma_squared);
                th_ij = m_ij + k * sigma;
                if double(imag(i,j)) > th_ij
                   imagBW(i,j) = 1;
                end
            end
        end
    case 2
        for i = 1+b : b : Hei+b
            for j = 1+b : b : Wid+b
                upR =  i-floor(b/2-1/2);
                dnR =  i+floor(b/2);
                lfC =  j-floor(b/2-1/2);
                rtC =  j+floor(b/2);
                m_ij = mean(mean(imag(upR : dnR, lfC : rtC)));
                sigma_squared = double(imag(upR : dnR, lfC : rtC)) - repmat(m_ij, (dnR-upR+1), (rtC-lfC+1));
                sigma_squared = sigma_squared .^ 2;
                sigma_squared = mean(mean(sigma_squared));
                sigma = sqrt(sigma_squared);
                th_ij = m_ij + k * sigma;
                imagBW(upR : dnR, lfC : rtC) = double(imag(upR : dnR, lfC : rtC)) > th_ij;
            end
        end
    otherwise
        display('Wrong Choice!');
end
imagBW = imagBW(1+b : Hei+b, 1+b : Wid+b);
% figure, imshow(imagBW), title('Binarized Image');
toc;

        
        
