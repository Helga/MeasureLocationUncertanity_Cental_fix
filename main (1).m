%
% Main routine for measuring location uncertainty
%
% NOTE: This code uses Psychtoolbox 3.x
% History: Sep 22, 2015 created by HM

clear all
clear mex
KbName('UnifyKeyNames');

%%%% comment out this line when runing real experiment
%initScreenBypassDisplaySettingCheck = 1;
addpath('../Palamedes/');
expmnt.task = 'Location uncertainty measurement';
expmnt.subj = input('Subj ID:','s');
expmnt.DomEye = input('Dominant eye(R or L):','s');
dataFileName       = [expmnt.subj '.mat']; % experiment parameters + response data
eyeTrackerBaseName = [expmnt.subj]; % eyetracker data
bkupFileName       = [expmnt.subj '_backup.mat']; % backup file

if ~exist(dataFileName,'file')
    %%% NEW SUBJECT %%%
    %%% All experimental parameters should be listed here.
    %%% They should not be anywhere else in the code.
    
    % The display
    expmnt.ppd = 26.36; % pixels per degree
    expmnt.screenRect = [0 0 1024 768];
    
    expmnt.bgColor = [127 127 127];
    expmnt.refreshRate =85; %Hz
   
    % The fixation
    expmnt.nTrial = 10; % trial per block. 
    expmnt.nFixLocations = 8;
    d = 2*pi/expmnt.nFixLocations;
    
    %location of the eccentric fixation each block
    expmnt.fixationLocations_Phi = Shuffle(0:expmnt.nFixLocations-1) * d;
    expmnt.fix.R =  5; %degree, radius from center of the screen    
    expmnt.fixationCross.color =  [0 255 0];
    expmnt.fixationCross.length = 1;%in degrees.
    
    %probe dot and its surrounding circle
    expmnt.dot.R = .2;%in degrees.
    expmnt.dot.color = [0 0 0];    
    expmnt.ring.R = 2;
    expmnt.ring.color = [0 0 0];
    expmnt.ring.width = 1;

    % Trials and Blocks
    expmnt.nSuperBlock = inf; % no end point
    expmnt.plan = addSuperBlock(expmnt);
    expmnt.thisBlock = 1;
    
    % The game
    expmnt.mxTrialDur = 120; %second, maximum trial duration
    expmnt.fixationBlock_duration = 10; %second, trial duration for fixation at the beginning of each block
    expmnt.stable_gaze_std = norm(15, 15); %when std of gaze location is below this value, we consider it as a stable gaze
    expmnt.iti = .5; %second, inter-trial interval
    expmnt.trialBeep = sin(2*pi*0.06*(0:500)); % a new trial
    expmnt.acquiredBeep  = sin(2*pi*0.037*(0:900)); % target acquired
    expmnt.missedBeep  = [sin(2*pi*0.01*(0:2000)) zeros(1,1000) sin(2*pi*0.01*(0:2000))]; % target missed
    expmnt.targetDisplayBeep = sin(2*pi*0.05*(0:4000));
    expmnt.blank_page_display_time = .5;
    expmnt.stimuli_display_time = .150;
    expmnt.slidingWinWid = 2;%in seconds
    expmnt.stable_gaze_thresh = expmnt.ppd; %is the gaze location close enough to the fixation point?

    expmnt.data = {};
    expmnt.bestTime = inf;
    
    % Eye tracking
    expmnt.useEyeTracker = 1; % real eyetracker (set to 0 for mouse)
    expmnt.eyeCalInterval = 5; % in number of blocks
    expmnt.eyeCal = []; % blocks that started with eye tracker calibration
    
    % Misc
    expmnt.expDuration = 1;
    expmnt.instructFont = 'Courier';
    expmnt.instructSize = 24;    
    expmnt.instructColor = [0 0 0];    
    expmnt.saveInterval = 0; % how often data is saved. 0 means every block will be saved
    
    % Initialize rand and randn
    expmnt.randState = sum(100*clock);
    expmnt.randnState = sum(100*clock);
    
else
    % Files associated with the subject
    % if a data file already exists for this subject, continue
    % from the point the subject left off
    load(dataFileName);
    rand('state',expmnt.randState);   % recover the last rand & randn
    randn('state',expmnt.randnState); % states from previous run
end

% pre-allocate space for storing gaze sequence information
% 1st column stores x position, 2nd column y position
maxGazeIter = 2^ceil(log(expmnt.mxTrialDur*(expmnt.nTrial+5)*1000)/log(2)); % length of the gaze record, at the rate 1 per ms
gazeSeq = single(zeros(maxGazeIter,2));
gazeTime = double(zeros(maxGazeIter,2));
gazePupil = single(zeros(maxGazeIter,1));
gazeStimIdx = uint16(zeros(maxGazeIter,1));

lastEyeCalBlk = -inf;
lastSavedBlk = -inf;

% initalize screen and screen-related parameters
initScreen; % screen will go blank at this point (bad if you are debugging)
%%% RUN THE EXPERIMENT
sessionStart = clock;
done = 0; % this flag is set within 'runBlock' if the subject wants to quit

while (~done)
    if expmnt.plan(end,1) < expmnt.thisBlock
        expmnt.plan = [expmnt.plan;addSuperBlock(expmnt)];
    end
    runBlock; % also save data for record and recovery
end;
%%% BOOK KEEPING AND CLEANUP
sessionStop = clock;
sessionDur = etime(sessionStop, sessionStart);
expmnt.expDuration = expmnt.expDuration + sessionDur;
msg = {};
msg{1} = sprintf('Session Duration: %d minutes', round(sessionDur/60));
msg{3} = sprintf('Backing up data ... ');
giveInstruction(win,msg,textEntry,backgroundEntry);
save(bkupFileName, 'expmnt');
save(dataFileName, 'expmnt');
msg{4} = 'Done!';
giveInstruction(win,msg,textEntry,backgroundEntry);
WaitSecs(0.5)
cleanup;

