function [iFn,iAnz ] = GetIm( imPath,defFn)
% Reads in the filelist in Path match the defFn pattern
% iFn  record  nameFilenamechar array
%              dateModification date timestampchar array
%              bytesNumber of bytes allocated to the filedouble
%              isdir1 if name is a directory; 0 if notlogical
%              datenumModification date as serial date numberchar array
fn=strcat(imPath,'\',defFn);
iFn=dir(fn);
iAnz=size(iFn,1);
iSize=[];
iType=[];
for i=1:iAnz
 iFn(i).fullname=strcat(imPath,'\',iFn(i).name);
 [pathstr, name, ext] = fileparts(iFn(i).fullname);
 iFn(i).filename=name;
end  
end