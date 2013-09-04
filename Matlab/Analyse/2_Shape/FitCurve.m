function [ A1,A2 ] = FitCurv(V,fig )
%FITCURV Summary of this function goes here
% Detailed explanation goes here
%  s = fitoptions('Method','NonlinearLeastSquares',...
%               'Lower',[0,0],...
%               'Upper',[Inf,max(cdate)],...
%               'Startpoint',[0 0]);

  
  y=V(:,1);x=V(:,2);
  xmin=min(x);
  xmax=max(x);
  met='poly2';
  switch met
    case 'poly2'
      s = fitoptions('Method','NonlinearLeastSquares');
      f = fittype('a + b*x +c*x^2','options',s);
      [c1,gof] = fit(x,y,f);
      s1=c1.b+c1.c*2*xmin;
      s2=c1.b+c1.c*2*xmax;
      x0=xmin;
      ymin=c1.a+c1.b*x0+c1.c*x0^2;
      x0=xmax;
      ymax=c1.a+c1.b*x0+c1.c*x0^2;
    case 'poly3'
      s = fitoptions('Method','NonlinearLeastSquares');
      f = fittype('a + b*x +c*x^2+d*x^3','options',s);
      [c1,gof] = fit(x,y,f);
      s1=c1.b+c1.c*2*xmin+c1.d*3*xmin^2;
      s2=c1.b+c1.c*2*xmax+c1.d*3*xmax^2;
      x0=xmin;
      ymin=c1.a+c1.b*x0+c1.c*x0^2+c1.d*x0^3;
      x0=xmax;
      ymax=c1.a+c1.b*x0+c1.c*x0^2+c1.d*x0^3;
    case 'poly4'
      s = fitoptions('Method','NonlinearLeastSquares');
      f = fittype('a + b*x +c*x^2+d*x^3+e*x^4','options',s);
      [c1,gof] = fit(x,y,f);
      s1=c1.b+c1.c*2*xmin+c1.d*3*xmin^2+c1.e*4*xmin^3;
      s2=c1.b+c1.c*2*xmax+c1.d*3*xmax^2+c1.e*4*xmax^3;
      x0=xmin;
      ymin=c1.a+c1.b*x0+c1.c*x0^2+c1.d*x0^3+c1.e*x0^4;
      x0=xmax;
      ymax=c1.a+c1.b*x0+c1.c*x0^2+c1.d*x0^3+c1.e*x0^4;
  end
  hold on
  p=plot(c1);
  set(p,'Color','red','LineWidth',2);
  
  % tangent in  xmin
  lx=xmin-10:1:xmax;
  a=ymin-xmin*s1;
  ly=a+s1*lx;
  plot(lx,ly,'b','LineWidth',2);
  plot(xmin,ymin,'xg');
  
  % tangent in xmax
  lx=xmin:1:xmax+10;
  a=ymax-xmax*s2;
  ly=a+s2*lx;
  plot(lx,ly,'b','LineWidth',2);
  plot(xmax,ymax,'xg');

  %plot(Px,Py,'xg','LineWidth',2);

  %pi=3.1415926;
  St=(abs(s1)+abs(s2))/2;
 
  %angle in xmin
  w=atan(s1);
  A1=w;
  w1=num2str(w);
  w2=num2str(w*180/pi);
  w3=strcat('w=',w1,' ;',w2);
  text(50,200,w3,'HorizontalAlignment','left','Color','blue');

  %angle in xmax
  w=-atan(s2);
  A2=w;
  w1=num2str(w);
  w2=num2str(w*180/pi);
  w3=strcat('w=',w1,' ;',w2);
  text(300,200,w3,'HorizontalAlignment','left','Color','blue');

  
  hold off
  
end

