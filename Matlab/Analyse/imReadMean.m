function [ imr ] = imReadMean( impath,Filename,nums,start )
% Read nums Images and take calc average
% if num > 0 start fis first
% if num < 0 start with last
[Flist,anz]=GetFiles(impath,Filename);
if anz>0
  from=1;
  to=anz;
  if nargin<4 , 
    if nums>0 ,start=1;end;
    if nums<0 , start=anz;end;
  end  
  if start> anz ,start=anz;end;
  if start< 1   ,start=1;end;
  if nargin>=3 
    if nums>0
      if nums+start>anz
        error('nums+start)>anz');
      else
        from=start;  
        to=nums+start-1;
      end
    else  
      if start+nums<0
        error('start+nums<0');
      else
        from=start+nums;
        to=start;
      end    
    end
  end  
  hasMean=0;
  %Fn=Flist(1).filename;
  %meanfilename=strcat(Fn,'_M.tif');
  %[FN,hasMean]=GetFiles(impath,meanfilename);
  cnt=0;
  if hasMean==1
    imr=imread(FN(1).fullname);
  else  
    for i=from:to
      fn=Flist(i).fullname;
      im=imReadDbl(fn);
      cnt=cnt+1;
      if i==from
        im0=im;
      else
        im0=im0+im;
      end
    end %for  
    im0=(im0/cnt);
    imr=im0;
  end  
  %imr=uint16(im0);
  %imwrite(imr,strcat(impath,'\',meanfilename));
else
  msgbox(strcat('check Sample:',Filename));
  imr=[];
end  

end

