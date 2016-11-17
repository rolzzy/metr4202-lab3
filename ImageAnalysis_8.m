function [caption,centroid,domino_id,NumberOfDominos,GlobalPoints] = ImageAnalysis_8(IM)
caption = [];
centroid = [];
domino_id = [];
% Detect Dominos
originalImage = rgb2gray(IM);

binaryImage = adaptivethreshold(originalImage,20,0.03,0); % (20,0.07 for frame1021) (40,0.032 for frame 153)
binaryImage = imclearborder(binaryImage);
binaryImage = bwareaopen(binaryImage,80);

% Get all the tile properties and number of tiles.
tileMeasurements = regionprops(binaryImage);
numberOfTiles = size(tileMeasurements, 1);

% Pre-allocate space for global coordinate points
GlobalPoints = zeros([28,2]);
NumberOfDominos = 0;

caption = zeros(0,numberOfTiles);
caption = num2cell(caption);
centroid = zeros(0,numberOfTiles);
centroid = num2cell(centroid);
domino_id = zeros(0,numberOfTiles);
domino_id = num2cell(domino_id);

for k = 1 : numberOfTiles           % Loop through all Tiles.
    % Find the bounding box of each tile.
    thisTilesBoundingBox = tileMeasurements(k).BoundingBox;
    thisTilesCentroid = tileMeasurements(k).Centroid;
    % Extract this out into it's own image.
    subImage = imcrop(binaryImage, thisTilesBoundingBox);
    subImage = ~bwareaopen(~subImage,50);
    % Get list of pixels in current Tile.
    [B,L,N] = bwboundaries(subImage,'noholes');
    stats = regionprops(L,'Area','Centroid',...
        'Orientation','MinorAxisLength','MajorAxisLength','Extrema');

    % If more than just domino boundary is detected in stats, remove false
    % boundaries.
    myarray = zeros(10,1);
    if length(stats) > 1
        for i = 1:length(stats)
            for j = 1:length(stats)
                if i < j && stats(i).Area < stats(j).Area
                    myarray(i) = i;
                end
            end
        end
    end

    % Delete rows identified directly above.
    for i = length(myarray):-1:1
        if myarray(i) ~= 0
            stats(myarray(i),:) = [];
        end
    end

    % Locate Extrema for diagonal dominos
    P1 = (stats(1).Extrema(1,:)+stats(1).Extrema(2,:))/2;
    P2 = (stats(1).Extrema(3,:)+stats(1).Extrema(4,:))/2;
    P3 = (stats(1).Extrema(5,:)+stats(1).Extrema(6,:))/2;
    P4 = (stats(1).Extrema(7,:)+stats(1).Extrema(8,:))/2;
    fixedPoints = [0,0;0,26;51,26;51,0];

    smallAngle = 5;
    largeAngle = 80; % (80 for frame 1021 - planar) (63 for frame 153 - projective)

    % Edit extrema for horizontal dominos
    if abs(stats(1).Orientation) < smallAngle
        P1 = [stats(1).Extrema(7,1),stats(1).Extrema(1,2)]; % Left-Top
        P2 = [stats(1).Extrema(3,1),stats(1).Extrema(1,2)]; % Right-Top
        P3 = [stats(1).Extrema(3,1),stats(1).Extrema(5,2)]; % Right-Bottom
        P4 = [stats(1).Extrema(7,1),stats(1).Extrema(5,2)]; % Left-Bottom
        movingPoints = [P4;P1;P2;P3];
        t_proj = fitgeotrans(movingPoints,fixedPoints,'projective');
    end

    % Edit extrema for vertical dominos
    if abs(stats(1).Orientation) > largeAngle
        P1 = [stats(1).Extrema(7,1),stats(1).Extrema(1,2)]; % Left-Top
        P2 = [stats(1).Extrema(3,1),stats(1).Extrema(1,2)]; % Right-Top
        P3 = [stats(1).Extrema(3,1),stats(1).Extrema(5,2)]; % Right-Bottom
        P4 = [stats(1).Extrema(7,1),stats(1).Extrema(5,2)]; % Left-Bottom
        movingPoints = [P1;P2;P3;P4];
        t_proj = fitgeotrans(movingPoints,fixedPoints,'projective');
    end

    % Transform Images
    if abs(stats(1).Orientation) > smallAngle &&...
            abs(stats(1).Orientation) < largeAngle && stats(1).Orientation < 0
        movingPoints = [P4;P1;P2;P3];
        t_proj = fitgeotrans(movingPoints,fixedPoints,'projective');
    elseif abs(stats(1).Orientation) > smallAngle &&...
            abs(stats(1).Orientation) < largeAngle && stats(1).Orientation > 0
        movingPoints = [P1;P2;P3;P4];
        t_proj = fitgeotrans(movingPoints,fixedPoints,'projective');
    end

    tformImage = imwarp(subImage,t_proj);

    % Determine whether sub-plot represents a domino
    [B1,L1,N1] = bwboundaries(tformImage,'holes');
    statsTform = regionprops(L1,'Area','Centroid',...
        'Orientation','MinorAxisLength','MajorAxisLength','Extrema');

    % If more than just domino boundary is detected in stats, remove false
    % boundaries.
    myarray = zeros(10,1);
    if length(statsTform) > 1
        for i = 1:2
            for j = 1:2
                if i < j && statsTform(i).Area < statsTform(j).Area
                    myarray(i) = i;
                end
            end
        end
    end

    % Delete rows identified directly above.
    for i = length(myarray):-1:1
        if myarray(i) ~= 0
            statsTform(myarray(i),:) = [];
        end
    end
    
    ARdomino = statsTform(1).MajorAxisLength/statsTform(1).MinorAxisLength; % Domino Aspect Ratio
    HP = statsTform(1).Centroid(1,1); % Horizontal half-point of Domino
    DArea = statsTform(1).Area; % Domino Area
    leftdots = 0;
    rightdots = 0;

    for i = 1:length(statsTform)
        domino = 0;
        AR1 = statsTform(i).MajorAxisLength/statsTform(i).MinorAxisLength; % Hole Aspect Ratio
        if i ~= 1 && AR1 > 4.5 && ARdomino > 1.65 && ARdomino < 2.5...
                && abs(statsTform(i).Orientation) > 20 && DArea > 500
            domino = 1;
            for j = 1:length(statsTform)
                AR = statsTform(j).MajorAxisLength/statsTform(j).MinorAxisLength; % Aspect Ratio
                HArea = statsTform(j).Area; % Hole Area
                XCentroid = statsTform(j).Centroid(1,1); % X-coordinate of hole centroid
                if j ~= 1 && HArea/DArea > 0.01 && AR > 1/4 && AR < 2.5 && XCentroid < HP
                    leftdots = leftdots + 1;
                end
                if j ~= 1 && HArea/DArea > 0.01 && AR > 1/4 && AR < 2.5 && XCentroid > HP
                    rightdots = rightdots + 1;
                end
            end
        caption{k} = sprintf('%d | %d', leftdots, rightdots);
        centroid{k} = thisTilesCentroid;
        if leftdots < rightdots || leftdots == rightdots
            domino_id{k} = [leftdots,rightdots];
        else
            domino_id{k} = [rightdots,leftdots];
        end
    end
    
    if domino == 1
        NumberOfDominos = NumberOfDominos + 1;
        % Record global point coordinates
        RGPoints = zeros(4,2);
        RGPoints(1,:) = P1+thisTilesBoundingBox(1,1:2);
        RGPoints(2,:) = P2+thisTilesBoundingBox(1,1:2);
        RGPoints(3,:) = P3+thisTilesBoundingBox(1,1:2);
        RGPoints(4,:) = P4+thisTilesBoundingBox(1,1:2);

        % Store global point coordinates
        for w = 1:4
            GlobalPoints(w+4*(k-1),:) = RGPoints(w,:);
        end
        caption = caption(~cellfun('isempty',caption));
        centroid = centroid(~cellfun('isempty',centroid));
        domino_id = domino_id(~cellfun('isempty',domino_id));
        GlobalPoints(all(GlobalPoints==0,2),:)=[];
    end
    end

for i = 1:length(centroid)
    x{i}=centroid{i}(1);
    y{i}=centroid{i}(2);
end
end