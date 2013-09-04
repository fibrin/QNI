function [ imf ,adif ] = imFilter(im,tp,r,tol,option)
  % im   Image
  % r    Radius the median filter
  % tol  Image if dif between median and original >tol pixel stays original
  % imf  filtered Image
  %
  % fspecial
  % nlfilter
  % roifilt2
  % mean2 
  % std2
  % medfilt2
  % imfilter
  % filter2
  % 
  if ~exist('tp','var') || isempty(tp)
    tplist={'rem','med','gaussian'};
  else
    tplist={tp};
  end
  if ~exist('tol','var') || isempty(tol)
    tol=100;
  end
  if ~exist('r','var') || isempty(r)
    d=3;
  else
    d=2*r+1;
  end
  verbose=0;
  try verbose=option.test;end;
  
  cnt=length(tplist);
  for f=1:cnt
    filter=tplist{f};
     met=1;
    switch filter
      case 'rem'
        met=-1;
        flt=medfilt2(im,[d d]);
      case 'med'
        flt=medfilt2(im,[d d]);
      case 'disk'
        H=fspecial(filter,d);
        flt=imfilter(im,H);
      case 'gaussian'
        H=fspecial(filter,d);
        flt=imfilter(im,H);
      case 'unsharp'
        H=fspecial(filter);
        flt=imfilter(im,H);
      case 'log'
        H=fspecial(filter,d);
        flt=imfilter(im,H);
    end
    N=ones(d,d);
    ref=rangefilt(flt,N);
    %ref=max(max(flt))-min(min(flt));
    %ref=abs(flt);
    ref=medfilt2(im,[20,20]);
    %refm=min(min(ref(ref>0)));
    %ref(ref==0)=refm;
    adif=imabsdiff(im,flt);
    ref=median(median(adif));
    div=imdivide(adif,ref);
    div(div>100)=100;
    if met==1 
       Tind=(div<=tol);
    else
      Tind=(div>=tol);
    end  
    imf=im;
    imf(Tind)=flt(Tind);
    if verbose
      ImageShow(im,strcat(filter,':','original'),[],1);
      ImageShow(flt,strcat(filter,':','filtered'),[],1);
      ImageShow(adif,strcat(filter,':','absdif'),[],1);
      %ImageShow(ref,strcat(filter,':','ref'),[],1);
      ImageShow(div,strcat(filter,':','div'),[],1);
      %ImageShow(ref,strcat(filter,':','ref'),[],1);
      ImageShow(Tind,strcat(filter,':','ind'),[],1);
      ImageShow(imf,strcat(filter,':','Result'),[],1);
    end  
  end



end

