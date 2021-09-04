% PID control

clear all
clc

load('Case4_data.mat')
load('Case4_data_off.mat')
    
ysp = 57.3635;
yt(1) = 70;
 y_open(1) = 70;
ref = yt(1);

u_s = 65.9;
u = 0;

er(1) = abs(ysp - yt(1));

Kc = 6;
Ti = 160;
Td = 0;

Tal = 168;
K = -0.1973;

dt = 1;
N = 600;

for i = 1:1:N
    
    % Function
    y(i) = K*u*(1-exp(-i/Tal));
    y_open(i) = K*u_s*(1-exp(-i/Tal))+70;
    yt(i+1) = ref + y(i);
    yref(i+1) = abs(ysp-yt(i+1));
    
    % Integrate
    er(i+1) = abs(ysp - yt(i+1));
    b = i; a = i-1;
    I(i) = (b-a)*((er(i+1)+er(i))/2);
    SumI = sum(I);
    
    % Differentation 
    der(i) = (er(i+1) - er(i))/i;
    
    
    u_pid(i) = Kc*(er(i+1) + (1/Ti)*SumI + Td*der(i));
    %if u_pid(i) > 45
    %    u_pid(i) = 45;
    %end
    u = u_pid(i)
end
%%


figure(1)
subplot(2,1,1)
con_max = (23)*ones(1,N);
plot(tu,con_max,'r','Linewidth',1)
hold on
con_s = (20.0827)*ones(1,N);
plot(tu,con_s,'--r','Linewidth',1)
hold on
plot(t,yt,'Linewidth',1.5)
legend('Hard constraint','Steady-state');
hold on
ylabel('Level(cm3/s)')
xlabel('time(s)')
grid on


t = 0:1:N;
tm = 0:1:N-1;
tp = 0:1:N+1;
figure(1)
plot(tm,u_pid,'Linewidth',1)
hold on
grid on
figure(2)
plot(tm,y_open,'--r','Linewidth',1.5)
hold on
plot(t(1:30:N),yt(1:30:N),'-^','Linewidth',1)
hold on
plot(t,y_temp_online,'Linewidth',1.5)
hold on
plot(t,y_temp_offline,'Linewidth',1.5)
hold on
legend('Open loop','PID','Online MPC','Offline MPC');
grid on



