function [ Imo] = ImBorderSet( Im,bd,pixv,frame )
% changes the values of the imige border
% Im the image
% bd pixelwidth of the border default=1
% or [x1,y1]
% pix the value of the pixels added to the image def=0
if ~exist('bd','var')
  bd=1;
end
if ~exist('pixv','var')
  pixv=0;
end
if ~exist('frame','var')
  frame=0;
end
  
sx0=1;
sy0=1;
sx=size(Im,2);
sy=size(Im,1);

if frame
  [y,x]=find(Im>0);
  sx0=min(x);sx=max(x);
  sy0=min(y);sy=max(y);
end

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
    Imo(sy0:sy0+bd-1,sx0:sx)=pixv;
    Imo(sy-bd+1:sy,sx0:sx)=pixv;
    Imo(sy0:sy,sx0:sx0+bd-1)=pixv;
    Imo(sy0:sy,sx-bd+1:sx)=pixv;
  else
    %bad with last
    for i=1:bd
      Imo(sy0+i-1,:)=Im(bd+1,:);
      Imo(sy-i+1,:)=Im(sy-bd,:);
      Imo(:,sx0+i-1)=Im(:,bd+1);
      Imo(:,sx-i+1)=Im(:,sx-bd);
    end
  end  
end  
%ImageShow(Imo,'Border set');
end

