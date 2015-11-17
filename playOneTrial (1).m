
show_blank_page = 0;
show_grid = 0;
stimuli_page_on_time = 0;
warningBeep_time = 0;
blank_page_on_time = 0;


% getting ready
if expmnt.useEyeTracker == 1
    Priority(1);
end

oldEyePos = winCenter;
oldDot = winCenter;

FlushEvents('KeyDown');
Screen('FillRect',win,backgroundEntry)
WaitSecs(expmnt.iti);

% at the beginning of the next frame
succ = 0;
keyCode = [];
key_pressed = ' ';

temp = nan;
Snd('Play',expmnt.trialBeep);
trailStartGazeInd = thisGaze;%gaze index when this trial starts

Screen('fillrect', win, backgroundEntry);
trial_start_time = Screen('Flip',win);%mark trial start time

state = 'fixation';
ringRPix = expmnt.ring.R * expmnt.ppd;
dotRPix = expmnt.dot.R * expmnt.ppd;


dotXY = data.stim.dotXY(ii,:);
        
% trial loop: records gaze location constantly and walks through different
% states of a trial. Loop aborts when we reach the last state: "finish"
while strcmp(state, 'finish') == 0
    eyeavail = 0;
    % Get eye coordinates
    if expmnt.useEyeTracker == 1
        err=Eyelink('CheckRecording');
        if(err~=0)
            error('Eyelink not recording eye-position data');
        end
        if Eyelink('NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
             eyeSampleTime = GetSecs;
            elEvent = Eyelink('NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample
                x = elEvent.gx(eye_used+1); % +1 as we're accessing MATLAB array
                y = elEvent.gy(eye_used+1);
                pupilSize = elEvent.pa(eye_used+1);
                % do we have valid data and is the pupil visible?
                if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA && elEvent.pa(eye_used+1)>0.5
                    eyeavail = 1;
                    eyePos = [x, y] ;
                else
                    eyeavail = 0;
                    Screen('FillRect',win,backgroundEntry);
                    Screen('Flip',win);
                    if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA
                        eyePos = [x, y] ;
                    else
                        eyePos = [nan, nan];
                    end
                end
            end
        end
        
    else
        % Query current mouse cursor position (our "pseudo-eyetracker")
        if GetSecs-eyeSampleTime < 0.001 % keep the millisecond rate
            eyeavail = 0;
        else
            % Query current mouse cursor position (our "pseudo-eyetracker")
            eyeavail = 1;
            [eyePos(1), eyePos(2), buttons]=GetMouse;
            pupilSize = 1;
            eyeSampleTime = GetSecs;
        end
    end
  
    gaze_changed = ~isequal(eyePos, oldEyePos);
    
    if eyeavail
        % store the eye position
        gazeSeq(thisGaze,:) = eyePos;
        gazeTime(thisGaze,:) = [nan eyeSampleTime];
        gazePupil(thisGaze,:) = pupilSize;
        gazeStimIdx(thisGaze,1) = ii;
        thisGaze = thisGaze+1;        
        
        % Keep track of last gaze position:
        oldEyePos=eyePos;
       switch state
            case 'fixation' % Local drift correction
                if gaze_changed %% draw the fixation cross and wait until fixated
                    
                    drawCross(win, eyePos, 10,[ 1 0 0]);%TODO: for debugging purpose, need to remove it when subject performs the experiment
                    drawCross(win,[round(fixXY(1)) ,round(fixXY(2))], fixationCross_length, fixationCross_color); %draw the fixation cross
                    fixationCross_page_on_time = Screen('Flip',win);
                    gazeWin = slidingGazeWin(gazeTime(trailStartGazeInd:thisGaze-1, :) , ...
                        gazeSeq(trailStartGazeInd:thisGaze-1,:), expmnt.slidingWinWid);%sliding gaze window
                    medianGaze = median(gazeWin);%
                    gazeWin_std = std(gazeWin);
                    %             msg{15} = ['median gaze = ', num2str(medianGaze)];
                    %             giveInstruction(win,msg,textEntry,backgroundEntry);
                    %             normD(thisGaze) =  norm(medianGaze - winCenter)
                    %             GW(thisGaze, :, :) = gazeWin;
                    if  sum(isnan(medianGaze)) ==0  && norm(gazeWin_std) < expmnt.stable_gaze_std ...%is the gaze stable?
                            && norm(medianGaze - fixXY) < expmnt.stable_gaze_thresh %is the subject actually looking at the fixation?                        
                        state = 'blank';
                        est_drift = double(medianGaze- fixXY);                                              
                        state = 'show_stimuli';
                        est_drift = double(medianGaze- fixXY);                        
                        
                    end
                end
           case 'show_stimuli'
               
%                dotXY = data.stim.dotXY(ii,:) + (eyePos - fixXY); %gaze zontingent
               dotXY = data.stim.dotXY(ii,:); %non-gaze zontingent

               dotRec = round([dotXY(1)-dotRPix, dotXY(2)-dotRPix,dotXY(1)+dotRPix, dotXY(2)+dotRPix]);
               
%                ringCenterXY = winCenter + (eyePos - fixXY); %gaze zontingent
               ringCenterXY = winCenter ; %non-gaze zontingent
               ringRec = round([ringCenterXY(1)-ringRPix,ringCenterXY(2)-ringRPix,ringCenterXY(1)+ringRPix, ringCenterXY(2)+ringRPix]);
           
               drawCross(win, eyePos, 10,[ 1 0 0]);%TODO: for debugging purpose, need to remove it when subject performs the experiment
               drawCross(win,[round(fixXY(1)) ,round(fixXY(2))], fixationCross_length, fixationCross_color); %draw the fixation cross
           
               Screen('frameoval', win, expmnt.ring.color, ringRec, expmnt.ring.width);%draw the ring
               Screen('filloval', win, expmnt.dot.color, dotRec);%draw the dot
                   temp = Screen('Flip',win);
               if stimuli_page_on_time == 0
                   stimuli_page_on_time = temp;
               elseif (GetSecs - stimuli_page_on_time > expmnt.stimuli_display_time)
                   state ='blank';
               end
       
            case 'blank'
                if blank_page_on_time == 0 %show the blank page if this is the first time we hit here
                    Screen('fillrect', win, backgroundEntry);
                    blank_page_on_time = Screen('Flip',win);
                elseif (GetSecs - blank_page_on_time > expmnt.blank_page_display_time) && (warningBeep_time == 0)
                    Snd('Play', expmnt.targetDisplayBeep);% warning beep goes off after a delay
                    warningBeep_time = GetSecs;
                    state ='show_resp_page';                    
                end
           
            case 'show_resp_page'
                space_is_pressed = 0;
                %  nClicks = 0;     
                HideCursor
%                 SetMouse(winCenter(1), winCenter(2));
                respDotXY = data.stim.respDotXY(ii,:);

                dotRec = round([respDotXY(1)-dotRPix, respDotXY(2)-dotRPix, respDotXY(1)+dotRPix, respDotXY(2)+dotRPix]);
                ringRec = round([respDotXY(1)-ringRPix, respDotXY(2)-ringRPix, respDotXY(1)+ringRPix, respDotXY(2)+ringRPix]);
                
                Screen('frameoval', win, expmnt.ring.color, ringRec, expmnt.ring.width);%draw the ring
                Screen('filloval', win, expmnt.dot.color, dotRec);%draw the dot
                resp_page_on_time = Screen('Flip',win);
%                 ShowCursor('Arrow');
                while ~space_is_pressed
                    [newDot(1),newDot(2), ~] = GetMouse;
                    if ~isequal(oldDot, newDot)
%                         ringRec = round([newDot(1)-ringRPix, newDot(2)-ringRPix, newDot(1)+ringRPix, newDot(2)+ringRPix]);
                        Screen('frameoval', win, expmnt.ring.color, ringRec, expmnt.ring.width);%draw the ring
                        dotRec = round([newDot(1)-dotRPix, newDot(2)-dotRPix, newDot(1)+dotRPix, newDot(2)+dotRPix]);
                        Screen('filloval', win, expmnt.dot.color, dotRec);%draw the dot
                        Screen('Flip',win)
                        oldDot = newDot;
                    end
                     [keydown, ~, keyCode] = KbCheck;
                     if keydown && keyCode(KbName('Space')) %subject pressed space, end of trial
                         space_is_pressed = 1;
                         [dot_x, dot_y, ~] = GetMouse;
                     end
                end

                
%                 while ~space_is_pressed
%                     [dot_x, dot_x, nClicks, space_is_pressed] = waitForClick(nClicks);
%                     Screen('frameoval', win, expmnt.ring.color, ringRec, expmnt.ring.width);%draw the ring
%                     dotRec = round([dot_x-dotRPix, dot_y-dotRPix, dot_x+dotRPix, dot_y+dotRPix]);
%                     Screen('filloval', win, expmnt.dot.color, dotRec);%draw the dot
%                     Screen('Flip',win)
%                 end
                
                
                    state = 'finish';
                    trial_end_time = GetSecs;
                    Snd('Play',expmnt.acquiredBeep);

           otherwise
               error('Unknown state!');
       end
    end
    
end

data.est_drift(ii,:) = est_drift;
data.std(ii,:) = gazeWin_std;
data.timing.black_page_on_time(ii) = blank_page_on_time;
data.timing.warningBeep_time(ii) = warningBeep_time;
data.timing.trial_start_time(ii) = trial_start_time;
data.timing.trial_end_time(ii) = trial_end_time;
data.timing.fixationCross_page_on_time(ii) = fixationCross_page_on_time;
data.timing.resp_page_on_time(ii) = resp_page_on_time;
data.timing.stimuli_page_on_time(ii) = stimuli_page_on_time;
data.clickedLoc(ii,:) = [dot_x, dot_y];
Priority(0);


