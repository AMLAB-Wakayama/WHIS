%
%     HIsimFastGC_GUIで Loss compressionとLoss linearの割合を算出
%     Irino, T.
%     Created:  7 Jul 18
%     Modified: 7 Jul 18
%     Modified: 12 Dec 2018  ParamHI.HLdB_LossCompressionの値の修正
%
%   ParamHI.DegreeCompression_Faudgramの値を決める。
%   あらかじめ、Loss Compressionが　HearingLevelVal の値を超えないように制限されている。
%   このHearingLevelVal にへばりついた時の、DegreeCompression
%   （ParamHI.DegreeCompression_Faudgram）を逆算する。
%    さらに、残りの部分に相当するHLdB_LossLinearも計算する。
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
% Loss compressionの値は、ParamHI.Table_HLdB_DegreeCompressionPreSetの100%の
% ところとの差分にすべき。100%健全な場合当然0 dBでなければいけない。
ParamHI.HLdB_LossCompression = ParamHI.HLdB_LossCompression ...
    - ParamHI.Table_HLdB_DegreeCompressionPreSet(1,:);

ParamHI.HLdB_LossLinear  = ParamHI.HearingLevelVal - ParamHI.HLdB_LossCompression;

return;

