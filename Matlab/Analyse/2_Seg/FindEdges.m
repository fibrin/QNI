function [ Eim ] = FindEdges( im ,Th,Sig)
%FINDEDGES Summary of this function goes here
%   Detailed explanation goes here
if ~exist('Th','var'),Th=[];end;
if ~exist('Sig','var'),Sig=[];end;

ImageShow(im,'Start Edg');
tp=3;
if tp==1 || tp==0
  BW = edge(im,'canny',0.1,1,'nothinning');
  ImageShow(BW,'c 0.1,1');
  BW = edge(im,'canny',0.2,0.2,'nothinning');
  ImageShow(BW,'c 0.2,0.2');
  BW = edge(im,'canny',0.2,0.5,'nothinning');
  ImageShow(BW,'c 0.2,0.5');
  BW = edge(im,'canny',0.2,1,'nothinning');
  ImageShow(BW,'c 0.2,1');
  BW = edge(im,'canny',0.3,0.5,'nothinning');
  ImageShow(BW,'c 0.3,0.5');
  BW = edge(im,'canny',0.3,1,'nothinning');
  ImageShow(BW,'c 0.3,1');
  BW = edge(im,'canny',0.5,1,'nothinning');
  ImageShow(BW,'c 0.5,1');
  BW = edge(im,'canny',0.5,1.4,'nothinning');
  ImageShow(BW,'c 0.5,1.4');
  BW = edge(im,'canny',0.8,2,'nothinning');
  ImageShow(BW,'c 0.8,2');
  BW = edge(im,'canny',0.8,4,'nothinning');
  ImageShow(BW,'c 0.8,4');
  [BW ,Thres] = edge(im,'canny');
  ImageShow(BW,'c auto');
  
end
if (tp==2 || tp==0) && 0
  BW = FindEdgesCanny(im,'canny',0.1,1,'nothinning');
  ImageShow(BW,'c 0.1,1');
  BW = FindEdgesCanny(im,'canny',0.2,0.2,'nothinning');
  ImageShow(BW,'c 0.2,0.2');
  BW = FindEdgesCanny(im,'canny',0.2,0.5,'nothinning');
  ImageShow(BW,'c 0.2,0.5');
  BW = FindEdgesCanny(im,'canny',0.2,1,'nothinning');
  ImageShow(BW,'c 0.2,1');
  BW =FindEdgesCanny(im,'canny',0.3,0.5,'nothinning');
  ImageShow(BW,'c 0.3,0.5');
  BW = FindEdgesCanny(im,'canny',0.3,1,'nothinning');
  ImageShow(BW,'c 0.3,1');
  BW = FindEdgesCanny(im,'canny',0.5,1,'nothinning');
  ImageShow(BW,'c 0.5,1');
  BW = FindEdgesCanny(im,'canny',0.8,1,'nothinning');
  ImageShow(BW,'c 0.8,1');
  BW = FindEdgesCanny(im,'canny',.95,1,'nothinning');
  ImageShow(BW,'c 1,1');
  [BW,thres] = edge(im,'canny');
  ImageShow(BW,'c auto');
end


if tp==3 || tp==0
  if isempty(Th) 
     [BW,thres] = edge(im,'canny');
  else   
     BW = edge(im,'canny',Th,Sig,'nothinning');
  end   
  ImageShow(BW,'c');
end

if 0
  %BW=ImBorderClean(BW,4);
  se=strel('disk',1); 
  BW=imdilate(BW,se);
  BW=bwmorph(BW,'bridge');
  se=strel('disk',2); 
  BW=imclose(BW,se);
  %BW=bwmorph(BW,'skel');
  %BW=imdilate(BW,se);
  %se=strel('disk',1); 
  %BW=imclose(BW,se);
  ImageShow(BW,'Edges');
end
Eim=BW;
end

