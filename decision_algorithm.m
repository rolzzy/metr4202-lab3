function [start_position,end_position,D] = decision_algorithm(T_Delete)
    %% Calculate the distances 
    T = T_Delete;
    CLX1 = T(:,2);
    TP1 = T(:,4);
    j = height(CLX1);
    CLX2 = table2cell(CLX1);
    TP2 = table2cell(TP1);
    TP = cell2mat(TP2);
    CLX = cell2mat(CLX2);
    L = CLX - TP;
    i = 1;
    A = zeros(j,1);
    B = zeros(j,1);
    C = zeros(j,1);
    average_x = zeros(1,1);
    average_y = zeros(1,1);
    SUM = sum(CLX);
    SUMX = SUM(1,1);
    SUMY = SUM(1,2);
    AVGX =(1/j)*SUMX;
    AVGY = (1/j)*SUMY;
    for k=1:height(CLX1)
        distance = [sqrt(L(k,1)^2 + L(k,2)^2)];
        A(k) = distance;
        B(k) = AVGX;
        C(k) = AVGY;
    end
    % Calculate the distance to the centroid
    Xdist = CLX(:,1) - B;
    Ydist = CLX(:,2) - C;
    D = zeros(j,1);
    for q=1:height(CLX1)
        distance2centroid = sqrt(Xdist(q)^2 + Ydist(q)^2);
        D(q) = distance2centroid;
    end   

    %% Choose the domino with the largest distance to the centroid
    for k=1:height(CLX1)
        if (A(k,1) < 20)
            D(k,1) = 0;
        end 
    end

    max_distance = max(D(:));
    [row2 col2] = find(D == max_distance);
    D(row2,:) = 0;
    
    start_position = T(row2,2); % retrieve the domino position to put into goto
    end_position = T(row2,4); % retreive the final position to put into goto
%    check_id = T(row2, 1);
    
    start_position = round(cell2mat(start_position.centroid2)/10);
    end_position = round(cell2mat(end_position.target_pos)/10);
    
end