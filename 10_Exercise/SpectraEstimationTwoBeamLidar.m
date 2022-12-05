% -----------------------------
% Script: Estimates the spectra of a two Beam Lidar
% Exercise 10 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
% - adjust script and config
% ------------
% History:
% v04:	David Schlipf on 06-Dec-2021: add coherence stuff again
% v03:	David Schlipf on 28-Jul-2021: remove coherence stuff
% v02:	David Schlipf on 11-Jan-2021
% v01:	David Schlipf on 01-Dec-2019
% ----------------------------------
%% 1. Initialization 
clear all;close all;clc;

%% 2. Load and extract data
load('TwoBeamLidarData','LidarData')
URef     	= 20; % [m/s]

% Beam Index
Idx1        = LidarData.IdxPointInTrajectory==1; % Idx 1st focus point
Idx2        = LidarData.IdxPointInTrajectory==2; % Idx 2nd focus point

% time
t           = LidarData.time.relSec(Idx1); % time (equal for both points)

% line-of-sight
v_los_1     = LidarData.v_los(Idx1);
v_los_2     = LidarData.v_los(Idx2);

% coordinates
x_1         = LidarData.x_L(1);
x_2         = LidarData.x_L(2);
y_1         = LidarData.y_L(1);
y_2         = LidarData.y_L(2);
z_1         = LidarData.z_L(1);
z_2         = LidarData.z_L(2);

% ranges
f_1         = LidarData.f(1);
f_2         = LidarData.f(2);

% laser vector
x_n_1       = x_1/f_1;
x_n_2       = x_2/f_2;
y_n_1       = y_1/f_1;
y_n_2       = y_2/f_2;
z_n_1       = z_1/f_1;
z_n_2       = z_2/f_2;

%% 3. Reconstruction
% estimation of u component
u_1_est     = v_los_1; 
u_2_est     = v_los_2; 

% estimation of rotor-effective wind speed
v_0L        = ((u_1_est/x_n_1) + (u_2_est/x_n_2))/2; 

%% 4. Estimation of Spectrum from Data
signal               	= detrend(v_0L,'constant');
nBlocks                 = 32;
nOverlap                = [];   % default: nDataPerBlock/2;
nFFT                    = [];   % default: 2^nextpow2(nDataPerBlock);
SamplingFrequency       = 1/0.25;
nDataPerBlock           = floor(size(signal,1)/nBlocks/2)*2; % should be even
vWindow                 = hamming(nDataPerBlock);

[S_LL_est,f]            = pwelch(signal,vWindow,nOverlap,nFFT,SamplingFrequency); 

%% 5. Definition of the Kaimal spectrum 
% from [IEC 61400-1 third edition 2005-08 Wind turbines - Part 1: Design requirements 2005]
L_1         = 8.1   *42;
L_2         = 2.7   *42;
L_3         = 0.66  *42;
sigma_1     = 0.16*(0.75*URef+5.6);
sigma_2     = sigma_1*0.8;
sigma_3     = sigma_1*0.5;

% Spectra
S_uu        = (4*L_1/URef./((1+6*f*L_1/URef).^(5/3))*sigma_1^2);
S_vv        = (4*L_2/URef./((1+6*f*L_2/URef).^(5/3))*sigma_2^2);
S_ww        = (4*L_3/URef./((1+6*f*L_3/URef).^(5/3))*sigma_3^2);

% Coherence
Distance    = sqrt((y_1-y_2)^2+(z_1-z_2)^2); % distance in y-z plane
kappa       = 12*((f/URef).^2+(0.12/L_1).^2).^0.5;
gamma_uu    = exp(-kappa.*Distance); % coherence between point 1 and 2 in u

%% 6. Analytic spectrum of rotor effective wind speed estimate
S_LL        =  (x_n_1^2*S_uu+y_n_1^2*S_vv+z_n_1^2*S_ww) + (x_n_2^2*S_uu+y_n_2^2*S_vv+z_n_2^2*S_ww);%0.25.*(S_uu.*(2+ 2.*gamma_uu)) + (S_vv((y_n_2.^2/x_n_2.^2)+(y_n_1.^2/x_n_1.^2)));  % needs correction !!! Currently, this is the analytic spectrum of v_los_1

%% 7. Analytic spectrum of rotor effective wind speed
R                   = 63;
[Y,Z]               = meshgrid(-64:4:64,-64:4:64);
DistanceToHub       = (Y(:).^2+Z(:).^2).^0.5;
nPoint              = length(DistanceToHub);
IsInRotorDisc       = DistanceToHub<=R;
nPointInRotorDisc   = sum(IsInRotorDisc);

S_RR                =(S_uu/1).*gamma_uu;         % needs correction !!!

%% 8. Analytic cross-spectrum 
% cross-spectra rotor-effective wind speed and its lidar estimate
S_RL                = (S_uu/1);         % needs correction !!!

%% 9. Coherence
gamma_Sq_RL         = gamma_uu;     % needs correction !!!
k                   = (2*pi*f)/v_0L;            % needs correction !!!
MCB                 = NaN;          % needs correction !!!
SDES                = NaN;          % needs correction !!!

%% 10. Plots
% time
figure('Name','Time')
hold all; grid on; box on
plot(t,v_los_1,'.-')
plot(t,v_los_2,'.-')
plot(t,v_0L,'.-')
xlim([0 30])
xlabel('time [s]')
ylabel('wind speeds [m/s]')
legend('v_{los,1}','v_{los,2}','v_{0L}')

% frequency
figure('Name','Spectra')
hold all; grid on; box on
plot(f,S_LL_est)
plot(f,S_LL)
plot(f,S_uu)
plot(f,S_RR)
set(gca,'xScale','log')
set(gca,'yScale','log')
xlim([1e-3 1e0])
xlabel('frequency [Hz]')
ylabel('spectra [(m/s)^2/Hz]')
legend('S_{LL,est}','S_{LL}','S_{uu}','S_{RR}')

% coherence
figure('Name','Coherence')
hold all; grid on; box on
plot(k,gamma_Sq_RL)
plot([1e-3 1e0],[0.5 0.5])
plot(MCB,0.5,'o')
xlim([1e-3 1e0])
set(gca,'xScale','log')
xlabel('wave number [rad/m]')
ylabel('coherence [-]')
