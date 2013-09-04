function [ imr ] = imReadMean( impath,Filename,nums,start )
% Read nums Images and calc average
% if num > 0 start with first
% if num < 0 start with last
% if start>0 start with first
% if start<0 start with last-start
% if the Meanfile already exists just read the meanfile
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
  Fn=Flist(1).filename;
  meanfilename=strcat(impath,'\',Fn,'_M.fits');
  hasMean=exist(meanfilename,'file');
  cnt=0;
  %hasMean=0;
  if hasMean
    imr=ImReadFits(meanfilename);
  else  
    for i=from:to
      fn=Flist(i).fullname;
      im=imReadDbl(fn);
      im=imFilter(im,'rem',2,5);
      ImageShow(im,strcat('REF',num2str(i)),[],1);
      cnt=cnt+1;
      if i==from
        im0=im;
      else
        im0=im0+im;
      end
    end %for  
    im0=(im0/cnt);
    imr=im0;
    ImWriteFits(meanfilename,imr);
  end  
else
  msgbox(strcat('check Sample:',Filename));
  imr=[];
end  

end

