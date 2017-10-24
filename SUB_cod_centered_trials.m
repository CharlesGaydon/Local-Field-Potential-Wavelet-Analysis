function sub = SUB_cod_centered_trials(cfg,trl_ocular,trl_event)
% Define the trials according to the parameters specified in cfg , in the case of
% event-centered trials. (type "help LFP_ocular_trials_fun" for more info)
%
% Determine trials boundaries around the event cfg.cod, followed by 
% cfg.next if cfg.next is positive. Detects trials in which one or several
% saccades occur, and then keep all or a portion of them according to the
% cfg.saccadobserved parameter.
%
% You can uncomment some lines to calculate some saccade ratio in the window
% around event.
%
% Input : cfg parameter of LFP_ocular_trials_fun ;
%         trl_ocular output of SUB_simple_ocular_trials ;
%         trl_event output of SUB_event_transform;
% Output : trials [beg end offset] in seconds.
%
% Last edited 24/08/2016
% Charles Gaydon

disp(strcat('Keep only the saccades around the event #',num2str(cfg.cod)))
if cfg.next >0
    disp(strcat('followed by the event #',num2str(cfg.next)))
end
if ~strcmp(cfg.saccadobserved, 'all')
    disp(strcat('Presence of a saccad in the trials : ',cfg.saccadobserved))
end
event = trl_event(:,1);
timestamp = trl_event(:,2);


%% Determine trials boundaries around the event cfg.cod, followed by 
% cfg.next if cfg.next is positive.

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

%% Times of the trials

begcodtimes = codtimes + cfg.trialdef.prestim;
endcodtimes = codtimes + cfg.trialdef.poststim;

%% Times around which look for some saccades
begsac = codtimes + cfg.trialdef.presac;
endsac = codtimes + cfg.trialdef.postsac; 

%% Select time of beginning of saccades
oczero = trl_ocular(:,4); 

%% Initiate variables for looping
sub = []; %output
sub_indice_yes = []; %index of codtimes for the trials with a saccade

eve = 1;
last = 1;

%% Detect trials in which a saccade occurs

LC = length(endsac);
LO = length(oczero);
while eve<LC
    cur = begsac(eve);
    sac = last;
    while sac<=LO 
        if oczero(sac)<cur
            sac=sac+1;
            last = sac;
        elseif oczero(sac)>endsac(eve)
                eve=eve+1;
                cur = begsac(eve);
        elseif 1
           sub = vertcat(sub,[begcodtimes(eve) endcodtimes(eve) cfg.trialdef.prestim]);               
           sub_indice_yes = [sub_indice_yes eve];
           sac = sac+1;
        end
        if eve>=(LC-1) 
            break
        end
    end
    eve=eve+1;
end

%%% Uncomment to count the number saccades per second rate of the trials.
% ratio = length(sub_indice_yes)/(length(begcodtimes)*(cfg.trialdef.postsac-cfg.trialdef.presac)); %sac par sec dans zone
% disp(strcat('Around event #',num2str(cfg.cod),' (',...
%     num2str(cfg.trialdef.presac),';',num2str(cfg.trialdef.postsac),...
%     '), ratio of saccade is :',num2str(ratio))) 

sub = unique(sub,'rows');
sub_indice_yes = unique(sub_indice_yes);

if strcmp(cfg.saccadobserved,'no')
    a = 1:length(begcodtimes);
    for i = sub_indice_yes
        a(i) = 0;
    end
    a(a==0)=[];
    sub = [begcodtimes(a)  endcodtimes(a) repmat(cfg.trialdef.prestim,sum(a ~= 0),1)];
elseif strcmp(cfg.saccadobserved,'all')
    le = length(begcodtimes); 
    a = 1:le;
    sub = [begcodtimes(a)  endcodtimes(a) repmat(cfg.trialdef.prestim,sum(a ~= 0),1)];
end
end
