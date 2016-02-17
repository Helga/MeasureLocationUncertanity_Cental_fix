%plot RMSE for all subjects
close all
pre = [1 0]; %pre or post measurement plots
subjs = {'MF', 'SK'};
% subjs = {'TF', 'NA', 'PM'};

clr = ['b', 'r'];
skip_ind = 3;

for s = 1:length(subjs)
    figure;
    %% fake date. Forcing matlab use the same plot range for all the subjects
    entro = 20*ones(1,9);%fake data.
    phi=0:pi/4:2*pi;
    h_fake = polar(phi, entro);hold on
    set(h_fake,'Visible','off');
    %%
    for r=1:2
        if pre(r) == 1
            test = '(pre)';
            subj = subjs{s};
        else
            test = '(post)';
            subj = [subjs{s}, 'P'];
        end
        
        [phi, err] = preprocesssubj(subj);
        mean_err_all(:,s,r) = mean(err);
        std_err_all(:,s,r) = std(err);
        
        phi(end+1)= phi(1);%for plotting. Make sure the curve is a closed loop
        mean_err = mean(err);
        mean_err(end+1) = mean_err(1);
        h(r) = polar(phi, mean_err, [clr(r), '--o']);hold on
        set(h(r), 'lineWidth', 3);
    end
    fig=gcf;
    set(findall(fig,'-property','FontSize'),'FontSize',18)
    %     title(['Location uncertaininty measurements' , subjs{s}])
    
    %     legend([h(1), h(2)], {'pre', 'post'}, 'Location', 'best')
    fname = ['LocationUncert_',  subjs{s}];
    print('-depsc','-r300',['../EPS/' fname, '.eps'])
    
end
temp = mean_err_all(:,:,2);
temp(skip_ind, :) = [];
RMSE = temp(:);

save('../../VSS_res/LocationUncert.mat', 'RMSE', 'subjs');%pre data will be used in GLM analysis



