
%% DISPLAY_HYPOXIA %%
% Display rSO2 and SpO2 signals for each hypoxic episode as individual subplots. %

%% PLOT FILTERED TIME INTERVALS %%
% Graph each of the hypoxia episodes that contain both SpO2 and rSO2 data. %

% Create plot with subplots for each hypoxia.
figure
t = tiledlayout(length(interval_lengths), 1);
rso2_row = 0; % Row number in rso2_hyp corresponding to distinct hypoxia
spo2_row = 0; % Row number in spo2_hyp corresponding to distinct hypoxia

% Create each subplot.
for i=1:length(interval_lengths)
    nexttile
    
    yyaxis left
    plot(rso2_hyp(rso2_row+1:rso2_row+interval_lengths(i,1)-1,:),"timeCdt","rso2") % Draw rSO2 signal
    hold on
    yyaxis right
    plot(spo2_hyp(spo2_row+1:spo2_row+interval_lengths(i,2)-1,:),"timeCdt","SpO2") % Draw SpO2 signal
    hold off
    
    legend("rSO2", "SpO2")

    % Increment by current episode length to update index to next episode.
    rso2_row = rso2_row + interval_lengths(i,1);
    spo2_row = spo2_row + interval_lengths(i,2);

    % Not to overwhelm the figures
    if mod(i+1, 3) == 0
        figure
    end
end

% Remove variables that will no longer be used.
clear rso2_row spo2_row i;
