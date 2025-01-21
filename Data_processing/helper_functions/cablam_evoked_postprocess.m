function [] = cablam_evoked_postprocess()

data_path = 'C:\Users\Jerem\Desktop\current\cablam\data\processed\16-Oct-2024\';

fig_save_pth = ['C:/Users/Jerem/Desktop/cablam_' date '/'];
if ~exist(fig_save_pth)
    mkdir(fig_save_pth)
end

suffix = '_5Hz_pk.mat';
c1 = load([data_path 'ndnf_cablam_4_processed_data' suffix]);
c2 = load([data_path 'ndnf_cablam_3_processed_data' suffix]);
g1 = load([data_path 'ndnf_37_processed_data' suffix]);

set(0,'DefaultFigureWindowStyle' , 'normal')

c = [200 50 150; 89 50 150; 0 190 50]./256;
%%

params.bs_lims = [-3 0];
params.Fs = 5;
params.elim_short_isi = false;
params.isi_cut = [0 0];
params.rej_out = false;
params.smooth_len = 1;
params.x_lim = [-3 10];

%%

c1_run = 1;
c1_roi = 6;

[ep_mus,ep_trls,ep_ids,ep_n_rej,t] = cablam_evoked(c1,params);

run_trl = ep_trls{c1_run};
run_trl_mus = cellfun(@(x) mean(x,2),run_trl,'UniformOutput',false);
run_trl_mus = [run_trl_mus{:}];

% across rois

go_on = true;
while go_on
    yy = max(run_trl_mus);
    thresh = mean(yy) + 3*std(yy);
    bts = find(yy>thresh);
    run_trl_mus(:,bts) = [];
    if isempty(bts)
        go_on = false;
    end
end

[~,ix] = sort(max(run_trl_mus),'descend');

figure
imagesc(t,1:size(run_trl_mus,2),run_trl_mus(:,ix)')
clim([0 .1]);
xlim(params.x_lim)
xlim(params.x_lim)
colormap(viridis)
colorbar
ax = gca;
ax.DataAspectRatio = [1 5 1];
colormap(viridis)
colorbar
ylabel('ROI')
xlabel('Time (Sec)')

%exportfig_jm(gcf,[fig_save_pth 'c1_evoked_stack_ex'],1024,1024,'emf')

figure 
hold on
plot_barform(t,run_trl_mus',c(1,:),'ci_bt','mean')
xlim(params.x_lim)
ax = gca;
ax.PlotBoxAspectRatio = [1 .5 1];
ylim([-0.02 0.1])
%exportfig_jm(gcf,[fig_save_pth 'c1_evoked_waves_ex'],1024,1024,'emf')

% numbers
idx_post_stim = t>0;
zidx = find(t == 0);
[pk,srm] = max(run_trl_mus(idx_post_stim,:));

srm = t(srm + zidx);
 
median(srm)
iqr(srm)

median(pk)
iqr(pk)


% single roi
x = ep_trls{c1_run}{c1_roi};

[~,ix] = sort(max(x),'descend');
x = x(:,ix);

% single roi
figure
imagesc(t,1:size(x,2),x')
clim([0 1]);
xlim(params.x_lim)
colormap(viridis)
colorbar
axis square
ylabel('Trial')
xlabel('Time (Sec)')
ax = gca;
ax.PlotBoxAspectRatio = [1 .5 1];
%exportfig_jm(gcf,[fig_save_pth 'c1_evoked_stack_singleROI_ex'],1024,1024,'emf')

figure
hold on
plot_barform(t,x',c(1,:),'ci_bt','mean')
xlim(params.x_lim)
ax = gca;
ax.PlotBoxAspectRatio = [1 .5 1];
ylim([-0.15 0.4])
%exportfig_jm(gcf,[fig_save_pth 'c1_evoked_wave_singleROI_ex'],1024,1024,'emf')

%%

c2_run = 6;
c2_roi = 1; 

[ep_mus,ep_trls,ep_ids,ep_n_rej,t] = cablam_evoked(c2,params);

run_trl = ep_trls{c2_run};
run_trl_mus = cellfun(@(x) mean(x,2),run_trl,'UniformOutput',false);
run_trl_mus = [run_trl_mus{:}];

go_on = true;
while go_on
    yy = max(run_trl_mus);
    thresh = mean(yy) + 3*std(yy);
    bts = find(yy>thresh);
    run_trl_mus(:,bts) = [];
    if isempty(bts)
        go_on = false;
    end
end

[~,ix] = sort(max(run_trl_mus),'descend');

figure
imagesc(t,1:size(run_trl_mus,2),run_trl_mus(:,ix)')
clim([-0.05 0.05]);
xlim(params.x_lim)
colormap(viridis)
colorbar

ylabel('ROI')
xlabel('Time (Sec)')
%exportfig_jm(gcf,[fig_save_pth 'c2_evoked_stack_ex'],1024,1024,'emf')

figure
hold on
plot_barform(t,run_trl_mus',c(2,:),'ci_bt','mean')

% numbers
idx_post_stim = t>0;
zidx = find(t == 0);
[pk,srm] = max(run_trl_mus(idx_post_stim,:));

srm = t(srm + zidx);
 
median(srm)
iqr(srm)

median(pk)
iqr(pk)

% single roi
x = ep_trls{c2_run}{c2_roi};

[~,ix] = sort(max(run_trl_mus),'descend');

figure
imagesc(t,1:size(x,2),x')
clim([-.5 .5]);
xlim(params.x_lim)
colormap(viridis)
colorbar
axis square
ylabel('Trial')
xlabel('Time (Sec)')
%exportfig_jm(gcf,[fig_save_pth 'c1_evoked_stack_singleROI_ex'],1024,1024,'emf')

figure
hold on
plot_barform(t,x',c(1,:),'ci_bt','mean')
xlim(params.x_lim)

%%

g1_run = 1;

[ep_mus,ep_trls,ep_ids,ep_n_rej,t] = cablam_evoked(g1,params);

run_trl = ep_trls{g1_run};
run_trl_mus = cellfun(@(x) mean(x,2),run_trl,'UniformOutput',false);
run_trl_mus = [run_trl_mus{:}];

go_on = true;
while go_on
    yy = max(run_trl_mus);
    thresh = mean(yy) + 3*std(yy);
    bts = find(yy>thresh);
    run_trl_mus(:,bts) = [];
    if isempty(bts)
        go_on = false;
    end
end

[~,ix] = sort(max(run_trl_mus),'descend');

figure
imagesc(t,1:size(run_trl_mus,2),run_trl_mus(:,ix)')
clim([0 .1]);
xlim(params.x_lim)
colormap(viridis)
colorbar
ax = gca;
ax.PlotBoxAspectRatio = [1 .5 1];
ylabel('ROI')
xlabel('Time (Sec)')
%exportfig_jm(gcf,[fig_save_pth 'g1_evoked_stack_ex'],1024,1024,'emf')

figure, hold on
plot_barform(t,run_trl_mus',c(3,:),'ci_bt','mean')
xlim(params.x_lim)
axis square
ylim([-0.03 0.38])
xlabel('Time (Sec)')
ax = gca;
ax.PlotBoxAspectRatio = [1 .5 1];
%exportfig_jm(gcf,[fig_save_pth 'g1_evoked_waves_ex'],1024,1024,'emf')

% numbers
idx_post_stim = t>0;
zidx = find(t == 0);
[pk,srm] = max(run_trl_mus(idx_post_stim,:));

srm = t(srm + zidx);
 
median(srm)
iqr(srm)

median(pk)
iqr(pk)

% single roi
g1_roi = 11; 
x = ep_trls{g1_run}{g1_roi};
[~,ix] = sort(max(x),'descend');
x = x(:,ix);

figure
imagesc(t,1:size(x,2),x')
clim([0 5]);
xlim(params.x_lim)
colormap(viridis)
colorbar
axis square
ylabel('Trial')
xlabel('Time (Sec)')
ax = gca;
ax.PlotBoxAspectRatio = [1 .5 1];
%exportfig_jm(gcf,[fig_save_pth 'g1_evoked_stack_singleROI_ex'],1024,1024,'emf')

figure
hold on
plot_barform(t,x',c(3,:),'ci_bt','mean')
xlim(params.x_lim)
ylim([-0.1 1.2])
xlabel('Time (Sec)')
ax = gca;
ax.PlotBoxAspectRatio = [1 .5 1];
%exportfig_jm(gcf,[fig_save_pth 'g1_evoked_wave_singleROI_ex'],1024,1024,'emf')


