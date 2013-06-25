function [InputPoints,BasePoints]=ControlPoints(Itrns,Ibase,InputPoints_in,BasePoints_in,check)
%% Select Controlpoint on two images
% 
% check : 0 no user interface 
%
%

%% Start
if ~exist('Itrns')
  msgbox('you have do run the main file');
else  
  InputImage=Itrns;
  BaseImage=Ibase;
  if nargin<3
     InputPoints_in=[];
     BasePoints_in=[];
     check=1;
  elseif nargin<5 
    check=0;
  end
end

%% Flag for Control Point selection
% 0 -> control points already selected and available, to be loaded in the
%      workspace
% 1 -> control points to be selected manually
FlagControlPoints = 0;

BasePoints_in=ImCheckPts(BaseImage,BasePoints_in,1);
InputPoints_in=ImCheckPts(InputImage,InputPoints_in,1);

FlagControlPoints = check;
%% check points
%  Open the Control Point SELECtion Tool's GUI to choose manually the
%  checkpoints in the two images, points to be used later on for the
%  optimal estimation of the affine deformation parameters
%  This built-in Matlab function returns, two arrays, called "xyinput_out"
%  and "xybase_out". These two arrays have got size
%  n-by-2, where n is the total number of valid checkpoints selected in
%  the images. The arrays contain the x-coordinates and y-coordinates,
%  respectively first and second column, that specify the locations of
%  the checkpoints selected.
%  The 'Wait' flag, when = true, passes the control to the GUI until the
%  user has finished with the checkpoint selection.

if FlagControlPoints 
  [InputPoints, BasePoints]= cpselect(InputImage,BaseImage,InputPoints_in, BasePoints_in,'Wait',true);
else
  InputPoints=InputPoints_in; BasePoints= BasePoints_in;
end
InputPoints1=InputPoints;
%InputPoints= cpcorr(InputPoints1, BasePoints, InputImage, BaseImage);

%
