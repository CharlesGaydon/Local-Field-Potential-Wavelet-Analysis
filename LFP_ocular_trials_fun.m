function trl = LFP_ocular_trials_fun(cfg)

% This function define the trials of the experiment. It is used by the 
% ft_definetrial FieldTrip function and must return an array of at least three 
% columns and N lines, N being the number of trials.  The columns are :
% C1 : Begin of trial (unit : sample), 
% C2 : End of trial (idem),
% C3 : offset (idem).
%
% This function needs, in the structure cfg :
%
%    trialtype : % 'event' or 'saccade' centered trials.
%    cod ; next : trials are around the event "cod" followed by "next" or around the
%                       saccade in such context. A negative value (for "next", or "next" and "cod"),
%                       allow to not care of the event of the trials, but "cod" must be valid
%                       if trialtype = 'event'.
%
%    trialdef.presac ; trialdef.postsac : Time window in which to search 
%                                       for saccades around the event.
%    trialdef.prestim ; trialdef.poststim : Time window of a trial around
%                                           an event/saccade.
%    saccadobserved : For event-centered trials, 'yes' keeps only the trials 
%                     in which a saccade is observed, 'no' removes them and 
%                     'all' keep all the trials.
%    isolatesaccades ; gauchesaccade ; droitesaccade : Get rid of the saccades 
%                                      having a neighboor saccade beginning in 
%                                      the window [gauchesaccade ; droitesaccade], 
%                                      if isolatesaccades = 'yes'. Else,
%                                      isolatesaccades = 'no'.
%    
%   fsample : sampling rate of the lfp data AND the eye data.
%   event : structure containing timestamp and data (i.e. event cods) (vectors)
%   eye : structure with data.eye_x, data.eye_Y (note the uppercase) and
%       saccades_timeStamp, a two columns matrix with the beginning and end
%       of each saccade (in (s)).
%
% Last edited : 23/08/2016
% Charles Gaydon




%% Get relevant informations of all the saccades : 
% [beg_t,end_t,offset,time, time_fin] in (s)

trl_ocular = SUB_simple_ocular_trials(cfg); 

%% Get cods and timestamp of event of all the full task cycles exept the 
% 10 first cycles which are removed : [event timestamp] in (s)

trl_event = SUB_event_transform(cfg,10);

%% Define the trials around saccade or event

if strcmp(cfg.trialtype,'event')
    trl = SUB_cod_centered_trials(cfg,trl_ocular,trl_event);
elseif strcmp(cfg.trialtype,'saccade')
    trl = SUB_ocular_centered_trials(cfg,trl_ocular,trl_event);
end

%% Visualisation of gaze (heatmap and xy plot) for the whole trials

SUB_ocular_analysis(cfg, trl,trl_ocular)

%% output : transform in the good unit, which is "sample".

trl = fix(trl(:,1:3).*cfg.fsample);

end
        