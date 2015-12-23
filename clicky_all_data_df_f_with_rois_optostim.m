function [intens, ax1] = clicky_all_data_df_f_with_rois_optostim(a_data, FR, TPRE, STIM, FLUSH, basepath, title_str, roi_points_in);

fname = [basepath title_str];

avg_data = squeeze(mean(a_data,1));

refimg = mean(avg_data, 3);

nframes = size(avg_data, 3);

f = figure;
subplot(1,3,1)
imshow(refimg, [], 'InitialMagnification', 'fit')
caxis([0 250]); 
%colorbar;
hold on;

[ysize, xsize] = size(refimg(:,:,1));
npts = 1;
colorindex = 0;
%order = get(gca,'ColorOrder');
order_avg    = [ rgb('Blue'); rgb('Green'); rgb('Red'); rgb('Black'); rgb('Purple'); rgb('Brown'); rgb('Indigo'); rgb('DarkRed') ];
order_single = [ rgb('LightBlue'); rgb('LightGreen'); rgb('LightSalmon'); rgb('LightGray'); rgb('Violet'); rgb('Bisque'); rgb('Plum'); rgb('LightPink') ];
nroi = 1;
intens = [];
[x, y] = meshgrid(1:xsize, 1:ysize);

t = [0:nframes-1]./FR;

%base_begin = floor(TPRE*FR);
%base_end = floor((TPRE+STIM)*FR);

base_begin = 1;
base_end = floor(TPRE*FR);


%bs_fr_end = floor(TPRE*FR);

for ii = 1:size(roi_points_in,2)
    
    subplot(1,3,1);    
    % [xv,yv] = roi_points_in{ii};
    roi = roi_points_in{ii};
    xv = roi(:,1);
    yv = roi(:,2);
    
    inpoly = inpolygon(x,y,xv,yv);
    
    %draw the bounding polygons and label them
    currcolor_single = order_single(1+mod(colorindex,size(order_single,1)),:);
    currcolor_avg    = order_avg(1+mod(colorindex,size(order_single,1)),:);
    plot(xv, yv, 'Linewidth', 1,'Color',currcolor_avg);
    text(mean(xv),mean(yv),num2str(colorindex+1),'Color',currcolor_avg,'FontSize',12);
    
    for tt=1:size(a_data,1)
        tmp = squeeze(sum(sum(squeeze(a_data(tt,:,:,:)).*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
        baseline = repmat(mean(tmp(base_begin:base_end)), [1 1 size(tmp,2)]);
        itrace(tt,:) = (tmp-baseline) ./ baseline;
    end
    
    tmp = squeeze(sum(sum(avg_data.*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
    baseline = repmat(mean(tmp(base_begin:base_end)), [1 1 size(tmp,2)]);
    itrace_avg = (tmp-baseline) ./ baseline;
    itrace_avg_raw = tmp;
    
    ax1 = subplot(1,3,2:3); % plot the trace
    hold on;
    
    for tt=1:size(a_data,1)
        plot(t, itrace(tt,:),'Color', currcolor_single, 'LineWidth', 0.5);
    end
    
    plot(t, itrace_avg,'Color', currcolor_avg, 'LineWidth', 2.5);
    
    xlim([0 max(t)]);
    %ylim([-0.25 1.4]);
    ylim([-0.25 0.8]);
    xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    %ylabel('Flourescence (au)', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14 );
    set(gca, 'FontWeight', 'bold');
    
    colorindex = colorindex+1;
    
    intens = [intens; itrace_avg'];
    nroi = nroi + 1;
end
 
% Plot stim window
axes(ax1);
yy = ylim;
y_min = yy(1); y_max = yy(2);
hh = fill([ TPRE TPRE TPRE+STIM TPRE+STIM ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

intens = intens';
title([title_str ': avg of ' num2str(size(a_data,1)) ' trials'], 'Interpreter','none');



global file_writer_cnt;

saveas(f, [fname '_' num2str(file_writer_cnt) '.fig']);
saveas(f, [fname '_' num2str(file_writer_cnt) '.png'], 'png');

file_writer_cnt = file_writer_cnt + 1;
