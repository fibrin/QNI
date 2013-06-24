function [ dat ] = datains( data,cells,LeftDown )
%% fill th cellarray to write to excel
% put the next cell
% Leftdown 0=> same row (left)
%          1=> same col (down)   
% Example 
% start    data={};
% header   data=datains(data,{'x', 'y', 'xc', 'yc', 'xa', 'ya'});
% skip col data=datains(data,{''});
% scalar   data=datains(data,{cx,cy});
% scalar   data=datains(data,{Mat,Mat2});



%row,col
[dr,dc]=size(data);
dcx=dc;
[cr,cc,cb]=size(cells);
if (nargin < 3) || isempty(LeftDown),LeftDown=0;end;
if LeftDown==0
  % right same row  
  for c1x=1:dc
    if isempty(cell2mat(data(dr,c1x)))
      dcx=c1x-1;
      break;
    end
  end
  c1=dcx+1;
  r1=dr;
  if r1==0 ,r1=1;end
else
  % down next row  
  c1=1;
  r1=dr+1;
end
dat=data;
for r=1:cr
    r2=r1+r-1;
    c2=c1;
    for c=1:cc
        ce=cells{r,c};
        if ischar(ce)
            %adding Chars
            dat(r2,c2)=cells(r,c);
            c2=c2+1;
        else
            %adding Matrix
            [vr vc vz]=size(ce);
            if vr==0, % 1  cs 6.4.2011
               cx=zeros(vc,vz);
               cx(1:vc,1:vz)=ce(1,1:vc,1:vz);
               ce=cx;
               vr=vc;vc=vz;
            end   
            for rx=1:vr
                r3=r2+rx-1;
                for cx=1:vc
                    c3=c2+cx-1;
                    dat{r3,c3}=ce(rx,cx);
                end
            end
            c2=c2+vc;
        end    
    end
end


end

