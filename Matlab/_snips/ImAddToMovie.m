function [ mov ] = ImAddToMovie( mov,fh )
%IMADDTOMOVIE Summary of this function goes here
%   Detailed explanation goes here

% Adjust size of this window to include the whole figure window (if you require the axes, title and axis labels in the movie):
    winsize = get(fh,'Position');
    winsize(1:2) = [0 0];
    winsize(3)=winsize(3)-1;
    winsize(4)=winsize(4)-1;
    

  if isempty(mov)
     MovFnr=0;
     clear 'mov';
  else
    MovFnr=length(mov);
    [h,w]=size(mov(1).cdata(:,:,1));
    winsize(3)=w;
    winsize(4)=h;
  
  end
  
  MovFnr=MovFnr+1;
  fr=getframe(fh,winsize);
  
  mov(MovFnr)=fr;
  %

  

end

