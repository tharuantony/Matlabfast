%% Processing FAST
OutputFile  = 'TowerDamperTest.out';
if ~exist(OutputFile,'file')                % only run FAST if out file does not exist
    dos('FAST_Win32.exe TowerDamperTest.fst');
end