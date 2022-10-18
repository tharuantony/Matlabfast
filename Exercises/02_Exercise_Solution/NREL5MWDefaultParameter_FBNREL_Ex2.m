% -----------------------------
% Function: should add parameters for NREL5MW Baseline Torque Controller
% Exercise 02 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Input:
% - Parameter   struct of Parameters
% ------------
% Output:
% - Parameter   struct of Parameters
% ------------
% History: 
% v02:	David Schlipf on 26-Jul-2021: small update
% v01:	David Schlipf on 29-Sep-2019
% ----------------------------------
function Parameter = NREL5MWDefaultParameter_FBNREL_Ex2(Parameter)

%% FBNREL Torque Controller
Omega_g_rated                           = rpm2radPs(12.1*97); 
eta_el                                  = 0.944;       % [rad/s]
P_el_rated                              = 5e6;                              % [W]
lambda_opt                              = 7.55;                              % [-]
theta_opt                               = 0; 
theta                                   = Parameter.Turbine.SS.theta;
lambda                                  = Parameter.Turbine.SS.lambda;% [deg]
c_P                                     = Parameter.Turbine.SS.c_P;
c_P_opt                                 = interp2(theta,lambda,c_P,theta_opt,lambda_opt);
rho                                     = Parameter.General.rho;
R                                       = Parameter.Turbine.R;
i                                       = Parameter.Turbine.i;
Parameter.VSC.k                         = 0.5* rho*pi*R^5*c_P_opt/lambda_opt^3*i^3;                              % [Nm/(rad/s)^2]
Parameter.VSC.theta_fine                = deg2rad(theta_opt);                       % [rad]      
Parameter.VSC.Mode                      = 1;                                % 1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 
Parameter.VSC.P_a_rated                 = P_el_rated/Parameter.Generator.eta_el;  % [W] aerodynamic power
Parameter.VSC.M_g_rated                 = Parameter.VSC.P_a_rated/Omega_g_rated;   % [Nm] 
c_P_optmax                              = max(c_P(:,1)); 
lambda_optmax                           = lambda(100);
c_P_opt1 =c_P_opt * 0.99;
lambda_opt1 = 6.9554611;
k_1 = 0.5* rho*pi*R^5*c_P_opt1/lambda_opt1^3*i^3;

% region limits & region parameters based on Jonkman 2009
Parameter.VSC.Omega_g_1To1_5            = rpm2radPs(670);                   % [rad/s]
Parameter.VSC.Omega_g_1_5To2            = rpm2radPs(871);                   % [rad/s]
Parameter.VSC.Omega_g_2To2_5            = rpm2radPs(1150.9);              	% [rad/s]
Parameter.VSC.Omega_g_2_5To3            = Omega_g_rated;                    % [rad/s]

% Region 1_5: M_g = a * Omega_g + b: 
% 1.Eq: 0                   = a * Omega_g_1To1_5 + b 
% 2.Eq: k*Omega_g_1_5To2^2  = a * Omega_g_1_5To2 + b
Parameter.VSC.a_1_5                     = Parameter.VSC.k*Parameter.VSC.Omega_g_1_5To2^2/(Parameter.VSC.Omega_g_1_5To2-Parameter.VSC.Omega_g_1To1_5);
Parameter.VSC.b_1_5                     = -Parameter.VSC.a_1_5*Parameter.VSC.Omega_g_1To1_5;

a_1_5                     = k_1*Parameter.VSC.Omega_g_1_5To2^2/(Parameter.VSC.Omega_g_1_5To2-Parameter.VSC.Omega_g_1To1_5);
b_1_5                     = -a_1_5*Parameter.VSC.Omega_g_1To1_5;
a_2_5                     = (Parameter.VSC.M_g_rated-Parameter.VSC.k*Parameter.VSC.Omega_g_2To2_5^2)/(Parameter.VSC.Omega_g_2_5To3-Parameter.VSC.Omega_g_2To2_5);
b_2_5                     = Parameter.VSC.M_g_rated-a_2_5*Parameter.VSC.Omega_g_2_5To3;
 

% Region 2_5: M_g = a * Omega_g + b: 
% 1.Eq: M_g_rated           = a * Omega_g_2_5To3       + b 
% 2.Eq: k*Omega_g_2To2_5^2  = a * Omega_g_2To2_5    + b
Parameter.VSC.a_2_5                     = (Parameter.VSC.M_g_rated-Parameter.VSC.k*Parameter.VSC.Omega_g_2To2_5^2)/(Parameter.VSC.Omega_g_2_5To3-Parameter.VSC.Omega_g_2To2_5);
Parameter.VSC.b_2_5                     = Parameter.VSC.M_g_rated-Parameter.VSC.a_2_5*Parameter.VSC.Omega_g_2_5To3;


end