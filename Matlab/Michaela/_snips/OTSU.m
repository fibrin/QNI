function [ BW ] = OTSU( Im,levrange)
%OTSU Summary of this function goes here
%   Detailed explanation goes here
  level = graythresh(Im);
  BW = im2bw(Im,level);
end

