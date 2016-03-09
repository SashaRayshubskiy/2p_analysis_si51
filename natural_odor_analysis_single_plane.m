%% Load ScanImage 5.1 imaging data
clear all;
close all;

if isunix() == 1
slash = '/';
else
slash = '\';
end

%datapath = 'B:\Sasha\second_test_12_03_2015\';
%datafile = 'right_LH_PB_7um_16slices_80_volumes_00002.tif';

%datapath = 'B:\Sasha\first_test_12_02_2015\';
%datafile = 'LH_80_volumes_14_slices_00011.tif';

datapath = 'B:\Sasha\160308_nsyb_01\';

analysis_path = [datapath 'analysis'];

if(~exist(analysis_path, 'dir'))
    mkdir(analysis_path);
end

sid = 7;
trial_str = 'RightOdor';
    
search_path = [datapath '*' trial_str '*_sid_' num2str(sid) '_*.tif'];
files = dir(search_path);
        
for i=2:size(files,1)
    filename = files(i).name;
    
    filepath = [datapath slash filename];
    
    cur_data = open_tif_fast_single_plane(filepath);
    DATA_ALL(i,:,:,:,:) = cur_data;
    disp(['Loaded file: ' filepath]);
end

% [ numLines, numPixels, num_planes, num_volumes ]
DATA = squeeze(DATA_ALL); % the squeeze is needed to remove the channel dimension. There should only be 1. 
AVG_DATA = squeeze(mean(squeeze(DATA)));

% Drop initial volumes here
% DATA = DATA(:,:,:,3:end);

FR = 104.32;
dt = 10;
data_end = 670;
DATA_new = squeeze(mean(reshape(DATA(:,:,:,1:data_end), [ size(DATA,1), size(DATA,2), size(DATA,3) dt, size(DATA(:,:,:,1:data_end),4)/dt ]),4));
DATA = DATA_new;
FRAMES = size(DATA,4);

SUBAXIS_ROW = 2;
SUBAXIS_COL = 2;
file_writer_cnt = 1;

%% Show average images
SPACING = 0.01;
PADDING = 0;
MARGIN = 0.05;

f = figure;
for i=1:PLANES
    subaxis(SUBAXIS_ROW,SUBAXIS_COL,i, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
    
    imagesc(squeeze(mean(mean(squeeze(DATA(:,:,:,i,:)),4),1)));
    colormap gray;
    caxis([0 1000]);
    axis image;
    axis off;
end

saveas(f, [analysis_path '\' datafile '_mean_slices_in_volume.fig']);
saveas(f, [analysis_path '\' datafile '_mean_slices_in_volume.png']); 


%%
TPRE = 3.0;
STIM = 0.5;
fname = [analysis_path '\sid_ ' num2str(sid) '_' trial_str '_clicky_df_f_' num2str(file_writer_cnt)];
[roi_points, intens] = clicky_all_data_df_f(double(DATA), FR/dt, TPRE, STIM, fname);
file_writer_cnt = file_writer_cnt + 1;

%% Get response timeocourse in ROI
REFERENCE_PLANE = 7;

fname = [analysis_path '\' trial_str '_ref_plane_' num2str(REFERENCE_PLANE) '_clicky_df_f_' num2str(file_writer_cnt)];
%[roi_points, intens] = clicky_df_f(squeeze(DATA(1,:,:,REFERENCE_PLANE,:)), FR, fname);
BASELINE_START = 0.1;
BASELINE_END = 3.0;
[roi_points, intens] = clicky_df_f_custom_baseline(squeeze(AVG_DATA(:,:,REFERENCE_PLANE,:)), FR, BASELINE_START, BASELINE_END, fname);
file_writer_cnt = file_writer_cnt + 1;

%% Get correlation image in volume
SPACING = 0.01;
PADDING = 0;
MARGIN = 0.05;

BEGIN_CORR = 8.0;
END_CORR = 11.0;

begin_corr_idx = floor(BEGIN_CORR*FR);
end_corr_idx = floor(END_CORR*FR);

f2 = figure;

DATA = double(DATA);

for i=1:PLANES
    subaxis(SUBAXIS_ROW,SUBAXIS_COL, i, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
    rho = corr(squeeze(intens(1,begin_corr_idx:end_corr_idx))', reshape(squeeze(AVG_DATA(:,:,i,begin_corr_idx:end_corr_idx)), [size(AVG_DATA,1)*size(AVG_DATA,2) size(AVG_DATA(:,:,:,begin_corr_idx:end_corr_idx),4) ])' );
    corr_img = reshape(rho', [size(AVG_DATA,1),  size(AVG_DATA,2)]);
    imagesc( corr_img );
    %caxis([-0.2 0.2]);
    axis image;
    axis off;
    colormap jet;
    %colorbar;
end

saveas(f2, [analysis_path '\corr_in_volume_' num2str(file_writer_cnt) '.fig']);
saveas(f2, [analysis_path '\corr_in_volume_' num2str(file_writer_cnt) '.png']); 

%% Play movie frame by frame
figure;
for i=1:VOLUMES
    imagesc(squeeze(DATA(:,:,1,i)));
    colormap gray;
    title(['Volume number: ' num2str(i)]);
    pause(0.1)    
end

%% Play movie frame by frame
figure;
for i=1:VOLUMES
    for j=1:PLANES
        subaxis(SUBAXIS_ROW,SUBAXIS_COL, i, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
        
        imagesc( squeeze(DATA(:,:,j,i)) );
        colormap gray;
        caxis([0 4000]);
        axis image;
        axis off;
    end
    
    title(['Volume number: ' num2str(i)]);
    pause(0.1)    
end


