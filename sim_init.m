%% John Donnellan
close all; clear all; clc
%% Init Field
field.xs = [0:.01:2]; %m
field.ys = [0:.01:1]; %m
field.rho_water = 1000;
field.A_field = 0.01;
field.a = 0;
field.b = 1;

[field.U,field.V,loadables.U_field,loadables.V_field] = velocity_field_init('no_flow', field);

%% Init Boat
boat = boat_init('asym_point_particle',field.rho_water);

%% Init Control System
[controls, actuators, nav] = control_system_init('PI', 'direct_thrust', 'nav_passthrough');

%% Init Sim
%Sim Parameters
sim.dt = 0.005;
sim.xdot_d = 0.10;
sim.allow_disable = 0;
sim.thrust_disable_thresh = 0; 
sim.rot_disable_thresh = 0.0;
sim.cte_disable_thresh = 100;

%Constants
constants.rtod = 180/pi;
constants.dtor = pi/180;

%Boat IC Definition
% boat.x0 = waypoints_load(1,:); %m
boat.x0 = [1 0.5]; %m, overwritten if 'user_defined' waypoints
boat.xd = [1 1]; %m, overwritten if 'user_defined' waypoints
boat.v0 = [1 0]; %m/s
boat.v0_mag = norm(boat.v0);
boat.a0 = [0 0]; %m/s^2
boat.alpha0 = 0;
boat.theta0 = 0.*pi/180; %rad, init heading
boat.theta_dot0 = 0; %rad/s
boat.theta_ddot0 = 0; %rad/s^2

% Waypoints
waypoints_str = 'user_defined';
switch waypoints_str
    case 'user_defined'
        sim.waypoints = [boat.x0;boat.xd];
        boat.x0 = sim.waypoints(1,:);
        boat.xd = sim.waypoints(end,:);
    case 'my_efficient_path'
        [sim.waypoints,sim.predicted_cost] = gen_my_efficient_path(field,boat);
    case 'ref_efficient_path'
        
end

%% Plots
% figure
% scatter(sim.waypoints(:,1),sim.waypoints(:,2))
% figure
quiver(field.xs,field.ys,field.U,field.V)
