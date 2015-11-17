function plan = addSuperBlock(expmnt)
% Extend the existing plan by one superblock. Return the extended plan
% plan = [blk,fixLocPhi, dot_XY, jitter] 
%jitter: Location of the dot in the response page relative to the center
%of the screen

numRep = expmnt.nTrial;
fixLocPhi = expmnt.fixationLocations_Phi;
nBlocks = length(fixLocPhi);
plan = [];
for b = 1:nBlocks
    dot_XY = expmnt.ring.R/5 * expmnt.ppd .*randn(numRep, 2);
    blk = ones(numRep, 1) * b;
    locNum = ones(numRep, 1)*fixLocPhi(b);
    jitter = 100*rand(numRep,2);%jitter from the center of the screen. Location of the dot in the response page
    temp = [blk(:), locNum(:), dot_XY, jitter];
    plan = [plan;temp];    
    
end
if isfield(expmnt, 'plan')
    plan(:,1) = plan(:,1) + expmnt.plan(end, 1);
end