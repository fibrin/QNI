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
  
    %read  Reference     Dry  8 images =>mean
    inIm0=imReadMean(QNIDir,'*.tif',8,1);
    [inIm,rngRef]=ImageAdjust(inIm0,2,0,0,[0,0.5]); %Qni is small double value
    ImageShow(inIm,'Drop Ref');
    
    dryIm=inIm;
    
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
    
    H=fspecial('disk',10);
        imFlt=imfilter(imDif,H);
        r=10;
        imFlt= medfilt2(imDif,[r r]);
    
        ImageShow(imFlt,'filter');
        
        th1=graythresh(imFlt)*1.2;
        th=max ([th1 0.24]);
        imTh=imFlt>th;
        ImageShow(imTh,'Th');
        
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
        ImageShow(water2,'water2 OTSU');
        water=water2;
        
      ii=0;  
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
        Mass(ii)=Gray(ii).*max(rngRef)
      end  
     



        
        
        

    