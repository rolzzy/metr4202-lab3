
clear all
close all

%% Call setup function for Dynamixel
o=setup();

%% Move robot to home position
gotoangle(90,90,0,o);
o.Exit()

%% Load camera parameters from file or from automatic calibration
load('cameraParams.mat');
% cameraParams = automatic_calibration;

%% Start "D" index which tracks whether or not the robot has finished its
% task.
D = [1,1,1,1,1,1,1,1,1,1,1,1];

%% Start robot
while any(D) == 1
    %% Detect dominos and origin of workspace 
    [cameraParams,RREF,TREF,T_Original,T_Delete] = framedetection1(cameraParams);

    %% Calculate path.  This also sorts the detected dominos in table T and include decision algorithm.
    % D is a relative domino position index, if D has all zeros in it, then the
    % robot has finished sorting dominos 
    [Optimal_path,D] = calculate_path(T_Original,T_Delete);
    
    %% Move domino
    o=setup();
    followline(Optimal_path,o);
    
end