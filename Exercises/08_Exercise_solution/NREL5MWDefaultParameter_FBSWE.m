function [Parameter] = NREL5MWDefaultParameter_FBSWE(Parameter)

%% Pitch Controller

% calculated for D_d = [0.700000 ]
% and omega_0_d = [0.500000 ]
% at v_0   = [12.000000 16.000000 20.000000 24.000000 ] 
theta      = [0.066475 0.210387 0.304969 0.389926 ];
kp         = [0.021909 0.006679 0.003383 0.002464 ];
Ti         = [2.895831 2.433870 1.814097 1.436113 ];
% ---
Parameter.CPC.GS.theta                  = theta;                            % [rad]
Parameter.CPC.GS.kp                     = kp;                               % [s]
Parameter.CPC.GS.Ti                     = Ti;                               % [s] 

Parameter.CPC.Omega_g_rated             = rpm2radPs(12.1*97);               % [rad/s]
Parameter.CPC.theta_max                 = deg2rad(90);                      % [rad]
Parameter.CPC.theta_min                 = deg2rad(0);                       % [rad]

%% Torque Controller
P_el_rated                              = 5e6;                              % [W]

Parameter.VSC.k                         = 2.3689;                           % [Nm/(rad/s)^2]
Parameter.VSC.Mode                      = 1;                                % 1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 
Parameter.VSC.M_g_rated                 = P_el_rated/Parameter.Generator.eta_el/Parameter.CPC.Omega_g_rated;  % [Nm] 
Parameter.VSC.P_a_rated                 = P_el_rated/Parameter.Generator.eta_el;  % [W]


Parameter.VSC.Omega_g_1d5               = rpm2radPs(8)/Parameter.Turbine.i; % [rad/s];  
Parameter.VSC.kp                        = 2974.123913;
Parameter.VSC.Ti                        = 2.556479; 

Parameter.VSC.M_g_max                   = Parameter.VSC.M_g_rated*1.1;      % [Nm] 

%% Set-Point-Fading
Parameter.VSC.Delta_Omega_g             = 0.10*Parameter.CPC.Omega_g_rated; % [rad/s]   % over-/under-speed limit for setpoint-fading, first guess
Parameter.VSC.Delta_theta               = deg2rad(25);                      % [rad]     % change of pitch angle at which under-speed limit should be reached, brute-force-optimized
Parameter.VSC.Delta_P                   = 5e6;                          	% [W]       % change of power at which over-speed limit should be reached, first guess
Parameter.Filter.LowPass2.f_cutoff     	= 0.1;                              % [Hz]      % cut-off-frequency for low pass filter for setpoint-fading, first guess


%% Filter Generator Speed
Parameter.Filter.LowPass.Enable         = 1;
Parameter.Filter.LowPass.f_cutoff       = 2;                                % [Hz]

Parameter.Filter.NotchFilter.Enable   	= 1;
Parameter.Filter.NotchFilter.f        	= 1.66;                             % [Hz]
Parameter.Filter.NotchFilter.BW      	= 0.40;                             % [Hz]
Parameter.Filter.NotchFilter.D       	= 0.01;                             % [-]  
   
end