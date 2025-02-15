function [Magnitude, Phase] = bodePlotter(scopeIP, inputChan, outputChan, Frequencies)
% BODEPLOTTER inputs sound into a filter and reads the output voltage.
% Returns phase and attenuation (in dB)
%   [mag,phase] = bodePlotter('scopeIP', 'inputChannel', 'outputChannel', f);
%   connects to the oscilloscope at the ip address given. Returns the
%   magnitude and phase response of whatever is connected to the
%   oscilloscope.
%
%   INPUTS
%       scopeIP - a string with the network address of the scope
%           ('10.66.0.122' is an example of one in the Electronics lab)
%       inputChannel - a string such as 'CH1' that represents the channel
%          the input signal is connected to on the scope.
%       outputChannel - a string such as 'CH2' that represents the channel
%           the output signal is connected to on the scope.
%       f - a vector of frequencies (in order, please) to take magnitude
%           and phase measurements at.
%
%   OUTPUTS
%       mag - a vector representing the magnitude response of whatever is
%           connected to the scope in dB. Math is 20*log10(output/input)
%       phase - a vector representing the phase response of whatever is
%           connected to the scope in degrees. Math is done on the scope.
%
% Author: Nathan West
% March 2011
%
% SEE ALSO:
%   grabScopeData, sendScopeMsg, setupMeasurement, readMeasurement

% SOURCES:
% commands are taken from:
%   Tektronix TDS 3000 and TDS3000B Series Programmer Manual

msgBox = sprintf(':MESSage:SHOW \"Preparing Bode Plotter\\nPlease Wait.\"');
sendScopeMsg(scopeIP,'COMMAND',msgBox);
sendScopeMsg(scopeIP,'COMMAND','MESSage:BOX 125,350,420,400');
sendScopeMsg(scopeIP,'COMMAND','MESSage:STATE ON');

% Make sure both channels are on and centered
sendScopeMsg(scopeIP,'COMMAND',sprintf(':SELect:%s ON', inputChan));
sendScopeMsg(scopeIP,'COMMANd',sprintf(':%s:POSition 0', inputChan));
sendScopeMsg(scopeIP,'COMMAND',sprintf(':SELect:%s ON', outputChan));
sendScopeMsg(scopeIP,'COMMANd',sprintf(':%s:POSition 0', outputChan));
% TODO: set up trigger to external

% Meas 1 is amplitude of input signal
setupMeasurement(scopeIP, 1, 'AMPlitude', inputChan);
% Meas 2 is amplitude of output signal
setupMeasurement(scopeIP, 2, 'AMPlitude', outputChan);
% Meas 3 is phase difference
setupMeasurement(scopeIP, 3, 'PHASE', outputChan, inputChan);

% Some setup variables for outputting sinusoids
Fs = 44100;
time = 0:15*Fs; % time is 3 seconds

Phase = zeros(length(Frequencies),1);
Magnitude = zeros(length(Frequencies),1);
index = 0;
numOfFrequencies = numel(Frequencies);

% Start with an autoset at 1st frequency to make sure we start in range
testSignal = sin(time*Frequencies(1)*2*pi/Fs);
autoSetWave = audioplayer([testSignal,testSignal]',Fs);
play(autoSetWave);
pause(1);
sendScopeMsg(scopeIP,'COMMAND',':AUTOSet EXECute');

% Make sure both channels are on and centered
sendScopeMsg(scopeIP,'COMMAND',sprintf(':SELect:%s ON', inputChan));
sendScopeMsg(scopeIP,'COMMANd',sprintf(':%s:POSition 0', inputChan));
sendScopeMsg(scopeIP,'COMMAND',sprintf(':SELect:%s ON', outputChan));
sendScopeMsg(scopeIP,'COMMANd',sprintf(':%s:POSition 0', outputChan));


% band limit both channels to 20MHz
inputBandlimit = sprintf(':%s:BANdwidth TWEnty',inputChan);
sendScopeMsg(scopeIP,'COMMAND',inputBandlimit);
outputBandlimit = sprintf(':%s:BANdwidth TWEnty',outputChan);
sendScopeMsg(scopeIP,'COMMAND',outputBandlimit);
% setup averging
sendScopeMsg(scopeIP,'COMMAND',':ACQuire:MODe AVErage');
sendScopeMsg(scopeIP,'COMMAND',':ACQuire:NUMAVg 8');
pause(.75);
stop(autoSetWave);
% Sweep through frequencies and read measurements each time
for currentFrequency = Frequencies
%    fprintf('f = %d\n',currentFrequency); %<-debug onlly
% Show status in message box
    percentDone = index/numOfFrequencies;
    finishedBar = repmat(' ',1,round((percentDone*40)));
    unfinishedBar = repmat(' ',1,round((40-percentDone*40)));
    msgBox = sprintf(':MESSage:SHOW \"Current Frequency: %d Hz\\n%2.1f%% [\\x1b\\x32%s\\x1b\\x36%s\\x1b\\x08]\"', currentFrequency,100*percentDone,finishedBar,unfinishedBar);
    sendScopeMsg(scopeIP,'COMMAND',msgBox);
    sendScopeMsg(scopeIP,'COMMAND','MESSage:BOX 125,350,420,400');
    sendScopeMsg(scopeIP,'COMMAND','MESSage:STATE ON');

    index = index + 1;
    sync = mod(time,Fs/currentFrequency) > (Fs/currentFrequency)/2; % Make sync for trigger
    signal = sin(time * currentFrequency * 2*pi/Fs); % Make signal
    freqPlayer = audioplayer([sync;signal]', Fs);
    play(freqPlayer); % Output sound
    pause(1.2); % pause 1.2 s (enough time for averaging to settle
    
    % set trigger hold off to be just more than 1/2 period (10% more)
    holdOffCommand = sprintf(':TRIGger:A:HOLdoff:TIMe %2.4f', 1.1/(2*currentFrequency));
    sendScopeMsg(scopeIP,'COMMAND',holdOffCommand);
    
    % set time/div to get about 3 periods
    secDiv = 1/(3*currentFrequency);
    setScaleCommand = sprintf('HORizontal:MAIn:SCAle %1.9f', secDiv);
    sendScopeMsg(scopeIP,'COMMAND',setScaleCommand);
    
    % set volt/div of channel to maximize size
    inputAmplitude = readMeasurement(scopeIP,1);
    setInputVoltdiv = sprintf(':%s:SCAle %1.4f',inputChan,inputAmplitude/4.5);
    sendScopeMsg(scopeIP,'COMMAND',setInputVoltdiv);
    
    outputAmplitude = readMeasurement(scopeIP,2);
    setOutputVoltdiv = sprintf(':%s:SCAle %1.4f',outputChan,outputAmplitude/4.5);
    sendScopeMsg(scopeIP,'COMMAND',setOutputVoltdiv);
    
    % Read in the measurements
    inputAmplitude = readMeasurement(scopeIP,1);
    outputAmplitude = readMeasurement(scopeIP,2);
    Magnitude(index) = 20*log10(outputAmplitude / inputAmplitude);
    Phase(index) = readMeasurement(scopeIP,3);
    stop(freqPlayer);
end
sendScopeMsg(scopeIP,'COMMAND',':MESSage:STATE OFF');
end % function end

% EOF

