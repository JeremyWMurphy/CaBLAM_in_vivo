function [] = cablam_postprocess()

data_path = 'C:\Users\Jerem\Desktop\current\cablam\data\processed\24-Sep-2024\';

suffix = '_5Hz_pk.mat';
c1 = load([data_path 'ndnf_cablam_4_processed_data' suffix]);
c2 = load([data_path 'ndnf_cablam_3_processed_data' suffix]);
g1 = load([data_path 'ndnf_37_processed_data' suffix]);

set(0,'DefaultFigureWindowStyle' , 'normal')

c1_run_to_plot = 1;
c2_run_to_plot = 6;
g1_run_to_plot = 1;

% params
params.x_cut = [-6 6]; % clip the waveform plots to this range in seconds
params.bs_sec = [-10 -2]; % baseline events to this range in seconds
params.nrois = 10; % max rois to plot, if total runs < nrois, then plot total runs
clrs = magma(params.nrois);
params.clrs = abs(clrs-0.3); % muddy/darken it a bit
params.t_orig = c1.D{1}.t_wave;
params.Fs = c1.D{c1_run_to_plot}.Fs;
params.pk_toi = [-1 1];
params.save_figs = false;
params.n_smooth = params.Fs;
params.scl = 1; 
params.rej_otlrs = true;
params.sec_to_plot = 300;
params.sz_offset = 5;

%plot individual data figures
[c2wv, ~, c2_rates,c2_pks,c2_rej_rois,c2_n_roi_otlrs] = cablam_plot_events_a(c2,c2_run_to_plot,'cablam 1','ndnf_cablam_3',params);
[c1wv,~,c1_rates,c1_pks,c1_rej_rois,c1_n_roi_otlrs] = cablam_plot_events_a(c1,c1_run_to_plot, 'cablam 2','ndnf_cablam_4',params);
[g1wv,twv,g1_rates,g1_pks,g1_rej_rois,g1_n_roi_otlrs] = cablam_plot_events_a(g1,g1_run_to_plot,'GCaMP6s 1','ndnf_37',params);

%%
params2.c = [200 50 150; 89 50 150; 0 190 50]./256;
params2.save_figs = false;
params2.norm_method = 'range';
params2.x_cut = params.x_cut;
params2.rej_otlrs = true;

% plot summary data figures
cablam_plot_events_b(c1wv,c2wv,g1wv,c1_rates,c2_rates,g1_rates,...
    c1_pks,c2_pks,g1_pks,twv,params2);

%% spit stats
ids = {'cablam_a';'cablam_b';'gcamp6s'};

% peaks
fname = 'C:\Users\Jerem\Desktop\current\cablam\CaBLAM in vivo info.xlsx';
sname = 'peak_stats';
s.ids = ids;
s.dat = {c1_pks,c2_pks,g1_pks};
spit_stats(s,fname,sname)

% rates
fname = 'C:\Users\Jerem\Desktop\current\cablam\CaBLAM in vivo info.xlsx';
sname = 'event_stats';
s.ids = ids;
s.dat = {c1_rates(c1_rates>0),c2_rates(c2_rates>0),g1_rates(g1_rates>0)};
spit_stats(s,fname,sname)

% roi info
tot_rois = [numel(c1_rej_rois)+size(c1_n_roi_otlrs,1); ...
    numel(c2_rej_rois)+size(c2_n_roi_otlrs,1); ...
    numel(g1_rej_rois)+size(g1_n_roi_otlrs,1)];

ded_rois = [numel(c1_rej_rois); ...
    numel(c2_rej_rois); ...
    numel(g1_rej_rois)];

wv_otlrs = [sum(c1_n_roi_otlrs(:,2)); sum(c2_n_roi_otlrs(:,2)); sum(g1_n_roi_otlrs(:,2))];

T = table(ids,tot_rois,ded_rois,wv_otlrs);
writetable(T,fname,'Sheet','roi_info','WriteVariableNames',true);




































