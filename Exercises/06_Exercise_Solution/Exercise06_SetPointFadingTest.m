% -----------------------------
% Script: Tests Advanced Torque Controller
% Exercise 06 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
%
% ------------
% History:
% v02:	David Schlipf on 06-Dec-2020
% v01:	David Schlipf on 17-Nov-2019
% ----------------------------------

clearvars;close all;clc;

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW2DOF;
Parameter                       = NREL5MWDefaultParameter_FBSWE_Ex6_SPF(Parameter);

% Time
Parameter.Time.dt                       = 0.01;            % [s] simulation time step            
Parameter.Time.TMax                     = 30;              % [s] simulation length

% Wind
DeltaU                                  = .1;
URef                                    = 11.6;                
Disturbance.v_0.time                    = [0;   10;  10.01;      	30];            % [s]      time points to change wind speed
Disturbance.v_0.signals.values          = [URef;URef; URef+DeltaU;  URef+DeltaU];   % [m/s]    wind speeds  

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','Omega','theta','x_T','M_g');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
Parameter.IC.x_T                = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');
Parameter.IC.M_g                = interp1(SteadyStates.v_0,SteadyStates.M_g     ,URef,'linear','extrap');

%% Processing SLOW
sim('NREL5MW_FBSWE_SLOW2DOF_Ex6_SPF.mdl')

%% PostProcessing SLOW
figure

% plot generator torque
subplot(511)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.M_g.Data/1e3)
ylabel('$M_G$ [kNm]','Interpreter','latex')

% plot pitch angle
subplot(512)
hold on;box on;grid on;
plot(tout,logsout.get('u').Values.theta_c.Data/2/pi*360)
ylabel('$\theta$ [deg]','Interpreter','latex')

% plot generator speed
subplot(513)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega_g.Data*60/2/pi)
ylabel('$\Omega_G$ [rpm]','Interpreter','latex')

% plot delta generator speed
subplot(514)
hold on;box on;grid on;
plot(tout,logsout.get('logFB').Values.Delta_Omega_g.Data*60/2/pi)
plot(tout,logsout.get('logFB').Values.Delta_Omega_g_f.Data*60/2/pi)
ylabel('$\Delta\Omega_g$ [rpm]','Interpreter','latex')

% plot generator power
subplot(515)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.P_el.Data/1e6)
ylabel('$P$ [MW]','Interpreter','latex')

xlabel('time [s]')