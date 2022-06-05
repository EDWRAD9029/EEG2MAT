function [data_is_contained_trigs,trig] = BrainVision_readmarker_0003(filename,filepath)
%% config for error
warning('on');

%% open the file
[fid,~] = fopen(strcat(filepath,filename,'.vmrk'));

% this is used when reading the file
i=1; % this display the number of trigger.count up when this find the trigger
segCounter = 0; %the trigger is nothing if this is 0,but the trigger exists

while 1
    % read the char class's line from the file.
    % return the -1 if reading EOF(end of file) 
	dataStr = fgetl(fid);

    % break this loop if dataStr is not char class
	if ~ischar(dataStr), break, end
	
    %% pick up the trigger
    % check the line contained "MK"
    % you get error if you use function "contains".because the line "; Eachentry: Mk<"
	if strncmp(dataStr,'Mk',2)
        % check the line contained "New Segment"
        if  contains(dataStr,'New Segment')
            segCounter = segCounter + 1;
            i = 1;
        end 

        % t1={0*0 char} 1*1cell class if MK1
        % t1={'S 1'} after MK2
		[t1, t2] = strread(dataStr,'%*s%s%d%*f%*f','delimiter',',');

		str = t1{1};
        % read the data from MK1
		if ~isempty(str)
			res{segCounter,1}(i) = str2double(str(2:end));
			res{segCounter,2}(i) = t2;
			i=i+1;
		end

	end
end
if i == 1
    data_is_contained_trigs = 0;
else
    data_is_contained_trigs = 1;
end

%% close the file
fclose(fid);

%% display the warning if the trigger is nothing
if data_is_contained_trigs == 0
	warning("BrainVision_readmarker  this data doesn't contain the trigger.");
    % this is needed for avoiding error
    out = [0 0 0;0 0 0;];
end

%% if the trigger exists
% default
% set trigger calues and it's times to variable "out"
if data_is_contained_trigs == 1
	out =  [res{1,1};res{1,2}];
else
% if some tirrgers exist
	cnt = 1;
	for i=1:data_is_contained_trigs
		if ~isempty(res{i,1}) % only if there is data in segment
			out{cnt} = [res{i,1};res{i,2}];
			cnt = cnt + 1;
		end
    end
end

%% return the trigger
if numel(out) == 1
	trig = out{1};
else
	trig = out;
end
