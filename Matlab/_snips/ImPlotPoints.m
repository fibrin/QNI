  
function fig= ImPlotPoints(Iin,title,PointPosIn,BdWidth)
%%
%fig= Implotpoints(Iin,title,PointPosIn,BdWidth)

global ResDir

   if nargin<4 ||  BdWidth==0
     BdWidth=0;
   end  
   bd=BdWidth;
   if bd>0
     I0=ImBorderAdd(Iin,bd,0);
     PointPos=PointPosIn+bd;
   else
     I0=Iin;
     PointPos=PointPosIn;
   end  
   
   fig=ImageShow(I0,title,[], [],[], 1); 
   
   %*******************************
   %Plot Boundingboxes in refImage 
       hold on;
       [sy,sx]=size(I0);
       % Loop over all Points
       startPoint=1;stopPoint=size(PointPos,1);
       for p=startPoint: stopPoint
          %the Point to Track
          xc=PointPos(p,1);
          yc=PointPos(p,2);
          plot(xc,yc,'g+');
          if bd>=0 
            isUsed=1;%isUsed=posTab(p,9);
            if isUsed
              text(xc+5,yc+10,num2str(p),'FontSize',8,'color','green');
              if bd>0 
                x1=xc-bd;y1=yc-bd;
                x2=xc+bd;y2=yc+bd;
                if x1<1 , x1=1;end;
                if y1<1 , y1=1;end;
                if x2>sx , x2=sx;end;
                if y2>sy , y2=sy;end;
                B(1)=x1;
                B(2)=y1;
                B(3)=x2-x1;
                B(4)=y2-y1;
                rectangle('Position',B,'EdgeColor','y');
              end
            else  
              % red skipt
              plot(x1,y1,'r*');
              sr=strcat('\color{red}\fontsize{10}',num2str(p));
              text('Position',[x1-5,y1+0],'String',sr);
            end
          end  
       end
       hold off;
end       
