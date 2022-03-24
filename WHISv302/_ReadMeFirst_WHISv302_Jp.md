%% ======================================================================  
%%  
%% README file for Wadai (Wakayama University) Hearing Impairment Simulator (WHIS)  
%% 和大模擬難聴システム  
%% Copyright (c) 2010-20xx  Wakayama University   
%% All rights reserved.　  
%% by Toshio Irino ,  24-Mar-2022
%%    
%% ======================================================================    
  
  
本資料の内容：   
1. ソフトウェアの構成  
2. 模擬難聴システム(GUI version)の使い方  
3. 模擬難聴、操作手順 
4. Batch処理手順と対応ソフト  　  
5. 内部処理と音圧レベル  　  
6. 使用するヘッドホンやマイクについて  
7. 簡易音圧調整治具 「ちょめジグ」  
  
  
---  
  
1. ソフトウェアの構成と設定  
  
- 動作には、GCFBv233が必要です。以下のようにLocal directoryで設定してください。  
   - [LocalDir]/WHIS/WHISv301  
   - [LocalDir]/gammachirp-filterbank/GCFBv233   
   - Hearing lossの設定は、GCFBv233を使っています。そちらを参照のこと  
  
- WHIS_GUI :  GUI version of WHIS  
  
- WHISv30_Batch: Batch version of WHIS  
  
- testWHISv302v226_Batch.m : test program for WHISv301 (dtvf & fbas) & v226 for comparison  
  
- Snd_Hello123.wav :   Sample sound  
  
- There are some other programs.  
  
---  
  
2. 模擬難聴システム(GUI version)の使い方  
    （ Document/GUI_UserManual.pdf も参照のこと）  
  
 - 起動法：    
 ＞＞ StartupWHIS    
 ＞＞ WHIS_GUI    
 これにより、変数をclearし、WHIS_GUIを起動します。  
  
- 作業directoryとして、以下が自動的に設定されます。（2019/1/12)  
	Mac:	/Users/[UserName]/Data/WHIS   
	Win:  C:¥Users¥[UserName]¥Data¥WHIS   
    ただし、別のところにsaveしたい場合は、saveする時点で選べます。 
  
- 立ち上がると、まず音圧キャリブレーションが必要です。    
  
- 音圧キャリブレーション  (WHIS_GUI)   
   １）　一番下パネルの[Playボタン]を押して、基準となるキャリブレーショントーン( sin波, 1kHz, 80dB)を出す。  
    - ５秒間流れます。    
    - 音圧設定の意味合いを理解するためには、以下の「4. 内部処理と音圧レベル」をご参照ください。  
  
	２）　人工耳＋サウンドレベルメータ（6. 参照)で、その音が80dBとなるように、オーディオデバイスの「出力」を設定。  
	  - これで、ヘッドホン出力が80 dBに設定されました。以降、出力レベルを動かしてはいけません。    
  
  ３）　ヘッドホンをつけた人工耳のマイクの近く（ヘッドホンの中）に小型の収録用マイクを設置。  
	  - 密閉がくずれないように設置してください。漏れがあると多少音圧が変わります。オーディオの入力設定でマイクの音が直接パソコンに入るように。  
  
	４）　キャリブレーショントーンを再生し、このマイクの音を収録。  
  
	５）　同じ中央パネル内にある[Replayボタン]で、マイクで収録された音を再生。  
  
	６）　この再生された音が８０dBとなるように、マイクゲインを調整して３）からの手順を繰り返す。  
	  - これで、システムにマイク入力で録音されたものも、80dBに対応するようになります。これにより、入出力両方とも80 dBの基準を覚えさせられます。  
	  
	７）　中央パネルの下向き矢印をクリックして、音をsave。~/tmp/　フォルダが必要です。  
	  
	８）　上記手順が終わると、あとはいままでどおり模擬難聴システムが使えます。  
  
---  
  
3. 模擬難聴、操作手順　 
  
   １）　一番上のオージオグラム選択   
   ２）　圧縮特性選択   
   ３）　マイクで音を収録    
   ３’）　録音された音をファイルから読み出す。   
	    - defaultでは、この音はrmsレベル（Leq）で65dBとみなします。  
	      違う値にしたい場合は、その下の選択ボタンで適宜選択。音圧の意味あいは、4. 参照。    
  
	４）　模擬難聴処理／Processingで信号処理開始   
	５）　模擬難聴音が流れます。これと原音声は一番下のパネルで再度再生可能。  
	    - rms level = Leqも表示されるので参考まで  
  
---  
  
4. Batch処理手順と対応ソフト　 
  
  - WHISv30_Batch  
    - 聴覚心理実験用の音声刺激音をを自動的に生成するために、Batch処理用の関数を用意しました。  
    - 使用法は、testWHISv302v226_Batch.m を実行/内容を見て確認。  
  
---  
  
5. 内部処理と音圧レベル    
  
  - コンピュータは、外界の世界を知りません。  
    内部で生成したディジタル信号が、外界で音圧レベルSPL (Leq)で何 dBであるかを教えることが1. の作業手順となっています。  
  
  - 内部では、ディジタルのRMS level で　-26 dBのsin 波をCalibration toneとしています。  
  - この音が、外界で測定した時に音圧レベルSPL (Leq)で何 dBとなるかを設定します。  
  - この模擬難聴システムGUI WHIS_GUIの場合には、これを80 dBとしました。  
    -	[内部RMS level  -26 dB]  == [外界での音圧レベルSPL (Leq) 80 dB]  
    - これが、模擬難聴システムでのすべての音圧の基準となります。  
  
  - 問題：　ある音ファイルがあって、そのディジタルRMS level が x dBだったとします。  
    この音は、外界のSPL で何 dBでしょうか？  
     - 答は：　　x + 26 + 80 (dB)  
  
  - WHISv30_Batchの場合は、Calibration toneのSPLを任意に選べます。  
  
  - WHISの音声に関してのnormalizationはRMS値(Leq)で行っています。  
    - A特性等(L_Aeq)の話を入れるとややこしくなるので入れていません。  
    - そもそもA特性の元になった等ラウドネス曲線は健聴者特性ですので、WHISにはふさわしくありません。
  
---   
  
6. GUI版で使用するヘッドホンやマイクについて   
  - ヘッドホン：　  
	  - ゼンハイザーHD580や後継機種や、SONY MDR-AM2は信頼できそうです。  
  	- 4000円程度のヘッドホンでも演習で用いる程度であれば一応大丈夫そうです。それ以下はやめた方が良いかと思います。  
	  
  - マイク：　  
   - 外部マイクが必須です。音圧校正ができないといけないので、パソコンのマイクでは正確に模擬できません。  
	  - 小型のラベリアマイク/ピンマイク型（例えばDPAのミニチュアマイクDPA4060等）を使えると良いですが、高価でオーディオインタフェースも必要な場合もあります。  
	  - USBに直接接続できるマイクを使うのが良いと思います。  
      - たとえば、ラベリアUSB-Cマイクの、BOYA BY-M3は安い割に使えそうです。  　
      - Winマシンに直接つなぐアナログマイクはハム音を拾うのでやめておいた方が良いと思います。  
	    - 机におけるPC用のUSBマイクは選択肢の一つですが、軸が太いと密閉できず不正確になります。  
  
  - オーディオインタフェース：  
    - DA変換：　SONY Walkman NW-A55は、ハイレゾ対応のUSB DACとしては推奨できます。  
    	- ボリューム設定の値がディジタル表示されるので、再現性良く使えます。  
	  - AD変換：　アナログマイクを使用する場合は必要となります。  

--- 

7. 簡易音圧調整治具 「ちょめジグ(ChomeJig)」  
  - 人工耳とサウンドレベルメータは、高価(B&Kでそろえると150万円コース)なので、通常は所持していないと思います。  
  - そこで、規定の音圧レベルにおおよそ設定をできるように、「ちょめジグ」という簡易音圧調整治具を開発しています。   
	  - See http://www.wakayama-u.ac.jp/~irino/Making/   
    -	See http://www.wakayama-u.ac.jp/~irino/Making/ChomeJig_Guide_5Jan18.pdf   
    - なお論文等のため、正確な音圧を測定する必要のある実験には使えないことにご注意ください。  
    - あくまで、簡易にGUIを使うための道具です。  
     
   - ChomeJigは、研究／教育目的であれば、貸出することができます。  
     - なお、改善のため、使用レポートを提出していただくことを貸出の条件としたいと思います。  
     - ご相談ください。  
  
  
8. 資料 ("Document"以下に置いてある)  
  
  - GUI_UserManual.pdf  
    User manual of GUI  
  
  - ReportJpn_ASJHdec21JpTaiwan_I.pdf  
    Toshio Irino, "A new implementation of hearing impairment simulator WHIS based on the gammachirp auditory filterbank (ガンマチャープ聴覚フィルタに基づく模擬難聴システム WHIS の新実装)," The 3rd Japan-Taiwan Symposium on Psychological and Physiological Acoustics, Proc. Auditory Res. Meeting, The Acoustical Society of Japan, Vol.51, No.8, pp.545-550, H-2021-102, 2021. (in Japanese. English paper is under preparation.)  
  
  - AbstEng_ASJHdec21JpTaiwan_I.pdf  
    Extended abstract for ReportJpn_ASJHdec21JpTaiwan_I.pdf  
  
---  
  
- 本資料の情報   
最終更新日：　2022/3/24
履歴：　2022/3/20 (WHISv302)
履歴：　2022/3/6 (WHISv301)
履歴：　2022/2/27 更新 (adding Document）   
履歴：　2021/12/5 更新 (WHISv300対応）  
履歴：　2020/9/5 更新 (WHIS_v225で起動するように記述変更）  
履歴：　2019/1/12 更新 (作業directoryに関して追加）  
履歴：　2018/12/27 更新 ([４] 内部処理と音圧レベル　[５][６]　を追加）  
履歴：　2018/12/14a更新   
履歴：　2018/07/08 更新 (Batch処理用の関数)  
履歴：　2017/08/08 初版  
 
  入野＠和歌山大学  
	e-mail：irino@sys.wakayama-u.ac.jp  




