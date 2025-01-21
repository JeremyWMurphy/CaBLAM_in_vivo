function [] = cablam_teensy_data_proc(pth_nfo)

% parse data from teensy microcontroller for stim times, frames times

for i = 1:size(pth_nfo,1)

    if contains(pth_nfo(i).name,'run') && pth_nfo(i).isdir

        fprintf(['\nFound ' pth_nfo(i).name])
        data_pth = [pth_nfo(i).folder '\' pth_nfo(i).name '\'];
        hdf_fl = dir([data_pth '*.hdf']);
        hdf_fl = hdf_fl.name;
        
        nfo = h5info([data_pth '\' hdf_fl]);

        pth2data = '/sessionData/dataStreams';
        data = double(h5read([data_pth '\' hdf_fl],pth2data));

        frames = data(7,:);
        piezo = data(12,:);

        pth2data = '/sessionData/taskSettings/';
        Fs = h5readatt([data_pth '\' hdf_fl],pth2data,'sampRate');
        Fs = double(Fs);

        [~,idx] = findpeaks(diff(frames));
        frame_dists_hz = Fs./diff(idx);
        frame_rate = round(mode(frame_dists_hz));

        pth2data = '/sessionData/signalParameters/tFired';
        trig = h5read([data_pth '\' hdf_fl],pth2data);
        trig = double(trig);
        trig(isnan(trig)) = [];
        trig = round(trig*Fs);
        trig_trunc = trig(trig<size(frames,2));
        stim_frames = frames(trig_trunc);

        S  = struct('nfo',nfo,'frames',frames,'trig',trig,'Fs',Fs, 'frame_rate', frame_rate,...
            'piezo',piezo,'stim_frames',stim_frames,'raw_data',data);
        
        fprintf('\nSaving')
        save([data_pth 'teensy_data.mat'],'S')

    end
end