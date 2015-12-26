function [ num_channels, num_planes, num_volumes ] = parse_si51_frame_string( frameString );

cc = strsplit(frameString, '\n');

num_channels = 1; 
num_planes = 1;
num_volumes = 1;

for i=1:length(cc)

    str_tokenized = strtrim(strsplit(cc{i},'='));
    %disp(str_tokenized);
    
    if(~isempty(findstr(str_tokenized{1}, 'hChannels.channelsActive')))
        num_channels = str2num(str_tokenized{2});
    elseif(~isempty(findstr(str_tokenized{1}, 'hFastZ.numFramesPerVolume')))
        num_planes = str2num(str_tokenized{2});        
    elseif(~isempty(findstr(str_tokenized{1}, 'hFastZ.numVolumes')))
        num_volumes = str2num(str_tokenized{2});
    end
end

end

