function drawStimuli(windowPtr, targSize, targLocation, targInd, targets, fixationLocation)
%

[Targettex, targRecSize] = readStim(targets, targInd, targSize, windowPtr);
targX = targLocation(1);
targY = targLocation(2);

w = targRecSize(3);
h = targRecSize(3);%targRecSize(4);

disScale = 1;
disScale2 = 1.6;

TargetPos = ceil([targX-w/2, targY-h/2,targX+w/2, targY+h/2]);

CircPos = round([targX-disScale*w,targY-disScale*h,targX+disScale*w, targY+disScale*h]);
CircPos2 = round([targX-disScale2*w,targY-disScale2*h, targX+disScale2*w,targY+disScale2*h]);

Screen('FillRect',windowPtr,[127 127 127]);
 Screen('DrawTexture',windowPtr, Targettex,targRecSize,TargetPos);


if exist('fixationLocation', 'var')
    drawCross(windowPtr, fixationLocation, 4,[0 0 0], 4);
end
ringWidth = targSize/6;%max(.1, targSize/5);
Screen('frameoval', windowPtr, [0 0 0], [CircPos' CircPos2'], double(ringWidth));
