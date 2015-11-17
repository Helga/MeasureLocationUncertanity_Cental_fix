%function dat = preprocesssubj(subj)
% function dat = preprocesssubj(subj)
% Save result to subj_prep.mat.
% Assuming the data files are named <subj>.mat


subj = 'RM';
inpFileName =  [subj '.mat'];
s = load(['../data/' inpFileName]);

% Parameters:

dispctr = [512 384];

nBlocks = length(s.expmnt.data);
fprintf('\n***** Found %d blocks for subject %s******\n', nBlocks, subj);

ppd = s.expmnt.ppd; % ppd is unlike to change, but just in case

BLOCKS = 1:nBlocks;
for blk_ind =1:length(BLOCKS)
    
    curData = s.expmnt.data{BLOCKS(blk_ind)};
    %location of the stimuli relative to the center of the ring
    relative_dotXy = bsxfun(@minus, curData.stim.dotXY(2:end,:,:), dispctr);
    %Where subject chose, relative to the center of the ring
    relative_respXY = curData.clickedLoc(2:end,:,:)-curData.stim.respDotXY(2:end, :,:);
    %RMSE for x and y
    err_dist(:,blk_ind) = sqrt(sum((relative_dotXy - relative_respXY).^2, 2));
    
end
errorbar(mean(err_dist), std(err_dist))
title('RMSE of distance (error)')
set(gca, 'xTick', 1:5)
xlabel('Blk #')
ylabel('Error between the location of dot and the answer(in pixels)')