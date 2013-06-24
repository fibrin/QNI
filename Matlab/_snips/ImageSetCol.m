function [ I ] = ImageSetCol( Irgb,ImCol,Col,Th,m )
% Irgb Picture to becolored
% imCol GrayVal for coloring all pixels>th will be colored or mask and wrote To Irgb 
% Color to be set [255,255,255]  R G B
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

%% Make RGB  
if size(Irgb,3)<3
  I(:,:,1)=Irgb;  
  I(:,:,2)=Irgb;  
  I(:,:,3)=Irgb;
else  
  I=Irgb;
end
if ~isa(I,'uint8')
  if isa(I,'double') || isa(I,'single')
      ma=max(max(max(I)));
      if ma>0.1 && ma<2
        I=I*255/ma;
        I=uint8(I);
      else
        I=im2uint8(I);
      end
  else
    I=Irgb;
  end 
end

%% ??
if ~isa(ImCol,'uint8')
   if ~isa(ImCol,'double') || isa(I,'single')
      ma=max(max(max(I)));
      if ma>0.1 && ma<2  %double not between 0 and 1
        I=I*255/ma;
        I=uint8(I);
      else
        I=im2uint8(I);
      end
   else
      I=im2uint8(I);
   end    
end      


%% Set the Color
for ic=1:3
  Ii=I(:,:,ic);
  Ii(m)=Ii(m)*1+Col(ic);
  I(:,:,ic)=Ii;
end     
I(I>255)=255;
end

