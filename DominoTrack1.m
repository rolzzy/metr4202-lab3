function [T_Original, T_Delete] = DominoTrack1
    T_Original = [];
    T_Delete = [];
    persistent dominoStats; 
    persistent j;
    
    % Define frame rate
    NumberFrameDisplayPerSecond=5;

    % Open figure
    hFigure=figure(1);

    % Set-up webcam video input
    try
       % For windows
       vid = videoinput('kinect', 1, 'RGB_1280x960');
    catch
       try
          % For macs.
          vid = videoinput('macvideo', 1);
       catch
          errordlg('No webcam available');
       end
    end

    % Set parameters for video
    % Acquire only one frame each time
    set(vid,'FramesPerTrigger',1);
    % Repeat an additional 9 frames, total of 10
    set(vid,'TriggerRepeat',19);
    triggerconfig(vid, 'Manual');

    % set up timer object
    TimerData=timer('TimerFcn', {@Tracking,vid},'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop');

    % Start video and timer object
    start(vid);
    start(TimerData);

    % Handle the figure being closed during acquisition
    if vid.FramesAcquired < 20
        if ~ishandle(hFigure)
            % Clean up everything
            stop(TimerData);
            delete(TimerData);
            stop(vid);
            delete(vid);
            return
        end
    end

    % Stop video and timer when acquisition is finished
    if vid.FramesAcquired == 20
        close all;
        [T_Original,T_Delete] = Detect6(dominoStats);
        j = 0;
        dominoStats = cell(1); 
        stop(TimerData);
        delete(TimerData);
        stop(vid);
        delete(vid);
    end

    function Tracking(obj, event,vid)
        persistent IMf;
        persistent handlesTrack;
        persistent handlesPlot;
        persistent handlesText;
        if vid.FramesAcquired == 20
            return
        end
        trigger(vid);
        IM=getdata(vid,1,'uint8');
        IMf = fliplr(IM);

        % Add imagePoints to the output below
        [caption,centroid,domino_id,NumberOfDominos,GlobalPoints] = ImageAnalysis_8(IMf);
        for i = 1:length(centroid)
            x{i}=centroid{i}(1);
            y{i}=centroid{i}(2);
        end

        % If it is the first iteration, set up the figure
        if isempty(handlesTrack)
           j = 1;
           handlesTrack=imshow(IMf);
           hold on
           handlesPlot = scatter(GlobalPoints(:,1),GlobalPoints(:,2),'x','y','LineWidth',2);
           if isempty(caption) == 0
               handlesText = text(cell2mat(x),cell2mat(y),caption,'color','red','FontWeight', 'bold');
           end
           dominoStats{j} = [cell2mat(centroid'), cell2mat(domino_id')];
           title('Domino Tracking');
        else
           % Update the image and domino positions
           j = j+1;
           delete(handlesTrack);
           handlesTrack=imshow(IMf);
%            set(handlesTrack,'CData',IM);
           delete(handlesPlot);
           delete(handlesText);
           dominoStats{j} = [cell2mat(centroid'), cell2mat(domino_id')];
           hold on
           handlesPlot = scatter(GlobalPoints(:,1),GlobalPoints(:,2),'x','y','LineWidth',2);
           if isempty(caption) == 0
               handlesText = text(cell2mat(x),cell2mat(y),caption,'color','red','FontWeight', 'bold');
           end
        end
    end
end
