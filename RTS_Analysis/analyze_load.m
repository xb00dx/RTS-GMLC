clear; clc; close all;

default_size = [20,50,720,560];

data_path = ['../RTS_Data/timeseries_data_files/Load/'];
nd = 3; % 3 load regions
load_regions = {'region 1','region 2', 'region 3'};
da_filename = 'DAY_AHEAD_regional_Load.csv';
rt_filename = 'REAL_TIME_regional_load.csv';

opts = detectImportOptions([data_path,da_filename]);
preview([data_path,da_filename],opts)

opts.SelectedVariableNames = 5:7; 
% (day-ahead) get a 8784-by-4 matrix
% (real-time) get a 105408-by-4 matrix
load_data.da = readmatrix([data_path,da_filename],opts); 
load_data.rt = readmatrix([data_path,rt_filename],opts); 
load_data.da(1,:) = []; load_data.rt(1,:) = []; % delete the header "1,2,3"
assert(size(load_data.da,1) == 366*24); % 1 hour resolution
assert(size(load_data.rt,1) == 366*24*12); % 5 min resolution

time_indices.da = 1:1/24:(367-1/24);
time_indices.rt = 1:1/288:(367-1/288);

%% RT-DA Errors, real-time minus day-ahead
load_data.da_rt = zeros(size(load_data.rt,1), nd);
for i = 1:nd
    temp = repmat(load_data.da(:,i),1,288/24)';
    load_data.da_rt(:,i) = temp(:)-load_data.rt(:,i);
end

%% Plotting Wind Profiles
figure('Position',default_size);
for i = 1:nd
    subplot(nd,1,i)
    
    plot(time_indices.rt, load_data.rt(:,i)), hold on,
    plot(time_indices.da, load_data.da(:,i)), hold on,
%     set(gca,'FontSize',12)
    xlabel('day (366 days in total)'),
    ylabel([load_regions{i}, ' (MW)']),
    legend('DA','RT','Location','EastOutside')
    hold off
end

%% DA-RT error
% plot time series
figure('Position',default_size);
plot(time_indices.rt, load_data.da_rt)
xlabel('day (366 days in total)'), ylabel('DA-RT Error (MW)')

% plot histogram
figure('Position',default_size);
for i = 1:nd
    subplot(2,2,i)
    histogram(load_data.da_rt(:,i),20,'FaceColor','#A2142F'),hold on,
%     histfit(load_data.da_rt(:,i),20,'normal') % not a good fit
    xlabel('DA-RT Error (MW)')
    ylabel('frequency (out of 105408)')
    title(load_regions{i})
end

%% DA&RT errors of persistence forecast (a forecast that the future weather
% condition will be the same as the present condition
persist_forecast.da = [NaN, NaN, NaN, NaN; load_data.da(1:(end-1),:)];
persist_forecast.rt = [NaN, NaN, NaN, NaN; load_data.rt(1:(end-1),:)];
persist_forecast_MWerr.da = persist_forecast.da - load_data.da;
persist_forecast_MWerr.rt = persist_forecast.rt - load_data.rt;
% plot DA time series
figure('Position',default_size);
for i = 1:nd
    subplot(nd,1,i)
    plot(time_indices.da, persist_forecast_MWerr.da), hold on,
    xlabel('day (366 days in total)'),
    ylabel([load_regions{i}, ' (MW)']),
    hold off
end

% plot DA histogram
figure('Position',default_size);
for i = 1:nd
    subplot(2,2,i)
    histogram(persist_forecast_MWerr.da,20,'FaceColor','#A2142F'),hold on,
    xlabel('DA persistence forecast error (MW)')
    ylabel([load_regions{i}, ' (MW)']),
    hold off
end

% plot RT time series
figure('Position',default_size);
for i = 1:nd
    subplot(nd,1,i)
    plot(time_indices.rt, persist_forecast_MWerr.rt), hold on,
    xlabel('day (366 days in total)'),
    ylabel([load_regions{i}, ' (MW)']),
    hold off
end

% plot RT histogram
figure('Position',default_size);
for i = 1:nd
    subplot(2,2,i)
    histogram(persist_forecast_MWerr.rt,50,'FaceColor','#A2142F'),hold on,
    xlabel('RT persistence forecast error (MW)')
    ylabel([load_regions{i}, ' (MW)']),
    hold off
end

persist_forecast_percent_err.da = persist_forecast.da ./ load_data.da - 1;
persist_forecast_percent_err.rt = persist_forecast.rt ./ load_data.rt - 1;
% plot DA histogram, sth might be wrong
figure('Position',default_size);
for i = 1:nd
    subplot(2,2,i)
    histogram(persist_forecast_percent_err.da,100,'FaceColor','#A2142F'),hold on,
    xlabel('RT persistence forecast error (%)')
    ylabel(load_regions{i}),
    hold off
end
% plot RT histogram, sth might be wrong
figure('Position',default_size);
for i = 1:nd
    subplot(2,2,i)
    histogram(persist_forecast_percent_err.rt,100,'FaceColor','#A2142F'),hold on,
    xlabel('RT persistence forecast error (%)')
    ylabel(load_regions{i}),
    hold off
end

