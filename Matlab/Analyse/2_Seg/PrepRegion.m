function [ BWOut ] = PrepRegion( im,Th,minA,Brd,holes,cls)
%FINDMAXREGION Summary of this function goes here
%   Detailed explanation goes here
 %change Holes of wood to white
 
 if (nargin < 2) || isempty(Th)
   Th=80;
 end
 if (nargin < 3) || isempty(minA)
  minA=20;
 end
 if (nargin < 4) || isempty(Brd)
    Brd=0;
 end
 if (nargin < 5) || isempty(holes)
    holes=0;
 end
 if (nargin < 6) || isempty(cls)
    cls=2;
 end
 
  ImShow(1);
  
  %Add Black frame
  ImageShow(im,'PrepRegion im');
  
  %Thresholding
  im=imadjust(im,stretchlim(im));
  BW=im>Th;
  ImageShow(BW,'PrepReg BW');
  
  %make holes white
  %se=strel('disk',2);
  %im=imopen(im,se);
  %ImageShow(im);
  
  %Areas ar white
  % remove smale areas  
  % Holes
  BW=BW==0;
  BW=bwareaopen(BW,200);
  % Wood
  BW=BW==0;
  BW=bwareaopen(BW,200);
  ImageShow(BW,'PrepReg clean BW');
  
  
  se=strel('disk',2); 
  BW=imclose(BW,se);
  ImageShow(BW,'close wood 2');
  
  
  
  
  if ~Brd 
    BW=imclearborder(BW);
    ImageShow(BW);
  end
  % Wood +1
  se=strel('disk',1); 
  BW=imdilate(BW,se);
  
  
  BW=ImBorderAdd(BW,30,false);
   %close Small gabs in Wood struct
  se=strel('disk',cls);
  BW=imclose(BW,se);
  ImageShow(BW,'close wood cls');
  %BW=ImBorderRemove(BW,30);
  
  %BW=ImBorderAdd(BW,30,true);
  %earse small gap lines
  se=strel('disk',4);
  BW=imopen(BW,se);
  ImageShow(BW,'open air 4');
  BW=ImBorderRemove(BW,30);

  BW=ImBorderAdd(BW,30,true);
  se=strel('disk',2);
  BW=imclose(BW,se);
  ImageShow(BW,'close wood 2');
  BW=ImBorderRemove(BW,30);
  
  se=strel('disk',3);
  BW=imopen(BW,se);
  ImageShow(BW,'close Holes 3');
  
  % remove all objects les than x pix
  % Wood
  BW=bwareaopen(BW,minA);
  % Air
  BW=BW==0;
  BW=bwareaopen(BW,50);
  BW=BW==0;
 
  %
  % fill holes
  %BW=imfill(BW,'holes');
  %ImageShow(BW,'holes');
  if holes
    %make holes dark again
    BWOut=BW==0;
  else
    BWOut=BW;
  end  
  
  ImageShow(BWOut,'Prepair');
  ImShow('-');
  
end

