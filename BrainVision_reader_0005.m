function [] = BrainVision_reader_0005(filename,filepath,text_added,mat_file_version)
% this traslate the EEG file to the MAT file
% this need EEG,VHDR,VMRK files
% this need the meta data file made by eeg2mat.m
%% make the file name omited extension
filename = extractBefore(filename,'.');

%% check files
if exist(strcat(filepath,filename,'.vhdr'),'file')==0
    error("error : BrainVision_reader  vhdr file don't exist.");
end
if exist(strcat(filepath,filename,'.vmrk'),'file')==0
    error("error : BrainVision_reader  vmrk file don't exist.");
end
if exist(strcat(filepath,filename,'.eeg'),'file')==0
    error("error : BrainVision_reader  eeg file don't exist.");
end

%% get the time(this time is file's traslated time)
time_exchanged = datetime;

%% pick up the trigger from VMRK file
% data_is_contained_trigs : trig's set number
%   trigger is nothing  if data_is_contained_trigs is 0
%   default 1
% trig : trigger value and it's times
try
    [data_is_contained_trigs,trig] = BrainVision_readmarker_0003(filename,filepath);
catch
    warning("warning : Could not get any of data_is_contained_trigs, trig from BrainVision_readmarker ");
end

%% read the values and configuration from VHDR file
try
    [data,fs,chName,meta] = BrainVision_loadeeg_0005(filepath,filename);
catch
    error("error : Could not get any of data, fs, chName, meta from BrainVision_loadeeg ");
end

%% Frame数とCh数の確認
iframe = length(data(:,1));
iChan = length(chName);

%% 出力トリガーの初期化
trigger = zeros(iframe,1);
% データにトリガーが含まれている場合
if data_is_contained_trigs
    type = trig(1,:);
    num = trig(2,:);
    for n = 1:length(type)
        trigger(num(n)) = type(n);
    end
end

%% 出力の形式に整える
% eeg.data = double(data);
% eeg.trig = trigger;
% eeg.Fs = fs;
% eeg.fileName = filename;
% eeg.filepath = filepath;
% eeg.meta = meta;
% eeg.time_exchanged = time_exchanged;
% 
% tmp = strings([1,iChan]);
% for n=1:length(tmp)
%     tmp(n) = cell2mat(chName(n));
% end
% eeg.ChName = tmp;
% 
% eeg.time = (1:iframe)/fs;
% 
% eeg.mat_file_version = mat_file_version;

% 
eeg_data = double(data);
eeg_trig = trigger;
eeg_Fs = fs;
eeg_fileName = filename;
eeg_filepath = filepath;
eeg_meta = meta;
eeg_time_exchanged = time_exchanged;
tmp = strings([1,iChan]);
for n=1:length(tmp)
    tmp(n) = cell2mat(chName(n));
end
eeg_ChName = tmp;
eeg_time = (1:iframe)/fs;
eeg_mat_file_version = mat_file_version;


%%
% ===============================================================
variable_name_output = "eeg";
eeg.data = eeg_data;
eeg.trig = eeg_trig;
eeg.Fs = eeg_Fs;
eeg.fileName = eeg_fileName;
eeg.filepath = eeg_filepath;
eeg.meta = eeg_meta;
eeg.time_exchanged = eeg_time_exchanged;
eeg.ChName = eeg_ChName;
eeg.time = eeg_time;
eeg.mat_file_version = eeg_mat_file_version;
% ===============================================================

%% 現在のパスを確認
dir_now = dir;
dir_now = dir_now(1).folder;

%% データがあるフォルダに移動
cd(filepath);

%% .matで保存する
save(strcat(filename,text_added),variable_name_output,mat_file_version);

%% 元のフォルダに戻る
cd(dir_now);

%% 終了を知らせる
fprintf('complete %s\n',filename);

end