function [] = cablam_data_import(data_pth,pth_nfo,params)

% images for 'darks', ie data acquired with shutter closed
Fs_10_calib = 'MED_bkgd_10hz_300em.tif'; % for biolum data with em gain on, sample rate 10 Hz
Fs_5_calib = 'MED_bkgd_5hz_300em.tif'; % for biolum data with em gain on, sample rate 5 Hz
Fs_10_calib_GCaMP = 'MED_bkgd_10hZ_EM_OFF.tif'; % for GCaMP data with em gain off, sample rate 10 Hz
calib_pth = [data_pth '\calibration_images\'];

for i = 1:size(pth_nfo,1)

    if contains(pth_nfo(i).name,'run') && pth_nfo(i).isdir

        fprintf(['\nFound ' pth_nfo(i).name])

        data_pth = [pth_nfo(i).folder '\' pth_nfo(i).name '\'];

        if strcmp(params.indicator,'GCaMP')
            calib_img = imread([calib_pth Fs_10_calib_GCaMP]);
        elseif strcmp(params.indicator,'CaBLAM') && params.FS == 10
            calib_img = imread([calib_pth Fs_10_calib]);
        elseif strcmp(params.indicator,'CaBLAM') && params.FS == 5
            calib_img = imread([calib_pth Fs_5_calib]);
        else
            keyboard
        end

        calib_img = double(calib_img);

        tif_fl_nfo = dir([data_pth '*run*.tif']);
        imgs = read_tiff_stack(tif_fl_nfo);
        imgs = double(imgs);

        fprintf('\nBinning')
        sz = size(imgs,1);
        sz_calib = size(calib_img,1);

        [imgs] = bin_img_series_jm(imgs,256,sz,'median');
        [bkgd] = bin_img_series_jm(calib_img,256,sz_calib,'median');

        fprintf('\nDoing outlier detection')
        imgs = im_outlier_detect_correct(imgs);
   
        imgs = bsxfun(@minus,imgs,bkgd);
        mu_img = squeeze(mean(imgs,3));

        fprintf('\nSaving')
        save([data_pth 'data_clean.mat'],'imgs','bkgd','mu_img')

    end
end