

function [ Ir, lowhigh ] = ImageAdjust(Im,rngtol,center,restp,fit)
%[ Ir, lowhigh ] = ImageAdjust(Im,tol,center,restp,rng)
% Im: Image
% tol: toleranz% (2)
% center:0...1  look in th center of the image +- center  (0)
% restp: resulttype []=>original 0=>dbl no bdcheck 1=>0..1 2=>uint8 3=>unit16  ([])
% rng: fit to range [min..max] value  
 

 
 if (nargin < 2) || isempty(rngtol)
    tol=2;
    rng=[];
 else
   if length(rngtol)>1
     rng=rngtol;
     tol=2;
   else
     tol=rngtol;
     rng=[];
   end  
 end
 if (nargin < 3) || isempty(center)
    center=0;
 end
 if center>=1,center=1;end
 if (nargin < 4) || isempty(restp)
    restp=0;
    if isempty(rng) ;
      restp=1;
    end  
    if isa(Im,'uint8')
      restp=2;
    elseif isa(Im,'uint16')
      restp=3;
    end
 end
 if (nargin < 5) || isempty(fit)
    fit=[0,1];
 end
 
 
 Ix=double(Im);
 img=Ix;
 
 
 if isempty(rng)
    %get the limits
    if center>0
        f=center;
        [sy,sx]=size(Ix);
        dwy=int32((sy)*f/2);dwx=int32((sx)*f/2);
        cy=int32((sy)/2);cx=int32((sx)/2);
        Ix=Ix(cy-dwy:cy+dwy,cx-dwx:cx+dwx);
    end           
    imin=min(min(Ix));
    imax=max(max(Ix));
    %norm 0..1 
    img=(img-imin)/(imax-imin);
    lowhigh=[0 1];
    if tol>0 
      if tol>=0.1 ,tol=tol/100;end;
      lowhigh=stretchlim(img,tol);
    end
    f=(imax-imin)/1;
    imin1=imin+lowhigh(1)*f;
    imax1=imin+lowhigh(2)*f;
    iminf=imin1;
    imaxf=imax1;
    f=(imax1-imin1)/(fit(2)- fit(1));
    f=1/f;
    if ~(f==1)
      iminf=(fit(1)-f*(imin1))/(1-f);
      imaxf=iminf+1/f;
    end  
    rng(1)=iminf;
    rng(2)=imaxf;
 end  

 % calculate
 img=rng(1)+(Im-rng(1))/(rng(2)-rng(1));
 
 if restp>0 
  img(img<fit(1))=fit(1);
  img(img>fit(2))=fit(2);
 end
 
 if restp==0
   Ir=img;
 elseif restp==1
   Ir=img;
 elseif restp==2
   Ir=im2uint8(img);
 elseif restp==3
   Ir=im2uint16(img);
 end  
 lowhigh=rng;
end

