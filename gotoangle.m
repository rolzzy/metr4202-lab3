function gotoangle(angle1,angle2,angle3,o)

%Purpose: Set the angles of the motors

%Angle 1 is angle of motor 1 from the horisontal
%Angle 2 is angle of motor 1 from the vertical
%Angle 3 is angle of motor 1 from the flat
%% Initialise
dynamixel_id = 2;

%% Write Command
%1st motor
o.writeAngle('id',2,'deg',angle1+60);
%2nd motor
o.writeAngle('id',1,'deg',angle2+150);
%3rd motor
o.writeAngle('id',3,'deg',150+angle3);
end