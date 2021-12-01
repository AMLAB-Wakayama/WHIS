%
%     HIsimFastGC_GUI�� Loss compression��Loss linear�̊������Z�o
%     Irino, T.
%     Created:  7 Jul 18
%     Modified: 7 Jul 18
%     Modified: 12 Dec 2018  ParamHI.HLdB_LossCompression�̒l�̏C��
%
%   ParamHI.DegreeCompression_Faudgram�̒l�����߂�B
%   ���炩���߁ALoss Compression���@HearingLevelVal �̒l�𒴂��Ȃ��悤�ɐ�������Ă���B
%   ����HearingLevelVal �ɂւ΂�������́ADegreeCompression
%   �iParamHI.DegreeCompression_Faudgram�j���t�Z����B
%    ����ɁA�c��̕����ɑ�������HLdB_LossLinear���v�Z����B
%
%
function [ParamHI] = HIsimFastGC_CalDegreeCmprsLin(ParamHI);

LenFag = length(ParamHI.FaudgramList);
for nfag = 1:LenFag   % mod
    % linear interpolation seems better
    ParamHI.DCcmpnst(nfag) = interp1(ParamHI.Table_HLdB_DegreeCompressionPreSet(:,nfag), ...
        ParamHI.Table_DegreeCompressionPreSet,ParamHI.HLdB_LossCompression(nfag),'linear','extrap');
    ParamHI.DCcmpnst(nfag) = max(min(ParamHI.DCcmpnst(nfag),1),0); % limit between 0 and 1
    % Loss Compression
    ParamHI.HLdB_LossCompression(nfag) = interp1(ParamHI.Table_DegreeCompressionPreSet, ...
        ParamHI.Table_HLdB_DegreeCompressionPreSet(:,nfag),ParamHI.DCcmpnst(nfag));
end
ParamHI.DegreeCompression_Faudgram = ParamHI.DCcmpnst;
% 12 Dec 2018
% Loss compression�̒l�́AParamHI.Table_HLdB_DegreeCompressionPreSet��100%��
% �Ƃ���Ƃ̍����ɂ��ׂ��B100%���S�ȏꍇ���R0 dB�łȂ���΂����Ȃ��B
ParamHI.HLdB_LossCompression = ParamHI.HLdB_LossCompression ...
    - ParamHI.Table_HLdB_DegreeCompressionPreSet(1,:);

ParamHI.HLdB_LossLinear  = ParamHI.HearingLevelVal - ParamHI.HLdB_LossCompression;

return;

