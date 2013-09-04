function [ ymin,ymax,xmin,xmax,V] = FindCurv(B,fig,maxmin)
% input
%   B boundary vektor of a shape defineed bei B(y..,x..)
%   figur to plot on
%   maxmin 0:fit to upper part   1:fit to lower part 
% output 
%   ymin top the shape
%   ymax bottom of the shape
%   xmin left
%   xmax right
%   V output vector to be fit lower or upper part of a shape

if ~exist('fig','var') || isempty(fig)
  fig=figure;
end
figure(fig);
hold on
if ~exist('maxmin','var') || isempty(maxmin)
   maxmin=1;
end   


%{
ymax=0;
anz=size(B,1);
for i=1:anz
  v=B{i};
  vx=v(v(:,2)==sm);
  if isempty(vx)
    if anz==1
      ym=max(v(:,1));
    else
      ym=0;
    end
  else
    ym=max(vx(:,1));
  end;
  if ym> ymax , ymax=ym;i0=i;end;
end
%}

v=B;
cnt=size(B,1);
if cnt>5
    v(:,1)=v(:,1)-0; % Y zwei pixwl nach oben verschieben passt besser aufs auge
    xmin=min(v(:,2))+2;
    xmax=max(v(:,2))-2;
    anz=xmax-xmin;
    vk=zeros(anz,2);
    for i=1:anz+1
      x=xmin+i-1;
      vk(i,2)=x;
      xi= v(:,2)==x;
      if maxmin==0
         vk(i,1)=min(v(xi,1));
      else
         vk(i,1)=max(v(xi,1));
      end   
    end
    ymin=min(vk(:,1));
    ymax=max(vk(:,1));
    y1=vk(1,1);
    y2=vk(anz+1,1);
    plot(vk(:,2),vk(:,1),'g','LineWidth',1);
    plot(xmin,y1,'bx');
    plot(xmax,y2,'bx');
    hold off
    H=(ymax-ymin);
    L=(xmax-xmin);
    V=vk;
else
    ymin=0;
    ymax=0;
    xmin=0;
    xmax=0;
    V=[];
end
end

