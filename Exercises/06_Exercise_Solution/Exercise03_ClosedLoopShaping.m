% -----------------------------
% Script: Closed Loop Shaping of Pitch Controller
% Exercise 03 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
% - Get operation point
% - Linearize at each operation point
% - Determine theta, kp and Ti for each operation point
% - Copy the output into NREL5MWDefaultParameter_FBNREL_Ex3.m
% ------------
% History:
% v01:	David Schlipf on 06-Oct-2019
% ----------------------------------

clearvars;close all;clc;

%% Design
OPs         = [5 11];
D_d         = 0.7;
omega_d     = 0.5;

%% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW2DOF;
Parameter.VSC.P_a_rated       	= 5e6/Parameter.Generator.eta_el;   % [W]
SteadyStates                    = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','Omega','theta');                       

%% loop over operation points
nOP     = length(OPs);
kp      = NaN(1,nOP);
Ti      = NaN(1,nOP);
theta   = NaN(1,nOP);

for iOP=1:nOP  
    
    % Get operation point
    v_0_OP    = OPs(iOP); % Wind speed OP
    Omega_OP  = interp1(SteadyStates.v_0,SteadyStates.Omega,v_0_OP,'linear','extrap'); % RotSpeed OP
    theta_OP  = interp1(SteadyStates.v_0,SteadyStates.theta,v_0_OP,'linear','extrap'); % BldPitch OP
    
    % Linearize at each operation point
    [A,B,C,D] = LinearizeSLOW1DOF_TC(Omega_OP,v_0_OP,Parameter);
        
    % Determine theta, kp and Ti for each operation point
    theta(iOP) = theta_OP;
    kp(iOP)    = -(2*D_d*omega_d+A)/(B(1)*C);
    ki         = -omega_d^2 /(B(1)*C);
    Ti(iOP)    = kp(iOP)/ki;

end

fprintf('Parameter.CPC.GS.theta                  = [%s];\n',sprintf('%f ',theta));
fprintf('Parameter.CPC.GS.kp                     = [%s];\n',sprintf('%f ',kp));
fprintf('Parameter.CPC.GS.Ti                     = [%s];\n',sprintf('%f ',Ti));  

pole1 = -D_d*omega_d + sqrt(omega_d^2-1);
pole2 = -D_d*omega_d-sqrt(omega_d^2-1);

%% Transfer function

sys_ss = ss(A,B,C,D);
sys_ss.InputName  	= {'theta','v_0'};
sys_ss.OutputName 	= {'Omega_g'};   

figure
for iOP=1:nOP  
    
    s                   = tf('s');    
    PC                  = kp(iOP)*(1+1/Ti(iOP)*1/s);
    PC.InputName        = {'Omega_g'};    
    PC.OutputName       = {'theta'}; 

    CL_2DOF             = connect(sys_ss,PC,'v_0',{'Omega_g'});
    
    hold on; box on; grid on;
    
    step(CL_2DOF)
    legend('iOP = 5 m/s', 'iOP = 11 m/s')

end

figure
for iOP=1:nOP
    
    num = [C*B(2) 0];
    den = [1 (-A - B(1)*C*kp(iOP)) (-B(1)*C*kp(iOP)/Ti(iOP))];
    sys = tf(num, den);
    
    hold on; box on; grid on;
    step(sys)
    legend('iOP = 5 m/s', 'iOP = 11 m/s')

end

figure  
num = [1*omega_d^2 0];
den = [1 (2*D_d*omega_d) (omega_d^2)];
sys = tf(num, den);
hold on; box on; grid on;
step(sys)
