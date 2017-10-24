function pre_trl = SUB_simple_ocular_trials(cfg)
% Gives the relevant time informations of all the saccades.
%
% Input : same as the LFP_ocular_trials_fun (see help).
% Output : a Nx5 matrix, N beeing the number of saccade in the data that
% are kept according to the cfg.isolatesaccades parameter. 
%
% Its tructure is as follow :
% [beg_t,end_t,offset,time, time_fin] in (s)
% Three first columns define some potential saccade-centered trials while
% the two last columns define the boundaries of the saccade.
%
% Last edited 24/08/2016
% Charles Gaydon
    if ~strcmp(cfg.trialtype,'fixation')
        time = cfg.eye.saccades_timeStamp(:,1);
        time_fin = cfg.eye.saccades_timeStamp(:,2);
    else
        time = cfg.eye.fixation_timeStamp(:,1);
        time_fin = cfg.eye.fixation_timeStamp(:,2);
    end
    
    if strcmp(cfg.isolatesaccades, 'no')

    elseif strcmp(cfg.isolatesaccades, 'yes')
        %% get rid of saccades surrounded by saccades in a specific window
        gauche = time + cfg.gauchesaccade;
        droite = time + cfg.droitesaccade;
        overwhelmed_win = zeros(length(gauche),1);
        i = 1; 
        j = 1;
        while i < (length(time)-2)
           while j<length(overwhelmed_win)

               if time(i) < gauche(j)
                   i = i+1;
               elseif time(i) > droite(j)
                   j = j+1;
               elseif overwhelmed_win(j) == 0
                   overwhelmed_win(j) = 1;
                   i=i+1;
               else
                   overwhelmed_win(j) = -1;
                   j = j+1;
               end     
           end   
        end
        time(overwhelmed_win<0) = [];
        time_fin(overwhelmed_win<0) = [];
    end
    
    temporary_time = time;
    
    time((temporary_time + cfg.trialdef.prestim)<=0) = [];
    time_fin((temporary_time + cfg.trialdef.prestim)<=0) = [];
    beg_t = time + cfg.trialdef.prestim;
    end_t = time + cfg.trialdef.poststim;
    offset = repmat(cfg.trialdef.prestim,length(time),1);

    pre_trl = [beg_t,end_t,offset,time, time_fin]; 
end