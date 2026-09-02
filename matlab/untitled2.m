% データの読み込み
data_intN = load('solution_intN.txt');
data_fracN = load('solution_fracN.txt');
data_dtc = load('solution_DTC.txt');
data_hm = load('solution_HM.txt');

V = [2, 2, 3, 4]; % 決定変数の数 (あなたの設定は完璧です)

% --- ランク1（最前線のパレート最適解）だけを抽出 ---
pareto_intN = data_intN(data_intN(:, V(1)+3) == 1, :);
pareto_fracN = data_fracN(data_fracN(:, V(2)+3) == 1, :);
pareto_dtc = data_dtc(data_dtc(:, V(3)+3) == 1, :);
pareto_hm = data_hm(data_hm(:, V(4)+3) == 1, :);

% --- ジッタの小さい順に並び替え（線で結ぶため） ---
pareto_intN = sortrows(pareto_intN, V(1)+1);
pareto_fracN = sortrows(pareto_fracN, V(2)+1);
pareto_dtc = sortrows(pareto_dtc, V(3)+1);
pareto_hm = sortrows(pareto_hm, V(4)+1);

figure;
% 論文に合わせて点ではなく線(-o)でプロット
loglog(pareto_intN(:, V(1)+1)/1e-15, pareto_intN(:, V(1)+2), 'r-o', 'LineWidth', 1.5); hold on;
loglog(pareto_fracN(:, V(2)+1)/1e-15, pareto_fracN(:, V(2)+2), 'b-o', 'LineWidth', 1.5);
loglog(pareto_dtc(:, V(3)+1)/1e-15, pareto_dtc(:, V(3)+2), 'm-o', 'LineWidth', 1.5);
loglog(pareto_hm(:, V(4)+1)/1e-15, pareto_hm(:, V(4)+2), 'g-o', 'LineWidth', 1.5);

grid on;
xlabel('Integrated Jitter (fs)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Total Power (mW)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Integer-N PLL', 'Fractional-N PLL', 'DTC-based PLL', 'HM-based PLL', 'FontSize', 11);
title('Jitter-Power Trade-Off (Fig.5 Reproduction)', 'FontSize', 14);

% --- グラフの表示範囲を論文のFig.5に強制的に合わせる ---
xlim([10, 10000]); % X軸(ジッタ): 10^1 fs から 10^4 fs まで
ylim([0.1, 100]);  % Y軸(電力)  : 10^-1 mW から 10^2 mW まで