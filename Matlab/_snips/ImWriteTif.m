function [ output_args ] = ImWriteTif( Im,fn,f )
%IMWRITETIF Summary of this function goes here
%   Detailed explanation goes here
   
    if ~exist('f','var') || isempty(f) || f==1
      mi=min(min(Im));
      Im=Im-mi;
      ma=max(max(Im));
      Im=Im/ma;
      Im=Im*65536
    else
      Im=Im*f;
    end  
    Im=uint16(Im);
    imwrite(Im,fn)
end

