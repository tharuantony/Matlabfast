function Disturbance = GenerateRotorEffectiveWindSpeed(windfield,Parameter)
% -----------------------------
% Function: Generates a time series for rotor-effective wind speed
% Exercise 06 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% History:
% v01:	David Schlipf on 18-Nov-2019
% ----------------------------------

% Configuration
T       = Parameter.Time.TMax;
dt      = Parameter.Time.dt;
Seed    = Parameter.TurbSim.RandSeed;
URef    = Parameter.TurbSim.URef;

% frequency

f_min   = 1/T;
f_max   = dt/2;%1/dt*1/2;
df      = f_min;
f       =  [0:df:2];
n_f     = length(f);
% spectrum
S_RR    = Calculation_S_RR(f,windfield,Parameter);

% amplitudes
A       = sqrt(2*S_RR*df);

% init RNG
rng(Seed);

% phase angles
Phi     = rand(1,n_f)*2*pi;

% time
t       = 0:dt:T;
n_t     = length(t); 

% generate time series         
U       = n_f*[0,A].*exp([0,1i*Phi]);
v_0     = URef+ifft(U,n_t,'symmetric');

% Disturbance
Disturbance.v_0.time            = t';
Disturbance.v_0.signals.values  = v_0';

end

