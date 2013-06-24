function fno=searchPath(in,pattern,startpattern)
if nargin<1 
  in='C:\_3D\_MATLAB\4_ImReg\images';
end
if nargin<2
  pattern='*';
end 
if nargin<3
  startpattern='';
end  
PathPat=pattern;
if length(in)>0
  PathPat=strcat(in,'\',pattern);
end  
f=dir(PathPat);
if length(f)>0
  fn=f(1).name;
  fno=fn;
  if length(in)>0
    fno=strcat(in,'\',fn);
  end  
else 
  fno=[];
  PathPat=strcat(in,'\',startpattern,'*');
  f=dir(PathPat);
  cnt=length(f); 
  for i=1:cnt
    isdir=f(i).isdir;
    fn=f(i).name;
    if strcmp(fn,'.') || strcmp(fn,'..')
      isdir=0;
    end  
    if isdir
      path =strcat(in,'\',fn);
      fnr=searchPath(path,pattern,startpattern);
      disp(strcat(path,' :: ',fno));
      if length(fnr)>0 && length(fno)==0 
        fno=fnr;
        return;
      end 
    end  
  end
end
  
end