function [Parameter] = IEA15MWDefaultParameter_FBSWE(Parameter)

%% Pitch Controller
Parameter.CPC.Omega_g_rated             = rpm2radPs(7.56);                  % [rad/s]
Parameter.CPC.theta_max                 = deg2rad(90);                      % [rad]
Parameter.CPC.theta_min                 = deg2rad(0);                       % [rad]

%% Torque Controller
P_el_rated                              = 15e6;                              % [W]

lambda_s                                = 2:0.001:14.5;
c_P_s                                   = spline(Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P(:,6),lambda_s);
[c_P_opt,maxIdx]                        = max(c_P_s);
lambda_opt                              = lambda_s(maxIdx);
k                                       = 0.5*Parameter.General.rho*pi*Parameter.Turbine.R^5*(c_P_opt/(lambda_opt^3))*Parameter.Turbine.i^3;

Parameter.VSC.k                         = k;   % [Nm/(rad/s)^2]
Parameter.VSC.Mode                      = 2;   % 1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3
Parameter.VSC.M_g_rated                 = P_el_rated/Parameter.Generator.eta_el/Parameter.CPC.Omega_g_rated;  % [Nm]
Parameter.VSC.P_a_rated                 = P_el_rated/Parameter.Generator.eta_el;  % [W]

Parameter.VSC.Omega_g_1d5               = rpm2radPs(5)/Parameter.Turbine.i; % [rad/s];  
Parameter.VSC.M_g_max                   = Parameter.VSC.M_g_rated*1.1;      % [Nm] 

end