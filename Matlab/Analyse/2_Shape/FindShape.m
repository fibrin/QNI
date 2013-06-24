function [ Reg ] = FindShape( Im,Th,Sig)
    %FINDEDGESCANNY Summary of this function goes here
    %%%%%%%%%%%%% The main.m file  %%%%%%%%%%%%%%%
    % The algorithm parameters:
    % 1. Parameters of edge detecting filters:
    %    Y-axis direction filter:
         Ny1=20;Sigmay1=Sig;Ny2=20;Sigmay2=Sig;Theta2=0;
    % 2. The thresholding parameter alfa:
         alfa=Th;

    Imageshow(Im,'Image');
    x=size(Im,2);
    %x=uint16(x/2);
    w=Im(:,1:x);

    % Y-axis direction edge detection
    filtery=d2dgauss(Ny1,Sigmay1,Ny2,Sigmay2,Theta2);
    Iy=conv2(w,filtery,'same'); 
    ImageShow(Iy,'Iy',[],1);
    NVI=sqrt(Iy.*Iy);
    ImageShow(NVI,'Norm of Gradient',[],1);
    %h=fspecial('disk',10);
    %NVI=imfilter(NVI,h,'replicate');
    [sy,sx]=size(NVI);
    NVI=NVI(21:sy-20,:);
    ImageShow(NVI,'Gradient Mean',[],1);
    
    % Thresholding
    I_max=max(max(NVI));
    I_min=min(min(NVI));
    NVI=(NVI-I_min)/(I_max-I_min);
    I_max=max(max(NVI));
    I_min=min(min(NVI));
    level=alfa*(I_max-I_min)+I_min;
    % Level to Imax
    BW=NVI>level;
    ImageShow(BW,'BW after Thresh');
    % close gabs
    se=strel('disk',7);
    BW=imclose(BW,se);
    ImageShow(BW,'BW closed');
    BW=bwareaopen(BW,2000);
    ImageShow(BW,'BW >2000');

    
    
    Reg=[]; 
    L1=bwlabel(BW);
    R1=regionprops(L1,{'Centroid','Area','Eccentricity','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation'});
    %Sortieren nach Grösse
    %[sVal sInd] = sort([R1.Area]);
    % extrahieren der Fläche aus den Regionprops
    j=0;
    idx=[];
    hold on
    for i=1:length(R1)
      plot(R1(i).Centroid(1),R1(i).Centroid(2),'b*');
      F=R1(i).BoundingBox(3)/R1(i).BoundingBox(4);
      a=R1(i).Area;
      % F<1: h>b ,  F>1: b>h F>>1 horizontaler Strich
      if F<5 && 500<a<5000
         j=j+1;
         idx(j)=i;
      end   
    end
    %GössteRegion
    %[idx] = find(max(a));
    %R2=R1(idx);
    R2=R1(idx);
    if ~isempty(R2)
      %Umformen Struct to Matrix
      %Re=[R2.*] not allowd;
      C=[R2.Centroid];%=>1x18
      co=size(C,1);ro=size(C,2);
      co=co*2;ro=ro/2; M=reshape(C,co,ro);
      C1=M(1,:);  C2=M(2,:);%=>1x9
      %Reg=[C1;C2;R2.Area;R2.MajorAxisLength;R2.MinorAxisLength]; %in Matrix
     %Ploten  
      num=size(R2,1);
      for i=1:num
        j=i;
        plot(R2(j).Centroid(1),R2(j).Centroid(2),'r*');
        %plot(Reg(1,j),Reg(2,j),'go');
      end
      hold off;
      if length(idx)~=1
         disp('more then one region');
         %pause;
         R2=[];
      end
    end
    Reg=R2;
end
%%%%%%%%%%%%%% End of the main.m file %%%%%%%%%%%%%%%


%%%%%%% The functions used in the main.m file %%%%%%%
% Function "d2dgauss.m":
% This function returns a 2D edge detector (first order derivative
% of 2D Gaussian function) with size n1*n2; theta is the angle that
% the detector rotated counter clockwise; and sigma1 and sigma2 are the
% standard deviation of the gaussian functions.
function h = d2dgauss(n1,sigma1,n2,sigma2,theta)
    r=[cos(theta) -sin(theta);
       sin(theta)  cos(theta)];
    for i = 1 : n2 
        for j = 1 : n1
            u = r * [j-(n1+1)/2 i-(n2+1)/2]';
            h(i,j) = gauss(u(1),sigma1)*dgauss(u(2),sigma2);
        end
    end
    h = h / sqrt(sum(sum(abs(h).*abs(h))));
end

% Function "gauss.m":
function y = gauss(x,std)
  y = exp(-x^2/(2*std^2)) / (std*sqrt(2*pi));
end

% Function "dgauss.m"(first order derivative of gauss function):
function y = dgauss(x,std)
  y = -x * gauss(x,std) / std^2;
end

%%%%%%%%%%%%%% end of the functions %%%%%%%%%%%%%
