
function [ Imo] = ImBorderAdd( Im,bd,pix )
%IMBORDERCLEAN Summary of this function goes here
%   Detailed explanation goes here
if ~exist('bd','var')
  bd=1;
end
if ~exist('pix','var')
  pix=-1;
end
sx=size(Im,2);
sy=size(Im,1);
Imo=zeros(sy+2*bd,sx+2*bd);
Imo(bd+1:sy+bd,bd+1:sx+bd)=Im;
Imo=ImBorderSet(Imo,bd,pix);
%ImageShow(Imo,'Border add');
end

