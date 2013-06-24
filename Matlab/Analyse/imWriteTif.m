function [ output_args ] = imWriteTif( Im,fn,auto )
%IMWRITETIF Summary of this function goes here
%   Detailed explanation goes here
if ~exist('auto','var')
  auto=0;
end
if auto 
  Imin=min(min(Im));
  Imax=max(max(Im));
  Im=(Im-Imin)/(Imax-Imin);
  Im=im2uint16(Im);
else
  if isa(Im,'double')
    Im=im2uint16(Im);
  else  
    Im=im2uint16(Im);
  end
end  
imwrite(Im,fn);
end

