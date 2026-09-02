function obj = opt_for_nested(x, M, V)

%% function f = evaluate_objective(x, M, V)
% Function to evaluate the objective functions for the given input vector
% x. x is an array of decision variables and f(1), f(2), etc are the
% objective functions. The algorithm always minimizes the objective
% function hence if you would like to maximize the function then multiply
% the function by negative one. M is the numebr of objective functions and
% V is the number of decision variables. 
%
% This functions is basically written by the user who defines his/her own
% objective function. Make sure that the M and V matches your initial user
% input. Make sure that the 
%
% An example objective function is given below. It has two six decision
% variables are two objective functions.

% f = [];
% %% Objective function one
% % Decision variables are used to form the objective function.
% f(1) = 1 - exp(-4*x(1))*(sin(6*pi*x(1)))^6;
% sum = 0;
% for i = 2 : 6
%     sum = sum + x(i)/4;
% end
% %% Intermediate function
% g_x = 1 + 9*(sum)^(0.25);
% 
% %% Objective function two
% f(2) = g_x*(1 - ((f(1))/(g_x))^2);

%% Kursawe proposed by Frank Kursawe.
% Take a look at the following reference
% A variant of evolution strategies for vector optimization.
% In H. P. Schwefel and R. Männer, editors, Parallel Problem Solving from
% Nature. 1st Workshop, PPSN I, volume 496 of Lecture Notes in Computer 
% Science, pages 193-197, Berlin, Germany, oct 1991. Springer-Verlag. 
%
% Number of objective is two, while it can have arbirtarly many decision
% variables within the range -5 and 5. Common number of variables is 3.
obj = [];
Fc_main = x(1);
P_vco = x(2);
%Optimization for HM-PLL  
%close all; clear variables; clc;
%Laplace transform
% f = 1e3 : 10e3 : 1e9;
f = 1e3 : 10e3 : 1e8;
s = 1j .* f .* 2 .* pi;
y = 1;
Q = 10;
%P_main = 20;
% Integrated range of RMS jitter 
Nstart = 1;
Nstop = 10001; % 100MHz
% Nstop = 1001; % 10MHz
% Nstop = 4001; % 40MHz
% Nstop = length(f); % 1GHz
%Constants
k = 1.38e-23;
T = 300;
%Loop Parameters
%Integer-N PLL
Fref = 50e6;  %% Reference frequency
Kvco = 2*pi*100e6; % (rad/s)/V
%Kspdp = 0.4;   %% Main SPD gain, V/rad
Icp = 100e-6; % A
Kpfdcp =  Icp/(2*pi); % A/rad
N = 62.06;
Wc = Fc_main*(2*pi); % rad/s
l = 3; %DSM Order
%Calculate LPF parameters
%Tp = (sec(PM)-tan(PM))/Wc; % Time constant of pole;
%Tz = 1/(Wc*Wc*Tp);
Tp = 1/(Wc*5);
Tz = 1/(Wc/5);
Ctotal = Kpfdcp*Kvco/(N*Wc^2)*sqrt((1+(Wc*Tz)^2)/(1+(Wc*Tp)^2));
C2 = Ctotal*Tp/Tz;
C1 = Ctotal-C2;
R1 = Tz/C1;
Hlf = (1+Tz.*s)./(Ctotal .*(s.* (1 + Tp.*s) )); % 2nd-order loop filter in type-ii HMPLL
Fout = Fref * N; %% Output Frequency
%Loop Filters

%Loop Transfer Functions
%Main PLL
Hopen2 = Kpfdcp .* Hlf .* (Kvco ./ s) .* (1/N);
Hopen2dB = 20 .* log10(abs(Hopen2));

Hclose2 = N .* Hopen2 ./ (1 + Hopen2);
Hclose2dB = 20 .* log10(abs(Hclose2));

Hvco2 = 1 ./ (1+Hopen2);
Hvco2dB = 20 .* log10(abs(Hvco2));

%%-- Calculate -3dB bandwidth of closed loop
Hclose2_dc = Hclose2dB(1);
% for n=1:length(Hclose2dB)
%     BW_close2 = f(n);
%     Hclose2_BW = Hclose2dB(n);
%     if Hclose2_BW<=Hclose2_dc-3
%         break
%     end
% end
%display(strcat('Main PLL Closed-Loop -3dB BW =',32,num2str(BW_close2*1e-6),32,'MHz'));

%Noise Sources
%HM PLL
n_psd_ref = 1e-16;
n_psd_vco2 = 4.*pi.*k.*T.*(1+y) .* (Fout ./ 2 ./ Q ./f) .^2 ./ (P_vco.*1e-3);
Svco2_Free_dB =  10 .* log10(n_psd_vco2);
n_psd_dsm = ( ( (2 * pi) / N) ^ 2) .* (1 / 12) .* (1 / Fref) .* ( (2 .* sin(pi .* f ./ Fref) ) .^ (2 * (l-1) ) );
%Output Noise
%Main PLL
Svco2 = (abs(Hvco2) .^ 2) .* n_psd_vco2;
Svco2dB = 10 .* log10(Svco2);

Sref = (abs(Hclose2) .^ 2) .* n_psd_ref;
SrefdB = 10 .* log10(Sref);

Sdsm = (abs(Hclose2) .^ 2) .* n_psd_dsm;
SdsmdB = 10 .* log10(Sdsm);

%Stotal = Svco2 + Sref + Sdsm;
Stotal = Svco2 + Sdsm;
StotaldB = 10 .* log10(Stotal);

A = Stotal .* 10e3;
A_T = sum(A);
J = (sqrt(2 * A_T) ) / (2 * pi * Fout);
obj(1) = (sqrt(2 * A_T) ) / (2 * pi * Fout);
obj(2) = P_vco;

%display(strcat('Total Jitter =',32,num2str(J_Nest*1e15),32,'fs'));
%display(strcat('FOM =',32,num2str(objective),32));


%% Check for error
if length(obj) ~= M
    error('The number of decision variables does not match you previous input. Kindly check your objective function');
end