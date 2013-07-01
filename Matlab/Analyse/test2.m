clear all;
clc % clears all the old variavles form memory and closes open graphe
A1_Init;

global ProgDir ResDir ImShowFlag

    ImShowFlag=1;

    RAWDATA='C:\Users\lej\Desktop\Jaebong_PSI_20122511\P12101\raw_data\'; 
  
    SampleDir='Meule\RH50_V1\7';  % 25.1
    
    SampleDir=strcat(RAWDATA,SampleDir);
    
  %% set Path and file
    QNIDir=strcat(SampleDir,'\QNI\QNI_r');
    ImDir=strcat(QNIDir,'\RAW');
    NeutraDir=strcat(SampleDir,'\RAW');
    
    OutDif=strcat(QNIDir,'\Dif');
    s=mkdir(OutDif);
  
    %read  Reference     Dry  8 images =>mean
    inIm0=imReadMean(QNIDir,'*.tif',8,1);
    [inIm,rngRef]=ImageAdjust(inIm0,2,0,0,[0,0.5]); %Qni is small double value
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
      SE=strel('disk',4);        % make the border mor smooth
      imBW=imclose(imBW,SE);      
      imBW=imfill(imBW,'holes'); % fill the holes  
      imBW=imopen(imBW,SE);      
      Stone=imBW;
      ImageShow(Stone,'BW Stone');
    end       
    
    % read file list 
    [FList,FCnt]=GetFiles(QNIDir,'*.TIF');
    
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
    inIm0=imReadDbl(FList(11).fullname);
    inIm=ImageAdjust(inIm0,rngRef);
    % difference to the initial dry state
    ImageShow(dryIm,'initial dry');
    ImageShow(inIm,'initial input');

    imDif0=imsubtract(inIm,dryIm);
    [imDif,rngDif]=ImageAdjust(imDif0,0.1,0,0,[0.1,0.9]);
    ImageShow(imDif,'initial dif');
      
          
     
    pics=1:1:FCnt;

    ImShowFlag=max(pics)<FCnt;
    T=0;
    lastIm=dryIm;
    lastWater=zeros(size(dryIm));
    droped=0;
    droptime=0;
    ii=0;
    for i=pics
      disp(strcat('Analyse QNI  (',num2str(i),'/',num2str(FCnt),')  F=',FList(i).name));
      % read next image
      inIm0=imread(FList(i).fullname);
      inIm=double(inIm0);
      inIm=ImageAdjust(inIm,rngRef);
      ImageShow(inIm,'input');
      % difference to the initial dry state
      imDif=imsubtract(inIm,dryIm);
      imDif=imDif.*mask;
      imDif=ImageAdjust(imDif,rngDif);
      ImageShow(imDif,'dif');
     
      %bwMet='chan';
     %% BW1
     if 1
        imBW=ChanVeseBW(imDif,1);  
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
      %% BW2
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
      
     
       
      
      % write differetial image 
      fn=strcat(OutDif,'\',FList(i).name);
      imWriteTif(imDif,fn);
      
      
    
      ii=ii+1;
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
        Mass(ii)=Gray(ii).*max(rngRef);
      end  
      BWstack{ii}=water;
     
    end
 

