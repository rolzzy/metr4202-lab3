function [T_Original,T_Delete] = Detect6(dominoStats)
    % Find the frame that detected the maximum amount of dominos
    [max_size, max_index] = max(cellfun('size', dominoStats, 1));
    % Create a X by 2 double containing the coordinates of the dominos
    base_centroid = round(dominoStats{max_index}(:,1:2));
    % Coherence measures the consistency of domino detection
    coherence = zeros(length(base_centroid),7);
    for i = 1:length(dominoStats)
        % If i == max_index, the frame being compared are the same. 
        % Skip the iteration and try again
        if i == max_index
            continue
        else
            % Create a X by 2 double of the coordinates for this frame. 
            centroid = round(dominoStats{i}(:,1:2));
        end
        % Compare the domino readings
        for j = 1:length(base_centroid)
            % Find the index where the same values of the coordinates are
            % stored
            index = find(centroid == base_centroid(j,:));
            if size(index,1) == 1
                if index > length(centroid(:,1))
                    index = index - length(centroid(:,1));
                end
            end
            if ~isempty(index)
                % A domino is detected at the same position
                coherence(j,1) = coherence(j,1)+1;
                coherence(j,6:7) = base_centroid(j,1:2);
                if dominoStats{i}(index(1),3) == dominoStats{max_index}(j,3)
                    % The domino has the same left number
                    coherence(j,2) = coherence(j,2)+1;
                    coherence(j,4) = dominoStats{max_index}(j,3);
                end
                if dominoStats{i}(index(1),4) == dominoStats{max_index}(j,4)
                    % The domino has the same right number
                    coherence(j,3) = coherence(j,3)+1;
                    coherence(j,5) = dominoStats{max_index}(j,4);
                end
            end
        end
    end
    index2 = [];
    for j = 1:length(coherence(:,1))
        if coherence(j,1) < 3
            % The shape is not a domino. Note down the index. 
            index2 = j;
        end
        if coherence(j,2)/coherence(j,1) < 0.75
            % The measurement is inconsistent, meaning the number is a 6
            coherence(j,4) = 6;
        end
        if coherence(j,3)/coherence(j,1) < 0.75
            % The measurement is inconsistent, meaning the number is a 6
            coherence(j,5) = 6;
        end          
    end
    if ~isempty(index2)
        % Delete rows that are not a domino
        coherence(index2,:) = [];
    end
%     for j = 1:length(coherence(:,1))
%         if j > length(coherence(:,1))
%             break
%         end
%         a = find(coherence(:,6:7) == coherence(j,6:7));
%         if size(a,1) ~= 2
%             for k = 1:round(length(a)/2)
%                 if coherence(a(k),2)==0 && coherence(a(k),3)==0
%                     coherence(a(k),:)=[];
%                     j = j+1;
%                 end
%             end
%         end
%     end
    domino_id = cell(length(coherence),1);
    centroid = cell(length(coherence),1);
    caption = cell(length(coherence),1);
    for j = 1:length(coherence(:,1))
        domino_id{j} = [coherence(j,4),coherence(j,5)];
        centroid{j} = [coherence(j,6),coherence(j,7)];
        caption{j} = sprintf('%d | %d', coherence(j,4),coherence(j,5));
    end
    domino_id(cellfun(@(domino_id) isempty(domino_id),domino_id))=[];
    a = cell2mat(domino_id);
    for i = 1:length(domino_id)
        if a(i,1) > a(i,2)
            temp=a(i,1);
            a(i,1)=a(i,2);
            a(i,2)=temp;
        end
    end
    domino_id = mat2cell(a,[ones(1,length(a))],2);
    
    %% Sort Table before creating
    domino_id(cellfun(@(domino_id) isempty(domino_id),domino_id))=[];
    caption(cellfun(@(caption) isempty(caption),caption))=[];
    centroid(cellfun(@(centroid) isempty(centroid),centroid))=[];
    for i = 1:length(domino_id)
    for j = 1:length(domino_id)
        domino_i = cell2mat(domino_id(i));
        domino_j = cell2mat(domino_id(j));
        centroid_i = centroid(i);
        centroid_j = centroid(j);
        caption_i = caption(i);
        caption_j = caption(j);
        if i < j && domino_i(1) > domino_j(1)
            domino_id(i) = mat2cell(domino_j,[1]);
            domino_id(j) = mat2cell(domino_i,[1]);
            centroid(i) = centroid_j;
            centroid(j) = centroid_i;
            caption(i) = caption_j;
            caption(j) = caption_i;
        end
        if i < j && domino_i(1) == domino_j(1) && domino_i(2) > domino_j(2)
            domino_id(i) = mat2cell(domino_j,[1]);
            domino_id(j) = mat2cell(domino_i,[1]);
            centroid(i) = centroid_j;
            centroid(j) = centroid_i;
            caption(i) = caption_j;
            caption(j) = caption_i;
        end
    end
    end        
    %% Create Table
     assignin('base','domino_id',domino_id);
     assignin('base','centroid',centroid);
     assignin('base','caption',caption);
    T_Original = table(domino_id,centroid,caption,'VariableName',{'domino_id' 'centroid' 'caption'});
    u_domino_id = unique(cell2mat(domino_id),'rows','stable');
    a = cell2mat(domino_id);
    b = cell2mat(caption);
    c = cell2mat(centroid);
    if length(u_domino_id) == length(a)
        T_Delete = T_Original;
    else
        for i = 1:length(u_domino_id)
            if u_domino_id(i,:) ~= a(i,:)
                b(i,:) = [];
                c(i,:) = [];
            end
        end
    end
    domino_id2 = cell(length(u_domino_id),1);
    centroid2 = cell(length(u_domino_id),1);
    caption2 = cell(length(u_domino_id),1);
    for j = 1:length(u_domino_id)
        domino_id2{j} = [u_domino_id(j,1),u_domino_id(j,2)];
        centroid2{j} = [c(j,1),c(j,2)];
        caption2{j} = b(j,:);
    end
%     assignin('base','domino_id',domino_id);
%     assignin('base','u_domino_id',u_domino_id);
%     assignin('base','domino_id2',domino_id2);
    %% Match target points

    load('Desired_Positions.mat');
    target_id = Desired_Positions.Domino;
    target_pos = Desired_Positions.Desired_Position;

    % Remove domino values that have not been detected
    MyArray = zeros(10,1);
    for i = 1:length(Desired_Positions.Domino)
        if any(cellfun(@(x) isequal(x, target_id{i}), domino_id2)) == 0
            MyArray(i) = i;
        end
    end

    for i = length(MyArray):-1:1
        if MyArray(i) ~= 0
            target_id{i} = [];
            target_pos{i} = [];
        end
    end
    % Remove empty cells
    target_id(cellfun(@(target_id) isempty(target_id),target_id))=[];
    target_pos(cellfun(@(target_pos) isempty(target_pos),target_pos))=[];
%     assignin('base','target_pos',target_pos);
%     assignin('base','target_id',target_id);
    T_Delete = table(domino_id2,centroid2,caption2,target_pos,target_id,...
        'VariableName',{'domino_id2' 'centroid2' 'caption2' 'target_pos' 'target_id'});
end