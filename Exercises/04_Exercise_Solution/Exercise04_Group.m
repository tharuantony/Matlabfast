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
[FASTResults, OutList, ~, ~, ~]    = ReadFASTbinary(OutputFile);
Time        = FASTResults(:,strcmp(OutList,'Time'));
RotSpeed    = FASTResults(:,strcmp(OutList,'RotSpeed'));

%% PostProcessing
figure
hold on;box on;grid on;
plot(Time,RotSpeed)
ylabel('\Omega [rpm]')
xlim([20 60])

% compare it to step
D_d         = 0.7;
omega_d     = 0.5;
G0          = [ 11.6488  ];
 
% get closed-loop tf
CL = tf([G0*omega_d^2 0],[1 2*D_d*omega_d omega_d^2]);

% step 
[y,t] = step(CL,Time-30);

% plot
plot(t+30,y*60/2/pi/97*0.1+12.1)
   
legend('FAST','Design')

%% FFT calculation to define peak frequencies
% figure
% T = 0.0125;
% Fs = 1/T;
% L = length(Time);
% FFT = fft(RotSpeed);
% P2 = abs(FFT/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs*(0:(L/2))/L;
% hold on;box on;grid on;
% plot(f(1:300),P1(1:300)) 
% title('Single-Sided Amplitude Spectrum of Rotor Speed signal')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
% ylim([0 0.65])
% x1 = 1.666;
% y1 = 0.6384;
% x2 = 3.316;
% y2 = 0.0334;
% hold on;box on;grid on;
% plot(x1,y1,'r.', x2,y2,'r.')

