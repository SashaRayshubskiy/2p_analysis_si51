function [ aOut ] = open_tif_fast_simple( tifpath, numLines, numPixels, num_planes, num_channels, num_volumes, numImg )
% Output: [Lines, Pixels, Channels, Planes, Volumes]

% Open tiff file
tifObj = Tiff(tifpath,'r');

% Get TIFF information
imageDataType = 'uint16';

aOut_tmp = zeros(numLines,numPixels,numImg,imageDataType);
for idx = 1:numImg
    tifObj.setDirectory(idx);
    aOut_tmp(:,:,idx) = tifObj.read();
end

aOut = reshape(aOut_tmp, [numLines,numPixels, num_channels,num_planes,num_volumes]);

tifObj.close();
end

