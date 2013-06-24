
A1_Init;
ImShowFlag=0;
%WorkDir='R:\Scratch\118\Gilani\Raw_N\Wood Marjan Saeed\beech';
WorkDir='R:\Scratch\118\Gilani\Raw_N\Wood Marjan Saeed\spruce';
%WorkDir='R:\Scratch\118\Gilani\Raw_N\Wood Marjan Saeed\lvl';

%OrganiseData ---------------
%OrganizeData;

%Do one Sample
SampleList={'80SL1','80SL2P','80SR1','80ST1','50SL1R','50SL2','50SR1','50ST1','30SL1','30SL2','30SR1','30ST1'};
%SampleList={'30SL2'};
l=length(SampleList);
for s = l-1:l
  Sample=SampleList{s};
  %Sample='30SL1';
  AnalyseSampleQNI(WorkDir,Sample,-1);
end

m=msgbox('done','Press OK');
uiwait(m);