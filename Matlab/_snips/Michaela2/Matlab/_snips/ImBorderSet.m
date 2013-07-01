function [ Imo] = ImBorderSet( Im,bd,pixv )
%IMBORDERCLEAN Summary of this function goes here
%   Detailed explanation goes here
if ~exist('bd','var')
  bd=1;
end
if ~exist('pixv','var')
  pixv=0;
end
  
sx=size(Im,2);
sy=size(Im,1);
Imo=Im;
if numel(bd)>1 %ROI
  x1=round(bd(1,1)); y1=round(bd(1,2)); %lefttop
  x2=round(bd(2,1)); y2=round(bd(2,2)); %rightbottom
  Imo(1:y1,1:sx)=pixv;
  Imo(y2:sy,1:sx)=pixv;
  Imo(1:sy,1:x1)=pixv;
  Imo(1:sy,x2:sx)=pixv;
else %bd
  if pixv>=0 
    Imo(1:bd,1:sx)=pixv;
    Imo(sy-bd+1:sy,1:sx)=pixv;
    Imo(1:sy,1:bd)=pixv;
    Imo(1:sy,sx-bd+1:sx)=pixv;
  else
    %bad with last
    for i=1:bd
      Imo(i,:)=Im(bd+1,:);
      Imo(sy-i+1,:)=Im(sy-bd,:);
      Imo(:,i)=Im(:,bd+1);
      Imo(:,sx-i+1)=Im(:,sx-bd);
    end
  end  
end  
%ImageShow(Imo,'Border set');
end

