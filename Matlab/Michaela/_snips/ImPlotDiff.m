function [ fh] = ImPlotDiff( BaseImage,RegisteredInputImage,Title,ROI,doAdjust,TH )
%% show difference between base and deformed image
%  
%
global WorkDir ResDir

       if ~exist('Title','var') || isempty(Title)
          Title='ImPlotDiff';
       end  
       if ~exist('ROI','var') || isempty(ROI)
          [sy1,sx1]=size(BaseImage);
          [sy2,sx2]=size(RegisteredInputImage);
          sy=min(sy1, sy2);sx=min(sx1, sx2);
          ROI(1,1)=1;ROI(2,1)=sx;ROI(1,2)=1;ROI(2,2)=sy;
        end  
        if ~exist('doAdjust','var') || isempty(doAdjust)
          doAdjust=1;
        end
        if ~exist('TH','var') || isempty(TH)
          TH=0;
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
        %ImageShow(BIbw,'base',[],[],[],1);
        %ImageShow(RIbw,'reg',[],[],[],1);
        fh=ImageShow(DIFbw,Title,[],[],[],1);
        imwrite(DIFbw,strcat(ResDir,Title,'.png'));
        
end

