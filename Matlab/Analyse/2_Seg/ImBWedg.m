function [ imBW ] = ImBW( Im,options )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
      ImDif=Im;
      % filter 
      H=fspecial('disk',3);
      imFlt=imfilter(imDif,H)*2;
      %imFlt=imDif; %filter not used
      ImageShow(imFlt,'filter');
      %edg
      imEdg=FindEdges(imFlt,0.3,5);
      SE=strel('disk',4);        
      imEdg=imclose(imEdg,SE);      
      ImageShow(imEdg,'Edg');
      % threshold and morphological operations to do BW
      % could be replaced with better function
      imFlt=imFlt+imEdg;
      % threshold and morphological operations to do BW
      % could be replaced with better function
      th=0.3;
      imBW=imFlt>th;
      ImageShow(imBW,'threshold');
      imBW=bwareaopen(imBW,40);  % remove small areas
      SE=strel('disk',6);        % make the border more smooth
      imBW=imclose(imBW,SE);      
      imBW=imfill(imBW,'holes'); % fill the holes  
      ImageShow(imBW,'water');   % show
end

