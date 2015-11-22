function [sorted_phi, err_dist_rearranged] = preprocesssubj(subj)
% function dat = preprocesssubj(subj)
% Save result to subj_prep.mat.
% Assuming the data files are named <subj>.mat
% sorted_phi shows the location of the the foveal fixation (in degree)
%err_dist_rearranged is the error associated with each foveal fixation location    

inpFileName =  [subj '.mat'];
s = load(['../data/' inpFileName]);

% Parameters:

dispctr = [512 384];

nBlocks = length(s.expmnt.data);
fprintf('\n***** Found %d blocks for subject %s******\n', nBlocks, subj);

ppd = s.expmnt.ppd; % ppd is unlike to change, but just in case

for blk_ind =1:nBlocks
    
    curData = s.expmnt.data{blk_ind};
    %location of the stimuli relative to the center of the ring
    relative_dotXy = bsxfun(@minus, curData.stim.dotXY(2:end,:,:), dispctr);
    %Where subject chose, relative to the center of the ring
    relative_respXY = curData.clickedLoc(2:end,:,:)-curData.stim.respDotXY(2:end, :,:);
    %RMSE for x and y
    err_dist(:,blk_ind) = sqrt(sum((relative_dotXy - relative_respXY).^2, 2));
    p = s.expmnt.data{blk_ind}.stim.fixPhi;
    phi(blk_ind) = 360-round(180* p/3.14);%flip the y axis
end
%rearange the err matrix to represent Phi in acsending order
[sorted_phi, I] = sort(phi);
for i=1:length(phi)
    err_dist_rearranged(:,i) = err_dist(:,I(i));
end
% figure;
% errorbar(mean(err_dist_rearranged), std(err_dist_rearranged));
% title('RMSE of distance (error)')
% set(gca, 'xTick', 1:nBlocks, 'XTickLabel', sorted_phi)
% xlabel('Fov Fix at')
% ylabel('Error between the location of dot and the answer(in pixels)')
