function [ I ] = ImageSetCol( Irgb,ImCol,Col,Th,m )
% Irgb Pictur,e to becolored
% imCol GrayVal for coloring all pixels>th will be colored or mask and wrote To Irgb 
% Col numer of Color 1,2,3 R G B
% Th treshold Level for the mask if mask is empty
% mask 
if (nargin < 3) || isempty(Col)
  Col=[255,255,255];
end
if (nargin < 4) || isempty(Th)
    Th=0;
end
if (nargin < 5) || isempty(m)
  m=(ImCol>Th);
else
  m=m>0;  
end
if size(Irgb,3)<3 
  I(:,:,1)=Irgb;  
  I(:,:,2)=Irgb;  
  I(:,:,3)=Irgb;  
else
  I=Irgb;
end  
for ic=1:3
  Ii=I(:,:,ic);
  Ii(m)=Col(ic);
  I(:,:,ic)=Ii;
end     
end

