function A1_Init
  close all;
  imtool close all;
  clear;
  global ImShowFlag ImShowPos  ImShowList;
  global WorkDir;
  dbstop if error
  WD=add_function_paths();
  cd(WD);
  addpath(path,'..\_snips');
  addpath(path,'\_snips');
  addpath(path,strcat(WD,'_snips'));
  ImShowPos=1;
  ImShowList(ImShowPos)=1;
  ImShowFlag=0;


function WD=add_function_paths()
WD=[];
try
    functionname='A1_Init.m';
    functiondir=which(functionname);
    functiondir=functiondir(1:end-length(functionname));
    WD=functiondir;
   % addpath([functiondir '/1_Affine'])
   % addpath([functiondir '/2_getPOI'])
   % addpath([functiondir '/3_TPS_RPM'])
   % addpath([functiondir '/3_Bspline'])
catch me
    disp(me.message);
end