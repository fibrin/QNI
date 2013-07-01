function [ Im] = removeBackground( I,s )
%REMOVEBACKGROUND Summary of this function goes here
%   Detailed explanation goes here
background = imopen(I,strel('disk',s));
Imageshow(background,'back');
Im=uint8(I - background);
ImageShow(Im,'Result');

end

