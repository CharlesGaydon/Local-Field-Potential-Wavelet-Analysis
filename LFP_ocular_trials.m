% The purpose of this script is to isolate time windows of interest (trials)
% from lfp signal (caracterized by the oculomotor activity of the
% non-human primate (e.g. saccades) , and/or the event of the performed task)
% and perform Time-Frequency analysis using morlet's wavelet. It also
% allows several oculomotor analysis performed with the
% SUB_SUB_density_ocular function.
%
% This script uses the event data (cod and timestamp) of the experiment,
% oculomotor data already cleaned from artefacts and lfp data brought to
% the same sampling rate as the oculomotor data. However, one you cleaned
% your own data, it is easy to adapt them to the format I chose, in the
% 'Data import section'.
%
% Last edited 23/08/2016
% Charles Gaydon

clear


%------------------------------------------------------
% Data import 
%------------------------------------------------------


filename = 'HDRKNOPMW2_4439';

%%% Some paths
lfp_path = 'C:\ANALYSIS_Charles\RAW\';
behav_path = 'C:\ANALYSIS_Charles\RAW\';

%% load of raw lfp data
cd(lfp_path)
LFPfile = dir(strcat('*',filename,'.mat'));
LFPfile = LFPfile(1).name; %only the first if multiple. Only one theoretically.
RAW_LFP = load(LFPfile);
RAW_LFP = RAW_LFP.REC;
% RAW_LFP contains event, eye.data, eye.time...

%% Load of selected saccades.
cd(behav_path)
Sacfiles = dir(strcat('*',filename,'*','selected','*'));
Sacfiles = Sacfiles.name;
SAC = load(Sacfiles);
SAC = SAC.REC;


%% Here add your own data in the appropriate variables

fsample = RAW_LFP.lfp.LFP_Fs; %double
time = SAC.lfp.time; %vector
lfp_data = SAC.lfp.data.lfp2; %vector - lfp1 = LPFC ; others : MCC.

event = RAW_LFP.event; 
%Structure : event.timestamp, event.data (i.e. event cods) (vectors)

eye = SAC.eye;
% Structure : eye.data.eye_x, eye.data.eye_Y (note the uppercase) and
% eye.saccades_timeStamp, a two columns matrix with the beginning and end
% of each saccade.


%------------------------------------------------------
% Parameters of analysis
%------------------------------------------------------


%% Type of trials and window of interest

trialtype = 'event';
% 'event' or 'saccade' centered trials.
cod = 165;
next = -1;
% trials are around the event "cod" followed by "next" or around the
% saccade in such context. A negative value (for "next", or "next" and "cod"),
% allow to not care of the event of the trials, but "cod" must be valid
% if trialtype = 'event';
precod = -3; % (can be negative), time before event/saccade in (s)
postcod = 3; % time after event/saccade in (s)
window = [-1 2]; %this is solely for visual inspection

%% Distance to search for saccades around the event

presac = -0.3; % (can be negative), time before event in (s)
postsac = 0; % time after event in (s)
saccadobserved = 'all';
% For event-centered trials, 'yes' keeps only the trials in which a saccade
% is observed, 'no' removes them and 'all' keep all the trials.

%% Get rid of the saccade having a neighboor saccade beginning in the window 
% [gauchesaccade ; droitesaccade], if isolatesaccades = 'yes'.

isolatesaccades = 'no';
gauchesaccade = -0.2; % (can be negative), time before saccade in (s)
droitesaccade = 0.2; % time after saccade in (s)

%% Conditions of trials

cfg = [];
cfg.trialfun = 'LFP_ocular_trials_fun';
cfg.trialdef.presac  = presac;
cfg.trialdef.postsac = postsac; 
cfg.trialdef.prestim = precod;
cfg.trialdef.poststim = postcod;
cfg.isolatesaccades = isolatesaccades;
cfg.saccadobserved = saccadobserved;
cfg.gauchesaccade = gauchesaccade;
cfg.droitesaccade = droitesaccade;
if exist('cod','var')
    cfg.cod = cod;
end
cfg.fsample = fsample;
cfg.event = event;
cfg.eye = eye;
cfg.next = next;
cfg.trialtype = trialtype;

%% Format data for FieldTrip

lfp = [];
lfp.fsample = fsample;
lfp.time = {time'};
lfp.trial = {lfp_data'}; 
lfp.fid = filename;
lfp.label = {'Label'}; %unrelevant
lfp.channel = 1; 
lfp.date = {'NoSpecified'}; %unrelevant
lfp.depth = -1.0; %unrelevant


%------------------------------------------------------
% Trials and artefact detection
%------------------------------------------------------


%% Make trials

cfg = ft_definetrial(cfg);
lfp_trials = ft_redefinetrial(cfg,lfp);

%% First visualisation

% cfg.continuous = 'no';
% cfg.viewmode   = 'butterfly';
% cfg.blocksize  = 2;
% ft_databrowser(cfg,lfp_trials);

%% Visual reject of artefacts
cfg = [];
cfg.method = 'channel';
cfg.latency  = window;
cfg.trials = 'all';
lfp_cleaned = ft_rejectvisual(cfg,lfp_trials);

%% Or charge actual cleaned data
% disp('CLEANED DATA LOADED')
% save('C:\ANALYSIS_Charles\SCRIPTS\CleanData22082016\TFRsaccade_(-0.3;0)_160-150_LFP2_(11082016).mat', 'TFR2')
% load('C:\ANALYSIS_Charles\SCRIPTS\CleanData22082016\TFRisolated(-0.2;0.2)saccade_(-0.3;0)_160-66_LFP2_(11082016).mat')


%------------------------------------------------------
% Time-Frequency analysis and Comparison of conditions
%------------------------------------------------------


%% Morlet's Wavelett convolution
cfg = [];
cfg.channel    = 'all';        
cfg.method     = 'wavelet';             
cfg.output     = 'pow';
cfg.foi        = 2:0.5:100;           
cfg.toi        = precod:0.01:postcod;
cfg.keeptrials = 'yes'; 
cfg.width = 7;
TFRwave = ft_freqanalysis(cfg, lfp_cleaned); 

%% Visualisation parameters


cfg.xlim = [-1 2];
cfg.ylim = [2 64];
%cfg.zlim = [-3.5 3.5]; % Automatic if not specified (use symetric z scale)
cfg.yScale = 'log'; % Standard or semi-logarithmic scale.

% cfg.baselinetype = 'db'; %Uncomment this line to apply a baseline
% cfg.baseline = [-1.2 0.4]; %Uncomment this line to apply a baseline


if strcmp(cfg.keeptrials,'no')
    TF_singleplot(cfg, TFRwave)
else
    % Re-Sampling parameters (see the help for TF_multiplot function)

    cfg.numrandomization = 300; 
    cfg.method = 'z'; 
    cfg.alpha = 0.05;
    cfg.quantiles = fix(1/cfg.alpha);
    
    % Re-Sampling and plotting
    
    TF_multiplot(cfg,TFR1,TFR2) 
    
end

TF_highlight_burst(cfg,TFR165yes,[12 20],cfg.xlim)
   