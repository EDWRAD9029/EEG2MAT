function [data,fs,chName,meta] = BrainVision_loadeeg_0005(filepath,filename)
%% get the configuration from VHDR file
try
    [fs,chName,meta] = BrainVision_readheader_0005(filepath,filename);
catch
    error("error : Could not get any of fs, chname, meta from BrainVision_readheader ");
end
nChans = numel(chName);

%% データフォーマットがBINARYか確認
if ~strcmpi(meta.DataFormat, 'binary')
	error("error : BrainVision_loadeeg  this program has only binary's system.");  
end

%% データ型に応じてメモリ単位を調整
switch lower(meta.DataType)
    case 'int_16',        binformat = 'int16'; bytesPerSample = 2;
    case 'uint_16',       binformat = 'uint16'; bytesPerSample = 2;
    case 'ieee_float_32', binformat = 'float32'; bytesPerSample = 4;
    otherwise, error('Unsupported binary format');
end

%% .eegファイルを開く
fp = fopen(strcat(filepath,filename,'.eeg'),'r');

%% ファイルを先頭から最後まで読み込む
fseek(fp, 0, 'eof');

%% 合計文字数を算出
totalBytes =  ftell(fp);

%% 1チャネル1測定分のメモリ*チャネル数でわり、合計のframe数を算出
nFrames =  totalBytes / (bytesPerSample * nChans);

%% 4bite(32bit)の浮動小数点値として初期化
data = single( zeros(nChans,nFrames) );

%% .eegデータを読み込む
switch lower(meta.DataOrientation)
    case 'multiplexed'
        % ファイルでの参照位置を先頭にする
		frewind(fp);
        % 各値、binformatとして読み取り、float32に変換し保存
		data = fread(fp, [nChans, nFrames], [binformat '=>float32']);
        % ファイルを閉じる
		fclose(fp);
    case 'vectorized'
		error('Reading vectorized binary is not Not implemented')
    otherwise
		error('Not implemented')
end


%% スケール調整する
data = (data .* repmat(meta.scaleFactor',1,size(data,2)))';
