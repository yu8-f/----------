%% Noise analysis of Dual-FeedForward PLL

close all;
clear all;

%% Laplace transform
f_step = 1e3;
f = 1e3 : f_step : 1e9;
s = 1j .* f .* 2 .* pi;

%% Design Parameters
P_VCO_A = 100 * 1e-3;
P_VCO_M = 48.8e-3;
K_VCO_M = 2 * pi * 4.76 * 1e9;

T_DIV = 24;
N_I = 20;
N_F = 12;

k_I = 3;
k_F = 4;

%% Constants
k = 1.38e-23;
T_kelvin = 300;
r = 1;

v_ov = 0.2;
t_on = 100e-12;

V_DD = 0.9;

l = 3; %DSM order

%% Loop parameters
f_REF = 5e9;
f_PD_A = f_REF / T_DIV;
f_MID = (k_I + N_I/T_DIV) * f_REF;
f_PD_M = f_MID / N_F;
f_OUT = (k_F + 1/N_F) * f_MID;

%% Aux Loop: INPLL
Q_A = 10;

K_VCOn_A = (4*pi*k*T_kelvin*(1+r) / P_VCO_A) * ((f_MID / (2 * Q_A))^2);

K_VCO_A = 2 * pi * 30e6;
K_PD_A = 20;
P_PD_A = 1e-3;  % 1mW

%% Main Loop: dual feed-forward
Q_M = 10;

K_VCOn_M = (4*pi*k*T_kelvin*(1+r) / P_VCO_M) * ((f_OUT / (2 * Q_M))^2);

K_PD_M = 0.9 / pi;
P_PD_M = 2.75e-3;



%% Loop Filter
% Aux Loop
C1_A = 5e-12;
C2_A = 500e-15;

F_LF_A = (f_PD_A .* ((C1_A / C2_A) ./ (s + ((C1_A * f_PD_A) / C2_A)))) .* ((cos((pi .* f) ./ f_PD_A)) - (1j .*sin((pi .* f) ./ f_PD_A))) .* ((f_PD_A .* (sin((pi .* f) ./ f_PD_A))) ./ (pi .* f));
F_LF_A_dB = 20 .* log10(abs(F_LF_A));

% Main Loop
a = 4;
Gain_feedback = 2;
f_u_M = 10e6;
w_u_M = 2 * pi * f_u_M;

R1_M = 50e3;
C1_M = (1/(w_u_M*R1_M)) * sqrt(((K_PD_M*K_VCO_M*a)/(Gain_feedback * w_u_M))^2 - 1);
R2_M = (1/(C1_M*w_u_M)) * ((a^2-1)/a);
C2_M = C1_M / (a^2-1);
F_LF_M = ((s .* R2_M .* (C1_M + C2_M) + 1) ./ ((s .* R1_M .* C1_M + 1) .* (s .* R2_M .* C2_M + 1) + s .* R2_M .* C1_M));

T1_M = (R1_M + R2_M) * C1_M;
T2_M = R2_M * (C1_M + C1_M);
T3_M = R2_M * C2_M;
f1_M = 1 / (2*pi*T1_M);
f2_M = 1 / (2*pi*T2_M);
f3_M = 1 / (2*pi*T3_M);



%% Loop Transfer Functions
% Aux Loop
H_OL_A = K_PD_A .* F_LF_A .* (K_VCO_A ./ s) .* (1 / N_I);
H_OL_A_dB = 20 .* log10(H_OL_A);

H_LP_A = H_OL_A ./ (1 + H_OL_A);
H_LP_A_dB = 20 .* log10(H_LP_A);

H_HP_A = 1 ./ (1 + H_OL_A);
H_HP_A_dB = 20 .* log10(H_HP_A);

H_BP_A = (K_VCO_A ./ s) .* (1 ./ (1 + H_OL_A));
H_BP_A_dB = 20 .* log10(H_BP_A);

% Main Loop
H_OL_M = K_PD_M .* F_LF_M .* (K_VCO_M ./ s) .* (1./Gain_feedback);
H_OL_M_dB = 20 .* log10(H_OL_M);

H_OL_M_wo_LF = K_PD_M .* (K_VCO_M ./ s);
H_OL_M_wo_LF_dB = 20 .* log10(H_OL_M_wo_LF);

H_LP_M = H_OL_M ./ (1 + H_OL_M);
H_LP_M_dB = 20 .* log10(H_LP_M);

H_HP_M = 1 ./ (1 + H_OL_M);
H_HP_M_dB = 20 .* log10(H_HP_M);

H_BP_M = (K_VCO_M ./ s) .* (1 ./ (1 + H_OL_M));
H_BP_M_dB = 20 .* log10(H_BP_M);



%% Noise Sources
% Aux Loop
PN_REF_f = [1e3 10e3 100e3];
PN_REF_dBc = [-117 -127 -142];
n_psd_ref = zeros(1, length(f));
n_psd_ref_dB = zeros(1, length(f));
for i = 1:length(f)
    if f(i) < PN_REF_f(2)
        tmp = ((PN_REF_dBc(2)-PN_REF_dBc(1))/(log10(PN_REF_f(2))-log10(PN_REF_f(1))))*(log10(f(i))-log10(PN_REF_f(1))) + PN_REF_dBc(1);
    else
        tmp = ((PN_REF_dBc(3)-PN_REF_dBc(2))/(log10(PN_REF_f(3))-log10(PN_REF_f(2))))*(log10(f(i))-log10(PN_REF_f(2))) + PN_REF_dBc(2);
    end
    
    if tmp >= -142
        n_psd_ref_dB(i) = tmp;
    else
        n_psd_ref_dB(i) = -142;
    end
    
    n_psd_ref(i) = 10^(n_psd_ref_dB(i)/10);
end

n_psd_pd_A = 1e-20 / P_PD_A;
n_psd_pd_A_dB = 10 * log10(n_psd_pd_A);

n_psd_lf_A = k * T_kelvin / (2 * C2_A) * (1/f_PD_A);

n_psd_vco_A = K_VCOn_A ./ (f .^ 2);
n_psd_vco_A_dB = 10 .* log10(n_psd_vco_A);

% Main Loop
n_psd_dsm = ( ( (2 * pi) / N_F) ^ 2) .* (1 / 12) .* (1 / f_PD_M) .* ( (2 .* sin(pi .* f ./ f_PD_M) ) .^ (2 * (l-1) ) );
n_psd_pd_M = 1e-20 / P_PD_M;

n_psd_lf_M = (abs( ...
    (s .* R2_M .* (C1_M + C2_M) + 1) ./ ...
    (s .^ 2 .* (R1_M .* R2_M .* C1_M .* C2_M) + s .* (R1_M .* C1_M + R2_M .* (C1_M + C2_M)) + 1)) ...
    .^2) ...
    .* 4 .* k .* T_kelvin .* R1_M;
n_psd_lf_M_dB = 10 .* log10(n_psd_lf_M);

PN_VCO_M_sim_f = [1e6 10e6];
PN_VCO_M_sim_dBc = [-86.4 -106.9];
n_psd_vco_M_sim = zeros(1, length(f));
n_psd_vco_M_sim_dB = zeros(1, length(f));
for i = 1:length(f)        
    n_psd_vco_M_sim_dB(i) = ...
        ((PN_VCO_M_sim_dBc(2)-PN_VCO_M_sim_dBc(1)) / (log10(PN_VCO_M_sim_f(2))-log10(PN_VCO_M_sim_f(1)))) ...
        * (log10(f(i))-log10(PN_VCO_M_sim_f(1))) ...
        + PN_VCO_M_sim_dBc(1);
    n_psd_vco_M_sim(i) = 10^(n_psd_vco_M_sim_dB(i)/10);
end

n_psd_vco_M = n_psd_vco_M_sim;
n_psd_vco_M_dB = n_psd_vco_M_sim_dB;



%% Noise Contributions
% Aux Loop
S_N_REF = ((abs(N_I .* (1/N_I + 1/T_DIV) .* H_LP_A)) .^ 2) .* n_psd_ref;
S_N_REF_dB = 10 .* log10(S_N_REF);

S_N_PD_A = ((abs((N_I / K_PD_A) .* H_LP_A)) .^ 2) .* n_psd_pd_A;
S_N_PD_A_dB = 10 .* log10(S_N_PD_A);

S_N_LF_A = ((abs(H_BP_A)) .^ 2) .* n_psd_lf_A;
S_N_LF_A_dB = 10 .* log10(S_N_LF_A);

S_N_VCO_A = ((abs(H_HP_A)) .^ 2) .* n_psd_vco_A;
S_N_VCO_A_dB = 10 .* log10(S_N_VCO_A);

S_N_TOT_A = S_N_REF + S_N_PD_A + S_N_LF_A + S_N_VCO_A;
S_N_TOT_A_dB = 10 .* log10(S_N_TOT_A);

S_N_VCO_free_A = K_VCOn_A ./ (f .^ 2);
S_N_VCO_free_A_dB = 10 .* log10(S_N_VCO_free_A);

% Main Loop
S_N_FROM_A = ((abs((1/N_F + 1) .* H_LP_M)) .^ 2) .* S_N_TOT_A;
S_N_FROM_A_dB = 10 .* log10(S_N_FROM_A);

S_N_PD_M = ((abs((Gain_feedback / K_PD_M) .* H_LP_M)) .^ 2) .* n_psd_pd_M;
S_N_PD_M_dB = 10 .* log10(S_N_PD_M);

S_N_LF_M = ((abs(H_BP_M)) .^ 2) .* n_psd_lf_M;
S_N_LF_M_dB = 10 .* log10(S_N_LF_M);

S_N_VCO_M = ((abs(H_HP_M)) .^ 2) .* n_psd_vco_M;
S_N_VCO_M_dB = 10 .* log10(S_N_VCO_M);

S_N_DSM = ((abs(H_LP_M)) .^ 2) .* n_psd_dsm;
S_N_DSM_dB = 10 .* log10(S_N_DSM);

S_N_TOT_M = S_N_FROM_A + S_N_LF_M + S_N_VCO_M + S_N_DSM;
S_N_TOT_M_dB = 10 .* log10(S_N_TOT_M);

S_N_VCO_free_M = n_psd_vco_M;
S_N_VCO_free_M_dB = 10 .* log10(S_N_VCO_free_M);



%% Integrated Jitter
% Aux Loop
A_A = S_N_TOT_A .* f_step;
A_A_T = sum(A_A);
J_A = (sqrt(2 * A_A_T) ) / (2 * pi * f_MID);

% 2nd Stage
A_M = S_N_TOT_M .* f_step;
A_M_T = sum(A_M);
J_M = (sqrt(2 * A_M_T) ) / (2 * pi * f_OUT);
A_M_T_contribution = A_M_T / A_M_T;

A_DSM = S_N_DSM .* f_step;
A_DSM_T = sum(A_DSM);
J_DSM = (sqrt(2 * A_DSM_T) / (2 * pi * f_OUT));
A_DSM_T_contribution = A_DSM_T / A_M_T;

A_VCO_M = S_N_VCO_M .* f_step;
A_VCO_M_T = sum(A_VCO_M);
J_VCO_M = (sqrt(2 * A_VCO_M_T) / (2 * pi * f_OUT));
A_VCO_M_T_contribution = A_VCO_M_T / A_M_T;

A_PD_M = S_N_PD_M .* f_step;
A_PD_M_T = sum(A_PD_M);
J_PD_M = (sqrt(2 * A_PD_M_T) / (2 * pi * f_OUT));
A_PD_M_T_contribution = A_PD_M_T / A_M_T;

A_LF_M = S_N_LF_M .* f_step;
A_LF_M_T = sum(A_LF_M);
J_LF_M = (sqrt(2 * A_LF_M_T) / (2 * pi * f_OUT));
A_LF_M_T_contribution = A_LF_M_T / A_M_T;

A_AUX_M = S_N_FROM_A .* f_step;
A_AUX_M_T = sum(A_AUX_M);
J_AUX_M = (sqrt(2 * A_AUX_M_T) / (2 * pi * f_OUT));
A_AUX_M_T_contribution = A_AUX_M_T / A_M_T;



%% calc PLL Open Loop Phase Margin
PLL_BW = 0;
PLL_OL_Phase = angle(H_OL_M)*180/pi;
for i = 1:length(f)
    if H_OL_M_dB(i) < 0
        PLL_BW = (f(i) + f(i+1)) / 2;
        break
    end
end



%% Noise contribution plots
color1 = [0 0.4470 0.7410];
color2 = [0.8500 0.3250 0.0980];
color3 = [0.9290 0.6940 0.1250];
color4 = [0.4940 0.1840 0.5560];
color5 = [0.4660 0.6740 0.1880];
color6 = [0.3008 0.7422 0.9297];
color_gray_1 = [0.5 0.5 0.5];
mycolors_1 = [color1; color2; color3; color4; color5; color5;];
mycolors_2 = [color1; color2; color3; color4; color5; color6; color6;];

% 1st Stage
figure (1);
semilogx(f, S_N_TOT_A_dB, 'LineWidth', 7);
hold on;
semilogx(f, S_N_REF_dB, f, S_N_PD_A_dB, f, S_N_LF_A_dB, f, S_N_VCO_A_dB, 'LineWidth', 3);
semilogx(f, S_N_VCO_free_A_dB, 'LineWidth', 3, 'LineStyle', ':');
legend ('Aux total', 'Reference', 'PD', 'LF' ,'VCO', 'VCO freerun');
colororder(mycolors_1)
set(gca, 'FontName', 'Arial', 'fontsize', 16, 'fontweight', 'b');
ylim([-250 -50]);
grid on;
xlabel('Offset Frequency [Hz]');
ylabel('Phase Noise [dBc/Hz]');
title('Phase Noise: 1st stage');

% 2nd Stage
figure (2);
semilogx(f, S_N_TOT_M_dB, 'LineWidth', 7);
hold on;
semilogx(f, S_N_FROM_A_dB, f, S_N_DSM_dB, f, S_N_PD_M_dB, f, S_N_LF_M_dB, f, S_N_VCO_M_dB, 'LineWidth', 3);
semilogx(f, S_N_VCO_free_M_dB, 'LineWidth', 3, 'LineStyle', ':');
xline(PLL_BW, 'LineWidth',3);
legend ('Total', 'External PLL Contribution: ' + string(round(A_AUX_M_T_contribution*100, 1)) + '%', ...
    'DSM: ' + string(round(A_DSM_T_contribution*100, 1)) + '%', ...
    'PD: ' + string(round(A_PD_M_T_contribution*100, 1)) + '%', ...
    'LF: ' + string(round(A_LF_M_T_contribution*100, 1)) + '%', ...
    'VCO: ' + string(round(A_VCO_M_T_contribution*100, 1)) + '%', ...
    'VCO freerun', ...
    '(Loop Bandwidth = ' + string(PLL_BW/1e6) + 'MHz)');
colororder(mycolors_2)
set(gca, 'FontName', 'Arial', 'fontsize', 16, 'fontweight', 'b');
ylim([-250 -50]);
grid on;
xlabel('Offset Frequency [Hz]');
ylabel('Phase Noise [dBc/Hz]');
title('Phase Noise: 2nd stage');

% Bode plot: Open Loop
figure(3);
subplot(2,1,1);
semilogx(f, 20 .* log10(H_OL_M), 'LineWidth', 3);
xline(PLL_BW, 'LineWidth',3);
legend ('', 'Loop Bandwidth = ' + string(PLL_BW/1e6) + 'MHz');
set(gca, 'FontName', 'Arial', 'fontsize', 16, 'fontweight', 'b');
grid on;
xlabel('Offset Frequency [Hz]');
ylabel('Gain [dB]');
title('Bode plot: Open Loop');

subplot(2,1,2);
semilogx(f, unwrap(angle(H_OL_M))*180/pi, 'LineWidth', 3);
xline(PLL_BW, 'LineWidth',3);
set(gca, 'FontName', 'Arial', 'fontsize', 16, 'fontweight', 'b');
grid on;
xlabel('Offset Frequency [Hz]');
ylabel('Phase [deg]');

% Bode plot: Loop Filter
figure(4);
subplot(2,1,1);
semilogx(f, 20 .* log10(F_LF_M), 'LineWidth', 3);
xline(f_u_M, 'LineWidth',3, 'Color',color_gray_1);
xline(f1_M, 'LineWidth',3, 'Color',color1);
xline(f2_M, 'LineWidth',3, 'Color',color2);
xline(f3_M, 'LineWidth',3, 'Color',color3);
legend ('', 'f_u: ' + string(f_u_M/1e6) + 'MHz', 'pole_1: ' + string(f1_M/1e3) + 'kHz', 'zero_1: ' + string(f2_M/1e6) + 'MHz', 'pole_2: ' + string(f3_M/1e6) + 'MHz');
set(gca, 'FontName', 'Arial', 'fontsize', 16, 'fontweight', 'b');
grid on;
xlabel('Offset Frequency [Hz]');
ylabel('Gain [dB]');
title('Bode plot: Loop Filter');

subplot(2,1,2);
semilogx(f, angle(F_LF_M)*180/pi, 'LineWidth', 3);
xline(f_u_M, 'LineWidth',3, 'Color',color_gray_1);
xline(f1_M, 'LineWidth',3, 'Color',color1);
xline(f2_M, 'LineWidth',3, 'Color',color2);
xline(f3_M, 'LineWidth',3, 'Color',color3);
set(gca, 'FontName', 'Arial', 'fontsize', 16, 'fontweight', 'b');
grid on;
xlabel('Offset Frequency [Hz]');
ylabel('Phase [deg]');



%% print values
fprintf('f_u_M: %f [MHz]\n', f_u_M/1e6);
fprintf('R1_M: %f[kOhm]\n', R1_M / 1e3);
fprintf('C1_M: %f[pF]\n', C1_M / 1e-12);
fprintf('R2_M: %f[kOhm]\n', R2_M / 1e3);
fprintf('C2_M: %f[pF]\n', C2_M / 1e-12);