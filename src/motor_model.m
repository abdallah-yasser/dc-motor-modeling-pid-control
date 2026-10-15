%% DC Motor Modeling - FAULHABER 2237S006CXR
% Derives the speed and current transfer functions three ways
% (hand calculation, feedback() blocks, Simulink linearization)
% and computes the partial-fraction (residue) form.
% Run this script first: it also loads the parameters used by the
% Simulink models in /models.

%% Motor parameters (FAULHABER 2237S006CXR, datasheet)
V_an  = 6;          % V,     nominal voltage
R_a   = 0.851;      % Ohm,   armature resistance
L_a   = 32.9e-6;    % H,     armature inductance
kfi   = 7.45e-3;    % Vs/rad, torque / back-EMF constant
I_anl = 0.125;      % A,     no-load current
J_m   = 3.1e-7;     % kgm^2, rotor inertia

% Viscous friction coefficient (from no-load operating point)
B_m = (kfi^2 * I_anl) / (V_an - R_a * I_anl);   % Nms

%% Load torques for simulation
T_nl = 0;          % Nm, no-load torque
T_1  = 5e-3;       % Nm, intermediate torque
T_n  = 11.7e-3;    % Nm, nominal torque
T_2  = 30e-3;      % Nm, intermediate torque
T_s  = 47.2e-3;    % Nm, stall torque

%% 1) Transfer functions - hand calculated
num   = kfi;
denom = [(J_m*L_a) (B_m*L_a + J_m*R_a) (kfi^2 + B_m*R_a)];
omega1   = tf(num, denom)          % Omega(s) / U(s)

numI     = [J_m B_m];
current1 = tf(numI, denom)         % I(s) / U(s)

%% 2) Transfer functions - built from blocks with feedback()
TFe  = tf(1, [L_a R_a]);           % electrical part
TFm  = tf(1, [J_m B_m]);           % mechanical part
kfi1 = tf(kfi);

omega2   = feedback(TFe * kfi1 * TFm, kfi1)
current2 = feedback(TFe, kfi1 * TFm * kfi1)

%% 3) Transfer functions - from the Simulink model (Model Linearizer)
% Open models/motor_transfer_function.slx, linearize it with the
% Model Linearizer app (sessions in /linearization) and export
% linsys1 (current) and linsys2 (speed) to the workspace.
if exist('linsys1', 'var') && exist('linsys2', 'var')
    current3 = tf(linsys1)
    omega3   = tf(linsys2)
end

%% Partial-fraction expansion
[r,  p,  k ] = residue(num,  denom)
[r1, p1, k1] = residue(numI, denom)

%% Time constants
T_e = L_a / R_a                    % electrical time constant
T_m = J_m * R_a / kfi^2            % mechanical time constant

%% Step response at nominal voltage
figure('Color', 'w');
subplot(1,2,1); step(V_an * omega1 * 30/pi); grid on;
title('Speed [rpm]');
subplot(1,2,2); step(V_an * current1); grid on;
title('Armature current [A]');
