function [ImPOI,CSG reg ] = ImTraceBW(Im, BW,tol,maxDist,met)
%TRACEBW Summary of this function goes here
%   Detailed explanation goes here

  %% show the Image
  ImageShow(BW,'The BW  Regions to trace');
  f=ImageShow(Im,'on the Image to trace');
  hold on
  maxCell=0;
  sumCell=0;
  numCell=0;
  maxNodes=5000;
  maxEL=100;
  ysize=size(BW,1);
  sx=size(BW,2);
  sy=size(BW,1);
  V=zeros(1,maxNodes);
  GM=zeros(maxNodes,maxEL);
  
  POI=zeros(5000,2);%max 5000 points
  ImPOI=zeros(size(Im));
  npts=0;

  if  ~exist('tol','var') || isempty(tol)
     %max toleranz
     %tol=1; %more noders
     tol=3; % tol less => more noders
     %tol=5; 
     %tol=10; %less nodes
  end
  if  ~exist('maxDist','var') || isempty(maxDist)
     %max distance in pixel
     %maxDist=30; %more nodes
     maxDist=50; %md more => less nodes
     %maxDist=100; %less nodes
  end
   
  if  ~exist('met','var') || isempty(met)
     met=1; %white regions
  else
     met=2; %white lines
  end   
  if met==1
      % Regions
      % Find Points on the Boundaries of the region
      % BW=BW==0;% invert BW
      % BW  :: Structure=white Air=black
      % BW=>BWD :: Cell array with for each region all the points on the boundary
      BND=bwboundaries(BW,8);
  else
     % is line 
     %ImPlotPoints(BW,'Points',Ppos,-1);
     BW=bwmorph(BW,'thin');
     [Y X]=find(BW>0);
     b=0;BND=[];
     while size(Y,1)>4;
       y=Y(1);x=X(1);
       bnd=bwtraceboundary(BW,[y,x],'E');   %das geht nicht!!!!!!!
       for i=1:size(bnd,1);
         BW(bnd(i,1),bnd(i,2))=0;
       end
       ImageShow(BW,'Trace Regions',f);
       b=b+1;
       BND{b}=bnd;
       [Y X]=find(BW>0);
     end  
  end   
   
  BND2={};b=0;
  numE=numel(BND);% number of regions
  for j=1:numE
     Cell=BND{j};
     x=(Cell(:,2));y=(Cell(:,1));% x,y Points on the boundary
     % node reduction
     %pp=spline(x,[y(end) y y(1)]);
     [x2, y2]=reducem(x,y,tol); % reduce the points
     [x1,y1]=interpm(x2,y2,maxDist); % if dinstance is to big add points on staight lines
     x1=uint32(x1);y1=uint32(y1);
     Cell2=[y1 x1];
     % Check for boundarie elements
     l_x=0;l_y=0;l_inbd=0;
     sp=0;x3=[];y3=[];
     spx=0;spy=0;
     epx=0;epy=0;
     %check all points
     s=size(x1);
     for ii=1:s
       xi=x1(ii);yi=y1(ii);
       if xi==1 && yi==199
         disp( 'check');
       end
       % is it on the boundary of the image
       inbd=( xi==1 || xi==sx || yi==1 ||yi==sy);
       if inbd
          if  sp  %point bbontd not jet added
            epx=xi;epy=yi;
            mpx=(epx+spx)/2;
            mpy=(epy+spy)/2;
            if epx==1 || epx==sx,mpx=epx;end; 
            if spx==1 || spx==sx,mpx=spx;end; 
            if epy==1 || epy==sy,mpy=epy;end; 
            if spy==1 || spy==sy,mpy=spy;end; 
            x_=[epx mpx spx];
            y_=[epy mpy spy];
            [xx yy]=interpm(double(x_),double(y_),maxDist);
            s=size(xx,1);
            x3(bi+1:bi+s)=xx;
            y3(bi+1:bi+s)=yy;
            x3(bi+s+1)=x3(1);
            y3(bi+s+1)=y3(1);
            b=b+1;
            Cell3=[y3' x3'];
            BND2{b}=Cell3;
          end
          sp=false;
          bi=0;y3=[];x3=[];
       else
          if  l_inbd
            spx=l_x;spy=l_y;
            sp=true;
          end;
          if sp
            bi=bi+1;
            x3(bi)=xi;y3(bi)=yi;
          end;
       end
       %last inbound
       l_inbd=inbd;
       l_x=xi;l_y=yi;
     end
     BND{j}=Cell2;
  end
  
  % Plot Boundary Elements
  for bd=1:2
    if bd==1, BNDp=BND;else BNDp=BND2; end;  
    numE=numel(BNDp);
    for j=1:numE
       Cell=BNDp{j};
       x1=Cell(:,2);y1=Cell(:,1);
       x1=uint32(x1);y1=uint32(y1);
       n=numel(x1)-1;
       if n>0
         numCell=numCell+1;
         reg{numCell}=[y1 x1];
         % plot line
           if bd==1, coll='g';colp='ro'; else coll='b';colp='yx';end;
           plot(x1,y1,coll,'LineWidth',2);
         % plot point 
           plot(x1,y1,colp,'LineWidth',3);
           
         % Add to GM  
         % oben unten vertauschen
         % y1=ysize-y1;
         ob=[2 n x1(1:end-1)' y1(1:end-1)' V]';
         GM(:,numCell)=ob(1:maxNodes);
         sumCell=sumCell+n;
         if n>maxCell
           maxCell=n;
         end 
         
         % Add to POI
         s=size(x1,1);
         for p=1:s
           x=find(POI(:,1)==x1(p)& POI(:,2)==y1(p),1);
           ImPOI(y1(p),x1(p))=1;
           if isempty(x);
             npts=npts+1;
             POI(npts,1:2)=[x1(p),y1(p)];
           end
         end 
          
       end
    end
  end   
  hold off
  
  n=2+maxCell*2;
  CSG=GM(1:n,1:numCell);
  POI=POI(1:npts,:);
  
  
end
