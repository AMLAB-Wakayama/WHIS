%
%       Set Tools of WHIS for standalone running
%       IRINO T.
%       Created: 11 Sep 2021
%       Modified: 11 Sep 2021
%       Modified: 19 Sep 2021
%       Modified: 30 Sep 2021
%       Modified:  9  Oct 2021
%       Modified: 26 Oct 2021
%
%
%
DirProg = fileparts(which(mfilename));
NameProg = DirProg(max(strfind(DirProg,'WHIS')):end);
disp(['+++  ' NameProg ' +++'])
cd(DirProg)
DirTool = [DirProg  '/'];
% if exist(DirTool) == 0
%     mkdir(DirTool)
% end

DirMAT = [getenv('HOME') '/m-file/'];

DirSource1 = [DirMAT '/Signal/Filter/'];
NameFile1 = {'PwrSpec2MinPhaseFilter.m','SimTimeVaryFilter_AnaSyn.m'};
 for nFile = 1:length(NameFile1)
    if exist([DirTool char(NameFile1(nFile))]) == 0
        str = ['cp  -p -f ' DirSource1 char(NameFile1(nFile)) '   "' DirTool '" '];
        disp(str); unix(str);
        pause(0.1);
    else
        disp(['File exists: ' char(NameFile1(nFile)) '--- Remove it in advance if replacement is necessary.' ]);
    end  
 end
 
str = ['cp  -p -f ' DirMAT  '/Signal/MkSound/MkPipToneSequence.m '  ' "' DirTool '" '];
disp(str); unix(str);
% %%

DirTool2 = [DirTool '/OneThirdOctFB/'];
if exist(DirTool2) == 0
    mkdir(DirTool2)
end
DirSource2 = [DirMAT '/Auditory/OneThirdOctFB/'];
FileInfo = dir(DirSource2);
% length(FileInfo)
 for nFile = 4:length(FileInfo)-1
    NameFile = char(FileInfo(nFile).name);
    if exist([DirTool NameFile]) == 0
        str = ['cp  -p -f ' DirSource2  NameFile '   "' DirTool2 '" '];
        disp(str); unix(str);
        pause(0.1);
    else
        disp(['File exists: ' char(NameFile) '--- Remove it in advance if replacement is necessary' ]);
    end  
 end

 

%% %%%
% Trash 
%%%%%%
% str = ['cp  -p -f ' DirMAT '/Tool/Plot/printi.m    "' DirTool '" '];  % This exists in GCFBv231/Tool/.
% disp(str); unix(str);

