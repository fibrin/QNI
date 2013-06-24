function [  ] = checkSample(WorkDir,OutDir,ROI,mode)
    %ANALYSEIMAGE Summary of this function goes here
    %   Detailed explanation goes here

     if (nargin < 4) || isempty(mode)
       mode='T';
     end
  
     if strcmp(mode,'T')
       hasXray=0;
     else
       hasXray=1;
     end
    
    %path NI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    masspath=strcat(WorkDir,'\nuptake');
    [massFN,anz]=GetIm(masspath,'*.fits');


    %path xray from X-ray images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xraypath=strcat(WorkDir,'\xuptake');
    [xrayFN,anz]=GetIm(xraypath,'*.fits');


    %path bb and dc and dry from neutron images  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bbpath=strcat(WorkDir,'\REF\bb');
    bb=imreadMean(bbpath);

    dcpath=strcat(WorkDir,'\REF\dcn');
    dc=imreadMean(dcpath);

    drypath=strcat(WorkDir,'\Dry\');
    DRY=imreadMean(drypath);
    
    
    IMx=imsubtract(DRY,bb); % subtract black body
    %IMx=imsubtract(IMx,dc); % subtract dark current
    DRY0=IMx;
    WPyx=[250,250];BPyx=[100,100];
    HighLow=[0,0];HighLow=[500,60000];
    %[DRY0,N_HighLow]=IntensityCorrection(DRY0,BPyx,WPyx,HighLow,80);
    DRY0=65535-DRY0(:,:); % invers

    ImageShow(DRY0,'Dry Imag after IntensityCorrection ');

    %path time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    timepath=strcat(WorkDir,'\nuptake');
    [timeFN,anz]=GetIm(timepath,'*.fits');


    %path output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    outpath=strcat(WorkDir,'\',OutDir);
    s=mkdir(outpath);
    s=mkdir(strcat(outpath,'\2_ROI'));
    s=mkdir(strcat(outpath,'\3_MC'));
    s=mkdir(strcat(outpath,'\1_IN'));



    % name for the excelsheet%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fnxls=strcat(outpath, '\results.xls');
    row=1;
    ce=strcat('A',num2str(row));
    % location on the sheet header
    data={'num','name','xoff','yoff','time [s]','gray'};
    %write the header
    xlswrite(fnxls, data, 'Res',ce);
    %datafiled for excel data
    data={};


    %anz=10;
    from=1;
    for f=from:anz
      close all;

      %remember the filename
      name=timeFN(f).filename;
      % take a numerical stamp to sort the results
      l=length(name);
      num=str2num(name(2:l));
      if num==51
        disp('break');
      end

      
      %read massimage neutron 
      fn=strcat(masspath,'\',massFN(f).filename,'.fits');
      MIM0r=imreadUint16(fn); %massimage
      IMx=imsubtract(MIM0r,bb); % subtract black body
     % IMx=imsubtract(IMx,dc); % subtract dark current
      MIM0=IMx;
      %[MIM0]=IntensityCorrection(MIM0,BPyx,WPyx,N_HighLow,80);
      MIM0=65535-MIM0(:,:); % invers 

      fm=ImageShow(MIM0,'Mass thickness'); % and show dh picture
      
      XIM0=MIM0;
      XIM0(:,:)=1;
      xoff=0;yoff=0;
      
      if hasXray
        %getxray
        fn=strcat(xraypath,'\',xrayFN(f).filename,'.fits');
        XIMr=imreadUint16(fn); %xrayation
        XIM0=XIMr;
        h = fspecial('average',3);
        %h = fspecial('disk',5);
        XIM0=imfilter(XIM0,h,'replicate');
        XIM0=65535-XIM0(:,:); % invers EW=white  LW=black
        if f==1
            BPyxX=[500,920];WPyxX=[500,200];HighLow=[-60000,65000];
            [XIM0,X_HighLow]=IntensityCorrection(XIM0,BPyxX,WPyxX,HighLow);
        else
            [XIM0]=IntensityCorrection(XIM0,BPyxX,WPyxX,X_HighLow);
        end   
        fx=ImageShow(XIM0,'X-ray');
      end

      

      
      
      
      %Analysing the Neutron imageage  
      % mcT the total moister content 
      % mcX profile of moister content along X mean value of vertical pixels
      % mcY provile of moister content along Y mean value of horizontal pixels
      % mcM matix of moister content
      % IMout RGB neutron xray mask
      % IMout RGB neutron xray mask croped to ROI
      [mcT,mcX,mcY,mcM,IMout,IMout2]=AnalyseImage(DRY0,MIM0,XIM0,ROI,mode);

      Mass(:,f)=mcY';
      
      
      % calculate the time
      time=FileDate(timeFN(f).date);
      if f==from
        time0=time;
        Mass=zeros(size(IMout2,1),anz);
      end
      time=int32((time-time0)*24*60*60+.0); %seconds

      data=datains(data,{num,name, xoff,yoff,time, mcT,mcY},1);

      
      
      
      %output image files
      fn=strcat(outpath,'\1_IN\',massFN(f).filename,'.tif');
      imwrite(IMout,fn);
      fn=strcat(outpath,'\2_ROI\',massFN(f).filename,'.tif');
      imwrite(IMout2,fn);
      fn=strcat(outpath,'\3_MC\',massFN(f).filename,'.tif');
      MCout=ImageAdjust(mcM,0,0,3); 
      imwrite(MCout,fn);

    end
    
    row=2;
    ce=strcat('A',num2str(row)); % location on the sheet
    %wirte results to the excel sheet
    xlswrite(fnxls, data, 'Res',ce);
    fn=strcat(outpath,'\','Mass','.tif');
    Mass(isinf(Mass))=0;
    Mass=ImageAdjust(Mass,2,0,3);
    imwrite(Mass,fn);

      
      
      
end