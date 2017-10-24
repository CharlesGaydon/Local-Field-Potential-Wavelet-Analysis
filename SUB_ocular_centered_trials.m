function sub = SUB_ocular_centered_trials(cfg,trl_ocular,trl_event)
% Define the trials according to the parameters specified in cfg , in the case of
% ocular-centered trials. 
%
% If cfg.cod is not negative, determine trials boundaries around the 
% saccades occuring near the event cfg.cod, followed by cfg.next if cfg.next 
% is positive.
%
% Input : cfg parameter of LFP_ocular_trials_fun ;
%         trl_ocular output of SUB_simple_ocular_trials ;
%         trl_event output of SUB_event_transform;
% Output : [beg_t,end_t,offset,time, time_fin, start] in seconds.
%           where the first three columns are the trials definition,
%           time and time_fin the boundaries of the saccade, 
%           and start the difference betweend the time and the timestamp of
%           the event.
%
% Last edited 24/08/2016
% Charles Gaydon

event = trl_event(:,1);
timestamp = trl_event(:,2);

%% Times around which to look for some saccades

if ~isnan(cfg.cod) && cfg.cod > 0
    disp(strcat('Keep only the saccades around in the window (',num2str(cfg.trialdef.presac),...
        ';',num2str(cfg.trialdef.postsac),') around the event #',num2str(cfg.cod)))
    if cfg.next >0
        disp(strcat('followed by the event #',num2str(cfg.next), '.'))
    end

    if cfg.next >0
        codtimes = [];
        n = 1:(length(event)-1);
        for i = n
           if event(i) == cfg.cod && event(i+1) == cfg.next
               codtimes = vertcat(codtimes,timestamp(i));
           end
        end
    else
        codtimes = timestamp(event == cfg.cod); 
    end
else
    codtimes = timestamp;
    disp('Keep the saccades without consideration of event.')
end

begsac = codtimes + cfg.trialdef.presac;
endsac = codtimes + cfg.trialdef.postsac; 

%% Select time of beginning of saccades

oczero = trl_ocular(:,4);

%% Select only the saccades around the event (or two events) specified.

sub = [];  
i_e = 1;
i_s = 1;
n_s = length(oczero);
n_e = length(codtimes);

while i_s <= n_s  

    while i_e <= n_e

        if oczero(i_s)<begsac(i_e)               
            i_s = i_s+1;                
        elseif oczero(i_s)>endsac(i_e)
            i_e = i_e+1;
        else 
           sub = vertcat(sub,[trl_ocular(i_s,1:5) (oczero(i_s)-codtimes(i_e))]);
           i_s = i_s+1;
           break
        end
        if i_s > n_s
            break
        end
    end
    i_s = i_s+1;      
end

end