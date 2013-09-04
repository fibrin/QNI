function [ f ] = ImageShow( Im,Title,fig ,map,pos,doshow,dosave)
%   [f] = ImageShow (Im,Title,fig ,map,pos,doshow)
% Im: the Image
% Title: Title of the figure
% fig: figure handel if already is open
% map: if true = map min(image)..max(image) to 0..1
% pos: 0 whole figure else  1..4 in figure
% doshow overwrite the global doshow flag
% f:: = hadle of the open figure
global ImShowFlag ResDir
    if ~exist('map','var') || isempty(map)
        map=0;
    end 
    if ~exist('pos','var')|| isempty(pos)
        pos=0;
    end    
    if ~exist('doshow','var')|| isempty(doshow)
        doshow=0;
    end    
     if ~exist('dosave','var')|| isempty(dosave)
        dosave=0;
    end    

    if isempty(ImShowFlag)
        ImShowFlag=1;
    end

    f=[];
    [sy,sx,sz]=size(Im);
    if sz<4 ,is2D=1;else is2D=0;end;
    
    if (ImShowFlag || doshow)

      if is2D  
        if (nargin < 2) || isempty(Title)
          Title='-';
        end
        S=max(size(Im));
        S0=500;
        mag=S0/S*100;
        if ~exist('fig','var') || isempty(fig)
           f=figure;
           fig=f;
        else
           f=fig;  
           figure(fig);
        end   
        if pos~=0 
          scrsz = get(0,'ScreenSize');
          scx=200;scy=200;
          if pos==2, scx=scrsz(3)/2;end;
          if pos==3, scy=scrsz(4)/2;end;
          if pos==4, scx=scrsz(3)/2;scy=scrsz(4)/2;end;
          fpos=get(fig,'position');
          wx=fpos(3);
          wy=fpos(4);
          set(fig,'Position',[(1+scx) (scrsz(4)-scy-wy) wx wy ])
        end
        %imshow
        if map
          tol=1-map;
          mi=min(min(Im));
          Im=Im-mi;
          ma=max(max(Im));
          Im=Im/ma;
          if tol>0
            LO_HI=stretchlim(Im,tol);
            mi=LO_HI(1);ma=LO_HI(2);
            mm=ma-mi;
            Im=(Im-mi)/mm;
          end  
        end  
        imshow(Im,'InitialMagnification',mag);
        if ~strcmp(Title,'-')
          set(f,'Name',Title);
        end
      
        if dosave
          SaveFig(f);
        end
        
      else  % Show 3D pic
        showcs3(Im);
      end
   
    end
  
end

