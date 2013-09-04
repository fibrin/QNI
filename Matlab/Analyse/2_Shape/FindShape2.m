function [R, B] = FindShape2(BW, fig)
  %  finds the largest shape ( object) in a black white image
  %  input 
  %   BW black white Image
  %   fig not used
  %  output 
  %    R :largest white Object in the image
  %    B :longest boundary  should be  boundary of the object
  % ---------------------------------------------------------- 
   
    %% Region an its properties
    R=[]; 
    L1=bwlabel(BW);
    R1=regionprops(L1,{'Centroid','Area','Eccentricity','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation'});
    if length(R1)<1
      %no region
      return
    end
    %get largest region
    a=[R1(:).Area];
    [idx] = find(max(a));
    R=R1(idx(1));
    
    %% boundary vector
    B=[];
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
    end
    
    
  

end

