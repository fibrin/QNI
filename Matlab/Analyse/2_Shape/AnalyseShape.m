function [ w1,w2,fig] = AnalyseShape( BW,fig)
%ANALYSESHAPE Summary of this function goes here
%   Detailed explanation goes here
      if ~exist('fig','var') || isempty(fig)
         %RGB=ImageSetCol(Ix,IX,[0.2*255,0,0],0,BW)
         fig=ImageShow(BW);
         
      end
      
      test=1;
      Px=[];Py=[];w=[];xmin=[];xmax=[];
      x0=251;
      y0=1;
      [Reg,S]=FindShape2(BW,fig);
      if ~isempty(Reg)
        B=[Reg(1).BoundingBox];
        %% Crop
        % bd=30;
        % x1=x0+B(1)-bd;y1=y0+B(2)-4*bd;x2=x1+B(3)+2*bd;y2=y1+B(4)+6*bd;
        % Ix=I0(y1:y2,x1:x2);
        % if wr ,imwrite(Ix,fn);end;
        %% Find curve
        [H,L,xmin,xmax,V]=FindTangent(S,fig);
        % Fit the curves 
        [w1,w2]=FitCurv(V,fig);
      end
     
 
end
