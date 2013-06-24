function [ Ir, lowhigh ] = ImageAdjust(Im,tol,center,restp,rng)
%[ Ir, lowhigh ] = ImageAdjust(Im,tol,center,restp,rng)
% Im: Image
% tol: toleranz% (2)
% center:0.1..0.5  look in th center of the image +- center  (0)
% restp: resulttype 0=>0..1 1=>original 2=>uint8 3=>unit16  (1)
% rng: fit to range [min..max value  

 if (nargin < 2) || isempty(tol)
    tol=2;
 end
 if (nargin < 3) || isempty(center)
    center=0;
 end
 if center>=1,center=0.5;end
 if (nargin < 4) || isempty(restp)
    restp=0;
    if isa(Im,'uint8')
      restp=2;
    elseif isa(Im,'uint16')
      restp=3;
    end
 end
 if (nargin < 5) || isempty(rng)
    rng=[0,0];
 end
 
  Ix=double(Im);
  img=Ix;
  %figure
  %imhist(img(:,:,1),1028);
  if center>0
      f=center;
      [sy,sx]=size(Ix);
      dwy=int32((sy)*f/2);dwx=int32((sx)*f/2);
      cy=int32((sy)/2);cx=int32((sx)/2);
      Ix=Ix(cy-dwy:cy+dwy,cx-dwx:cx+dwx);
  end           
  if rng==0
     imin=min(min(Ix));
     imax=max(max(Ix));
  else
    imin=rng(1);
    imax=rng(2);
  end
  
  %norm 0..1 
  img=(img-imin)/(imax-imin);
  %figure
  %imhist(img(:,:,1),1028);
 
  lowhigh=[0 1];

  if tol>0 && rng(1)==0 && rng(2)==0
    nbins=1028;
    if isa(Im,'uint8')
        nbins = 256;
    else
        nbins = 65536;
    end
    if tol>1
      tol=tol/100;
    end
    tol_low = tol;
    tol_high = 1-tol;
    p = size(img,3);
    p=1;
    ilowhigh = zeros(2,p);
    for i = 1:p                          % Find limits, one plane at a time
        N = imhist(img(:,:,i),nbins);
        cdf = cumsum(N)/sum(N); %cumulative distribution function
        ilow = find(cdf > tol_low, 1, 'first');
        ihigh = find(cdf >= tol_high, 1, 'first');
        if ilow == ihigh   % this could happen if img is flat
            ilowhigh(:,i) = [1;nbins];
        else
            ilowhigh(:,i) = [ilow;ihigh];
        end
    end
    lowhigh = (ilowhigh - 1)/(nbins-1);  % convert to range [0 1]
    img=(img-lowhigh(1))/(lowhigh(2)-lowhigh(1));
    lowhigh=lowhigh*(imax-imin)+imin;
    imin=lowhigh(1);imax=lowhigh(2);
    lowhigh=[0 1];
  end

 img(img<lowhigh(1))=lowhigh(1);
 img(img>lowhigh(2))=lowhigh(2);

 if restp==0
   Ir=img;
 elseif restp==1
   Ir=img/(imax-imin)+imin;
 elseif restp==2
   Ir=im2uint8(img);
 elseif restp==3
   Ir=im2uint16(img);
 end  
 lowhigh=[imin,imax];
end

