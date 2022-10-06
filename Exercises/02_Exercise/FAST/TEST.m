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
fclose(fid);