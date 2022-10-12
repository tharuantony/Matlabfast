function [A,B,C,D] = LinearizeSLOW1DOF_PC(theta_OP,Omega_OP,v_0_OP,Parameter)
% (c) Universitaet Stuttgart and sowento GmbH

% internal variables
J               = Parameter.Turbine.J;
R               = Parameter.Turbine.R;
i               = Parameter.Turbine.i;
rho             = Parameter.General.rho;
P_a             = Parameter.VSC.P_a_rated;

% gradients
dtheta          = diff(Parameter.Turbine.SS.theta(1:2));
dlambda         = diff(Parameter.Turbine.SS.lambda(1:2));
lambda_OP       = Omega_OP*R/v_0_OP;

% power coefficient
cP_Tmin1        = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP-dtheta,     lambda_OP, 'linear', 0.0); %Zero outside domain for zero pitch
cP_Tplus1       = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP+dtheta,     lambda_OP);
cP_Lmin1        = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP,            lambda_OP-dlambda);
cP_Lplus1       = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP,            lambda_OP+dlambda);
cP_0            = interp2(Parameter.Turbine.SS.theta, Parameter.Turbine.SS.lambda, Parameter.Turbine.SS.c_P, theta_OP,            lambda_OP);
dcP_dtheta      = (cP_Tplus1 - cP_Tmin1)/(2*dtheta);
dcP_dlambda     = (cP_Lplus1 - cP_Lmin1)/(2*dlambda);

% helpers       
f               = 1/2*rho*pi*R^2;
dlambda_dv0     = -1/v_0_OP^2*Omega_OP*R;
dlambda_dOmega  = R/v_0_OP;
dcP_dv0         = dcP_dlambda*dlambda_dv0;
dcP_dOmega      = dcP_dlambda*dlambda_dOmega;

% derivatives of Ma = f*v0^3*cP(v0,theta,Omega)/Omega
dMa_dtheta      = f*v_0_OP^3/Omega_OP*dcP_dtheta;
dMa_dv0         = f*v_0_OP^3/Omega_OP*dcP_dv0    + f*cP_0/Omega_OP*3*v_0_OP^2;
dMa_dOmega      = f*v_0_OP^3/Omega_OP*dcP_dOmega + f*v_0_OP^3*cP_0*(-1/Omega_OP^2);

% torque control
dMg_dOmega      = -P_a*i/(Omega_OP)^2;

% x_1 = Omega
% u_1 = theta
% u_2 = v_0
% y_1 = Omega_g

b11             = dMa_dtheta/J;
b12             = dMa_dv0/J;
a11             = (dMa_dOmega-dMg_dOmega/i)/J;
c11             = 1/i;

% Outputs
A               = a11;
B               = [b11,b12];
C               = c11; 
D               = [0 0];

end

