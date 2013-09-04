function [ output_args ] = SaveFig( fh,tp,fn )
% Saving a figure as tp
% tp= tif png,fig,jpg......
% ---------------------------------------------
global ResDir
if ~exist('tp','var') 
  tp='png';
end  
Dir=ResDir;
if ~exist('fn','var') 
  Dir=strcat(Dir,'\fig\');
  fn=get(fh, 'name');
  fn=strcat(num2str(fh),'-',fn);
else
  if 0
    Dir='';  
  end  
end  
if ~exist(Dir,'dir'),mkdir(Dir);end;
fn=strcat(Dir,fn,'.',tp);
saveas(fh,fn);
end

