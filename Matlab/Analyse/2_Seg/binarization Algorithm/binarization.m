% ͼ���ֵ���ű�����Otsu������Niblack������Kittler��С������󷽷���
% ��Matlab������ʱ�����԰Ѹ��ļ�����Ϊ��ǰĿ¼(Current Directory)
% �ȶ���Ҷ�ͼƬ
I = imread('coins.bmp');

% Otsu��ֵ��
I_bw_o = otsu(I);
% ��ʾ��ֵ�����
figure, imshow(I_bw_o);
% Kittler��ֵ�� 
I_bw_k = kittlerMet(I);
% ��ʾ��ֵ�����
figure, imshow(I_bw_k);
% niblack��ֵ��
I_bw_n = niblack(I);
% ��ʾ��ֵ�����
figure, imshow(I_bw_n);