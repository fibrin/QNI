
function option=A1_Init()

    clear;
    close all;
    imtool close all;

    global root
    global ProgDir WorkDir ResDir;
    global ImShowFlag ImShowPos  ImShowList;


    dbstop if error;
    s=warning('off','MATLAB:dispatcher:pathWarning');
    s=warning('off','MATLAB:MKDIR:DirectoryExists');
    s=warning('off','MATLAB:colon:nonIntegerIndex');

    path(path,'..\_snips');
    path(path,'_snips');
    ProgDir=add_function_paths();
    cd(ProgDir);

    path(path,'2_Seg');
    path(path,'2_Shape');
    path(path,'2_Seg\ChanVese');

    ImShowPos=1;
    ImShowList(ImShowPos)=1;
    ImShowFlag=0;

    return    
      
      
      
      
  %% add all Pathes and check Workdir
  function PD=add_function_paths()
      PD=[];
      try
          functionname='A1_Init.m';
          functiondir=which(functionname);
          functiondir=functiondir(1:end-length(functionname));
          PD=functiondir;
          PD=PD(1:length(PD)-1);
          add_sub_path(PD,'',0);
      catch me
          disp(me.message);
      end
    end

    function add_sub_path(P0,P1,lv)
      Pa=strcat(P0,'\',P1); 
      lv=lv+1;
      [Dlist,cnt ]=GetFiles(Pa,'DIR');
      for d=1:cnt
        p=Dlist(d).name;
        p=strcat(P1,p);
        path(path,p);
        disp (strcat('add Path : ',p));
        p=strcat(p,'\');
        add_sub_path(P0,p,lv);
      end
    end

end
