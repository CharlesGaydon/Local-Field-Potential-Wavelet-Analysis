function TF_singleplot(cfg, TFRwave)

% Apply a baseline to the power spectrum matrix given by the ft_freqanalysis 
% function and plot the result according to the parameter given in cfg. 
%(See the help of LFP_ocular_trials_fun for more information).
%
% Inputs :
%
% TFRwave : the output of the FieldTrip ft_freqanalysis function with 
% cfg.keeptrials = 'no'.
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
% NB : This function only takes as an input a 2D power sprectrum matrix
% (obtained with cfg.keeptrials = 'no' for ft_freqanalysis, or by extracting
% a subset of a larger 3D/4D matrix).
%
% Last edited 24/08/2016
% Charles Gaydon


pow = squeeze(TFRwave.powspctrm); %dimensions : freq x time
time = TFRwave.time;
freq = TFRwave.freq;
nf = size(pow,1);
nt = size(pow,2);

if isfield(cfg, 'baseline')
    baseb = cfg.baseline(1);
    basee = cfg.baseline(2);

    if baseb>=basee || baseb<time(1,1) || basee>time(1,end)
        error('Wrong baseline definition');
    end
end

%% Baseline and reduction of window
[pow, time_index, freq_index] = SUB_SUB_applybaseline(cfg,TFRwave.powspctrm,...
    TFRwave.time, TFRwave.freq);

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
ylabel('Fréquence (Hz)')
end