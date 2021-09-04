clear all
clc

load('Case4_data.mat')
load('Y_openloop.mat')
load('Case4_exp.mat')
N = 600;
N_offline = N;
nx = 2;

% System parameter

K1 = -0.1913;
T1 = 168;
t1 = 68
t1_s = 57;

K2 = 0.0973;
T2 = 306;
t2 = 5.75
t2_s = 10.5;

k = 0; % time

u_s = 65.9;
umax = 10.13;

dist = 0.01;

A_offline = [dist, 0 ; 0, dist];

% System dimension
nx = 2;
nu = 1;
ny = 1;

% Weighting matrices
Q = diag([1 1]);
R = 2e-1;

% Preallocate variables
T = [t1-t1_s;t2-t2_s];
Ts = [t1_s;t2_s];
x_offline = zeros(nx,N+1);
T_reactor(1) = T(1);
T_coolance(1) = T(1); 

y_temp_offline(1) = t1+2;
y_cool_offline(1) = t2;

x_offline(:,1) = T;

el = [1,2,3,60,120,180,240,340,480];
nl = numel(el);
J_offline = 0;

tStart = cputime;

for k = 1:1:N;
    
    for i=2:nl

        val = x_offline(:,k)'*inv(O_value{el(i)})*x_offline(:,k); % xQ^-1x
        
        if val >1
            break
        
    end
            
    end
 
    if i == nl
        
        i_k = i
        
    else
        
        i_k = i-1;
        
    end
    

    % Plant
    
    K_offline = K_value{i_k};
    
    u_offline(k) = K_offline*x_offline(:,k);
    
    B_offline = [K1*(1-exp(-k/T1)); K2*(1-exp(-k/T2))];

    x_offline(:,k+1) = A_offline*x_offline(:,k) + B_offline*(u_offline(k)+u_s);

    y_temp_offline(k+1) = t1_s+x_offline(1,k);
    y_cool_offline(k+1) = t2_s+x_offline(2,k);

    x_offline(1,k+1) = x_offline(1,k+1)+T(1,1)+1.2515;
    x_offline(2,k+1) = x_offline(2,k+1)+T(2,1);
    
    err_offline = (abs(y_temp_offline(k+1)-t1_s)/t1_s)*100;
    
    J_offline = J_offline + ((x_offline(:,k+1)'*Q*x_offline(:,k+1))+(u_offline(:,k)'*R*u_offline(:,k)))

end

 tEnd = cputime - tStart
 
%%

u_offline(1:1:6)=u_offline(7);
y_temp_offline(2) = (y_temp_offline(1)+y_temp_offline(3))/2;
y_temp_offline(3) = (y_temp_offline(2)+y_temp_offline(4))/2;
y_cool_offline(2) = y_cool_offline(1);

tt = 0:1:N;
tt_ = 0:1:N-1;
tt_online = 5:20:N;
tt_openloop = 0:3:N;

figure(1)
subplot(2,1,1);  
plot(tt,y_temp_offline,'Linewidth',1.5);
hold on
plot(tt_online,y_temp_online(5:20:N),'-^','Linewidth',1.5);
hold on
plot(tt_openloop,y_reactor_openloop,'Linewidth',1.5);
xlabel('time (s)');
ylabel('Reactor temperature (C)');
legend('Offline algorithm', 'Online algorithm', 'Open loop')
grid on;

subplot(2,1,2);  
plot(tt,y_cool_offline,'Linewidth',1.5);
hold on
plot(tt_online,y_cool_online(5:20:N),'-^','Linewidth',1.5);
hold on
plot(tt_openloop,y_cool_openloop,'Linewidth',1.5);
xlabel('time (s)');
ylabel('Coolannt temperature (C)');
grid on;

tt2 = 0:1:598;

figure(2);  
con1 = umax*ones(1,N);
plot(tt_,con1,'--r','Linewidth',1)
hold on
plot(tt2,u_offline(2:1:N),'Linewidth',1.5);
hold on
plot(tt_online,u_online(5:20:N),'-^','Linewidth',1.5);
hold on
con_o = 0*ones(1,N);
plot(tt_,con_o,'Linewidth',1)
hold on
xlabel('time (s)');
ylabel('u');
legend('Max capasity','Offline algorithm', 'Online algorithm', 'Open loop')
grid on;

figure(3);  
con3 = (umax+u_s)*ones(1,N);
plot(tt_,con3,'--r','Linewidth',1)
hold on
plot(tt2,u_offline(2:1:N)+u_s,'Linewidth',1.5);
hold on;
plot(tt_online,u_online(5:20:N)+u_s,'-^','Linewidth',1.5);
hold on
con_o = u_s*ones(1,N);
plot(tt_,con_o,'Linewidth',1)
hold on
xlabel('time (s)');
ylabel('cm3 / s.');
legend('Max capasity','Offline algorithm', 'Online algorithm', 'Open loop')
grid on;
%%
xvar = sdpvar(nx,1);

el_p = [1,60,120,180,240,340];

figure(4);  
for i=1:1:size(el_p,2)

    cont = [[xvar'*inv(O_value{el_p(i)})*xvar]<=1]
    ops = sdpsettings('plot.shade',0.1); %1 mean %visturl
    plot_col = [1 0.85 0.4] %Colour 0-1 [R G B]
    plot(cont,xvar,plot_col,200,ops)
    hold on
    grid on
    
end
plot(x_offline(1,20:5:N),x_offline(2,20:5:N),'-* b','Linewidth',0.5);
hold on
xlabel('T_1-T_1s');
ylabel('T_2-T_2s');

hold on
%%

figure(5);  
for i=1:1:size(el_p,2)

    cont = [[xvar'*inv(O_value{el_p(i)})*xvar]<=1]
    ops = sdpsettings('plot.shade',0.1); %1 mean %visturl
    plot_col = [1 0.85 0.4] %Colour 0-1 [R G B]
    plot(cont,xvar,plot_col,200,ops)
    hold on
    grid on
    
end

xlabel('T_1-T_1s');
ylabel('T_2-T_2s');
plot(y_temp_exp(31:201)-t1_s,y_cool_exp(31:201)-t2_s,'-* b','Linewidth',0.5);
hold on

J_offline

%% Plot of experiment

tt_exp = 0:3:N;

figure(6);  
plot(tt_exp,y_temp_exp,'Linewidth',1.5)
hold on
set1 = 57*ones(1,N);
plot(tt_,set1,'--r','Linewidth',1);
grid on;
xlabel('time (s)');
ylabel('Reactor temperature');
legend('Temperature', 'set-point')

figure(7);  
plot(tt_exp,y_cool_exp,'Linewidth',1.5)
grid on;
xlabel('time (s)');
ylabel('Coolant temperature');

figure(8);
plot(tt_exp,u_exp,'Linewidth',1.5)
hold on
set2 = u_s*ones(1,N);
plot(tt_,set2,'--r','Linewidth',1);
grid on;
xlabel('time (s)');
ylabel('cm3/s.');

figure(9);
plot(tt_exp,u_exp-u_s,'Linewidth',1.5)
hold on
set2 = 0*ones(1,N);
plot(tt_,set2,'--r','Linewidth',1);
grid on;
xlabel('time (s)');
ylabel('u');

save('Case4_data_off.mat','y_temp_offline')
%%

%save('Case4_exp.mat','y_temp_exp','y_cool_exp','PWM_exp','u_exp')