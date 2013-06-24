function [ fig ] = ImPlotROI( Iin,title,ROIin )
%IMPLOTROI Summary of this function goes here
%   Detailed explanation goes here

   fig=ImageShow(Iin,title,[], [],[], 1); 
   
   %*******************************
   %Plot Boundingboxes in refImage 
     hold on;
     %[sy,sx]=size(I0);
     % Loop over all ROIS
     startR=1;stopR=size(ROIin,1);
     for r=startR: stopR
     x1=ROIin(r,1);y1=ROIin(r,2);x2=ROIin(r,3);y2=ROIin(r,4);
     B(1)=x1;
        B(2)=y1;
        B(3)=x2-x1;
        B(4)=y2-y1;
        xc=x1;yc=y1;
        text(xc+15,yc+15,num2str(r),'FontSize',12,'color','red');
        rectangle('Position',B,'EdgeColor','y');
     end  
     hold off
 end

