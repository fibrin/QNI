function [ H,L,xmin,xmax,V] = FindTangent(B,fig,minmax)
%FINDTANGENT Summary of this function goes here
%   Detailed explanation goes here

if ~exist('fig','var') || isempty(fig)
  fig=figure;
end
figure(fig);
hold on
if ~exist('minmax','var') || isempty(minmax)
   minmax=1;
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
      if minmax==0
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
    H=ymax-ymin;
    Lx1=xmin;
    Lx2=xmax;
    L=(xmax+xmin)/2;
    V=vk;
else
    H=0;
    Lx1=0;
    Lx2=0;
    L=0;
    V=0;
end
end
