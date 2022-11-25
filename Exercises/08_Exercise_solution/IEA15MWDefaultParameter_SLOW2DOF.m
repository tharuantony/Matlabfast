% -----------------------------
% Function: provides parameter for IEA15MW SLOW wind turbine model
% ------------
% Input:
% none
% ------------
% Output:
% - Parameter   struct of Parameters
% ------------
% History: 
% v01:	David Schlipf on 20-Oct-2019
% ----------------------------------
function [Parameter] = IEA15MWDefaultParameter_SLOW2DOF

%% General          
Parameter.General.rho               = 1.225;         	% [kg/m^3]  air density
%--------------------------------------------------------------------------
%% Turbine
Parameter.Turbine.SS             	= load('PowerAndThrustCoefficientsIEA15MW','c_P','c_T','theta','lambda');
Parameter.Turbine.SS.theta          = deg2rad(Parameter.Turbine.SS.theta);

Parameter.Turbine.i               	= 1;                % [-]       gearbox ratio
Parameter.Turbine.R              	= 240/2;            % [m]       Rotor radius

% Generator
Parameter.Generator.eta_el      	= 0.9655;           % [-]       Generator efficiency
Parameter.Generator.M_g_dot_max     = 4500000;          % [Nm/s]    maximum torque rate

% drive-train dynamics
J_G                               	= 8008650;          % [kgm^2]	Generator Inertia About High-Speed Shaft
J_R                                	= 310619488;        % [kgm^2]	Rotor Inertia About High-Speed Shaft
Parameter.Turbine.J                	= J_R+J_G/Parameter.Turbine.i^2;

% fore-aft tower dynamics  
d_s                                 = 0.01;             % [-]       Structural Damping ratio from NRELOffshrBsline5MW_Tower_Onshore.dat
f_0TwFADOF1                         = 0.200;            % [Hz]      first tower fore-aft eigenfrequency
Parameter.Turbine.x_T0           	= -0.1660;          % [m]       tower top deflection without wind
Parameter.Turbine.m_Te            	= 1.2884e+06;                                       % [kg]      tower equivalent modal mass 
Parameter.Turbine.k_Te          	= Parameter.Turbine.m_Te*(2*pi*f_0TwFADOF1)^2;  	% [kg/s^2]  tower equivalent bending stiffness
Parameter.Turbine.c_Te            	= d_s*Parameter.Turbine.k_Te/(pi*f_0TwFADOF1);      % [kg/s]	tower equivalent structual damping
Parameter.Turbine.HubHeight       	= 150;              % [m]       hub height

end