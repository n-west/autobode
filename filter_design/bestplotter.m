% tf taken from wikipedia's sallen-key filter design
R1 = 150;
C1 = 4.7e-6;
R2 = 2*R1;
C2 = C1;
Rb = 20000;
Ra = 15000;
Rf = 3000;

num = [(1+Rb/Ra)/(R1*C1), 0];
den = [1, (1/(R1*C1) + 1/(R2*C1) + 1/(R2*C2) - Rb/(Ra*Rf*C1)), (R1+Rf)/(R1*Rf*R2*C1*C2)];
sys = tf(conv(num,num),conv(den,den));
frequencies = logspace(log10(25),log10(18500),10000);
w = frequencies*(2*pi);
[m,p]=bode(sys,w);

mag = [];
phase = [];
for ind = 1:numel(m)
    mag(ind) = 20*log10(m(1,1,ind));
    phase(ind) = p(1,1,ind);
end
mag =  mag - abs(max(mag));

%%

figure(2);
set(2,'Units','pixels');
set(2,'Position',[1,1,1281,721]);
subplot(1,2,1);
semilogx(frequencies, mag,'b.');
title('Magnitude Response of Fourth Order BPF','FontSize',20);
ylabel('Magnitude |H(\omega)| [dB]','FontSize',17);
xlabel('Frequency [Hz]','FontSize',17);
grid on;

subplot(1,2,2);
semilogx(frequencies, phase,'b.');
title('Phase Response of Fourth Order BPF','FontSize',20);
ylabel('Phase \angle H(\omega) [\circ]','FontSize',17);
xlabel('Frequency [Hz]','FontSize',17);
grid on;


%%

load looooongdatacapture.mat

figure(2);
subplot(1,2,1);
hold on;
set(gca,'FontSize',14);
semilogx(f, h-max(h),'.','MarkerEdgeColor',[1,.5,0]);
legend('Theoretical','Measured');
set(gca,'Units','pixels');
set(gca,'Position',[80 80 525 590]);
hold off;
subplot(1,2,2);

hold on;
semilogx(f, -w,'.','MarkerEdgeColor',[1,.5,0]);
set(gca,'FontSize',14);
legend('Theoretical','Measured');
set(gca,'Units','pixels');
set(gca,'Position',[730 80 525 590]);
hold off;