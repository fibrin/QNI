function [Time,Area,WaterMassSum,dryIm,Stone,WaterStack ,MassStack ] = AnalyseQNI(SampleDir,FirstTime,framerate,option)
    %
    % input 
    %   SampleDir    directory where the neutra Data is stored
    %   FirstTime    timestamp of the first picture
    %   framerate    frame rate of the neutra images ( QniImages have no real time stamp ) 
    % output 
    %   time(1..) time in sec
    %   Area(1..) area in pixels 
    %   WaterMassSum(1..) total water mass where water was detected just e estimation
    %   dryIm(y:x) Initial dry image from QNI pic bas for calculation mean  value from the first 8 images
    %   Stone(y:x) BW of the stone from the dryImage
    %   WaterStack{1..} Water(y:x) Stack of BW images where water was dedected
    %   MassStack{1..} Mass(y:x)  Stack of diferential mass images from QNI in [g] 
    %
    %---------------------------------------------------------------------------------------------------------
    
    if nargin<1, A0_main;return;end;
      test=0;
    try
      test=option.test;
    catch
    end
    
    global ImShowFlag
    if test, ImShowFlag=1;end;
    
    %% set Path for input
    QNIDir=strcat(SampleDir,'\QNI\QNI_r');
    
    %path for output
    OutRes=strcat(QNIDir,'\RES');
    s=mkdir(OutRes);
    OutDif=strcat(QNIDir,'\Dif');
    s=mkdir(OutDif);
    QNIOutRgb=strcat(QNIDir,'\RGB');
    s=mkdir(QNIOutRgb);
    QNIOutBw=strcat(QNIDir,'\BW');
    s=mkdir(QNIOutBw);
    
    %% READ REFERENCE
    %read  Reference     Dry  8 images =>mean
    QNIRef=imReadMean(QNIDir,'*.tif',8,1);
    inIm0=QNIRef;
    [inIm,rngRef]=ImageAdjust(inIm0,2,0,0,[0,0.5]); %Qni is small double value scale to Double in the range 0..1
    ImageShow(inIm,'Drop Ref');
    
    %scaled dry image
    dryIm=inIm;
    
    %% make the first segmentation to get the stone
    if isempty(inIm)
      return
    elseif 1
      % make BW from stone  segmentation
      im=inIm;
      %filter smothing
      H=fspecial('disk',3);
      imFlt=imfilter(im,H);
      imFlt=im; % not used
      ImageShow(imFlt,'filter');
      %edg
      imEdg=FindEdges(imFlt,0.5,10);  % canny
      imEdg=imEdg>0;
      ImageShow(imEdg,'Edg');
      % threshold and morphological operations to do BW
      % could be replaced with better function
      th=0.55;
      imBW=imFlt>th;
      ImageShow(imBW,'threshold');
      imBW=imBW+imEdg;
      imBW=bwareaopen(imBW,40);  % remove small areas
      SE=strel('disk',4);        % make the border more smooth
      imBW=imclose(imBW,SE);      
      imBW=imfill(imBW,'holes'); % fill the holes  
      imBW=imopen(imBW,SE);      
      Stone=imBW;
      ImageShow(Stone,'BW Stone');
    end       
    
    
    
    
    
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
    [sy,sx]=size(dryIm);
    mask=zeros(size(dryIm));
    mask(30:sy-10,10:sx-10)=1; % build a mask to remove the border of the images
          
    if option.QniDryOnly,return;end;

    
    %Read fist pic with drop ( pic11) for rangefit
    inIm0=imReadDbl(FList(11).fullname);
    inIm=ImageAdjust(inIm0,rngRef);
    % difference to the initial dry state
    ImageShow(dryIm,'initial dry');
    ImageShow(inIm,'initial input');

    %fix the range for correction 
    imDif0=imsubtract(inIm,dryIm);
    [imDif,rngDif]=ImageAdjust(imDif0,0.1,0,0,[0.1,0.9]);
    ImageShow(imDif,'initial dif');
      
          
     
    pics=1:1:FCnt;
    if test
       pics=[15,20,FCnt-3];
    end   
    T=0;
    lastIm=dryIm;
    lastWater=zeros(size(dryIm));
    droped=0;
    droptime=0;
    ii=0;
    for i=pics
      option.ImageNumber=i;
      disp(strcat('Analyse QNI  (',num2str(i),'/',num2str(FCnt),')  F=',FList(i).name));
      % read next image
      QNIim=imread(FList(i).fullname); % original QNI image
      QNIim=double(QNIim);
      inIm=ImageAdjust(QNIim,rngRef); % sacle to 0..1
      ImageShow(inIm,'input');
      
      %% DIFF IMAGE
      QNIDif=imsubtract(QNIim,QNIRef);
      QNIDif=QNIDif.*mask; % get rid of the Border
      % write differetial image ther is no wax to write a tiff thet is not in the range from 0..1 
      fn=strcat(OutDif,'\QNI',FList(i).filename,'.fits');
      ImWriteFits(fn,QNIDif);  % double must be written in fits
     
      % difference to the initial dry state scaled image 0..1 
      imDif=imsubtract(inIm,dryIm);
      imDif=imDif.*mask; % get rid of the border
      imDif=ImageAdjust(imDif,rngDif);
      ImageShow(imDif,'dif');

      
      
      % write differetial image 
      fn=strcat(OutDif,'\',FList(i).name);
      imWriteTif(imDif,fn);
 
      
      
      %% Segmentation BW on differetial image
      %imDisk=imFilter(imDif,'disk',20);
      %imMed=imFilter(imDif,'median');
     
      
      
      bwMet='chan';
      %% BW1  Chan-Vese
      option.Iref=QNIDif;
      if 1
        %option.TH=0.0043; %stop chanvese
        imBW=ChanVeseBW(imDif,option);  
        ImageShow(imBW,'chan');
        SE=strel('disk',6);        % make the border more smooth
        imBW=imclose(imBW,SE);      
        imBW=imfill(imBW,'holes'); % fill the holes  
        imBW=bwareaopen(imBW,200);  % remove small areas
        water1=imBW;
        ImageShow(water1,'water chan');   % show
        water=water1;
      end
      if 0
      %% BW2 Threshold
        % filter 
        H=fspecial('disk',10);
        imFlt=imfilter(imDif,H);
        r=10;
        imFlt= medfilt2(imDif,[r r]);
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
        water2=imBW;
        ImageShow(water2,'water2 OTSU');   % show
        water=water2
      end  
      %%
      
     
       
      
      
      
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
      MassStack{ii}=Mass;
     
    end
    Time(FCnt:maxP)=T;
    dt=droptime-FirstTime;
    Time=Time-dt;
    
   
      
 end


