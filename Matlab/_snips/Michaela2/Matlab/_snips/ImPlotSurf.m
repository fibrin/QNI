function [ f] = ImPlotSurf( x,y,z,dgr,Im)
%IMPLOTSURF Summary of this function goes here
%   Detailed explanation goes here
     if nargin<2 || isempty(y) ,plotfield=1; else plotfield=0; end
     if plotfield
        dgr=1;
        T=x;
        if size(T,3)==2
          Ux=T(:,:,1); %dx Mat
          Uy=T(:,:,2); %dy Mat
          Z=sqrt(Ux.^2+Uy.^2);
        else
          Z=T(:,:,1);
        end  
        Z=ImBorderSet(Z,20,0);
        Z0=ImageAdjust(Z,0,[],0);
        %Z=grs2rgb(Z,hot(255),Im);
        Z1=grs2rgb(Z0,jet(255),Im);
        Z2=grs2rgb(Z0,gray(255));
        f=ImageShow(Z1);
        ImageShow(Z2);
        %imwrite(Z2,strcat(WorkDir,Title,'.png'));
     elseif plotfield
        dgr=1;
        T=x;
        Ux=T(:,:,1); %dx Mat
        Uy=T(:,:,2); %dy Mat
        Z=sqrt(Ux.^2+Uy.^2);
        Z=ImBorderSet(Z,20,0);
        f=figure;
        s=surf(Z);
        set(s,'EdgeColor','none');
     else  
        if nargin<4 || isempty(dgr)
           dgr=0;
        end
        if nargin<5 || isempty(Im)
          sy=max(y)*1.1;
          sx=max(x)*1.1;
        else
          [sy,sx]=size(Im);
        end
        if dgr==0
          [X,Y] = meshgrid(x,y);
        else
          [X,Y] = meshgrid(1:dgr:sx,1:dgr:sy);
        end
        Z = griddata(x,y,z, X, Y);
        f= figure;
        s=surf(X,Y,Z);
     end

end

