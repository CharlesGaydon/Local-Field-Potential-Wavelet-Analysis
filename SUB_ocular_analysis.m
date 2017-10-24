function SUB_ocular_analysis(cfg,trl, ~)
% Exctract the saccades coordinates and plot them, alongside a gaze heatmap
% and an histogram of the temporal repartition of the saccades in the
% trials.
%
% Input : cfg parameter of LFP_ocular_trials_fun;
%         trl output of SUB_cod_centered_trials or SUB_ocular_centered_trials;
%         trl_ocular output of SUB_simple_ocular_trials;
%
% Last edited 24/08/2016
% Charles Gaydon

nb_trials = size(trl,1);
X = cfg.eye.data.eye_x.without_blinks;
Y = cfg.eye.data.eye_Y.without_blinks;

%% Take the saccades (default) coordinates from raw data

% visu_x_y = [];
% for i = 1:nb_trials
%     beg_t = trl(i,1);
%     end_t = trl(i,2);
%     beg_indx = fix(beg_t*cfg.fsample);
%     end_indx = fix(end_t*cfg.fsample);
%     visu_x_y = vertcat(visu_x_y, [X(beg_indx:end_indx) Y(beg_indx:end_indx)], [NaN NaN]);
% end 

% You can also take the end of the saccade coordinates by uncommenting those
% lines :

visu_x_y = [];
for i = 1:(nb_trials)
    beg_t = trl(i,1);
    end_t = trl(i,2);
    beg_indx = fix(beg_t*cfg.fsample);
    end_indx = fix(end_t*cfg.fsample);
    visu_x_y = vertcat(visu_x_y, [X((end_indx-1):end_indx) Y((end_indx-1):end_indx)], [NaN NaN]);
end 


%% Plot gaze

figure

plot(visu_x_y(:,1),visu_x_y(:,2))
xlim([-1600 1000])
ylim([-1000 1000])

%% Plot gaze heatmap (in percentage of total gaze)

figure
xgrid = -1600:100:1000;
ygrid = -1000:100:1000;
[hx,centers] = hist3(visu_x_y,'Edges', {xgrid, ygrid});

hx = rot90(hx,3); %reorientation
hx = flip(hx,2); %reorientation
hx = (hx./(sum(sum(hx)))).*100; %pourcentage
imagesc(centers{:}, hx)
xlim([-1600 1000]) %same as above, only for display
ylim([-1000 1000])
colorbar
%axis equal
axis xy

%% Plot temporal repartition of end of saccade

if strcmp(cfg.trialtype,'saccade')
    figure
    n = 100;
    [h , center] = hist(trl(:,6), n);
    bar(center, h./(nb_trials*(trl(1,2)-trl(1,1))/n))
    if cfg.next>0
        Title = ['Isolated saccades (' num2str(cfg.trialdef.presac) ';' num2str(cfg.trialdef.postsac)...
            ') repartition around event #' num2str(cfg.cod) 'followed by event #'...
            num2str(cfg.next) ];
    else
        Title = ['Isolated saccades (' num2str(cfg.trialdef.presac) ';' num2str(cfg.trialdef.postsac)...
            ') repartition around event #' num2str(cfg.cod)];
    end
    
    title(Title)
end