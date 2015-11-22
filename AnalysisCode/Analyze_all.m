%plot RMSE for all subjects 
subjs = {'TF', 'PM'};
figure;hold on;
clr = ['r', 'b', 'g'];
for s = 1:length(subjs)
    [phi, err] = preprocesssubj(subjs{s});
    errorbar(mean(err), std(err),clr(s), 'LineWidth',3);
end
title('Location uncertaininty measurements(pre)')
set(gca, 'xTick', 1:length(phi), 'XTickLabel', phi)
xlabel('Fov fixation location')
ylabel('RMSE(in pixels)')
legend(subjs)
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',16)