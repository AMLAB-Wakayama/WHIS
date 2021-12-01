%
%      startup m-file of WHISv300. 
%      IRINO T.
%      Created:    14 Sep 21
%      Modified:   14 Sep 21
%      Modified:   26 Sep 21
%
%      Setting path at least once before starting WHIS programs
%   
DirProg = fileparts(which(mfilename));
addpath([DirProg '/Tool/']);
addpath([DirProg '/Tool/OneThirdOctFB/']);    

NameGCFB = 'GCFBv231';
addpath([DirProg '/../../GCFB/' NameGCFB '/']);    
addpath([DirProg '/../../GCFB/' NameGCFB '/Tool/']);   

