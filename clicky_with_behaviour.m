function [intens, ax1] = clicky_with_behaviour(cdata, bdata_vel, bdata_vel_time, VPS, settings, figsave_prefix);

refimg = mean(cdata, 3);
nframes = size(cdata, 3);

prestim = settings.pre_stim;
stim    = settings.stim;
poststim    = settings.post_stim;

total_time = prestim + stim + poststim;

first_stim_t = prestim;
last_stim_t = stim + prestim;

f = figure;
subplot( 3, 3, 4 ) 
imshow(refimg, [], 'InitialMagnification', 'fit')
caxis([0 3000]); 
%colorbar;
hold on;

subplot(3,3, [8:9]);
aconst = get_analysis_constants;

hold on;
p1 = plot(bdata_vel_time, bdata_vel(aconst.VEL_FWD,:), 'color', rgb('FireBrick'));
p2 = plot(bdata_vel_time, bdata_vel(aconst.VEL_YAW,:), 'color', rgb('SeaGreen'));
legend( [ p1, p2 ], 'Vel fwd', 'Vel yaw' );

yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ first_stim_t first_stim_t last_stim_t last_stim_t ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

xlim([0, total_time]);
xlabel('Time (s)');
ylabel('Velocity (au/s)');

[ysize, xsize] = size(refimg(:,:,1));
npts = 1;
colorindex = 0;
%order = get(gca,'ColorOrder');
order_avg    = [ rgb('Blue'); rgb('Green'); rgb('Red'); rgb('Black'); rgb('Purple'); rgb('Brown'); rgb('Indigo'); rgb('DarkRed') ];
order_single = [ rgb('LightBlue'); rgb('LightGreen'); rgb('LightSalmon'); rgb('LightGray'); rgb('Violet'); rgb('Bisque'); rgb('Plum'); rgb('LightPink') ];
nroi = 1;
intens = [];
[x, y] = meshgrid(1:xsize, 1:ysize);

t = [0:nframes-1]./VPS;

base_begin = 1;
base_end = floor(prestim*VPS);

while(npts > 0)    
    
    subplot( 3, 3, 4 );    
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
    
    tmp = squeeze(sum(sum(cdata.*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
    baseline = repmat(mean(tmp(base_begin:base_end)), [1 1 size(tmp,2)]);
    itrace = (tmp-baseline) ./ baseline;
        
    ax1 = subplot( 3, 3, [2 3 5 6] ); % plot the trace
    hold on;
        
    plot(t, itrace,'color', currcolor_avg);
    
    xlim([0 total_time]);
    ylim([-0.7 1.5]);
    xlabel('Time (s)');
    ylabel('dF/F');
    
    %xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    %ylabel('dF/F', 'FontSize', 14, 'FontWeight', 'bold');
    %set(gca, 'FontSize', 14 );
    %set(gca, 'FontWeight', 'bold');
    
    colorindex = colorindex+1;
    
    intens = [intens; itrace];
    nroi = nroi + 1;
end
 
% Plot stim window
axes(ax1);
yy = ylim;
y_min = yy(1); y_max = yy(2);
hh = fill([ first_stim_t first_stim_t last_stim_t last_stim_t ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

intens = intens';

global file_writer_cnt;

saveas( f, [figsave_prefix '_' num2str(file_writer_cnt) '.fig'] );
saveas( f, [figsave_prefix '_' num2str(file_writer_cnt) '.png'], 'png' );

file_writer_cnt = file_writer_cnt + 1;
