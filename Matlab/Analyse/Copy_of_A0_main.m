  

 %{
***************************************************************************
  Functions:
    Analyse makes black and white images with time stamp 
    and stores the result in a matlab  cell arry 
  
  Notes:
    Choose RAWDATA path
    Check options for running 
    xxxx
 
  Dodo:
    give better names  :: Rename Analyse to ...
    Analyse QNI and AnalyseHS shoude bothe find the stone first
    and new also the SurfaceLine as Vector
    makefunction Vector To image and line on image to Vector
    do calculations in seperate file
    
 *************************************************************************
 %}
 
  %% INIT
    clear;
    A1_Init; % clears all the old variavles form memory and closes open graphe
    global ProgDir ResDir ImShowFlag % global varibles for later use
    global option;
    ImShowFlag=1;
    
    RAWDATA='C:\Users\lej\Desktop\Jaebong_PSI_20122511\P12101\raw_data'; 
    RAWDATA='T:\Jaebong_PSI_20122511\P12101\raw_data'; 
    
    %SampleDir='Meule\RH11_V1\3';  % 25.1
    %SampleDir='Meule\RH50_V1\7';  % 25.1
    %SampleDir='\Meule\RH11_V1\3';  % 25.1
    
    SampleDir='\Meule\RH50_V1\7';  
    %SampleDir='\Meule\RH50_V3\11'; 
    %SampleDir='\Pietra\RH50_V1\7'; 
    %SampleDir='\Savonniers\RH50_V1\7'; 
    
    
    SampleDir=strcat(RAWDATA,SampleDir);

    
    
    %{ 
    % Test for fits
      I=ImReadFits(strcat(SampleDir,'\Qni\S7_0000.fits'));
      ImageShow(I,'x',[],1)
      ImWriteFits(strcat(SampleDir,'\im.fits'),I);
      Ii=ImReadFits(strcat(SampleDir,'\im.fits'));
      ImageShow(Ii,'x',[],1)
    %}

    

  %% Get Sample Dir and set Path
    %Iname=ChooseDirFile(strcat(imDir,'*.*'),[],'Input Image');
    %SampleDir=ChooseDirFile(WorkDir,1,'choose working directory');

  %% outputpath
    ResDir=strcat(SampleDir,'\Results');
    mkdir(ResDir);
    
    
  %% Sample
    [pathstr, Sample] = fileparts(SampleDir); 
    
    
  %% Options    
     ImShowFlag=0;
     option.test=1;  
     option.chooseROI=0;
     option.AnalyseAll=0;  
     option.Init=0;
     %AVI ScreanShot
     option.useAVI=0;
     option.AnalyseAVI=0;   %BW
     option.AnalyseSS=0; 
     option.AviContour=0;
     %QNI
     option.useQNI=1;
     option.AnalyseQni=0;
     option.QniContour=0;
     option.QniShape=1;
     option.QniWaterMass=0;      % water mass
     option.QniWaterMassSaveToExcel=1;
     option.QniWaterMassPlot =1;
     %Highspeed
     option.useHS=0;
     option.AnalyseHS=0; 
     option.HSVolume=0;
     option.HSShape=0;
     %others
     option.SampleDir=SampleDir;
     option.ResDir=ResDir;
     option.createxls=0;
     % option.fnxls=see below;
    

   %%----------------------------------------------------------------------------------------------------------------
   % INIT  
   %----------------------------------------------------------------------------------------------------------------

     
    %% prepare the excelsheet for outputs
     xlsFile=strcat('Results_',Sample,'.xls');
     fnxls=strcat(SampleDir, '\',xlsFile);
     if option.createxls
       display('create XLS');
       sourcexls=strcat(ProgDir,'\Templates\Results.xls');
       try
         copyfile(sourcexls,fnxls);
       catch ME
         ME
         msgbox('Error Excle sheet is open please close befor running the code');
         return;
       end
     end
     display('check XLS');
     option.fnxls=fnxls;
     Tabn='RES';
     ra='A1';
     data={'Results'};
     %write the to excel 
     try
       xlswrite(fnxls, data, Tabn,ra);
     catch ME
       ME
       msgbox('Error Excle sheet is open please close befor running the code');
       return;
     end
     
     
   %%----------------------------------------------------------------------------------------------------------------
   % Time  
   %----------------------------------------------------------------------------------------------------------------
     
     %% Evaluate the timestamp from AviFile and QNI and HS-camera files
     % check the avifile for the time stamp
     % Cnt should be 1
     fn=strcat(ResDir, '\Init.mat');
     if ~exist(fn,'file') ||option.Init || option.AnalyseAll
       % avi frame rate offset
       disp('Init time stamp for Avi and QNI');
       [AviFile,cnt]=GetFiles(strcat(SampleDir ,'\AVI'),'*.avi');
       AviTime=(AviFile(1).datenum)*24*3600;
       sec2=AviTime-(floor(AviTime/60)*60); %sec from the lastpicture
       nm=AviFile(1).filename;
       l=length(nm);
       sec1=nm(l-1:l); %sec1 = trigger time
       sec1=str2num(sec1);    % sec from the drop
       td=sec2-sec1;        % td is the time when image has drop on avi
       if td<0,td=td+60;end;  % time from drop to last pic
       [AviFile,cnt]=GetFiles(strcat(SampleDir ,'\AVI'),'*.Tif');
       td2=td;                     % time after drop
       AviFrameRate=(cnt-30)/td2;  % frame rate
       td1=30/AviFrameRate;        % time before drop
       StartTime=AviTime-td2;      % drop time
       AviOffset=-td1;             % offset from the first pic  

       % Qni frame rate offset
       [QniFile,cnt]=GetFiles(strcat(SampleDir,'' ),strcat(Sample,'.fits'));
       EndTime=(QniFile(1).datenum)*24*3600;
       td=EndTime-StartTime;
       [QniFile,cnt]=GetFiles(strcat(SampleDir,'\QNI'),strcat('S',Sample,'_*.fits'));
       QniFrameRate=(cnt-10)/td;  %pics/sec    firts 10 pics are Refpic if case has less than 10 pic for ref. please change digit
       
       %HS frameRate
       HSStartTime=0;
       HSFrameRate=100; %pics/sec
     
       if ~option.test ,save(fn,'StartTime','AviFrameRate','AviOffset','QniFrameRate','HSStartTime','HSFrameRate');end;
     
     else 
       disp('load time stamp for Avi and QNI');
       load(fn);
       HSStartTime=0;
       HSFrameRate=100; %pics/sec
     end   
   
     
   %%----------------------------------------------------------------------------------------------------------------
   % AVI  
   %----------------------------------------------------------------------------------------------------------------
   if option.useAVI
     
    
   %% analyse AVI and Screen Shots SS
     BW1=[];BW2=[];
     fn=strcat(ResDir, '\AVI.mat');
     if ~exist(fn,'file') || option.AnalyseAVI || option.AnalyseAll
        disp('analyse AVI ');
        [Time1,Area1,Gray1,BW1]=AnalyseAvi(SampleDir,AviOffset,AviFrameRate,option);
        AviCnt=length(Time1);
        save(fn,'AviCnt','Time1','Area1','Gray1','BW1');
     else   
        disp('load AVI results');
        load(fn);
     end   
     fn=strcat(ResDir, '\SS.mat');
     if ~exist(fn,'file') || option.AnalyseSS || option.AnalyseAll 
        disp('analyse screen shots');
        [Time2,Area2,Gray2,BW2]=AnalyseSS(SampleDir,StartTime,option);
        SSCnt=length(Time2);
        save(fn,'SSCnt','Time2','Area2','Gray2','BW2');
     else 
        disp('load screen shot results');
        load(fn);
     end   
     
   %% plot AviContour
     fig=[];
     if  option.AviContour || option.AnalyseAll 
       timesteps=[0,2,4,10,20,40,9999];
       Cts=length(timesteps);
       disp(strcat('Avi Contours ', num2str(Cts),'   '));
       ts=1;
       for i=1:AviCnt
         if Time1(i)>timesteps(ts) 
           nm=strcat('t=',num2str(timesteps(ts)));
           fig=plotContour(BW1{i},fig,nm,ts);
           if ts<Cts,ts=ts+1;end;
         end  
       end
       for i=1:SSCnt
         if Time2(i)>timesteps(ts) 
           nm=strcat('t=',num2str(timesteps(ts)));
           fig=plotContour(BW2{i},fig,nm,ts);
           if ts<Cts,ts=ts+1;end;
         end  
       end
       figure(fig);
       legend('show');
       haxes=get(fig,'CurrentAxes');
       set(haxes,'DataAspectRatioMode','manual');
       fn=strcat(ResDir,'\AviCountour.fig');
       saveas(fig,fn);
     end
     BW1=[];BW2=[];
   end 
   
   
   
   
   
   %%----------------------------------------------------------------------------------------------------------------
   % QNI  
   %----------------------------------------------------------------------------------------------------------------
   if option.useQNI
   
     %% analyse QNI files calcualtet from neutra Images
     fn=strcat(ResDir, '\Qni.mat');
     if  ~exist(fn,'file') ||option.AnalyseQni || option.AnalyseAll
        disp('anayse QNI images');
        FristTime=1/QniFrameRate/2+.5; % time for the first pic
        option.QniDryOnly=0;
        [Time3,Area3,WaterMassSum,dryIm,Stone,BW,WaterMass]=AnalyseQNI(SampleDir,FristTime,QniFrameRate,option);
        QniCnt=length(Time3);
        if ~option.test ,save(fn,'QniCnt','Time3','Area3','WaterMassSum','dryIm','Stone','BW','WaterMass');end;
     else   
        disp('load QNI results');
        dryIm=[];
        load(fn);
        if isempty(dryIm)
          try WaterMassSum=WaterMass;end;
          try WaterMass=WaterContent;end
          option.QniDryOnly=1;
          [d1,d2,d3,dryIm,Stone,d4,d5]=AnalyseQNI(SampleDir,0,0,option);
          
        end
     end   
       
     %% plot Qni Countour  of water for specific times
     fig=[];
     if  option.QniContour || option.AnalyseAll 
       timesteps=[0,2,4,10,20,40,9999]; %secs
       Cts=length(timesteps);
       disp(strcat('QNI Contours ', num2str(Cts),'   '));
       fig=plotContour(Stone,fig,'Stone',1,2);
       ts=1;
       for i=1:QniCnt
         if Time3(i)>timesteps(ts) 
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
     

     %% analyse shape and get surface form Qnipicturs and plot QniShape
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
           [w1,w2,fig]=AnalyseShapeQNI(BW{i},fig,surf);
           fign=strcat(ResDir,'\QniShape',nm,'.fig');
           saveas(fig,fign);
           close(fig);
           if ts<Cts,ts=ts+1;end;
         end  
       end
       if ~option.test ,save(fn,'H','L','xmin','xmax','surf','w1','w2');end
     else   
       load(fn);
     end
     

    %%Geomety
     pixsize=45.5*1E-6;
     thickness=10*1E-3;
     Vol=pixsize*pixsize*thickness;

     
     
    %% QNI Water Mass 
     fn=strcat(ResDir, '\QniWaterMass.mat');
     if  option.QniWaterMass || option.AnalyseAll 
       Cts=length(timesteps);
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
       if option.test,list=[15,20,50];end;
       for i=list
         if WaterMassSum(i)>0 || i<13
           %% Calc water content
           WaterMask=BW{i};
           Mass=WaterMass{i};
           Neg=Mass<0;
           %Mass(Neg)=0; %set all negative value to 0
           [y,x]=size(Mass);
           ROImask=zeros(y,x);
           w=220;h=160;cx=round(size(Mass,2)/2);cy=110;
           ROImask(cy-h/2:cy+h/2,cx-w/2:cx+w/2)=1;
           MassKgm3=Mass/Vol/1000;
          
           % Moister Content in ROI area
           MoisterContent=MassKgm3.*ROImask;
   
           %masks for calculation of WaterMass
           Water1=bwmorph(WaterMask,'dilate',5);
           Water2=bwmorph(WaterMask,'dilate',10);
           Water3=bwmorph(WaterMask,'dilate',15);
           Water4=bwmorph(WaterMask,'dilate',20);
           Water5=bwmorph(WaterMask,'dilate',30);
           Stone_2=bwmorph(Stone,'erode',2);
           Stone_1=bwmorph(Stone,'erode',1);
           Stone1=bwmorph(Stone,'dilate',1);
           Stone2=bwmorph(Stone,'dilate',2);
           %WaterMass
           WaMass=Mass;
           MassROI(i)=sum(sum(WaMass.*ROImask)); % just the ROI part of 
           MassW(i)=sum(sum(WaMass.*WaterMask)); % just count the mass where water
           MassW1(i)=sum(sum(WaMass.*Water1));   % just count the mass where water + a border of 5 pixel was dedected
           MassW2(i)=sum(sum(WaMass.*Water2));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           MassW3(i)=sum(sum(WaMass.*Water3));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           MassW4(i)=sum(sum(WaMass.*Water4));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           MassW5(i)=sum(sum(WaMass.*Water5));   % just count the mass where water + a border of 10 pixel  was dedected by threshold
           WaMass=Mass.*Water5;                   % Water and the border of 10 pixel
           MassS(i)=sum(sum(WaMass.*Stone));      % from that just the stone 
           MassS_2(i)=sum(sum(WaMass.*Stone_2));  % from that just the stone decreased by 2 pixel
           MassS_1(i)=sum(sum(WaMass.*Stone_1));  % from that just the stone decreased by 2 pixel
           MassS1(i)=sum(sum(WaMass.*Stone1));    % from that just the stone increased by 1 pixel
           MassS2(i)=sum(sum(WaMass.*Stone2));    % from that just the stone increased by 2 pixel
         end
       end
       if ~option.test ,save(fn,'Time3','MassROI','MassW','MassW1','MassW2','MassW3','MassW4','MassW5','MassS','MassS_2','MassS_1','MassS1','MassS2');end
     else
       load(fn)       
     end
          
     if option.QniWaterMassSaveToExcel
        fnxls=option.fnxls;
        Tabn='WaterMass';
        ra='A1';
        data={'WaterMass',1};
        data=datains(data,{''},1);
        data=datains(data,{'time','MassROI','MassW','MassW1','MassW2','MassW3','MassW4','MassW5','MassS_2','MassS_1','MassS','MassS1','MassS2'},1);
        data=datains(data, {Time3,MassROI,MassW,MassW1,MassW2,MassW3,MassW4,MassW5,MassS_2,MassS_1,MassS,MassS1,MassS2},1);
        %write the to excel 
        xlswrite(fnxls, data, Tabn,ra);
     end   
     
     if  option.QniWaterMassPlot 
       fig=figure;fig2=figure;
       mov=[];mov2=[];
       ImShowFlag=1;
       timesteps=[5,30,60,120,180,9999];%secs
       doAll=true;
       ts=1;
       list=1:QniCnt;
       if option.test,list=[15,20,50];end;
       for i=list
          if Time3(i)>timesteps(ts) || doAll
             nm=strcat('t = ', num2str(Time3(i)),' [sec]'); %round(Time3(i))
             Mass=WaterMass{i};
             MassKgm3=Mass/Vol/1000;
            %Penetration
             [x,y]=size(Mass);
             w=22;h=y;cx=X0;cy=y/2;
             Plotcrop=Mass(cy-h/2+1:cy+h/2,cx-w/2:cx+w/2);
             PlotMass=sum(Plotcrop,2);
             PlotMC=PlotMass/Vol/1000;
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
             SaveFig(fig);

             figure(fig2);
             hold on
               sy=size(PlotMass,1);
               sx=5e-3;
               yaxis=1:1:sy;
               PlotMass=PlotMass*1000;
               yaxis=(yaxis-Ysurf)*-pixsize*1000;
               plot(PlotMass, yaxis,'b');
               plot([0,0],[-20,5],'r','LineWidth',1); %Vertical
               plot([-0-005,0.05],[0,0],'r','LineWidth',1); %horizontal
               tit=strcat('WM:',num2str(i) ,'[mg]  time:',num2str(Time3(i)),'[min]'  );
               title(tit, 'FontSize', 10);
               xlabel('water [mg]');
               xlim([-0.005,0.05]);
               ylabel('hight [mm]');
               ylim([-20,5]);

             hold off
             mov2=ImAddToMovie( mov2,fig2 );
             
             if ts<Cts,ts=ts+1;end;
          end  
       end
       close(fig);close(fig2);
       save(fn,'WCarea','WCmass');
       fn=strcat('Watercontent.avi');
       ImWriteAvi( fn,mov);
       ImWriteAvi( fn,mov2);
     end     
     
   %% QniContoure profile in hight
  
  
     
     
 
   end  

   %%----------------------------------------------------------------------------------------------------------------
   % HS Camera  
   %----------------------------------------------------------------------------------------------------------------
   
  
   
   
  %% HS  Highspeed Camera
  if option.useHS
     BW=[];
     fn=strcat(ResDir, '\HS.mat');
     if option.AnalyseHS || option.AnalyseAll
         if  ~exist(fn,'file')
             if exist(fn,'file')
                 load(fn,'ROI');
             else
                 ROI=[];
             end
             FristTime=HSStartTime; % time for the first pic
             [Time4,Area4,Gray4,BW,StoneHS,ROI]=AnalyseHS(SampleDir,FristTime,HSFrameRate,ROI,option);
             HSCnt=length(Time3);
             if ~option.test ,save(fn,'HSCnt','Time3','Area3','Gray3','BW','StoneHS','ROI');end
         else
             load(fn);
         end
     end
     
       
  %% HSVolume
     fig=[];
     if  option.HSVolume || option.AnalyseAll 
       timesteps=[0,2,4,10,20,40,9999]; %secs
       Cts=length(timesteps);
       disp(strcat('HS Contours ', num2str(Cts),'   '));
       fig=plotContour(StoneHS,fig,'Stone',1,2);
       ts=1;
       for i=1:HSCnt
         if Time3(i)>timesteps(ts) 
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
       fn=strcat(ResDir,'\HSCountour.fig');
       saveas(fig,fn);
     end

  %% HSShape
     fig=[];
     ImShowFlag=1;
     if  option.HSShape || option.AnalyseAll 
 
       timesteps=[0,2,4,10,20,40,9999];
       Cts=length(timesteps);
       disp(strcat('HS Shape ', num2str(Cts),'   '));

       %find surface stone
       [sy,sx]=size(Stone);
       fig=ImageShow(Stone);
       [R, B ] = FindShape2(Stone,fig );
       [ymin,ymax,xmin,xmax,V] = FindCurve(B,fig,0);
       ind=find(V(:,2)>100);
       V=V(ind,:);
       ind=find(V(:,2)<sx-100);
       V=V(ind,:);
       surf=V(:,1) ;
       Ysurf=mean(surf);
       hold on
       plot(V(:,2),V(:,1),'r','LineWidth',2);
       hold off
       close(fig);
       
       %fit curve to HS shape
       ts=1;
       for i=1:HSCnt
         if Time3(i)>timesteps(ts) 
           nm=strcat('t=',num2str(timesteps(ts)));
           nm=strcat('t=',num2str(round(Time3(i))));
           [w1,w2,fig]=AnalyseShapeHS(BW{i});
           hold on
             plot(B(:,2),B(:,1),'y','LineWidth',1);
           hold off
           fn=strcat(ResDir,'\HSShape',nm,'.fig');
           saveas(fig,fn);
           close(fig);
           if ts<Cts,ts=ts+1;end;
         end  
       end
     end
     BW=[];    
  end  
     
     
     
   %% save Results     
         
        Tabn='Drop';
        disp(strcat('Store in excel :', fnxls,'   T=',Tabn));
        row=4;
        ce=strcat('A',num2str(row));
        % location on the sheet header
        data={};
        data=datains(data,{'AVi','','','ScreenShot','','','Qni','',''},1);
        data=datains(data,{'time','area [mm2]','gray','time','area [mm2]','gray','time','area [mm2]','WaterMass'},1);
        data=datains(data,{Time1,Area1,Gray1,Time2,Area2,Gray2,Time3,WCarea,WCmass},1);
        %write the to excel
        xlswrite(fnxls, data, Tabn,ce);
        

   %% 
 
     m=msgbox('done','Press OK');
     uiwait(m);