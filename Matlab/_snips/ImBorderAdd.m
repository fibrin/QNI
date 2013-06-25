
function [ Imo] = ImBorderAdd( Im,bd,pix )
% Adds a border to image
% Im the image
% bd bixelwidth of the border sedfaul=1
% pix the value of the pixels added to the image def=0
if ~exist('bd','var')
  bd=1;
end
if ~exist('pix','var')
  pix=0;
end
sx=size(Im,2);
sy=size(Im,1);
Imo=zeros(sy+2*bd,sx+2*bd);
Imo(bd+1:sy+bd,bd+1:sx+bd)=Im;
Imo=ImBorderSet(Imo,bd,pix);
%ImageShow(Imo,'Border add');
end

