
% translate eeg,vhdr,vmrk files(multiple selection support)
% viable without triggers

% ※ Precautions ※
% delete old version paths if you added old versions

clear all;
format compact;
%% =============== you can use options =================
%% you can add character string behind the file name.
% ----------------------------------
% |  example                        |
% | load file name = AAA            |
% | text_added = BB                 |
% | output file name = AAABB        |
% ----------------------------------
% if you add nothing
text_added = [];
% text_added = '_pre';
% text_added = '_short';

%% change the MAT file version
% mat_file_version = '-v6';
mat_file_version = '-v7.3';

% ===============================================================


%% select the EEG file(one or more)
% keep Ctrl key pressed if you select some files
[filename, filepath] = uigetfile( {'*.vmrk'}, ...
    'select the EEG files','MultiSelect','on');

%% check the number of files
% filename's data class is char if number is one
% filename's data class is cell if number is some
if ischar(filename)
    file_Length = 1;
else
    file_Length = length(filename);
end

%% if you select one file
if file_Length == 1
    fprintf('load %s\n',extractBefore(filename,'.'));
    BrainVision_reader_0005(filename,filepath,text_added,mat_file_version);
end

%% if you select some files
if file_Length > 1
% translate filename from cell class to char class
filename1 = filename;
for n=1:file_Length
    filename = cell2mat(filename1(n));
    fprintf('[%d / %d] load %s\n',n,file_Length,extractBefore(filename,'.'));
    BrainVision_reader_0005(filename,filepath,text_added,mat_file_version);
end
end

%% notify ends
fprintf("complete all\n");
clear file_Length filename filepath n text_added dir_eeg2mat BrainVisionReader mat_file_version filename1
