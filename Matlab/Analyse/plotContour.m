function [ fig ] = plotContour( BW,figIn,nm,nr ,LineWidth)
%PLOTCONTOUR Summary of this function goes here
%   Detailed explanation goes here

if ~exist('figIn','var') || isempty(figIn)
  fig=figure;
  %set(fig,'DefaultAxesLineStyleOrder',{'--',':'});
  %set(fig,'DefaultAxesColorOrder',[1 0 1; 0 1 1; 0 1 0]);
  % I=zeros(size(BW));
  % imshow(I);
else
  fig=figIn;
end  
colors=jet(8);
if ~exist('nm','var'),nm=[];end;
if ~exist('nr','var'),nr=1;end;
if ~exist('LineWidth','var'),LW=1;else  LW=LineWidth ;end;

[bnd,L,N]=bwboundaries(BW);
%find largest boundary
cm=0;bi=0;
for i=1:N
  B=bnd{N};
  cnt=sum(sum(B));
  if cnt>cm
    bi=i;
    cm=cnt;
  end
end
if bi>0
 figure(fig);
 %plot it
 Cell=bnd{bi};
 x1=Cell(:,2);y1=Cell(:,1);
 x1=uint32(x1);y1=uint32(y1);
 n=numel(x1)-1;
 if n>0
   %numCell=numCell+1;
   %reg{numCell}=[y1 x1];
   % plot line
   hold on;
   l=plot(x1,y1,'Color',colors(nr,:));
   set(l,'LineWidth',LW);
   if ~isempty(nm),  set(l,'DisplayName',nm);end;
   hold off;
   % plot point 
   % plot(x1,y1,colp,'LineWidth',3);
 end
end
end

