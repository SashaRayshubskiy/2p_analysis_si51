function [ value ] = si51_frame_string_get_value_for_key( frameString, key );

cc = strsplit(frameString, '\n');

value = '';
for i=1:length(cc)
    str_tokenized = strtrim(strsplit(cc{i},'='));
    
    if(~isempty(findstr(str_tokenized{1}, key)))
        value = str2num(str_tokenized{2});
    end
end

end

