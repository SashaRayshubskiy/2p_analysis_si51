%% Convert .avi to .mat

basepath = 'C:\Users\WilsonLab\Desktop\Sasha\HW_Task_pebbled_gcamp3_2014_12_27\';

avifilename = 'right_2014-12-27-182258-0000';
%avifilename = 'left_2014-12-27-182346-0000';

avipath = [basepath avifilename '.avi'];

mov=VideoReader(avipath);
nFrames=mov.NumberOfFrames;

clear avidata;
dx = 1;
dy = 1;
avidata = zeros(mov.Height/dx, mov.Width/dy, nFrames/4);

for i=1:nFrames/4
  videoFrame=read(mov,4*i);
  I = rgb2gray(videoFrame);
  
  %I_downsampled = squeeze(mean(squeeze(mean(reshape(I, [mov.Height/dx, dx, mov.Width/dy, dy]), 4)), 2));
  I_downsampled = I(1:dx:end, 1:dy:end);
  
  %imshow(I_downsampled);
  avidata(:,:,i) = I_downsampled;
end

disp('got here');
save([basepath avifilename '.mat'], 'avidata', '-mat', '-v7.3');
