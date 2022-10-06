% -----------------------------
% Script: Compares a wind step simulation of the SLOW model to a FAST simulation
% Exercise 01 of Course "Controller Design of Wind Turbines and Wind Farms"
% ------------
% Task:
% ------------
% History: 
% v2: David Schlipf on 19-Sep-2022: remove tower motion
% v1: David Schlipf on 01-Nov-2020
% ----------------------------------

clearvars;close all;clc;

%% Preprocessing SLOW
% Define parameter (turbine and controller)
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;  

% internal parameters to make code easier to read 
eta_el                          = Parameter.Generator.eta_el;
i_GB                            = Parameter.Turbine.i_GB;

% manual control 
theta                           = deg2rad(12.06);                           % constant pitch for 16 m/s TODO!!!
P_el_rated                      = 5000000; % [W]
Omega_g_rated                   = 1.26/i_GB;
M_g                             = P_el_rated/Omega_g_rated;                 % constant torque for 16 m/s TODO!!!

% Aerodynamics
Parameter.AD                    = load('PowerAndThrustCoefficientsNREL5MW','c_P','c_T','lambda','theta'); % Actuator Disc Parameter Region 2

% Define simulation details (same as FAST)
dt          = 0.0125;           % time step                 [s]
TMax        = 60;           	% maximum time              [s]
t           = 0:dt:TMax;        % time vector
n           = length(t);        % number of simulation steps

% Define disturbance (wind signal)
v_0         = interp1([0,60],[16 16],t);          % rotor effective wind speed at every simulation step

%% Processing SLOW
% initial values (from FAST simulation)
x           = NaN(1,1);         % allocation of state vector
x(1,1)      = 12.1/60*2*pi;     % rotor speed               [rad/s]

% simulation using Euler forward
tic
for k = 1:1:n-1
    x_dot_k = SLOW_OpenLoop(x(k,:),M_g,theta,v_0(k),Parameter);
    x(k+1,:)= x(k,:)+x_dot_k*dt;
end
TimeRatio   = TMax/toc;

%% PostProcessing SLOW
Omega       = x(:,1);                       % rotor speed is 1st state
P_el        = Omega*i_GB*M_g*eta_el;        % electrical power 

%% Processing FAST
OutputFile  = 'ConstantWind_16.out';
if ~exist(OutputFile,'file')                % only run FAST if out file does not exist
    dos('FAST_Win32.exe ConstantWind_16.fst');
end

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

% plot wind
subplot(311)
hold on;box on;grid on;
plot(Time,Wind1VelX)
plot(t,v_0)
ylabel('wind speed [m/s]')

% plot rotor speed
subplot(312)
hold on;box on;grid on;
plot(Time,RotSpeed)
plot(t,Omega/2/pi*60) % rad/s to rpm
ylabel('rotor speed [rpm]')
legend({'FAST','SLOW'},'location','best')

% plot Power
subplot(313)
hold on;box on;grid on;
plot(t,GenPwr/1e3)
plot(t,P_el/1e6) 
ylabel('Power [MW]')
xlabel('time [s]')

