function TF_multiplot(cfg, TFR1, TFR2)
% Execute a permutation test on time-frequency cleaned data, to determine
% if the spectral response under condition 1 is significantly different
% than in the other cases. A baseline may be applied. The difference
% studied is TFR1 minus TFR2.
%
% Inputs :
%
%   TFR1 : the output of the FieldTrip ft_freqanalysis function with 
%        cfg.keeptrials = 'yes' for condition 1.
%   TFR2 : the output of the FieldTrip ft_freqanalysis function with 
%        cfg.keeptrials = 'yes' for condition 2.
%
% This function also needs, in the structure cfg :
%   baselinetype : a baseline normalization will be applied only if this
%                  parameter is defined.  Possible choices are 'db' for
%                  decibel, 'perc' for percentage and 'z' for a
%                  z-transform.
%   baseline : specify the time boundaries of the baseline to apply.
%   foi : frequencies of interest used for the TFanalysis.
%   toi : times of interest used for the TFanalysis.
%   xlim = [beg end] which gives the temporal boundaries of the spectral
%          response to plot.
%   ylim = [beg end] which gives the spectral boundaries of the spectral
%          response to plot.
%   zlim = [beg end] which gives the power boundaries of the spectral
%          response to plot. It is determined automaticaly if not specified.
%          Should be a symetric scale (i.e. [-end end]).
%   yScale : standard ('lin') or semi-logarithmic ('log') y scale.
%
%
% NB : The two possible methods give similar results but the z-transform gives
% results that are easier to interpret.
%
% Possible methods :
%
% method = 'global' :
%   Collect all the trials into one set. 
%   Then, cfg.numrandomization times, randomly draw N1
%   trials from the set, average them and apply the baseline. Finally
%   establish a repartition map of the spectral response, defined by
%   quantiles given by cfg.quantiles (should be at least = 20).
%   Then only plot on a colormap the spectral response that is
%   significantly different with a cfg.alpha threshold 
%   (i.e : eliminate what is beween the 5th and the 95th quantiles.)
%
% method = 'z' :
%   Collect all the trials into one set. Randomly reproduce subset of the 
%   sizes of the two conditions considered and compute the mean and the 
%   standard-variation of their difference. 
%   Substract to the condition 1 studied and divide by the
%   standard-deviation. We now have a z-value easely understandable.
%   Then only plot on a colormap the spectral response that is
%   significantly different with a cfg.alpha threshold 
%   (i.e : eliminate what is beween the 5th and the 95th quantiles.)
%
% method = 'diff' :
%   Only plot the difference between the two conditions, without resampling. 
%
% Last edited : 23/08/2016
% Charles Gaydon

disp(['Launching permutation test with method : ' cfg.method])

p1 = TFR1.powspctrm;
p2 = TFR2.powspctrm;
size_1 = size(p1,1);
size_2 = size(p2,1);

pall = [];
pall(:,:,:,:) = p2(:,:,:,:);
pall((size_2+1):(size_2+size_1),:,:,:) = p1(:,:,:,:);

%% Mean on each subset, establish quantiles

if strcmp(cfg.method,'global')
    
    mean_set = [];
    for i = 1:cfg.numrandomization
        if rem(i, fix(cfg.numrandomization/20)) == 0
            disp(['Randomization #' num2str(i) 'on' num2str(cfg.numrandomization) '.'])
        end
        R = randi([1 (size_1+size_2)],[size_1 1]);

        subset_mean = nanmean(pall(R,:,:,:),1);
        [subset_mean_norm, ~, ~] = SUB_SUB_applybaseline(cfg,squeeze(subset_mean),...
      TFR1.time, TFR1.freq); 
        mean_set(i,:,:) = squeeze(subset_mean_norm);

    end
    quantiles = quantile(mean_set,cfg.quantiles, 1);
    down_q_index = fix(quantile(1:cfg.quantiles,cfg.alpha));
    up_q_index = round(quantile(1:cfg.quantiles,1-cfg.alpha)); %% test : inf ou egal, sup ou egal!

    [pow, time_index, freq_index] = SUB_SUB_applybaseline(cfg,...
        squeeze(nanmean(p1(:,:,:,:),1)), TFR1.time, TFR1.freq); 
    pow_log = pow(:,:)>=squeeze(quantiles(down_q_index,:,:)) & pow(:,:)<=squeeze(quantiles(up_q_index,:,:));
    pow(pow_log) = 0;
    
elseif strcmp(cfg.method,'z')
    
    [pow1, ~, ~] = SUB_SUB_applybaseline(cfg,...
        squeeze(nanmean(p1(:,:,:,:),1)), TFR1.time, TFR1.freq); 
    [pow2, time_index, freq_index] = SUB_SUB_applybaseline(cfg,...
        squeeze(nanmean(p2(:,:,:,:),1)), TFR1.time, TFR1.freq); 
    diff_pow = pow1 - pow2;
    
    diff_set = [];
    for i = 1:cfg.numrandomization
        if rem(i, fix(cfg.numrandomization/20)) == 0
            disp(['Randomization #' num2str(i) ' on ' num2str(cfg.numrandomization) '.'])
        end
        % 1
        R1 = randi([1 (size_1+size_2)],[size_1 1]);
        subset_C1_mean = nanmean(pall(R1,:,:,:),1);
        [subset_C1_mean, ~, ~] = SUB_SUB_applybaseline(cfg,squeeze(subset_C1_mean),...
      TFR1.time, TFR1.freq); 
        % 2
        R2 = 1:(size_1+size_2);
        R2(R1) = [];
        subset_C2_mean = nanmean(pall(R2,:,:,:),1);
        [subset_C2_mean, ~, ~] = SUB_SUB_applybaseline(cfg,squeeze(subset_C2_mean),...
      TFR1.time, TFR1.freq); 
        % Difference
        diff_set(i,:,:) = squeeze(subset_C1_mean-subset_C2_mean);
    end
    diff_sd = squeeze(std(diff_set,0,1));
    diff_mean = squeeze(nanmean(diff_set,1));
    
    pow = (diff_pow -  diff_mean)./diff_sd;
    
    % Using a gaussian law for the quantiles gives similar results and
    % could be used as well :
    % up_quantile = norminv(1-cfg.alpha,0,1);
    % down_quantile = norminv(cfg.alpha,0,1);

    quantiles = quantile(diff_set,cfg.quantiles, 1);
    
    down_q_index = fix(quantile(1:cfg.quantiles,cfg.alpha));
    up_q_index = round(quantile(1:cfg.quantiles,1-cfg.alpha));
    
    down_quantile = (squeeze(quantiles(down_q_index,:,:)) - diff_mean)./diff_sd;
    up_quantile = (squeeze(quantiles(up_q_index,:,:)) - diff_mean)./diff_sd;
    
    pow_non_s = (pow>down_quantile) & (pow<up_quantile);
    pow(pow_non_s) = 0;
    
elseif strcmp(cfg.method,'diff')
    [pow1, ~, ~] = SUB_SUB_applybaseline(cfg,...
        squeeze(nanmean(p1(:,:,:,:),1)), TFR1.time, TFR1.freq); 
    [pow2, time_index, freq_index] = SUB_SUB_applybaseline(cfg,...
        squeeze(nanmean(p2(:,:,:,:),1)), TFR2.time, TFR2.freq); 
    pow = pow1 - pow2;
else
    error('Bad definition of cfg.method (possible : global, z, diff)')
end


%% Visualisation

if strcmp(cfg.yScale,'lin')
    if ~isfield(cfg,'zlim')
        if isfield(cfg,'baselinetype')
            m = max(max(abs(pow(:,:))));
            cfg.zlim = [-m m];
            figure
            im = imagesc(cfg.xlim,cfg.ylim,pow);
            set(gca,'YDir','normal')
            set(gca,'Clim',cfg.zlim)
            colorbar
        else
            figure
            im = imagesc(cfg.xlim,cfg.ylim,pow);
            set(gca,'YDir','normal')
            colorbar
        end
    else
        figure
        im = imagesc(cfg.xlim,cfg.ylim,pow);
        set(gca,'YDir','normal') 
        set(gca,'Clim',cfg.zlim)
        colorbar
    end
elseif strcmp(cfg.yScale,'log')
    if ~isfield(cfg,'zlim')
        if isfield(cfg,'baselinetype')
            m = max(max(abs(pow(:,:))));
            cfg.zlim = [-m m];
            figure
            contourf(cfg.toi(time_index(1):time_index(2)),...
                cfg.foi(freq_index(1):freq_index(2)),...
                pow,40,'linestyle','none');
            set(gca,'yscale','log','ytick',[2 4 8 16 32 64 128]);
            set(gca,'Clim',cfg.zlim)
            colorbar
        else
            figure
            contourf(cfg.toi(time_index(1):time_index(2)),...
                cfg.foi(freq_index(1):freq_index(2)),...
                pow,40,'linestyle','none');
            set(gca,'yscale','log','ytick',[2 4 8 16 32 64 128]);
            colorbar
        end
    else
        figure
        contourf(cfg.toi(time_index(1):time_index(2)),...
            cfg.foi(freq_index(1):freq_index(2)),...
            pow,40,'linestyle','none');
        set(gca,'yscale','log','ytick',[2 4 8 16 32 64 128]);
        set(gca,'Clim',cfg.zlim)
        colorbar
    end
end
xlabel('Temps (s)')
ylabel('Frequency (Hz)')
title('Time-Frequency power spectrum')
end