function [roi_points, intens] = clicky_all_data_df_f(a_data, FR, TPRE, STIM, fname);

avg_data = squeeze(mean(a_data,1));
%avg_data = a_data;

refimg = mean(avg_data, 3);

nframes = size(avg_data, 3);

f = figure;
subplot(1,3,1)
imshow(refimg, [], 'InitialMagnification', 'fit')
caxis([0 1600]); 
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

bs_fr_end = floor(TPRE*FR);

while(npts > 0)
    
    subplot(1,3,1)
    [xv, yv] = (getline(gca, 'closed'));
    if size(xv,1) < 3  % exit loop if only a line is drawn
        break
    end
    inpoly = inpolygon(x,y,xv,yv);
    
    %draw the bounding polygons and label them
    currcolor_single = order_single(1+mod(colorindex,size(order_single,1)),:);
    currcolor_avg    = order_avg(1+mod(colorindex,size(order_single,1)),:);
    plot(xv, yv, 'Linewidth', 1,'Color',currcolor_avg);
    text(mean(xv),mean(yv),num2str(colorindex+1),'Color',currcolor_avg,'FontSize',12);
    
    for tt=1:size(a_data,1)
        tmp = squeeze(sum(sum(squeeze(a_data(tt,:,:,:)).*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
        baseline = repmat(mean(tmp(1:bs_fr_end)), [1 1 size(tmp,2)]);
        itrace(tt,:) = (tmp-baseline) ./ baseline;
    end
    
    tmp = squeeze(sum(sum(avg_data.*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
    baseline = repmat(mean(tmp(1:bs_fr_end)), [1 1 size(tmp,2)]);
    itrace_avg = (tmp-baseline) ./ baseline;
    
    ax1 = subplot(1,3,2:3); % plot the trace
    hold on;
    
    for tt=1:size(a_data,1)
        plot(t, itrace(tt,:),'Color', currcolor_single, 'LineWidth', 0.5);
    end
    
    plot(t, itrace_avg,'Color', currcolor_avg, 'LineWidth', 2.5);
    
    xlim([0 max(t)]);
    ylim([-0.2 0.75]);
    xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    %ylabel('Flourescence (au)', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14 );
    set(gca, 'FontWeight', 'bold');
    
    colorindex = colorindex+1;
    
    intens = [intens; itrace'];
    roi_points{nroi} = [xv, yv];
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
title(['Avg of ' num2str(size(a_data,1)) ' trials']);

global file_writer_cnt;

saveas(f, [fname '_' num2str(file_writer_cnt) '.fig']);
saveas(f, [fname '_' num2str(file_writer_cnt) '.png'], 'png');

file_writer_cnt = file_writer_cnt + 1;