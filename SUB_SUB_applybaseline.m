function [pow, time_index, freq_index] = SUB_SUB_applybaseline(cfg,pow,time, freq)

% From a unique 2D spectral response matrix, apply a chosen baseline and
% keep only the freq and time needed as specified in cfg. 
% See the help of TF_singleplot or TF_multiplot for more information.
%
% NB : This function only takes as an input a 2D power sprectrum matrix
% (obtained with cfg.keeptrials = 'no' for ft_freqanalysis, or by extracting
% a subset of a larger 3D/4D matrix).
%
% Input : 
%   cfg : parameter of LFP_ocular_trials_fun function (see its help) ;
%   pow : the (nf,nt) matrix if the spectral response, contained in the output 
%         of the FieldTrip ft_freqanalysis function, when argument 
%         cfg.keeptrials = 'no'; 
%   time : the nt times of the temporal window of analysis.
%   freq = the nf frequencies of the analysis.
%
% Output : 
%   pow : the truncated 2D spectral response matrix, after a possible 
%         baseline normalization ;
%   time_index : truncature index boundaries of the time ;
%   freq_index : truncature index boundaries of the frequencies.
%
% Last edited : 24/08/2016
% Charles Gaydon

if ndims(pow)>3
    error('Input spectral response cover several trials. Try extracting one or averaging them.')
end

pow = squeeze(pow);
nt = size(pow,2);
nf = size(pow,1);

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
    for i = 1:(nf)
        freq_mp(i) = nanmean(pow(i,base_index(1):base_index(2)));
        if ~isfield(cfg,'baselinetype')
        elseif strcmp(cfg.baselinetype,'db')
            pow(i,:) = 10*log10(pow(i,:)/freq_mp(i));            
        elseif strcmp(cfg.baselinetype,'perc')
            pow(i,:) = 100*(pow(i,:)-freq_mp(i))./freq_mp(i);            
        elseif strcmp(cfg.baselinetype,'z')
             var = (1/nt)*nansum((pow(i,:)-freq_mp(i)).^2);
             pow(i,:) = (pow(i,:)-freq_mp(i))./sqrt(var);

        end
    end

end

%% Index of time to plot : keep only what you want to look at

if ~isfield(cfg,'xlim')
    cfg.xlim = [time(1,1) time(1,end)];
    time_index = [1 nt];
else
    time_index = [];
    for t = 1:nt
        if time(1,t)>=cfg.xlim(1)
            time_index = t;
            break
        end
    end
    for t = time_index(1):nt
       if time(1,t)>=cfg.xlim(2)
            time_index = [time_index (t-1)];
            break
       end
    end
end
pow = pow(:,time_index(1):time_index(2));

%% Index of frequency to plot : keep only what you want to look at

if ~isfield(cfg,'ylim')
    cfg.ylim = [freq(1,1) freq(1,end)];
    freq_index = [1 nf];
else
    
    if freq(1,1)>cfg.ylim(1)
        freq_index = 1;
    else
        freq_index = [];
        for f = 1:nf
            if freq(1,f)>=cfg.ylim(1)
                freq_index = f;
                break
            end
        end
    end
    
    if freq(1,end)<cfg.ylim(2)
        freq_index = [freq_index nf];
    else
        for f = freq_index(1):nf
           if freq(1,f)>=(cfg.ylim(2)-1)
                freq_index = [freq_index (f-1)];
                break
           end
        end
    end
    
end

pow = pow(freq_index(1):freq_index(2),:);

end