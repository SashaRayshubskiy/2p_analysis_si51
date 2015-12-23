%% Load all data for session 
clear data avg_data;
close all;

%basepath = 'C:\Users\WilsonLab\Desktop\Sasha\fly_health_84_07242015\';
basepath = '/data/drive_fast/sasha/bergamo_fly_health_1/';

analysis_path = [basepath 'analysis'];

if(~exist(analysis_path, 'dir'))
    mkdir(analysis_path);
end


NUM = 10;
num_str = [ num2str( NUM ) '_'];
% trial_types = { 'both_odor', 'left_odor', 'right_odor', 'both_air', 'left_air', 'right_air' };
trial_types = { ['Both_Odor_' num_str], ['Left_Odor_' num_str], ['Right_Odor_' num_str] };
%trial_types = { ['Both_Air_' num_str], ['Left_Air_' num_str], ['Right_Air_' num_str]};
%trial_types = { 'Right_Air_0_' };
%trial_types = { 'Both_Air_14_' };
         
VPS = 6.79;
TPRE = 3.0;
STIM = 0.5;
PLANES = 16;

for tt = 1:size(trial_types,2)
    
    search_path = [basepath '*' trial_types{tt} '*'];
    files = dir([search_path '.tif']);
        
    for i=1:size(files,1)
        filename = [basepath files(i).name];
    
        disp(['Opening file: ' filename]);
    
        
        if 0
            [header,Aout,imgInfo] = scanimage.util.opentif(filename);
            % Aout = M x N x Channels x Frames x Slixes x Volumes
            data(tt,i,:,:,:,:) = reshape(Aout, [size(Aout,1), size(Aout,2), PLANES, size(Aout,3)/PLANES]);        
        end
        
        info = imfinfo(filename);
        num_images = numel(info);
        aOut = zeros(128,512,800);
        for k = 1:num_images
            aOut(:,:,k) = double(imread(filename, k));
        end
        
        data(tt,i,:,:,:,:) = reshape(Aout, [size(Aout,1), size(Aout,2), PLANES, size(Aout,3)/PLANES]);                
    end
    
    avg_data{tt} = squeeze(mean(squeeze(data(tt,:,:,:,:,:))));
end

%%
avg_data1 = squeeze(mean(squeeze(data(1,1,:,:,:,:)),4));

refimg = mean(avg_data1, 3);
f = figure;
imshow(refimg, [], 'InitialMagnification', 'fit')
caxis([0 100]);    
colorbar;


%% Get ROIs
% data(1,2,:,:,:) = data(1,1,:,:,:);

% Get ROIs
% left_roi  = rois{1};
% right_roi = rois{2};

CUR_PLANE = 7;

rois = get_rois(squeeze(data(1,:,:,:,CUR_PLANE,:)));

%% Get ROIs in corr image
% Get df/f in ROIs
cur_num = NUM;
cur_num_str = [ '_' num2str(cur_num) ];
tt = 1;
%data(1,2,:,:,:) = data(1,1,:,:,:);
%clicky_all_data_df_f(squeeze(data(1,:,:,:,:)), FR, TPRE, STIM, [basepath '/' trial_types{tt}]);
[intens,dummy] = clicky_all_data_df_f_with_rois_optostim( squeeze(data(tt,:,:,:,CUR_PLANE,:)), FR, TPRE, STIM, FLUSH, [basepath '/'], [trial_types{tt} '_' num2str(cur_num)], rois );

% Get corr image for above df/f
DATA = avg_data{1};
BEGIN_TC = 1;
END_TC = size(DATA,4);
        
f2 = figure;
rho = corr(squeeze(intens(:,1)), reshape(DATA(:,:,CUR_PLANE, BEGIN_TC:END_TC), [size(DATA,1)*size(DATA,2) size(DATA(:,:,BEGIN_TC:END_TC),4) ])' );
corr_img = reshape(rho', [size(DATA,1),  size(DATA,2)]);
imagesc( corr_img );
axis image;
colorbar;

saveas(f2,[analysis_path '/' trial_types{1} cur_num_str '_corr_img.fig']);
saveas(f2,[analysis_path '/' trial_types{1} cur_num_str '_corr_img.png']);

% get ROIs in corr image
% left_roi  = rois{1};
% right_roi = rois{2};

rois = get_rois(squeeze(data(1,:,:,:,CUR_PLANE,:)), corr_img);


%% Use the corr image
cnt = 1;
cnt_str = [ '_' num2str(cnt) ];

clear intens_air intens_odor;
f = figure('units','normalized','outerposition',[0 0 1 1]);

SPACING = 0.01;
PADDING = 0;
MARGIN = 0.05;

SPACING1 = 0.01;
PADDING1 = 0;
MARGIN1 = 0.05;

f2 = figure('units','normalized','outerposition',[0 0 1 1]);
f3 = figure('units','normalized','outerposition',[0 0 1 1]);

DATA = avg_data{1};

for tt=1:3
    [intens_odor,ax1] = clicky_all_data_df_f_with_rois_optostim( squeeze(data(tt,:,:,:,CUR_PLANE,:)), FR, TPRE, STIM, FLUSH, [basepath '/'], [trial_types{tt} cnt_str], rois );
    
    curfig  = gcf();    
    figure(f)
    %cur_axis = subaxis(2,3,tt, 'Spacing', SPACING1, 'Padding', PADDING1, 'Margin', MARGIN1);
    cur_axis = subplot(1,3,tt);
    pos = get(cur_axis,'Position');
    delete(cur_axis);
    hax2 = copyobj(ax1,f);
    set(hax2,'Position', pos);
    close(curfig);
          
    side_str = {'left', 'right'};

    for side = 1:2
        if(side == 1)
            figure( f2 );
        else
            figure( f3 );            
        end
        
        CAXIS_RANGE = 0.7;
        BEGIN_TC = 1;
        END_TC = size(DATA,3);
        subplot(1,3,tt);
        %subaxis(2,2,tt, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
        DATA = squeeze(mean(squeeze(data(tt,:,:,:,CUR_PLANE,:))));
        rho = corr(squeeze(intens_odor(BEGIN_TC:END_TC,side)), reshape(DATA(:,:,CUR_PLANE,BEGIN_TC:END_TC), [size(DATA,1)*size(DATA,2) size(DATA(:,:,BEGIN_TC:END_TC),4) ])' );
        corr_img = reshape(rho', [size(DATA,1),  size(DATA,2)]);
        imagesc( corr_img ); axis image; axis off; colorbar;
        title(['Corr image ' side_str{side} ' side: ' trial_types{tt}], 'FontSize', 14, 'FontWeight', 'bold')
        caxis([-1.0*CAXIS_RANGE CAXIS_RANGE]);        
    end
end

saveas(f2,[ analysis_path '/corr_img_' num_str side_str{1} cnt_str '.fig']);
saveas(f2,[ analysis_path '/corr_img_' num_str side_str{1} cnt_str '.png']);
saveas(f3,[ analysis_path '/corr_img_' num_str side_str{2} cnt_str '.fig']);
saveas(f3,[ analysis_path '/corr_img_' num_str side_str{2} cnt_str '.png']);
saveas(f,[ analysis_path '/optostim_ts_' num_str cnt_str '.fig']);
saveas(f,[ analysis_path '/optostim_ts_' num_str cnt_str '.png']);

