
function [Optimal_path,D] = calculate_path(T_Original,T_Delete)
%% Sort detected domino's

% for i = 1:length(domino_id)
%     for j = 1:length(domino_id)
%         domino_i = cell2mat(domino_id(i));
%         domino_j = cell2mat(domino_id(j));
%         centroid_i = centroid(i);
%         centroid_j = centroid(j);
%         caption_i = caption(i);
%         caption_j = caption(j);
%         if i < j && domino_i(1) > domino_j(1)
%             domino_id(i) = mat2cell(domino_j,[1]);
%             domino_id(j) = mat2cell(domino_i,[1]);
%             centroid(i) = centroid_j;
%             centroid(j) = centroid_i;
%             caption(i) = caption_j;
%             caption(j) = caption_i;
%         end
%         if i < j && domino_i(1) == domino_j(1) && domino_i(2) > domino_j(2)
%             domino_id(i) = mat2cell(domino_j,[1]);
%             domino_id(j) = mat2cell(domino_i,[1]);
%             centroid(i) = centroid_j;
%             centroid(j) = centroid_i;
%             caption(i) = caption_j;
%             caption(j) = caption_i;
%         end
%     end
% end        
% 
% %% Match target points
% 
% load('Desired_Positions.mat');
% target_id = Desired_Positions.Domino;
% target_pos = Desired_Positions.Desired_Position;
% 
% % Remove domino values that have not been detected
% MyArray = zeros(10,1);
% for i = 1:length(Desired_Positions.Domino)
%     if any(cellfun(@(x) isequal(x, target_id{i}), domino_id')) == 0
%         MyArray(i) = i;
%     end
% end
% 
% for i = length(MyArray):-1:1
%     if MyArray(i) ~= 0
%         target_id{i} = [];
%         target_pos{i} = [];
%     end
% end
% 
% % Remove empty cells
% target_id(cellfun(@(target_id) isempty(target_id),target_id))=[];
% target_pos(cellfun(@(target_pos) isempty(target_pos),target_pos))=[];

%% Construct Table

% T = table(domino_id',centroid',caption',target_pos,target_id,...
%     'VariableNames',{'domino_id' 'centroid' 'caption' 'target_pos' 'target_id'});  
%         
%% Generate Path
[start_position,end_position,D] = decision_algorithm(T_Delete);

% Find start position in T_Delete and extract end position
% for i = 1:length(T_Delete.domino_id2)
%     StartPosCompare = T_Delete(i,2);
%     if round(cell2mat(StartPosCompare.centroid2)/10) == start_position
%         end_position = T_Delete(i,4);
%     end
% end
% end_position = round(cell2mat(end_position.target_pos)/10);
Optimal_path = A_Star3(T_Original.centroid,start_position,end_position);
Optimal_path = Optimal_path*10;