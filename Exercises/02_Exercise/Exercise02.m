% -----------------------------
% Script: Tests Baseline Torque Controller
% Exercise 02 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
%
% ------------
% History:
% v01:	David Schlipf on 29-Sep-2019
% ----------------------------------

clearvars;close all;clc;

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_Ex2(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 60;   % [s] simulation lenght

% wind
Disturbance.v_0.time            = [0; 30; 30+dt; 60]; % [s]      time points to change wind speed
Disturbance.v_0.signals.values  = [8;  8;     9;  9]; % [m/s]    wind speeds

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,8,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,8,'linear','extrap');


%% Processing SLOW
sim('NREL5MW_FBNREL_SLOW1DOF_Ex2.mdl')

%% PostProcessing SLOW
figure


% plot wind
subplot(411)
hold on;box on;grid on;
plot(tout,logsout.get('d').Values.v_0.Data)
ylabel('v_0 [m/s]')

% plot generator torque
subplot(412)
hold on;box on;grid on;
plot(tout,logsout.get('u').Values.M_g_c.Data/1e3)
ylabel('M_G [kNm]')

% plot rotor speed
subplot(413)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega.Data*60/2/pi)
ylabel('\Omega [rpm]')

% plot tip speed ratio
subplot(414)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.lambda.Data)
ylabel('\lambda [-]')
xlabel('time [s]')



%% PostProcessing FAST
fid         = fopen(OutputFile);
formatSpec  = repmat('%f',1,10);
FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
Time        = FASTResults{:,1};
Wind1VelX   = FASTResults{:,2};
RotSpeed    = FASTResults{:,4};
GenPwr      = FASTResults{:,9};
fclose(fid);

%% Compare Results
fprintf('Time Ratio SLOW (Sim/CPU): %f\n',TimeRatio)

figure