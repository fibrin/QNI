%%------------------------------------------------------------------------------------
% Analysing QNI dataset stored in the SampleDir
% 
% 
%-------------------------------------------------------------------------------------

function [ ] = AnalyseQNI(SampleDir,FirstTime,QniFrameRate,option)
   if nargin<1, A0_main;return;end; % if called directly 
   global ImShowFlag
 
%    option.test=true;
     if option.test
      option.testpics=[15,30,50];
      ImShowFlag=1;
    end  

     %% set Path for input
     QNIDir=strcat(SampleDir,'\QNI\QNI_r');
     ResDir=option.ResDir;

     %% analyse QNI files calcualted from neutra Images
     fn=strcat(ResDir, '\Qni.mat');
     if  ~exist(fn,'file') ||option.QniGetDiferentialImage || option.AnalyseAll
        disp('anayse QNI images');
        FristTime=1/QniFrameRate/2+.5; % time for the first pic
        [QniDry,QniDrop,StoneBW,Surf,DropBW,Center]=QniGetRef(QNIDir,option);
        [Time,WaterMass,QniCnt]=QniGetWaterMass(QniDry,QniDrop,QNIDir,FristTime,QniFrameRate,option);
        if ~option.test ,save(fn,'QniDry','QniDrop','StoneBW','Surf','DropBW','Center','QniCnt','Time','WaterMass');end;
     else   
        disp('load QNI results');
        QniDry=[];
        load(fn);
        if isempty(QniDry) 
          try Time=Time3;end;
          try WaterMassSum=WaterMass;end;
          try WaterMass=WaterContent;end;
          [QniDry,QniDrop,StoneBW,Surf,DropBW,Center]=QniGetRef(QNIDir,option);
          save(fn,'QniDry','QniDrop','StoneBW','Surf','DropBW','Center','QniCnt','Time','WaterMass')
        end
     end
     
     % define the region of intrest
      w=220;h=120;cx=round(size(WaterMass,2)/2)-15;cy=80;
      option.QniROI=[cy-h/2,cy+h/2,cx-w/2,cx+w/2];
     
     % WaterCountoure 
      WaterBW=[];
      [QniStack]=QniFilter(QniDry,QNIDir,option);
      WaterBW=QniSegmentWater(QniDry,QniDrop,QniCnt,Time,WaterMass,option);
      %plotCountour(StoneBW,WaterBW,option);
      %analyseShape(StoneBW,Drop,WaterBW,option);
      
      % WaterProfile
      TotalMass=[];StoneMass=[];
      [TotalMass,StoneMass]=CalculateMoisterContent(QniCnt,Time,WaterMass,StoneBW,WaterBW,option);
      mov=PlotWaterMassProfile(QniCnt,Time,WaterMass,TotalMass,StoneMass,Center.Y,Center.X,StoneBW,option);
      
      
      %saving al the Data To excel
      
      
      
end


  %%--------------------------------------------------------------------------
  % Initial and Reference calculations
  %-------------------------------------------------------------------------
  function [DryRef,DropRef,StoneBW,Surf,DropBW,Center]=QniGetRef(QNIDir,option)
    % 
    %  build mean value from the first x images from QNI dry state
    %  do the segmentation of the stone =>BW
    %  get the surface line of the stone
    %  do the segmentation of one of the frist images with droplet
    %  define the center of this drop
    %  
    %  Input:
    %    QniDir       directory where the Resutls from QNI are stored
    %    option       options
    %
    %  Output:
    %    DryRef:  build mean value from the first x images from QNI dry state
    %    DropRef: fist Image with drop
    %    Stone:   do the segmentation of the stone =>BW
    %    Surf:    get the surface line of the stone
    %
    %
    %
    %-----------------------------------------------------------------
    
    test=0;
    try  test=option.test; end
 
    %% READ REFERENCE
      % read  Reference     Dry  8 images =>mean
      DryRef=imReadMean(QNIDir,'*.tif',8,1);
      if isempty(DryRef)   return;  end;
      [dryIm,rngRef]=ImageAdjust(DryRef,2,0,0,[0,0.5]); %Qni is small double value scale to Double in the range 0..1
      ImageShow(dryIm,'Dry Ref');
    
    %% make BW from stone  segmentation
      option.BWmet='stone';
      option.BWroi=[10,110,10,135];
      StoneBW=getWaterBW(dryIm,option);
      ImageShow(StoneBW,'BW Stone');

    
    %% make BW from first drop
      QNIdrop=imReadDbl(QNIDir,'*015.tif'); % tif number 15
      QNIdrop=imFilter(QNIdrop,'rem',2,5);
      DropRef=QNIdrop;
      [dropIm]=ImageAdjust(QNIdrop,rngRef); % is small double value scale to Double in the range 0..1
      H=fspecial('disk',5);
      %dropIm=imfilter(dropIm,H); %filter
      ImageShow(dropIm,'Drop Ref');
      % make dif
      difIm=imsubtract(dropIm,dryIm);
      %[difIm]=ImageAdjust(difIm,2,0,0,[0,0.7]);   %is small double value scale to Double in the range 0..1
      ImageShow(difIm,'Diff Ref');
      option.BWmet='drop';
      option.BWroi=[65,110,135,335];
      DropBW=getWaterBW(difIm,option);
      ImageShow(DropBW,'BW Drop');

    
     %find surface of the stone
       fig=ImageShow(dropIm); % Sample
       
       [sy,sx]=size(StoneBW);
       [R, B ] = FindShape2(StoneBW,fig );
       [ymin,ymax,xmin,xmax,V0] = FindCurve(B,fig,0);
       ind= V0(:,2)>100;
       V=V0(ind,:);
       ind=find(V(:,2)<sx-100);
       V=V(ind,:); 
       Surf=V ;                  %this is the surface line  (x=1,y=2)
       Ysurf=mean(Surf(:,1)); % this is the Y value of the surface = hight
       %plot the suface
       hold on
         plot(Surf(:,2),Surf(:,1),'r','LineWidth',2);
       hold off
      
       
       %find center of Water in Drop
        X0=(xmin+xmax)/2; %default
       [w1,w2,fig,Cor]=AnalyseShapeQNI(DropBW,fig,Surf);
        X0=Cor.x0;
       
        Center.X=X0;
        Center.Y=Ysurf;
        hold on
          plot(Center.X,Center.Y,'xb','LineWidth',3);
        hold off
    
       close all;
       
  end
  
  %%---------------------------------------------------------------------------------------------
  % Filtering the QNI images 
  %---------------------------------------------------------------------------------------------
  function [QniStack]=QniFilter(QniDry,QNIDir,option)
      % read file list of all QNI tif files 
      [FList,FCnt]=GetFiles(QNIDir,'*.TIF');
      [sy,sx]=size(QniDry);
      Imgs=zeros(sy,sx,FCnt);
      QniStack(FCnt)=[];     
      for i=1:FCnt
        QNIim=imread(FList(i).fullname); % original QNI image
        QNIim=double(QNIim);
        Imgs(:,:,i)=QNIim;
      end
      H=fspecial('disk',5);
      H=ones(5,5,5)/(5*5*5);
      MImgs=imfilter(Imgs,H);
      for i=1:FCnt
        QNIdif=MImgs(:,:,i)-QniDry;
        QniStack{i}=QNIdif;
      end
  end
  
  
  
  
  
  %%---------------------------------------------------------------------------------------------
  % Calculate the WaterMass as differential image from QniDry 
  %---------------------------------------------------------------------------------------------
  function [Time,MassStack ,QniCnt ] = QniGetWaterMass(QniDry,QniDrop,QNIDir,FirstTime,framerate,option)
    % 
    %  Calculates the differential image from QNI(i)-QNIRef 
    %  change of water mass by time ins sec
    %
    % input 
    %   QNIRef       is the referens image ( mean value from the first x dry image
    %   QniDir       directory where the Resutls from QNI are stored
    %   FirstTime    timestamp of the first picture
    %   framerate    frame rate of the neutra images ( QniImages have no real time stamp ) 
    % output 
    %   Time(1..)    time stamps in sec
    %   MassStack{1..} Mass(y:x)  Stack of diferential mass images from QNI(i)-QNIRef in [g] 
    %   QniCnt       number of QNI images
    %---------------------------------------------------------------------------------------------------------
    
  
      test=0;
      try  test=option.test; end

      global ImShowFlag
      if test, ImShowFlag=1;end;


      %path for output
      OutRes=strcat(QNIDir,'\RES');
      s=mkdir(OutRes);
      OutDif=strcat(QNIDir,'\Dif');
      s=mkdir(OutDif);
      QNIOutRgb=strcat(QNIDir,'\RGB');
      s=mkdir(QNIOutRgb);
      QNIOutBw=strcat(QNIDir,'\BW');
      s=mkdir(QNIOutBw);


      % read file list of all QNI tif files 
      [FList,FCnt]=GetFiles(QNIDir,'*.TIF');

      % create data arrays
      maxP=500;
      if maxP<FCnt,maxP=FCnt;end; %limit to 500 Images
      Time=zeros(maxP,1);
      Area=zeros(maxP,1);
      WaterMassSum=zeros(maxP,1);
      WaterStack{maxP}=[];
      MassStack{maxP}=[];
      [sy,sx]=size(QniDry);
      mask=zeros(size(QniDry));
      mask(30:sy-10,10:sx-10)=1; % build a mask to remove the border of the images


      % fix scalings
      [ScaleDry,rngRef]=ImageAdjust(QniDry,2,0,0,[0,0.5]); %Qni is small double value scale to Double in the range 0..1
      ScaleDrop=ImageAdjust(QniDrop,rngRef);
      % difference to the initial dry state
      ImageShow(ScaleDry,'initial dry');
      ImageShow(ScaleDrop,'initial input');
      %fix the range for scaling the diferential image 

      QniDif=imsubtract(QniDrop,QniDry);
      [ScaleDif,rngDif]=ImageAdjust(QniDif,0.1,0,0,[0.1,0.9]);
      ImageShow(ScaleDif,'initial dif');


      figIn=figure('Position',[300 400 500 500 ]);%left bottom
      figDif=figure('Position',[1000 400 500 500 ]);
      QniCnt=FCnt;  % number of images
      pics=1:1:FCnt;
      T=0;
      lastIm=QniDry;
      lastWater=zeros(size(QniDry));
      MassStack{500}=[];
      for i=pics
        Time(i)=FirstTime +framerate*(i-1);
        
        option.ImageNumber=i;
        disp(strcat('Analyse QNI  (',num2str(i),'/',num2str(FCnt),')  F=',FList(i).name));
        % read next image
        QNIim=imread(FList(i).fullname); % original QNI image
        QNIim=double(QNIim);
        % QNIim=imFilter(QNIim,'rem',2,5);  %filter
        inIm=ImageAdjust(QNIim,rngRef); % sacle to 0..1
        ImageShow(inIm,'input',figIn);

        %% DIFF IMAGE
        QniDif=imsubtract(QNIim,QniDry);
        QniDif=QniDif.*mask; % get rid of the Border
        % write differetial image ther is no way to write a tiff thet is not in the range from 0..1 
        fn=strcat(OutDif,'\',FList(i).filename,'.fits');
        ImWriteFits(fn,QniDif);  % double must be written in fits
        MassStack{i}=QniDif;

        % difference to the initial dry state scaled image 0..1 
        imDif=ImageAdjust(QniDif,rngDif);
        ImageShow(imDif,'dif',figDif);

      end
      
      close all;
  end  
      
  
  %%---------------------------------------------------------------------------
  %  segmentation of QniDif WaterMass to get the BW of water
  %---------------------------------------------------------------------------
  function [WaterStack]=QniSegmentWater(QniDry,QniDrop,Time,MassStack,option)

     QniCnt=length(MassStack);
     doAll=true;
     timesteps=[5,30,60,120,180,9999];%secs
     ts=1;
     list=1:QniCnt;
     
     if option.test,list=[15,20,50];end;
     for i=list
       if Time(i)>timesteps(ts) || doAll
 
      
        %% Segmentation BW on differetial image
        %imDisk=imFilter(imDif,'disk',20);
        %imMed=imFilter(imDif,'median');

        option.BWmet='chan';
        Qni=MassStack{i};
        
        
        
        option.Iref=Qni;
        water=getWaterBW(imDif,option);


        %% BW of water dedection
        % Measure Water

        % difference to the last water BW
        waterDif=imsubtract(double(water),double(lastWater));
        more=waterDif>0;
        less=waterDif<0;
        ImageShow(more,'more');   % show
        ImageShow(less,'less');   % show
        lastIm=inIm;
        lastWater=water;

         % create RGB for visualisation on the 
        imIgr=uint8(ImageAdjust(imDif,1,0,0,[0,0.5])*255);
        imRGB=imIgr;
        imRGB=ImageSetCol(imRGB,imIgr,[255*0.2,0,0],0,water); %red
        imRGB=ImageSetCol(imRGB,imIgr,[0,255*0.2,0],0,more); %green
        imRGB=ImageSetCol(imRGB,imIgr,[0,0,255*.2],0,less); %blue
        ImageShow(imRGB,'rgb');
        fn=strcat(QNIOutRgb,'\',FList(i).name);
        imwrite(imRGB,fn);
        fn=strcat(QNIOutBw,'\',FList(i).name);
        imwrite(uint16(water*255),fn);


        ii=ii+1;
        ii=i;
        % Timestamp
        T=FirstTime+(1/framerate)*(ii-1); 
        Time(ii)=T;
        % 
        % Measure the water 
        r=regionprops(water,'Area');
        l=length(r);
        if l>0 
          a0=r(1).Area;
          a=a0;  %200pix=10mm
          Area(ii)=a;

          if a>1 && droped==0
             droped=1;
             droptime=T;
          end   
        end

        Mass=QNIDif;
        %Mass(Mass<0)=0;   % only positive Pass this is not realy good
        WaterMassSum(ii)=sum(sum(Mass.*water));
        WaterStack{ii}=water;

      end
 
     end

  end

  
  
  
  %%-----------------------------------------------------------------------------------------------
  % ploting contoure of BW Water 
  %----------------------------------------------------------------------------------------------
  function plotCountour(Stone,BW,option)   
     %% plot Qni Countour  of water for specific times
     fig=[];
     if  option.QniContour || option.AnalyseAll
       doall=0;
       timesteps=[0,2,4,10,20,40,9999]; %secs
       Cts=length(timesteps);
       disp(strcat('QNI Contours ', num2str(Cts),'   '));
       fig=plotContour(Stone,fig,'Stone',1,2);
       ts=1;
       for i=1:QniCnt
         if Time3(i)>timesteps(ts) || doall
           nm=strcat('t=',num2str(timesteps(ts)));
           nm=strcat('t=',num2str(round(Time3(i))));
           fig=plotContour(BW{i},fig,nm,ts+1);
           if ts<Cts,ts=ts+1;end;
         end  
       end
       figure(fig);
       a=get(fig,'CurrentAxes');
       set(a,'YDir','reverse');
       legend('show');
       haxes=get(fig,'CurrentAxes');
       set(haxes,'DataAspectRatioMode','manual');
       fign=strcat(ResDir,'\QniCountour.fig');
       saveas(fig,fign);
     end   
  end  
     
  
  
  
   %%------------------------------------------------------------------------------
   % analys ethe shape of the BW water
   %------------------------------------------------------------------------------
   function analyseShape(Stone,Drop,BW,option)
     %% analyse shape and get surface form Qnipicturs and plot QniShape
     %path for output
     OutDir=strcat(QNIDir,'\RES\');
     s=mkdir(OutDir);
      
     ResDir=option.ResDir;
      
     fn=strcat(ResDir, '\QniShape.mat');
     fig=[];
     ImShowFlag=1;
     if  option.QniShape || option.AnalyseAll 
       timesteps=[0,2,4,10,20,40,9999];%secs
       Cts=length(timesteps);
       disp(strcat('QNI Shape ', num2str(Cts),'   '));
       %find surface of the stone
       [sy,sx]=size(Stone);
       fig=ImageShow(dryIm); % stone is BW
       [R, B ] = FindShape2(Stone,fig );
       [ymin,ymax,xmin,xmax,V0] = FindCurve(B,fig,0);
       ind= V0(:,2)>100;
       V=V0(ind,:);
       ind=find(V(:,2)<sx-100);
       V=V(ind,:); 
       surf=V ; %this is the surface line  (x=1,y=2)
       Ysurf=mean(surf(:,1));
       hold on
         plot(surf(:,2),surf(:,1),'r','LineWidth',2);
       hold off
       
       X0=(xmin+xmax)/2;
       %find center of Water in pic 13
       [w1,w2,fig,Cor]=AnalyseShapeQNI(BW{15},fig,surf);
       X0=Cor.x0;
       %
       
       
       Y0=Ysurf;
       hold on
         plot(X0,Y0,'xb','LineWidth',3);
       hold off
       close(fig);fig=[]; 
        
       %fit curve to QNI shape
       ts=1;doAll=1;
       list=1:QniCnt;
       if option.test,list=[15,20,50];end;
       for i=list
         if Time3(i)>timesteps(ts) || doAll
           nm=strcat('t=',num2str(timesteps(ts)));
           nm=strcat('t=',num2str(round(Time3(i))));
           fig=[];
           fig=ImageShow(WaterMass{i},'Shape',[],1,0,1); % stone is BW
           hold on % plot the stone
             plot(B(:,2),B(:,1),'y','LineWidth',1);
           hold off
           [w1(i),w2(i),fig]=AnalyseShapeQNI(BW{i},fig,surf); % wetted angle
           fign=strcat(OutDir,'\Shape',nm,'.fig');
           saveas(fig,fign);
           close(fig);
           if ts<Cts,ts=ts+1;end;
         end  
       end
       if ~option.test ,save(fn,'H','L','xmin','xmax','surf','w1','w2');end
     else   
       load(fn);
     end
  end   

    

    %%------------------------------------------------------------------------------
    % CalculateMoisterContent
    %------------------------------------------------------------------------------
    function [TotalMass,StoneMass]=CalculateMoisterContent(QniCnt,Time,WaterMass,StoneBW,WaterBW,option)
    
      ResDir=option.ResDir;
      ROI=option.QniROI;
      test=option.test;
      test=0;
      
      if isempty(StoneBW);
        StoneBW=zeros(size(WaterMass{1}));
      end
      if isempty(WaterBW);
        WaterMask=zeros(size(WaterMass{1}));
        WaterBW{QniCnt}=[];
      end
     
     %Geomety
     pixsize=45.5*1E-6;
     thickness=10*1E-3;
     Vol=pixsize*pixsize*thickness;

     
     % QNI Water Mass 
     fn=strcat(ResDir, '\QniWaterMass.mat');
     if  ~exist(fn,'file') ||option.QniWaterMass || option.AnalyseAll 
       Cts=QniCnt;
       disp(strcat('QNI Water Content ', num2str(Cts),'   '));
       WCarea=zeros(QniCnt,1);
       WCmass=zeros(QniCnt,1);
       MassROI=zeros(QniCnt,1);
       MassW=zeros(QniCnt,1);
       MassW1=zeros(QniCnt,1);
       MassW2=zeros(QniCnt,1);
       MassW3=zeros(QniCnt,1);
       MassW4=zeros(QniCnt,1);
       MassW5=zeros(QniCnt,1);
       MassS=zeros(QniCnt,1);
       MassS_2=zeros(QniCnt,1);
       MassS_1=zeros(QniCnt,1);
       MassS1=zeros(QniCnt,1);
       MassS2=zeros(QniCnt,1);
       ts=1;
       list=1:QniCnt;
       %if option.test,list=[15,20,50];end;
       for i=list
         %% Calc water content
         if ~isempty(WaterBW{i}), WaterMask=WaterBW{i};end;
         Mass=WaterMass{i};
         if ~isempty(Mass)
           Neg=Mass<0;
           %Mass(Neg)=0; %set all negative value to 0
           [y,x]=size(Mass);
           ROImask=zeros(y,x);
           ROImask(ROI(1):ROI(2),ROI(3):ROI(4))=1;
           MassKgm3=Mass/Vol/1000;
          
           % Moister Content in ROI area
           MoisterContent=MassKgm3.*ROImask;
   
           %masks for calculation of WaterMass
           Water1=bwmorph(WaterMask,'dilate',5);
           Water2=bwmorph(WaterMask,'dilate',10);
           Water3=bwmorph(WaterMask,'dilate',15);
           Water4=bwmorph(WaterMask,'dilate',20);
           Water5=bwmorph(WaterMask,'dilate',30);
           Stone_2=bwmorph(StoneBW,'erode',2);
           Stone_1=bwmorph(StoneBW,'erode',1);
           Stone1=bwmorph(StoneBW,'dilate',1);
           Stone2=bwmorph(StoneBW,'dilate',2);
           %WaterMass
           WaMass=Mass;
           MassROI(i)=sum(sum(WaMass.*ROImask)); % just the ROI part of 
           MassW(i)=sum(sum(WaMass.*WaterMask)); % just count the mass where water
           MassW1(i)=sum(sum(WaMass.*Water1));   % just count the mass where water + a border of 5 pixel was dedected
           MassW2(i)=sum(sum(WaMass.*Water2));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           MassW3(i)=sum(sum(WaMass.*Water3));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           MassW4(i)=sum(sum(WaMass.*Water4));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           MassW5(i)=sum(sum(WaMass.*Water5));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           WaMass1=Mass.*ROImask;                   % Water and the border of 10 pixel
           MassS(i)=sum(sum(WaMass1.*StoneBW));      % from that just the stone 
           MassS_2(i)=sum(sum(WaMass1.*Stone_2));  % from that just the stone decreased by 2 pixel
           MassS_1(i)=sum(sum(WaMass1.*Stone_1));  % from that just the stone decreased by 2 pixel
           MassS1(i)=sum(sum(WaMass1.*Stone1));    % from that just the stone increased by 1 pixel
           MassS2(i)=sum(sum(WaMass1.*Stone2));    % from that just the stone increased by 2 pixel
         end  
       end
       if ~test 
         disp('save watermass'); 
         save(fn,'Time','MassROI','MassW','MassW1','MassW2','MassW3','MassW4','MassW5','MassS','MassS_2','MassS_1','MassS1','MassS2');
       end
     else
       disp('load watermass');
       load(fn)       
     end
     
      TotalMass=MassROI;
      StoneMass=MassS;

     
     if option.QniWaterMassSaveToExcel
        disp('Save the excel'); 
        fnxls=option.fnxls;
        Tabn='WaterMass';
        ra='A1';
        data={'WaterMass',1};
        data=datains(data,{''},1);
        data=datains(data,{'time','MassROI','MassW','MassW1','MassW2','MassW3','MassW4','MassW5','MassS_2','MassS_1','MassS','MassS1','MassS2'},1);
        data=datains(data, {Time,MassROI,MassW,MassW1,MassW2,MassW3,MassW4,MassW5,MassS_2,MassS_1,MassS,MassS1,MassS2},1);
        %write the to excel 
        xlswrite(fnxls, data, Tabn,ra);
     end   
     
  end        
     
     

       
     %%------------------------------------------------------------------------------
     % Plot Moister Content Profile
     %------------------------------------------------------------------------------
     function mov=PlotWaterMassProfile(QniCnt,Time,WaterMass,TotalMass,StoneMass,Ysurf,X0,Stone,option)
     
       if isempty(TotalMass), TotalMass=zeros(size(Time));end;
       if isempty(StoneMass), StoneMass=zeros(size(Time));end;
     
       ROI=option.QniROI;
     
       %%Geomety
       pixsize=45.5*1E-6;
       thickness=10*1E-3;
       Vol=pixsize*pixsize*thickness;
        
%        ROIw=300;  % ROIwith 
%        X1=X0-ROIw/2;
%        X2=X0+ROIw/2;
       X1=ROI(3);
       X2=ROI(4);
       Y1=ROI(1);
       Y2=ROI(2);
       
       S=[];StoneBoundaries=[0,0];
       try  S=Stone; end;
       if ~isempty(S),[R, StoneBoundaries ] = FindShape2(Stone );end;
       

       
       % plots the waterMass profile
       fig=figure; mov=[];
       set(fig,'Position',[300 300 900 600 ]);
       f1=subplot('Position',[10,15,50,70]/100); %left,bottum,width,height
       f2=subplot('Position',[70,15,25,70]/100); %left,bottum,width,height
       timesteps=[5,30,60,120,180,9999];%secs
       ts=1;Cts=length(timesteps);
       list=1:QniCnt;
       doAll=1;
       if option.test
         doAll=true;
         list=[15,20,50];
       end
       
       for i=list
          if Time(i)>timesteps(ts) || doAll
            nm=strcat('t = ', num2str(Time(i)),' [sec]'); 
            Mass=WaterMass{i};
            MassKgm3=Mass/Vol/1000;
            figure(fig);
            tit=strcat('   time[',num2str(Time(i)),']' );
            set(fig,'name',tit);
            
            %moisterContent
              subplot(f1);
              TMass=TotalMass(i)*1000;
              SMass=StoneMass(i)*1000;
              %crop=MassKgm3(ROI(1):ROI(2),ROI(3):ROI(4));
              imshow(MassKgm3);
              H=size(Mass,1);
              tit=strcat('water distribution [kg/m3]', '  time:',num2str(Time(i)),'[sec]' );
              title(tit, 'FontSize', 10);
              colormap(jet(20));
              %colormap(gray(10));
              cmax=2e-006/Vol/1000;
              caxis([0 cmax]);
              h = colorbar('vertical');
              hold on
                % plot the Stone
                plot(StoneBoundaries(:,2),StoneBoundaries(:,1),'k','LineWidth',1);
                % plot ROI
                plot([X1,X1],[Y1,Y2],'r','LineWidth',2);
                plot([X2,X2],[Y1,Y2],'r','LineWidth',2);
                ylim([ROI(1),ROI(2)+30]);
                xlim([ROI(3),ROI(4)]);
                text(100,100,strcat(num2str(TMass),' [mg]'),'FontSize',10,'Color','k');
                text(100,20,strcat(num2str(TMass-SMass),' [mg]'),'FontSize',10,'Color','r');
                text(100,200,strcat(num2str(SMass),' [mg]'),'FontSize',10,'Color','g');
              hold off  
              %caxis(h,[mi ma]);
              %set(h,'CLim',[mi ma]);
              %colormap(jet(256));
              %h=colorbar('vertical'); 
              %colorbar('YTickLabel',
              %a=get(fig,'CurrentAxes');
              %set(a,'YDir','reverse');
              %legend('show');
              %haxes=get(fig,'CurrentAxes');
              %set(haxes,'DataAspectRatioMode','manual');

             %profile
               subplot(f2);
              %Calc Penetration
               [sx,sy]=size(Mass);
               Plotcrop=Mass(Y1:Y2,X1:X2);
               PlotSum=sum(Plotcrop,2);
               %plotProfile
               sx=20e-3;
               yaxis=Y1:1:Y2;
               PlotSum=PlotSum*1000;
               yaxis=(yaxis-Ysurf)*-pixsize*1000;
               plot(PlotSum, yaxis,'k','LineWidth',1);
               tit=strcat('WM:',num2str(sum(PlotSum)) ,'[mg]  time:',num2str(Time(i)),'[sec]'  );
               title(tit, 'FontSize', 10);
               hold on
                 % med=mean2(PlotSum,[21,1]);
                 H= fspecial('average',3);
                 med=imfilter(PlotSum,H); % plot filter
                 plot(med, yaxis,'b','LineWidth',2);
                 plot([0,0],[-20,5],'r','LineWidth',1); %Vertical
                 plot([-0.02,0.20],[0,0],'r','LineWidth',1); %horizontal
                 xlabel('water [mg]');
                 xlim([-0.02,0.20]);
                 ylabel('height [mm]');
                 ylim([(ROI(2)+80-Ysurf)*-pixsize*1000,(ROI(1)-Ysurf)*-pixsize*1000]);
               hold off
               
             mov=ImAddToMovie( mov,fig );
             if ts<Cts,ts=ts+1;end;
          end  
       end
       
       close(fig);
       fn=strcat('WaterProfile.avi');
       ImWriteAvi( fn,mov);
     end     
   
     
     
    %%------------------------------------------------------------------------------
    % Plot Water Mass notused
    %------------------------------------------------------------------------------
    function [mov]=PlotWaterMass(Time,WaterMass,option)
       fig=figure;
       mov=[];
       ImShowFlag=1;
       doAll=true;
       timesteps=[5,30,60,120,180,9999];%secs
       ts=1;
       list=1:QniCnt;
       if option.test,list=[15,20,50];end;
       for i=list
          if Time(i)>timesteps(ts) || doAll
             nm=strcat('t = ', num2str(Time(i)),' [sec]'); 
             Mass=WaterMass{i};
             MassKgm3=Mass/Vol/1000;
             figure(fig);
             imshow(MassKgm3);
             colormap(jet(20));
             %colormap(gray(10));
             caxis([0 250]);
             h = colorbar('vertical');
             title(nm, 'FontSize', 16);
             set(fig,'Position',[300 300 1000 700 ]); %left,buttom,width,height
             set(fig,'name',strcat('water mass ',nm));
             mov=ImAddToMovie( mov,fig );
             %SaveFig(fig);
          if ts<Cts,ts=ts+1;end;
          end  
       end
       close(fig)
       fn=strcat('WaterContent.avi');
       ImWriteAvi( fn,mov);
    end     
       
    
     
    
    
    %%------------------------------------------------------------------------------
    % Segmentation
    %------------------------------------------------------------------------------
     
    function [BW]=getWaterBW(Im,option)
      % make BW from gray Im
      % option.BWmet 'drop','stone','chan',('th')
      % option.BWroi ROI to calculate threshold by OTSU
      
        met='th';
        imROI=Im;
        
        try met=option.BWmet;end;
        try 
          ROI=option.BWroi;
          imROI=Im(ROI(1):ROI(2),ROI(3):ROI(4));
        end;
         
        switch met
          case'drop'
            % make BW
            th=graythresh(imROI);
            th = th*1.2;
            imBW = im2bw(Im,th);
            ImageShow(imBW,'bw');
            imBW=bwareaopen(imBW,40);  % remove small areas
            SE=strel('disk',4);        % make the border more smooth
            imBW=imclose(imBW,SE);      
            imBW=imfill(imBW,'holes'); % fill the holes  
            imBW=imopen(imBW,SE);      
            BW=imBW;
            ImageShow(BW,'BW');
          case'chan'
            %option.TH=0.0043; %stop chanvese
            imBW=ChanVeseBW(Im,option);  
            ImageShow(imBW,'chan');
            SE=strel('disk',6);        % make the border more smooth
            imBW=imclose(imBW,SE);      
            imBW=imfill(imBW,'holes'); % fill the holes  
            imBW=bwareaopen(imBW,200);  % remove small areas
            BW=imBW;
            ImageShow(BW,'BW');
          case 'stone'
            %filter smothing
            H=fspecial('disk',3);
            imFlt=imfilter(Im,H);
            imFlt=Im; % not used
            ImageShow(imFlt,'filter');
            %edg
            imEdg=FindEdges(imFlt,0.5,10);  % canny
            imEdg=imEdg>0;
            ImageShow(imEdg,'Edg');
            % threshold and morphological operations to do BW
            % could be replaced with better function
            th=graythresh(imROI);
            th=th*1.1;
            imBW=imFlt>th;
            ImageShow(imBW,'threshold');
            imBW=imBW+imEdg;
            imBW=bwareaopen(imBW,40);  % remove small areas
            SE=strel('disk',4);        % make the border more smooth
            imBW=imclose(imBW,SE);      
            imBW=imfill(imBW,'holes'); % fill the holes  
            imBW=imopen(imBW,SE);      
            BW=imBW;
            ImageShow(BW,'BW');
          case 'th'
            %% BW2 Threshold
            % filter 
            H=fspecial('disk',10);
            imFlt=imfilter(Im,H);
            r=10;
            imFlt= medfilt2(Im,[r r]);
            %imFlt=imDif; %filter not used
            ImageShow(imFlt,'filter');
            % threshold and morphological operations to do BW
            % could be replaced with better function
            % th=0.3;
            th1=graythresh(imFlt)*1.1;
            th=max ([th1 0.24]);
            imTh=imFlt>th;
            ImageShow(imTh,'Th');
            % imGrad=gradient(imDif,10);
            % ImageShow(ImageAdjust(imGrad,0),'gradient');
            % add edg
            imEdg=FindEdges(imFlt,0.3,5);
            imEdg=imEdg>0;
            SE=strel('disk',5);        
            imEdg=imclose(imEdg,SE);
            imEdg=bwmorph(imEdg,'bridge');
            imEdg=imEdg.*mask;
            ImageShow(imEdg,'Edg');
            imBW=imTh+imEdg;
            ImageShow(imBW,'th + Edg');
            SE=strel('disk',6);        % make the border more smooth
            imBW=imclose(imBW,SE);      
            imBW=imfill(imBW,'holes'); % fill the holes  
            imBW=bwareaopen(imBW,200);  % remove small areas
            BW=imBW;
            ImageShow(BW,'BW');
        end  
       

    
    end
    
    

