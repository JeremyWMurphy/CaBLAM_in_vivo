function [] = cablam_make_rois(pth_nfo,params)

for i = 1:size(pth_nfo,1)

    if contains(pth_nfo(i).name,'run') && pth_nfo(i).isdir

        fprintf(['\nFound ' pth_nfo(i).name])

        data_pth = [pth_nfo(i).folder '\' pth_nfo(i).name '\'];
        data_fl_nfo = dir([data_pth '*data_clean_supporting.mat']);
        data_fl_nfo_2 = dir([data_pth '*data_clean_reg_post.mat']);

        for j = 1:size(data_fl_nfo,1)
            fprintf(['\nLoading ' data_fl_nfo(j).name])
            load([data_pth data_fl_nfo(j).name],'ibmean');
            load([data_pth data_fl_nfo_2(j).name],'reg');

            r = uint8(rescale(ibmean,0,2^8-1));
            r = imresize(r,4);
            
            % we make rois and save them to the workspace as "BW"
            imageSegmenter(r) 

            keyboard

            BW = evalin('base','BW');
            BW = imresize(BW,1/4);

            
            L = bwlabel(BW,8);
            [tseries,L] = im_roi_supervised(L,reg,4);
            save([data_pth 'roi_data' date '.mat'],'tseries','L');

        end

    end
    
end