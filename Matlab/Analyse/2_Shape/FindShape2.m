function [R, B] = FindShape2(BW, fig)
%FINDSHAPE2 Summary of this function goes here
%   Detailed explanation goes here
   
    %%
    R=[]; 
    L1=bwlabel(BW);
    R1=regionprops(L1,{'Centroid','Area','Eccentricity','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation'});
    if length(R1)<1
      return
    end  
    a=[R1(:).Area];
    [idx] = find(max(a));
    R=R1(idx(1));
    
    %%
    [bnd,L,N]=bwboundaries(BW);
    %find largest boundary
    cm=0;bi=0; 
    for i=1:N
      B=bnd{N};
      cnt=size(B,1);
      if cnt>cm
        bi=i;
        cm=cnt;
      end
    end

    if bi>0
      B=bnd{bi};
    else
      B=[];
    end
    
    
  

end

