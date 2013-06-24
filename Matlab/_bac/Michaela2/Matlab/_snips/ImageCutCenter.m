function [ cut ] = ImageCutCenter( Im,cx,cy,bd,docheck)
%ImageCutCenter( Im,cx,cy,bd,docheck)
%   Detailed explanation goes here
  if nargin<5 
    docheck=0;
  end  
  cx=round(cx);cy=round(cy);
  x1=cx-bd;x2=cx+bd;
  y1=cy-bd;y2=cy+bd;
  s=2*bd+1;
  cut=zeros(s,s);
  cy1=1;cy2=s;
  cx1=1;cx2=s;
  if docheck
    [sy sx]=size(Im);
    if x1<1,cx1=1-x1+1;x1=1;end;
    if x2>sx,cx2=s-x2+sx;x2=sx;end;
    if y1<1,cy1=1-y1+1;y1=1;end;
    if y2>sy,cy2=s-y2+sy;y2=sy;end;
  end  
  cut(cy1:cy2,cx1:cx2)=Im(y1:y2,x1:x2);
  h=ImageShow(Im,'cut');
  if ~isempty(h),rectangle('Position',[x1,y1,x2-x1+1,y2-y1+1],'EdgeColor','r');end;
end

       
       % bx1=1;by1=1;bz1=1;
       % [by2 bx2]=size(pic0);
       % if px1<1 , bx1=bx1-px1+1;px1=1;end;
       % if py1<1 , by1=by1-py1+1;py1=1;end;
       % if px2>sx , bx2=bx2-px2+sx; px2=sx;end;
       % if py2>sy , by2=by2-py2+sy;py2=sy;end;
       % if 0
       %  if px2<5,bx2=5;px2=5;end;
       %  if py2<5,by2=5;py2=5;end;
       %  if px1>sx-5 , px1=sx-5;end;
       %  if py1>sy-5 , py1=sy-5;end;
       % end
 

