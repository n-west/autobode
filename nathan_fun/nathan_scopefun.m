%% Fun with tektronix!

scopeIP = '10.66.0.122';

%% Some fun commands
clc

response = urlread(['http://', scopeIP], 'get', {'COMMAND', ':BELL'});

%%
clc
% 1. Select waveform source using Data:source
% 2. Specify waveform data format using Data:Encdg
% 3. specify bytes/data using data:width
% 4. specify portion of data using data:start and data:stop
% 5. transfer waveform preamble information using wfmpre?
% 6. use curve to get data



%%
try urlread(['http://', scopeIP], 'get', {'COMMAND', ':select:ch1 on'});
end
try urlread(['http://', scopeIP], 'get', {'COMMAND', ':select:ch2 on'});
end
try urlread(['http://', scopeIP], 'get', {'COMMAND', ':data:encdg ASCII'});
end
try urlread(['http://', scopeIP], 'get', {'COMMAND', ':data:source CH1'});
end
try ch1scale = urlread(['http://', scopeIP], 'get', {'COMMAND', ':ch1:SCAle?'});
end
try response = urlread(['http://', scopeIP], 'get', {'COMMAND', ':curve?'});
end
ch1 = eval(ch1scale)*cell2mat(textscan(response, '%f', 'delimiter', ','))/(2^16);
try urlread(['http://', scopeIP], 'get', {'COMMAND', ':data:source ch2'});
end
try response = urlread(['http://', scopeIP], 'get', {'COMMAND', ':curve?'});
end
try ch2scale = urlread(['http://', scopeIP], 'get', {'COMMAND', ':ch2:SCAle?'});
end
ch2 = eval(ch2scale)*cell2mat(textscan(response, '%f', 'delimiter', ','))/(2^16);
try response = urlread(['http://', scopeIP], 'get', {'COMMAND', ':horizontal:secdiv?'});
end
t = linspace(0,eval(response)*10,length(ch1));
plot(t,ch1,'y',t,ch2,'b');
title('Scope Capture');
ylabel('Voltage [V]');
xlabel('Time [s]');
legend('channel 1', 'channel 2');
%% get data
response = urlread(['http://', scopeIP], 'get', {'COMMAND', ':horizontal:secdiv?'});

%%
response = urlread(['http://', scopeIP], 'get', {'COMMAND', ':select:control CH2'});

%%

response = urlread(['http://', scopeIP], 'get', {'COMMAND', ':data:source?'});