function [ mcT,mcX,mcY,mcM,Imout,Imout2 ] = AnalyseImageQNI(DIM0,MIM0,XIM0,ROI,mode)
  % DIM0 is the image of the sample in dry state (reference image)
  % MIM0 is the image of the wet sample
  % XIM0 is the Xray image to build a mask for early and late wood if empty => no mask   
  % ROI  crop area on the original picture to be analysed
  % mode for 'T'=total no mask 'EW'=eraly wood or 'LW'=late wood
  % mcT the total moister content 
  % mcX profile of moister content along X mean value of vertical pixels
  % mcY provile of moister content along Y mean value of horizontal pixels
  % mcM matix of moister content
    
      if (nargin < 3) || isempty(XIM0)
         XIM0=DIM0;
         XIM0(:,:)=1; % no maske count every pixel
      end
      % eraly latE   T  just do all
      if (nargin < 4) || isempty(mode)
        mode='T';
      end
      [sy,sx]=size(DIM0);
       %if no ROI analyse whole pic
      if (nargin < 5) || isempty(ROI)
        ROI=[1,1,size(DIM0,2),size(DIM0,1)];
      end

      %RGB picture 3 colors 3 layers
      x1=ROI(1);y1=ROI(3);x2=ROI(2);y2=ROI(4);
      if x1<1 ,x1=1;end;
      if x2>sx ,x2=sx;end;
      if y1<1 ,y1=1;end;
      if y2>sy ,y2=sy;end;
      
      %Mask the croped area
      Imout(:,:,1)=MIM0;   % red   Mass
      Imout(:,:,2)=XIM0;  % green X-ray
      Imout(:,:,3)=0;     % blue  mask to count
      Imout(y1:y2,x1:x2,3)=1;
      %crop Mass and wdir pic
      MIM=MIM0(y1:y2,x1:x2);   %mass crop
      XIM=XIM0(y1:y2,x1:x2);   %xray crop
      DIM=DIM0(y1:y2,x1:x2);   %dry  crop        

      %define the Mask for early and late wood
      if strcmp(mode,'T')
         level=0;% no mask all 1
      else
        level=graythresh(XIM);
      end
      BW = im2bw(XIM,level);
      if strcmp(mode,'LW') %LW=black
        BW=~BW;
      end
      
      %rgb Image croped
      f=65535;
      Imout2(:,:,1)=MIM;    %red
      Imout2(:,:,2)=XIM;    %green
      Imout2(:,:,3)=BW;     %blue

      %calculate MC Total,Vektor, Pixel
      [mcT,mcX,mcY,mcM]=M_C(DIM,MIM,BW);
  return
      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




  function [ mcT,mcX,mcY,mcM ] = M_C( dry,wet,mask )
  % MC moister contents 
  % where inupt 
  % dry is the image of the sample in dry state (reference image)
  % wet ist the image of the wet sample
  % where mask is 1 pixels will be taken in account 
  % else they are ignored to  build the mean value
  % output
  % mcT the total moister content 
  % mcX profile of moister content along X mean value of vertical pixels
  % mcY profile of moister content along Y mean value of horizontal pixels
  % mcM matix of moister content
  %
  % Parameters
    if (nargin < 3) || isempty(mask)
       mask=wet;
       mask(:,:)=1; % no maske count every pixel
    end
    [sy,sx]=size(dry);
    
    mcX(1:sx)=0;
    mcY(1:sy)=0;
    mcM=zeros(sy,sx);
    for y=1:sy
      for x=1:sx
        if mask(y,x)
          d=double(dry(y,x));
          w=double(wet(y,x));
          m=w-d;
          mcM(y,x)=m;
        end  
      end
    end
    d=sum(sum(dry));
    w=sum(sum(wet));
    m=w-d;
    mcT=sum(sum(mcM(mask)));   % mean
    for i=1:sx,mcX(i)=sum(mcM(mask(:,i),i));end; % profile X
    for i=1:sy,mcY(i)=sum(mcM(i,mask(i,:)));end; % profile Y
  end

      
      
      
end
     
        
