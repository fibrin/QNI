function [ ] = A4_Mesh( Im,BW, FileN )
%A8_MESH Summary of this function goes here
%   Detailed explanation goes here
 [GM reg]=TraceBW(Im,BW);
 r=length(reg);
 backgrnd=0;
 amax=0;
 sx=size(Im,2);
 sy=size(Im,1);
 for i=1:r
   Cell=reg{i};
   xmin=min(Cell(:,2));
   xmax=max(Cell(:,2));
   ymin=min(Cell(:,1));
   ymax=max(Cell(:,1));
   a=(xmax-xmin)*(ymax-ymin);
   if a>amax
     amax=a;
     backgrnd=i;
   end
 end
 %mesh
 f=ImageShow(Im,'Mesh ');
 hold on
 dl=decsg(GM);
 pdegplot(dl);
 % [p,e,t]=initmesh(dl,'box','on');
 [p,e,t]=initmesh(dl);
 pdemesh(p,e,t);
 disp('num of points');
 disp(length(p));
 hold off
 FN=GetFilename(FileN,'_Mesh','jpg');
 saveas(f,FN);
 FN=GetFilename(FileN,'_Mesh','msh');
 writemesh(FN,p,t, backgrnd);
end

