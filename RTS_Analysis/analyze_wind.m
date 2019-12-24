clear; clc; close all;

default_size = [20,50,720,560];

data_path = ['../RTS_Data/timeseries_data_files/WIND/'];
nw = 4; % 4 wind farms
wind_names = {'x309-WIND','x317-WIND', 'x303-WIND', 'x122-WIND'};
da_filename = 'DAY_AHEAD_wind.csv';
rt_filename = 'REAL_TIME_wind.csv';

opts = detectImportOptions([data_path,da_filename]);
preview([data_path,da_filename],opts)

opts.SelectedVariableNames = 5:8; 
% ?day-ahead) get a 8784-by-4 matrix
% ?day-ahead) get a 105408-by-4 matrix
wind_data.da = readmatrix([data_path,da_filename],opts); 
wind_data.rt = readmatrix([data_path,rt_filename],opts); 
assert(size(wind_data.da,1) == 366*24); % 1 hour resolution
assert(size(wind_data.rt,1) == 366*24*12); % 5 min resolution

time_indices.da = 1:1/24:(367-1/24);
time_indices.rt = 1:1/288:(367-1/288);

%% RT-DA Errors, real-time minus day-ahead
wind_data.da_rt = zeros(size(wind_data.rt,1), nw);
for iw = 1:nw
    temp = repmat(wind_data.da(:,iw),1,288/24)';
    wind_data.da_rt(:,iw) = temp(:)-wind_data.rt(:,iw);
end


%% Plotting Wind Profiles
figure('Position',default_size);
for iw = 1:nw
    subplot(nw,1,iw)
    plot(time_indices.da, wind_data.da(:,iw)), hold on,
    plot(time_indices.rt, wind_data.rt(:,iw)), hold on,
%     set(gca,'FontSize',12)
    xlabel('day (366 days in total)'),
    ylabel([wind_names{iw}, ' (MW)']),
    legend('DA','RT','Location','EastOutside')
    hold off
end

%% DA-RT error
% examine independence
[corr_mat, p_mat] = corrcoef(wind_data.da_rt);
disp(corr_mat);
disp(p_mat);

% plot time series
figure('Position',default_size);
plot(time_indices.rt, wind_data.da_rt)
xlabel('day (366 days in total)'), ylabel('DA-RT Error (MW)')

% plot histogram
figure('Position',default_size);
for iw = 1:nw
    subplot(2,2,iw)
    histogram(wind_data.da_rt(:,iw),20,'FaceColor','#A2142F', 'Facealpha', 1),hold on,
%     histfit(wind_data.da_rt(:,iw),20,'normal') % not a good fit
    xlabel('DA-RT Error (MW)')
    ylabel('frequency (out of 105408)')
    title(wind_names{iw})
end
% pair() plot, to show correlation
figure('Position',default_size);
plotmatrix(wind_data.da_rt)
title('DA-RT forecast error')

%% DA&RT errors of persistence forecast (a forecast that the future weather
% condition will be the same as the present condition
persist_forecast.da = [NaN, NaN, NaN, NaN; wind_data.da(1:(end-1),:)];
persist_forecast.rt = [NaN, NaN, NaN, NaN; wind_data.rt(1:(end-1),:)];
persist_forecast_MWerr.da = persist_forecast.da - wind_data.da;
persist_forecast_MWerr.rt = persist_forecast.rt - wind_data.rt;
% plot DA time series
figure('Position',default_size);
for iw = 1:nw
    subplot(nw,1,iw)
    plot(time_indices.da, persist_forecast_MWerr.da), hold on,
    xlabel('day (366 days in total)'),
    ylabel([wind_names{iw}, ' (MW)']),
    hold off
end

% plot DA histogram
figure('Position',default_size);
for iw = 1:nw
    subplot(2,2,iw)
    histogram(persist_forecast_MWerr.da,100,'FaceColor','#A2142F', 'Facealpha', 1),hold on,
    xlabel('DA persistence forecast error (MW)')
    ylabel('frequency (out of 8784)')
    title(wind_names{iw})
    hold off
end

% pair() plot, to show correlation
figure('Position',default_size);
plotmatrix(persist_forecast_MWerr.da)
title('DA persistence forecast error')

series = persist_forecast_MWerr.da(2:end,:); % first row is NaN
[corr_mat, p_mat] = corrcoef(series);
disp(corr_mat);
disp(p_mat);

% plot RT time series
figure('Position',default_size);
for iw = 1:nw
    subplot(nw,1,iw)
    plot(time_indices.rt, persist_forecast_MWerr.rt), hold on,
    xlabel('day (366 days in total)'),
    ylabel([wind_names{iw}, ' (MW)']),
    hold off
end

% plot RT histogram
figure('Position',default_size);
for iw = 1:nw
    subplot(2,2,iw)
    histogram(persist_forecast_MWerr.rt,100,'FaceColor','#A2142F', 'Facealpha', 1),hold on,
    xlabel('RT persistence forecast error (MW)')
    ylabel('frequency (out of 105408)')
    title(wind_names{iw})
    hold off
end

% pair() plot, to show correlation
figure('Position',default_size);
plotmatrix(persist_forecast_MWerr.rt)
title('RT persistence forecast error')

series = persist_forecast_MWerr.rt(2:end,:); % first row is NaN
[corr_mat, p_mat] = corrcoef(series);
disp(corr_mat);
disp(p_mat);

return

persist_forecast_percent_err.da = persist_forecast.da ./ wind_data.da - 1;
persist_forecast_percent_err.rt = persist_forecast.rt ./ wind_data.rt - 1;
% plot DA histogram, sth might be wrong
figure('Position',default_size);
for iw = 1:nw
    subplot(2,2,iw)
    histogram(persist_forecast_percent_err.da,100,'FaceColor','#A2142F', 'Facealpha', 1),hold on,
    xlabel('DA persistence forecast error (%)')
    ylabel(wind_names{iw}),
    hold off
end
% plot RT histogram, sth might be wrong
figure('Position',default_size);
for iw = 1:nw
    subplot(2,2,iw)
    histogram(persist_forecast_percent_err.rt,100,'FaceColor','#A2142F', 'Facealpha', 1),hold on,
    xlabel('RT persistence forecast error (%)')
    ylabel(wind_names{iw}),
    hold off
end

