function [BW ] = A3_MakeBW( Im)

   % try to make Black and White ot of Pic
   
   imAir=[];
   Reg2=[];
   
   
   Img=Im;
   I0=imadjust(Img);

   M=mean2(I0);
   EarlyWood=M<100;
   if EarlyWood %early wood
     I0=removeBackground(I0,25);  %15 for firstpic 25 for the 2.pic
   end                              
   
   ImageShow(Img,'Im');
   Imageshow(I0,'I0');
    
   I0b=imadjust(I0,[],[],2.5); % gamma>1 mitte wird dunkler
   Imageshow(I0b,'I0b gamma');
   
   if EarlyWood
      ImEdg=FindEdges(Img,0.3,0.5);
   else
      ImEdg=FindEdges(Img,0.8,1);
   end
   ImageShow(ImEdg,'Edges');
   
   I0=imadd(I0,ImEdg);
   
   %Th=FindThreshold(I0,20);
   if EarlyWood 
     Th=100;
   else
    Th=105;
   end

   if EarlyWood
      BW=PrepRegion(I0,Th,20,1,0,8);
   else
      BW=PrepRegion(I0,Th,20,1,0,15);
   end     
   
   ImageShow(BW,'makebw BW');
 
end 
  