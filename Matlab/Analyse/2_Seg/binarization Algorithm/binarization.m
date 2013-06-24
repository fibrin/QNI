% 图像二值化脚本程序（Otsu方法，Niblack方法，Kittler最小分类错误方法）
% 在Matlab上运行时，可以把该文件夹设为当前目录(Current Directory)
% 先读入灰度图片
I = imread('coins.bmp');

% Otsu二值化
I_bw_o = otsu(I);
% 显示二值化结果
figure, imshow(I_bw_o);
% Kittler二值化 
I_bw_k = kittlerMet(I);
% 显示二值化结果
figure, imshow(I_bw_k);
% niblack二值化
I_bw_n = niblack(I);
% 显示二值化结果
figure, imshow(I_bw_n);