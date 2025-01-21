function [all_ep_means,all_ep_trials,all_ep_ids,all_ep_n_rej,t] = cablam_evoked(M,params)

unstruct(params);

t = M.D{1}.t_ep;
bs_idx = t>=bs_lims(1) & t <= bs_lims(2);

all_ep_means = [];
all_ep_trials = {};
all_ep_ids = [];
all_ep_n_rej = [];

sigma = 3; % for noisy trial rejection

for i = 1:size(M.D,2) % each run

    x = M.D{i}.stim_eps; % time x roi x trial
    x = smoothdata(x,1,'movmean',Fs*smooth_len);

    isis = M.D{i}.isi;
    isis(isnan(isis)) = [];

    isi_pre_post = [];
    for j = 1:length(isis)-1
        isi_pre_post = [isi_pre_post; isis(j) isis(j+1)];
    end
    isi_pre_post(end,1) = isis(end);
    isi_pre_post(end,2) = Inf;

    bts1 = isi_pre_post(:,1) < isi_cut(1) | isi_pre_post(:,2) < isi_cut(2);
    bts2 = [];
    for j = 1:size(x,2) % each roi

        n_rej = [0 0 0 0];

        xx = squeeze(x(:,j,:)); % time x trial
        nt = size(xx,2);

        if elim_short_isi % reject trials too close to each other?
            xx(:,bts1) = [];
            n_rej(1) = sum(bts1);
        end

        if rej_out % reject trials with extremes
            trl_pwr = rms(xx);
            lims = detect_outlier_jm(trl_pwr,sigma,false);
            bts2 = trl_pwr<lims(1)|trl_pwr>lims(2);
            n_rej(2) = sum(bts2);
            xx(:,bts2) = [];
        end

        % baseline data (x - mean(x_base))./mean(x_base);
        bs = mean(xx(bs_idx,:));
        if rej_out % reject trials with extreme baselines
            bs_pwr = rms(xx(bs_idx,:));
            lims = detect_outlier_jm(bs_pwr,sigma,false);
            bts3 = bs_pwr<lims(1)|bs_pwr>lims(2);
            n_rej(3) = sum(bts3);
            xx(:,bts3) = [];
            bs(bts3) = [];
        end

        xx = bsxfun(@minus,xx,bs);
        xx = bsxfun(@rdivide,xx,bs);

         if rej_out % reject trials with extremes
            trl_pwr = mean(xx.^2);
            lims = detect_outlier_jm(trl_pwr,sigma,false);
            bts4 = trl_pwr<lims(1)|trl_pwr>lims(2);
            n_rej(4) = sum(bts4);
            xx(:,bts4) = [];
        end

        all_ep_trials{i}{j} = xx;

        xxx = squeeze(mean(xx,2));
        all_ep_means = cat(2,all_ep_means,xxx);
        all_ep_ids = [all_ep_ids; i*100+j];
        all_ep_n_rej = [all_ep_n_rej; n_rej nt i j];

    end
end







