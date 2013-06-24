function [ ImO ] = FlipPic( Im,Or_LR)
%FLIPPIC Summary of this function goes here
%   Detailed explanation goes here

sx=size(Im,2);
sy=size(Im,1);
if ~exist('Or_LR','var')
    O='R';
else
    O=Or_LR;
end     
ImO=uint8(zeros(sx,sy));
if O=='R' 
    for y=1:sy
        ImO(:,sy-y+1)=Im(y,:);
    end
elseif O=='L'
    for x=1:sx
        ImO(sx-x+1,:)=Im(:,x);
    end
else
  ImO=[];
  error('FlipError','Wrong Orientation Parameter');
end

end

