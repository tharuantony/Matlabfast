%% 1. Initialization 
clearvars;close all;clc;

%% 2. Values for 20 m/s
% Linear wind turbine model
% x_dot = A x + B u
% y     = C x + D u
% with
% x_1   = Omega
% x_2   = x_T
% x_3   = x_T_dot
% u_1   = theta
% u_2   = v_0
% y_1   = Omega_g
% y_2   = x_T_dot

A = [   -0.2465         0   -0.0299
              0         0    1.0000
        -1.6613   -4.1443   -0.2210];
B = [   -1.3820    0.0299
              0         0
        -9.6088    0.1803];
C = [        97         0         0
              0         0         1];
D = [         0         0
              0         0];
kp                  = 0.003383;
Ti                  = 1.814097;

%% 3. Define Wind Turbine
WT_2DOF             = ss(A,B,C,D);
WT_2DOF.InputName  	= {'theta','v_0'};
WT_2DOF.OutputName 	= {'Omega_g','x_T_dot'};   

%% 4. Define Pitch Controller
s                   = tf('s');    
PC                  = kp*(1+1/Ti*1/s); % Ex.5.1b: Please adjust!
PC.InputName        = {'Omega_g'};    
PC.OutputName       = {'theta'};  

%% 5. Closed Loop without Tower Damper
CL_2DOF             = connect(WT_2DOF,PC,'v_0',{'Omega_g','x_T_dot'});
disp('--- Closed Loop without Tower Damper --------------------------------')
damp(CL_2DOF)
disp('---------------------------------------------------------------------')

%% 6. Desired Closed loop
D_d                 = 0.7;
omega_0_d           = 0.5;
G_0                 = B(1,2)/omega_0_d.^2.*C(1,1);
CL_1DOF             = tf([G_0*omega_0_d^2 0],[1 2*D_d*omega_0_d omega_0_d^2]);
disp('--- Desired Closed loop ---------------------------------------------')
damp(CL_1DOF)
disp('---------------------------------------------------------------------')

%% 7. Define Tower Damper 
gain                = 0.04375; % Ex.5.1c: Please adjust!
TD                  = tf(gain); 
TD.InputName        = {'x_T_dot'};    
TD.OutputName       = {'theta'};    
    
%% 8. Closed Loop with Tower damper
CL_2DOF_TD       	= connect(WT_2DOF,[PC TD],'v_0',{'Omega_g','x_T_dot'});
disp('--- Closed Loop with Tower damper -----------------------------------')
damp(CL_2DOF_TD)
disp('---------------------------------------------------------------------')

%% 9. Compare Step response
figure
step(CL_1DOF,CL_2DOF,CL_2DOF_TD)
legend('Desired CL','CL without TD','CL with TD')
xlim([0 30])

figure
bode(CL_1DOF,CL_2DOF,CL_2DOF_TD)
legend('Desired CL','CL without TD','CL with TD')

%% PZ map
figure
hold on
pzmap(CL_1DOF,CL_2DOF,CL_2DOF_TD)
legend('Desired CL','CL without TD','CL with TD')
