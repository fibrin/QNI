function [ output_args ] = SaveVars( Varn,Var )
  % Saving a figure as tp
  % tp= tif png,fig,jpg......
  % ---------------------------------------------
  global ResDir
  Dir=ResDir;
  Dir=strcat(Dir,'\var\');
  if ~exist('Varn','var') 
    Varn='Var';
    fn=strcat(num2str(fh),'-',Varn);
  else
    if 0
      Dir='';  
    end  
 end  
 if ~exist(Dir,'dir'),mkdir(Dir);end;
 fn=strcat(Dir,Varn,'.','mat');
 cmd=strcat(Varn,'=Var');
 eval(cmd);
 save(fn,Varn);
 %save(fn,'Var');
end

