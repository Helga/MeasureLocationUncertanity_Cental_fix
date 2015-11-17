% function [x, y, nClicks, return_is_pressed] = waitForClick( nClicks)
% 
% %Draws all the candidate letters on the screen in a grid. The letter
% %that subject selected, (key_pressed), is marked by a rectangle around it
% 
% % History: July 10, 2014 created by HM
% % ShowCursor('Arrow');
% % return_is_pressed = 0;
% 
% 
% interClickSecs = .5;%500 msec
% return_is_pressed = 0;
% 
% % while ~return_is_pressed
% 
% keydown = 0;
% buttons = 0;
% while ~keydown && ~any(buttons)
%     %do nothing
%     [keydown, ~, keyCode] = KbCheck;
%     
%     [x,y,buttons] = GetMouse;
% end
% 
% if keydown %keyboard is used to select the target letter
%     
%     %     if keyCode(KbName('Escape'))
%     %         cleanup;
%     %         break
%     %     end
%     if keyCode(KbName('Return'))
%         return_is_pressed = 1;
%     end
% else
%     nClicks = nClicks + 1;
%     
%     % Wait for further click in the timeout interval.
%     tend=GetSecs + interClickSecs;
%     while GetSecs < tend
%         % If already down, wait for release...
%         while any(buttons) && GetSecs < tend
%             [x,y,buttons] = GetMouse;
%         end;
%         
%         % Wait for a press or timeout:
%         while ~any(buttons) && GetSecs < tend
%             [x,y,buttons] = GetMouse;
%             
%         end;
%         
%         % Mouse click or timeout?
%         if any(buttons) && GetSecs < tend
%             % Mouse click. Count it.
%             nClicks=nClicks+1;
%             if  nClicks == 2
%                 return_is_pressed = 1;
%                 break;
%             end;
%         else
%             nClicks = 0;
%         end
%         
%     end;
% end
% 
% FlushEvents('KeyDown');
% 
% % end
% % HideCursor;
% 
