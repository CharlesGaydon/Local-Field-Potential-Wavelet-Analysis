function sub = SUB_event_transform(cfg, nmin)
% This function preprocess the event and their timestamp to remove the
% nmin first cycles and to assure that each cycle is complete.
%
% Input : cfg as in LFP_ocular_trials and the number of cycles of the
%        experiment to be removed, in order to eliminate potential bad data.
% Output : the event cods in the first column and their time in (s) in the
%       second column : [event timestamp].
%
% Last edited 24/08/2016
% Charles Gaydon

timestamp = cfg.event.timestamp;
event = cfg.event.data;
Trials = [];
TrialsTime = [];
n = 0; 
for ii = 1 : length(event)
    if event(ii,1) == 100
        indx = ii + find(event(ii:end,1) == 101 , 1,'first') - 1; 
        if isempty(indx)
        elseif (~isempty(indx)) && n>nmin
            Trials((1:length(event(ii : indx))) + length(Trials) , 1) = event(ii : indx ,1);
            TrialsTime((1:length(timestamp(ii : indx))) + length(TrialsTime) , 1) = timestamp(ii : indx ,1);
        elseif 1 
            n=n+1;
        end
    end
end
sub = [Trials(:) TrialsTime(:)] ;   
end