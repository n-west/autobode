function negsemilogx(x,y)
% Do log10 but keep sign
xlog = sign(x).*log10(abs(x));
ylog = sign(y).*log10(abs(y));
% Just to get axis limits
plot(xlog,y,'o')
% Get limits
xaxislims = xlim;
xaxiswdth = diff(xaxislims);
yaxislims = ylim;
fprintf('%2.4f, %2.4f\n',yaxislims);
yaxishgt = diff(yaxislims);
fprintf('%d\n',yaxishgt);
% Wrap negative data around to positive side
xlog(xlog<0) = xlog(xlog<0) + xaxiswdth;
ylog(ylog>0) = ylog(ylog>0) - yaxishgt;
% Plot
plot(xlog,y,'o')
% Mess with ticks
tck = get(gca,'XTick')';
% Shift those that were wrapped from negative to positive (above) back 
% to their original values
tck(tck>xaxislims(2)) = tck(tck>xaxislims(2)) - xaxiswdth;
% Convert to string, then remove any midpoint
tcklbl = num2str(tck);
tcklbl(tck==xaxislims(2),:) = ' ';
% Update tick labels
set(gca,'XTickLabel',tcklbl)
