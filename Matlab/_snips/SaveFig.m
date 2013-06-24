function [ output_args ] = SaveFig( fh,tp,fn )
%SAVEFIG Summary of this function goes here
%   Detailed explanation goes here
global ResDir
if ~exist('tp','var') 
  tp='.png';
end  

if ~exist('fn','var') 
  fn=get(fh, 'name');
end  
fn=strcat(ResDir,fn,tp);
saveas(fh,fn);
end

