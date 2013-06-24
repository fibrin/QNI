function [ ROI ] = GetROI(Im, WorkDir,Fn,checkROI )
  % 
  % GetROI Summary of this function goes here
  % Detailed explanation goes here
  % read ROI and POI
  %

  %% Parameter 
  if nargin<3 
   Fn= 'Analyse.xls';
  end
  if nargin<4 
   checkROI=true;
  end

  
  %% read ROI from Exel
  fnxls=strcat(WorkDir,'\',Fn);
  tabn='ROI';

  %% ROI
  Row=5;  
  Ra=xlsColRow(1,Row);
  xlswrite(fnxls,{'ROI'},tabn,Ra);
  Ra=xlsColRow(1,Row+1,2,2);
  ROI=xlsread(fnxls,tabn,Ra);

  if isempty(ROI) || ROI(2,2)==0 || ROI(2,1)==0
    rd=20;
    [sy,sx]=size(Im);
    xmin=1+rd;xmax=sx-rd;
    ymin=1+rd;ymax=sy-rd;
    ROI(1,:)=[xmin,ymin];%topleft
    ROI(2,:)=[xmax,ymax];%butomright
    checkROI=true;
  end
  
  %% check ROI if needed
  wrROI=0;
  if checkROI
    %getROI
    pos=[ROI(1,:)  ROI(2,:)-ROI(1,:)];
    ImageShow(Im,'ROI',[],1,[],1); % show
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

  %% write ROI
  %ROI=uint16(ROI);
  if wrROI
    Ra=xlsColRow(1,Row+1);
    xlswrite(fnxls,ROI,tabn,Ra);
  end  
  
end

