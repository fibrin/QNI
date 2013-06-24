function [ Time,Area ,Gray,BWstack ] = AnalyseSS(SampleDir,StartTime,option )
    if nargin<1, A0_main;return;end;
    test=0;
    try
      test=option.test;
    catch
    end

    global ImShowFlag
     
 %%  set path
     SSDir=strcat(SampleDir,'\','SS');
     SSOutRgb=strcat(SSDir,'\','rgb');
     SSOutBw=strcat(SSDir,'\','bw');
    % create output Directory     
     mkdir(SSOutRgb);
     mkdir(SSOutBw);
     
 %% get Imagefiles
    [SSList,SSCnt]=GetFiles(SSDir,'*.TIF');
    [TimeList,TimeCnt]=GetFiles(SSDir,'*.Jpg');
    
    if ~(SSCnt==TimeCnt) 
      msgbox(' not the same number of files');
      exit;
    end
      
     
    % read the first 5 pictures todo a reference dry picture
    inIm=imReadMean(SSDir,'*.TIF',5);
    [inIm,rng]=ImageAdjust(inIm);
    ImageShow(inIm,'Drop Ref');
    
    % transformation to correct the camera angle 
    inpts= [1 1;220 1; 20 320 ;200 320];
    refpts=[1 1;200 1; 1 400 ;200 400]; 
    refIm=zeros(400,200);
    refIm=ImBorderSet(refIm,2,1);
    %cpselect(inIm,refIm,inpts,refpts);
    
    TrStrct = cp2tform(inpts,refpts,'projective');
    %save TransfStructure.mat TransfStructure
    regpts=tformfwd(TrStrct,inpts);
    dryIm = imtransform(inIm,TrStrct,'FillValues', 0,'XData', [1 200],'YData', [1 400]);
    ImageShow(dryIm,'transformed dryIm  1cm x 2cm');
    
    maxP=500;
    if maxP<SSCnt,maxP=SSCnt;end;
    Time=zeros(maxP,1);
    Area=zeros(maxP,1);
    Gray=zeros(maxP,1);
    BWstack{maxP}=[];
    [sy,sx]=size(dryIm);
    mask=zeros(size(dryIm));
    mask(50:sy-50,10:sx-10)=1;

    
    pics=1:1:SSCnt;
    if test
       pics=[10,11,SSCnt-3];
    end   
    ImShowFlag=max(pics)<SSCnt;
   
    T=0;
    lastIm=dryIm;
    lastWater=zeros(size(dryIm));
    droped=0;
    ii=0;
    for i=pics
      disp(strcat('Analyse SS  (',num2str(i),'/',num2str(SSCnt),')  F=',SSList(i).name));
      % read next image
      inIm=imReadDbl(SSList(i).fullname);
      inIm = imtransform(inIm,TrStrct,'FillValues', 0,'XData', [1 200],'YData', [1 400]);
      inIm=ImageAdjust(inIm,rng);
      inIm0=inIm;
      ImageShow(inIm,'input');
      % difference to the initial dry state
      imDif=imsubtract(dryIm,inIm);
      imDif=imDif.*mask;
      [imD,r2]=ImageAdjust(imDif);
      imDif=imDif*2.0;
      imDif(imDif>1)=1;
      imDif(imDif<0)=0;
      ImageShow(imDif,'dif');
      % filter 
      H=fspecial('disk',3);
      imFlt=imfilter(imDif,H)*2;
      %imFlt=imDif; %filter not used
      ImageShow(imFlt,'filter');
      % threshold and morphological operations to do BW
      % could be replaced with better function
      th1=graythresh(imFlt)*1.1;
      th=max ([th1 0.1]);
      imBW=imFlt>th;
      ImageShow(imBW,'threshold');
      imBW=bwareaopen(imBW,40);  % remove small areas
      SE=strel('disk',4);        % make the border mor smooth
      imBW=imclose(imBW,SE);      
      imBW=imfill(imBW,'holes'); % fill the holes  
      ImageShow(imBW,'water');   % show
      water=imBW;
      
      % difference to the last water
      waterDif=imsubtract(double(water),double(lastWater));
      more=waterDif>0;
      less=waterDif<0;
      
      if 0
        % difference to the LastImage
        imDif=imsubtract(lastIm,inIm);
        [imD,r2]=ImageAdjust(imDif);
        imDif=imDif*2.0;
        ImageShow(imDif,'dif');
        % filter (not used)
        H=fspecial('disk',2);
        imFlt=imfilter(imDif,H);
        ImageShow(imFlt,'filter');
        % threshold and morphological operations to do BW
        % could be replaced with better function
        th=0.1;
        imBW=imFlt>th;
        ImageShow(imBW,'threshold');
        %imBW=bwareaopen(imBW,40);  % remove small areas
        SE=strel('disk',2);        % make the border mor smooth
        imBW=imclose(imBW,SE);      
        imBW=imfill(imBW,'holes'); % fill the holes  
        ImageShow(imBW,'flt');   % show
        imBW=imBW.*water;
        more=imBW;
        more=imBW>lastWater;
        th=-th;
        imBW=imFlt<th;
        ImageShow(imBW,'threshold');
        %imBW=bwareaopen(imBW,40);  % remove small areas
        SE=strel('disk',2);        % make the border mor smooth
        imBW=imclose(imBW,SE);      
        imBW=imfill(imBW,'holes'); % fill the holes  
        ImageShow(imBW,'flt');   % show
        imBW=imBW.*lastWater;
        less=imBW;
      end
      
      ImageShow(more,'more');   % show
      ImageShow(less,'less');   % show
      
      lastIm=inIm;
      lastWater=water;

      % create RGB for visualisation
      imRGB=inIm0;
      imRGB=ImageSetCol(imRGB,inIm0,[255*0.2,0,0],0,water); %red
      imRGB=ImageSetCol(imRGB,inIm0,[0,255*0.2,0],0,more); %green
      imRGB=ImageSetCol(imRGB,inIm0,[0,0,255*.2],0,less); %blue
      ImageShow(imRGB,'rgb');
      fn=strcat(SSOutRgb,'\',SSList(i).name);
      imwrite(imRGB,fn);
      fn=strcat(SSOutBw,'\',SSList(i).name);
      imwrite(uint16(water*255),fn);

      
      ii=ii+1;
      % Timestamp
      T=TimeList(i).datenum*24*3600-StartTime;
      % Measure the water 
      RegP=regionprops(imBW,'Area');
      rCnt=length(RegP);
      if rCnt>0 
        if droped==0 
          droped=1;
          ii=ii+1;
        end;
        %go for all regions
        a0=0;am=0;rm=0;
        for r=1:rCnt
          a=RegP(r).Area;
          a0=a0+a;
          if a>am
            %index the bigest region
            am=a;ar=r;
          end
        end  
        a=a0/20/20;  %200pix=10mm
        Area(ii)=a;
        imGr=imDif.*water;
        a0=1;
        Gray(ii)=sum(sum(imGr))/a0;
        %if DropTime==0,DropTime=T;end;
      end  
      Time(ii)=T;
      BWstack{ii}=water;
    end
    Time(SSCnt:maxP)=T;

    
  

end

