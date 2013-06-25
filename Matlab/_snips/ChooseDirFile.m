function [ PathString ] = ChooseDirFile( def,tp,title,flg)
%  OpenF File Dialog to choose a File
%  def: default file name to be searched
%  tp : file tipe '*','PIC','DIR'
%  title: window title
%  flg: not used
%  PathSting: the file name or []

  PathString=[];
  st=[];
  if nargin<4 || isempty(flg)
    flg=0;
  end
  if nargin<1 || isempty(def)
      pa=char(System.Environment.CurrentDirectory);
      def=strcat(pa,'\','*.*');
      file='*.*';
      ext='.*';
      isDir=0;
  else  
     [pa,file,ext]=fileparts(def);
     x=dir(def);
  end 
  filter=strcat('*',ext);
  isDir=0;
  if ~(nargin<2 || isempty(tp))
    if strcmpi(tp,'DIR')
      isDir=1;
      if flg
        st='\';
      end  
    end
    if strcmpi(tp,'PIC')
      filter={'*.tif;*.png;*.jpg;*.bmp','Image (*.tif;*.png;*.jpg;*.bmp)';'*.*','All files (*.*)'};
    end
  end
  if nargin<3 || isempty(title)
    if isDir
      title='choose a directrory';
    else
      title='choose a file';
    end
  end
  multiselect=0;
  
  if isDir
     s=uigetdir(def,title);
     pa='';
  else
    if multiselect
      [s,pa]=uigetfile(filter,title,def,'MultiSelect','on');
    else  
      [s,pa]=uigetfile(filter,title,def);
    end  
  end  
  if isequal(s,0)
    PathString=[];
  else  
    PathString=strcat(pa,s,st);
  end  
end

