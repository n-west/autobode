function response = sendScopeMsg(scopeIP, query, value)
% response = SENDSCOPEMSG(scopeIP, queryType, value)
%   INPUT
%       scopeIP - a string with the scope's IP address
%       queryType - a query type. Most of them are 'COMMAND'.
%       value - a string with the command to send. example: ':AUTOSet EXECute'
%   OUTPUT
%       response - if there is a response, this is a string with the
%       response, otherwise it is empty.
%
% Author: Nathan West
% March 2011
% Credit to Steven Bell for some assistance
%
% SEE ALSO:
%   bodePlotter, readMeasurement, setupMeasurement

% SOURCES:
% commands are taken from:
%   Tektronix TDS 3000 and TDS3000B Series Programmer Manual
% Protocol is using built-in webserver and Steven used wireshark to figure
% out how to send the commands

% Sends the scope a message
% The try is used because some commands don't return a response
% and will throw an error and break execution otherwise.
    response = [];
    try response = urlread(['http://', scopeIP], 'get', {query, value});
    end
end % function end

% EOF