function[wv_stack,t_wv,wv_rates,wv_pks,rej_rois,n_roi_otlrs] = cablam_plot_events_a(M,rtp,subj,do_who,params)

unstruct(params);

% get data time series, smooth, and z-score
M_ts = smoothdata(M.D{rtp}.tseries,1,'movmean',n_smooth);
M_ts = zscore(M_ts);

%% ---Align, baseline and sort calcium events--- %%

% the wave data
wvs = M.D{rtp}.waves;
wv_nfo = M.D{rtp}.wv_nfo;

t_wv = x_cut(1):1/Fs:x_cut(2);
win_idxs = x_cut(1)*Fs:x_cut(2)*Fs;
bs_idx = t_wv>=bs_sec(1) & t_wv<=bs_sec(2);

% variable to be filled
wv_stack = [];
wv_ids = [];
wv_rates = [];
wv_bses = [];
wv_pks = [];
wv_roi_pks = [];
n_roi_otlrs = [];
rej_rois = [];
for i = 1:size(wvs,2) % for each ROI

    tmp = wvs{i};

    if isempty(tmp) % some rois have no detected events, skip them
        rej_rois = [rej_rois; i];
        continue
    end

    % smooth waves
    tmp = smoothdata(tmp,1,'movmean',n_smooth);

    tmp2 = [];
    for j = 1:size(tmp,2) % for each wave

        wv_tmp = tmp(:,j); % pull single wave
        wv_tmp = wv_tmp(find(t_orig==0)+win_idxs); % cut down to chosen time window
        wv_bs = mean(wv_tmp(bs_idx)); % get the average in the chosen baseline period
        wv_bses = [wv_bses;wv_bs]; % collect the baselines

        % df/f
        wv_tmp = wv_tmp - wv_bs;
        wv_tmp = wv_tmp./wv_bs;

        % collect the trimmed, baselined waves for this roi
        tmp2 = cat(2,tmp2,wv_tmp);

    end

    if rej_otlrs % remove outliers?

        mx_tmp = max(tmp2); % maximums of all wave values
        [~,outer_fences] = get_fences(mx_tmp);
        otlrs = mx_tmp < outer_fences(1) | mx_tmp > outer_fences(2);
        tmp2(:,otlrs) = [];
        n_roi_otlrs = [n_roi_otlrs; [length(otlrs) sum(otlrs) sum(otlrs)./length(otlrs)]];

    end

    % add this roi's waves to a stack
    wv_stack = [wv_stack tmp2];

    % collect peak data
    mx = max(tmp2(t_wv>=pk_toi(1) & t_wv<=pk_toi(2),:));
    wv_pks = [wv_pks; mx'];
    % and keep track of which roi it came from
    wv_ids = [wv_ids; i*ones(size(tmp2,2),1)];

    % the rate for this roi -- number events/record length (Hz)
    wv_rates(i) = size(tmp2,2)./(size(M_ts,1)./Fs);
    % average event peak for this roi
    wv_roi_pks(i) = mean(mx);

end

% if I want to scale this up to percent change I will have set scl to 100 above
% scale the waves if so desired
wv_stack = wv_stack.*scl;

% pick 'best' roi subset to plot
% sort by mean roi peaks weighted by rate
[~,roi_pk_ix] = sort(wv_roi_pks.*wv_rates,'descend');
zero_rois = find(wv_roi_pks(roi_pk_ix)==0);
roi_pk_ix(zero_rois) = [];

% if we've chosen too many rois too plot, set rois to plot to total rois
if numel(roi_pk_ix)<nrois
    nrois = numel(roi_pk_ix);
    clrs = magma(nrois);
    clrs = abs(clrs-0.3); % muddy/darken it a bit
end
rix = roi_pk_ix(1:nrois);

%% ---mark roi images based on selected time series--- %
f1 = figure; hold on

msk = M.D{rtp}.mask;
img_mu = M.D{rtp}.im_mu;

% mean image
im = bsxfun(@minus,img_mu,median(img_mu));
im = normalize(im(:),'range');
im = reshape(im,size(img_mu));
im = imadjust(im,[0.2 0.8]);

imagesc(im)
axis xy
colormap(gray)
axis equal
axis off

% draw rois
for i = 1:nrois
    tmp = msk==rix(i);
    tmp2 = bwboundaries(tmp);
    plot(tmp2{1}(:,2),tmp2{1}(:,1),'Color',clrs(i,:),'LineWidth',1)
end

%% ---make time series stack--- %
f2 = figure; hold on

tseries_sort = M_ts(:,rix);

% move through time series in windows of sec_to_plot and steps of 1 sec and
% look for the most 'active' segment
n_to_plot = sec_to_plot*Fs;
win_step = Fs;
win_shift = 0;
all_ixs = [];
not_to_far = true;
rms_mu = [];
while not_to_far

    ixs = (1:n_to_plot) + win_shift;    
    
    if any(ixs>size(tseries_sort,1))
        not_to_far = false;
        continue;
    end

    tmp = tseries_sort(ixs,:);
    rms_mu = [rms_mu; mean(rms(tmp))];

    win_shift = win_shift + win_step;
    all_ixs = [all_ixs; ixs];

end

[~,rms_mx_ix] = max(rms_mu);
the_ixs = all_ixs(rms_mx_ix,:);
tseries_sort = tseries_sort(the_ixs,:);
tseries_t = 1/Fs:1/Fs:size(tseries_sort,1)/Fs;

offset = linspace(size(tseries_sort,2)*sz_offset,0,size(tseries_sort,2));
tseries_offset = bsxfun(@plus,tseries_sort,offset);
plot(tseries_t,tseries_offset);
colororder(clrs)
xlabel('Time (Sec)')
xlim([tseries_t(1) tseries_t(end)])
ax = gca;
ax.XTick = 0:10:n_to_plot/Fs;

% mark detected events
for i = 1:nrois
    idxs = wv_nfo{rix(i)}(:,4);
    idxs(isnan(idxs)) = [];
    idxs(idxs<the_ixs(1) | idxs>the_ixs(end)) = [];
    idxs = idxs-the_ixs(1);
    plot(tseries_t(idxs),tseries_offset(idxs,i)+1,'.k')
end

ax.PlotBoxAspectRatio = [1.5 1 1];

%% ---make wave stack--- %

% sort events by max
wv_stack_sort = [];
wv_ids_sort = [];
for i = 1:length(rix)
    this_wv = wv_ids == rix(i);
    tmp = wv_stack(:,this_wv);
    wv_stack_sort = [wv_stack_sort tmp];
    wv_ids_sort = [wv_ids_sort; i*ones(sum(this_wv),1)];
end

f3 = figure;
hold on
ax1 = subplot(1,6,1);
imagesc(wv_ids_sort);
grid on
axis off
ax2 = subplot(1,6,2:6);
imagesc(t_wv,1:size(wv_stack_sort,1),wv_stack_sort');
colorbar
clim([0 1])
xlim(x_cut)
xlabel('Time (Sec)')
title([subj ', run ' num2str(rtp)])
ax1.PlotBoxAspectRatio = [1 50 1];
ax2.PlotBoxAspectRatio = [1 2 1];
colormap(ax2,'viridis')
colormap(ax1,clrs)
ax2.YTick = [];

% plot individual and median waves
f4 = figure;
hold on
plot(t_wv,wv_stack_sort,'Color',[.6 .6 .6])
plot(t_wv,median(wv_stack_sort,2,'omitnan'),'Color',[1 0.3 0])
ax = gca;
ax.PlotBoxAspectRatio = [1 2 1];
xlabel('Time (Sec)')
if strcmp(do_who,'ndnf_cablam_4') || strcmp(do_who,'ndnf_cablam_3')
    ylabel('\DeltaL/L')
else
    ylabel('\DeltaF/F')
end
title(subj)
xlim(x_cut)
%ylim([-1 2])

F = [];
F(1) = f1;
F(2) = f2;
F(3) = f3;
F(4) = f4;

if save_figs

    subj = strrep(subj,' ', '_');
    save_pth = ['C:/Users/Jerem/Desktop/cablam_' date '/'];
    if ~exist(save_pth)
        mkdir(save_pth)
    end
    exportfig_jm(f1,[save_pth 'mean_image_roi_' subj],1024,1024,'emf')
    exportfig_jm(f2,[save_pth 'trace_stack_' subj],1024,1024,'emf')
    exportfig_jm(f3,[save_pth 'wave_stack_' subj],1024,1024,'emf')
    exportfig_jm(f4,[save_pth 'waves_' subj],1024,1024,'emf')

end
