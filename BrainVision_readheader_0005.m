function [fs,chName,meta] = BrainVision_readheader_0005(filepath,filename)
%% config for error
warning('on');

%% open the file
fp = fopen(strcat(filepath,filename,'.vhdr'));
if fp == -1
	error("error : BrainVision_readheader_0005.m  VHDR file don't exist.");
end

%% read all lines
raw={};
while ~feof(fp)
    raw = [raw; {fgetl(fp)}];
end

%% close the file
fclose(fp);

%% delete the line contained ;
raw(strmatch(';', raw)) = [];

%% delete the line contained nothing
raw(cellfun('isempty', raw) == true) = [];

%% find the [~] and EOF(end of file)'s line
sections = [strmatch('[', raw)' length(raw) + 1];

%% each sections
for section = 1:length(sections) - 1
    % delete the [] from section's title and lowercase
    fieldname = lower(char(strread(raw{sections(section)}, '[%s', 'delimiter', ']')));
    % delete the space character
    fieldname(isspace(fieldname) == true) = [];

    switch fieldname
        case {'commoninfos' 'binaryinfos'}
            % from after title's line to next title's
            for line = sections(section) + 1:sections(section + 1) - 1
                % divide by =
                [parameter, value] = strread(raw{line}, '%s%s', 'delimiter', '=');
                % declare new variable
                hdr.(fieldname).(char(parameter)) = char(value);
            end
        case {'channelinfos' 'coordinates' 'markerinfos'}
            % from after title's line to next title's
            for line = sections(section) + 1:sections(section + 1) - 1
                % divide by =
                [parameter, value] = strread(raw{line}, '%s%s', 'delimiter', '=');
                % declare new variable(omit the Ch)
                hdr.(fieldname)(str2double(parameter{1}(3:end))) = value;
            end
        case 'comment'
            % copy the comment part
            hdr.(fieldname) = raw(sections(section) + 1:sections(section + 1) - 1);
    end
end

%% ch
ChannelSize = str2num(hdr.commoninfos.NumberOfChannels);

%% sampling frequency
Ts = str2num(hdr.commoninfos.SamplingInterval);
fs = 1000000/Ts;

%% check the comment
% each lines
for i=1:length(hdr.comment)
    datastr = hdr.comment(i);
    % if this contains Channels
    if contains(datastr,'Channels'),Channels_line = i;end
    % if this contains SoftwareFilters
    if contains(erase((cell2mat(datastr)),' '),'SoftwareFilters'),SoftwareFilters_line = i;end
    % if this contains data's impedance
    if contains(datastr,'Data Electrodes Selected Impedance Measurement'),DataImpedance_line = i;end
    % if this contains ground's impedance
    if contains(datastr,'Ground Electrode Selected Impedance Measurement'),GroundImpedance_line = i;end
    % if this contains reference's impedance
    if contains(datastr,'Reference Electrode Selected Impedance Measurement'),ReferenceImpedance_line = i;end
    % check the first impedance's line
    if contains(datastr,'Impedance [k'),Impedance_line = i;end
end

%% Channels
try
    if exist('Channels_line','var')
        % pick up Channels part
        hdr.Channels = hdr.comment(Channels_line+2:Channels_line+2+ChannelSize);
        % set the format 
        % each lines
        for line = 1:length(hdr.Channels)
            % pick up the line
            datastr = cell2mat(hdr.Channels(line));
            % find the space character
            space_mat = isspace(datastr);
            % set the 0 when two or more 1 are connected
            counter = 0;
            for i=2:length(space_mat)
                if space_mat(i)
                    counter = counter + 1;
                else
                    if counter > 1
                        space_mat(i-counter:i-1) = 0;
                    end
                    counter = 0;
                end
            end
            % delete the space charecter if only one
            datastr(space_mat) = [];
            % devide by space character
            datastr = strsplit(datastr,' ');
            % make cell array
            if line == 1
                datastr1 = datastr(1:7);
            else
                datastr1 = [datastr1; datastr(1:7)];
            end
        end
        % check the Resolution's unit

        % each row
        for i=1:length(datastr1(1,:))
            section = datastr1{1,i};
            switch section
                case 'Name'
                    chName = datastr1(2:end,i)';
                case 'Phys.Chn.'
                    meta.PhysChn = zeros(1,ChannelSize)*NaN;
                    for iChan=1:ChannelSize
                        meta.PhysChn(iChan) = str2num(datastr1{1+iChan,i});
                    end
                case 'Resolution/Unit'
                    scale = zeros(1,ChannelSize)*NaN;
                    for iChan=1:ChannelSize
                        if contains(datastr1{1+iChan,i},'ﾂｵ')
                            % case1
                            scale(iChan) = str2num(extractBefore(datastr1{1+iChan,i},'ﾂｵ'));
                        else
                            % case2
                            scale(iChan) = str2num(extractBefore(datastr1{1+iChan,i},'µV'));
                        end
                    end
                case 'LowCutoff[s]'
                    meta.Channels.LowCutoff = zeros(1,ChannelSize)*NaN;
                    for iChan=1:ChannelSize
                        meta.Channels.LowCutoff(iChan) = str2num(datastr1{1+iChan,i});
                    end
                case 'HighCutoff[Hz]'
                    meta.Channels.HighCutoff = zeros(1,ChannelSize)*NaN;
                    for iChan=1:ChannelSize
                        meta.Channels.HighCutoff(iChan) = str2num(datastr1{1+iChan,i});
                    end
                case 'Notch[Hz]'
                    meta.Channels.Notch = datastr1(2:end,i)';
                otherwise
                    % skip
            end
        end
    end
catch
    error("error : BrainVision_readheader Channels");
end

%% SoftwareFilters
try
    if exist('SoftwareFilters_line','var')
       % pick up 'SoftwareFilters' part
       hdr.SoftwareFilters = hdr.comment(SoftwareFilters_line+2:SoftwareFilters_line+2+ChannelSize);
       % adjust the format
       % each lines
       for line = 1:length(hdr.SoftwareFilters)
          % pick up the one line
          datastr = cell2mat(hdr.SoftwareFilters(line));
           % find the space character
           space_mat = isspace(datastr);
           % set to 0 if two or more 1's continue
           counter = 0;
           for i=2:length(space_mat)
               if space_mat(i)
                   counter = counter + 1;
               else
                   if counter > 1
                       space_mat(i-counter:i-1) = 0;
                   end
                   counter = 0;
               end
           end
           % delete the line if it has only one space character
           datastr(space_mat) = [];
           % split by space character
           datastr = strsplit(datastr,' ');
           % make a cell's array
           if line == 1
               datastr1 = datastr(1:4);
           else
               datastr1 = [datastr1; datastr(1:4)];
           end
       end
       % each columns
       for i=1:length(datastr1(1,:))
           section = datastr1{1,i};
           switch section
               case 'LowCutoff[s]'
                   meta.SoftwareFilters.LowCutoff = zeros(1,ChannelSize)*NaN;
                   for iChan=1:ChannelSize
                       if strcmp(datastr1{1+iChan,i},'Off')
                           meta.SoftwareFilters.HighCutoff(iChan) = NaN;
                       else
                           meta.SoftwareFilters.LowCutoff(iChan) = str2num(datastr1{1+iChan,i});
                       end
                   end
               case 'HighCutoff[Hz]'
                   meta.SoftwareFilters.HighCutoff = zeros(1,ChannelSize)*NaN;
                   for iChan=1:ChannelSize
                       if strcmp(datastr1{1+iChan,i},'Off')
                           meta.SoftwareFilters.HighCutoff(iChan) = NaN;
                       else
                           meta.SoftwareFilters.HighCutoff(iChan) = str2num(datastr1{1+iChan,i});
                       end
                   end
               case 'Notch[Hz]'
                   meta.SoftwareFilters.Notch = datastr1(2:end,i)';
               otherwise
                   % skip
           end
       end
    end
catch
    warning("warning : BrainVision_readheader SoftwareFilters");
end

%% Inpedance's configuration
try
    if exist('DataImpedance_line','var')
       % pick up the line
       datastr = hdr.comment{DataImpedance_line};
       % pick up the string from ':' to 'k'
       datastr = extractBefore(extractAfter(datastr,':'),'k');
       % delete the space character
       datastr(isspace(datastr)) = [];
       % add to meta
       meta.Impedance.Data_range = [str2double(extractBefore(datastr,'-')) str2double(extractAfter(datastr,'-'))];
    end
catch
    warning("warning : BrainVision_readheader Inpedance configuration");
end

%% Ground Impedance's configuration
try
    if exist('GroundImpedance_line','var')
       % pick up the line
       datastr = hdr.comment{GroundImpedance_line};
       % pick up the string from ':' to 'k'
       datastr = extractBefore(extractAfter(datastr,':'),'k');
       % delete the space character
       datastr(isspace(datastr)) = [];
       % add to meta
       meta.Impedance.Ground_range = [str2double(extractBefore(datastr,'-')) str2double(extractAfter(datastr,'-'))];
    else
       % add to meta
       meta.Impedance.Ground_range = meta.Impedance.Data_range;
    end
catch
    warning("warning : BrainVision_readheader Ground Inpedance configuration");
end
    
%% Reference Impedance's configuration
try
    if exist('ReferenceImpedance_line','var')
       % pick up the line
       datastr = hdr.comment{ReferenceImpedance_line};
       % pick up the string from ':' to 'k'
       datastr = extractBefore(extractAfter(datastr,':'),'k');
       % delete the space character
       datastr(isspace(datastr)) = [];
       % add to meta
       meta.Impedance.Reference_range = [str2double(extractBefore(datastr,'-')) str2double(extractAfter(datastr,'-'))];
    else
       % add to meta
       meta.Impedance.Reference_range = meta.Impedance.Data_range;
    end
catch
    warning("warning : BrainVision_readheader Reference Inpedance configuration");
end

%% Impedance's value
try
    if exist('Impedance_line','var')
       % calcurate the lines of Impedance's value
       lines = length(hdr.comment) - Impedance_line;
       % pick up the lines
       hdr.Impedance = hdr.comment(Impedance_line+1:Impedance_line+lines);
       % each lines
       for line=1:lines
           % pick up th eline
           datastr = hdr.Impedance{line};
           % delete the space character
           datastr(isspace(datastr)) = [];
           % get the ch name('+','-' are exchanged for 'Plus','Minus' because avoiding error)
           str_name = extractBefore(datastr,':');
           if contains(str_name,'+')
               str_name = strcat(extractBefore(str_name,'+'),'Plus');
           end
           if contains(str_name,'-')
               str_name = strcat(extractBefore(str_name,'-'),'Minus');
           end
           % get the impedance's value
           str_impedance = extractAfter(datastr,':');
           % add to meta
           meta.Impedance.(str_name) = str2num(str_impedance);
       end

       % pick up first line
       datastr = hdr.Impedance{1};
       % pick up the string after the 'at'
       datastr = extractAfter(datastr,'at');
       % delete the space character
       datastr(isspace(datastr)) = [];
       % exchange the format to hh:mm:ss
       datastr = datastr(1:end-1);
       % change the class to duration
       meta.Impedance.time = duration(datastr);
    end
catch
   warning("warning : BrainVision_readheader Inpedance value"); 
end

%% other data
meta.eegFile = hdr.commoninfos.DataFile;
meta.DataFormat = hdr.commoninfos.DataFormat;
meta.DataType = hdr.binaryinfos.BinaryFormat;
meta.DataOrientation = hdr.commoninfos.DataOrientation;
meta.scaleFactor  = scale;

