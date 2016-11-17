function [f,distance]=get_line

%Purpose: For testing purposes only. The user can click a number of points
%on the plot which appears when the function is run. The code returns N
% equally spaced points linearly joining the points. Distance is the
% distance the point of the robot travels in mm.

N=100;

%% initialise function
%hold on
%axis equal

%% read in lego board image
%A = imread('Untitled.png');
%image([0 600],[0 550],A)
%xlabel('X')
%ylabel('Y')

%% get points by clicking points on image using the interprac function
%% !!!REPLACE WITH TRAJECTORY FROM MOTION PLANNING ALGORITHM!!!
%[x,y]=getpts();
x=[288 288];
y=[418 500];

%% interpolate to get trajectory
n = numel(x);
pt = interparc(N,x,y,'linear');
xi=pt(:,1);
yi=pt(:,2);
%plot trajectory (immediately cleared)
%figure
%plot(xi,yi)
%figure
%pause(999)
f=[xi,yi,zeros(length(xi),1)];
distance=arclength(xi,yi);

%% call sturdy2 to plot robot arm. Plots are supressed.
%for i=1:length(xi)
  %  clf
   % image([0 50],[0 50],A)
   % axis([-20 70 -20 70])
   % set(gca,'Ydir','normal')
   % sturdy2(f(i,1),f(i,2),f(i,3));
   % view([10,10,10])
   % set speed by adjusting pause time
   % pause(distance/(speed*length(xi)))
%end

end

