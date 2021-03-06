%% John Donnellan
close all; clear all; clc
%% Init Field
field.xs = [0:0.01:2]; %m
field.ys = [0:0.01:1]; %m
field.rho_water = 1000;
field.A_field = 0.01;
field.a = 0;
field.b = 1;

%Sizes are correct, think row/column vs x/y
[field.U,field.V,loadables.U_field,loadables.V_field] = velocity_field_init('gyre', field);

%% Init Boat
boat = boat_init('asym_point_particle',field.rho_water);

%% Init Control System
[controls, actuators, nav] = control_system_init('PI', 'direct_thrust', 'nav_passthrough');

%% Init Sim
%Sim Parameters
simu.dt = 0.005;
simu.xdot_d = 0.10;
simu.allow_disable = 0;
simu.thrust_disable_thresh = 0; 
simu.rot_disable_thresh = 0.0;
simu.cte_disable_thresh = 100;

%Constants
constants.rtod = 180/pi;
constants.dtor = pi/180;

%Boat IC Definition
% boat.x0 = waypoints_load(1,:); %m
boat.x0 = [0.0 0.01]; %m, overwritten if 'user_defined' waypoints
boat.xd = [1.99 0.99]; %m, overwritten if 'user_defined' waypoints
boat.v0 = [0 0]; %m/s
boat.v0_mag = norm(boat.v0);
boat.a0 = [0 0]; %m/s^2
boat.alpha0 = 0;
boat.theta0 = -90.*pi/180; %rad, init heading
boat.theta_dot0 = 0; %rad/s
boat.theta_ddot0 = 0; %rad/s^2

% Waypoints
waypoints_str = 'my_efficient_path';
switch waypoints_str
    case 'user_defined'
        simu.waypoints = [[0.01 0.01]; boat.xd];
    case 'my_efficient_path'
        [simu.waypoints,simu.predicted_cost] = gen_my_efficient_path(field,boat);
    case 'ref_efficient_path'
        
end

%% Plots
figure
scatter(simu.waypoints(:,1),simu.waypoints(:,2))
hold on
scatter(simu.waypoints(1,1),simu.waypoints(1,2),'ro')
scatter(simu.waypoints(end,1),simu.waypoints(end,2),'rx')
quiver(field.xs,field.ys,field.U,field.V)
