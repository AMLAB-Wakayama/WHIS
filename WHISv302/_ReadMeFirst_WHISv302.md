%% ======================================================================   
%%  
%% README file for Wadai (Wakayama University) Hearing Impairment Simulator (WHIS)  
%% 和大模擬難聴システム  
%% Copyright (c) 2010-20xx  Wakayama University   
%% All rights reserved.  
%% by Toshio Irino ,  20-Mar-2022
%%    
%% ======================================================================   
  
  
  
1. Software and setting  
  
- You need GCFBv233. Set local directory as follows.  
   - [LocalDir]/WHIS/WHISv302  
   - [LocalDir]/gammachirp-filterbank/GCFBv233   
   - See GCFBv233 for Seting of hearing loss (HL)   
  
- WHISv30_GUI :  GUI version of WHIS  
  
- WHISv30_Batch: Batch version of WHIS  
  
- testWHISv302v226_Batch.m : test program for WHISv301 (dtvf & fbas) & v226 for comparison  
  
- StartupWHIS.m : setting path for tools of WHIS and GCFB  
  
- Snd_Hello123.wav :   Sample sound  
  
- ShowIOfunc_WHISv302CamHLS_GCFBv233.m   
    Calculation of Input-Output function using GCFB, WHIS, and CambHLS_(Not provided here)  
  
- ShowSpec_WHISv302CamHLS_GCFBv233.m   
    Calculation of spectrogram using GCFB, WHIS, and CambHLS_(Not provided here)  
  
- ShowIOfunc_GCFBWHISCamHLS.m  
    Showing IO function after finishing ShowIOfunc_WHISv301CamHLS_GCFBv231.m  
  
- There are some other programs.  
  
---  
  
2. GUI version of WHIS  
- WHIS_GUI  
  - See Document/GUI_UserManual.pdf  
  
- Execution:   
 ＞＞ StartupWHIS    
 ＞＞ WHIS_GUI   
   
- The following directory will be produced automatically.   
	Mac:	/Users/[UserName]/Data/WHIS    
	Win:  C:¥Users¥[UserName]¥Data¥WHIS   
    You can change the directory when the data is saved.  
  
- You need to calibrate the SPL. --> See section 4.  
  
---  
  
3. Batch version of WHIS  
  
- WHISv30_Batch  
  - Batch processing program is also provided to produce many sound files for psychoacoustic experiments.
  - See testWHISv302v226_Batch.m   

---  

4. Internal digital level and SPL of real environment  

- Calibration tone:  sin wave with diginal RMS level of -26 dB  
    - Specify SPL (Leq) of this sound in dB.  

- In the case of WHIS_GUI, it is set to 80 dB SPL.  
  -	[Intenal digital RMS level  -26 dB]  == [Outside SPL (Leq) 80 dB]  

- You may specify this value when using WHISv30_Batch  

---  

5. Document (See directory "Document")  
  
  - GUI_UserManual.pdf  
    User manual of GUI  
  
  - ReportJpn_ASJHdec21JpTaiwan_I.pdf  
    Toshio Irino, "A new implementation of hearing impairment simulator WHIS based on the gammachirp auditory filterbank," The 3rd Japan-Taiwan Symposium on Psychological and Physiological Acoustics, Proc. Auditory Res. Meeting, The Acoustical Society of Japan, Vol.51, No.8, pp.545-550, H-2021-102, 2021. (in Japanese. English paper is under preparation.)  
  
  - AbstEng_ASJHdec21JpTaiwan_I.pdf  
    Extended English abstract for ReportJpn_ASJHdec21JpTaiwan_I.pdf  
  
---   
  
History:  
  2022/3/20  WHISv302
  2022/3/6   WHISv301
  2022/2/27 Upload documents  
  2021/12/5 Introducing WHISv300  

Toshio Irino  
e-mail: irino@sys.wakayama-u.ac.jp  




