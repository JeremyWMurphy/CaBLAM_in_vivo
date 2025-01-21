function[] = cablam_plot_events_b(c1wv,c2wv,g1wv,c1_rates,c2_rates,g1_rates,c1_pks,c2_pks,g1_pks,twv,params)

unstruct(params)

%% normalized mean events for each animal
figure, hold on
plot(twv,normalize(median(c1wv,2),norm_method)','Color',c(1,:))
plot(twv,normalize(median(c2wv,2),norm_method)','Color',c(2,:))
plot(twv,normalize(median(g1wv,2),norm_method)','Color',c(3,:))
xlim(x_cut)
ylim([-0.2 1.2])
ax = gca;
ax.PlotBoxAspectRatio = [1 1.5 1];
ax.YTick = [0 1];
ax.YTickLabel = {'min','max'};
legend({'CaBLAM A','CaBLAM B','GCaMP6s'})
xlabel('Time (Sec)')
f1 = gcf;

%%  median events with shading at 25th and 75 percentiles events for each animal
figure, hold on
plot_barform(twv,c1wv',c(1,:),'mid_qs','median')
plot_barform(twv,c2wv',c(2,:),'mid_qs','median')
plot_barform(twv,g1wv',c(3,:),'mid_qs','median')
xlim(x_cut)
ylim([-0.5 1.5])
ax = gca;
ax.PlotBoxAspectRatio = [1 1.5 1];
xlabel('Time (Sec)')
ylabel('\DeltaL/L or \DeltaF/F')

f4 = gcf;

%%  df/f summary plots
figure, hold on

if rej_otlrs
    [~,outer_fences] = get_fences(c1_pks);
    c1_otlrs = c1_pks>outer_fences(2);
    [~,outer_fences] = get_fences(c2_pks);
    c2_otlrs = c2_pks>outer_fences(2);
    [~,outer_fences] = get_fences(g1_pks);
    g1_otlrs = g1_pks>outer_fences(2);
else
    c1_otlrs = zeros(size(c1_pks));
    c2_otlrs = zeros(size(c2_pks));
    g1_otlrs = zeros(size(g1_pks));
end

dat = [c1_pks(~c1_otlrs); c2_pks(~c2_otlrs); g1_pks(~g1_otlrs)];
grp_ids = [ones(numel(c1_pks(~c1_otlrs)),1); ...
    2*ones(numel(c2_pks(~c2_otlrs)),1); ...
    3*ones(numel(g1_pks(~g1_otlrs)),1)];

clrs = [repmat(c(1,:),numel(c1_pks(~c1_otlrs)),1); ...
    repmat(c(2,:),numel(c2_pks(~c2_otlrs)),1); ...
    repmat(c(3,:),numel(g1_pks(~g1_otlrs)),1)];

swarmchart(grp_ids,dat,[],clrs,'filled','MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.5)

c1_n_otlrs = sum(c1_otlrs);
ot_obj = scatter(linspace(1.1,1.25,c1_n_otlrs),max(c1_pks(~c1_otlrs)),'Marker','o','MarkerFaceColor',c(1,:),'MarkerEdgeColor','r');
alpha(ot_obj,0.3)

c2_n_otlrs = sum(c2_otlrs);
ot_obj = scatter(linspace(2.1,2.25,c2_n_otlrs),max(c2_pks(~c2_otlrs)),'Marker','o','MarkerFaceColor',c(2,:),'MarkerEdgeColor','r');
alpha(ot_obj,0.3)

g1_n_otlrs = sum(g1_otlrs);
ot_obj = scatter(linspace(3.1,3.25,g1_n_otlrs),max(g1_pks(~g1_otlrs)),'Marker','o','MarkerFaceColor',c(3,:),'MarkerEdgeColor','r');
alpha(ot_obj,0.3)

md1 = median(c1_pks);
md2 = median(c2_pks);
md3 = median(g1_pks);

line_len = 0.3;
plot([1-line_len 1+line_len],[md1 md1],'k','LineWidth',1)
plot([2-line_len 2+line_len],[md2 md2],'k','LineWidth',1)
plot([3-line_len 3+line_len],[md3 md3],'k','LineWidth',1)

line_len = 0.15;
c1_ps = prctile(c1_pks,[25 75]);
plot([1 1],c1_ps,'k','LineWidth',1)
plot([1-line_len 1+line_len],[c1_ps(1) c1_ps(1)],'k','LineWidth',1)
plot([1-line_len 1+line_len],[c1_ps(2) c1_ps(2)],'k','LineWidth',1)

c2_ps = prctile(c2_pks,[25 75]);
plot([2 2],c2_ps,'k','LineWidth',1)
plot([2-line_len 2+line_len],[c2_ps(1) c2_ps(1)],'k','LineWidth',1)
plot([2-line_len 2+line_len],[c2_ps(2) c2_ps(2)],'k','LineWidth',1)

g1_ps = prctile(g1_pks,[25 75]);
plot([3 3],g1_ps,'k','LineWidth',1)
plot([3-line_len 3+line_len],[g1_ps(1) g1_ps(1)],'k','LineWidth',1)
plot([3-line_len 3+line_len],[g1_ps(2) g1_ps(2)],'k','LineWidth',1)

ax = gca;

ax.XTick = [1 2 3];
ax.XTickLabel = {'CaBLAM A','CaBLAM B','GCaMP6s'};

ylabel('\DeltaL/L or \DeltaF/F')

ax.PlotBoxAspectRatio = [1 1 1];

ylim([-1 5])

f2 = gcf;

%% rate summary plots

figure, hold on

c1_rates = c1_rates';
c2_rates = c2_rates';
g1_rates = g1_rates';

if rej_otlrs
    [~,outer_fences] = get_fences(c1_rates);
    c1_otlrs = c1_rates>outer_fences(2);
    [~,outer_fences] = get_fences(c2_rates);
    c2_otlrs = c2_rates>outer_fences(2);
    [~,outer_fences] = get_fences(g1_rates);
    g1_otlrs = g1_rates>outer_fences(2);
else
    c1_otlrs = zeros(size(c1_rates));
    c2_otlrs = zeros(size(c2_rates));
    g1_otlrs = zeros(size(g1_rates));
end

dat = [c1_rates(~c1_otlrs); c2_rates(~c2_otlrs); g1_rates(~g1_otlrs)];
grp_ids = [ones(numel(c1_rates(~c1_otlrs)),1); ...
    2*ones(numel(c2_rates(~c2_otlrs)),1); ...
    3*ones(numel(g1_rates(~g1_otlrs)),1)];

clrs = [repmat(c(1,:),numel(c1_rates(~c1_otlrs)),1); ...
    repmat(c(2,:),numel(c2_rates(~c2_otlrs)),1); ...
    repmat(c(3,:),numel(g1_rates(~g1_otlrs)),1)];

swarmchart(grp_ids,dat,[],clrs,'filled','MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.5)

c1_n_otlrs = sum(c1_otlrs);
ot_obj = scatter(linspace(1.1,1.25,c1_n_otlrs),max(c1_rates(~c1_otlrs)),'Marker','o','MarkerFaceColor',c(1,:),'MarkerEdgeColor','r');
alpha(ot_obj,0.3)

c2_n_otlrs = sum(c2_otlrs);
ot_obj = scatter(linspace(2.1,2.25,c2_n_otlrs),max(c2_rates(~c2_otlrs)),'Marker','o','MarkerFaceColor',c(2,:),'MarkerEdgeColor','r');
alpha(ot_obj,0.3)

g1_n_otlrs = sum(g1_otlrs);
ot_obj = scatter(linspace(3.1,3.25,g1_n_otlrs),max(g1_rates(~g1_otlrs)),'Marker','o','MarkerFaceColor',c(3,:),'MarkerEdgeColor','r');
alpha(ot_obj,0.3)

md1 = median(c1_rates);
md2 = median(c2_rates);
md3 = median(g1_rates);

line_len = 0.3;
plot([1-line_len 1+line_len],[md1 md1],'k','LineWidth',1)
plot([2-line_len 2+line_len],[md2 md2],'k','LineWidth',1)
plot([3-line_len 3+line_len],[md3 md3],'k','LineWidth',1)

line_len = 0.15;
c1_ps = prctile(c1_rates,[25 75]);
plot([1 1],c1_ps,'k','LineWidth',1)
plot([1-line_len 1+line_len],[c1_ps(1) c1_ps(1)],'k','LineWidth',1)
plot([1-line_len 1+line_len],[c1_ps(2) c1_ps(2)],'k','LineWidth',1)

c2_ps = prctile(c2_rates,[25 75]);
plot([2 2],c2_ps,'k','LineWidth',1)
plot([2-line_len 2+line_len],[c2_ps(1) c2_ps(1)],'k','LineWidth',1)
plot([2-line_len 2+line_len],[c2_ps(2) c2_ps(2)],'k','LineWidth',1)

g1_ps = prctile(g1_rates,[25 75]);
plot([3 3],g1_ps,'k','LineWidth',1)
plot([3-line_len 3+line_len],[g1_ps(1) g1_ps(1)],'k','LineWidth',1)
plot([3-line_len 3+line_len],[g1_ps(2) g1_ps(2)],'k','LineWidth',1)

ax = gca;

ax.XTick = [1 2 3];
ax.XTickLabel = {'CaBLAM A','CaBLAM B','GCaMP6s'};

ylabel('ROI Event Rate (Hz)')

ax.PlotBoxAspectRatio = [1 1 1];

ylim([-0.01 .05])

f3 = gcf;

%% save figures

if save_figs

    save_pth = ['C:/Users/Jerem/Desktop/cablam_' date '/'];
    if ~exist(save_pth)
        mkdir(save_pth)
    end

    exportfig_jm(f1,[save_pth 'normalized_waves_ex'],1024,1024,'emf')
    exportfig_jm(f4,[save_pth 'waves_error_bars'],1024,1024,'emf')
    exportfig_jm(f2,[save_pth 'snr_swarm'],1024,1024,'emf')
    exportfig_jm(f3,[save_pth 'rate_swarm'],1024,1024,'emf')

end