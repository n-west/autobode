function [success] = setupMeasurement(scopeIP, measNum, measurementType, measSrc, varargin)
% success = setupMeasurement(scopeIP, measNum, measurementType, measSrc...[, measDst]);
%
% Author: Nathan West
% March 2011
%
% SEE ALSO:
%   bodePlotter, readMeasurement, grabScopeData, sendScopeMsg

% SOURCES:
% commands are taken from:
%   Tektronix TDS 3000 and TDS3000B Series Programmer Manual

% set measurement type
setMeasCommand = sprintf(':MEASUrement:MEAS%d:TYPe %s',measNum,measurementType);
sendScopeMsg(scopeIP,'COMMAND', setMeasCommand);
    
% set measurement source
measSrcCommand = sprintf(':MEASUrement:MEAS%d:SOURCE1 %s',measNum, measSrc);
sendScopeMsg(scopeIP,'COMMAND', measSrcCommand);

if( nargin == 5 ) % There is a destination addr
    measDstCommand = sprintf(':MEASUrement:MEAS%d:SOURCE2 %s', measNum, varargin{1});
    sendScopeMsg(scopeIP,'COMMAND', measDstCommand);
end

% turn measurement on
onCommand = sprintf(':MEASUrement:MEAS%d:STATE ON',measNum);
sendScopeMsg(scopeIP,'COMMAND',onCommand);

% TODO: verify measurement settings with MEAS<x>?
% until then...
    success = 1;
    
end % function end

% EOF
