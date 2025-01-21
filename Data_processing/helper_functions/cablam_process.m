function[] = cablam_process(pth_nfo,params)

fprintf('\nCablam main processing\n')

unstruct(params);

run_cntr = 1;
data_pths = {};
for i = 1:size(pth_nfo,1)
    if contains(pth_nfo(i).name,'run') && pth_nfo(i).isdir
        fprintf(['\nFound ' pth_nfo(i).name])
        data_pths{run_cntr} = [pth_nfo(i).folder '\' pth_nfo(i).name '\'];
        run_cntr = run_cntr + 1;
    end
end

n_runs = size(data_pths,2);

D = {};

for i = 1:n_runs % each run

    data_pth = data_pths{i};
    pth_pieces = split(data_pth(1:end-1),'\');

    id = pth_pieces{8};

    fprintf(['\nDoing ' pth_pieces{end} '\n'])

    load([data_pth 'teensy_data.mat'])

    [stim_frames] = cablam_align_stim_frames(S);

    load([data_pth '\roi_data.mat'],'L','tseries')
    load([data_pth '\data_clean_supporting.mat'],'ibmean')


    tseries = tseries';

    if do_resample
        new_tseries = [];
        if Fs ~= nfs
            for k = 1:size(tseries,2)
                new_tseries(:,k) = decimate(tseries(:,k),2);
            end
            tseries = new_tseries;
            stim_frames = round(stim_frames./2);
        end
        Fs = nfs;
    end

    bkgd = tseries(:,1); % first roi which is everything thats not marked as a cell
    tseries = tseries(:,2:end); % drop first roi which is everything thats not marked as a cell
    %tseries = bsxfun(@minus,tseries,bkgd);

    %% detect calcium events
    tseries_wv = tseries;
    tseries_wv = smoothdata(detrend(tseries_wv),1,'movmean',Fs); % smooth just for finding peaks
    spk_rast = zeros(size(tseries));
    for j = 1:size(tseries,2) % for each roi

        x = tseries_wv(:,j);
        thresh = median(x) + thresh_val*iqr(x);
        ix1 = find(x>thresh);
        ix_rr = find_in_a_row(ix1);

        ix = [];
        pk_info = [];
        for k = 1:size(ix_rr,2)
            tmp = ix_rr{k};
            if numel(tmp)>rr_thresh
                [pk,mx_ix] = max(x(tmp));
                ix = [ix; tmp(mx_ix)];
                pk_info = cat(1,pk_info,[pk length(tmp) length(tmp) tmp(mx_ix) i]);
            end
        end
   
        win_idx = round(Fs*wv_pre_post(1)):round(Fs*wv_pre_post(2));

        run_waves = [];
        for k = 1:numel(ix) % for each spike

            win = win_idx + ix(k);

            if any(win<1) || any(win>size(x,1))
                pk_info(k,:) = NaN;
            else
                run_waves = cat(2,run_waves,tseries(win,j));
            end
        end

        D{i}.waves{j} = run_waves;
        D{i}.wv_nfo{j} = pk_info;

        % make a 'spike' raster
        spk_rast(ix,:) = 1;

    end % roi

    %% stimulus timing

    isi = [Inf diff(stim_frames)./Fs];
    frames = stim_frames;

    % collect across runs
    D{i}.im_mu = ibmean;
    D{i}.mask = L;
    D{i}.tseries = tseries;
    D{i}.frames = frames;
    D{i}.isi = isi;
    D{i}.Fs = Fs;
    D{i}.t_wave = wv_pre_post(1):1/Fs:wv_pre_post(2);
    D{i}.t_ep = stim_pre_post(1):1/Fs:stim_pre_post(2);

end % runs

if ~exist(save_pth)
    mkdir(save_pth);
end

save([save_pth id '_processed_data.mat'],'D')






