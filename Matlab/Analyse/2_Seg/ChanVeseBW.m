function   BW=ChanVeseBW(I,option)
  
   %filter smothing
   H=fspecial('disk',3);
   %Iflt=imfilter(I,H);
   
   Iflt=medfilt2(I,[10 10]);
   
 
   % test weather tere is water prensent in the stone or not
   % crop center by y=110 posibly water 160x160
   r=80;cx=round(size(I,2)/2);cy=r+30;
   Iw=Iflt(cy-r:cy+r,cx-r:cx+r);
   ImageShow(Iw,'water');
   mdw=mean2(Iw);     % mean of the are
   miw=min(min(Iw));
   maw=max(max(Iw));
   dw=maw-miw;        % rang max-min with in area
   % crop  center by y=300 only Stone 160 x 160
   r=80;cx=round(size(I,2)/2);cy=300;
   Is=Iflt(cy-r:cy+r,cx-r:cx+r);
   ImageShow(Is,'stone');
   mds=mean2(Is);
   mis=min(min(Is));
   mas=max(max(Is));
   ds=mas-mis;       % range max-min with in area
   dif1=(mdw-mds);   % diff between meanvalues
   dif2=((dw-ds));   % diff between ranges
   if dif2<0.05  
     % no water
     seg= false(size(I));
   else
     % water 
      m=zeros(size(I)); 
      w=220;h=160;cx=round(size(I,2)/2);cy=110;
      m(cy-h/2:cy+h/2,cx-w/2:cx+w/2)=1;
      seg = chenvese(I,m,400,0.02,'chan'); % ability on gray image
   end  
   BW=seg;
end
