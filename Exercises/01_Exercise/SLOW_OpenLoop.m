% -----------------------------
% Function: Provides the derivatives of the SLOW ODEs (Open Loop)
% ------------
% Input:
% - x           vector of states 
% - v_0         scalar of rotor-effective wind speed
% - Parameter   struct of Parameters
% ------------
% Output:
% - x_dot       vector of derivatives 
% ------------
% History: 
% v1: David Schlipf on 19-Sep-2022: remove tower motion
% ----------------------------------
function [x_dot] = SLOW_OpenLoop(x,M_g,theta,v_0,Parameter)

% internal parameters to make code easier to read
J           = Parameter.Turbine.J;
i_GB        = Parameter.Turbine.i_GB;

% renaming states
Omega       = x(1);

% Aerodynamics
M_a         = Aerodynamics_AD_1DOF(Omega,theta,v_0,Parameter);

% derivatives from Equation (3.3) in [4]
Omega_dot   = (M_a-M_g/i_GB)/J;

% renaming output
x_dot(1)    = Omega_dot;

end

