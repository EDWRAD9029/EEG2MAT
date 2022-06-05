EEG2MAT version2.0
更新日時 2022/02/24

EEGファイルをMATファイルに変換するプログラムです。
測定時からファイル名を変更していても、.eeg .vhdr .vmrkが同じ名前なら変換できます。
実験条件であるSoftwareFilterやLowCut等の設定、インピーダンスの測定値も取り出せます。
トリガー入力していないデータも変換できます。


＜動作確認環境＞
OS　　	:Windows10home x64（オプションのMATファイルバージョン変更機能以外はx84で動作するはずです）
MATLAB	:MATLAB2020a、MATLAB2021a（R14 version7.0 以降であれば動作するはずです）
Linux、Mac環境では動作しない場合があります(shellスクリプトの都合上)。


＜使い方＞
1.以前のバージョンが存在する場合はパスから削除してください。
	A.MATLAB上部にある「ホーム」タブより「パスの設定」を選択
	B.対象のフォルダを選択
	C.「削除」を選択し、「保存」
2.MATLABを起動し、「EEG2MAT」フォルダに含まれているすべてのファイルのパスを通します。
	A.MATLAB上部にある「ホーム」タブより「パスの設定」を選択
	B.「サブフォルダーも追加」を選択
	C.ダウンロードした「EEG2MAT」を選択し、「保存」
3.eeg,vhdr,vmrkファイルが同じ場所、同じ名前であることを確認する。
4.eeg2mat.mを実行
	A.ダイアログがでたら変換したいファイルを１つ、または複数選択(ctrl押しながらで複数選択できる)する（複数選択は同じフォルダに入っている場合に限る）。


＜利用上の注意点＞
1.サンプリング周波数が10のべき乗で割り切れない場合は正常に動作しない場合があります。
2.EEG,VHDR,VMRKのファイル名に拡張子以外の"."を含めないようにしてください。正常に動作しなくなります。
3.MATファイルの保存バージョンをデフォルトで7.3としていますが、公式は7を規定としています。古いMATLABバージョンを使っていなければ問題はありませんが、一度リファレンス<https://jp.mathworks.com/help/matlab/import_export/mat-file-versions.html>を確認してください。


＜トラブルシューティング＞
■変数～が保存されませんでした。変数が2GBを超える場合は、MATファイル Version7.3以降を使用してください。
　変数が大きいため、旧MAT形式では保存できません。eeg2matのオプションとしてmat_file_version = 7.3と指定してください。制限としてMATLABバージョンやOSが存在するので、詳細は公式リファレンスへ<https://jp.mathworks.com/help/matlab/import_export/mat-file-versions.html>
■error : BrainVision_reader  vhdr file don't exist.
　VHDRファイルが読み込めません。考えられる要因は以下です。
	・ファイルが存在しない
	・VMRKファイルと同じ場所に存在しない
	・パスが通っていない
	・ファイル名がVMRKファイルと統一されていない
	・ファイル名に拡張子以外の"."が存在する
■error : BrainVision_reader  vmrk file don't exist.
　VMRKファイルが読み込めません。考えられる要因は以下です。
	・パスが通っていない
	・ファイル名に拡張子以外の"."が存在する
■error : BrainVision_reader  eeg file don't exist.
　EEGファイルが読み込めません。考えられる要因は以下です。
	・ファイルが存在しない
	・VMRKファイルと同じ場所に存在しない
	・パスが通っていない
	・ファイル名がVMRKファイルと統一されていない
	・ファイル名に拡張子以外の"."が存在する
■error : BrainVision_readheader Channels
　VHDRファイルの＜Channels＞セッションを正常に読み込めません。作成者に問い合わせてください。
■warning : BrainVision_readheader SoftwareFilters
　VHDRファイルの＜SoftwareFilters＞セッションを正常に読み込めません。作成者に問い合わせてください。
　出力変数から＜SoftwareFilters＞が削除された状態で出力されます。
■warning : BrainVision_readheader Inpedance configuration
　VHDRファイルの＜Inpedance configuration＞セッションを正常に読み込めません。作成者に問い合わせてください。
　出力変数から＜Inpedance configuration＞が削除された状態で出力されます。
■warning : BrainVision_readheader Ground Inpedance configuration
　VHDRファイルの＜Ground Inpedance configuration＞セッションを正常に読み込めません。作成者に問い合わせてください。
　出力変数から＜Ground Inpedance configuration＞が削除された状態で出力されます。
■warning : BrainVision_readheader Reference Inpedance configuration
　VHDRファイルの＜Reference Inpedance configuration＞セッションを正常に読み込めません。作成者に問い合わせてください。
　出力変数から＜Reference Inpedance configuration＞が削除された状態で出力されます。
■warning : BrainVision_readheader Inpedance value
　VHDRファイルの＜Inpedance value＞セッションを正常に読み込めません。作成者に問い合わせてください。
　出力変数から＜Inpedance value＞が削除された状態で出力されます。
■warning : Could not get any of data_is_contained_trigs, trig from BrainVision_readmarker
　トリガーの読み込みができません。作成者に問い合わせてください。
■error : Could not get any of data, fs, chName, meta from BrainVision_loadeeg
　loadeeg関数を正常に動作できません。作成者に問い合わせてください。
■error : BrainVision_loadeeg  this program has only binary's system.
　EEGファイルがバイナリファイルになっていません。別フォーマットの場合は作成者に問い合わせてください。
■Unsupported binary format
　EEGファイルのデータ型がサポートされていません。作成者に問い合わせてください。
　サポートされている型は'int_16','uint_16','ieee_float_32'です。
■Reading vectorized binary is not Not implemented
　EEGファイルの変数保存方式は'vectorized'をサポートしていません。作成者に問い合わせてください。
　EEGファイルの変数保存方式は'multiplexed'のみ実装しています。
■Not implemented
　EEGファイルの変数保存方式がサポートされていません。作成者に問い合わせてください。
　EEGファイルの変数保存方式は'multiplexed'のみ実装しています。
■BrainVision_readmarker  this data doesn't contain the trigger.
　このデータにはトリガーが存在しません。


＜デフォルトでのデータ型＞
※VHDR,VMRKにパラメータが存在しない場合はその要素は存在しなくなります。
※デフォルトでの構造です。変更している場合は出力変数が異なります。
eeg
|- time(1×データ長)
|- data(データ長×チャネル数)
|- trig(データ長×1、存在しない場合はない)
|- ChName(1×チャネル数)
|- Fs(Hz)
|- fileName(変換したeegファイル名)
|- filepath(eegファイルのあった場所)
|- time_exchanged(eegからmatへ変換した時刻)
|- meta
   |- PhysChn(実験時の物理チャネル番号)
   |- Channels
      |- LowCutoff
      |- HighCutoff
      |- Notch
   |- SoftwareFilters
      |- LowCutoff
      |- HighCutoff
      |- Notch
   |- Impedance(インピーダンス最終測定時のレンジと大きさ、時刻)
   |- eegFile(実験時のeegファイル名)
   |- DataFormat(eegファイルの保存形式)
   |- DataType(eegファイルの保存形式)
   |- DataOrientation(eegファイルの保存形式)
   |- scaleFactor(各チャネルのスケール)
|- mat_file_version(MATファイルのバージョン)


＜データ型の変更方法＞
BrainVision_readerを開き、'＝'で囲まれた範囲(デフォルトでは93行目～103行目)を編集してください。
具体的な操作は以下を参照してください。
■出力変数の名前を変更する場合
　変数variable_name_outputに文字列として代入し、それ以降の'eeg.*'を全て置き換えてください。
■データ構造を変更する場合
　変数eeg_*に各データが格納されています。変数variable_name_outputで指定した名前に集約されるように構築してください。
　その際、eeg.*の箇所を変更することで、出力変数名以外の内部の名前も変更できます。
