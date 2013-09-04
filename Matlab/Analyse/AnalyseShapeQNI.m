function [ w1,w2,fig,Cor] = AnalyseShapeQNI( BW,fig,basline)
%ANALYSESHAPE Summary of this function goes here
%   Detailed explanation goes here
      if ~exist('fig','var') || isempty(fig)
         %RGB=ImageSetCol(Ix,IX,[0.2*255,0,0],0,BW)
         fig=ImageShow(double(BW)+.5);
      else     
         figure(fig);
         %hold on
         %image(double(BW));
         %axis image;
         %caxis([0 1]);
         %colorbar;
         %colormap('gray');
         %axis off;
         %set(fig,'AlphaData',double(BW)*.5);
         %hold off
      end
      
      Px=[];Py=[];w=[];xmin=[];xmax=[];
      [Reg,S]=FindShape2(BW,fig);
      if ~isempty(Reg)
        B=[Reg(1).BoundingBox];
        %% Find curve
        [ymin,ymax,xmin,xmax,V] = FindCurve(S,fig);
        % Fit the curves 
        [w1,w2]=FitCurve(V,fig);
      end
     Cor.y0=(ymax+ymin)/2;
     Cor.x0=(xmax+xmin)/2;
     Cor.ymin=ymin;
     Cor.ymax=ymax;
     Cor.xmin=xmin;
     Cor.xmax=xmax;
     
 
end
