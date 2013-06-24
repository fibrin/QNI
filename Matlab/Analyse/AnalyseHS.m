function [Time,Area,Gray,BWstack ,Stone,ROI ] = AnalyseHS(SampleDir,FirstTime,framerate,ROI,option)
    %  this Reads all images foem sampledir and makes BW form the Trop
    %  and calculates the Droplet Volue
    %  Output is timetable,Area,Volume,BWpicturs if Drop and the stone
    %
    if nargin==0 ,A0_main;return; end;

    if nargin<1, A0_main;return;end;
      test=0;
    try
      test=option.test;
    catch
    end

    global ImShowFlag
    
    
    %% set Path and file
    HSDir=strcat(SampleDir,'\HS');
    
    %path output
    OutRes=strcat(HSDir,'\RES');
    s=mkdir(OutRes);
    OutDif=strcat(HSDir,'\Dif');
    s=mkdir(OutDif);
    HSOutRgb=strcat(HSDir,'\RGB');
    s=mkdir(HSOutRgb);
    HSOutBw=strcat(HSDir,'\BW');
    s=mkdir(HSOutBw);
    
    ROI=[150,200,850,800];%left,top,right,bottom
    
    if isempty(ROI) || option.chooseROI
      
    end
    
    %read  Reference     Dry  8 images =>mean
    iRGB=imReadMean(HSDir,'*.tif',5);
    iRGBend=imReadMean(HSDir,'*.tif',-5);
    % substuidude im with drop with background from last pics
    iRGB(1:500,:,:)=iRGBend(1:500,:,:);
    % ok 
    inIm0=rgb2gray(iRGB);
    inIm0=ImageCutROI(inIm0,ROI);
    [inIm,rngRef]=ImageAdjust(inIm0,2,0,0,[0,0.5]); %HS is small double value 
      
    ImageShow(inIm,'Drop Ref');
    
    dryIm=inIm;
    
    
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
      imEdg=FindEdges(imFlt,0.1,5);  % canny
      imEdg=imEdg>0;
      ImageShow(imEdg,'Edg');
      % threshold and morphological operations to do BW
      % could be replaced with better function
      th=graythresh(imFlt(250:500,250:500));
      th=th*.8;
      %th=0.55;
      imBW=~(imFlt>th);
      ImageShow(imBW,'threshold');
      imBW=imBW; % +imEdg;
      imBW=bwareaopen(imBW,50000);  % remove small areas
      ImageShow(imBW,'BW1');
      SE=strel('disk',4);        % make the border mor smooth
      imBW=imclose(imBW,SE);      
      imBW=imfill(imBW,'holes'); % fill the holes  
      imBW=imopen(imBW,SE);      
      Stone=imBW;
      ImageShow(Stone,'BW Stone');
      Surface=bwperim(Stone);
      Surface=ImBorderSet(Surface,10,0);
      inIm=inIm+1*Surface;
      ImageShow(inIm,'Surface');
    end       
    
    % read file list 
    [FList,FCnt]=GetFiles(HSDir,'*.TIF');
    
    % create data arrays
    maxP=500;
    if maxP<FCnt,maxP=FCnt;end;
    Time=zeros(maxP,1);
    Area=zeros(maxP,1);
    Gray=zeros(maxP,1);
    BWstack{maxP}=[];
    [sy,sx]=size(dryIm);
    mask=zeros(size(dryIm));
    mask(10:sy-10,10:sx-10)=1;
          

    
    %Read fist pic with drop for rangefit
     iRGB=imReadDbl(FList(10).fullname);
     inIm0=rgb2gray(iRGB);
     inIm=ImageCutROI(inIm0,ROI);
     inIm=ImageAdjust(inIm,rngRef);
     
    % difference to the initial dry state
    ImageShow(dryIm,'initial dry');
    ImageShow(inIm,'initial input');

    imDif0=imsubtract(dryIm,inIm);
    imDif0(imDif0<0)=0;
    [imDif,rngDif]=ImageAdjust(imDif0,0.1,0,0,[0.1,0.9]);
    
    ImageShow(imDif,'initial dif');
      
          
     
    pics=1:1:FCnt;
    if test
       pics=[10,70,FCnt-200];
    end   
    ImShowFlag=max(pics)<FCnt;
    T=0;
    lastIm=dryIm;
    lastWater=zeros(size(dryIm));
    droped=0;
    droptime=0;
    ii=0;
    for i=pics
      disp(strcat('Analyse HS  (',num2str(i),'/',num2str(FCnt),')  F=',FList(i).name));
      % read next image
      iRGB=imReadDbl(FList(i).fullname);
      inIm0=rgb2gray(iRGB);
      inIm=ImageCutROI(inIm0,ROI);
      inIm=ImageAdjust(inIm,rngRef);
      ImageShow(inIm,'input');
      % difference to the initial dry state
      imDif=imsubtract(dryIm,inIm);
      imDif=imDif.*mask;
      imDif=ImageAdjust(imDif,rngDif);
      ImageShow(imDif,'dif');
      if 1
      %% BW2
        if 0
          % filter 
          H=fspecial('disk',10);
          imFlt=imfilter(imDif,H);
          r=10; imFlt= medfilt2(imDif,[r r]);
          ImageShow(imFlt,'filter');
        else
           %imFlt=imDif; %filter not used
          imFlt=imDif;
        end   
        % threshold and morphological operations to do BW
        % could be replaced with better function
        % th=0.3;
        th1=graythresh(imFlt)*1.1;
        th=min ([th1 0.3]);
        imTh=imFlt>th;
        ImageShow(imTh,'Th');
        imBW=imTh;
        % imGrad=gradient(imDif,10);
        % ImageShow(ImageAdjust(imGrad,0),'gradient');
        % add edg
        if 0
          imEdg=FindEdges(imFlt,0.3,5);
          imEdg=imEdg>0;
          SE=strel('disk',5);        
          imEdg=imclose(imEdg,SE);
          imEdg=bwmorph(imEdg,'bridge');
          imEdg=imEdg.*mask;
          ImageShow(imEdg,'Edg');
          imBW=imBW +imEdg;    
        end
        imBW=imBW + Surface;
        ImageShow(imBW,'th + Surf');
        imBW=imfill(imBW,'holes'); % fill the holes  
        imBW=imBW.*~Stone;
        imBW=bwareaopen(imBW,1000);  % remove small areas
        ImageShow(imBW,'crop Stone');
        SE=strel('disk',3);        % make the border more smooth
        imBW=imclose(imBW,SE);      
        water2=imBW;
        ImageShow(water2,'water');   % show
        water=water2;
        
     end  
      %%
      
     
       
      
      % write differetial image 
      fn=strcat(OutDif,'\',FList(i).name);
      imWriteTif(imDif,fn);
      
      
      %%
      % Measure Water
      
      % difference to the last water
      waterDif=imsubtract(double(water),double(lastWater));
      more=waterDif>0;
      less=waterDif<0;
      
      ImageShow(more,'more');   % show
      ImageShow(less,'less');   % show
      
      lastIm=inIm;
      lastWater=water;
      
       % create RGB for visualisation
      inIm0=uint8(ImageAdjust(inIm0,1,0,0,[0,0.5])*255);
      imRGB=inIm0;
      imRGB=ImageSetCol(imRGB,inIm0,[255*0.2,0,0],0,water); %red
      imRGB=ImageSetCol(imRGB,inIm0,[0,255*0.2,0],0,more); %green
      imRGB=ImageSetCol(imRGB,inIm0,[0,0,255*.2],0,less); %blue
      ImageShow(imRGB,'rgb');
      fn=strcat(HSOutRgb,'\',FList(i).name);
      imwrite(imRGB,fn);
      fn=strcat(HSOutBw,'\',FList(i).name);
      imwrite(uint16(water*255),fn);
      
     
      ii=ii+1;
      % Timestamp
      T=T+1/framerate; 
      Time(ii)=T;
      % Measure the water 
      r=regionprops(water,'Area');
      l=length(r);
      if l>0 
        a0=r(1).Area;
        a=a0;  %200pix=10mm
        Area(ii)=a;
        imGr=inIm.*water;
        a0=1;
        Gray(ii)=sum(sum(imGr))/a0;
        if a>1 && droped==0
           droped=1;
           droptime=T;
        end   
      end  
      BWstack{ii}=water;
     
    end
    Time(FCnt:maxP)=T;
    dt=droptime-FirstTime;
    Time=Time-dt;
    
   
      
 end


