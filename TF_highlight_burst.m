function TF_highlight_burst(cfg, TFRwave, freq_lim, time_lim)
% This function averages for each trial the power response between 
% boundaries given by freq_lim and time_lim. It finally plots the whole 
% averaged data to highlight the burst in individual trials.
%
% The data used is the output of the FieldTrip ft_freqanalysis
% function used with cfg.keeptrials = 'yes'.
%
% Last edited 24/08/2016
% Charles Gaydon

freq_l = freq_lim(1);
freq_h = freq_lim(2);

x_l = time_lim(1);
x_h = time_lim(2);

%% Extract relevant data

pow = squeeze(TFRwave.powspctrm);
time = TFRwave.time;
freq = TFRwave.freq;
ntrials = size(pow,1);
nfreq = length(freq);
ntime = length(time);

%% Apply baseline normalization

nt = ntime;
nf = nfreq;


if isfield(cfg,'baseline')
    %% Index of the baseline

    base_index = [];
    baseb = cfg.baseline(1);
    basee = cfg.baseline(2);
    for t = 1:nt
        if time(1,t)>=baseb
            base_index = t;
            break
        end
    end
    for t = base_index(1):nt
       if time(1,t)>basee
            base_index = [base_index t];
            break
        end
    end

    %% Apply baseline

    freq_mp = zeros(1,nf);   
    for j = 1:ntrials
        for i = 1:(nf)
            freq_mp(j,i) = nanmean(pow(j,i,base_index(1):base_index(2)));
            if ~isfield(cfg,'baselinetype')
            elseif strcmp(cfg.baselinetype,'db')
                pow(j,i,:) = 10*log10(pow(j,i,:)/freq_mp(j,i));            
            elseif strcmp(cfg.baselinetype,'perc')
                pow(j,i,:) = 100*(pow(j,i,:)-freq_mp(j,i))./freq_mp(j,i);            
            elseif strcmp(cfg.baselinetype,'z')
                 var = (1/nt)*nansum((pow(j,i,:)-freq_mp(j,i)).^2);
                 pow(j,i,:) = (pow(j,i,:)-freq_mp(j,i))./sqrt(var);

            end
        end
    end

end

%% Determine the frequency index between wich we keep the data
if freq_l < freq(1)
    index_beg = 1;
else
    if freq_l > freq(end)
        error('Wrong freq_l input')
    else
        for i = 1:nfreq
            if freq(i) > freq_l
               index_beg = i;
               break
            end
        end
    end
end

if freq_h > freq(end)
    index_end = nfreq;
else
    if freq_h < freq(1)
        error('Wrong freq_h input')
    else
        for i = 1:nfreq
            if freq(i) > freq_h
               index_end = i;
               break
            end
        end
    end
end

%% Determine the time index between wich we keep the data
if x_l < time(1)
    time_beg = 1;
else
    if x_l > time(end)
        error('Wrong x_l input')
    else
        for i = 1:ntime
            if time(i) > x_l
               time_beg = i;
               break
            end
        end
    end
end

if x_h > time(end)
    time_end = ntime;
else
    if x_h < time(1)
        error('Wrong x_h input')
    else
        for i = 1:ntime
            if time(i) > x_h
               time_end = i;
               break
            end
        end
    end
end

%% Select, average and plot the result.

pow = pow(:,index_beg:index_end,time_beg:time_end);
avpow = squeeze(nanmean(pow,2));
set(gca,'YDir','normal')
imagesc([time(time_beg) time(time_end)], [1 size(avpow,1)],avpow);
if ~isfield(cfg,'zlim')
        if isfield(cfg,'baselinetype')
            m = max(max(abs(pow(:,:))));
            cfg.zlim = [-m m];
            set(gca,'Clim',cfg.zlim)
        end 
end
          
colorbar
xlabel('Temps (s)')
ylabel('Trial')
end