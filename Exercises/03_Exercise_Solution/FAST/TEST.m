%% Processing FAST
OutputFile  = 'PitchControllerTest.outb';
if ~exist(OutputFile,'file')                % only run FAST if out file does not exist
    dos('FAST_Win32.exe PitchControllerTest.fst');
end