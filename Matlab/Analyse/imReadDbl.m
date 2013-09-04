function [ im ] = imReadDbl( ImPathFile,Filename)
%IMREADFITS Summary of this function goes here
%   Detailed explanation goes here
if ~exist('Filename','var')
 imi=imread(ImPathFile);
 im=double(imi);
else  
  im=[];
  [Flist,anz]=GetFiles(ImPathFile,Filename);
  if anz>0
   imfn=Flist(1).fullname;
   imi=imread(imfn);
   im=double(imi);
  end
end  
end

