
    %% globals
    global WorkDir ResDir fnxls
    global ImShowFlag

    %% init
    A1_Init;

    %% working and Res path
    WorkDir='R:\Scratch\118\Guizzardi\PSI august 2012\20121003_frame 17 QNI\';
    QniDir=strcat(WorkDir,'QNI\');
    TimeDir=strcat(WorkDir,'original pictures\');
    ResDir=strcat(WorkDir,'RES\');
    vox=0.1; %mm/pix
    Thickness=17;  %mm
    VolPix=vox*vox*Thickness; % mm
    VolPix=VolPix/1000/1000/1000;% m3
    mkdir(ResDir)

    
    %% Xls filename
    fnxls=strcat(WorkDir,'_ROIs.xls');

    %% read ROI   
    Ra=xlsColRow(1,2);
    xlswrite(fnxls,{'ROI'},'ROI',Ra);
    Ra=xlsColRow(1,3,5,10);
    Y=xlsread(fnxls,'ROI',Ra);
    Rcnt=size(Y,1);
    ROI=zeros(Rcnt,4);

    disp('Read Images');
    [flist,Fcnt]=GetFiles(QniDir,'*.tif');
    

    if Fcnt>0
      fn=flist(1).fullname;
      Im=imread(fn); %load the image
      Im=im2double(Im); % convert to double
      [sy,sx]=size(Im);
      ROI(:,1)=1;
      ROI(:,2)=sy-Y(:,5);
      ROI(:,3)=sx;
      ROI(:,4)=sy-Y(:,3);
      Im1=imadjust(Im);
      regfig=ImPlotROI(Im1,'Regions',ROI);
    end
    uiwait(msgbox('Regions'));
   
    TS=[0,2,4,8,16,20,30,40];
    TScnt=size(TS,1);
    TScnt=Fcnt;
    
    VolT=VolPix*sx*sy;
    
    %Sum(ImageNumber,RegionNumber)
    W=zeros(Fcnt,Rcnt);
    Th=zeros(1,TScnt);
    T=zeros(Fcnt,1);
    H=sy+1-(1:sy)';
    Reg=(1:Rcnt);
    WM=zeros(sy,TScnt);  
    WT=zeros(1,TScnt);
    
   
    ti=0;
    Tx=0;
    for f=1:Fcnt
      disp(strcat(num2str(f),'::',flist(f).name));
      fn=flist(f).fullname;
      Tfn=flist(f).filename;
      Tfn=strcat(Tfn,'*.fits');
      [Tlist,Tcnt]=GetFiles(TimeDir,Tfn);
      if f==1
        T0=Tlist(1).datenum;
      end  
      if Tcnt==1
        Tx=(Tlist(1).datenum-T0)*24*60;
      end  
      T(f)=Tx;
      Im=imread(fn); %load the image
      Im=im2double(Im); % convert to double
      for r=1:Rcnt
        x1=ROI(r,1);y1=ROI(r,2);x2=ROI(r,3);y2=ROI(r,4);
        pic=Im(y1:y2,x1:x2);
        W(f,r)=sum(sum(pic));
      end
      if Tx>=0
        ti=ti+1;
        Th(ti)=Tx;
        Wy=sum(Im,2);
        WM(:,ti)=Wy;
        WT(1,ti)=sum(sum(Im));
      end  
    end
    
    %% scale  
    H=H/10;       %pixel => mm
    WM=WM/VolPix/1000/sx; %g/pixel=> kg/m3
    WT=WT/VolT/1000;
    
       %% WriteBack to excel
        wrBack=1;
        if wrBack 
          %% Save Results to mat file
          save(strcat(ResDir,'Res.mat'),'regfig','ROI','T','W','Reg','Th','H','WM','WT');
          %%  
          data={};
          data=datains(data,{'Regions'},1);
          data=datains(data,{'sum [g]'},1);
          data=datains(data,{' '},1);
          data=datains(data,{'time /region',Reg},1);
          data=datains(data,{T,W},1);
          Ra=xlsColRow(1,3);
          xlswrite(fnxls,data,'Water',Ra);
          %%
          data={};
          data=datains(data,{'Profile'},1);
          data=datains(data,{'sum [g]'},1);
          data=datains(data,{' '},1);
          data=datains(data,{'Starttime='},1);
          data=datains(data,{'H /time',Th},1);
          data=datains(data,{'eff time'},1);
          data=datains(data,{H,WM},1);
          data=datains(data,{0,WT},1);
          Ra=xlsColRow(1,3);
          xlswrite(fnxls,data,'Profile',Ra);
        end

    
    
    
    %% END
    msgbox('done','CreateMode','modal');





