%
%      startup m-file of WHISv300. 
%      IRINO T.
%      Created:    14 Sep 21
%      Modified:   14 Sep 21
%      Modified:   26 Sep 21
%      Modified:    1  Dec  21
%      Modified:   22 Jan 2022  % defined as a function not to overwrite  DirProg
%
%      Setting path at least once before starting WHIS programs
%   
function DirProg = StartupWHIS

DirProg = fileparts(which(mfilename)); % Directory of this program
addpath([DirProg '/Tool/']);
addpath([DirProg '/Tool/OneThirdOctFB/']);    

% DirGCFB = 'GCFB';
DirGCFB = 'gammachirp-filterbank';
NameGCFB = 'GCFBv231';
addpath([DirProg '/../../' DirGCFB '/' NameGCFB '/']);    
addpath([DirProg '/../../' DirGCFB '/' NameGCFB '/Tool/']);   

end