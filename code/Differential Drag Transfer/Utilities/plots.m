% function [] = plots3(C,C0,P,P0,B,tau,tfapp,amax,r0,mu,m,animations, n)

%% Set figures
% Setting up for gif image
imsize = 350;
im = cell(1,m);
xpos=10; ypos=150;

%% Final state vector
% Final time
time_days = tau.*tf*t0;

% Final spacecraft trajectory in Cartesian coordinates
[S] = cylindrical2cartesian(C(1:3,:),true);
x = S(1,:);
y = S(2,:); 
z = S(3,:);

% Earth's orbit
thetaE = linspace(0,2*pi,size(C,2));
s = zeros(6,length(thetaE));

for i = 1:length(thetaE)
    s(:,i) = coe2state(mu, [coe_earth(1:end-1) initial(2)+thetaE(i)]);
end
xE = s(1,:);
yE = s(2,:);
zE = s(3,:);

% Mars's orbit
for i = 1:length(thetaE)
    s(:,i) = coe2state(mu, [coe_mars(1:end-1) final(2)+thetaE(i)]);
end
xM = s(1,:);
yM = s(2,:);
zM = s(3,:);

%% Orbit representation
figure_orbits = figure;
view(3)
set(figure_orbits,'position',[xpos,ypos,1.2*imsize,imsize])
hold on
xlabel('$X$ coordinate')
ylabel('$Y$ coordinate')
zlabel('$Z$ coordinate')
plot3(0,0,0,'*k');
plot3(x(1),y(1),z(1),'*k');
plot3(xE,yE,zE,'LineStyle','--','Color','r','LineWidth',0.3);   % Earth's orbit
plot3(xM,yM,zM,'LineStyle','-.','Color','b','LineWidth',0.3);   % Mars' orbit
hold on
grid on; 

% Animation
if (animations == 1)
    for i = 1:m
        marker = plot(x(i),y(i),'k*');
        hold on
        title(strcat('time elapsed = ',{' '}, num2str(round(time_days(i))),' days'));
        frame = getframe(figure_orbits);
        im{i} = frame2im(frame);
        delete(marker)
        plot(x(i),y(i),'k.');
    end
    
    frame = getframe(figure_orbits);
    im{i} = frame2im(frame);
    writegif('orbit.gif',im,m,2/m);
end

legend('off')
title('Transfer orbit')
plot3(x,y,z,'k','LineWidth',1);
plot3(x(m),y(m),z(m),'*k');
grid on;

%% Propulsive acceleration plot
% Plot
figure_propulsion = figure;
subfigure(3,1,1)
set(figure_propulsion,'position',[xpos + 1.2*imsize,ypos,1.2*imsize,imsize])
hold on;
plot(time_days, u(1,:), 'LineWidth', 0.3)
yline(T, '--k')
xlabel('Flight time [days]')
ylabel('$\B$')
grid on;n;

subfigure(3,1,2)
hold on
plot(time_days, u(2,:), 'LineWidth', 0.3)
yline(dT, '--k')
xlabel('Flight time [days]')
ylabel('$\dot{B}$')
grid on;

subfigure(3,1,3)
hold on
plot(time_days, u(3,:), 'LineWidth', 0.3)
yline(ddT, '--k')
xlabel('Flight time [days]')
ylabel('$\ddot{B}$')
grid on;

sgtitle('Spacecraft $B^*$ state in time')

%% Position coordinates
figure_coordinates = figure;
set(figure_coordinates,'position',[xpos + 2*1.2*imsize,ypos,1.2*imsize,imsize])
title('Spacecraft position coordinates in time')
hold on

subplot(3,1,1)
hold on
plot(time_days, xM, 'LineStyle','-.','Color','b','LineWidth',0.3)
plot(time_days, xE, 'LineStyle','--','Color','r','LineWidth',0.3)
plot(time_days, x, 'k','LineWidth',1)
plot(time_days(1), x(1),'*k','DisplayName','')
plot(time_days(end),x(end),'*k','DisplayName','')
xlabel('Flight time [days]')
ylabel('$x$ [AU]')
grid on;

subplot(3,1,2)
hold on
plot(time_days, yM, '-.','LineWidth',0.3)
plot(time_days, yE, '--','LineWidth',0.3)
plot(time_days, y, 'k','LineWidth',1)
plot(time_days(1), y(1),'*k','DisplayName','')
plot(time_days(end),y(end),'*k','DisplayName','')
xlabel('Flight time [days]')
ylabel('$y$ [AU]')
grid on;