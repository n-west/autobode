function [time, varargout] = grabScopeData(scopeIP, waveformsToCapture, varargin)
% GRABSCOPEDATA grab data from an oscilloscope connected to campus network.
%   [time, <chx>, ... ] = ...
%           grabScopeData('scopeIP', {<chx>}, 'Property', 'PropertyValue' ... ) 
%   connects to the oscilloscope at the ip Address scopeIP and reads the
%   given waveforms.
%
%   INPUTS
%       scopeIP - a string with the network address of the scope
%           ('10.66.0.122' is an example of one in the Electronics lab)
%       waveformsToCapture - a cell array of waveforms. Possible values:
%               'CH1', 'CH2', 'MATH', 'REF1', 'REF2', 'REF3', 'REF4' (for
%               our scopes at least)
%       Property/PropertyValue - some settings that might affect output.
%               Property        -   Acceptable Values
%               'Resolution'    - 'LOW' (500 pts) or 'HIGH' (10,000 pts)
%experimental ->    'DataEncoding'  - 'ASCIi', 'RIBinary', 'RPBinary', 'SRIbinary', 'SRPbinary'
%               'DataWidth'     - 1, 2 (determines number of bytes in data)
%               'DataStart'     - integer (determines start point for data)
%               'DataStop'      - integer (determines stop point for data)
%
%   OUTPUTS
%       time - a vector with the correct time scale of the scope (starts at 0)
%       chx - a vector with the data from the given waveform. There is a
%           vector for each waveform in waveformsToCapture.
%
% Author: Nathan West
% March 2011
% Credit to Steven Bell for some assistance
%
% SEE ALSO:
%   bodePlotter, readMeasurement, setupMeasurement, sendScopeMsg

% SOURCES:
% commands are taken from:
%   Tektronix TDS 3000 and TDS3000B Series Programmer Manual
% Protocol is using built-in webserver and Steven used wireshark to figure
% out how to send the commands

numDivisions = 10; % 10 horizontal divisions on our scope
width = 2; % default value
% Get input arguments
for i = 1:2:nargin-2
    if( strcmpi(varargin{i}, 'Resolution') )
        resolution = varargin{i+1};
        sendScopeMsg(scopeIP, 'COMMAND', [':HORizontal:RESOlution ', resolution]);
    elseif( strcmpi(varargin{i}, 'DataEncoding') )
        encoding = varargin{i+1};
        sendScopeMsg(scopeIP, 'COMMAND', [':DATa:ENCdg ', encoding]);
    elseif( strcmpi(varargin{i}, 'DataWidth') )
        width = str2double(varargin{i+1});
        sendScopeMsg(scopeIP, 'COMMAND', [':DATa:WIDth ', sprintf('%d',width)]);
    elseif( strcmpi(varargin{i}, 'DataStart') )
        dataStart = varargin{i+1};
        sendScopeMsg(scopeIP, 'COMMAND', ['DATa:STARt ', dataStart]);
    elseif( strcmpi(varargin{i}, 'DataStop') )
        dataStop = varargin{i+1};
        sendScopeMsg(scopeIP, 'COMMAND', ['DATa:STOP ', dataStop]);
    end
end

% Create a time vector based on scope settings
recordLength = str2double(sendScopeMsg(scopeIP, 'COMMAND', 'HORizontal:RECORDLength?'));
horzScale = sendScopeMsg(scopeIP, 'COMMAND', 'HORizontal:MAIn:SCAle?');
time = linspace(0, numDivisions*str2double(horzScale), recordLength);

% pre-allocate output waveform matrix (MATLAB says to do this for speed)
numOfWaveforms = size(waveformsToCapture);

% Grab waveform data
for chan = 1:numOfWaveforms(2)
    sendScopeMsg(scopeIP, 'COMMAND', [':SELect:', waveformsToCapture{chan}, ' ON']);
    sendScopeMsg(scopeIP, 'COMMAND', [':DATa:SOUrce ', waveformsToCapture{chan}]);
    scale = str2double(sendScopeMsg(scopeIP, 'COMMAND', [':',waveformsToCapture{chan}, ':SCAle?']));
    gain = str2double(sendScopeMsg(scopeIP, 'COMMAND', [':',waveformsToCapture{chan}, ':PRObe?']));
    offset = sendScopeMsg(scopeIP, 'COMMAND', [':',waveformsToCapture{chan}, ':POSition?']);
    sendScopeMsg(scopeIP, 'COMMAND', [':',waveformsToCapture{chan}, ':POSition 0']);
    chanRawData = sendScopeMsg(scopeIP, 'COMMAND', 'CURVe?');
    sendScopeMsg(scopeIP, 'COMMAND', [':',waveformsToCapture{chan}, ':POSition ', offset]);
    try 
        chanMatrix = cell2mat(textscan(chanRawData, '%f', 'delimiter', ','));
        % Adjust channel data by voltage scale and normalize to ADC
        chanVoltage = gain*scale*chanMatrix/((2^(8*width))-1); 
        varargout{chan} = chanVoltage';
    catch exception
        fprintf('There was an error grabbing data from the scope on %s -- skipping.\n', waveformsToCapture{chan});
    end
end

end % function end

function response = sendScopeMsg(scopeIP, query, value)
% Sends the scope a message
% The try is used because some commands don't return a response
% and will throw an error and break execution otherwise.
    response = [];
    try response = urlread(['http://', scopeIP], 'get', {query, value});
    end
end % function end

% EOF

    