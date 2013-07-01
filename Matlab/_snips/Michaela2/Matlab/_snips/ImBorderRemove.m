function [ I] = ImBorderRemove( Im,bd)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ~exist('bd','var')
  bd=1;
end
sy=size(Im,1);
sx=size(Im,2);
I=Im(bd:sy-bd,bd:sx-bd);
%ImageShow(I,'Border Remove');

end

