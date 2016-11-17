function [P] =sturdy2(x,y,z)

%Purpose: Calculate Inverse Kinematics

L1=310; %Length of arm 1 (mm) Previous value 305
L2=170; %Length of arm 2 (mm) Previous value 170
L3_actual=225; %mm
offset=33; %mm
L3=(L3_actual^2+offset^2)^0.5;; %Length of arm 3 (mm) 
angleoffset=atand(offset/L3_actual);

%Position of base from 0 point
x_base=-55; %-35 %measured -25
y_base=115;% 148 %measured 113
z_base=120; % Actual 190

%Dedefine x,y,z as deviation from 0 point
x=-x-x_base;
y=y-y_base;
z=z-z_base;

%inverse kinematics calcs
theta3=asind(-z/L3)+angleoffset;
a2=L2+L3*cosd(theta3);
theta2=acosd((x^2+y^2-L1^2-a2^2)/(2*L1*a2));
c1=(x*(L1+a2*cosd(theta2))+y*a2*sind(theta2))/(L1^2+a2^2+2*L1*a2*cosd(theta2));
s1=(y*(L1+a2*cosd(theta2))-x*a2*sind(theta2))/(L1^2+a2^2+2*L1*a2*cosd(theta2));
theta1=atan2d(s1,c1);
P=[theta1,theta2,theta3];


%plot of robot position in 3D space
%  hold on
%  scatter3(x_base,y_base,z_base)
%  scatter3(x+x_base,y+y_base,z+z_base)
%  scatter3(L1*cosd(theta1)+x_base,L1*sind(theta1)+y_base,z_base)
%  scatter3(L1*cosd(theta1)+L2*cosd(theta1+theta2)+x_base,L1*sind(theta1)+L2*sind(theta1+theta2)+y_base,z_base)
%  a=[x_base,y_base,z_base];
%  b=[L1*cosd(theta1)+x_base,L1*sind(theta1)+y_base,z_base];
%  c=[L1*cosd(theta1)+L2*cosd(theta1+theta2)+x_base,L1*sind(theta1)+L2*sind(theta1+theta2)+y_base,z_base];
%  d=[x+x_base,y+y_base,z+z_base];
%  plot3([a(1);b(1)],[a(2);b(2)],[a(3);b(3)]);
%  plot3([b(1);c(1)],[b(2);c(2)],[b(3);c(3)]);
%  plot3([c(1);d(1)],[c(2);d(2)],[c(3);d(3)]);
%  xlabel('X')
%  ylabel('Y')
%  zlabel('Z')
%  axis equal
%  hold off

end
