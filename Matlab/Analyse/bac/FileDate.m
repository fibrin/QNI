function [ DateTime ] = FileDate( filename )
%FILEDATE Summary of this function goes here
%   Detailed explanation goes here
  fn=filename;
  d=fn;
  %dn=datenum(d,'dd-mmm-jjjj HH:MM:SS');
  p=find(fn==' ',1,'Last');
  d=fn(p+1:p+8);
  %dn=datenum(d,'HH:MM:SS');
  dn=datenum(fn);
  DateTime=dn;
end

