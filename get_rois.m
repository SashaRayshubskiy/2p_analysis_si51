function [roi_points] = get_rois(a_data, img);

avg_data = squeeze(mean(a_data,1));

if( nargin == 2 )
    refimg = img;
else
    refimg = mean(avg_data, 3);
end


f = figure;
%subplot(1,3,1)
imshow(refimg, [], 'InitialMagnification', 'fit')

if( nargin ~= 2 )
    caxis([0 5000]);    
end

hold on;

order_avg    = [ rgb('Blue'); rgb('Green'); rgb('Red'); rgb('Black'); rgb('Purple'); rgb('Brown'); rgb('Indigo'); rgb('DarkRed') ];
order_single = [ rgb('LightBlue'); rgb('LightGreen'); rgb('LightSalmon'); rgb('LightGray'); rgb('Violet'); rgb('Bisque'); rgb('Plum'); rgb('LightPink') ];
nroi = 1;
npts = 1;
colorindex = 0;

while(npts > 0)
    [xv, yv] = (getline(gca, 'closed'));
    if size(xv,1) < 3  % exit loop if only a line is drawn
        break
    end
    
    currcolor_avg    = order_avg(1+mod(colorindex,size(order_single,1)),:);
    plot(xv, yv, 'Linewidth', 1,'Color',currcolor_avg);
    text(mean(xv),mean(yv),num2str(colorindex+1),'Color',currcolor_avg,'FontSize',12);
    
    roi_points{nroi} = [xv, yv];
    colorindex = colorindex+1;
    nroi = nroi + 1;
end
