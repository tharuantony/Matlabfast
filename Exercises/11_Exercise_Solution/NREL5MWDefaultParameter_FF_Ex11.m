% -----------------------------
% Function: provides parameter for collective pitch feedforward controller
% ------------
% Input:
% none
% ------------
% Output:
% - Parameter   struct of Parameters
% ------------
% History: 
% v01:	David Schlipf on 09-Dec-2019
% ----------------------------------
function [Parameter] = NREL5MWDefaultParameter_FF_Ex11(Parameter)

Parameter.CPC.FF                        = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','theta'); 
Parameter.CPC.FF.Mode                	= 0;    % [0/1]     % 0: FF disabled, 1: FF enabled
Parameter.CPC.FF.T_buffer               = 1;    % [s]
Parameter.Filter.LowPass3.Enable       	= 0;    % [0/1]
Parameter.Filter.LowPass3.f_cutoff     	= 1;   	% [Hz]                


end