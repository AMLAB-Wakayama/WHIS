%% ======================================================================
%%
%% README file for Wadai (Wakayama University) Hearing Impairment Simulator (WHIS)
%%  和大模擬難聴システム
%% Copyright (c) 2010-20xx  Wakayama University
%% All rights reserved.
%% By Toshio Irino , 2-Dec-2021  
%% ======================================================================


本資料の内容：
[1]  ソフトウェアの構成
[2]　模擬難聴システム(GUI version)の使い方
[3]　模擬難聴、操作手順　
[4]　Batch処理手順と対応ソフト　
[5]  内部処理と音圧レベル　　
[6]　使用するヘッドホンやマイクについて 
[7]　簡易音圧調整治具 「ちょめジグ」


―――――
[1]  ソフトウェアの構成と設定

動作には、GCFBv231が必要です。以下のようにLocal directoryで設定してください。
[LocalDir]/WHIS/WHISv300
[LocalDir]/gammachirp-filterbank/GCFBv231
Hearing lossの設定は、GCFBv231を使っています。そちらを参照のこと

WHISv300_GUI :  GUI version of WHIS

WHISv300_Batch: Batch version of WHIS

testWHISv300v226_Batch.m  
    test program for WHISv300 (dtvf & fbas) & v226 for comparison

Snd_Hello123.wav 
    Sample sound

ShowIOfunc_WHISv300CamHLS_GCFBv231.m
    Calculation of Input-Output function using GCFB, WHIS, and CambHLS_(Not provided here)

ShowSpec_WHISv300CamHLS_GCFBv231.m
    Calculation of spectrogram using GCFB, WHIS, and CambHLS_(Not provided here)

ShowIOfunc_GCFBWHISCamHLS.m
    Showing IO function after finishing ShowIOfunc_WHISv300CamHLS_GCFBv231.m

There are some other programs.



[2]　模擬難聴システム(GUI version)の使い方
    （ WHIS_GUImanual_v225-300.pdfも参照のこと）

起動法：　
>> StartupWHIS 
>> WHISv300_GUI

これにより、変数をclearし、WHIS_GUIを起動します。

作業directoryとして、以下が自動的に設定されます。（2019/1/12)
	Mac:	/Users/[UserName]/Data/WHIS 
	Win:  C:¥Users¥[UserName]¥Data¥WHIS
ただし、別のところにsaveしたい場合は、saveする時点で選べます。

立ち上がると、まず音圧キャリブレーションが必要です。

＊＊　音圧キャリブレーション　＊＊
	2018/07/08  やり方が多少変わったため、それに伴い、一部改変。

１）　一番下パネルの[Playボタン]を押して、基準となるキャリブレーショントーン( sin波, 1kHz, 80dB)を出す。
		(５秒間流れます。）
		(音圧設定の意味合いを理解するためには、以下の「[4] 内部処理と音圧レベル」をご参照ください。）
２）　人工耳＋サウンドレベルメータ（[６]参照)で、その音が80dBとなるように、オーディオデバイスの「出力」を設定。
		(これで、ヘッドホン出力が80 dBに設定されました。以降、出力レベルを動かしてはいけません。）
３）　ヘッドホンをつけた人工耳のマイクの近く（ヘッドホンの中）に小型の収録用マイクを設置。
		(密閉がくずれないように設置してください。漏れがあると多少音圧が変わります。
		　オーディオの入力設定でマイクの音が直接パソコンに入るように。）
４）　キャリブレーショントーンを再生し、このマイクの音を収録。
		(再生と同時に自動的に収録されます。中央にある[RECボタン]を押す必要がなくなりました。）
５）　同じ中央パネル内にある[Replayボタン]で、マイクで収録された音を再生。
６）　この再生された音が８０dBとなるように、マイクゲインを調整して３）からの手順を繰り返す。
		（これで、システムにマイク入力で録音されたものも、80dBに対応するようになります。
		　これにより、入出力両方とも80 dBの基準を覚えさせられます。）
７）　中央パネルの下向き矢印をクリックして、音をsave。~/tmp/　フォルダが必要です。
８）　上記手順が終わると、あとはいままでどおり模擬難聴システムが使えます。

―――――

[3]　模擬難聴、操作手順　

１）　一番上のオージオグラム選択
２）　圧縮特性選択
３）　マイクで音を収録
３’）　録音された音をファイルから読み出す。
	（defaultでは、この音はrmsレベル（Leq）で65dBとみなします。
	違う値にしたい場合は、その下の選択ボタンで適宜選択。音圧の意味あいは、[４]参照。）
４）　模擬難聴処理／Processingで信号処理開始
５）　模擬難聴音が流れます。これと原音声は一番下のパネルで再度再生可能。
	(rms level = Leqも表示されるので参考まで）

―――――

[4]　Batch処理手順と対応ソフト　 　(2018/07/08)

データを自動的に処理するために、Batch処理用の関数を用意しました。　
HIsimBatchです。
使用法は、
testHIsimBatch
で確認してください。


　3.1) 上記以外のプログラムで重要なもの（備忘録)　(2018/12/14)

	Check_HIsim_IOfuction_sin.m   
		sin波を使い、IO functionのplot をするm-file. 

	HIsimFastGC_MkCmpnstGain.m  
		最終的な出力Gain補正のためのTable作成プログラム。
		これにより、HIsimFastGC_CmpnstGain.matが作成される。
		このmat fileがないと、プログラムは動かない。
		すでにこのdirectoryにあるが、必要に応じ、事前に作っておいておく。

―――――

[5]  内部処理と音圧レベル　　（2018/12/26)

コンピュータは、外界の世界を知りません。
内部で生成したディジタル信号が、外界で音圧レベルSPL (Leq)で何 dBであるかを教えることが[１]の作業手順となっています。

内部では、ディジタルのRMS level で　-26 dBのsin 波をCalibration toneとしています。
	HIsimFastGC_MkCalibTone.mの中で、以下のように記述してあります。
	Tdur = 5; % sec
	fCalib = 1000; % 1 kHz tone
	OutLeveldB = -26;
	AmpCalib    = 10^(OutLeveldB/20)*sqrt(2); % set about the same as recording level
	CalibTone   = AmpCalib*sin(2*pi*fCalib*(0:Tdur*ParamHI.fs-1)/ParamHI.fs);
	
この音が、外界で測定した時に音圧レベルSPL (Leq)で何 dBとなるかを設定します。
この模擬難聴システムの場合には、これを80 dBとしました。すなわち
 	[内部RMS level  -26 dB]  == [外界での音圧レベルSPL (Leq) 80 dB]
と対応づけたことになります。これが、模擬難聴システムでのすべての音圧の基準となります。

それでは、ある音ファイルがあって、そのディジタルRMS level が x dBだったとします。
この音は、外界のSPL で何 dBでしょうか？
答は：　　x + 26 + 80 (dB)
となります。[ 2020/7/15 ミス修正]

	% 以下を実行すると、Calbration toneがRMS levelで-26 dBであることが確認できます。
	ParamHI.fs = 48000;
	Tdur = 5; % sec
	fCalib = 1000; % 1 kHz tone
	OutLeveldB = -26;
	AmpCalib    = 10^(OutLeveldB/20)*sqrt(2); % set about the same as recording level
	CalibTone   = AmpCalib*sin(2*pi*fCalib*(0:Tdur*ParamHI.fs-1)/ParamHI.fs);

	RMSlevel_CalibTone = 20*log10( sqrt(mean(CalibTone.^2)))
	% この式で、同様に、任意の音の　RMS levelも計算できます。

注）A特性等の話を入れるとどんどんややこしくなるので、素直にRMS levelだけにしています。
	要は、ちゃんと定義がされていれば、後で再現できるので。

―――――

[6]　使用するヘッドホンやマイクについて 　（2018/12/26)
安価で十分精度が良いものをいまだに探索中です。探索途中の情報をおきます。

ヘッドホン：　
	- 4000円程度のヘッドホンでも一応大丈夫そうです。それ以下はやめた方が良いかと思います。
	(高) ゼンハイザーHD580や後継機種。

マイク：　　
	- USBに直接接続できるマイクを使うのが良いと思います。（アナログマイクはハム音を拾います。）
	- 密閉に気をつける必要がありますが、机におけるPC用のUSBマイクくらいが妥当な気がします。		可能であれば、ヘッドホンの中にいれても、密閉がくずれないピンマイク型が良いのですが、
		安物を買ったところ、録音開始時に音が安定に取れないことがありました。ご注意。
	(高)   DPA4060 等を使えると良いですが、高価でオーディオインタフェースも必要。

オーディオインタフェース：
	- マイクを何にするかによって異なってきます。高級マイクだと必要です。
	(高)  Zoom UAC-2。

―――――

[7]　簡易音圧調整治具 「ちょめジグ」　（2018/12/26)
人工耳とサウンドレベルメータは、高価(B&Kでそろえると150万円コース)なので、通常は所持していないと思います。
そこで、規定の音圧レベルにおおよそ設定をできるように、「ちょめジグ」という簡易音圧調整治具を開発しています。
http://www.wakayama-u.ac.jp/~irino/Making/
http://www.wakayama-u.ac.jp/~irino/Making/ChomeJig_Guide_5Jan18.pdf
を参照ください。（論文等のため、正確な音圧を示す必要のある実験には使えないことをご注意ください。）

こちらは、研究／教育目的であれば、貸出することはできます。
なお、改善のため、使用レポートを提出していただくことを貸出の条件としたいと思います。
ご相談ください。

ーーーーーーーーーーーーーーーーーー
本資料の情報
更新日：　2021/12/1 更新 (WHISv300で起動するように記述変更）
履歴：　2020/9/5 更新 (WHIS_v225で起動するように記述変更）
履歴：　2019/1/12 更新 (作業directoryに関して追加）
履歴：　2018/12/27 更新 ([４] 内部処理と音圧レベル　[５][６]　を追加）
履歴：　2018/12/14a更新 
履歴：　2018/07/08 更新 (Batch処理用の関数)
履歴：　2017/08/08 初版
文責：入野＠和歌山大学
質問：irino@sys.wakayama-u.ac.jpへ


