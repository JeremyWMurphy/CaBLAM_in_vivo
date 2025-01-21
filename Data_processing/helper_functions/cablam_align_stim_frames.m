function[stim_frame_idxs] = cablam_align_stim_frames(S)

teensy_n_frames = S.frames(end);

frame_cntr = 7;
fire_raw = 8;
trial_boxcar = 13;
piezo_raw = 12;

% figure, hold on
% plot(S.raw_data(frame_cntr,:))
% plot(zscore(S.raw_data(fire_raw,:)))
% plot(zscore(S.raw_data(piezo_raw,:)))
% plot(zscore(S.raw_data(trial_boxcar,:)))
% legend('Frame counter','exp fire','piezo','trl boxcar')

exp_onoff = zscore(diff(S.raw_data(fire_raw,:)));
exp_on = exp_onoff;
exp_off = exp_onoff;
exp_on(exp_on<0) = 0;
exp_off(exp_off>0) = 0;
exp_off = abs(exp_off);
exp_off = [0 exp_off(1:end-1)];

[~,on_ix] = findpeaks(exp_on,'MinPeakHeight',1,'MinPeakDistance',0.01*S.Fs);
if max(diff(diff(on_ix)))>1
    fprintf('\nCheck on frame intervals')
    keyboard
end
[~,off_ix] = findpeaks(exp_off,'minpeakheight',1,'MinPeakDistance',0.01*S.Fs);
if max(diff(diff(off_ix)))>1
    fprintf('\nCheck off frame intervals')
    keyboard
end

if off_ix(1) < on_ix(1) % then the teensy caught only the offset of frame 1, this usually seems to happen
    on_ix = [nan on_ix];
    teensy_n_frames = teensy_n_frames + 1;
end

trial_onoff = diff(zscore(S.raw_data(trial_boxcar,:)));
trial_on = trial_onoff>0;

trial_on_idx = find(trial_on);
stim_frame_idxs = [];

cntr = 1;
for i = 1:size(trial_on_idx,2)

    tmp = trial_on_idx(i);
    tmp2 = on_ix - tmp;
    ix_tmp = find(tmp2<0,1,'last');
    if ~isempty(ix_tmp)
        stim_frame_idxs(cntr) = ix_tmp;
        cntr = cntr + 1;
    end

end

% figure, hold on
% plot(zscore(S.raw_data(trial_boxcar,:)))
% plot(exp_on./15)
% plot(on_ix(stim_frame_idxs),1,'om')

if length(on_ix) ~= teensy_n_frames
    fprintf('\nSomething is off in frame count')
    keyboard
end




