% Stefan

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
    A1_Init; % clears all the old variavles form memory and closes open graphe
    global ProgDir ResDir ImShowFlag % global varibles for later use
    
    RAWDATA='C:\Users\lej\Desktop\Jaebong_PSI_20122511\P12101\raw_data'; 
   
    %SampleDir='Meule\RH11_V1\3';  % 25.1
    %SampleDir='Meule\RH50_V1\7';  % 25.1
    SampleDir='\Meule\RH50_V1\7';  % 25.1
    
    SampleDir=strcat(RAWDATA,SampleDir);
 

  %% Get Sample Dir and set Path
    %Iname=ChooseDirFile(strcat(imDir,'*.*'),[],'Input Image');
    %SampleDir=ChooseDirFile(WorkDir,1,'choose working directory');

  %% outputpath
    ResDir=strcat(SampleDir,'\Results');
    mkdir(ResDir);
    
    
  %% Sample
    [pathstr, Sample] = fileparts(SampleDir); 
    
    
  %% Options    
     ImShowFlag=1;
     option.test=0;  
     option.chooseROI=0;
     option.AnalyseAll=0;  
     option.Init=0;
     %AVI ScreanShot
     option.AnalyseAVI=0;   %BW
     option.AnalyseSS=0; 
     option.AviContour=0;
     %QNI
     option.AnalyseQni=0;
     option.QniContour=0;
     option.QniShape=0;
     option.QniWaterContent=1;
     %Highspeed
     option.AnalyseHS=0; 
     option.HSVolume=0;
     option.HSShape=0;
     %others
     option.SampleDir=SampleDir;
     option.ResDir=ResDir;
     option.createxls=1;
    
    
  %% prepare the excelsheet for outputs
     if option.createxls
       sourcexls=strcat(ProgDir,'\Templates\Results.xls');
       xlsFile=strcat('Results_',Sample,'.xls');
       fnxls=strcat(SampleDir, '\',xlsFile);
       try
         copyfile(sourcexls,fnxls);
       catch ME
         ME
         msgbox('Error Excle sheet is open please close befor running the code');
         return;
       end
     end
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
     
   %% Evaluate the timestamp from AviFile
     % check the avifile for the time stamp
     % Cnt should be 1
     fn=strcat(ResDir, '\Init.mat');
     if ~exist(fn,'file') ||option.Init || option.AnalyseAll
       % avi frame rate offset
       [AviFile,cnt]=GetFiles(strcat(SampleDir ,'\AVI'),'*.avi');
       AviTime=(AviFile(1).datenum)*24*3600;
       sec2=AviTime-(floor(AviTime/60)*60); %sec from the lastpicture
       nm=AviFile(1).filename;
       l=length(nm);
       sec1=nm(l-1:l);
       sec1=str2num(sec1);    % sec from the drop
       td=sec2-sec1;
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
       QniFrameRate=(cnt-10)/td;  %pics/sec    firts 10 pics are Refpic
       
       %HS frameRate
       HSStartTime=0;
       HSFrameRate=100; %pics/sec
     
       save(fn,'StartTime','AviFrameRate','AviOffset','QniFrameRate','HSStartTime','HSFrameRate');
     
     else   
       load(fn);
       HSStartTime=0;
       HSFrameRate=100; %pics/sec
     end   
     
    
   %% analyse AVI and SS
     BW1=[];BW2=[];
     fn=strcat(ResDir, '\AVI.mat');
     if ~exist(fn,'file') || option.AnalyseAVI || option.AnalyseAll 
        [Time1,Area1,Gray1,BW1]=AnalyseAvi(SampleDir,AviOffset,AviFrameRate,option);
        AviCnt=length(Time1);
        save(fn,'AviCnt','Time1','Area1','Gray1','BW1');
     else   
        load(fn);
     end   
     fn=strcat(ResDir, '\SS.mat');
     if ~exist(fn,'file') || option.AnalyseSS || option.AnalyseAll 
        [Time2,Area2,Gray2,BW2]=AnalyseSS(SampleDir,StartTime,option);
        SSCnt=length(Time2);
        save(fn,'SSCnt','Time2','Area2','Gray2','BW2');
     else   
        load(fn);
     end   
     
   %% AviContour
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
    
     
     
   %% QNI
     BW=[];
     fn=strcat(ResDir, '\Qni.mat');
     if  ~exist(fn,'file') ||option.AnalyseQni || option.AnalyseAll
        FristTime=1/QniFrameRate/2+.5; % time for the first pic
        [Time3,Area3,WaterMass,BW,Stone,WaterContent]=AnalyseQNI(SampleDir,FristTime,QniFrameRate,option);
        QniCnt=length(Time3);
        save(fn,'QniCnt','Time3','Area3','WaterMass','BW','Stone','WaterContent');
     else   
        load(fn);
     end   
       
  %% QniCountour
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
       fn=strcat(ResDir,'\QniCountour.fig');
       saveas(fig,fn);
     end

  %% QniShape
     fig=[];
     ImShowFlag=1;
     if  option.QniShape || option.AnalyseAll 

       timesteps=[0,2,4,10,20,40,9999];%secs
       Cts=length(timesteps);
       disp(strcat('QNI Shape ', num2str(Cts),'   '));

       %find surface stone
       [sy,sx]=size(Stone);
       fig=ImageShow(Stone);
       [R, B ] = FindShape2(Stone,fig );
       [ H,L,xmin,xmax,V] = FindTangent(B,fig,0);
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
       
       %fit curve to QNI shape
       ts=1;
       for i=1:QniCnt
         if Time3(i)>timesteps(ts) 
           nm=strcat('t=',num2str(timesteps(ts)));
           nm=strcat('t=',num2str(round(Time3(i))));
           [w1,w2,fig]=AnalyseShapeQNI(BW{i});
           hold on
             plot(B(:,2),B(:,1),'y','LineWidth',1);
           hold off
           fn=strcat(ResDir,'\QniShape',nm,'.fig');
           saveas(fig,fn);
           close(fig);
           if ts<Cts,ts=ts+1;end;
         end  
       end
     end
     
     
  %% QNI Water Content
     fig=[];
     mov=[];
     ImShowFlag=1;
     fn=strcat(ResDir, '\QniWC.mat');
     if  option.QniWaterContent || option.AnalyseAll 
       timesteps=[5,30,60,120,180,9999];%secs
       doAll=true;
       Cts=length(timesteps);
       disp(strcat('QNI Water Content ', num2str(Cts),'   '));
       WCarea=zeros(QniCnt,1);
       WCmass=zeros(QniCnt,1);
       ts=1;
       for i=1:QniCnt
         if WaterMass(i)>0 || i<13
          if Time3(i)>timesteps(ts) || doAll
           nm=strcat('t=',num2str(round(Time3(i))));
           %% Calc water content
           water=BW{i};
           Mass=WaterContent{i};
           ROImask=zeros(size(Mass)); 
           w=220;h=160;cx=round(size(Mass,2)/2);cy=110;
           ROImask(cy-h/2:cy+h/2,cx-w/2:cx+w/2)=1;
           pixsize=45.5*1E-6;
           thickness=10*1E-3;
           Vol=pixsize*pixsize*thickness;
           MassKgm3=Mass/Vol/1000;
           MassW=sum(sum(Mass.*water)); % just count the mass where water was dedected by threshold
           MassROI=sum(sum(Mass.*ROImask)); % just count the mass where water was dedected by threshold
           MassKgm3W=sum(sum(MassKgm3.*water))/sum(sum(water));
           WCarea(i)=sum(sum(water))*pixsize*pixsize*100*100 ;%cm2
           WCmass(i)=MassROI;
           % WC=MassKgm3.*water;
           WC=MassKgm3;
           crop=WC(cy-h/2:cy+h/2,cx-w/2:cx+w/2);
           f=figure;
           imshow(crop);
           colormap(jet(20));
           %colormap(gray(10));
           caxis([0 250]);
           h = colorbar('vertical'); 
           set(f,'Position',[300 300 1000 700 ]); %left,buttom,width,height
           set(f,'name',strcat('WC ',nm));
           mov=ImAddToMovie( mov,f );
           %SaveFig(f);
           close(f);
           if ts<Cts,ts=ts+1;end;
          end  
         end
       end 
       save(fn,'WCarea','WCmass');
       fn=strcat('Watercontent.avi');
       ImWriteAvi( fn,mov);
     else
       load(fn)       
     end
     
  %% QniContoure profile in hight
  
  
     
     
 
    
  
  %% HS  Highspeed Camera
     BW=[];
     fn=strcat(ResDir, '\HS.mat');
     if  ~exist(fn,'file') ||option.AnalyseHS || option.AnalyseAll
        if exist(fn,'file') 
           load(fn,'ROI');
        else
           ROI=[];
        end   
        FristTime=HSStartTime; % time for the first pic
        [Time4,Area4,Gray4,BW,StoneHS,ROI]=AnalyseHS(SampleDir,FristTime,HSFrameRate,ROI,option);
        HSCnt=length(Time3);
        save(fn,'HSCnt','Time3','Area3','Gray3','BW','StoneHS','ROI');
     else   
        load(fn);
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
       [ H,L,xmin,xmax,V] = FindTangent(B,fig,0);
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