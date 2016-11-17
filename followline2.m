function followline2(Optimal_path,o)

%Purpose: Move the robot. This file will be replaced when the motion
%planning algorithm is built.

%Set desired speed. 200mm/s is ideal.
speed = 50; %mm/s

goto_height = 10; % Use this height in goto function

% Set height high
height = 70;
set_height(0,0,height,o);
pause(1)

% Go to start position
goto(Optimal_path(size(Optimal_path,1),1),Optimal_path(size(Optimal_path,1),2),goto_height,o);

% Set height low
pause(3)
height = 10;
set_height(0,0,height,o);
pause(3)

%Sequentially call goto function to make robot go through the x,y points set by
%optimal path
for i = length(Optimal_path)-1:-1:1
    goto(Optimal_path(i,1),Optimal_path(i,2),goto_height,o);
%     pause(distance/(speed*length(Optimal_path))); %Ask Henry the importance of this line
end

% Set height high
pause(3)
height = 70;
set_height(0,0,height,o);
pause(3)

%Set the home position
start_position = [Optimal_path(1,1),Optimal_path(1,2)];
end_position = [400,420];
home_path = A_Star4(start_position/10,end_position/10);
home_path = home_path*10;
for i = length(home_path)-1:-1:1
    goto(home_path(i,1),home_path(i,2),0,o);
%     pause(distance/(speed*length(Optimal_path))); %Ask Henry the importance of this line
end
height = 150;
set_height(0,0,height,o);

% Close figures and disconnect dynamixels
close all
o.Exit()
end
