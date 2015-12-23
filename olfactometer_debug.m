%% Load all data for session 
clear data avg_data;
close all;
%basepath = '/Users/sasha/Documents/Wilson lab/Data/2p_olfactometer_test_2014_11_05/';
%basepath = 'C:\Users\WilsonLab\Desktop\Sasha\BL_Task_GCaMP3_GH298_2014_12_17\';
%basepath = 'C:\Users\WilsonLab\Desktop\Sasha\Or67d_gcamp6f_2014_01_14\';
%basepath = '/Users/sasha/Documents/Wilson lab/Data/2p_olfactometer_test_2014_12_02/';
basepath = 'C:\Users\WilsonLab\Desktop\Sasha\nSyb_GCaMP6f_LexA-83b_LexAOPCsChrimson_03242015\';
cd(basepath)

NUM = 4;
num_str = [ num2str( NUM ) '_'];
% trial_types = { 'both_odor', 'left_odor', 'right_odor', 'both_air', 'left_air', 'right_air' };
trial_types = { ['Both_Odor_' num_str], ['Left_Odor_' num_str], ['Right_Odor_' num_str], ['Both_Air_' num_str], ['Left_Air_' num_str], ['Right_Air_' num_str] };
%trial_types = { ['Both_Odor_' num_str], ['Left_Odor_' num_str], ['Right_Odor_' num_str], ['Both_Air_' num_str], ['Left_Air_' num_str]};
%trial_types = { ['Both_Air_' num_str], ['Left_Air_' num_str], ['Right_Air_' num_str]};
%trial_types = { 'Right_Odor_16_' };
%trial_types = { 'Both_Air_14_' };
         
FR = 7.8;
TPRE = 5;
STIM = 10.0;
TPRE_FLUSH = 20;
FLUSH = 5;

for tt = 1:size(trial_types,2)
    
    search_path = ['*' trial_types{tt} '*'];
    files = dir([search_path '.tif']);
        
    for i=1:size(files,1)
        filename = files(i).name;
        
        info = imfinfo(filename);
        num_images = numel(info);
        for k = 3:num_images-2
            data(tt,i,:,:,k-2) = double(imread(filename, k));
        end
    end
    
    avg_data{tt} = squeeze(mean(squeeze(data(tt,:,:,:,:))));
end

%%
avg_data1 = squeeze(mean(squeeze(data(1,1,:,:,:)),3));

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

rois = get_rois(squeeze(data(1,:,:,:,:)));


%% Get ROIs in corr image
% Get df/f in ROIs
cur_num = NUM;
cur_num_str = [ '_' num2str(cur_num) ];
tt = 1;
%data(1,2,:,:,:) = data(1,1,:,:,:);
%clicky_all_data_df_f(squeeze(data(1,:,:,:,:)), FR, TPRE, STIM, [basepath '/' trial_types{tt}]);
[intens,dummy] = clicky_all_data_df_f_with_rois( squeeze(data(tt,:,:,:,:)), FR, TPRE, STIM, TPRE_FLUSH, FLUSH, [basepath '/'], [trial_types{tt} '_' num2str(cur_num)], rois );

% Get corr image for above df/f
DATA = avg_data{1};
BEGIN_TC = 1;
END_TC = size(DATA,3);
        
f2 = figure;
rho = corr(squeeze(intens(:,1)), reshape(DATA(:,:,BEGIN_TC:END_TC), [size(DATA,1)*size(DATA,2) size(DATA(:,:,BEGIN_TC:END_TC),3) ])' );
corr_img = reshape(rho', [size(DATA,1),  size(DATA,2)]);
imagesc( corr_img );
axis image;
colorbar;

saveas(f2,[basepath '/' trial_types{1} cur_num_str '_corr_img.fig']);
saveas(f2,[basepath '/' trial_types{1} cur_num_str '_corr_img.png']);

% get ROIs in corr image
% left_roi  = rois{1};
% right_roi = rois{2};

rois = get_rois(squeeze(data(1,:,:,:,:)), corr_img);


%% Use the corr image
cnt = 0;
cnt_str = [ '_' num2str(cnt) ];

STIM = 10.0;
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

for tt=1:6
    [intens_odor,ax1] = clicky_all_data_df_f_with_rois( squeeze(data(tt,:,:,:,:)), FR, TPRE, STIM, TPRE_FLUSH, FLUSH, [basepath '/'], [trial_types{tt} cnt_str], rois );
    
    curfig  = gcf();    
    figure(f)
    cur_axis = subaxis(2,3,tt, 'Spacing', SPACING1, 'Padding', PADDING1, 'Margin', MARGIN1);
    %cur_axis = subplot(1,3,tt);
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
        subaxis(2,3,tt, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
        DATA = squeeze(mean(squeeze(data(tt,:,:,:,:))));
        rho = corr(squeeze(intens_odor(BEGIN_TC:END_TC,side)), reshape(DATA(:,:,BEGIN_TC:END_TC), [size(DATA,1)*size(DATA,2) size(DATA(:,:,BEGIN_TC:END_TC),3) ])' );
        corr_img = reshape(rho', [size(DATA,1),  size(DATA,2)]);
        imagesc( corr_img ); axis image; axis off; colorbar;
        title(['Corr image ' side_str{side} ' side: ' trial_types{tt}])
        caxis([-1.0*CAXIS_RANGE CAXIS_RANGE]);        
    end
end

saveas(f2,[basepath '/corr_img_' num_str side_str{1} cnt_str '.fig']);
saveas(f2,[basepath '/corr_img_' num_str side_str{1} cnt_str '.png']);
saveas(f3,[basepath '/corr_img_' num_str side_str{2} cnt_str '.fig']);
saveas(f3,[basepath '/corr_img_' num_str side_str{2} cnt_str '.png']);
saveas(f,[basepath '/air_ts_' num_str cnt_str '.fig']);
saveas(f,[basepath '/air_ts_' num_str cnt_str '.png']);
%% Use the corr image
cnt = 0;
cnt_str = [ '_' num2str(cnt) ];

STIM = 10.0;
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

for tt=1:3
    tt_air = tt+3;
    [intens_odor,ax1] = clicky_all_data_df_f_with_rois( squeeze(data(tt,:,:,:,:)), FR, TPRE, STIM, TPRE_FLUSH, FLUSH, [basepath '/'], [trial_types{tt} cnt_str], rois );
        
    curfig  = gcf();    
    figure(f)
    %cur_axis = subaxis(2,3,tt, 'Spacing', SPACING1, 'Padding', PADDING1, 'Margin', MARGIN1);
    cur_axis = subplot(2,3,tt);
    pos = get(cur_axis,'Position');
    delete(cur_axis);
    hax2 = copyobj(ax1,f);
    set(hax2,'Position', pos);
    close(curfig);
    
    [intens_air, ax2] = clicky_all_data_df_f_with_rois( squeeze(data(tt_air,:,:,:,:)), FR, TPRE, STIM, TPRE_FLUSH, FLUSH, [basepath '/'], [trial_types{tt_air} cnt_str], rois );
    
    curfig  = gcf();    
    figure(f)
    cur_axis = subplot(2,3,tt_air);
    %cur_axis = subaxis(2,3,tt_air, 'Spacing', SPACING1, 'Padding', PADDING1, 'Margin', MARGIN1);
    pos = get(cur_axis,'Position');
    delete(cur_axis);
    hax2 = copyobj(ax2,f);
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
        subaxis(2,3,tt, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
        DATA = squeeze(mean(squeeze(data(tt,:,:,:,:))));        
        rho = corr(squeeze(intens_odor(BEGIN_TC:END_TC,side)), reshape(DATA(:,:,BEGIN_TC:END_TC), [size(DATA,1)*size(DATA,2) size(DATA(:,:,BEGIN_TC:END_TC),3) ])' );
        corr_img = reshape(rho', [size(DATA,1),  size(DATA,2)]);
        imagesc( corr_img ); axis image; axis off; colorbar;
        title(['Corr image ' side_str{side} ' side: ' trial_types{tt}])
        caxis([-1.0*CAXIS_RANGE CAXIS_RANGE]);
        
        subaxis(2,3,tt_air, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
        DATA = squeeze(mean(squeeze(data(tt_air,:,:,:,:))));
        rho = corr(squeeze(intens_air(BEGIN_TC:END_TC,side)), reshape(DATA(:,:,BEGIN_TC:END_TC), [size(DATA,1)*size(DATA,2) size(DATA(:,:,BEGIN_TC:END_TC),3) ])' );
        corr_img = reshape(rho', [size(DATA,1),  size(DATA,2)]);
        imagesc( corr_img ); axis image; axis off;  colorbar;
        title(['Corr image ' side_str{side} ' side: ' trial_types{tt_air}])
        caxis([-1.0*CAXIS_RANGE CAXIS_RANGE]);
    end
end

saveas(f2,[basepath '/corr_img_' num_str side_str{1} cnt_str '.fig']);
saveas(f2,[basepath '/corr_img_' num_str side_str{1} cnt_str '.png']);
saveas(f3,[basepath '/corr_img_' num_str side_str{2} cnt_str '.fig']);
saveas(f3,[basepath '/corr_img_' num_str side_str{2} cnt_str '.png']);
saveas(f,[basepath '/odor_vs_air_ts_' num_str cnt_str '.fig']);
saveas(f,[basepath '/odor_vs_air_ts_' num_str cnt_str '.png']);

%%
tt = 1;
clicky_all_data_df_f_with_rois( squeeze(data(tt,:,:,:,:)), FR, TPRE, STIM, TPRE_FLUSH, FLUSH, [basepath '/'], trial_types{tt}, rois );

%% BACKUP
    figure(f);
    subplot(1,3,tt);
    nframes = size(data,5);
    t = [0:nframes-1]./FR;
    
    hold on;
    bs_fr_end = floor(TPRE*FR);
    left_pc = (intens_odor(:,1)-intens_air(:,1))./ intens_air(:,1);
    left_pc_s = left_pc - (mean(left_pc(1:bs_fr_end)));    
    
    right_pc = (intens_odor(:,2)-intens_air(:,2))./ intens_air(:,2);
    right_pc_s = right_pc - (mean(right_pc(1:bs_fr_end)));
    
    p1 = plot( t', left_pc_s, 'b' );
    p2 = plot( t', right_pc_s, 'g' );
    legend([p1, p2], 'Left','Right');
    xlim([0 20]);
    % ylim([-0.1 0.35]);
    title(['(' trial_types{tt} ' - ' trial_types{tt_air} ')/' trial_types{tt_air}],'Interpreter','none');
    xlabel('Time (s)');
    ylabel('% change');
