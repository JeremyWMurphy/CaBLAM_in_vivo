function [params] = cablam_set_params()

params.do_resample = true; % downsample the data to 'nfs'
params.nfs = 5; % sample rate to downsample to 
params.bin_to = 256; % spatial binning to this size (e.g., 256 = 256 x 256 images)

% event detection stuff
params.wv_pre_post = [-10 10]; % window around an event to extract, in sec
params.thresh_val = 1.5; %
params.rr_thresh = 5; %

% stim epoching stuff
params.stim_pre_post = [-5 10];

params.save_pth = ['C:\Users\Jerem\Desktop\current\cablam\data\processed\' date '\'];

