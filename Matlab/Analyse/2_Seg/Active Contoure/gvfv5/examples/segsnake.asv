function [ seg ] = segsnake(I,s )
%SEGSNAKE Summary of this function goes here
%   Detailed explanation goes here

  [m,n] = size(I);
  Imin  = min(I(:));
  Imax  = max(I(:));
  I = (I-Imin)/(Imax-Imin)*255;  % Normalize I to the range [0,255]

  bnd=bwboundaries(s);
  


   % Compute its edge map
     disp(' Compute edge map ...');
     f = 1 - I/255; 

   % Compute the GVF of the edge map f
     disp(' Compute GVF ...');
     [u,v] = GVF(f, 0.2, 80); 
     disp(' Nomalizing the GVF external force ...');
     mag = sqrt(u.*u+v.*v);
     px = u./(mag+1e-10); py = v./(mag+1e-10); 

  % display the results
     figure(1); 
     subplot(221); imdisp(I); title('test image');
     subplot(222); imdisp(f); title('edge map');

     % display the gradient of the edge map
     [fx,fy] = gradient(f); 
     subplot(223); quiver(fx,fy); 
     axis off; axis equal; axis 'ij';     % fix the axis 
     title('edge map gradient');

     % display the GVF 
     subplot(224); quiver(px,py);
     axis off; axis equal; axis 'ij';     % fix the axis 
     title('normalized GVF field');

     
     
     
   % snake deformation
     disp(' Press any key to start GVF snake deformation');
     pause;
     subplot(221);
     image(((1-f)+1)*40); 
     axis('square', 'off');
     colormap(gray(64)); 
     t = 0:0.05:6.28;
     x = 32 + 30*cos(t);
     y = 32 + 30*sin(t);
     [x,y] = snakeinterp(x,y,3,1); % this is for student version
     % for professional version, use 
     %   [x,y] = snakeinterp(x,y,2,0.5);

     snakedisp(x,y,'r') 
     pause(1);

     for i=1:25,
       [x,y] = snakedeform(x,y,0.05,0,1,0.6,px,py,5);
       [x,y] = snakeinterp(x,y,3,1); % this is for student version
       % for professional version, use 
       %   [x,y] = snakeinterp(x,y,2,0.5);
       snakedisp(x,y,'r') 
       title(['Deformation in progress,  iter = ' num2str(i*5)])
       pause(0.5);
   end

     disp(' Press any key to display the final result');
     pause;
     cla;
     colormap(gray(64)); image(((1-f)+1)*40); axis('square', 'off');
     snakedisp(x,y,'r') 
     title(['Final result,  iter = ' num2str(i*5)]);
     disp(' ');
     disp(' Press any key to run the next example');
     pause;








end

