function [ Im_out ] = ImageCutROI( Im_in,ROI,bd )

[sy,sx]=size(Im_in);


if ~exist('ROI','var') || isempty(ROI),ROI=[1,1,sy,sx];end;
if ~exist('bd','var') || isempty(bd),bd=0;end;
    
[sy,sx]=size(ROI);

if sx==4
  % ROI=left,top,right,bottom
  Im_out=Im_in(ROI(1,2)+bd:ROI(1,4)-bd,ROI(1,1)+bd:ROI(1,3)-bd);
else
  % ROI=left,top
  %     right,bottom
  Im_out=Im_in(ROI(1,2)+bd:ROI(2,2)-bd,ROI(1,1)+bd:ROI(2,1)-bd);
end  

end

