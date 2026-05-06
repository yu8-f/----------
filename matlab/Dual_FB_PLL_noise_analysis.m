%% Noise analysis of Analog Dual feedback PLL

close all;
clear all;

%% Laplace transform

f = 1e3 : 10e3 : 1e9;
s = 1j .* f .* 2 .* pi;

%% Constants

k = 1.38e-23;
T = 300;

%% Loop parameters

N_INT = 56;
N_IAC = 2;
N_HM = 3;
N_FAC = 42.07293;
V_DD = 1.2;

l = 3;          %DSM order

f_ref = 48.812e6;
f_int = N_INT * f_ref;
f_out = (N_FAC / (N_FAC - 1)) * (N_HM / N_IAC) * f_int;
f_m = f_out / N_FAC;

K_VCOA = 2 * pi * 30e6;
K_WA = 1; 
C1A = 5e-12;
C2A = 500e-15;
I_BUF = 20e-3;
V_T = 0.4;
t_rise = (C1A * V_DD) / I_BUF;
%% K_PDA = (V_DD / (2 * pi * f_ref * t_rise));
K_PDA = 20;

w_u = 2 * pi * 3e6;
a = 3;
t_on = 100e-12;
v_ov = 0.2;
I_CP = 20e-6;
K_VCOM = 2 * pi * 30e6;
K_WM = 1;

%% Integer loop filter
F_A = (f_ref .* ((C1A / C2A) ./ (s + ((C1A * f_ref) / C2A)))) .* ((cos((pi .* f) ./ f_ref)) - (1j .*sin((pi .* f) ./ f_ref))) .* ((f_ref .* (sin((pi .* f) ./ f_ref))) ./ (pi .* f));
F_A_dB = 20 .* log10(abs(F_A));

%% Main loop filter
C1M = a * (K_VCOM / (2 * pi)) * (I_CP / ((w_u) ^ 2));
C2M = C1M / (a ^ 2);
RM = a / (C1M * w_u);
F_M = ((s .* RM .* C1M) + 1) ./ (((s .^2) .* RM .* C1M .* C2M) + (s .* (C1M + C2M)));
F_M_dB = 20 .* log10(abs(F_M));

%% Integer loop noise sources
n_psd_buf = ((2 * k * T) / I_BUF) .* (((4 / 3) / (V_DD - V_T)) + (1 / V_DD)) .* (f_ref ./ f) .^ 2;
n_psd_vcoa = K_WA ./ (f .^ 2);
n_psd_ref = 1e-16;

%% Main loop noise sources
n_psd_dsm = ( ( (2 * pi) / N_FAC) ^ 2) .* (1 / 12) .* (1 / f_m) .* ( (2 .* sin(pi .* f ./ f_m) ) .^ (2 * (l-1) ) );
n_psd_cp = (16 * t_on * k * T * I_CP * f_m) / (v_ov);
n_psd_lf = 4 * k * T * RM;
n_psd_vcom = K_WM ./ (f .^ 2);

%% Integer loop transfer functions
A_OL = K_PDA .* F_A .* (K_VCOA ./ s) .* (1 / N_INT);
A_OL_dB = 20 .* log10(abs(A_OL));

A_LP = A_OL ./ (1 + A_OL);
A_LP_dB = 20 .* log10(abs(A_LP));

A_HP = 1 ./ (1 + A_OL);
A_HP_dB = 20 .* log10(abs(A_HP));

%% Main loop transfer functions
M_OL = ((N_FAC - 1) / N_FAC) .* (I_CP / (2 * pi)) .* F_M .* (K_VCOM ./ s);
M_OL_dB = 20 .* log10(abs(M_OL));

M_LP = M_OL ./ (1 + M_OL);
M_LP_dB = 20 .* log10(abs(M_LP));

M_HP = 1 ./ (1 + M_OL);
M_HP_dB = 20 .* log10(abs(M_HP));

M_BP = (K_VCOM ./ s) .* M_HP;
M_BP_dB = 20 .* log10(abs(M_BP));

%% Integer loop noise
S_N_REF = ((abs(N_INT .* A_LP)) .^2) * n_psd_ref;
S_N_REF_dB = 10 .* log10(S_N_REF);

S_N_BUF = ((abs(A_LP)) .^ 2) .* n_psd_buf;
S_N_BUF_dB = 10 .* log10(S_N_BUF);

S_N_VCOA = ((abs(A_HP)) .^ 2) .* n_psd_vcoa;
S_N_VCOA_dB = 10 .* log10(S_N_VCOA);

S_N_INT = S_N_REF + S_N_BUF + S_N_VCOA;
S_N_INT_dB = 10 .* log10(S_N_INT);

%% Main loop noise
S_N_CP = ((abs((N_FAC / (N_FAC -1)) .* ((2 * pi) / (I_CP)) .* M_LP)) .^ 2) .* n_psd_cp;
S_N_CP_dB = 10 .* log10(S_N_CP);

S_N_LF = ((abs(M_BP)) .^ 2) .* n_psd_lf;
S_N_LF_dB = 10 .* log10(S_N_LF);

S_N_DSM = ((abs((N_FAC / (N_FAC-1)) .* M_LP)) .^ 2) .* n_psd_dsm;
S_N_DSM_dB = 10 .* log10(S_N_DSM);
S_N_DSM_CONV = ((N_FAC) ^ 2) .* S_N_DSM;
S_N_DSM_CONV_dB = 10 .* log10(S_N_DSM_CONV);

S_N_VCOM = ((abs(M_HP)) .^ 2) .* n_psd_vcom;
S_N_VCOM_dB = 10 .* log10(S_N_VCOM);

S_N_INT_OUT = ((abs((N_FAC / (N_FAC -1)) .* (N_HM / N_IAC) .* M_LP)) .^ 2) .* S_N_INT;
S_N_INT_OUT_dB = 10 .* log10(S_N_INT_OUT);

S_N_TOT = S_N_INT_OUT + S_N_CP + S_N_LF + S_N_DSM + S_N_VCOM;
S_N_TOT_dB = 10 .* log10(S_N_TOT);

%% Integrated jitter
A_INT = S_N_INT .* 10e3;
A_INT_T = sum(A_INT);
J_INT = (sqrt(2 * A_INT_T) ) / (2 * pi * f_int);

A = S_N_TOT .* 10e3;
A_T = sum(A);
J = (sqrt(2 * A_T) ) / (2 * pi * f_out);

A_DSM = S_N_DSM .* 10e3;
A_DSM_T = sum(A_DSM);
J_DSM = (sqrt(2*A_DSM_T)/(2*pi*f_out));

disp(J_INT);
disp(J);
disp(J_DSM);

%% For SSCL
EQ_2 = (N_FAC / (N_FAC - 1)) .* M_LP;
EQ_2_dB = 10 .* log10(EQ_2);

EQ_3 = ((2 * pi) / I_CP) .* EQ_2;
EQ_3_dB = 10 .* log10(EQ_3);

EQ_4 = (N_HM / N_IAC) .* EQ_2;
EQ_4_dB = 10 .* log10(EQ_4);

%% Noise contribution plots
figure (1);
semilogx(f, S_N_INT_dB, f, S_N_REF_dB, f, S_N_BUF_dB, f, S_N_VCOA_dB, 'LineWidth', 2);
set(gca, 'FontName', 'Arial', 'fontsize', 12, 'fontweight', 'b');
axis ([10e3 1e9 -250 -80]);
grid on;
legend ('Integer total', 'Reference', 'Buffer', 'VCO');
xlabel('f_o_f_f_s_e_t (Hz)');
ylabel('PN (dBc/Hz)');

figure (2);
semilogx(f, S_N_TOT_dB, f, S_N_INT_OUT_dB, f, S_N_DSM_dB, f, S_N_DSM_CONV_dB, f, S_N_CP_dB, f, S_N_LF_dB, f, S_N_VCOM_dB, 'LineWidth', 2);
set(gca, 'FontName', 'Arial', 'fontsize', 12, 'fontweight', 'b');
axis ([1e3 1e9 -200 -80]);
grid on;
legend ('Total', 'Integer loop', 'Fractional divider', 'Fractional divider amplified', 'CP', 'Loop filter', 'VCO');
xlabel('f_o_f_f_s_e_t (Hz)');
ylabel('PN (dBc/Hz)');

%% Transfer function plots
figure(3);
semilogx(f, F_A_dB, f, F_M_dB, 'Linewidth', 2);
set(gca, 'Fontname', 'Arial', 'fontsize', 12, 'fontweight', 'b');
axis([10e3 1e9 -100 150]);
grid on;
legend('Integer filter', 'Main filter');
xlabel('f_o_f_f_s_e_t (Hz)');
ylabel('PN (dBc/Hz)');

figure(4);
semilogx(f, A_OL_dB, f, A_LP_dB, f, A_HP_dB, 'Linewidth', 2);
set(gca, 'Fontname', 'Arial', 'fontsize', 12, 'fontweight', 'b');
axis([10e3 1e9 -100 120]);
grid on;
legend('Integer open loop', 'Integer Low pass', 'Integer High pass');
xlabel('f_o_f_f_s_e_t (Hz)');
ylabel('PN (dBc/Hz)');

figure(5);
semilogx(f, M_OL_dB, f, M_LP_dB, f, M_HP_dB, f, M_BP_dB, 'Linewidth', 2);
set(gca, 'Fontname', 'Arial', 'fontsize', 12, 'fontweight', 'b');
axis([10e3 1e9 -100 100]);
grid on;
legend('Main open loop', 'Main Low pass', 'Main High pass', 'Main Band pass');
xlabel('f_o_f_f_s_e_t (Hz)');
ylabel('PN (dBc/Hz)');

figure(6);
semilogx(f, EQ_2_dB, f, EQ_3_dB, f, EQ_4_dB, 'Linewidth', 2);
set(gca, 'Fontname', 'Arial', 'fontsize', 12, 'fontweight', 'b');
axis([10e3 100e6 -40 80]);
grid on;
legend('Equation 2', 'Equation 3', 'Equation 4');
xlabel('f_o_f_f_s_e_t (Hz)');
ylabel('PN (dBc/Hz)');