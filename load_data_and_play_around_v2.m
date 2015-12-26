%% Load ScanImage 5.1 imaging data

%datapath = 'B:\Sasha\second_test_12_03_2015\';
%datafile = 'right_LH_PB_7um_16slices_80_volumes_00002.tif';

datapath = 'Y:\drive_fast\sasha\pi-725_piezo_test_01\';
datafile = 'z_phantom_15_micron_spacing_400_volumes_00001.tif';

analysis_path = [datapath 'analysis'];

if(~exist(analysis_path, 'dir'))
    mkdir(analysis_path);
end



[header, aOut,imgInfo] = scanimage.util.opentif([datapath '\' datafile]);

%% 
clear DATA1;
nm940_precomp_number = [0, 2000, 4000, 6000, 7000, 7500, 8000, 8500, 9000, 9500, 10000, 12000];
nm800_precomp_number = [0, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000, 22000, 23500];

precomp_number = nm800_precomp_number;

for i=1:length(precomp_number)

     datafile = ['800nm_6micron_bead_' num2str(precomp_number(i)) 'precomp_00001.tif'];
    [header, aOut,imgInfo] = scanimage.util.opentif([datapath '\' datafile]);

     DATA1{i} = double(aOut);
     
     disp(['Processed file: ' datafile]);
end


%%

for i=1:length(precomp_number)
    avg_img(i) = mean(mean(mean(DATA1{i})));
end

figure;
plot(precomp_number, avg_img);
xlabel('Precomp number');
ylabel('Avg intensity');

%% 
clicky(DATA1{7});

%%
VOLUMES = 400;
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


