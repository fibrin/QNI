function checkPause(init)
 if (nargin < 1) || isempty(init)
   init=0;
 end
 if init
  try
    fid = fopen('_pause.txt','w');
    fclose(fid);
    delete('pause.txt');
  catch
    disp('Pause Error');
    keyboard;
  end
end
if 1
   pausecmd = dir('pause.txt');
   if size(pausecmd,1) > 0
     fid = fopen('_pause.txt','w');
     fclose(fid);
     delete('pause.txt');
     disp('Stopppppppppppppp');
     keyboard;
   end
end
end