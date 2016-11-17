function [cameraParams,RREF,TREF,T_Original,T_Delete] = framedetection1(cameraParams)

load('cameraParams.mat');

% Read Scene
vid = videoinput('kinect', 1, 'RGB_1280x960');
assignin('base', 'vid', vid);
frame = getsnapshot(vid);
imwrite(frame,'rgb.jpg');
 
RGB = imread('rgb.jpg'); 
 
%%The Kinect flips the image. Un-flip the image.
RGBf = fliplr(RGB);

worldPoints=2.3*[10,10;10,20;10,30;10,40;10,50;...
                 20,10;20,20;20,30;20,40;20,50;...
                 30,10;30,20;30,30;30,40;30,50;...
                 40,10;40,20;40,30;40,40;40,50;...
                 50,10;50,20;50,30;50,40;50,50;...
                 60,10;60,20;60,30;60,40;60,50;...
                 70,10;70,20;70,30;70,40;70,50;...
                 80,10;80,20;80,30;80,40;80,50];
[RREF,TREF] = extrinsics(imagePoints,worldPoints,cameraParams);

[T_Original,T_Delete] = DominoTrack1;
NumberOfDominos = length(T_Original.centroid);

for i=1:NumberOfDominos
    % Convert centroid to world co-ordinate system
    T_Original.centroid{i} = pointsToWorld(cameraParams, RREF, TREF, T_Original.centroid{i});
    T_Delete.centroid2{i} = pointsToWorld(cameraParams, RREF, TREF, T_Delete.centroid2{i});
end
end

