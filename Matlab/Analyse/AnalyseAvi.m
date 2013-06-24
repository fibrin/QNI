function [ Time,Area ,Gray,BWstack] = AnalyseAvi(SampleDir,StartTime,framerate,option )
   
    if nargin<1, A0_main;return;end;
    test=0;
    try
      test=option.test;
    catch
    end

    global ImShowFlag
     
 %%  set path
     AviDir=strcat(SampleDir,'\','Avi');
     AviOutBw=strcat(AviDir,'\','bw');
     AviOutRgb=strcat(AviDir,'\','rgb');
   
     % create output Directory     
     mkdir(AviOutBw);
     mkdir(AviOutRgb);
     
        
 %% get Imagefiles
    [AviList,AviCnt]=GetFiles(AviDir,'*.TIF');
     
    % read the first 5 pictures todo a reference dry picture
    inIm0=imReadMean(AviDir,'*.TIF',5);
    [inIm,rng]=ImageAdjust(inIm0);
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
    if maxP<AviCnt,maxP=AviCnt;end;
    Time=zeros(maxP,1);
    Area=zeros(maxP,1);
    Gray=zeros(maxP,1);
    BWstack{maxP}=[];
    [sy,sx]=size(dryIm);
    mask=zeros(size(dryIm));
    mask(50:sy-50,10:sx-10)=1;
  
    pics=1:1:AviCnt;
    if test
       pics=[10,11,AviCnt-3];
    end   
    ImShowFlag=max(pics)<AviCnt;
    DropTime=0;
    T=StartTime;
    lastIm=dryIm;
    lastWater=zeros(size(dryIm));
    ii=pics(1);
    for i=pics
      disp(strcat('Analyse Avi  (',num2str(i),'/',num2str(AviCnt),')   F=',AviList(i).name));
      % read next image
      inIm=imReadDbl(AviList(i).fullname);
      inIm = imtransform(inIm,TrStrct,'FillValues', 0,'XData', [1 200],'YData', [1 400]);
      inIm=ImageAdjust(inIm,rng);
      inIm0=inIm;
      ImageShow(inIm,'input');
      
      % diference to the initial dry state
      imDif=imsubtract(dryIm,inIm);
      imDif=imDif.*mask;
      [imD,r2]=ImageAdjust(imDif);
      imDif=imDif*2.0;
      imDif(imDif>1)=1;
      imDif(imDif<0)=0;
      ImageShow(imDif,'dif');
      % filter (not used)
      H=fspecial('disk',2);
      imFlt=imfilter(imDif,H);
      imFlt=imDif; %filter not used
      ImageShow(imFlt,'filter');
      % threshold and morphological operations to do BW
      % could be replaced with better function
      th1=graythresh(imFlt)*1.1;
      th=max ([th1 0.1]);
      imBW=imFlt>th;
      ImageShow(imBW,'threshold');
      imBW=bwareaopen(imBW,40);  % remove small areas
      SE=strel('disk',2);        % make the border mor smooth
      imBW=imclose(imBW,SE);      
      imBW=imfill(imBW,'holes'); % fill the holes  
      ImageShow(imBW,'water');   % show
      water=imBW;
      
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
      imRGB=inIm0;
      imRGB=ImageSetCol(imRGB,inIm0,[255*0.2,0,0],0,water); %red
      imRGB=ImageSetCol(imRGB,inIm0,[0,255*0.2,0],0,more); %green
      imRGB=ImageSetCol(imRGB,inIm0,[0,0,255*.2],0,less); %blue
      ImageShow(imRGB,'rgb');
      fn=strcat(AviOutRgb,'\',AviList(i).name);
      imwrite(imRGB,fn);
      fn=strcat(AviOutBw,'\',AviList(i).name);
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
        a=a0/20/20;  %200pix=10mm
        Area(ii)=a;
        imGr=imDif.*water;
        a0=1;
        Gray(ii)=sum(sum(imGr))/a0;
        if DropTime==0,DropTime=T;end;
      end  
      BWstack{ii}=water;
     
    end
    Time(AviCnt:maxP)=T;
    if test
      m=msgbox('Avi done');
      uiwait(m);
    end

end

