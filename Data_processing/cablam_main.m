function[] = cablam_main()

id = 'ndnf_37'; ...'ndnf_cablam_3','ndnf_cablam_4'  
exp_date = '20240501'; ...'20231204','20231121'
pth = 'C:\Users\Jerem\Desktop\current\cablam\data\';

params = cablam_set_params();
% add some subject specific parameters
params.Fs = 10; % GCaMP ndnf_36 = 10; CaBLAM ndnf_cablam_3 = 10; CaBLAM ndnf_cablam_4 = 5; 
params.indicator = 'GCaMP'; ... 'CaBLAM'

fprintf(['\nDoing ' id])

pth_nfo = dir([pth id '\' exp_date '\']);

% get teensy data (frames, stim times, etc.)
fprintf('\nReading Teensy Data')
cablam_teensy_data_proc(pth_nfo)
   
% read in tiffs and do minimal pre-processing of images
fprintf('\nReading image Data')
cablam_data_import(pth,pth_nfo,params)

% use functions from min1pipe for denoising
fprintf('\nmin1pipe Denoising')
cablam_min1pipe_denoise(pth_nfo,params)
   
% hand segment rois and get tseries
cablam_make_rois(pth_nfo,params);
    
% do find events, etc.
cablam_process(pth_nfo,params);

%% post porcessing/plotting for all animals

cablam_postprocess()
cablam_evoked_postprocess()

