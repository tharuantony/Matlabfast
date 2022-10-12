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
OPs         = [12 16 20 24];
D_d         = 0.7;
omega_d     = 0.5;

%% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter.VSC.P_a_rated       	= 5e6/Parameter.Generator.eta_el;   % [W]
SteadyStates                    = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       

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
    [A,B,C,D] = LinearizeSLOW1DOF_PC(theta_OP,Omega_OP,v_0_OP,Parameter);
        
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
num = [omega_d^2];
den = [1 2*D_d*omega_d omega_d^2];
sys = tf(num,den);
step(sys)

 
