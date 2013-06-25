function [  ] = ImWriteAvi( fn,Mov,MovT)
%IMWRITEAVI Summary of this function goes here
%   Detailed explanation goes here
global ResDir



if ~exist('fn','var') 
  fn='movie.avi';
end  

fn=strcat(ResDir,fn);

  if ~exist('MovT','var') || isempty(MovT);
     MovT=5;
  end 
  %make all the same size
  hm=9999;wm=9999;
  MovFnr=length(Mov);
  for i=1:MovFnr
    [h,w]=size(Mov(i).cdata(:,:,1));
    hm=min(h,hm);
    wm=min(w,wm);
  end
  for i=1:MovFnr
    Mov(i).cdata=Mov(i).cdata(1:hm,1:wm,:);
  end
  
  %frame rate
  fps=int16(MovFnr/MovT)+1;
  if fps>25
    %fps=25;
  end
  if fps<1
    fps=1;
  end  
  try 
    movie2avi(Mov,fn,'fps',fps,'Compression', 'none'); 
  catch err
    msgbox(err.identifier);
  end
  
  
end

