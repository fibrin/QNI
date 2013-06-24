function [ im ] = imReadDbl( imfn )
%IMREADFITS Summary of this function goes here
%   Detailed explanation goes here
 imi=imread(imfn);
 im=im2double(imi);
end

