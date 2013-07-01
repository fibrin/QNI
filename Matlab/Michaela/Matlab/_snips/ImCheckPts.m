function [ Ptso] = ImCheckPts( Im,Pts,corr_del )
%IMCHECKPTS Summary of this function goes here
%   Detailed explanation goes here
  if nargin<3 || isempty(corr_del)
    corr_del=0;
  end
  [sy,sx]=size(Im);
  if corr_del==0 
    %correct
    Pts(Pts(:,1)<1,1)=1;
    Pts(Pts(:,1)>sx,1)=sx;
    Pts(Pts(:,2)<1,2)=1;
    Pts(Pts(:,2)>sy,2)=sy;
    Ptso=Pts;
  else
    %delet
    del=zeros(size(Pts,1),1);
    del(Pts(:,1)<1)=1;
    del(Pts(:,1)>sx)=1;
    del(Pts(:,2)<1)=1;
    del(Pts(:,2)>sy)=1;
    Ptso=Pts(del==0,:);
  end
    
end

