% データの読み込み
data_intN = load('solution_intN.txt');
data_fracN = load('solution_fracN.txt');
data_dtc = load('solution_DTC.txt');
data_hm = load('solution_HM.txt');
data_hm_ffnc = load('solution_HM_FFNC.txt');

V = [2, 2, 3, 4, 4]; % 決定変数の数 (この次の列から目的関数の値が入っている)

figure;
% V+1列目がジッタ、V+2列目が消費電力。論文に合わせて単位を調整(fsとmW)
loglog(data_intN(:, V(1)+1)/1e-15, data_intN(:, V(1)+2), 'rx'); hold on;
loglog(data_fracN(:, V(2)+1)/1e-15, data_fracN(:, V(2)+2), 'bx'); hold on;
loglog(data_dtc(:, V(3)+1)/1e-15, data_dtc(:, V(3)+2), 'mx'); hold on;
loglog(data_hm(:, V(4)+1)/1e-15, data_hm(:, V(4)+2), 'gx');
loglog(data_hm_ffnc(:, V(5)+1)/1e-15, data_hm_ffnc(:, V(5)+2), 'x');

grid on;
xlabel('Integrated Jitter (fs)');
ylabel('Power Consumption (mW)');
title('Fig. 5.');

xlim([1e1, 1e3]);
ylim([1e-1, 1e3]);

lgd = legend('Integer-N PLL', 'Fractional-N PLL', 'DTC-based PLL', 'HM-based PLL');
lgd.FontSize = 14; 
lgd.Location = 'northeast';