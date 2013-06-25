function [ DIFbw ] = compareBaseInputBW( BaseImage,RegisteredInputImage,ROI,doAdjust,TH )
%% Compare the images by substraction 
%  BaseImage            : original image 
%  RegisteredInputImage : the registered  (transformed input image)
%  ROI: cut out a region of intrest
%  doAdjust: 0,1 do imadjust befor Subtraction 1=default
%  TH: threshold for binarisation  [] => max(otsu,0.35)
%  Difbw : (Base-Reg+1)/2 => adjusted to fit 0..1
%    
%%
        if nargin<3 || isempty(ROI)
          [sy1,sx1]=size(BaseImage);
          [sy2,sx2]=size(RegisteredInputImage);
          sy=min(sy1, sy2);sx=min(sx1, sx2);
          ROI(1,1)=1;ROI(2,1)=sx;ROI(1,2)=1;ROI(2,2)=sy;
        else
          
        end  
        if nargin<4 || isempty(doAdjust)
          doAdjust=1;
        end  
        
        BI=BaseImage(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
        RI=RegisteredInputImage(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
        if doAdjust
          BI=imadjust(BI,[0 1]);
          RI=imadjust(RI,[0 1]);
        end  
        
        BW=0;
        if BW
          if nargin<5 || isempty(TH)
            THb=graythresh(BI);
            if THb <0.35,THb=0.35;end;
            THr=graythresh(RI);
            if THr <0.35,THr=0.35;end;
          end  
          BIbw=(BI>THb)*1.0;
          RIbw=(RI>THr)*1.0;
        else
          BIbw=BI;
          RIbw=RI;
        end  
        DIFbw=imsubtract(BIbw,RIbw);
        DIFbw=(DIFbw+1)/2;
        if doAdjust,DIFbw=ImageAdjust(DIFbw,0);end;   
        ImageShow(BIbw,'base',[],[],[],1);
        ImageShow(RIbw,'reg',[],[],[],1);
        ImageShow(DIFbw,'Difbw',[],[],[],1);
 
end

