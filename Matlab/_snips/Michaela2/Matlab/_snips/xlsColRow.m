 function  [range]=xlsColRow(col,row,colwidth,rowHeight,home)
 %col RangeStartCol(1),row RangeStartRow(1), colwidth=RangeWidth(0) rowHeight=RagheHeight(0),home=('A1')
 if (nargin < 1) || isempty(col)
   col=1;
 end
 if (nargin < 2) || isempty(row)
   row=1;
 end
 if (nargin < 3) || isempty(colwidth)
   colwidth=0;
 end
 if (nargin < 4) || isempty(rowHeight)
   rowHeight=0;
 end
 if (nargin < 5) || isempty(home)
   home='A1';
 end
 FirstCol=home(1:1);
 FirstRow=home(2:size(home,2));
 FirstRow=str2num(FirstRow);
 BlockSize=26;
 ColNum=int8(FirstCol)+col-int8('A');
 ColBlock=floor(double((ColNum-1))/BlockSize);
 RowNum=FirstRow+row-1;
 cNum=ColNum-ColBlock*BlockSize;
 rNum=RowNum;
 BlockStr='';
 if ColBlock>0 
   BlockStr=char(int8('A')+ColBlock-1);
 end
 ColStr=char(cNum+int8('A')-1);
 range=strcat(BlockStr,ColStr,num2str(rNum));
 if colwidth>0 
   ColNum=ColNum+colwidth-1;
   if rowHeight==0 
      row=RowNum;
   else
      row=RowNum+rowHeight-1;
   end;
   ColBlock=floor(double((ColNum-1))/BlockSize);
   cNum=ColNum-ColBlock*BlockSize;
   rNum=row;
   BlockStr='';
   if ColBlock>0 
     BlockStr=char(int8('A')+ColBlock-1);
   end
   ColStr=char(cNum+int8('A')-1);
   range=strcat(range,':',BlockStr,ColStr,num2str(rNum));
 end;
  



 
  

