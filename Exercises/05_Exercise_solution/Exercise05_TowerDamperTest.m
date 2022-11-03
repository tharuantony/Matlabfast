% -----------------------------
% Script: Tests Tower Damper
% Exercise 05 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
%
% ------------
% History:
% v01:	David Schlipf on 27-Oct-2019
% ----------------------------------

clearvars;close all;clc;

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW2DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_Ex5(Parameter);

% Time
Parameter.Time.dt                       = 0.01;            % [s] simulation time step            
Parameter.Time.TMax                     = 60;              % [s] simulation lenght

% Wind
DeltaU                                  = 1;
URef                                    = 20;                
Disturbance.v_0.time                    = [0;   30;     30.01;      	60];            % [s]      time points to change wind speed
Disturbance.v_0.signals.values          = [URef; URef;  URef+DeltaU;  URef+DeltaU];   % [m/s]    wind speeds  

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta','x_T');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
Parameter.IC.x_T                = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');

%% Processing SLOW
sim('NREL5MW_FBNREL_SLOW2DOF_Ex5.mdl')

%% PostProcessing SLOW
figure

% plot rotor speed
subplot(211)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega.Data*60/2/pi)
ylabel('$\Omega$ [rpm]','Interpreter','latex')

% plot tower top velocity
subplot(212)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.x_T_dot.Data)
ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
xlabel('time [s]')

%% SLOW - FAST Comparison
OutputFile  = 'FAST/TowerDamperTest.out';
OutputFile_noTD = 'FAST/TowerDamperTest_noTD.out';

% FAST
% TD Controller
fid         = fopen(OutputFile);
formatSpec  = repmat('%f',1,10);
FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
Time        = FASTResults{:,1};
RotSpeed    = FASTResults{:,4};
TT_disp     = FASTResults{:,5};
h           = Time(2)-Time(1);
TT_speed    = diff(TT_disp)/h;
fclose(fid);

figure

% plot rotor speed
subplot(311)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega.Data*60/2/pi, Time, RotSpeed)
ylabel('$\Omega$ [rpm]','Interpreter','latex')
legend('SLOW', 'FAST')

% plot tower top displacement
subplot(312)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.x_T.Data, Time(1:end), TT_disp)
ylabel('$\ x_T$ [m]','Interpreter','latex')
xlabel('time [s]')
legend('SLOW', 'FAST')

% plot tower top speed
subplot(313)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.x_T_dot.Data, Time(1:end-1), TT_speed)
ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
xlabel('time [s]')
legend('SLOW', 'FAST')

% FAST
% TD No Control
fid         = fopen(OutputFile_noTD);
formatSpec  = repmat('%f',1,10);
FASTResults2 = textscan(fid,formatSpec,'HeaderLines',8);
Time2        = FASTResults2{:,1};
RotSpeed2    = FASTResults2{:,4};
TT_disp2     = FASTResults2{:,5};
h2           = Time2(2)-Time2(1);
TT_speed2    = diff(TT_disp2)/h2;
fclose(fid);

% plot rotor speed
figure

subplot(311)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega.Data*60/2/pi, Time2, RotSpeed2)
ylabel('$\Omega$ [rpm]','Interpreter','latex')
legend('SLOW', 'FAST')

% plot tower top displacement
subplot(312)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.x_T.Data, Time2(1:end), TT_disp2)
ylabel('$\ x_T$ [m]','Interpreter','latex')
xlabel('time [s]')
legend('SLOW', 'FAST')

% plot tower top speed
subplot(313)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.x_T_dot.Data, Time2(1:end-1), TT_speed2)
ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
xlabel('time [s]')
legend('SLOW', 'FAST')