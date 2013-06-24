function [ imr ] = imreadMean( impath,Filename,nums,skip )
%IMREADMEAN Summary of this function goes here
%   Detailed explanation goes here
[Flist,anz]=GetFiles(impath,Filename);
if anz>0
  from=1;
  to=anz;
  if nargin<4 , skip=0;end
  if nargin>=3 
    if abs(nums+skip)<anz
        if nums<0 
          from=anz+nums+1-skip;
          to=anz-skip;
        elseif nums<anz
          from=1+skip;  
          to=nums+skip;
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

