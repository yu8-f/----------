function obj = opt_for_nested(x, M, V)

obj = [];
f_u = x(1);
P_1 = x(2);
P_2 = x(3);
%Optimization for HM-PLL  
%%% Laplace transform

f = 1e3 : 10e3 : 100e6;
s = 1j .* f .* 2 .* pi;

%% Constants

k = 1.38e-23;
T = 300;
r = 1;

%% Loop parameters

f_REF = 50e6;
N_FAC = 62.06;
f_OUT = N_FAC * f_REF;
l = 3; %DSM order

P_VCO = P_1 * 1e-3;
Q = 10;

K_VCOn = (4*pi*k*T*(1+r) / P_VCO) * ((f_OUT / (2 * Q))^2);
K_VCO = 2 * pi * 30e6;
I_CP = 100e-6;
v_ov = 0.2;
t_on = 100e-12;
a = 5;
w_u = 2 * pi * 1e6 * f_u;
FOM_VCO = 10 .* log10(Q^2 / (1000 * pi * k * T * (1+r)));

P_PD = P_2 * 1e-3;

%% Loop Filter

C1 = a * (K_VCO / (2 * pi)) * (I_CP / (N_FAC * (w_u) ^ 2));
C2 = C1 / (a ^ 2);
R = a / (C1 * w_u);
F_LF = ((s .* R .* C1) + 1) ./ (((s .^2) .* R .* C1 .* C2) + (s .* (C1 + C2)));
F_LF_dB = 20 .* log10(abs(F_LF));

%% Loop Transfer Functions

H_OL = (I_CP / (2 * pi)) .* F_LF .* (K_VCO ./ s) .* (1 / N_FAC);
H_OL_dB = 20 .* log10(H_OL);

H_LP = N_FAC .* (H_OL ./ (1 + H_OL));
H_LP_dB = 20 .* log10(H_LP);

H_HP = 1 ./ (1 + H_OL);
H_HP_dB = 20 .* log10(H_HP);

H_BP = (K_VCO ./ s) .* (1 ./ (1 + H_OL));
H_BP_dB = 20 .* log10(H_BP);

%% Noise Sources

n_psd_in = 1e-16;
n_psd_dsm = ( ( (2 * pi) / N_FAC) ^ 2) .* (1 / 12) .* (1 / f_REF) .* ( (2 .* sin(pi .* f ./ f_REF) ) .^ (2 * (l-1) ) );
n_psd_vco = K_VCOn ./ (f .^ 2);
n_psd_pd = 1e-20 / P_PD;

%% Noise Contributions

S_N_IN = ((abs(H_LP)).^2) .* n_psd_in;
S_N_IN_dB = 10 .* log10(S_N_IN);

S_N_PD = ((abs(H_LP)).^2) .* n_psd_pd;
S_N_PD_dB = 10 .* log10(S_N_PD);

S_N_DSM = ((abs(H_LP)).^2) .* n_psd_dsm;
S_N_DSM_dB = 10 .* log10(S_N_DSM);

S_N_VCO = ((abs(H_HP)).^2) .* n_psd_vco;
S_N_VCO_dB = 10 .* log10(S_N_VCO);

S_N_TOT = S_N_IN + S_N_DSM + S_N_VCO + S_N_PD;
S_N_TOT_dB = 10 .* log10(S_N_TOT);

S_N_VCO_free = K_VCOn ./ (f .^ 2);
S_N_VCO_free_dB = 10 .* log10(S_N_VCO_free);

S_N_INT = S_N_IN + S_N_VCO + S_N_PD;
S_N_INT_dB = 10 .* log10(S_N_INT);

%% Integrated Jitter
A = S_N_TOT .* 10e3;
A_T = sum(A);
J = (sqrt(2 * A_T) ) / (2 * pi * f_OUT);

A_INT = S_N_INT .* 10e3;
A_INT_T = sum(A_INT);
J_INT = (sqrt(2 * A_INT_T) ) / (2 * pi * f_OUT);
P = P_1 + P_2;
obj(1) = J;
obj(2) = P;



%% Check for error
if length(obj) ~= M
    error('The number of decision variables does not match you previous input. Kindly check your objective function');
end
end