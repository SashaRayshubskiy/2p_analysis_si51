%% Load ScanImage 5.1 imaging data

%datapath = 'B:\Sasha\second_test_12_03_2015\';
%datafile = 'right_LH_PB_7um_16slices_80_volumes_00002.tif';

%datapath = 'B:\Sasha\first_test_12_02_2015\';
%datafile = 'LH_80_volumes_14_slices_00011.tif';

analysis_path = [datapath 'analysis'];

if(~exist(analysis_path, 'dir'))
    mkdir(analysis_path);
end

[header, aOut,imgInfo] = scanimage.util.opentif([datapath '\' datafile]);

%%
VOLUMES = 80;
PLANES = 16;

%VOLUMES = imgInfo.numVolumes;
%PLANES = imgInfo.numSlices;
DATA = reshape(aOut, [size(aOut,1), size(aOut,2), PLANES, VOLUMES]);


%% Show average images
SPACING = 0.01;
PADDING = 0;
MARGIN = 0.05;

f = figure;
for i=1:PLANES
    subaxis(4,4,i, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
    
    imagesc(mean(squeeze(DATA(:,:,i,3:end)),3));
    colormap gray;
    caxis([0 4000]);
    axis image;
    axis off;
end

saveas(f, [analysis_path '\' datafile '_mean_slices_in_volume.fig']);
saveas(f, [analysis_path '\' datafile '_mean_slices_in_volume.png']); 

%% Get correlation in volume
REFERENCE_PLANE = 6;
FR = 6.88;
file_writer_cnt = 11;
fname = [analysis_path '\' datafile '_ref_plane_' num2str(REFERENCE_PLANE) '_clicky_df_f_' num2str(file_writer_cnt)];
[roi_points, intens] = clicky_df_f(squeeze(DATA(:,:,REFERENCE_PLANE,:)), FR, fname);

%% Get correlation image in volume
SPACING = 0.01;
PADDING = 0;
MARGIN = 0.05;

f2 = figure;

DATA = double(DATA);

for i=1:PLANES
    subaxis(4,4,i, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
    rho = corr(squeeze(intens(1,3:end))', reshape(squeeze(DATA(:,:,i,3:end)), [size(DATA,1)*size(DATA,2) size(DATA(:,:,:,3:end),4) ])' );
    corr_img = reshape(rho', [size(DATA,1),  size(DATA,2)]);
    imagesc( corr_img );
    caxis([-0.2 0.2]);
    axis image;
    axis off;
    colormap jet;
    %colorbar;
end

saveas(f2, [analysis_path '\' datafile '_corr_in_volume_' num2str(file_writer_cnt) '.fig']);
saveas(f2, [analysis_path '\' datafile '_corr_in_volume_' num2str(file_writer_cnt) '.png']); 

%% Play movie
figure;
for i=1:VOLUMES
    imagesc(squeeze(DATA(:,:,1,i)));
    colormap gray;
    title(['Volume number: ' num2str(i)]);
    pause(0.1)    
end


