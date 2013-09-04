function [ I ] = ImReadFits( fn )
%IMREADFITS Summary of this function goes here
%   Detailed explanation goes here
  data=fitsread(fn);
  I=flipud(data);

end

