clear all
clc

% System parameter

load('Y_openloop.mat')

K1 = -0.1913;
T1 = 168;
t1 = 68
t1_s = 57;
M = 65.9;

K2 = 0.0973;
T2 = 306;
t2 = 5.75
t2_s = 10.5;

k = 0; % time

u_s = 65.9;
umax = 10.13;

% System dimension
nx = 2;
nu = 1;
ny = 1;

% Loop constant
N = 600;
dt = 1;
dist = 0.01;

% System matrix

A = [dist, 0 ; 0, dist];
B = [K1*(1-exp(-k/T1)); K2*(1-exp(-k/T2))];

nl = 1

% Weighting matrices
Q = diag([1 1]);
R = 2e-5;

% Decision variable
O = sdpvar(nx,nx,'symmetric');
Y = sdpvar(nu,nx);
X = sdpvar(nu,nu);
T = sdpvar(ny,ny);
G = sdpvar(nx,nx);
gamma = sdpvar(1);

% Preallocate variables
T = [t1-t1_s;t2-t2_s];
Ts = [t1_s;t2_s];
x = zeros(nx,N+1);
T_reactor(1) = T(1);
T_coolance(1) = T(1); 

y_temp(1) = t1+2;
y_cool(1) = t2;

x(:,1) = T;
tStart = cputime;
J_online = 0;
%%
for k = 1:dt:N

    LMIs = [];
    LMIs = [LMIs, [1 x(:,k)'; x(:,k) O] >= 0];

    for i = 1:nl
        
        LMIs = [ LMIs, [...
         G+G'-O              G'*A' + Y'*B'  G'*Q^(1/2)'     Y'*R^(1/2)';
         A*G + B*Y   O                zeros(nx,nx)    zeros(nx,nu);
         Q^(1/2)*G      zeros(nx,nx)     gamma*eye(nx)   zeros(nx,nu);
         R^(1/2)*Y      zeros(nu,nx)     zeros(nu,nx)    gamma*eye(nu)] >= 0];   
        
    end
     
    LMIs = [ LMIs,[umax^2 Y; Y' G+G'-O] >= 0];

    optimize(LMIs,gamma)
    
    K = value(Y)/value(G);
    O_value{k} = value(G);
    K_value{k} = value(K);

    %Plant
    norm_K(:,k)=norm(K,2);
    u(k) = K*x(:,k);
    u_input(k) = K*x(:,k)+u_s;
    B = [K1*(1-exp(-k/T1)); K2*(1-exp(-k/T2))];
    
    U(k) = u(:,k)+u_s;
    x(:,k+1) = A*x(:,k) + B*(U(k));

    y_temp(k+1) = t1_s+x(1,k);
    y_cool(k+1) = t2_s+x(2,k);
    
    x(1,k+1) = x(1,k+1)+T(1,1)+1.1;
    x(2,k+1) = x(2,k+1)+T(2,1);
    
    err = (abs(y_temp(k+1)-t1_s)/t1_s)*100
    J_online = J_online + ((x(:,k+1)'*Q*x(:,k+1))+(u(:,k)'*R*u(:,k)));
    
end
 tEnd = cputime - tStart
 
%%

tt = 0:1:N;
tt_ = 0:1:N-1;
tt2 = 0:3:N;
tt3 = 0:1:598;

u(1),u(2)=u(3);
y_temp(2) = (y_temp(1)+y_temp(3))/2;
y_cool(2) = y_cool(1);
x(1,1:2) = x(1,3);
x(2,1:2) = x(2,3);
x_=x(2,:)-0.7659;

tt = 0:1:N;

figure(1)
subplot(2,1,1)
plot(tt,x(1,:),'Linewidth',1.5);
grid on;
xlabel('time (s)');
ylabel('T_1 - T_1s (C)');
grid on;

subplot(2,1,2)
plot(tt,x(2,:),'Linewidth',1.5);
grid on;
xlabel('time (s)');
ylabel('T_2 - T_2s  (C)');
grid on;

figure(2);  
subplot(2,1,1)
plot(tt,y_temp,'Linewidth',1.5);d
hold on
plot(tt2,y_reactor_openloop,'--','Linewidth',1.5);
xlabel('time (s)');
ylabel('reactor temperature (C)');
legend('Online LMI-based RMPC','Open loop');
grid on;

subplot(2,1,2) 
plot(tt,y_cool,'Linewidth',1.5);
hold on
plot(tt2,y_cool_openloop,'--','Linewidth',1.5);
grid on;
xlabel('time (s)');
ylabel('Coolannt temperature (C)');
legend('Online LMI-based RMPC','Open loop');
grid on;

figure(3);  
plot(tt3,u(2:1:N),'Linewidth',1.5);
hold on
con1 = umax*ones(1,N);
plot(tt_,con1,'--r','Linewidth',1)
grid on;
xlabel('time (s)');
ylabel('u');
legend('u','constrain');
grid on;

figure(4);  
plot(tt3,u(2:1:N)+u_s,'Linewidth',1.5);
hold on
con2 = 76*ones(1,N);
plot(tt_,con2,'--r','Linewidth',1)
grid on;
xlabel('time (s)');
ylabel('cm3 / s.');
legend('Flow rate of coolant','constrain');
grid on;

%%

x_online = x;
u_online = u;
y_temp_online = y_temp;
y_cool_online = y_cool;
J_online
save('Case4_Data','O_value','K_value','N','x_online','u_online','y_temp_online','y_cool_online');
