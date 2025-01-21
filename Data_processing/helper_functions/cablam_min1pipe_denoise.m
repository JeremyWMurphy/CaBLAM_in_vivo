function cablam_min1pipe_denoise(pth_nfo,Params)

% this is a wrapper for several functions contained in the min1pipe toolbox
%
% https://github.com/JinghaoLu/MIN1PIPE
%
% Lu, J., Li, C., Singh-Alvarado, J., Zhou, Z., Fröhlich, F., Mooney, R., &
% Wang, F. (2018). A Miniscope 1-photon-based Calcium Imaging Signal 
% Extraction Pipeline Cell reports, vol 23, number 12
  
min1pipe_init;

%% session-specific parameter initialization %%
Fsi = Params.Fs;
Fsi_new = Params.Fs; %%% no temporal downsampling %%%
spatialr = 1; %%% no spatial downsampling %%%
se = 3; %%% cell half-width in pixels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% user defined parameters %%%                                     %%%
Params.Fsi = Fsi;                                                   %%%
Params.Fsi_new = Fsi_new;                                           %%%
Params.spatialr = spatialr;                                         %%%
Params.neuron_size = se; %%% half neuron size; 9 for Inscopix and 5 %%%
%%% for UCLA, with 0.5 spatialr separately  %%%
%%%
%%% fixed parameters (change not recommanded) %%%                   %%%
Params.anidenoise_iter = 4;                   %%% denoise iteration %%%
Params.anidenoise_dt = 1/7;                   %%% denoise step size %%%
Params.anidenoise_kappa = 0.5;       %%% denoise gradient threshold %%%
Params.anidenoise_opt = 1;                %%% denoise kernel choice %%%
Params.anidenoise_ispara = 0;             %%% if parallel (denoise) %%%
Params.bg_remove_ispara = 0;    %%% if parallel (backgrond removal) %%%
Params.mc_scl = 0.004;      %%% movement correction threshold scale %%%
Params.mc_sigma_x = 5;  %%% movement correction spatial uncertainty %%%
Params.mc_sigma_f = 10;    %%% movement correction fluid reg weight %%%
Params.mc_sigma_d = 1; %%% movement correction diffusion reg weight %%%
Params.pix_select_sigthres = 0.8;     %%% seeds select signal level %%%
Params.pix_select_corrthres = 0.6; %%% merge correlation threshold1 %%%
Params.refine_roi_ispara = 1;          %%% if parallel (refine roi) %%%
Params.merge_roi_corrthres = 0.9;  %%% merge correlation threshold2 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(pth_nfo,1)

    if contains(pth_nfo(i).name,'run') && pth_nfo(i).isdir

        fprintf(['\nFound ' pth_nfo(i).name])

        %% get dataset info %%
        path_name = [pth_nfo(i).folder '\' pth_nfo(i).name '\'];
        file_base = 'data_clean';
        file_fmt = 'mat';

        filecur = [path_name, file_base, '_data_processed.mat'];

        %% data cat %%
        Fsi = Params.Fsi;
        Fsi_new = Params.Fsi_new;
        spatialr = 1;
        [m, filename_raw, imaxn, imeanf, pixh, pixw, nf, imx1, imn1] = data_cat(path_name, file_base, file_fmt, Fsi, Fsi_new, spatialr);

        %%% remove dead pixels %%%
        [m, imaxn] = remove_dp(m, 'frame_allt');

        %%% spatial downsampling after auto-detection %%%
        [m, Params, pixh, pixw] = downsamp(path_name, file_base, m, Params, 0, imaxn);

        %% neural enhancing batch version %%
        filename_reg = [path_name, file_base, '_reg.mat'];
        [m, imaxy1, overwrite_flag, imx2, imn2, ibmean] = neural_enhance(m, filename_reg, Params);

        %% neural enhancing postprocess %%
        nflag = 1;
        m = noise_suppress(m, imaxy1, Fsi_new, nflag);
        m = frame_stab(m); %%% spatiotemporal stabilization %%%
        imaxy = imaxy1;

        %% movement correction postprocess %%
        nflag = 2;
        filename_reg_post = [path_name, file_base, '_reg_post.mat'];
        m = noise_suppress(m, imaxy, Fsi_new, nflag, filename_reg_post);

    end
end
end

function min1pipe_init
% parse path, and install cvx if not
%   Jinghao Lu, 11/10/2017

%%% prepare main folder %%%
pathname = mfilename('fullpath');
mns = mfilename;
lname = length(mns);
pathtop1 = pathname(1: end - lname);

%%% check if on path %%%
pathCell = regexp(path, pathsep, 'split');
if ispc  % Windows is not case-sensitive
    onPath = any(strcmpi(pathtop1(1: end - 1), pathCell)); %%% get rid of filesep %%%
else
    onPath = any(strcmp(pathtop1(1: end - 1), pathCell));
end

%%% set path and setup cvx if not on path %%%
cvx_dir = [pathtop1, 'utilities'];
pathcvx = [cvx_dir, filesep, 'cvx', filesep, 'cvx_setup.m'];
if ~onPath
    pathall = genpath(pathtop1);
    addpath(pathall)
    if ~exist([cvx_dir, filesep, 'cvx'], 'dir')
        if ispc
            cvxl = 'http://web.cvxr.com/cvx/cvx-w64.zip';
        elseif isunix
            cvxl = 'http://web.cvxr.com/cvx/cvx-a64.zip';
        elseif ismac
            cvxl = 'http://web.cvxr.com/cvx/cvx-maci64.zip';
        end
        disp('Downloading CVX');
        unzip(cvxl, cvx_dir);
    end
end
if ~exist(fullfile(fileparts(prefdir), 'cvx_prefs.mat'), 'file')
    run(pathcvx);
end
end





