% -----------------------------
% Script: Test Pitch Controller with notch filter
% Exercise 04 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
% - Adjust FBNREL_Ex04_discon.in to filter out the drive train vibration
% ------------
% History:
% v01:	David Schlipf on 23-Nov-2020
% ----------------------------------

clearvars;close all;clc;

%% Processing FAST
OutputFile  = 'FAST/PitchControllerTest.outb';
if ~exist(OutputFile,'file') % only run FAST if out file does not exist
    cd FAST
    dos('FAST_Win32.exe PitchControllerTest.fst');
    cd ..
end

%% PostProcessing FAST
addpath('FAST/Results')
RotSpeed = zeros(1,23);
BldPitch = zeros(1,23);
GenTq    = zeros(1,23);
TTDspFA  = zeros(1,23);
jj       = 1;
vFAST    = 3:1:25;
for iv_0=3:25
    OutputFile = 'PitchControllerTest_' + string(iv_0) + '.outb';
    [FASTResults, OutList, ~, ~, ~]    = ReadFASTbinary(OutputFile);
    Time        = FASTResults(:,strcmp(OutList,'Time'));
    RtSpd       = FASTResults(:,strcmp(OutList,'RotSpeed'));
    BldPit      = FASTResults(:,strcmp(OutList,'BldPitch1'));
    GnTq        = FASTResults(:,strcmp(OutList,'GenTq'));
    xT          = FASTResults(:,strcmp(OutList,'TTDspFA'));
    
    RotSpeed(jj) = mean(RtSpd(4600:4801));
    BldPitch(jj) = mean(BldPit(4600:4801));
    GenTq(jj)    = mean(GnTq(4600:4801));
    TTDspFA(jj)    = mean(xT(4600:4801));
    
    jj = jj + 1;
end

%% Comparison SLOW-FAST
load('SteadyStatesNREL5MW_NREL_SLOW.mat')
figure()
subplot(4,1,1)
plot(vFAST, RotSpeed, v_0, radPs2rpm(Omega))
legend('FAST', 'SLOW')
xlabel('Wind speed [m/s]')
ylabel('Rotor speed [rpm]')

subplot(4,1,2)
plot(vFAST, GenTq*1000, v_0, M_g)
legend('FAST', 'SLOW')
xlabel('Wind speed [m/s]')
ylabel('Generator torque [Nm]')

subplot(4,1,3)
plot(vFAST, BldPitch, v_0, rad2deg(theta))
legend('FAST', 'SLOW')
xlabel('Wind speed [m/s]')
ylabel('Blade pitch angle [deg]')

subplot(4,1,4)
plot(vFAST, TTDspFA, v_0, x_T)
legend('FAST', 'SLOW')
xlabel('Wind speed [m/s]')
ylabel('Tower top displacement [m]')
