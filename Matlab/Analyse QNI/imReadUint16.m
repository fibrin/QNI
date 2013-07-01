function [ im ] = imreadUint16( imfn )
%IMREADFITS Summary of this function goes here
%   Detailed explanation goes here
 imi=imread(imfn);
 l=length(imfn);
 tp=imfn(l-3:l);
 im=imi;
 if strcmp(tp,'fits')
   sy=size(imi,1);
   for i=1:sy
     im(i,:)=imi(sy-i+1,:);
   end
 end
 if isa(imi,'int16'),
    im=double(im + 32767);
 end
 im=uint16(im);
end

