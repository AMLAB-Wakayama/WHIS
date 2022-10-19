%
%      Startup m-file of WHISv30
%      IRINO T.
%      Created:    14 Sep 21
%      Modified:   14 Sep 21
%      Modified:   26 Sep 21
%      Modified:    1  Dec  21
%      Modified:   22 Jan 2022  % defined as a function not to overwrite  DirProg
%      Modified:   6  Mar 2022   WHISv300_func --> WHISv30_func, GCFBv231--> GCFBv232
%      Modified:  20 Mar 2022  v302  <--- GCFBv233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%      Modified:  19 Oct 2022  v302  GCFBv234 <-- GCFBv233
%
%      Setting path at least once before starting WHIS programs
%   
function [DirWHIS, DirGCFB] = StartupWHIS

DirWHIS = fileparts(which(mfilename)); % Directory of this program
addpath([DirWHIS '/Tool/']);
addpath([DirWHIS '/Tool/OneThirdOctFB/']);    

% DirGCFB = 'GCFB';
DirGCFB = ([DirWHIS '/../../gammachirp-filterbank/GCFBv234/']);
addpath(DirGCFB);
addpath([DirGCFB '/Tool/']);   

end