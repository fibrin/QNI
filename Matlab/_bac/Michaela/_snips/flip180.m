function [ im ] = flip180( imIn )
%FLIP180 Summary of this function goes here
%   Detailed explanation goes here
% im=imrotate(imIn,180);
[sy,sx]=size(imIn);
im=zeros(sy,sx);
%left-right
%for x=1:sx
%  im(:,sx-x+1)=imIn(:,x);
%end
%top-bottom
for y=1:sy
  im(sy-y+1,:)=imIn(y,:);
end  

end

