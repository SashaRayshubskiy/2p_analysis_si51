function [roi_points, intens] = clicky_df_f(a_data, FR, fname);

refimg = mean(a_data, 3);

nframes = size(a_data, 3);

f = figure;
subplot(1,3,1)
imshow(refimg, [], 'InitialMagnification', 'fit')
caxis([0 1600]); 
%colorbar;
hold on;

[ysize, xsize] = size(refimg(:,:,1));
npts = 1;
colorindex = 0;

order    = [ rgb('Blue'); rgb('Green'); rgb('Red'); rgb('Black'); rgb('Purple'); rgb('Brown'); rgb('Indigo'); rgb('DarkRed') ];
nroi = 1;
intens = [];
[x, y] = meshgrid(1:xsize, 1:ysize);

t = [0:nframes-1]./FR;

while(npts > 0)
    
    subplot(1,3,1)
    [xv, yv] = (getline(gca, 'closed'));
    if size(xv,1) < 3  % exit loop if only a line is drawn
        break
    end
    inpoly = inpolygon(x,y,xv,yv);
    
    %draw the bounding polygons and label them
    currcolor    = order(1+mod(colorindex,size(order,1)),:);
    plot(xv, yv, 'Linewidth', 1,'Color',currcolor);
    text(mean(xv),mean(yv),num2str(colorindex+1),'Color',currcolor,'FontSize',12);
        
    tmp = squeeze(sum(sum(a_data.*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
    baseline = repmat(mean(tmp), [1 1 size(tmp,2)]);
    itrace = (tmp-baseline) ./ baseline;
    
    ax1 = subplot(1,3,2:3); % plot the trace
    hold on; 
    plot(t, itrace, 'Color', currcolor, 'LineWidth', 2);
    
    xlim([0 max(t)]);
    ylim([-0.2 0.75]);
    xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('dF/F');
    set(gca, 'FontSize', 14 );
    set(gca, 'FontWeight', 'bold');
    
    colorindex = colorindex+1;
    
    intens = [intens; itrace']; % test comment
    roi_points{nroi} = [xv, yv];
    nroi = nroi + 1;
end
 
global file_writer_cnt;

saveas(f, [fname '_' num2str(file_writer_cnt) '.fig']);
saveas(f, [fname '_' num2str(file_writer_cnt) '.png'], 'png');

file_writer_cnt = file_writer_cnt + 1;