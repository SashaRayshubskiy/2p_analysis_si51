%% Load ScanImage 5.1 imaging data

datapath = 'B:\Sasha\first_test_12_02_2015\';
analysis_path = [datapath 'analysis'];

if(~exist(analysis_path, 'dir'))
    mkdir(analysis_path);
end

datafile = 'LH_80_volumes_14_slices_00011.tif';

[header, aOut,imgInfo] = scanimage.util.opentif([datapath '\' datafile]);

%%
VOLUMES = 80;
PLANES = 16;
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
    caxis([32697 34971]);
    axis image;
    axis off;
end

saveas(f, [analysis_path '\mean_slices_in_volume.fig']);
saveas(f, [analysis_path '\mean_slices_in_volume.png']); 

%% Get correlation in volume
FR = 6.88;

fname = [analysis_path '\clicky_all_data_df_f'];
[roi_points, intens] = clicky_df_f(a_data, FR, fname);




%% Play movie
figure;
for i=1:VOLUMES
    imagesc(squeeze(DATA(:,:,1,i)));
    colormap gray;
    title(['Volume number: ' num2str(i)]);
    pause(0.1)    
end


