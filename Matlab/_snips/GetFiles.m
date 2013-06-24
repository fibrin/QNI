function [Flist,Anz ] = GetFiles( imPath,defFn)

% Reads in the filelist in Path match the defFn pattern
% Flist record nameFilenamechar array
%              dateModification date timestampchar array
%              bytesNumber of bytes allocated to the filedouble
%              isdir1 if name is a directory; 0 if notlogical
%              datenumModification date as serial date numberchar array

onlyDir=0;
onlyPic=0;
if nargin<1 || isempty(imPath)
  imPath=char(System.Environment.CurrentDirectory);
end
if ~exist('defFn','var') || isempty(defFn)
  defFn='*.*';
end
if strcmpi(defFn,'DIR')
  onlyDir=1;
  defFn='';
end
if strcmpi(defFn,'PIC')
  onlyPic=1;
  defFn='*.*';
end


l=length(imPath);
if ~(strcmp(imPath(l:l),'\'))
  imPath=strcat(imPath,'\');
end
fn=strcat(imPath,defFn);
iFn=dir(fn);
iAnz=size(iFn,1);
iSize=[];
iType=[];
f=0;
list=[];
for i=1:iAnz
 [pathstr, name, ext] = fileparts(iFn(i).name);
 if iFn(i).isdir 
   n=iFn(i).name;
   if ~(strcmp(n,'.') || strcmp(n,'..')) && onlyDir
     f=f+1;list(f)=i;
   end
 else
   if onlyPic 
     ok=regexpi('.tif.png.jpg.',ext,'once');
     if ok
       f=f+1;list(f)=i;
     end  
   elseif onlyDir  
     %do nothing
   else
     f=f+1;list(f)=i;
   end  
 end  
 iFn(i).fullname=strcat(imPath,iFn(i).name);
 iFn(i).filename=name;
end
Flist=iFn(list);
Anz=length(Flist);
  
end