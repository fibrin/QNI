function [ RGB ] = compareBaseInput( BaseImage,RegisteredInputImage,ROI,doAdjust )
%% Compare the images by substraction 
%  BaseImage            : original image 
%  RegisteredInputImage : the registered  (transformed input image)
%  ROI: cut out a region of intrest
%  doAdjust: 0,1 do imadjust befor Subtraction 1=default
%  RGB : Output in Colors
%   Red  = Base-Reg <0= 0
%   Green= Reg-Base <0 =0
%   Blue = BaseImage
%%

        [sy,sx]=size(BaseImage);
        if nargin<3 || isempty(ROI)
          ROI(1,1)=1;ROI(2,1)=sx;ROI(1,2)=1;ROI(2,2)=sy;
        end  
        if nargin<4 || isempty(doAdjust)
          doAdjust=1;
        end  
        BI=BaseImage(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
        RI=RegisteredInputImage(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
        if doAdjust
          BI=imadjust(BI);
          RI=imadjust(RI);
        end  
        s1=imsubtract(BI,RI);
        s1(s1<0)=0;
        %s1=ImageAdjust(s1);
        s2=imsubtract(RI,BI);
        s2(s2<0)=0; 
        %s2=ImageAdjust(s2);

        %RGB(:,:,2)=BaseImage;
        RGB(:,:,1)=s1;'R'
        RGB(:,:,2)=s2;'G'
        RGB(:,:,3)=BI;'B'
        ImageShow(RGB,'base image vs registered input one');
 
end

