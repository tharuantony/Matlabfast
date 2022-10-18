%% Processing FAST
OutputFile  = 'TorqueControllerTest.out';
if ~exist(OutputFile,'file')                % only run FAST if out file does not exist
    dos('FAST_Win32.exe TorqueControllerTest.fst');
end

%% PostProcessing FAST
fid         = fopen(OutputFile);
formatSpec  = repmat('%f',1,10);
FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
Time        = FASTResults{:,1};
Wind1VelX   = FASTResults{:,2};
RotSpeed    = FASTResults{:,4};
GenPwr      = FASTResults{:,9};
GenTrq      = FASTResults{:,10};
fclose(fid);

%% Comparison FAST - FAST_99%
fid         = fopen('TorqueControllerTest_99.out');
formatSpec  = repmat('%f',1,10);
FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
Time1        = FASTResults{:,1};
Wind1VelX1   = FASTResults{:,2};
RotSpeed1    = FASTResults{:,4};
GenPwr1      = FASTResults{:,9};
GenTrq1      = FASTResults{:,10};
fclose(fid);

figure

% plot wind
subplot(411)
hold on;box on;grid on;
plot(Time,Wind1VelX)
plot(Time,Wind1VelX1)
ylabel('wind speed [m/s]')

% plot generator torque
subplot(412)
hold on;box on;grid on;
plot(Time,GenTrq)
plot(Time,GenTrq1) % 
ylabel('Generator torque [kNm]')
legend({'FAST','FAST 1% loss'},'location','best')

% plot rotor speed
subplot(413)
hold on;box on;grid on;
plot(Time,RotSpeed)
plot(Time,RotSpeed1) % rad/s to rpm
ylabel('rotor speed [rpm]')
legend({'FAST','FAST 1% loss'},'location','best')

% plot Power
subplot(414)
hold on;box on;grid on;
plot(Time,GenPwr/10^3)
plot(Time,GenPwr1/10^3) 
ylabel('Power [MW]')
xlabel('time [s]')
legend({'FAST','FAST 1% loss'},'location','best')
