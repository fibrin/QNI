function [ output_args ] = fitCurve( BW,figIn )
%FITCURVE Summary of this function goes here
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
 



end

