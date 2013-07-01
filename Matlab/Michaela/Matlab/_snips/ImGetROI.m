function [ ROI,wrROI ] = ImGetROI( Im ,ROIin )
%IMGETROI Summary of this function goes here
%   Detailed explanation goes here
    wrROI=0;
    ROI=ROIin;
    pos=[ROIin(1,:)  ROIin(2,:)-ROIin(1,:)];
    ImageShow(Im,'get ROI',[],1,[],1); % show
    hr=imrect(gca,pos);
    pos=wait(hr);
    close; 
    if ~isempty(pos) 
      ROI(1,:)=pos(1:2);
      ROI(2,1)=pos(3)+pos(1);
      ROI(2,2)=pos(4)+pos(2);
      wrROI=1;
    end

end

