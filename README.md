%% ======================================================================  
%%  
%% README file for Wadai (Wakayama University) Hearing Impairment Simulator (WHIS)  
%%  和大模擬難聴システム  
%% Copyright (c) 2010-2023  Wakayama University  
%% All rights reserved.  
%% By Toshio Irino , 10-Jul-2023  ( <-- 21-Mar-2022)
%%  
%% ======================================================================  

Packages:  
* WHISv225:   2020 version  
    - See ./WHISv255/_ReadMeFirst.rtf  (Japanese document)
    - No English document.  
    - Do not use this version in the future experiments.  

* WHISv226:  Oct 2021 version  
    - Introducing "FreeField" setting into GCFBv211.m --> GCFBv211_ff.m (ad hoc)      
    No other major change.   
    - This version was produced only for comparison to WHISv300.  
    - Do not use this version in the future experiments.  

* WHISv300:  Nov 2021 version [1] --> New algorithm  
    - New implementation of WHIS. 
    - GCFBv231 is essential for this version  
    - See ./WHISv300/_ReadMeFirst_WHISv300.md  
    - See ./WHISv300/_ReadMeFirst_WHISv300_Jp.md  (in Japanese)

* WHISv302:  Mar 2022 version
    - New implementation of WHIS. 
    - GCFBv233 or the later version is essential for this WHIS  
    - See ./WHISv302/_ReadMeFirst_WHISv302.md  
    - See ./WHISv302/_ReadMeFirst_WHISv302_Jp.md  (in Japanese)
    - See arXiv preprint "arXiv_WHISgc22_I.pdf" for the detail of WHISv30


---  
Documents:  
* GUI manual (Japanese & English)  
    - WHIS_GUImanual_v22v30.pdf   

* Related web page (Mainly for WHISv225)  
   - Web page URL (English): https://cs.tut.ac.jp/~tmatsui/whis/index-en.html  
   - ウェッブページ（日本語）: https://cs.tut.ac.jp/~tmatsui/whis/  

---  
Reference  
- [1] Toshio Irino, "A new implementation of hearing impairment simulator WHIS based on the gammachirp auditory filterbank," Report of ASJ hearing commitee meeting, 11 Dec 2021 (Main text in Japanese, with English extended abstract)  
- [2] Toshio Irino, "WHIS: Hearing impairment simulator based on the gammachirp auditory filterbank," arXiv preprint, [arXiv.2206.06604], 
[https://doi.org/10.48550/arXiv.2206.06604], 14 Jun 2022. (First English preprint)
- [3] Toshio Irino, "Hearing impairment simulator based on auditory excitation pattern playback: WHIS," IEEE access, Vol.11, pp.78419--78430, 25 July 2023,[DOI: 10.1109/ACCESS.2023.3298673], [https://ieeexplore.ieee.org/document/10193769],  25 July 2023. (English paper: more comprehensive)

