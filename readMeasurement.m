function [measurementValue] = readMeasurement(scopeIP, measNum)
% READMEASUREMENT reads in a measurement value from an oscilloscope.
%   measurementValue = readMeasurement(scopeIP, measNum);
%   connects to the scope and reads in the measurement indicated by measNm.
%   Use setupMeasurement to set up the measurement to what you want.
%
% Author: Nathan West
% March 2011
%
% See also: setupMeasurement, bodePlotter, sendScopeMsg, grabScopeData

measCheckCommand = sprintf(':MEASUrement:MEAS%d:STATE?',measNum);
measState = sendScopeMsg(scopeIP,'COMMAND',measCheckCommand);

if( str2double(measState) ==  1 )
    % turn measurement on
    onCommand = sprintf('MEASUrement:MEAS%d:VALue?',measNum);
    measurementValue = str2double(sendScopeMsg(scopeIP,'COMMAND',onCommand));
else
    measurementValue = -1;
end

end % function end

% EOF
