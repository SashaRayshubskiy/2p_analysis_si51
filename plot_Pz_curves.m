%% P/z

P0 = 10.0;
z0 = 200;
z = [0:500];

Lz = [100:25:500];

figure;

for i=1:length(Lz)
    hold on;
    
    P = P0 * exp((z-z0)/Lz(i));
    plot(z, P, 'DisplayName', ['Lz=' num2str(Lz(i))]);
end
legend('show', 'Location', 'northwest');
xlabel('Depth (microns)');
ylabel('Power (% of max)');
ylim([0 30]);
title('ScanImage Lz values for Power vs Depth P = P0 * exp((z-z0)/Lz');